-- ============================================================
-- Mount & Blade II — ゲームデータ MySQL DDL スクリプト
-- 対象カテゴリ: キャラクター関連 / 勢力・文化関連 / テキスト関連
-- 文字セット: utf8mb4 / utf8mb4_unicode_ci
-- ============================================================

SET FOREIGN_KEY_CHECKS = 0;

-- ------------------------------------------------------------
-- DROP（逆依存順）
-- ------------------------------------------------------------
DROP TABLE IF EXISTS string_tags;
DROP TABLE IF EXISTS strings;

DROP TABLE IF EXISTS culture_basic_mercenary_troops;
DROP TABLE IF EXISTS culture_tournament_team_templates_four_participant;
DROP TABLE IF EXISTS culture_tournament_team_templates_two_participant;
DROP TABLE IF EXISTS culture_tournament_team_templates_one_participant;
DROP TABLE IF EXISTS culture_rebellion_hero_templates;
DROP TABLE IF EXISTS culture_lord_templates;
DROP TABLE IF EXISTS culture_notable_templates;
DROP TABLE IF EXISTS culture_possible_clan_banner_icon_ids;
DROP TABLE IF EXISTS culture_cultural_feats;
DROP TABLE IF EXISTS culture_clan_names;
DROP TABLE IF EXISTS culture_female_names;
DROP TABLE IF EXISTS culture_male_names;
DROP TABLE IF EXISTS culture_default_policies;
DROP TABLE IF EXISTS culture_banner_bearer_replacement_weapons;
DROP TABLE IF EXISTS culture_vassal_reward_items;
DROP TABLE IF EXISTS culture_available_ship_hulls;
DROP TABLE IF EXISTS culture_elite_caravan_party_templates;
DROP TABLE IF EXISTS culture_caravan_party_templates;
DROP TABLE IF EXISTS culture_npc_roles;
DROP TABLE IF EXISTS cultures;

DROP TABLE IF EXISTS kingdom_policies;
DROP TABLE IF EXISTS kingdom_relationships;
DROP TABLE IF EXISTS kingdoms;

DROP TABLE IF EXISTS faction_minor_faction_templates;
DROP TABLE IF EXISTS faction_relationships;
DROP TABLE IF EXISTS factions;

DROP TABLE IF EXISTS heroes;

DROP TABLE IF EXISTS npc_character_resistances;
DROP TABLE IF EXISTS npc_character_lords;
DROP TABLE IF EXISTS npc_character_companions;
DROP TABLE IF EXISTS npc_character_hero;
DROP TABLE IF EXISTS npc_character_equipment_sets;
DROP TABLE IF EXISTS npc_character_equipment_items;
DROP TABLE IF EXISTS npc_character_equipment_rosters;
DROP TABLE IF EXISTS npc_character_upgrade_targets;
DROP TABLE IF EXISTS npc_character_feats;
DROP TABLE IF EXISTS npc_character_traits;
DROP TABLE IF EXISTS npc_character_skills;
DROP TABLE IF EXISTS npc_character_tattoo_tags;
DROP TABLE IF EXISTS npc_character_beard_tags;
DROP TABLE IF EXISTS npc_character_hair_tags;
DROP TABLE IF EXISTS npc_character_face;
DROP TABLE IF EXISTS npc_characters;

SET FOREIGN_KEY_CHECKS = 1;

-- ============================================================
-- カテゴリ1: キャラクター関連
-- ============================================================

CREATE TABLE npc_characters (
  id                            VARCHAR(255) NOT NULL,
  default_group                 VARCHAR(255) NULL,
  voice                         VARCHAR(255) NULL,
  is_hero                       VARCHAR(255) NULL,
  is_female                     VARCHAR(255) NULL,
  race                          VARCHAR(255) NULL,
  is_basic_troop                VARCHAR(255) NULL,
  is_template                   BOOLEAN      NULL,
  is_child_template             BOOLEAN      NULL,
  is_hidden_encyclopedia        BOOLEAN      NULL,
  face_mesh_cache               BOOLEAN      NULL,
  is_obsolete                   BOOLEAN      NULL,
  culture                       VARCHAR(255) NOT NULL COMMENT '書式: Culture.xxx',
  name                          VARCHAR(255) NULL,
  banner_symbol_mesh_name       VARCHAR(255) NULL,
  banner_symbol_color           VARCHAR(255) NULL     COMMENT '書式: 0xRRGGBBAA',
  banner_key                    VARCHAR(255) NULL,
  occupation                    VARCHAR(255) NULL,
  is_companion                  VARCHAR(255) NULL,
  offset                        VARCHAR(255) NULL,
  level                         VARCHAR(255) NULL,
  age                           VARCHAR(255) NULL,
  is_mercenary                  VARCHAR(255) NULL,
  formation_position_preference VARCHAR(255) NULL,
  default_equipment_set         VARCHAR(255) NULL,
  skill_template                VARCHAR(255) NULL,
  upgrade_requires              VARCHAR(255) NULL     COMMENT '書式: ItemCategory.xxx',
  PRIMARY KEY (id)
) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci;

