# Mount & Blade II — XMLデータ → MySQL 変換設計書

## 1. 概要

| 項目 | 内容 |
|---|---|
| 変換元 | Mount & Blade II ゲーム内データ（.xml / .xsd） |
| 変換先 | MySQL / MariaDB 用 SQLスクリプト（.sql） |
| 対象カテゴリ | キャラクター関連・勢力/文化関連・セリフ/テキスト関連（多言語） |
| 除外カテゴリ | アニメーション・サウンド・テクスチャ・モーション・ムービー等の非言語データ |

---

## 2. 設計方針

### 2.1. 基本方針

- `.xsd` のタグ名 → テーブル名
- `.xsd` の属性名 → カラム名（**スペルをXSD属性名と完全一致させる。camelCase→snake_case等の変換不可**）
- `.xsd` の属性型 → MySQLカラム型（型マッピングは下記参照）
- 入れ子構造（親子タグ）→ 別テーブルに分離し、FOREIGN KEY で結合
- 正規化を優先（結合より正規化）
- 子テーブルにおける `id` 属性は、参照先との区別がつかない場合に限り `{参照先を表す接頭辞}_id` にリネームする（例: `skill > id` → `skill_id`、`upgrade_target > id` → `target_npc_character_id`）。リネームした場合は備考にXSD属性名（`id`）を明記する

### 2.2. 型マッピング

| XSD型 | MySQLカラム型 |
|---|---|
| xs:string | VARCHAR(255) ※ text系は TEXT |
| xs:int | INT |
| xs:decimal | DECIMAL(10,2) |
| xs:float | FLOAT |
| xs:boolean | BOOLEAN（TINYINT の別名） |
| enumeration | ENUM(...) |

### 2.3. 文字セット・照合順序

- `utf8mb4 / utf8mb4_unicode_ci`（多言語対応・推奨）

### 2.4. 主キー方針

- XSD に `id` 属性（ゲーム内ID文字列）が定義されているテーブル → その `id` を PRIMARY KEY とする
- 参照元テーブルと **1:1** の子テーブル → FK カラムをそのまま PK と兼用する（サロゲートキー不要）
- 参照元テーブルと **1:N** の子テーブルで、FK と他の自然キーの組み合わせで行を一意に特定できる場合 → それらの複合主キーとする（サロゲートキー不要）
- 上記いずれにも該当しない子テーブル（NULL許容カラムが候補キーに含まれる場合など）→ `id INT AUTO_INCREMENT` をサロゲートキーとして追加

---

## 3. テーブル設計

### 3.1. カテゴリ1: キャラクター関連

#### 3.1.1. `npc_characters`

|項目|説明|
|:--|:--|
|テーブル名|`npc_characters`|
|説明|ゲーム内に登場するすべてのNPCキャラクターの基本情報を格納するルートテーブル。兵士・コンパニオン・領主など種別を問わず全NPCを収録する。|
|テーブル種別|ルートテーブル|
|親テーブル|無し|
|子テーブル|`npc_character_face`, `npc_character_hair_tags`, `npc_character_beard_tags`, `npc_character_tattoo_tags`, `npc_character_skills`, `npc_character_traits`, `npc_character_feats`, `npc_character_upgrade_targets`, `npc_character_equipment_rosters`, `npc_character_equipment_sets`, `npc_character_hero`, `npc_character_companions`, `npc_character_lords`, `npc_character_resistances`|
|変換元スキーマ要素|`NPCCharacters > NPCCharacter`|
|変換元スキーマ定義ファイル|`NPCCharacters.xsd`|

| カラム名 | 型 | NULL | 備考 |
|---|---|---|---|
| id | VARCHAR(255) | NOT NULL | PK |
| default_group | VARCHAR(255) | NULL | |
| voice | VARCHAR(255) | NULL | |
| is_hero | VARCHAR(255) | NULL | |
| is_female | VARCHAR(255) | NULL | |
| race | VARCHAR(255) | NULL | |
| is_basic_troop | VARCHAR(255) | NULL | |
| is_template | BOOLEAN | NULL | |
| is_child_template | BOOLEAN | NULL | |
| is_hidden_encyclopedia | BOOLEAN | NULL | |
| face_mesh_cache | BOOLEAN | NULL | |
| is_obsolete | BOOLEAN | NULL | |
| culture | VARCHAR(255) | NOT NULL | → cultures.id（書式: Culture.xxx） |
| name | VARCHAR(255) | NULL | |
| banner_symbol_mesh_name | VARCHAR(255) | NULL | |
| banner_symbol_color | VARCHAR(255) | NULL | 書式: 0xRRGGBBAA |
| banner_key | VARCHAR(255) | NULL | |
| occupation | VARCHAR(255) | NULL | |
| is_companion | VARCHAR(255) | NULL | |
| offset | VARCHAR(255) | NULL | |
| level | VARCHAR(255) | NULL | |
| age | VARCHAR(255) | NULL | |
| is_mercenary | VARCHAR(255) | NULL | |
| formation_position_preference | VARCHAR(255) | NULL | |
| default_equipment_set | VARCHAR(255) | NULL | |
| skill_template | VARCHAR(255) | NULL | |
| upgrade_requires | VARCHAR(255) | NULL | 書式: ItemCategory.xxx |

---

#### 3.1.2. `npc_character_face`

|項目|説明|
|:--|:--|
|テーブル名|`npc_character_face`|
|説明|NPCの顔・体型パラメータ（BodyProperties）を格納する。NPCCharacterと1対1で対応する。|
|テーブル種別|子テーブル（1:1）|
|親テーブル|`npc_characters`|
|子テーブル|無し|
|変換元スキーマ要素|`NPCCharacter > face`|
|変換元スキーマ定義ファイル|`NPCCharacters.xsd`|

| カラム名 | 型 | NULL | 備考 |
|---|---|---|---|
| npc_character_id | VARCHAR(255) | NOT NULL | PK 兼 FK → npc_characters.id |
| face_key_value | VARCHAR(255) | NULL | |
| face_key_max_value | VARCHAR(255) | NULL | |
| body_properties_version | VARCHAR(255) | NULL | |
| body_properties_age | VARCHAR(255) | NULL | |
| body_properties_weight | VARCHAR(255) | NULL | |
| body_properties_build | VARCHAR(255) | NULL | |
| body_properties_key | VARCHAR(255) | NULL | |
| body_properties_max_version | VARCHAR(255) | NULL | |
| body_properties_max_age | VARCHAR(255) | NULL | |
| body_properties_max_weight | VARCHAR(255) | NULL | |
| body_properties_max_build | VARCHAR(255) | NULL | |
| body_properties_max_key | VARCHAR(255) | NULL | |
| face_key_template_value | VARCHAR(255) | NULL | |
| body_properties_template_value | VARCHAR(255) | NULL | 書式: BodyProperty.xxx |

