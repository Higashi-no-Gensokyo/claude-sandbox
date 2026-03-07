# Mount & Blade II — XMLデータ → MySQL 変換設計書

## 概要

| 項目 | 内容 |
|---|---|
| 変換元 | Mount & Blade II ゲーム内データ（.xml / .xsd） |
| 変換先 | MySQL / MariaDB 用 SQLスクリプト（.sql） |
| 対象カテゴリ | キャラクター関連・勢力/文化関連・セリフ/テキスト関連（多言語） |
| 除外カテゴリ | アニメーション・サウンド・テクスチャ・モーション・ムービー等の非言語データ |

---

## 設計方針

### 基本方針

- `.xsd` のタグ名 → テーブル名
- `.xsd` の属性名 → カラム名
- `.xsd` の属性型 → MySQLカラム型（型マッピングは下記参照）
- 入れ子構造（親子タグ）→ 別テーブルに分離し、FOREIGN KEY で結合
- 正規化を優先（結合より正規化）

### 型マッピング

| XSD型 | MySQLカラム型 |
|---|---|
| xs:string | VARCHAR(255) ※ text系は TEXT |
| xs:int | INT |
| xs:decimal | DECIMAL(10,2) |
| xs:float | FLOAT |
| xs:boolean | BOOLEAN（TINYINT の別名） |
| enumeration | ENUM(...) |

### 文字セット・照合順序

- `utf8mb4 / utf8mb4_unicode_ci`（多言語対応・推奨）

### 主キー方針

- XSD に `id` 属性（ゲーム内ID文字列）が定義されているテーブル → その `id` を PRIMARY KEY とする
- 参照元テーブルと **1:1** の子テーブル → `npc_character_id` 等の FK カラムをそのまま PK と兼用する（サロゲートキー不要）
- 参照元テーブルと **1:N** の子テーブルで、FK と他の自然キーの組み合わせで行を一意に特定できる場合 → それらの複合主キーとする（サロゲートキー不要）
- 上記いずれにも該当しない子テーブル（NULL許容カラムが候補キーに含まれる場合など）→ `id INT AUTO_INCREMENT` をサロゲートキーとして追加

---

## テーブル設計

### カテゴリ1: キャラクター関連

#### `npc_characters`（メインテーブル / NPCCharacters.xsd > NPCCharacter）

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

#### `npc_character_face`（face要素 / npc_characters と 1:1）

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

#### `npc_character_hair_tags`（hair_tag要素 / 1:N）

| カラム名 | 型 | NULL | 備考 |
|---|---|---|---|
| npc_character_id | VARCHAR(255) | NOT NULL | 複合PK（1/2） FK → npc_characters.id |
| name | VARCHAR(255) | NOT NULL | 複合PK（2/2） |

PRIMARY KEY: `(npc_character_id, name)`

#### `npc_character_beard_tags`（beard_tag要素 / 1:N）

| カラム名 | 型 | NULL | 備考 |
|---|---|---|---|
| npc_character_id | VARCHAR(255) | NOT NULL | 複合PK（1/2） FK → npc_characters.id |
| name | VARCHAR(255) | NOT NULL | 複合PK（2/2） |

PRIMARY KEY: `(npc_character_id, name)`

#### `npc_character_tattoo_tags`（tattoo_tag要素 / 1:N）

| カラム名 | 型 | NULL | 備考 |
|---|---|---|---|
| npc_character_id | VARCHAR(255) | NOT NULL | 複合PK（1/2） FK → npc_characters.id |
| name | VARCHAR(255) | NOT NULL | 複合PK（2/2） |

PRIMARY KEY: `(npc_character_id, name)`

#### `npc_character_skills`（skill要素 / 1:N）

| カラム名 | 型 | NULL | 備考 |
|---|---|---|---|
| npc_character_id | VARCHAR(255) | NOT NULL | 複合PK（1/2） FK → npc_characters.id |
| skill_id | VARCHAR(255) | NOT NULL | 複合PK（2/2） |
| value | INT | NOT NULL | |

PRIMARY KEY: `(npc_character_id, skill_id)`

#### `npc_character_traits`（Trait要素 / 1:N）

| カラム名 | 型 | NULL | 備考 |
|---|---|---|---|
| npc_character_id | VARCHAR(255) | NOT NULL | 複合PK（1/2） FK → npc_characters.id |
| trait_id | VARCHAR(255) | NOT NULL | 複合PK（2/2） |
| value | INT | NOT NULL | |