-- ---

CREATE TABLE npc_character_face (
  npc_character_id              VARCHAR(255) NOT NULL COMMENT 'PK兼FK',
  face_key_value                VARCHAR(255) NULL,
  face_key_max_value            VARCHAR(255) NULL,
  body_properties_version       VARCHAR(255) NULL,
  body_properties_age           VARCHAR(255) NULL,
  body_properties_weight        VARCHAR(255) NULL,
  body_properties_build         VARCHAR(255) NULL,
  body_properties_key           VARCHAR(255) NULL,
  body_properties_max_version   VARCHAR(255) NULL,
  body_properties_max_age       VARCHAR(255) NULL,
  body_properties_max_weight    VARCHAR(255) NULL,
  body_properties_max_build     VARCHAR(255) NULL,
  body_properties_max_key       VARCHAR(255) NULL,
  face_key_template_value       VARCHAR(255) NULL,
  body_properties_template_value VARCHAR(255) NULL    COMMENT '書式: BodyProperty.xxx',
  PRIMARY KEY (npc_character_id),
  FOREIGN KEY (npc_character_id) REFERENCES npc_characters (id)
) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci;

-- ---

CREATE TABLE npc_character_hair_tags (
  npc_character_id VARCHAR(255) NOT NULL,
  name             VARCHAR(255) NOT NULL,
  PRIMARY KEY (npc_character_id, name),
  FOREIGN KEY (npc_character_id) REFERENCES npc_characters (id)
) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci;

-- ---

CREATE TABLE npc_character_beard_tags (
  npc_character_id VARCHAR(255) NOT NULL,
  name             VARCHAR(255) NOT NULL,
  PRIMARY KEY (npc_character_id, name),
  FOREIGN KEY (npc_character_id) REFERENCES npc_characters (id)
) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci;

-- ---

CREATE TABLE npc_character_tattoo_tags (
  npc_character_id VARCHAR(255) NOT NULL,
  name             VARCHAR(255) NOT NULL,
  PRIMARY KEY (npc_character_id, name),
  FOREIGN KEY (npc_character_id) REFERENCES npc_characters (id)
) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci;

-- ---

CREATE TABLE npc_character_skills (
  npc_character_id VARCHAR(255) NOT NULL,
  skill_id         VARCHAR(255) NOT NULL,
  value            INT          NOT NULL,
  PRIMARY KEY (npc_character_id, skill_id),
  FOREIGN KEY (npc_character_id) REFERENCES npc_characters (id)
) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci;

-- ---

CREATE TABLE npc_character_traits (
  npc_character_id VARCHAR(255) NOT NULL,
  trait_id         VARCHAR(255) NOT NULL,
  value            INT          NOT NULL,
  PRIMARY KEY (npc_character_id, trait_id),
  FOREIGN KEY (npc_character_id) REFERENCES npc_characters (id)
) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci;

-- ---

CREATE TABLE npc_character_feats (
  npc_character_id VARCHAR(255) NOT NULL,
  feat_id          VARCHAR(255) NOT NULL,
  value            INT          NOT NULL,
  PRIMARY KEY (npc_character_id, feat_id),
  FOREIGN KEY (npc_character_id) REFERENCES npc_characters (id)
) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci;

-- ---

CREATE TABLE npc_character_upgrade_targets (
  npc_character_id        VARCHAR(255) NOT NULL,
  target_npc_character_id VARCHAR(255) NOT NULL COMMENT '書式: NPCCharacter.xxx / 自己参照',
  PRIMARY KEY (npc_character_id, target_npc_character_id),
  FOREIGN KEY (npc_character_id)        REFERENCES npc_characters (id),
  FOREIGN KEY (target_npc_character_id) REFERENCES npc_characters (id)
) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci;

-- ---

CREATE TABLE npc_character_equipment_rosters (
  id               INT          NOT NULL AUTO_INCREMENT,
  npc_character_id VARCHAR(255) NOT NULL,
  civilian         BOOLEAN      NULL,
  PRIMARY KEY (id),
  FOREIGN KEY (npc_character_id) REFERENCES npc_characters (id)
) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci;