---

#### 3.1.3. `npc_character_hair_tags`

|項目|説明|
|:--|:--|
|テーブル名|`npc_character_hair_tags`|
|説明|NPCに適用可能なヘアスタイルのタグ一覧。1NPCに対して複数のタグが対応する。|
|テーブル種別|子テーブル（1:N）|
|親テーブル|`npc_characters`|
|子テーブル|無し|
|変換元スキーマ要素|`NPCCharacter > face > hair_tags > hair_tag`|
|変換元スキーマ定義ファイル|`NPCCharacters.xsd`|

| カラム名 | 型 | NULL | 備考 |
|---|---|---|---|
| npc_character_id | VARCHAR(255) | NOT NULL | 複合PK（1/2） FK → npc_characters.id |
| name | VARCHAR(255) | NOT NULL | 複合PK（2/2） |

PRIMARY KEY: `(npc_character_id, name)`

---

#### 3.1.4. `npc_character_beard_tags`

|項目|説明|
|:--|:--|
|テーブル名|`npc_character_beard_tags`|
|説明|NPCに適用可能なひげスタイルのタグ一覧。1NPCに対して複数のタグが対応する。|
|テーブル種別|子テーブル（1:N）|
|親テーブル|`npc_characters`|
|子テーブル|無し|
|変換元スキーマ要素|`NPCCharacter > face > beard_tags > beard_tag`|
|変換元スキーマ定義ファイル|`NPCCharacters.xsd`|

| カラム名 | 型 | NULL | 備考 |
|---|---|---|---|
| npc_character_id | VARCHAR(255) | NOT NULL | 複合PK（1/2） FK → npc_characters.id |
| name | VARCHAR(255) | NOT NULL | 複合PK（2/2） |

PRIMARY KEY: `(npc_character_id, name)`

---

#### 3.1.5. `npc_character_tattoo_tags`

|項目|説明|
|:--|:--|
|テーブル名|`npc_character_tattoo_tags`|
|説明|NPCに適用可能なタトゥーのタグ一覧。1NPCに対して複数のタグが対応する。|
|テーブル種別|子テーブル（1:N）|
|親テーブル|`npc_characters`|
|子テーブル|無し|
|変換元スキーマ要素|`NPCCharacter > face > tattoo_tags > tattoo_tag`|
|変換元スキーマ定義ファイル|`NPCCharacters.xsd`|

| カラム名 | 型 | NULL | 備考 |
|---|---|---|---|
| npc_character_id | VARCHAR(255) | NOT NULL | 複合PK（1/2） FK → npc_characters.id |
| name | VARCHAR(255) | NOT NULL | 複合PK（2/2） |

PRIMARY KEY: `(npc_character_id, name)`

---

#### 3.1.6. `npc_character_skills`

|項目|説明|
|:--|:--|
|テーブル名|`npc_character_skills`|
|説明|NPCが保有するスキルとそのレベル値の一覧。1NPCに対して複数スキルが対応する。|
|テーブル種別|子テーブル（1:N）|
|親テーブル|`npc_characters`|
|子テーブル|無し|
|変換元スキーマ要素|`NPCCharacter > skills > skill`|
|変換元スキーマ定義ファイル|`NPCCharacters.xsd`|

| カラム名 | 型 | NULL | 備考 |
|---|---|---|---|
| npc_character_id | VARCHAR(255) | NOT NULL | 複合PK（1/2） FK → npc_characters.id |
| skill_id | VARCHAR(255) | NOT NULL | XSD属性名は `id`。npc_character_id との区別のためリネーム。複合PK（2/2） |

---

#### 3.1.7. `npc_character_traits`

|項目|説明|
|:--|:--|
|テーブル名|`npc_character_traits`|
|説明|NPCが保有するトレイト（性格特性）とその値の一覧。1NPCに対して複数トレイトが対応する。|
|テーブル種別|子テーブル（1:N）|
|親テーブル|`npc_characters`|
|子テーブル|無し|
|変換元スキーマ要素|`NPCCharacter > Traits > Trait`|
|変換元スキーマ定義ファイル|`NPCCharacters.xsd`|

| カラム名 | 型 | NULL | 備考 |
|---|---|---|---|
| npc_character_id | VARCHAR(255) | NOT NULL | 複合PK（1/2） FK → npc_characters.id |
| trait_id | VARCHAR(255) | NOT NULL | XSD属性名は `id`。npc_character_id との区別のためリネーム。複合PK（2/2） |

---

#### 3.1.8. `npc_character_feats`

|項目|説明|
|:--|:--|
|テーブル名|`npc_character_feats`|
|説明|NPCが保有する特技（feat）とその値の一覧。1NPCに対して複数featが対応する。|
|テーブル種別|子テーブル（1:N）|
|親テーブル|`npc_characters`|
|子テーブル|無し|
|変換元スキーマ要素|`NPCCharacter > feats > feat`|
|変換元スキーマ定義ファイル|`NPCCharacters.xsd`|

| カラム名 | 型 | NULL | 備考 |
|---|---|---|---|
| npc_character_id | VARCHAR(255) | NOT NULL | 複合PK（1/2） FK → npc_characters.id |
| feat_id | VARCHAR(255) | NOT NULL | XSD属性名は `id`。npc_character_id との区別のためリネーム。複合PK（2/2） |

---

#### 3.1.9. `npc_character_upgrade_targets`

|項目|説明|
|:--|:--|
|テーブル名|`npc_character_upgrade_targets`|
|説明|兵士NPCのアップグレード先NPC（上位兵種）への参照。npc_characters テーブルへの自己参照関係。|
|テーブル種別|子テーブル（1:N）|
|親テーブル|`npc_characters`|
|子テーブル|無し|
|変換元スキーマ要素|`NPCCharacter > upgrade_targets > upgrade_target`|
|変換元スキーマ定義ファイル|`NPCCharacters.xsd`|

| カラム名 | 型 | NULL | 備考 |
|---|---|---|---|
| npc_character_id | VARCHAR(255) | NOT NULL | 複合PK（1/2） FK → npc_characters.id |
| target_npc_character_id | VARCHAR(255) | NOT NULL | XSD属性名は `id`。npc_character_id との区別のためリネーム。複合PK（2/2） FK → npc_characters.id（自己参照）書式: NPCCharacter.xxx |

PRIMARY KEY: `(npc_character_id, target_npc_character_id)`

---

#### 3.1.10. `npc_character_equipment_rosters`