PRIMARY KEY: `(npc_character_id, trait_id)`

#### `npc_character_feats`（feat要素 / 1:N）

| カラム名 | 型 | NULL | 備考 |
|---|---|---|---|
| npc_character_id | VARCHAR(255) | NOT NULL | 複合PK（1/2） FK → npc_characters.id |
| feat_id | VARCHAR(255) | NOT NULL | 複合PK（2/2） |
| value | INT | NOT NULL | |

PRIMARY KEY: `(npc_character_id, feat_id)`

#### `npc_character_upgrade_targets`（upgrade_target要素 / 1:N）

> アップグレード先のNPCキャラクターへの参照。`npc_characters` テーブルへの自己参照関係。

| カラム名 | 型 | NULL | 備考 |
|---|---|---|---|
| npc_character_id | VARCHAR(255) | NOT NULL | 複合PK（1/2） FK → npc_characters.id |
| target_npc_character_id | VARCHAR(255) | NOT NULL | 複合PK（2/2） FK → npc_characters.id（自己参照）書式: NPCCharacter.xxx |

PRIMARY KEY: `(npc_character_id, target_npc_character_id)`

#### `npc_character_equipment_rosters`（EquipmentRoster要素 / 1:N）

| カラム名 | 型 | NULL | 備考 |
|---|---|---|---|
| id | INT AUTO_INCREMENT | NOT NULL | PK |
| npc_character_id | VARCHAR(255) | NOT NULL | FK → npc_characters.id |
| civilian | BOOLEAN | NULL | |

#### `npc_character_equipment_items`（equipment要素 / npc_character_equipment_rosters と 1:N）

| カラム名 | 型 | NULL | 備考 |
|---|---|---|---|
| id | INT AUTO_INCREMENT | NOT NULL | PK |
| equipment_roster_id | INT | NOT NULL | FK → npc_character_equipment_rosters.id |
| slot | VARCHAR(255) | NULL | |
| item_id | VARCHAR(255) | NULL | |
| amount | VARCHAR(255) | NULL | |

#### `npc_character_equipment_sets`（EquipmentSet要素 / 1:N）

| カラム名 | 型 | NULL | 備考 |
|---|---|---|---|
| npc_character_id | VARCHAR(255) | NOT NULL | 複合PK（1/2） FK → npc_characters.id |
| set_id | VARCHAR(255) | NOT NULL | 複合PK（2/2） |
| civilian | BOOLEAN | NULL | |
| equipmentType | ENUM('Battle','Civilian','Stealth') | NULL | ※XSD属性名はcamelCase |

PRIMARY KEY: `(npc_character_id, set_id)`

#### `npc_character_hero`（Hero子要素 / npc_characters と 1:1）

> NPCCharacters.xsd の `Hero` 子要素を格納。
> `hero_id` は Heroes.xsd の `heroes` テーブルへの参照であり、2つのXSDをまたぐ連結関係を表す。

| カラム名 | 型 | NULL | 備考 |
|---|---|---|---|
| npc_character_id | VARCHAR(255) | NOT NULL | PK 兼 FK → npc_characters.id |
| hero_id | VARCHAR(255) | NOT NULL | FK → heroes.id（Heroes.xsdとの連結） |
| banner_key | VARCHAR(255) | NULL | |
| text | TEXT | NULL | |
| spouse | VARCHAR(255) | NULL | |
| alive | VARCHAR(255) | NULL | |
| voice | VARCHAR(255) | NULL | |
| father | VARCHAR(255) | NULL | |
| mother | VARCHAR(255) | NULL | |
| faction | VARCHAR(255) | NULL | 書式: Faction.xxx |
| clan | VARCHAR(255) | NULL | 書式: Clan.xxx |

#### `npc_character_companions`（Companion要素 / npc_characters と 1:N）

> `Components` 要素内の `Companion` 子要素を格納。
> `Companion` は `id` 属性のみを持ち、これは `npc_characters.id` への自己参照（コンパニオンとして紐づく別NPCへの参照）。

| カラム名 | 型 | NULL | 備考 |
|---|---|---|---|
| npc_character_id | VARCHAR(255) | NOT NULL | 複合PK（1/2） FK → npc_characters.id |
| companion_id | VARCHAR(255) | NOT NULL | 複合PK（2/2） FK → npc_characters.id（自己参照） |