-- ---

CREATE TABLE npc_character_equipment_items (
  id                   INT          NOT NULL AUTO_INCREMENT,
  equipment_roster_id  INT          NOT NULL,
  slot                 VARCHAR(255) NULL,
  item_id              VARCHAR(255) NULL,
  amount               VARCHAR(255) NULL,
  PRIMARY KEY (id),
  FOREIGN KEY (equipment_roster_id) REFERENCES npc_character_equipment_rosters (id)
) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci;

-- ---

CREATE TABLE npc_character_equipment_sets (
  npc_character_id VARCHAR(255)                       NOT NULL,
  set_id           VARCHAR(255)                       NOT NULL,
  civilian         BOOLEAN                            NULL,
  equipmentType    ENUM('Battle','Civilian','Stealth') NULL COMMENT 'XSD属性名はcamelCase',
  PRIMARY KEY (npc_character_id, set_id),
  FOREIGN KEY (npc_character_id) REFERENCES npc_characters (id)
) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci;

-- ---

CREATE TABLE npc_character_hero (
  npc_character_id VARCHAR(255) NOT NULL COMMENT 'PK兼FK',
  hero_id          VARCHAR(255) NOT NULL COMMENT 'FK → heroes.id（Heroes.xsdとの連結）',
  banner_key       VARCHAR(255) NULL,
  text             TEXT         NULL,
  spouse           VARCHAR(255) NULL,
  alive            VARCHAR(255) NULL,
  voice            VARCHAR(255) NULL,
  father           VARCHAR(255) NULL,
  mother           VARCHAR(255) NULL,
  faction          VARCHAR(255) NULL COMMENT '書式: Faction.xxx',
  clan             VARCHAR(255) NULL COMMENT '書式: Clan.xxx',
  PRIMARY KEY (npc_character_id),
  FOREIGN KEY (npc_character_id) REFERENCES npc_characters (id),
  FOREIGN KEY (hero_id)          REFERENCES heroes (id)
) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci;

-- ---

CREATE TABLE npc_character_companions (
  npc_character_id VARCHAR(255) NOT NULL,
  companion_id     VARCHAR(255) NOT NULL COMMENT 'FK → npc_characters.id（自己参照）',
  PRIMARY KEY (npc_character_id, companion_id),
  FOREIGN KEY (npc_character_id) REFERENCES npc_characters (id),
  FOREIGN KEY (companion_id)     REFERENCES npc_characters (id)
) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci;

-- ---

CREATE TABLE npc_character_lords (
  npc_character_id VARCHAR(255) NOT NULL,
  lord_id          VARCHAR(255) NOT NULL COMMENT 'FK → npc_characters.id（自己参照）',
  banner_key       VARCHAR(255) NULL,
  spouse           VARCHAR(255) NULL,
  voice            VARCHAR(255) NULL,
  father           VARCHAR(255) NULL,
  mother           VARCHAR(255) NULL,
  PRIMARY KEY (npc_character_id, lord_id),
  FOREIGN KEY (npc_character_id) REFERENCES npc_characters (id),
  FOREIGN KEY (lord_id)          REFERENCES npc_characters (id)
) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci;

-- ---

CREATE TABLE npc_character_resistances (
  npc_character_id VARCHAR(255) NOT NULL COMMENT 'PK兼FK',
  knockback        INT          NULL,
  knockdown        INT          NULL,
  dismount         INT          NULL,
  PRIMARY KEY (npc_character_id),
  FOREIGN KEY (npc_character_id) REFERENCES npc_characters (id)
) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci;

-- ---

CREATE TABLE heroes (
  id                           VARCHAR(255) NOT NULL,
  father                       VARCHAR(255) NULL COMMENT 'FK → heroes.id（自己参照）',
  mother                       VARCHAR(255) NULL COMMENT 'FK → heroes.id（自己参照）',
  faction                      VARCHAR(255) NOT NULL,
  banner_key                   VARCHAR(255) NULL,
  spouse                       VARCHAR(255) NULL COMMENT 'FK → heroes.id（自己参照）',
  alive                        BOOLEAN      NULL,
  text                         TEXT         NULL,
  preferred_upgrade_formation  VARCHAR(255) NULL,
  banner_item                  VARCHAR(255) NULL,
  PRIMARY KEY (id),
  FOREIGN KEY (father) REFERENCES heroes (id),
  FOREIGN KEY (mother) REFERENCES heroes (id),
  FOREIGN KEY (spouse) REFERENCES heroes (id)
) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci;