|項目|説明|
|:--|:--|
|テーブル名|`npc_character_equipment_rosters`|
|説明|NPCの装備ロスター（装備セットの集合体）を格納する。1NPCに複数のロスターが存在しうる。civilian フラグで民間用か戦闘用かを区別する。|
|テーブル種別|子テーブル（1:N）|
|親テーブル|`npc_characters`|
|子テーブル|`npc_character_equipment_items`|
|変換元スキーマ要素|`NPCCharacter > Equipments > EquipmentRoster`|
|変換元スキーマ定義ファイル|`NPCCharacters.xsd`|

| カラム名 | 型 | NULL | 備考 |
|---|---|---|---|
| id | INT AUTO_INCREMENT | NOT NULL | PK |
| npc_character_id | VARCHAR(255) | NOT NULL | FK → npc_characters.id |
| civilian | BOOLEAN | NULL | |

---

#### 3.1.11. `npc_character_equipment_items`

|項目|説明|
|:--|:--|
|テーブル名|`npc_character_equipment_items`|
|説明|装備ロスターに含まれる個々の装備アイテムとスロット情報を格納する。|
|テーブル種別|子テーブル（1:N）|
|親テーブル|`npc_character_equipment_rosters`|
|子テーブル|無し|
|変換元スキーマ要素|`NPCCharacter > Equipments > EquipmentRoster > equipment`|
|変換元スキーマ定義ファイル|`NPCCharacters.xsd`|

| カラム名 | 型 | NULL | 備考 |
|---|---|---|---|
| id | INT AUTO_INCREMENT | NOT NULL | PK |
| equipment_roster_id | INT | NOT NULL | FK → npc_character_equipment_rosters.id |
| slot | VARCHAR(255) | NULL | |
| item_id | VARCHAR(255) | NULL | |
| amount | VARCHAR(255) | NULL | |

---

#### 3.1.12. `npc_character_equipment_sets`

|項目|説明|
|:--|:--|
|テーブル名|`npc_character_equipment_sets`|
|説明|NPCに紐づく装備セット（Battle / Civilian / Stealth）の参照情報を格納する。|
|テーブル種別|子テーブル（1:N）|
|親テーブル|`npc_characters`|
|子テーブル|無し|
|変換元スキーマ要素|`NPCCharacter > Equipments > EquipmentSet`|
|変換元スキーマ定義ファイル|`NPCCharacters.xsd`|

| カラム名 | 型 | NULL | 備考 |
|---|---|---|---|
| npc_character_id | VARCHAR(255) | NOT NULL | 複合PK（1/2） FK → npc_characters.id |
| set_id | VARCHAR(255) | NOT NULL | 複合PK（2/2） |
| civilian | BOOLEAN | NULL | |
| equipmentType | ENUM('Battle','Civilian','Stealth') | NULL | ※XSD属性名はcamelCase |

PRIMARY KEY: `(npc_character_id, set_id)`

---

#### 3.1.13. `npc_character_hero`

|項目|説明|
|:--|:--|
|テーブル名|`npc_character_hero`|
|説明|NPCCharacters.xsd の `NPCCharacter > Hero` 子要素を格納する。`Hero` 要素はNPCのヒーロー属性（所属派閥・家族関係等）を保持し、Heroes.xsd 由来の `heroes` テーブルへの参照（`hero_id`）を持つ。2つのXSDにまたがる連結関係を表す唯一のテーブル。|
|テーブル種別|子テーブル（1:1）|
|親テーブル|`npc_characters`|
|子テーブル|無し|
|変換元スキーマ要素|`NPCCharacter > Hero`|
|変換元スキーマ定義ファイル|`NPCCharacters.xsd`|

| カラム名 | 型 | NULL | 備考 |
|---|---|---|---|
| npc_character_id | VARCHAR(255) | NOT NULL | PK 兼 FK → npc_characters.id |
| hero_id | VARCHAR(255) | NOT NULL | XSD属性名は `id`。npc_character_id との区別のためリネーム。FK → heroes.id（Heroes.xsdとの連結） |
| banner_key | VARCHAR(255) | NULL | |
| text | TEXT | NULL | |
| spouse | VARCHAR(255) | NULL | |
| alive | VARCHAR(255) | NULL | |
| voice | VARCHAR(255) | NULL | |
| father | VARCHAR(255) | NULL | |
| mother | VARCHAR(255) | NULL | |
| faction | VARCHAR(255) | NULL | 書式: Faction.xxx |
| clan | VARCHAR(255) | NULL | 書式: Clan.xxx |

---

#### 3.1.14. `npc_character_companions`

|項目|説明|
|:--|:--|
|テーブル名|`npc_character_companions`|
|説明|Components 要素内の Companion 子要素を格納する。あるNPCがコンパニオンとして紐づく別NPCへの自己参照関係を表す。|
|テーブル種別|子テーブル（1:N）|
|親テーブル|`npc_characters`|
|子テーブル|無し|
|変換元スキーマ要素|`NPCCharacter > Components > Companion`|
|変換元スキーマ定義ファイル|`NPCCharacters.xsd`|

| カラム名 | 型 | NULL | 備考 |
|---|---|---|---|
| npc_character_id | VARCHAR(255) | NOT NULL | 複合PK（1/2） FK → npc_characters.id |
| companion_id | VARCHAR(255) | NOT NULL | 複合PK（2/2） FK → npc_characters.id（自己参照） |

PRIMARY KEY: `(npc_character_id, companion_id)`

---

#### 3.1.15. `npc_character_lords`

|項目|説明|
|:--|:--|
|テーブル名|`npc_character_lords`|
|説明|Components 要素内の Lord 子要素を格納する。あるNPCが主君として紐づく別NPCへの自己参照関係と、その関係固有の属性（banner_key / spouse 等）を保持する。Companion とはカラム構成が異なるため別テーブルとして分離。|
|テーブル種別|子テーブル（1:N）|
|親テーブル|`npc_characters`|
|子テーブル|無し|
|変換元スキーマ要素|`NPCCharacter > Components > Lord`|
|変換元スキーマ定義ファイル|`NPCCharacters.xsd`|

| カラム名 | 型 | NULL | 備考 |
|---|---|---|---|
| npc_character_id | VARCHAR(255) | NOT NULL | 複合PK（1/2） FK → npc_characters.id |
| lord_id | VARCHAR(255) | NOT NULL | 複合PK（2/2） FK → npc_characters.id（自己参照） |
| banner_key | VARCHAR(255) | NULL | |
| spouse | VARCHAR(255) | NULL | |
| voice | VARCHAR(255) | NULL | |
| father | VARCHAR(255) | NULL | |
| mother | VARCHAR(255) | NULL | |

PRIMARY KEY: `(npc_character_id, lord_id)`

---

#### 3.1.16. `npc_character_resistances`