PRIMARY KEY: `(npc_character_id, companion_id)`

#### `npc_character_lords`（Lord要素 / npc_characters と 1:N）

> `Components` 要素内の `Lord` 子要素を格納。
> `Lord` は `id`（`npc_characters.id` への自己参照）に加え、関係固有の属性（banner_key / spouse 等）を持つ。
> `Companion` とはカラム構成が異なるため別テーブルとして分離。

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

#### `npc_character_resistances`（Resistances要素 / npc_characters と 1:1）

| カラム名 | 型 | NULL | 備考 |
|---|---|---|---|
| npc_character_id | VARCHAR(255) | NOT NULL | PK 兼 FK → npc_characters.id |
| knockback | INT | NULL | |
| knockdown | INT | NULL | |
| dismount | INT | NULL | |

#### `heroes`（Heroes.xsd > Heroes > Hero）

> Heroes.xsd で定義されるヒーロー（プレイヤーキャラクター・主要NPC）の一覧。
> `father` / `mother` / `spouse` は同テーブル内の別レコードへの自己参照。

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

### カテゴリ2: 勢力・文化関連

#### `factions`（Factions.xsd > Factions > Faction）

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

#### `faction_relationships`（relationship要素 / factions と 1:1）

| カラム名 | 型 | NULL | 備考 |
|---|---|---|---|
| faction_id | VARCHAR(255) | NOT NULL | PK 兼 FK → factions.id |
| clan | VARCHAR(255) | NULL | → factions.id（書式: Faction.xxx） |
| kingdom | VARCHAR(255) | NULL | → kingdoms.id（書式: Kingdom.xxx） |
| value | INT | NOT NULL | |

#### `faction_minor_faction_templates`（template要素 / 1:N）

| カラム名 | 型 | NULL | 備考 |
|---|---|---|---|
| faction_id | VARCHAR(255) | NOT NULL | 複合PK（1/2） FK → factions.id |
| template_npc_character_id | VARCHAR(255) | NOT NULL | 複合PK（2/2） → npc_characters.id（書式: NPCCharacter.xxx） |

PRIMARY KEY: `(faction_id, template_npc_character_id)`

#### `kingdoms`（Kingdoms.xsd > Kingdoms > Kingdom）

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

#### `kingdom_relationships`（relationship要素 / kingdoms と 1:N）

| カラム名 | 型 | NULL | 備考 |
|---|---|---|---|
| id | INT AUTO_INCREMENT | NOT NULL | PK |
| kingdom_id | VARCHAR(255) | NOT NULL | FK → kingdoms.id |
| clan | VARCHAR(255) | NULL | → factions.id（書式: Faction.xxx） |
| kingdom_ref | VARCHAR(255) | NULL | → kingdoms.id（書式: Kingdom.xxx） |
| value | INT | NOT NULL | |
| is_at_war | BOOLEAN | NULL | |

#### `kingdom_policies`（policy要素 / kingdoms と 1:N）

| カラム名 | 型 | NULL | 備考 |
|---|---|---|---|
| kingdom_id | VARCHAR(255) | NOT NULL | 複合PK（1/2） FK → kingdoms.id |
| policy_id | VARCHAR(255) | NOT NULL | 複合PK（2/2） |

PRIMARY KEY: `(kingdom_id, policy_id)`

#### `cultures`（SPCultures.xsd > SPCultures > Culture）

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

#### `culture_npc_roles`（NPC役職参照カラム群を縦持ちで分離 / cultures と 1:N）

| カラム名 | 型 | NULL | 備考 |
|---|---|---|---|
| culture_id | VARCHAR(255) | NOT NULL | 複合PK（1/2） FK → cultures.id |
| role_name | VARCHAR(255) | NOT NULL | 複合PK（2/2） 下記 role_name 一覧参照 |
| npc_id | VARCHAR(255) | NOT NULL | 対応する NPCCharacter の id 値 |

PRIMARY KEY: `(culture_id, role_name)`

**role_name 取りうる値一覧（XSD属性名をそのまま使用）:**
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

#### `culture_caravan_party_templates`（caravan_party_template要素 / 1:N）

| カラム名 | 型 | NULL | 備考 |
|---|---|---|---|
| culture_id | VARCHAR(255) | NOT NULL | 複合PK（1/2） FK → cultures.id |
| template_id | VARCHAR(255) | NOT NULL | 複合PK（2/2） |