-- ============================================================
-- カテゴリ2: 勢力・文化関連
-- ============================================================

CREATE TABLE factions (
  id                      VARCHAR(255)  NOT NULL,
  initial_home_settlement VARCHAR(255)  NOT NULL COMMENT '書式: Settlement.xxx',
  banner_key              VARCHAR(255)  NULL,
  tier                    DECIMAL(10,2) NOT NULL,
  owner                   VARCHAR(255)  NULL     COMMENT '書式: Hero.xxx',
  color                   VARCHAR(255)  NULL     COMMENT '書式: 0xRRGGBBAA',
  color2                  VARCHAR(255)  NULL     COMMENT '書式: 0xRRGGBBAA',
  culture                 VARCHAR(255)  NULL     COMMENT '書式: Culture.xxx',
  super_faction           VARCHAR(255)  NULL     COMMENT '書式: Kingdom.xxx',
  default_party_template  VARCHAR(255)  NULL     COMMENT '書式: PartyTemplate.xxx',
  is_bandit               BOOLEAN       NULL,
  is_noble                BOOLEAN       NULL,
  is_minor_faction        BOOLEAN       NULL,
  is_outlaw               BOOLEAN       NULL,
  is_clan_type_mercenary  BOOLEAN       NULL,
  is_nomad                BOOLEAN       NULL,
  is_sect                 BOOLEAN       NULL,
  is_mafia                BOOLEAN       NULL,
  settlement_banner_mesh  VARCHAR(255)  NULL,
  flag_mesh               VARCHAR(255)  NULL,
  name                    VARCHAR(255)  NOT NULL,
  short_name              VARCHAR(255)  NULL,
  text                    TEXT          NULL,
  PRIMARY KEY (id)
) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci;

-- ---

CREATE TABLE faction_relationships (
  faction_id VARCHAR(255) NOT NULL COMMENT 'PK兼FK',
  clan       VARCHAR(255) NULL     COMMENT '書式: Faction.xxx',
  kingdom    VARCHAR(255) NULL     COMMENT '書式: Kingdom.xxx',
  value      INT          NOT NULL,
  PRIMARY KEY (faction_id),
  FOREIGN KEY (faction_id) REFERENCES factions (id)
) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci;

-- ---

CREATE TABLE faction_minor_faction_templates (
  faction_id                 VARCHAR(255) NOT NULL,
  template_npc_character_id  VARCHAR(255) NOT NULL COMMENT '書式: NPCCharacter.xxx',
  PRIMARY KEY (faction_id, template_npc_character_id),
  FOREIGN KEY (faction_id) REFERENCES factions (id)
) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci;

-- ---

CREATE TABLE kingdoms (
  id                      VARCHAR(255) NOT NULL,
  initial_home_settlement VARCHAR(255) NOT NULL COMMENT '書式: Settlement.xxx',
  banner_key              VARCHAR(255) NULL,
  owner                   VARCHAR(255) NULL     COMMENT '書式: Hero.xxx',
  primary_banner_color    VARCHAR(255) NOT NULL COMMENT '書式: 0xRRGGBBAA',
  secondary_banner_color  VARCHAR(255) NOT NULL COMMENT '書式: 0xRRGGBBAA',
  color                   VARCHAR(255) NULL     COMMENT '書式: 0xRRGGBBAA',
  color2                  VARCHAR(255) NULL     COMMENT '書式: 0xRRGGBBAA',
  culture                 VARCHAR(255) NOT NULL COMMENT '書式: Culture.xxx',
  settlement_banner_mesh  VARCHAR(255) NULL,
  flag_mesh               VARCHAR(255) NULL,
  name                    VARCHAR(255) NOT NULL,
  short_name              VARCHAR(255) NULL,
  text                    TEXT         NULL,
  title                   VARCHAR(255) NULL,
  ruler_title             VARCHAR(255) NULL,
  PRIMARY KEY (id)
) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci;

-- ---

CREATE TABLE kingdom_relationships (
  id          INT          NOT NULL AUTO_INCREMENT,
  kingdom_id  VARCHAR(255) NOT NULL,
  clan        VARCHAR(255) NULL     COMMENT '書式: Faction.xxx',
  kingdom_ref VARCHAR(255) NULL     COMMENT '書式: Kingdom.xxx',
  value       INT          NOT NULL,
  is_at_war   BOOLEAN      NULL,
  PRIMARY KEY (id),
  FOREIGN KEY (kingdom_id) REFERENCES kingdoms (id)
) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci;