|項目|説明|
|:--|:--|
|テーブル名|`npc_character_resistances`|
|説明|NPCの各種ダメージ耐性値（ノックバック・ノックダウン・落馬）を格納する。NPCCharacterと1対1で対応する。|
|テーブル種別|子テーブル（1:1）|
|親テーブル|`npc_characters`|
|子テーブル|無し|
|変換元スキーマ要素|`NPCCharacter > Resistances`|
|変換元スキーマ定義ファイル|`NPCCharacters.xsd`|

| カラム名 | 型 | NULL | 備考 |
|---|---|---|---|
| npc_character_id | VARCHAR(255) | NOT NULL | PK 兼 FK → npc_characters.id |
| knockback | INT | NULL | |
| knockdown | INT | NULL | |
| dismount | INT | NULL | |

---

#### 3.1.17. `heroes`

|項目|説明|
|:--|:--|
|テーブル名|`heroes`|
|説明|Heroes.xsd で定義される主要ヒーロー（プレイヤーキャラクター・主要NPC）の一覧。father / mother / spouse は同テーブル内への自己参照。|
|テーブル種別|ルートテーブル|
|親テーブル|無し|
|子テーブル|無し（スコープ内）|
|変換元スキーマ要素|`Heroes > Hero`|
|変換元スキーマ定義ファイル|`Heroes.xsd`|

| カラム名 | 型 | NULL | 備考 |
|---|---|---|---|
| id | VARCHAR(255) | NOT NULL | PK |
| father | VARCHAR(255) | NULL | FK → heroes.id（自己参照） |
| mother | VARCHAR(255) | NULL | FK → heroes.id（自己参照） |
| faction | VARCHAR(255) | NOT NULL | → factions.id |
| banner_key | VARCHAR(255) | NULL | |
| spouse | VARCHAR(255) | NULL | FK → heroes.id（自己参照） |
| alive | BOOLEAN | NULL | |
| text | TEXT | NULL | |
| preferred_upgrade_formation | VARCHAR(255) | NULL | |
| banner_item | VARCHAR(255) | NULL | |

---

### 3.2. カテゴリ2: 勢力・文化関連

#### 3.2.1. `factions`

|項目|説明|
|:--|:--|
|テーブル名|`factions`|
|説明|氏族・勢力などの派閥情報を格納するルートテーブル。クラン・王国・盗賊団等、種別を問わずすべての派閥を収録する。|
|テーブル種別|ルートテーブル|
|親テーブル|無し|
|子テーブル|`faction_relationships`, `faction_minor_faction_templates`|
|変換元スキーマ要素|`Factions > Faction`|
|変換元スキーマ定義ファイル|`Factions.xsd`|

| カラム名 | 型 | NULL | 備考 |
|---|---|---|---|
| id | VARCHAR(255) | NOT NULL | PK |
| initial_home_settlement | VARCHAR(255) | NOT NULL | 書式: Settlement.xxx |
| banner_key | VARCHAR(255) | NULL | |
| tier | DECIMAL(10,2) | NOT NULL | |
| owner | VARCHAR(255) | NULL | → heroes.id（書式: Hero.xxx） |
| color | VARCHAR(255) | NULL | 書式: 0xRRGGBBAA |
| color2 | VARCHAR(255) | NULL | 書式: 0xRRGGBBAA |
| culture | VARCHAR(255) | NULL | → cultures.id（書式: Culture.xxx） |
| super_faction | VARCHAR(255) | NULL | → kingdoms.id（書式: Kingdom.xxx） |
| default_party_template | VARCHAR(255) | NULL | 書式: PartyTemplate.xxx |
| is_bandit | BOOLEAN | NULL | |
| is_noble | BOOLEAN | NULL | |
| is_minor_faction | BOOLEAN | NULL | |
| is_outlaw | BOOLEAN | NULL | |
| is_clan_type_mercenary | BOOLEAN | NULL | |
| is_nomad | BOOLEAN | NULL | |
| is_sect | BOOLEAN | NULL | |
| is_mafia | BOOLEAN | NULL | |
| settlement_banner_mesh | VARCHAR(255) | NULL | |
| flag_mesh | VARCHAR(255) | NULL | |
| name | VARCHAR(255) | NOT NULL | |
| short_name | VARCHAR(255) | NULL | |
| text | TEXT | NULL | |

---

#### 3.2.2. `faction_relationships`

|項目|説明|
|:--|:--|
|テーブル名|`faction_relationships`|
|説明|派閥の他の派閥（クランまたは王国）との関係値を格納する。factions と1対1で対応する。|
|テーブル種別|子テーブル（1:1）|
|親テーブル|`factions`|
|子テーブル|無し|
|変換元スキーマ要素|`Faction > relationship`|
|変換元スキーマ定義ファイル|`Factions.xsd`|

| カラム名 | 型 | NULL | 備考 |
|---|---|---|---|
| faction_id | VARCHAR(255) | NOT NULL | PK 兼 FK → factions.id |
| clan | VARCHAR(255) | NULL | → factions.id（書式: Faction.xxx） |
| kingdom | VARCHAR(255) | NULL | → kingdoms.id（書式: Kingdom.xxx） |
| value | INT | NOT NULL | |

---

#### 3.2.3. `faction_minor_faction_templates`

|項目|説明|
|:--|:--|
|テーブル名|`faction_minor_faction_templates`|
|説明|マイナー派閥が使用するNPCテンプレートの一覧。1派閥に複数のテンプレートが対応する。|
|テーブル種別|子テーブル（1:N）|
|親テーブル|`factions`|
|子テーブル|無し|
|変換元スキーマ要素|`Faction > minor_faction_character_templates > template`|
|変換元スキーマ定義ファイル|`Factions.xsd`|

| カラム名 | 型 | NULL | 備考 |
|---|---|---|---|
| faction_id | VARCHAR(255) | NOT NULL | 複合PK（1/2） FK → factions.id |
| template_npc_character_id | VARCHAR(255) | NOT NULL | XSD属性名は `id`。faction_id との区別のためリネーム。複合PK（2/2） → npc_characters.id（書式: NPCCharacter.xxx） |

PRIMARY KEY: `(faction_id, template_npc_character_id)`

---

#### 3.2.4. `kingdoms`

|項目|説明|
|:--|:--|
|テーブル名|`kingdoms`|
|説明|王国情報を格納するルートテーブル。factions とは独立したスキーマで定義される上位概念の派閥。|
|テーブル種別|ルートテーブル|
|親テーブル|無し|
|子テーブル|`kingdom_relationships`, `kingdom_policies`|
|変換元スキーマ要素|`Kingdoms > Kingdom`|
|変換元スキーマ定義ファイル|`Kingdoms.xsd`|

