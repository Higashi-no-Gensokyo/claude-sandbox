---
name: xsd-to-rdb
description: >
  XMLスキーマ（XSD）ファイルからリレーショナルデータベースのテーブル設計
  （CREATE TABLE文）を生成するスキル。XSDの要素・属性をテーブル・カラムに
  変換するルール、主キー選択、正規化、型マッピングを定義する。
  「XSDからテーブルを作る」「XMLデータをDBに変換する」「スキーマをSQL化する」
  等の作業時に参照すること。
---

# XSD → RDB テーブル変換ルール

## 基本変換方針

| XSD要素 | RDB要素 |
|---|---|
| ルート配列要素（`maxOccurs="unbounded"` の直接子） | テーブル |
| タグの属性（`xs:attribute`） | カラム |
| 入れ子になった子要素 | 別テーブル（FK で結合） |
| 属性名 | カラム名（**スペルをXSDと完全一致させる** ※後述） |

---

## 型マッピング

| XSD型 | MySQL型 | 備考 |
|---|---|---|
| xs:string | VARCHAR(255) | text/description等の長文属性はTEXT |
| xs:int | INT | |
| xs:decimal | DECIMAL(10,2) | |
| xs:float | FLOAT | |
| xs:boolean | BOOLEAN | TINYINT(1)の別名。NULLを許容する（省略とfalseを区別するため） |
| xs:enumeration | ENUM(...) | XSDのenumeration値をそのまま列挙 |

---

## 主キー選択ルール

### パターン1: ルートテーブル
XSDに `id` 属性が定義されている → その `id` をそのままPRIMARY KEYとする。

### パターン2: 1:1の子テーブル
親テーブルとの関係が `<xs:all>` 内に `maxOccurs` 未指定（=1）で定義されている場合。
→ 親テーブルのFKカラムをPK兼FKとして使う。サロゲートキー不要。

```sql
-- 例: npc_character_face
PRIMARY KEY (npc_character_id),
FOREIGN KEY (npc_character_id) REFERENCES npc_characters(id)
```

### パターン3: 1:Nの子テーブル（自然キーで一意性が保証できる場合）
FK + もう1つの属性の組み合わせで行を一意に特定できる場合。
→ 複合PKを構成する。サロゲートキー不要。

```sql
-- 例: npc_character_skills
PRIMARY KEY (npc_character_id, skill_id),
FOREIGN KEY (npc_character_id) REFERENCES npc_characters(id)
```

### パターン4: 自然キーで一意性を保証できない場合
候補キーにNULL許容カラムが含まれる、または一意性の根拠がない場合。
→ `id INT AUTO_INCREMENT` をサロゲートキーとして追加する。

```sql
-- 例: npc_character_equipment_rosters（civilian=NULL許容で一意性不明）
id INT AUTO_INCREMENT PRIMARY KEY,
FOREIGN KEY (npc_character_id) REFERENCES npc_characters(id)
```

---

## 1:1 vs 1:N の判定方法

XSD内の要素定義を確認する：

```xml
<!-- 1:1 → <xs:all>内、maxOccurs指定なし（デフォルト=1） -->
<xs:all>
  <xs:element name="relationship" minOccurs="0">  ← maxOccurs未指定=1:1

<!-- 1:N → maxOccurs="unbounded" が指定されている -->
<xs:sequence>
  <xs:element name="relationship" minOccurs="0" maxOccurs="unbounded">  ← 1:N
```

**注意**: `<xs:all>` と `<xs:sequence>` では `maxOccurs` のデフォルト動作が異なる。
必ず `maxOccurs` の有無を確認すること。

---

## 属性名のスペル保持ルール（重要）

**XSDの属性名はそのままカラム名に使用する。命名規則の変換（camelCase→snake_case等）を行わない。**

理由：変換するとXMLパース時の属性名とカラム名の対応関係が不明確になるため。

```yaml
# ❌ 誤り: 独自の命名規則に変換
equipment_type   # XSDでは equipmentType と定義されている

# ✅ 正しい: XSD属性名をそのまま使用
equipmentType    # XSDのxs:attribute name="equipmentType" に一致
```

確認方法：
```bash
grep -n "xs:attribute name" /path/to/file.xsd | grep -i "keyword"
```

---

## 多対多・複数ファイル対応の追加カラム

XSDに定義されていないが、複数ファイルの統合のために追加カラムが必要な場合がある。

例：多言語テキストファイル（GameText.xsd）
- XSDの `<string>` 要素は `id` と `text` の2属性のみ
- 言語ごとに別ファイルが存在するため、`language_code` カラムを追加
- `language_code` の値は `language_data.xml` の `<LanguageData id="...">` から取得
- PRIMARY KEY を `(string_id, language_code)` の複合PKとする

追加カラムを設ける場合は**設計書にXSD由来でないことを明記**すること。

---

## 縦持ち変換が有効なケース

同一タグの大量属性が「参照先のID」を持ち、属性名が役割名を表す場合。

```xml
<!-- XSD: Culture要素に約60個のNPC役職参照属性 -->
<xs:attribute name="blacksmith" type="xs:string"/>
<xs:attribute name="tavernkeeper" type="xs:string"/>
...
```

このような場合、横持ち（60カラム）より縦持ちテーブルに変換する：

```sql
CREATE TABLE culture_npc_roles (
  culture_id VARCHAR(255) NOT NULL,
  role_name  VARCHAR(255) NOT NULL,  -- 属性名をそのまま格納
  npc_id     VARCHAR(255) NOT NULL,  -- 属性値（参照先ID）
  PRIMARY KEY (culture_id, role_name)
);
```

---

## XSDパース時の注意点

1. **大きなXSDファイルは必ず分割して読む**（`large-file-reading` スキルを参照）
2. **コメントアウトされた属性を誤って取り込まない**
   ```xml
   <!-- <xs:attribute name="face_key_template" ...> -->  ← 無効、テーブルに含めない
   ```
3. **`<xs:ref>` による参照要素を見落とさない**
   ```xml
   <xs:element ref="equipment"/>  ← 別定義の要素を参照している
   ```
4. **グローバル要素定義（ルートレベルの `<xs:element>`）に注意**
   ファイル先頭で定義されたグローバル要素が子要素から `ref` で参照されることがある。

---

## 設計後のセルフチェックリスト

- [ ] 全XSDファイルを行数確認後、分割読み込みで完全に読んだ
- [ ] 全子要素（1:1・1:N両方）をテーブルとして捕捉した
- [ ] 属性名のスペルをXSDと照合した（特にcamelCaseに注意）
- [ ] 各子要素の maxOccurs を確認し、1:1/1:N を正確に判定した
- [ ] コメントアウトされた属性を誤って含めていないことを確認した
- [ ] XSD由来でない追加カラムを設計書に明記した
- [ ] 複合PKの構成カラムにNULL許容カラムが含まれないことを確認した