PRIMARY KEY: `(culture_id, template_id)`

#### `culture_elite_caravan_party_templates`（elite側 caravan_party_template要素 / 1:N）

| カラム名 | 型 | NULL | 備考 |
|---|---|---|---|
| culture_id | VARCHAR(255) | NOT NULL | 複合PK（1/2） FK → cultures.id |
| template_id | VARCHAR(255) | NOT NULL | 複合PK（2/2） |

PRIMARY KEY: `(culture_id, template_id)`

#### `culture_available_ship_hulls`（ship_hull要素 / 1:N）

| カラム名 | 型 | NULL | 備考 |
|---|---|---|---|
| culture_id | VARCHAR(255) | NOT NULL | 複合PK（1/2） FK → cultures.id |
| hull_id | VARCHAR(255) | NOT NULL | 複合PK（2/2） |

PRIMARY KEY: `(culture_id, hull_id)`

#### `culture_vassal_reward_items`（vassal_reward_items > item要素 / 1:N）

| カラム名 | 型 | NULL | 備考 |
|---|---|---|---|
| culture_id | VARCHAR(255) | NOT NULL | 複合PK（1/2） FK → cultures.id |
| item_id | VARCHAR(255) | NOT NULL | 複合PK（2/2） |

PRIMARY KEY: `(culture_id, item_id)`

#### `culture_banner_bearer_replacement_weapons`（banner_bearer_replacement_weapons > item要素 / 1:N）

| カラム名 | 型 | NULL | 備考 |
|---|---|---|---|
| culture_id | VARCHAR(255) | NOT NULL | 複合PK（1/2） FK → cultures.id |
| item_id | VARCHAR(255) | NOT NULL | 複合PK（2/2） |

PRIMARY KEY: `(culture_id, item_id)`

#### `culture_default_policies`（policy要素 / 1:N）

| カラム名 | 型 | NULL | 備考 |
|---|---|---|---|
| culture_id | VARCHAR(255) | NOT NULL | 複合PK（1/2） FK → cultures.id |
| policy_id | VARCHAR(255) | NOT NULL | 複合PK（2/2） |

PRIMARY KEY: `(culture_id, policy_id)`

#### `culture_male_names`（name要素 / 1:N）

| カラム名 | 型 | NULL | 備考 |
|---|---|---|---|
| culture_id | VARCHAR(255) | NOT NULL | 複合PK（1/2） FK → cultures.id |
| name | VARCHAR(255) | NOT NULL | 複合PK（2/2） |

PRIMARY KEY: `(culture_id, name)`

#### `culture_female_names`（name要素 / 1:N）

| カラム名 | 型 | NULL | 備考 |
|---|---|---|---|
| culture_id | VARCHAR(255) | NOT NULL | 複合PK（1/2） FK → cultures.id |
| name | VARCHAR(255) | NOT NULL | 複合PK（2/2） |

PRIMARY KEY: `(culture_id, name)`

#### `culture_clan_names`（name要素 / 1:N）

| カラム名 | 型 | NULL | 備考 |
|---|---|---|---|
| culture_id | VARCHAR(255) | NOT NULL | 複合PK（1/2） FK → cultures.id |
| name | VARCHAR(255) | NOT NULL | 複合PK（2/2） |

PRIMARY KEY: `(culture_id, name)`

#### `culture_cultural_feats`（feat要素 / 1:N）

| カラム名 | 型 | NULL | 備考 |
|---|---|---|---|
| culture_id | VARCHAR(255) | NOT NULL | 複合PK（1/2） FK → cultures.id |
| id | VARCHAR(255) | NOT NULL | 複合PK（2/2） |

PRIMARY KEY: `(culture_id, id)`

#### `culture_possible_clan_banner_icon_ids`（icon要素 / 1:N）

| カラム名 | 型 | NULL | 備考 |
|---|---|---|---|
| culture_id | VARCHAR(255) | NOT NULL | 複合PK（1/2） FK → cultures.id |
| id | INT | NOT NULL | 複合PK（2/2） ※XSDでxs:int定義 |

PRIMARY KEY: `(culture_id, id)`

#### `culture_notable_templates`（template要素 / 1:N）

| カラム名 | 型 | NULL | 備考 |
|---|---|---|---|
| culture_id | VARCHAR(255) | NOT NULL | 複合PK（1/2） FK → cultures.id |
| name | VARCHAR(255) | NOT NULL | 複合PK（2/2） |