| カラム名 | 型 | NULL | 備考 |
|---|---|---|---|
| id | VARCHAR(255) | NOT NULL | PK |
| initial_home_settlement | VARCHAR(255) | NOT NULL | 書式: Settlement.xxx |
| banner_key | VARCHAR(255) | NULL | |
| owner | VARCHAR(255) | NULL | → heroes.id（書式: Hero.xxx） |
| primary_banner_color | VARCHAR(255) | NOT NULL | 書式: 0xRRGGBBAA |
| secondary_banner_color | VARCHAR(255) | NOT NULL | 書式: 0xRRGGBBAA |
| color | VARCHAR(255) | NULL | 書式: 0xRRGGBBAA |
| color2 | VARCHAR(255) | NULL | 書式: 0xRRGGBBAA |
| culture | VARCHAR(255) | NOT NULL | → cultures.id（書式: Culture.xxx） |
| settlement_banner_mesh | VARCHAR(255) | NULL | |
| flag_mesh | VARCHAR(255) | NULL | |
| name | VARCHAR(255) | NOT NULL | |
| short_name | VARCHAR(255) | NULL | |
| text | TEXT | NULL | |
| title | VARCHAR(255) | NULL | |
| ruler_title | VARCHAR(255) | NULL | |

---

#### 3.2.5. `kingdom_relationships`

|項目|説明|
|:--|:--|
|テーブル名|`kingdom_relationships`|
|説明|王国の他の派閥（クランまたは王国）との関係値・戦争状態を格納する。1王国に複数の関係レコードが対応する。|
|テーブル種別|子テーブル（1:N）|
|親テーブル|`kingdoms`|
|子テーブル|無し|
|変換元スキーマ要素|`Kingdom > relationship`|
|変換元スキーマ定義ファイル|`Kingdoms.xsd`|

| カラム名 | 型 | NULL | 備考 |
|---|---|---|---|
| id | INT AUTO_INCREMENT | NOT NULL | PK |
| kingdom_id | VARCHAR(255) | NOT NULL | FK → kingdoms.id |
| clan | VARCHAR(255) | NULL | → factions.id（書式: Faction.xxx） |
| kingdom_ref | VARCHAR(255) | NULL | XSD属性名は `kingdom`。`kingdom_id`（FK）との名前衝突を避けるためリネーム。→ kingdoms.id（書式: Kingdom.xxx） |
| value | INT | NOT NULL | |
| isAtWar | BOOLEAN | NULL | ※XSD属性名はcamelCase |

---

#### 3.2.6. `kingdom_policies`

|項目|説明|
|:--|:--|
|テーブル名|`kingdom_policies`|
|説明|王国が採用している政策の一覧。1王国に複数の政策が対応する。|
|テーブル種別|子テーブル（1:N）|
|親テーブル|`kingdoms`|
|子テーブル|無し|
|変換元スキーマ要素|`Kingdom > policies > policy`|
|変換元スキーマ定義ファイル|`Kingdoms.xsd`|

| カラム名 | 型 | NULL | 備考 |
|---|---|---|---|
| kingdom_id | VARCHAR(255) | NOT NULL | 複合PK（1/2） FK → kingdoms.id |
| policy_id | VARCHAR(255) | NOT NULL | 複合PK（2/2） XSD属性名は `id`。XSD上は `use="optional"` だが実データでは常に存在するため NOT NULL とする。

PRIMARY KEY: `(kingdom_id, policy_id)`

---

#### 3.2.7. `cultures`

|項目|説明|
|:--|:--|
|テーブル名|`cultures`|
|説明|文化圏の基本情報を格納するルートテーブル。外見・ボーナス値・デフォルト装備ロスター等の属性に加え、NPC役職参照属性や子要素テーブルを多数持つ。|
|テーブル種別|ルートテーブル|
|親テーブル|無し|
|子テーブル|`culture_role_refs`, `culture_caravan_party_templates`, `culture_elite_caravan_party_templates`, `culture_available_ship_hulls`, `culture_vassal_reward_items`, `culture_banner_bearer_replacement_weapons`, `culture_default_policies`, `culture_male_names`, `culture_female_names`, `culture_clan_names`, `culture_cultural_feats`, `culture_possible_clan_banner_icon_ids`, `culture_notable_templates`, `culture_lord_templates`, `culture_rebellion_hero_templates`, `culture_tournament_team_templates_one_participant`, `culture_tournament_team_templates_two_participant`, `culture_tournament_team_templates_four_participant`, `culture_basic_mercenary_troops`|
|変換元スキーマ要素|`SPCultures > Culture`|
|変換元スキーマ定義ファイル|`SPCultures.xsd`|

| カラム名 | 型 | NULL | 備考 |
|---|---|---|---|
| id | VARCHAR(255) | NOT NULL | PK |
| name | VARCHAR(255) | NOT NULL | |
| color | VARCHAR(255) | NULL | 書式: 0xRRGGBBAA |
| color2 | VARCHAR(255) | NULL | 書式: 0xRRGGBBAA |
| is_main_culture | BOOLEAN | NULL | |
| is_bandit | BOOLEAN | NULL | |
| naval_factor | FLOAT | NULL | |
| can_have_settlement | BOOLEAN | NULL | |
| militia_bonus | INT | NULL | |
| prosperity_bonus | INT | NULL | |
| encounter_background_mesh | VARCHAR(255) | NULL | |
| faction_banner_key | VARCHAR(255) | NULL | |
| board_game_type | VARCHAR(255) | NULL | |
| default_battle_equipment_roster | VARCHAR(255) | NULL | |
| default_civilian_equipment_roster | VARCHAR(255) | NULL | |
| default_stealth_equipment_roster | VARCHAR(255) | NULL | |
| duel_preset_equipment_roster | VARCHAR(255) | NULL | |
| marriage_bride_equipment_roster | VARCHAR(255) | NULL | |
| text | TEXT | NULL | |
| default_character_creation_body_property | VARCHAR(255) | NULL | |
| start_point_position_x | FLOAT | NULL | |
| start_point_position_y | FLOAT | NULL | |

---

#### 3.2.8. `culture_role_refs`

|項目|説明|
|:--|:--|
|テーブル名|`culture_role_refs`|
|説明|Culture 要素の約60個のロール参照属性を縦持ちで正規化したテーブル。role_name に XSD属性名、ref_id に参照先IDを格納する。ref_id の書式は role_name によって異なり、`NPCCharacter.xxx`（blacksmith, tavernkeeper 等）または `PartyTemplate.xxx`（default_party_template 等）のいずれかとなる。|
|テーブル種別|子テーブル（1:N）|
|親テーブル|`cultures`|
|子テーブル|無し|
|変換元スキーマ要素|`Culture`（ロール参照属性群を縦持ちで正規化）|
|変換元スキーマ定義ファイル|`SPCultures.xsd`|

