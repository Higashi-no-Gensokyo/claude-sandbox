# MB2 XML→MySQL プロジェクト — Claude への指示書

## プロジェクト概要

Mount & Blade II のゲームデータ（`.xsd` / `.xml`）を MySQL / MariaDB 用の
リレーショナルデータベースに変換するプロジェクト。

---

## リポジトリ構成

```
repository root
├── CLAUDE.md                            ← Claude Code 向け指示書
├── PROJECT_CONTEXT.md                   ← 本ファイル（チャット版 Claude への指示書）
├── xsd/                                 ← ゲーム更新時に差し替えるXSDファイル群
│   ├── NPCCharacters.xsd
│   ├── Heroes.xsd
│   ├── Factions.xsd
│   ├── Kingdoms.xsd
│   ├── SPCultures.xsd
│   └── GameText.xsd
├── db/
│   ├── mb2_db_create.sql                ← CREATE TABLE文（成果物）
│   ├── mb2_db_design.md                 ← テーブル設計書（成果物）
│   └── mb2_db_conversion_rules.yaml     ← XSD→RDB変換ルール定義（成果物）
└── skills/
    ├── xsd-to-rdb_SKILL.md              ← XSD→RDB変換ナレッジ
    └── large-file-reading_SKILL.md      ← 大ファイル安全読み込みナレッジ
```

---

## 作業開始前に必ず読むこと

1. `skills/large-file-reading_SKILL.md` — XSDファイル読み込みの安全手順
2. `skills/xsd-to-rdb_SKILL.md` — テーブル設計の変換ルール
3. `db/mb2_db_conversion_rules.yaml` — 現在の変換ルール定義（差分対照の主軸）

---

## 確定済み設計方針

| 項目 | 決定内容 |
|---|---|
| 出力形式 | MySQL / MariaDB 用 `.sql` スクリプト |
| 文字セット・照合順序 | `utf8mb4` / `utf8mb4_unicode_ci` |
| xs:boolean の型 | `BOOLEAN`（NULL許容。省略とfalseを区別するため） |
| 1:1 子テーブルの PK | FK カラムを PK と兼用（サロゲートキー不要） |
| 1:N 子テーブルの PK | 自然キーで一意性が保証できる場合は複合PK、それ以外はサロゲートキー |
| カラム名 | **XSD属性名をそのまま使用する**（camelCase→snake_case等の変換不可） |
| 子テーブルの `id` リネーム | 親FK（例: `npc_character_id`）との区別がつかない場合のみ `{接頭辞}_id` にリネームし、備考にXSD属性名（`id`）を明記する |
| 制御文 | `DROP TABLE IF EXISTS`（依存の逆順）＋ `SET FOREIGN_KEY_CHECKS=0` を先頭に含める |
| 正規化方針 | 結合より正規化を優先 |

---

## 型マッピング

| XSD型 | MySQL型 | 備考 |
|---|---|---|
| xs:string | VARCHAR(255) | text/description等の長文はTEXT |
| xs:int | INT | |
| xs:decimal | DECIMAL(10,2) | |
| xs:float | FLOAT | |
| xs:boolean | BOOLEAN | NULL許容 |
| enumeration | ENUM(...) | XSDのenumeration値をそのまま列挙 |

---

## 対象カテゴリと対象XSDファイル

| カテゴリ | XSDファイル | テーブル数 |
|---|---|---|
| キャラクター関連 | NPCCharacters.xsd, Heroes.xsd | 17 |
| 勢力・文化関連 | Factions.xsd, Kingdoms.xsd, SPCultures.xsd | 26 |
| セリフ・テキスト | GameText.xsd | 2 |
| **合計** | | **45** |

除外対象: アニメーション・サウンド・テクスチャ・モーション等の非言語データ

---

## XSD更新時のワークフロー

### インプット
GitHubのPull RequestのURLを以下の形式で受け取る:
```
https://github.com/{user}/{repo}/pull/{N}.diff
```
※ `.diff` 形式（プレーンテキスト）を使用すること。

### 作業手順
1. `web_fetch` で `.diff` URLを取得し、変更内容を把握する
2. `db/mb2_db_conversion_rules.yaml` と照合し、影響テーブル・カラムを特定する
3. `skills/xsd-to-rdb_SKILL.md` のチェックリストに従って設計を見直す
4. 以下のファイルの該当箇所のみを更新する:
   - `db/mb2_db_conversion_rules.yaml`
   - `db/mb2_db_design.md`
   - `db/mb2_db_create.sql`
5. 更新したファイルをユーザーに提示し、プロジェクトへの反映を依頼する

---

## ファイル更新後のユーザーへの通知ルール

作業でファイルを生成・更新した場合、必ず以下を明示すること:

```
【プロジェクトへの反映をお願いします】
- 新規追加: ファイル名
- 上書き更新: ファイル名
```

---

## 過去の主な修正履歴（再発防止のための記録）

| 発生箇所 | 内容 | 原因 |
|---|---|---|
| SPCultures.xsd | 子要素テーブル10件の漏れ | viewツールによる中間行の自動切り捨て |
| npc_character_equipment_sets | カラム名 `equipment_type` → `equipmentType` | XSD属性名を確認せずsnake_caseに変換した |
| faction_relationships | 多重度を 1:N → 1:1 に修正 | `<xs:all>` と `<xs:sequence>` の違いを見落とした |
| culture_role_refs | テーブル名 `culture_npc_roles` → `culture_role_refs`、カラム名 `npc_id` → `ref_id` | 縦持ち化した属性群の参照先を実XMLで確認せず、NPCCharacter参照のみと思い込んだ（実際はPartyTemplateも混在） |
| kingdom_relationships | カラム名 `is_at_war` → `isAtWar` | XSD属性名（camelCase）を確認せずsnake_caseに変換した |
