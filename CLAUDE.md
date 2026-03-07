# MB2 XML→MySQL プロジェクト — CLAUDE.md

Mount & Blade II のゲームデータ（`.xsd` / `.xml`）を
MySQL / MariaDB 用リレーショナルデータベースに変換するプロジェクト。

---

## リポジトリ構成

```
repository root
├── CLAUDE.md                            ← 本ファイル（Claude Code 向け指示書）
├── PROJECT_CONTEXT.md                   ← チャット向け指示書（Claude Code では読まなくてよい）
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
│   └── mb2_db_conversion_rules.yaml     ← XSD→RDB変換ルール定義（差分対照の主軸）
└── skills/
    ├── xsd-to-rdb_SKILL.md              ← XSD→RDB変換ナレッジ
    └── large-file-reading_SKILL.md      ← 大ファイル安全読み込みナレッジ
```

---

## タスク着手前に必ず読むこと

作業種別に応じて、以下を必ず読んでから作業を開始すること。

| 作業種別 | 必読ファイル |
|---|---|
| XSD読み込み・テーブル設計 | `skills/large-file-reading_SKILL.md` → `skills/xsd-to-rdb_SKILL.md` → `db/mb2_db_conversion_rules.yaml` |
| SQL生成・修正 | `db/mb2_db_design.md` → `db/mb2_db_create.sql` |
| XML解析・データ変換 | `db/mb2_db_design.md`（テーブル構造の確認） |
| 上記以外の単発タスク | 不要（タスク内容に応じて判断） |

---

## 確定済み設計方針

| 項目 | 決定内容 |
|---|---|
| 出力形式 | MySQL / MariaDB 用 `.sql` スクリプト |
| 文字セット・照合順序 | `utf8mb4` / `utf8mb4_unicode_ci` |
| xs:boolean の型 | `BOOLEAN`（NULL許容。省略とfalseを区別するため） |
| 1:1 子テーブルの PK | FK カラムを PK と兼用（サロゲートキー不要） |
| 1:N 子テーブルの PK | 自然キーで一意性が保証できる場合は複合PK、それ以外はサロゲートキー |
| カラム名 | **XSD属性名をそのまま使用**（camelCase→snake_case等の変換不可） |
| 子テーブルの `id` リネーム | 親FK（例: `npc_character_id`）との区別がつかない場合のみ `{接頭辞}_id` にリネームし、備考にXSD属性名（`id`）を明記する |
| 制御文 | `DROP TABLE IF EXISTS`（依存の逆順）＋ `SET FOREIGN_KEY_CHECKS=0` を先頭に含める |
| 正規化方針 | 結合より正規化を優先 |

---

## 型マッピング

| XSD型 | MySQL型 | 備考 |
|---|---|---|
| xs:string | VARCHAR(255) | text / description 等の長文属性は TEXT |
| xs:int | INT | |
| xs:decimal | DECIMAL(10,2) | |
| xs:float | FLOAT | |
| xs:boolean | BOOLEAN | NULL許容 |
| enumeration | ENUM(...) | XSDのenumeration値をそのまま列挙 |

---

## 対象カテゴリとテーブル数

| カテゴリ | XSDファイル | テーブル数 |
|---|---|---|
| キャラクター関連 | NPCCharacters.xsd, Heroes.xsd | 17 |
| 勢力・文化関連 | Factions.xsd, Kingdoms.xsd, SPCultures.xsd | 26 |
| セリフ・テキスト | GameText.xsd | 2 |
| **合計** | | **45** |

除外対象: アニメーション・サウンド・テクスチャ・モーション等の非言語データ

---

## 成果物ファイルの更新ルール

以下3ファイルは常にセットで整合性を保つこと。
片方だけ更新して残りを放置しない。

1. `db/mb2_db_conversion_rules.yaml` — 変換ルールの正本
2. `db/mb2_db_design.md` — 人間向けの設計書
3. `db/mb2_db_create.sql` — 実行可能なDDL

---

## XSD更新時のワークフロー

```
1. git diff / PR diff で変更箇所を特定する
2. db/mb2_db_conversion_rules.yaml と照合し、影響テーブル・カラムを特定する
3. skills/xsd-to-rdb_SKILL.md のチェックリストに従って設計を見直す
4. 上記3ファイルの該当箇所のみを更新する（全書き換えしない）
```

---

## 過去の主な設計ミスと原因（再発防止）

| 発生箇所 | 内容 | 原因 |
|---|---|---|
| SPCultures.xsd | 子要素テーブル10件の漏れ | ファイルの中間行が自動切り捨てされた |
| npc_character_equipment_sets | `equipment_type` → `equipmentType` | XSD属性名を確認せずsnake_caseに変換した |
| faction_relationships | 多重度を 1:N → 1:1 に修正 | `<xs:all>` と `<xs:sequence>` の違いを見落とした |
| culture_role_refs | テーブル名・カラム名の誤り | 縦持ち化した属性群の参照先を実XMLで確認せず、NPCCharacter参照のみと思い込んだ（実際はPartyTemplateも混在） |
| kingdom_relationships | `is_at_war` → `isAtWar` | XSD属性名（camelCase）を確認せずsnake_caseに変換した |