| カラム名 | 型 | NULL | 備考 |
|---|---|---|---|
| culture_id | VARCHAR(255) | NOT NULL | 複合PK（1/2） FK → cultures.id |
| role_name | VARCHAR(255) | NOT NULL | 複合PK（2/2） 下記 role_name 一覧参照 |
| ref_id | VARCHAR(255) | NOT NULL | 書式: `NPCCharacter.xxx` または `PartyTemplate.xxx`（role_name により異なる） |

PRIMARY KEY: `(culture_id, role_name)`

**role_name 取りうる値一覧（XSD属性名をそのまま使用）:**

※ `basic_troop`, `elite_basic_troop` のみ XSD で `use="required"`。それ以外はすべて `use="optional"`。

`default_party_template`, `villager_party_template`, `fishing_party_template`,
`bandit_boss_party_template`, `militia_party_template`, `rebels_party_template`,
`vassal_reward_party_template`, `settlement_patrol_template_level_1`,
`settlement_patrol_template_level_2`, `settlement_patrol_template_level_3`,
`settlement_patrol_template_coastal`, `basic_troop`, `elite_basic_troop`,
`melee_militia_troop`, `melee_elite_militia_troop`, `ranged_militia_troop`,
`ranged_elite_militia_troop`, `tournament_master`, `caravan_master`, `armed_trader`,
`caravan_guard`, `veteran_caravan_guard`, `prison_guard`, `guard`, `steward`,
`blacksmith`, `weaponsmith`, `townswoman`, `townswoman_infant`, `townswoman_child`,
`townswoman_teenager`, `townsman`, `townsman_infant`, `townsman_child`,
`townsman_teenager`, `villager`, `village_woman`, `villager_male_child`,
`villager_male_teenager`, `villager_female_child`, `villager_female_teenager`,
`ransom_broker`, `gangleader_bodyguard`, `merchant_notary`, `artisan_notary`,
`preacher_notary`, `rural_notable_notary`, `shop_worker`, `tavernkeeper`,
`taverngamehost`, `musician`, `tavern_wench`, `armorer`, `horseMerchant`, `barber`,
`merchant`, `beggar`, `female_beggar`, `female_dancer`, `shipwright`,
`gear_practice_dummy`, `weapon_practice_stage_1`, `weapon_practice_stage_2`,
`weapon_practice_stage_3`, `gear_dummy`, `bandit_bandit`, `bandit_chief`,
`bandit_raider`, `bandit_boss`

---

#### 3.2.9. `culture_caravan_party_templates`

|項目|説明|
|:--|:--|
|テーブル名|`culture_caravan_party_templates`|
|説明|文化圏が使用するキャラバンのパーティテンプレート一覧。|
|テーブル種別|子テーブル（1:N）|
|親テーブル|`cultures`|
|子テーブル|無し|
|変換元スキーマ要素|`Culture > caravan_party_templates > caravan_party_template`|
|変換元スキーマ定義ファイル|`SPCultures.xsd`|

| カラム名 | 型 | NULL | 備考 |
|---|---|---|---|
| culture_id | VARCHAR(255) | NOT NULL | 複合PK（1/2） FK → cultures.id |
| template_id | VARCHAR(255) | NOT NULL | 複合PK（2/2） XSD属性名は `id` |

PRIMARY KEY: `(culture_id, template_id)`

---

#### 3.2.10. `culture_elite_caravan_party_templates`

|項目|説明|
|:--|:--|
|テーブル名|`culture_elite_caravan_party_templates`|
|説明|文化圏が使用するエリートキャラバンのパーティテンプレート一覧。|
|テーブル種別|子テーブル（1:N）|
|親テーブル|`cultures`|
|子テーブル|無し|
|変換元スキーマ要素|`Culture > elite_caravan_party_templates > caravan_party_template`|
|変換元スキーマ定義ファイル|`SPCultures.xsd`|

| カラム名 | 型 | NULL | 備考 |
|---|---|---|---|
| culture_id | VARCHAR(255) | NOT NULL | 複合PK（1/2） FK → cultures.id |
| template_id | VARCHAR(255) | NOT NULL | 複合PK（2/2） XSD属性名は `id` |

PRIMARY KEY: `(culture_id, template_id)`

---

#### 3.2.11. `culture_available_ship_hulls`

|項目|説明|
|:--|:--|
|テーブル名|`culture_available_ship_hulls`|
|説明|文化圏が使用可能な船体（hull）の一覧。|
|テーブル種別|子テーブル（1:N）|
|親テーブル|`cultures`|
|子テーブル|無し|
|変換元スキーマ要素|`Culture > available_ship_hulls > ship_hull`|
|変換元スキーマ定義ファイル|`SPCultures.xsd`|

| カラム名 | 型 | NULL | 備考 |
|---|---|---|---|
| culture_id | VARCHAR(255) | NOT NULL | 複合PK（1/2） FK → cultures.id |
| hull_id | VARCHAR(255) | NOT NULL | 複合PK（2/2） |

PRIMARY KEY: `(culture_id, hull_id)`

---

#### 3.2.12. `culture_vassal_reward_items`

|項目|説明|
|:--|:--|
|テーブル名|`culture_vassal_reward_items`|
|説明|家臣への報酬として授与されるアイテムの一覧。|
|テーブル種別|子テーブル（1:N）|
|親テーブル|`cultures`|
|子テーブル|無し|
|変換元スキーマ要素|`Culture > vassal_reward_items > item`|
|変換元スキーマ定義ファイル|`SPCultures.xsd`|

| カラム名 | 型 | NULL | 備考 |
|---|---|---|---|
| culture_id | VARCHAR(255) | NOT NULL | 複合PK（1/2） FK → cultures.id |
| item_id | VARCHAR(255) | NOT NULL | 複合PK（2/2） |

PRIMARY KEY: `(culture_id, item_id)`

---

#### 3.2.13. `culture_banner_bearer_replacement_weapons`

|項目|説明|
|:--|:--|
|テーブル名|`culture_banner_bearer_replacement_weapons`|
|説明|旗手が旗を持つ際に通常武器と置き換えられる武器アイテムの一覧。|
|テーブル種別|子テーブル（1:N）|
|親テーブル|`cultures`|
|子テーブル|無し|
|変換元スキーマ要素|`Culture > banner_bearer_replacement_weapons > item`|
|変換元スキーマ定義ファイル|`SPCultures.xsd`|

| カラム名 | 型 | NULL | 備考 |
|---|---|---|---|
| culture_id | VARCHAR(255) | NOT NULL | 複合PK（1/2） FK → cultures.id |
| item_id | VARCHAR(255) | NOT NULL | 複合PK（2/2） |

PRIMARY KEY: `(culture_id, item_id)`