PRIMARY KEY: `(culture_id, name)`

#### `culture_lord_templates`（template要素 / 1:N）

| カラム名 | 型 | NULL | 備考 |
|---|---|---|---|
| culture_id | VARCHAR(255) | NOT NULL | 複合PK（1/2） FK → cultures.id |
| name | VARCHAR(255) | NOT NULL | 複合PK（2/2） |

PRIMARY KEY: `(culture_id, name)`

#### `culture_rebellion_hero_templates`（template要素 / 1:N）

| カラム名 | 型 | NULL | 備考 |
|---|---|---|---|
| culture_id | VARCHAR(255) | NOT NULL | 複合PK（1/2） FK → cultures.id |
| name | VARCHAR(255) | NOT NULL | 複合PK（2/2） |

PRIMARY KEY: `(culture_id, name)`

#### `culture_tournament_team_templates_one_participant`（template要素 / 1:N）

| カラム名 | 型 | NULL | 備考 |
|---|---|---|---|
| culture_id | VARCHAR(255) | NOT NULL | 複合PK（1/2） FK → cultures.id |
| name | VARCHAR(255) | NOT NULL | 複合PK（2/2） |

PRIMARY KEY: `(culture_id, name)`

#### `culture_tournament_team_templates_two_participant`（template要素 / 1:N）

| カラム名 | 型 | NULL | 備考 |
|---|---|---|---|
| culture_id | VARCHAR(255) | NOT NULL | 複合PK（1/2） FK → cultures.id |
| name | VARCHAR(255) | NOT NULL | 複合PK（2/2） |

PRIMARY KEY: `(culture_id, name)`

#### `culture_tournament_team_templates_four_participant`（template要素 / 1:N）

| カラム名 | 型 | NULL | 備考 |
|---|---|---|---|
| culture_id | VARCHAR(255) | NOT NULL | 複合PK（1/2） FK → cultures.id |
| name | VARCHAR(255) | NOT NULL | 複合PK（2/2） |

PRIMARY KEY: `(culture_id, name)`

#### `culture_basic_mercenary_troops`（template要素 / 1:N）

| カラム名 | 型 | NULL | 備考 |
|---|---|---|---|
| culture_id | VARCHAR(255) | NOT NULL | 複合PK（1/2） FK → cultures.id |
| name | VARCHAR(255) | NOT NULL | 複合PK（2/2） |

PRIMARY KEY: `(culture_id, name)`

---

### カテゴリ3: セリフ・テキスト関連（多言語対応）

#### `strings`（GameText.xsd > strings > string）

| カラム名 | 型 | NULL | 備考 |
|---|---|---|---|
| string_id | VARCHAR(255) | NOT NULL | 複合PK（1/2） / XMLの `<string id="...">` |
| language_code | VARCHAR(255) | NOT NULL | 複合PK（2/2） / `language_data.xml` の `<LanguageData id="...">` の値（例: `"English"`, `"Français"`, `"日本語"`） |
| text | TEXT | NOT NULL | |

PRIMARY KEY: `(string_id, language_code)`

#### `string_tags`（tag要素 / strings と 1:N）

| カラム名 | 型 | NULL | 備考 |
|---|---|---|---|
| string_id | VARCHAR(255) | NOT NULL | 複合PK（1/3） FK → strings(string_id, language_code) |
| language_code | VARCHAR(255) | NOT NULL | 複合PK（2/3） FK → strings(string_id, language_code) |
| tag_name | VARCHAR(255) | NOT NULL | 複合PK（3/3） |
| weight | INT | NULL | |

PRIMARY KEY: `(string_id, language_code, tag_name)`

---

## テーブル数サマリー

| カテゴリ | テーブル数 |
|---|---|
| キャラクター関連 | 16 |
| 勢力・文化関連 | 23 |
| セリフ・テキスト | 2 |
| **合計** | **41** |

---



## データ投入フロー（予定）

```
Step 1: XSDファイルから CREATE TABLE 文を生成（本設計書に基づく）
Step 2: XMLファイルのパースチェック（laxモード）→ エラー一覧を出力・確認
Step 3: エラーへの対処方針を決定（無視 / 補完 / 修正）
Step 4: XMLデータを変換 → INSERT 文を生成
Step 5: .sql ファイルとして出力
```