-- ---

CREATE TABLE kingdom_policies (
  kingdom_id VARCHAR(255) NOT NULL,
  policy_id  VARCHAR(255) NOT NULL,
  PRIMARY KEY (kingdom_id, policy_id),
  FOREIGN KEY (kingdom_id) REFERENCES kingdoms (id)
) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci;

-- ---

CREATE TABLE cultures (
  id                                        VARCHAR(255) NOT NULL,
  name                                      VARCHAR(255) NOT NULL,
  color                                     VARCHAR(255) NULL     COMMENT '書式: 0xRRGGBBAA',
  color2                                    VARCHAR(255) NULL     COMMENT '書式: 0xRRGGBBAA',
  is_main_culture                           BOOLEAN      NULL,
  is_bandit                                 BOOLEAN      NULL,
  naval_factor                              FLOAT        NULL,
  can_have_settlement                       BOOLEAN      NULL,
  militia_bonus                             INT          NULL,
  prosperity_bonus                          INT          NULL,
  encounter_background_mesh                 VARCHAR(255) NULL,
  faction_banner_key                        VARCHAR(255) NULL,
  basic_troop                               VARCHAR(255) NOT NULL,
  elite_basic_troop                         VARCHAR(255) NOT NULL,
  board_game_type                           VARCHAR(255) NULL,
  default_battle_equipment_roster           VARCHAR(255) NULL,
  default_civilian_equipment_roster         VARCHAR(255) NULL,
  default_stealth_equipment_roster          VARCHAR(255) NULL,
  duel_preset_equipment_roster              VARCHAR(255) NULL,
  marriage_bride_equipment_roster           VARCHAR(255) NULL,
  text                                      TEXT         NULL,
  default_character_creation_body_property  VARCHAR(255) NULL,
  start_point_position_x                    FLOAT        NULL,
  start_point_position_y                    FLOAT        NULL,
  PRIMARY KEY (id)
) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci;

-- ---

CREATE TABLE culture_npc_roles (
  culture_id VARCHAR(255) NOT NULL,
  role_name  VARCHAR(255) NOT NULL COMMENT 'XSD属性名をそのまま格納',
  npc_id     VARCHAR(255) NOT NULL,
  PRIMARY KEY (culture_id, role_name),
  FOREIGN KEY (culture_id) REFERENCES cultures (id)
) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci;

-- ---

CREATE TABLE culture_caravan_party_templates (
  culture_id  VARCHAR(255) NOT NULL,
  template_id VARCHAR(255) NOT NULL,
  PRIMARY KEY (culture_id, template_id),
  FOREIGN KEY (culture_id) REFERENCES cultures (id)
) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci;

-- ---

CREATE TABLE culture_elite_caravan_party_templates (
  culture_id  VARCHAR(255) NOT NULL,
  template_id VARCHAR(255) NOT NULL,
  PRIMARY KEY (culture_id, template_id),
  FOREIGN KEY (culture_id) REFERENCES cultures (id)
) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci;

-- ---

CREATE TABLE culture_available_ship_hulls (
  culture_id VARCHAR(255) NOT NULL,
  hull_id    VARCHAR(255) NOT NULL,
  PRIMARY KEY (culture_id, hull_id),
  FOREIGN KEY (culture_id) REFERENCES cultures (id)
) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci;

-- ---

CREATE TABLE culture_vassal_reward_items (
  culture_id VARCHAR(255) NOT NULL,
  item_id    VARCHAR(255) NOT NULL,
  PRIMARY KEY (culture_id, item_id),
  FOREIGN KEY (culture_id) REFERENCES cultures (id)
) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci;

-- ---

CREATE TABLE culture_banner_bearer_replacement_weapons (
  culture_id VARCHAR(255) NOT NULL,
  item_id    VARCHAR(255) NOT NULL,
  PRIMARY KEY (culture_id, item_id),
  FOREIGN KEY (culture_id) REFERENCES cultures (id)
) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci;

-- ---

CREATE TABLE culture_default_policies (
  culture_id VARCHAR(255) NOT NULL,
  policy_id  VARCHAR(255) NOT NULL,
  PRIMARY KEY (culture_id, policy_id),
  FOREIGN KEY (culture_id) REFERENCES cultures (id)
) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci;

-- ---