---

#### 3.2.14. `culture_default_policies`

|項目|説明|
|:--|:--|
|テーブル名|`culture_default_policies`|
|説明|文化圏のデフォルトで採用される政策の一覧。|
|テーブル種別|子テーブル（1:N）|
|親テーブル|`cultures`|
|子テーブル|無し|
|変換元スキーマ要素|`Culture > default_policies > policy`|
|変換元スキーマ定義ファイル|`SPCultures.xsd`|

| カラム名 | 型 | NULL | 備考 |
|---|---|---|---|
| culture_id | VARCHAR(255) | NOT NULL | 複合PK（1/2） FK → cultures.id |
| policy_id | VARCHAR(255) | NOT NULL | 複合PK（2/2） |

PRIMARY KEY: `(culture_id, policy_id)`

---

#### 3.2.15. `culture_male_names`

|項目|説明|
|:--|:--|
|テーブル名|`culture_male_names`|
|説明|文化圏の男性キャラクターに使用される名前の候補一覧。|
|テーブル種別|子テーブル（1:N）|
|親テーブル|`cultures`|
|子テーブル|無し|
|変換元スキーマ要素|`Culture > male_names > name`|
|変換元スキーマ定義ファイル|`SPCultures.xsd`|

| カラム名 | 型 | NULL | 備考 |
|---|---|---|---|
| culture_id | VARCHAR(255) | NOT NULL | 複合PK（1/2） FK → cultures.id |
| name | VARCHAR(255) | NOT NULL | 複合PK（2/2） |

PRIMARY KEY: `(culture_id, name)`

---

#### 3.2.16. `culture_female_names`

|項目|説明|
|:--|:--|
|テーブル名|`culture_female_names`|
|説明|文化圏の女性キャラクターに使用される名前の候補一覧。|
|テーブル種別|子テーブル（1:N）|
|親テーブル|`cultures`|
|子テーブル|無し|
|変換元スキーマ要素|`Culture > female_names > name`|
|変換元スキーマ定義ファイル|`SPCultures.xsd`|

| カラム名 | 型 | NULL | 備考 |
|---|---|---|---|
| culture_id | VARCHAR(255) | NOT NULL | 複合PK（1/2） FK → cultures.id |
| name | VARCHAR(255) | NOT NULL | 複合PK（2/2） |

PRIMARY KEY: `(culture_id, name)`

---

#### 3.2.17. `culture_clan_names`

|項目|説明|
|:--|:--|
|テーブル名|`culture_clan_names`|
|説明|文化圏のクランに使用される名前の候補一覧。|
|テーブル種別|子テーブル（1:N）|
|親テーブル|`cultures`|
|子テーブル|無し|
|変換元スキーマ要素|`Culture > clan_names > name`|
|変換元スキーマ定義ファイル|`SPCultures.xsd`|

| カラム名 | 型 | NULL | 備考 |
|---|---|---|---|
| culture_id | VARCHAR(255) | NOT NULL | 複合PK（1/2） FK → cultures.id |
| name | VARCHAR(255) | NOT NULL | 複合PK（2/2） |

PRIMARY KEY: `(culture_id, name)`

---

#### 3.2.18. `culture_cultural_feats`

|項目|説明|
|:--|:--|
|テーブル名|`culture_cultural_feats`|
|説明|文化圏固有の特技（feat）の一覧。|
|テーブル種別|子テーブル（1:N）|
|親テーブル|`cultures`|
|子テーブル|無し|
|変換元スキーマ要素|`Culture > cultural_feats > feat`|
|変換元スキーマ定義ファイル|`SPCultures.xsd`|

| カラム名 | 型 | NULL | 備考 |
|---|---|---|---|
| culture_id | VARCHAR(255) | NOT NULL | 複合PK（1/2） FK → cultures.id |
| id | VARCHAR(255) | NOT NULL | 複合PK（2/2） |

PRIMARY KEY: `(culture_id, id)`

---

#### 3.2.19. `culture_possible_clan_banner_icon_ids`

|項目|説明|
|:--|:--|
|テーブル名|`culture_possible_clan_banner_icon_ids`|
|説明|文化圏のクランが使用可能なバナーアイコンIDの一覧。IDは整数値（xs:int）で定義される。|
|テーブル種別|子テーブル（1:N）|
|親テーブル|`cultures`|
|子テーブル|無し|
|変換元スキーマ要素|`Culture > possible_clan_banner_icon_ids > icon`|
|変換元スキーマ定義ファイル|`SPCultures.xsd`|

| カラム名 | 型 | NULL | 備考 |
|---|---|---|---|
| culture_id | VARCHAR(255) | NOT NULL | 複合PK（1/2） FK → cultures.id |
| id | INT | NOT NULL | 複合PK（2/2） ※XSDでxs:int定義 |

PRIMARY KEY: `(culture_id, id)`

---

#### 3.2.20. `culture_notable_templates`

|項目|説明|
|:--|:--|
|テーブル名|`culture_notable_templates`|
|説明|文化圏の著名人（notable）として生成されるNPCテンプレートの一覧。|
|テーブル種別|子テーブル（1:N）|
|親テーブル|`cultures`|
|子テーブル|無し|
|変換元スキーマ要素|`Culture > notable_templates > template`|
|変換元スキーマ定義ファイル|`SPCultures.xsd`|

| カラム名 | 型 | NULL | 備考 |
|---|---|---|---|
| culture_id | VARCHAR(255) | NOT NULL | 複合PK（1/2） FK → cultures.id |
| name | VARCHAR(255) | NOT NULL | 複合PK（2/2） |

PRIMARY KEY: `(culture_id, name)`

---

#### 3.2.21. `culture_lord_templates`

|項目|説明|
|:--|:--|
|テーブル名|`culture_lord_templates`|
|説明|文化圏の領主（lord）として生成されるNPCテンプレートの一覧。|
|テーブル種別|子テーブル（1:N）|
|親テーブル|`cultures`|
|子テーブル|無し|
|変換元スキーマ要素|`Culture > lord_templates > template`|
|変換元スキーマ定義ファイル|`SPCultures.xsd`|

| カラム名 | 型 | NULL | 備考 |
|---|---|---|---|
| culture_id | VARCHAR(255) | NOT NULL | 複合PK（1/2） FK → cultures.id |
| name | VARCHAR(255) | NOT NULL | 複合PK（2/2） |

PRIMARY KEY: `(culture_id, name)`

---

#### 3.2.22. `culture_rebellion_hero_templates`

|項目|説明|
|:--|:--|
|テーブル名|`culture_rebellion_hero_templates`|
|説明|反乱時に生成されるヒーローNPCのテンプレート一覧。|
|テーブル種別|子テーブル（1:N）|
|親テーブル|`cultures`|
|子テーブル|無し|
|変換元スキーマ要素|`Culture > rebellion_hero_templates > template`|
|変換元スキーマ定義ファイル|`SPCultures.xsd`|

| カラム名 | 型 | NULL | 備考 |
|---|---|---|---|
| culture_id | VARCHAR(255) | NOT NULL | 複合PK（1/2） FK → cultures.id |
| name | VARCHAR(255) | NOT NULL | 複合PK（2/2） |

PRIMARY KEY: `(culture_id, name)`

---

#### 3.2.23. `culture_tournament_team_templates_one_participant`

|項目|説明|
|:--|:--|
|テーブル名|`culture_tournament_team_templates_one_participant`|
|説明|1人参加トーナメント用チームのNPCテンプレート一覧。|
|テーブル種別|子テーブル（1:N）|
|親テーブル|`cultures`|
|子テーブル|無し|
|変換元スキーマ要素|`Culture > tournament_team_templates_one_participant > template`|
|変換元スキーマ定義ファイル|`SPCultures.xsd`|

| カラム名 | 型 | NULL | 備考 |
|---|---|---|---|
| culture_id | VARCHAR(255) | NOT NULL | 複合PK（1/2） FK → cultures.id |
| name | VARCHAR(255) | NOT NULL | 複合PK（2/2） |

PRIMARY KEY: `(culture_id, name)`

---

#### 3.2.24. `culture_tournament_team_templates_two_participant`

|項目|説明|
|:--|:--|
|テーブル名|`culture_tournament_team_templates_two_participant`|
|説明|2人参加トーナメント用チームのNPCテンプレート一覧。|
|テーブル種別|子テーブル（1:N）|
|親テーブル|`cultures`|
|子テーブル|無し|
|変換元スキーマ要素|`Culture > tournament_team_templates_two_participant > template`|
|変換元スキーマ定義ファイル|`SPCultures.xsd`|

| カラム名 | 型 | NULL | 備考 |
|---|---|---|---|
| culture_id | VARCHAR(255) | NOT NULL | 複合PK（1/2） FK → cultures.id |
| name | VARCHAR(255) | NOT NULL | 複合PK（2/2） |

PRIMARY KEY: `(culture_id, name)`

---

#### 3.2.25. `culture_tournament_team_templates_four_participant`

|項目|説明|
|:--|:--|
|テーブル名|`culture_tournament_team_templates_four_participant`|
|説明|4人参加トーナメント用チームのNPCテンプレート一覧。|
|テーブル種別|子テーブル（1:N）|
|親テーブル|`cultures`|
|子テーブル|無し|
|変換元スキーマ要素|`Culture > tournament_team_templates_four_participant > template`|
|変換元スキーマ定義ファイル|`SPCultures.xsd`|

| カラム名 | 型 | NULL | 備考 |
|---|---|---|---|
| culture_id | VARCHAR(255) | NOT NULL | 複合PK（1/2） FK → cultures.id |
| name | VARCHAR(255) | NOT NULL | 複合PK（2/2） |

PRIMARY KEY: `(culture_id, name)`

---

#### 3.2.26. `culture_basic_mercenary_troops`

|項目|説明|
|:--|:--|
|テーブル名|`culture_basic_mercenary_troops`|
|説明|文化圏の基本傭兵兵種のテンプレート一覧。|
|テーブル種別|子テーブル（1:N）|
|親テーブル|`cultures`|
|子テーブル|無し|
|変換元スキーマ要素|`Culture > basic_mercenary_troops > template`|
|変換元スキーマ定義ファイル|`SPCultures.xsd`|

| カラム名 | 型 | NULL | 備考 |
|---|---|---|---|
| culture_id | VARCHAR(255) | NOT NULL | 複合PK（1/2） FK → cultures.id |
| name | VARCHAR(255) | NOT NULL | 複合PK（2/2） |

PRIMARY KEY: `(culture_id, name)`

---

### 3.3. カテゴリ3: セリフ・テキスト関連（多言語対応）

#### 3.3.1. `strings`

|項目|説明|
|:--|:--|
|テーブル名|`strings`|
|説明|ゲーム内テキスト（UI文字列・セリフ等）を多言語対応で格納するルートテーブル。language_code はXSD上に存在しない追加カラムで、language_data.xml の LanguageData@id 値を使用する。|
|テーブル種別|ルートテーブル（多言語拡張）|
|親テーブル|無し|
|子テーブル|`string_tags`|
|変換元スキーマ要素|`strings > string`|
|変換元スキーマ定義ファイル|`GameText.xsd`|

| カラム名 | 型 | NULL | 備考 |
|---|---|---|---|
| string_id | VARCHAR(255) | NOT NULL | 複合PK（1/2） / XMLの `<string id="...">` |
| language_code | VARCHAR(255) | NOT NULL | 複合PK（2/2） / `language_data.xml` の `<LanguageData id="...">` の値（例: `"English"`, `"Français"`, `"日本語"`） |
| text | TEXT | NOT NULL | |

PRIMARY KEY: `(string_id, language_code)`

---

#### 3.3.2. `string_tags`

|項目|説明|
|:--|:--|
|テーブル名|`string_tags`|
|説明|テキスト文字列に付与されるタグ情報（名称・重み）を格納する。strings テーブルと1対多で対応する。|
|テーブル種別|子テーブル（1:N）|
|親テーブル|`strings`|
|子テーブル|無し|
|変換元スキーマ要素|`string > tags > tag`|
|変換元スキーマ定義ファイル|`GameText.xsd`|

| カラム名 | 型 | NULL | 備考 |
|---|---|---|---|
| string_id | VARCHAR(255) | NOT NULL | 複合PK（1/3） FK → strings(string_id, language_code) |
| language_code | VARCHAR(255) | NOT NULL | 複合PK（2/3） FK → strings(string_id, language_code) |
| tag_name | VARCHAR(255) | NOT NULL | 複合PK（3/3） |
| weight | INT | NULL | |

PRIMARY KEY: `(string_id, language_code, tag_name)`

---

## 4. テーブル数サマリー

| カテゴリ | テーブル数 |
|---|---|
| キャラクター関連 | 17 |
| 勢力・文化関連 | 26 |
| セリフ・テキスト | 2 |
| **合計** | **45** |

---

## 5. データ投入フロー（予定）

```
Step 1: XSDファイルから CREATE TABLE 文を生成（本設計書に基づく）
Step 2: XMLファイルのパースチェック（laxモード）→ エラー一覧を出力・確認
Step 3: エラーへの対処方針を決定（無視 / 補完 / 修正）
Step 4: XMLデータを変換 → INSERT 文を生成
Step 5: .sql ファイルとして出力
```