CREATE TABLE culture_male_names (
  culture_id VARCHAR(255) NOT NULL,
  name       VARCHAR(255) NOT NULL,
  PRIMARY KEY (culture_id, name),
  FOREIGN KEY (culture_id) REFERENCES cultures (id)
) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci;

-- ---

CREATE TABLE culture_female_names (
  culture_id VARCHAR(255) NOT NULL,
  name       VARCHAR(255) NOT NULL,
  PRIMARY KEY (culture_id, name),
  FOREIGN KEY (culture_id) REFERENCES cultures (id)
) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci;

-- ---

CREATE TABLE culture_clan_names (
  culture_id VARCHAR(255) NOT NULL,
  name       VARCHAR(255) NOT NULL,
  PRIMARY KEY (culture_id, name),
  FOREIGN KEY (culture_id) REFERENCES cultures (id)
) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci;

-- ---

CREATE TABLE culture_cultural_feats (
  culture_id VARCHAR(255) NOT NULL,
  id         VARCHAR(255) NOT NULL,
  PRIMARY KEY (culture_id, id),
  FOREIGN KEY (culture_id) REFERENCES cultures (id)
) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci;

-- ---

CREATE TABLE culture_possible_clan_banner_icon_ids (
  culture_id VARCHAR(255) NOT NULL,
  id         INT          NOT NULL COMMENT 'XSDでxs:int定義',
  PRIMARY KEY (culture_id, id),
  FOREIGN KEY (culture_id) REFERENCES cultures (id)
) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci;

-- ---

CREATE TABLE culture_notable_templates (
  culture_id VARCHAR(255) NOT NULL,
  name       VARCHAR(255) NOT NULL,
  PRIMARY KEY (culture_id, name),
  FOREIGN KEY (culture_id) REFERENCES cultures (id)
) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci;

-- ---

CREATE TABLE culture_lord_templates (
  culture_id VARCHAR(255) NOT NULL,
  name       VARCHAR(255) NOT NULL,
  PRIMARY KEY (culture_id, name),
  FOREIGN KEY (culture_id) REFERENCES cultures (id)
) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci;

-- ---

CREATE TABLE culture_rebellion_hero_templates (
  culture_id VARCHAR(255) NOT NULL,
  name       VARCHAR(255) NOT NULL,
  PRIMARY KEY (culture_id, name),
  FOREIGN KEY (culture_id) REFERENCES cultures (id)
) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci;

-- ---

CREATE TABLE culture_tournament_team_templates_one_participant (
  culture_id VARCHAR(255) NOT NULL,
  name       VARCHAR(255) NOT NULL,
  PRIMARY KEY (culture_id, name),
  FOREIGN KEY (culture_id) REFERENCES cultures (id)
) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci;

-- ---

CREATE TABLE culture_tournament_team_templates_two_participant (
  culture_id VARCHAR(255) NOT NULL,
  name       VARCHAR(255) NOT NULL,
  PRIMARY KEY (culture_id, name),
  FOREIGN KEY (culture_id) REFERENCES cultures (id)
) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci;

-- ---

CREATE TABLE culture_tournament_team_templates_four_participant (
  culture_id VARCHAR(255) NOT NULL,
  name       VARCHAR(255) NOT NULL,
  PRIMARY KEY (culture_id, name),
  FOREIGN KEY (culture_id) REFERENCES cultures (id)
) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci;

-- ---

CREATE TABLE culture_basic_mercenary_troops (
  culture_id VARCHAR(255) NOT NULL,
  name       VARCHAR(255) NOT NULL,
  PRIMARY KEY (culture_id, name),
  FOREIGN KEY (culture_id) REFERENCES cultures (id)
) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci;

-- ============================================================
-- カテゴリ3: セリフ・テキスト関連（多言語対応）
-- ============================================================

CREATE TABLE strings (
  string_id     VARCHAR(255) NOT NULL COMMENT 'XMLの<string id="...">',
  language_code VARCHAR(255) NOT NULL COMMENT 'language_data.xmlのLanguageData@id値（例: English, Français, 日本語）',
  text          TEXT         NOT NULL,
  PRIMARY KEY (string_id, language_code)
) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci;

-- ---

CREATE TABLE string_tags (
  string_id     VARCHAR(255) NOT NULL,
  language_code VARCHAR(255) NOT NULL,
  tag_name      VARCHAR(255) NOT NULL,
  weight        INT          NULL,
  PRIMARY KEY (string_id, language_code, tag_name),
  FOREIGN KEY (string_id, language_code) REFERENCES strings (string_id, language_code)
) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci;
