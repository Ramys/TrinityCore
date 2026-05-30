-- TDB 434.22011 world
UPDATE `version` SET `db_version`='TDB 434.22011', `cache_id`=22011 LIMIT 1;
UPDATE `updates` SET `state`='ARCHIVED';
UPDATE `creature_template` SET `ScriptName`= 'npc_atramedes_reverberating_flame' WHERE `entry`= 41962;
UPDATE `creature_template_movement` SET `Swim`= 1 WHERE `CreatureID` IN (43296, 47774, 47775, 47776);
UPDATE `creature_template_movement` SET `Swim`= 1 WHERE `CreatureID` IN (40765, 49064);
UPDATE `pet_levelstats` SET `hp`= 40529, `armor`= 11092, `str`= 476, `agi`= 3343, `sta`= 389, `inte`= 69, `spi`= 116 WHERE `creature_entry`= 26125 AND `level`= 85;
UPDATE `creature_template` SET `unit_class`= 4 WHERE `entry`= 26125;
UPDATE `reference_loot_template` SET `Reference`= 0 WHERE `Entry` IN (11919, 11920, 11921, 13006, 13007, 13008, 13009, 13010) AND `Entry`= `Reference`;
DELETE FROM `spell_script_names` WHERE `ScriptName`= 'spell_item_satisfied';
INSERT INTO `spell_script_names` (`spell_id`, `ScriptName`) VALUES
(87649, 'spell_item_satisfied');

-- Franclorn Forgewright
SET @ENTRY := 8888;
UPDATE `creature_template` SET `npcflag`=`npcflag`&~0x8000 WHERE `entry`=@ENTRY;

-- Gaeriyan
SET @ENTRY := 9299;
UPDATE `creature_template` SET `npcflag`=`npcflag`&~0x8000 WHERE `entry`=@ENTRY;
UPDATE `creature_template_addon` SET `auras`='10848' WHERE `entry`=@ENTRY;

-- Shroud of Death Spell
DELETE FROM `spell_script_names` WHERE spell_id=10848;
INSERT INTO `spell_script_names` VALUES(10848, 'spell_gen_shroud_of_death');

-- To the Looter Go the Spoils (1166)
DELETE FROM `creature_loot_template` WHERE `entry`=1 AND `item`=18228;
INSERT INTO `creature_loot_template` (`Entry`, `Item`, `Reference`, `Chance`, `QuestRequired`, `IsCurrency`, `LootMode`, `GroupId`, `MinCount`, `MaxCount`, `Comment`) VALUES
(1, 18228, 0, 1, 0, 0, 1, 0, 1, 1, '');

DELETE FROM `conditions` WHERE `SourceTypeOrReferenceId`=1 AND `SourceGroup`=1 AND `SourceEntry` IN(18228);
INSERT INTO `conditions` VALUES (1, 1, 18228, 0, 0, 22, 0, 30, 0, 0, 0, 0, 0, '', 'Requires map Alterac Valley');

-- Add Player Loot for WG quests
DELETE FROM `creature_loot_template` WHERE `entry`=1 AND `item` IN(43314, 43322, 43323, 43324, 44808, 44809);
INSERT INTO `creature_loot_template` (`Entry`, `Item`, `Reference`, `Chance`, `QuestRequired`, `IsCurrency`, `LootMode`, `GroupId`, `MinCount`, `MaxCount`, `Comment`) VALUES
(1, 43314, 0, 100, 1, 0, 1, 0, 5, 5, ''),
(1, 43322, 0, 100, 1, 0, 1, 0, 5, 5, ''),
(1, 43323, 0, 100, 1, 0, 1, 0, 5, 5, ''),
(1, 43324, 0, 100, 1, 0, 1, 0, 5, 5, ''),
(1, 44808, 0, 100, 1, 0, 1, 0, 5, 5, ''),
(1, 44809, 0, 100, 1, 0, 1, 0, 5, 5, '');

DELETE FROM `conditions` WHERE `SourceTypeOrReferenceId`=1 AND `SourceGroup`=1 AND `SourceEntry` IN(43314, 43322, 43323, 43324, 44808, 44809);
INSERT INTO `conditions` VALUES (1, 1, 44808, 0, 0, 23, 0, 4585, 0, 0, 0, 0, 0, '', 'Requires Glacial Falls area'),
(1, 1, 43322, 0, 0, 23, 0, 4585, 0, 0, 0, 0, 0, '', 'Requires Glacial Falls area'),
(1, 1, 43314, 0, 0, 23, 0, 4584, 0, 0, 0, 0, 0, '', 'Requires Cauldron of Flames area'),
(1, 1, 43323, 0, 0, 23, 0, 4587, 0, 0, 0, 0, 0, '', 'Requires Forest of Shadows area'),
(1, 1, 43324, 0, 0, 23, 0, 4590, 0, 0, 0, 0, 0, '', 'Requires Steppe of Life area'),
(1, 1, 44809, 0, 0, 23, 0, 4590, 0, 0, 0, 0, 0, '', 'Requires Steppe of Life area');
-- UPDATE `item_template` SET `spellppmRate_1`=2.5, `ScriptName`='item_generic_limit_chance_above_60' WHERE `entry`=19169;
UPDATE `item_template_addon` SET `SpellPPMChance`=2.5 WHERE `Id`=19169;ALTER TABLE `spell_enchant_proc_data`
    CHANGE `entry` `EnchantID` int(10) UNSIGNED NOT NULL,
    CHANGE `customChance` `Chance` float DEFAULT '0' NOT NULL,
    CHANGE `PPMChance` `ProcsPerMinute` float DEFAULT '0' NOT NULL,
    CHANGE `procEx` `HitMask` int(10) UNSIGNED DEFAULT '0' NOT NULL,
    ADD COLUMN `AttributesMask` int(10) UNSIGNED DEFAULT '0' NOT NULL AFTER `HitMask`;

-- Ragnaros
UPDATE `creature_template` SET `ScriptName`= 'boss_ragnaros_firelands' WHERE `entry`= 52409;
UPDATE `creature_template` SET `minlevel`= 88, `maxlevel`= 88, `exp`= 3, `faction`= 2234, `mechanic_immune_mask`= 650854271, `flags_extra`= 0x1 WHERE `entry` IN (52409, 53797, 53798, 53799);
UPDATE `creature_template` SET `difficulty_entry_2`= 54258 WHERE `entry`= 53920;
UPDATE `creature_template` SET `minlevel`= 88, `maxlevel`= 88, `exp`= 3, `faction`= 2234, `BaseAttackTime`= 1500, `mechanic_immune_mask`= 650854271, `flags_extra`= 0x1 WHERE `entry` IN (53920, 54258);
UPDATE `creature_template` SET `BaseVariance`= 0.5, `DamageModifier`= 240 WHERE `entry` IN (52409, 53797, 53798, 53799, 53920, 54258);

-- Magma Trap
UPDATE `creature_template` SET `unit_flags`= 0x2000000, `flags_extra`= `flags_extra`| 128, `AIName`= 'NullCreatureAI' WHERE `entry`= 53086;
-- Sulfuras Smash
UPDATE `creature_template` SET `unit_flags`= 0x2000000, `flags_extra`= `flags_extra` | 128, `AIName`= 'NullCreatureAI' WHERE `entry`= 53266;
UPDATE `creature_template` SET `unit_flags`= 0x2000000, `flags_extra`= `flags_extra` | 128 | 0x20000000, `AIName`= 'NullCreatureAI' WHERE `entry`= 53268;
-- Splitting Blow
UPDATE `creature_template` SET `unit_flags`= 0x2000000, `flags_extra`= `flags_extra` | 128, `AIName`= 'NullCreatureAI' WHERE `entry`= 53393;
-- Lava Wave
UPDATE `creature_template` SET `unit_flags`= 0x2000000, `flags_extra`= `flags_extra` | 128, `AIName`= 'NullCreatureAI' WHERE `entry`= 53363;
-- Son Of Flame
UPDATE `creature_template` SET `ScriptName`= 'npc_ragnaros_son_of_flame' WHERE `entry`= 53140;
UPDATE `creature_template` SET `mechanic_immune_mask`= 0x1 | 0x512 | 0x10000 | 0x20000 | 0x400000 WHERE `entry` IN (53140, 53800, 53801, 53802);
-- Sulfuras, Hand of Ragnaros
UPDATE `creature_template` SET `unit_flags`= 0x2000000, `unit_flags2`= 0x8000 | 0x800, `flags_extra`= `flags_extra` | 128, `AIName`= 'NullCreatureAI' WHERE `entry`= 53420;
-- Molten Seed Caster
UPDATE `creature_template` SET `unit_flags`= 0x2000000, `flags_extra`= `flags_extra` | 128, `AIName`= 'NullCreatureAI' WHERE `entry`= 53186;
-- Lava Scion - We have to disable pathfinding for this creature until gameobject pathfinding is supported.
UPDATE `creature_template` SET `ScriptName`= 'npc_ragnaros_lava_scion' WHERE `entry`= 53231;
UPDATE `creature_template` SET `flags_extra`= `flags_extra` | 0x20000000, `BaseVariance`= 0.5, `DamageModifier`= 120, `mechanic_immune_mask`= 650854271 WHERE `entry` IN (53231, 53816, 53817, 53818);
-- Molten Elemental - We have to disable pathfinding for this creature until gameobject pathfinding is supported.
UPDATE `creature_template` SET `unit_flags`= 0x100, `flags_extra`= `flags_extra` | 0x20000000, `BaseVariance`= 0.5, `DamageModifier`= 30, `mechanic_immune_mask`= 0x1 | 0x512 | 0x10000 | 0x20000 | 0x400000 WHERE `entry` IN (53189, 53810, 53811, 53812);
-- Blazing Heat
UPDATE `creature_template` SET `unit_flags`= 0x2000000, `flags_extra`= `flags_extra` | 128, `AIName`= 'NullCreatureAI' WHERE `entry`= 53473;
-- Dreadflame Spawn
UPDATE `creature_template` SET `unit_flags`= 0x2000000, `flags_extra`= `flags_extra` | 128, `AIName`= 'NullCreatureAI' WHERE `entry`= 54203;
-- Living Meteor
UPDATE `creature_template` SET `ScriptName`= 'npc_ragnaros_living_meteor' WHERE `entry`= 53500;
UPDATE `creature_template` SET `flags_extra`= `flags_extra` | 0x20000000 WHERE `entry` IN (53500, 53813, 53814, 53815);
-- Archdruids
UPDATE `creature_template` SET `ScriptName`= 'npc_ragnaros_archdruid' WHERE `entry` IN (53876, 53875, 53872);
-- Entrapping Roots
UPDATE `creature_template` SET `unit_flags`= 0x2000000, `flags_extra`= `flags_extra` | 128, `AIName`= 'NullCreatureAI' WHERE `entry`= 54074;
-- Dreadflame
UPDATE `creature_template` SET `flags_extra`= `flags_extra` | 128, `ScriptName`= 'npc_ragnaros_dreadflame' WHERE `entry`= 54127;
-- Cloudburst
UPDATE `creature_template` SET `ScriptName`= 'npc_ragnaros_cloudburst' WHERE `entry`= 54147;
UPDATE `creature_template` SET `flags_extra`= `flags_extra` | 128 WHERE `entry` IN (54147, 54155);
-- Breadth of Frost
UPDATE `creature_template` SET `unit_flags`= 0x2000000, `flags_extra`= `flags_extra` | 128, `AIName`= 'NullCreatureAI' WHERE `entry`= 53953;

DELETE FROM `creature_text` WHERE `CreatureID` IN (52409, 53231, 53872, 53875, 53876);
INSERT INTO `creature_text` (`CreatureID`, `GroupID`, `ID`, `Text`, `Type`, `Language`, `Probability`, `Emote`, `Duration`, `Sound`, `BroadcastTextId`, `comment`) VALUES
-- Ragnaros
(52409, 0, 0, 'Mortal Insects! You dare trespass into MY domain?  Your arrogance will be purged in living flame.', 14, 0, 100, 0, 0, 24517, 52203, 'Ragnaros - Emerge'),
(52409, 1, 0, 'Be consumed by flame!', 14, 0, 100, 0, 0, 24535, 52413, 'Ragnaros - Aggro'),
(52409, 1, 1, 'Begone from my realm, insects.', 14, 0, 100, 0, 0, 24533, 52411, 'Ragnaros - Aggro'),
(52409, 1, 2, 'The realm of fire will consume you!', 14, 0, 100, 0, 0, 24536, 52414, 'Ragnaros - Aggro'),
(52409, 2, 0, 'By fire be purged!', 14, 0, 100, 0, 0, 24532, 52211, 'Ragnaros - Wrath of Ragnaros'),
(52409, 3, 0, '|TInterface\\Icons\\spell_fire_selfdestruct.blp:20|t%s casts |cFFFF6600|Hspell:98164|h[Magma Trap]|h|r!', 41, 0, 100, 0, 0, 0, 52115, 'Ragnaros - Announce Magma Trap'),
(52409, 4, 0, '|TInterface\\Icons\\spell_shaman_lavasurge.blp:20|t%s begins to cast |cFFFF0000|Hspell:98710|h[Sulfuras Smash]|h|r!', 41, 0, 100, 0, 0, 0, 52125, 'Ragnaros to Sulfuras Smash'),
(52409, 5, 0, '|TInterface\\Icons\\spell_fire_ragnaros_splittingblow.blp:20|t%s begins to cast |cFFFF0000|Hspell:98951|h[Splitting Blow]|h|r!', 41, 0, 100, 0, 0, 0, 52114, 'Ragnaros - Announce Splitting Blow'),
(52409, 6, 0, 'You will be crushed!', 14, 0, 100, 0, 0, 24520, 52212, 'Ragnaros - Splitting Blow'),
(52409, 6, 1, 'Your judgement has come!', 14, 0, 100, 0, 0, 24522, 52214, 'Ragnaros  Splitting Blow'),
(52409, 7, 0, 'Denizens of flame, come to me!', 14, 0, 100, 0, 0, 24515, 52209, 'Ragnaros - Invoke Sons'),
(52409, 7, 1, 'Arise, servants of fire, consume their flesh!', 14, 0, 100, 0, 0, 24516, 52210, 'Ragnaros - Invoke Sons'),
(52409, 8, 0, 'Enough! I will finish this.', 14, 0, 100, 0, 0, 24523, 52215, 'Ragnaros - Pick up Sulfuras'),
(52409, 8, 1, 'Fall to your knees, mortals!  This ends now.', 14, 0, 100, 0, 0, 24524, 52216, 'Ragnaros - Pick up Sulfuras'),
(52409, 8, 2, 'Sulfuras will be your end.', 14, 0, 100, 0, 0, 24525, 52217, 'Ragnaros - Pick up Sulfuras'),
(52409, 9, 0, '|TInterface\\Icons\\ability_mage_worldinflames.blp:20|t%s begins to cast |cFFFF6600|Hspell:100171|h[World In Flames]|h|r!', 41, 0, 100, 0, 0, 0, 52450, 'Ragnaros - Announce World in Flames'),
(52409, 10, 0, '|TInterface\\Icons\\ability_mage_worldinflames.blp:20|t%s begins to cast |cFFFF6600|Hspell:99171|h[Engulfing Flames]|h|r!', 41, 0, 100, 0, 0, 0, 52084, 'Ragnaros - Announce Engulfing Flames'),
(52409, 11, 0, '%s is about to |cFFFF0000Emerge|r!', 41, 0, 100, 0, 0, 0, 52594, 'Ragnaros - Announce Emerge'),
(52409, 12, 0, 'Too soon! ... You have come too soon...', 14, 0, 100, 0, 0, 24519, 52218, 'Ragnaros - Defeated Normal'),
(52409, 13, 0, 'Too soon...', 14, 0, 100, 0, 0, 24528, 52219, 'Ragnaros - Submerge Heroic'),
(52409, 14, 0, 'Arrggh, outsiders - this is not your realm!', 14, 0, 100, 0, 0, 24527, 52220, 'Ragnaros - Emerge Heroic'),
(52409, 15, 0, 'When I finish this, your pathetic mortal world will burn with my vengeance!', 14, 0, 100, 0, 0, 24526, 52221, 'Ragnaros - Break Free'),
(52409, 16, 0, '|TInterface\\Icons\\inv_mace_2h_sulfuras_d_01.blp:20|t%s begins to cast |cFFFF6600|Hspell:100604|h[Empower Sulfuras]|h|r!', 41, 0, 100, 0, 0, 0, 52709, 'Ragnaros - Announce Empower Sulfuras'),
(52409, 17, 0, '|TInterface\\Icons\\ability_mage_firestarter.blp:20|t%s casts |cFFFF0000|Hspell:100675|h[Dreadflame]|h|r!', 41, 0, 100, 0, 0, 0, 52849, 'Ragnaros - Announce Dreadflame'),
(52409, 18, 0, 'Pathetic.', 14, 0, 100, 0, 0, 24530, 52205, 'Ragnaros - Slay'),
(52409, 18, 1, 'This is MY realm!', 14, 0, 100, 0, 0, 24529, 52206, 'Ragnaros - Slay'),
(52409, 18, 2, 'Begone from my realm, insects.', 14, 0, 100, 0, 0, 24533, 52411, 'Ragnaros - Slay'),
(52409, 18, 3, 'Die!', 14, 0, 100, 0, 0, 24521, 52213, 'Ragnaros - Slay'),
(52409, 19, 0, 'No, noooo- This was to be my hour of triumph...', 14, 0, 100, 0, 0, 24518, 52222, 'Ragnaros - Death'),
-- Cenarius
(53872, 0, 0, 'No, fiend. Your time is NOW.', 14, 0, 100, 0, 0, 25159, 52569, 'Cenarius'),
(53872, 1, 0, 'Perhaps...', 14, 0, 100, 0, 0, 25160, 52572, 'Cenarius'),
(53872, 2, 0, 'Ragnaros has perished.  But the primal powers he represents can never be vanquished.  Another will rise to power, someday.', 14, 0, 100, 0, 0, 25158, 52574, 'Cenarius'),
(53872, 3, 0, 'Indeed.', 14, 0, 100, 0, 0, 25161, 52576, 'Cenarius'),
-- Malfurion Stormrage
(53875, 0, 0, 'Heroes! He is bound. Finish him!', 14, 0, 100, 0, 0, 25169, 52570, 'Malfurion Stormrage '),
(53875, 1, 0, 'It is finished then!', 14, 0, 100, 0, 0, 25170, 52571, 'Malfurion Stormrage'),
(53875, 2, 0, 'Heroes, the world owes you a great debt.', 14, 0, 100, 0, 0, 25171, 52573, 'Malfurion Stormrage'),
-- Archdruid Hamuul Runetotem
(53876, 1, 0, 'Yes Cenarius, we must maintain a constant vigil over this realm.  But let us celebrate this day and the great victory we have earned here.', 14, 0, 100, 0, 0, 25168, 52575, 'Archdruid Hamuul Runetotem to Player'),
-- Lava Scion
(53231, 0, 0, '|TInterface\\Icons\\inv_elemental_mote_fire01.blp:16|tYou are about to burst into |cFFFF0000|Hspell:100460|h[Blazing Heat]|h|r!', 42, 0, 100, 0, 0, 0, 52819, 'Lava Scion - Announce Blazing Heat');

DELETE FROM `creature_summon_groups` WHERE `summonerId`= 52409;
INSERT INTO `creature_summon_groups` (`summonerId`, `summonerType`, `groupId`, `entry`, `position_x`, `position_y`, `position_z`, `orientation`, `summonType`, `summonTime`) VALUES
(52409, 0, 0, 53231, 1026.861083984375,  5.895833492279052734, 55.44696807861328125, 4.904375076293945312, 6, 3000), -- Lava Scion (Area: Sulfuron Keep - Difficulty: 0)
(52409, 0, 0, 53231, 1027.3055419921875, -121.746528625488281, 55.44710159301757812, 1.361356854438781738, 6, 3000), -- Lava Scion (Area: Sulfuron Keep - Difficulty: 0)
(52409, 0, 1, 53876, 787.2101, -50.723957, 93.77381, 6.27602386474609375, 8, 0), -- Archdruid Hamuul Runetotem (Area: Sulfuron Keep - Difficulty: 0) (Auras: 100311 - Transform (Hamuul)) (possible waypoints or random movement)
(52409, 0, 1, 53875, 786.36115, -68.770836, 93.93824, 3.261384487152099609, 8, 0), -- Malfurion Stormrage (Area: Sulfuron Keep - Difficulty: 0) (Auras: 100310 - Transform (Malfurion)) (possible waypoints or random movement)
(52409, 0, 1, 53872, 786.0003, -59.59131, 86.39431, 0.020506108179688453, 8, 0); -- Cenarius (Area: Sulfuron Keep - Difficulty: 0)

DELETE FROM `waypoint_data` WHERE `id` IN (53876 * 100, 53875 * 100, 53872 * 100);
INSERT INTO `waypoint_data` (`id`, `point`, `position_x`, `position_y`, `position_z`, `orientation`, `delay`, `move_type`, `velocity`) VALUES
(53876 * 100, 0, 982.9132, -43.220486, 59.49538, NULL, 0, 1, 24),
(53875 * 100, 0, 984.2274, -77.62153,  61.69744, NULL, 0, 1, 24),
(53872 * 100, 0, 984.13715, -57.65625, 55.366516, NULL, 0, 1, 24);

DELETE FROM `waypoint_data_addon` WHERE `PathID` IN (53876 * 100, 53875 * 100, 53872 * 100);
INSERT INTO `waypoint_data_addon` (`PathID`, `PointID`, `SplinePointIndex`, `PositionX`, `PositionY`, `PositionZ`) VALUES
-- Hamuul
(53876 * 100, 0, 0, 788.2101, -50.723957, 93.77381),
(53876 * 100, 0, 1, 789.7153, -50.376736, 97.14188),
(53876 * 100, 0, 2, 842.7656, -53.435764, 88.888725),
(53876 * 100, 0, 3, 884.75,   -36.713543, 60.775967),
(53876 * 100, 0, 4, 951.0347, -49.512154, 60.775967),
-- Malfurion
(53875 * 100, 0, 0, 787.36115, -68.770836, 93.93824),
(53875 * 100, 0, 1, 788.3715,  -69.71528,  98.04888),
(53875 * 100, 0, 2, 881.5781,  -67.989586, 79.69471),
(53875 * 100, 0, 3, 961.54517, -90.048615, 72.05601),
-- Cenarius
(53872 * 100, 0, 0, 786.9566, -59.883682, 86.39431),
(53872 * 100, 0, 1, 791.1458, -60.227432, 85.664314),
(53872 * 100, 0, 2, 821.7049, -59.600697, 71.56089),
(53872 * 100, 0, 3, 841.19446, -58.581596, 71.56089),
(53872 * 100, 0, 4, 869.1875, -59.211807, 54.77988),
(53872 * 100, 0, 5, 882.4983, -58.998264, 53.73591),
(53872 * 100, 0, 6, 890.92535, -58.80903, 49.192184),
(53872 * 100, 0, 7, 939.6042, -59.177082, 48.961807),
(53872 * 100, 0, 8, 963.4393, -58.230904, 49.187195),
(53872 * 100, 0, 9, 977.7205, -57.779514, 55.430775);

DELETE FROM `creature_template_addon` WHERE `entry` IN (52409, 53797, 53798, 53799);
DELETE FROM `creature_addon` WHERE `guid` IN (338819, 338906, 338912);
INSERT INTO `creature_addon` (`guid`, `bytes1`, `bytes2`, `visibilityDistanceType`, `auras`) VALUES
(338819, 0x3000000, 0x1, 5, ''),
(338906, 0x3000000, 0x1, 3, '99908'),
(338912, 0x3000000, 0x1, 3, '99908');

DELETE FROM `spell_script_names` WHERE `ScriptName` IN
('spell_ragnaros_wrath_of_ragnaros',
'spell_ragnaros_magma_trap',
'spell_ragnaros_magma_trap_periodic',
'spell_ragnaros_magma_trap_missile',
'spell_ragnaros_sulfuras_smash',
'spell_ragnaros_splitting_blow',
'spell_ragnaros_splitting_blow_script',
'spell_ragnaros_invoke_sons',
'spell_ragnaros_submerge',
'spell_ragnaros_invoke_sons_script',
'spell_ragnaros_burning_speed',
'spell_ragnaros_molten_seed',
'spell_ragnaros_molten_seed_dummy',
'spell_ragnaros_molten_seed_visual',
'spell_ragnaros_engulfing_flames',
'spell_ragnaros_world_in_flames',
'spell_ragnaros_molten_inferno',
'spell_ragnaros_blazing_heat',
'spell_ragnaros_blazing_heat_script',
'spell_ragnaros_blazing_heat_aoe',
'spell_ragnaros_living_meteor',
'spell_ragnaros_fixate',
'spell_ragnaros_combustible',
'spell_ragnaros_living_meteor_aoe',
'spell_ragnaros_death',
'spell_ragnaros_burning_wound',
'spell_ragnaros_empowered_sulfuras',
'spell_ragnaros_empower_sulfuras',
'spell_ragnaros_empower_sulfuras_periodic',
'spell_ragnaros_entrapping_roots',
'spell_ragnaros_entrapping_roots_aura',
'spell_ragnaros_dreadflame',
'spell_ragnaros_dreadflame_control_aura_damage',
'spell_ragnaros_dreadflame_control_aura_spawn',
'spell_ragnaros_dreadflame_control_aura_spread',
'spell_ragnaros_dreadflame_control_aura_deluge',
'spell_ragnaros_cloudburst',
'spell_ragnaros_breadth_of_frost_trigger',
'spell_ragnaros_breadth_of_frost',
'spell_ragnaros_superheated');

INSERT INTO `spell_script_names` (`spell_id`, `ScriptName`) VALUES
(98259, 'spell_ragnaros_wrath_of_ragnaros'),
(98260, 'spell_ragnaros_wrath_of_ragnaros'),
(100110, 'spell_ragnaros_wrath_of_ragnaros'),
(100111, 'spell_ragnaros_wrath_of_ragnaros'),
(98159, 'spell_ragnaros_magma_trap'),
(98171, 'spell_ragnaros_magma_trap_periodic'),
(98164, 'spell_ragnaros_magma_trap_missile'),
(98708, 'spell_ragnaros_sulfuras_smash'),
(100256, 'spell_ragnaros_sulfuras_smash'),
(100257, 'spell_ragnaros_sulfuras_smash'),
(100258, 'spell_ragnaros_sulfuras_smash'),
(98951, 'spell_ragnaros_splitting_blow'),
(100883, 'spell_ragnaros_splitting_blow'),
(100884, 'spell_ragnaros_splitting_blow'),
(100885, 'spell_ragnaros_splitting_blow'),
(99012, 'spell_ragnaros_splitting_blow_script'),
(99054, 'spell_ragnaros_invoke_sons'),
(98982, 'spell_ragnaros_submerge'),
(100295, 'spell_ragnaros_submerge'),
(100296, 'spell_ragnaros_submerge'),
(100297, 'spell_ragnaros_submerge'),
(100312 , 'spell_ragnaros_submerge'), -- Legs Submerge (Heroic Only)
(99051, 'spell_ragnaros_invoke_sons_script'),
(98473, 'spell_ragnaros_burning_speed'),
(98497, 'spell_ragnaros_molten_seed'),
(98498, 'spell_ragnaros_molten_seed_dummy'),
(100579, 'spell_ragnaros_molten_seed_dummy'),
(100580, 'spell_ragnaros_molten_seed_dummy'),
(100581, 'spell_ragnaros_molten_seed_dummy'),
(98520, 'spell_ragnaros_molten_seed_visual'),
(100887, 'spell_ragnaros_molten_seed_visual'),
(100888, 'spell_ragnaros_molten_seed_visual'),
(100889, 'spell_ragnaros_molten_seed_visual'),
(99171, 'spell_ragnaros_engulfing_flames'),
(100172, 'spell_ragnaros_engulfing_flames'),
(100173, 'spell_ragnaros_engulfing_flames'),
(100174, 'spell_ragnaros_engulfing_flames'),
(100171, 'spell_ragnaros_world_in_flames'),
(100190, 'spell_ragnaros_world_in_flames'),
(98518, 'spell_ragnaros_molten_inferno'),
(100252, 'spell_ragnaros_molten_inferno'),
(100253, 'spell_ragnaros_molten_inferno'),
(100254, 'spell_ragnaros_molten_inferno'),
(100459, 'spell_ragnaros_blazing_heat'),
(101249, 'spell_ragnaros_blazing_heat'),
(101250, 'spell_ragnaros_blazing_heat'),
(101251, 'spell_ragnaros_blazing_heat'),
(100460, 'spell_ragnaros_blazing_heat_script'),
(100981, 'spell_ragnaros_blazing_heat_script'),
(100982, 'spell_ragnaros_blazing_heat_script'),
(100983, 'spell_ragnaros_blazing_heat_script'),
(99125, 'spell_ragnaros_blazing_heat_aoe'),
(99267, 'spell_ragnaros_living_meteor'),
(101387, 'spell_ragnaros_living_meteor'),
(101388, 'spell_ragnaros_living_meteor'),
(101389, 'spell_ragnaros_living_meteor'),
(99849, 'spell_ragnaros_fixate'),
(99296, 'spell_ragnaros_combustible'),
(100282, 'spell_ragnaros_combustible'),
(100283, 'spell_ragnaros_combustible'),
(100284, 'spell_ragnaros_combustible'),
(99279, 'spell_ragnaros_living_meteor_aoe'),
(99430, 'spell_ragnaros_death'),
(99399, 'spell_ragnaros_burning_wound'),
(101238, 'spell_ragnaros_burning_wound'),
(101239, 'spell_ragnaros_burning_wound'),
(101240, 'spell_ragnaros_burning_wound'),
(100628, 'spell_ragnaros_empowered_sulfuras'),
(100604, 'spell_ragnaros_empower_sulfuras'),
(100997, 'spell_ragnaros_empower_sulfuras'),
(100605, 'spell_ragnaros_empower_sulfuras_periodic'),
(100645, 'spell_ragnaros_entrapping_roots'),
(100653, 'spell_ragnaros_entrapping_roots_aura'),
(101237, 'spell_ragnaros_entrapping_roots_aura'),
(100691, 'spell_ragnaros_dreadflame'),
(101016, 'spell_ragnaros_dreadflame'),
(100966, 'spell_ragnaros_dreadflame_control_aura_damage'),
(100906, 'spell_ragnaros_dreadflame_control_aura_spawn'),
(100695, 'spell_ragnaros_dreadflame_control_aura_spread'),
(100823, 'spell_ragnaros_dreadflame_control_aura_deluge'),
(100751, 'spell_ragnaros_cloudburst'),
(100472, 'spell_ragnaros_breadth_of_frost_trigger'),
(100503, 'spell_ragnaros_breadth_of_frost'),
(100594, 'spell_ragnaros_superheated'),
(100915, 'spell_ragnaros_superheated');

DELETE FROM `conditions` WHERE `SourceEntry` IN (98710, 100890, 100891, 100892, 98708, 100256, 100257, 100258, 98951, 100883, 100884, 100885, 99012, 99054, 99051, 98497, 98498, 100579, 100580, 100581, 100158, 100302, 99172, 100175, 100176, 100177, 99216, 99217, 99235, 100178, 100179, 100180, 99236, 100181, 100182, 100183, 99218, 99125, 99145, 100344, 100342, 100345, 100907, 100605, 100606, 100604, 100997, 100645, 100653, 101237, 100906, 100751, 100472, 100567, 101088, 101102) AND `SourceTypeOrReferenceId`= 13;
INSERT INTO `conditions` (`SourceTypeOrReferenceId`, `SourceGroup`, `SourceEntry`, `SourceId`, `ElseGroup`, `ConditionTypeOrReference`, `ConditionTarget`, `ConditionValue1`, `ConditionValue2`, `ConditionValue3`, `NegativeCondition`, `ErrorType`, `ScriptName`, `Comment`) VALUES
(13, 1, 98710, 0, 0, 31, 0, 3, 53268, 0, 0, 0, '', 'Sulfuras Smash - Target Sulfuras Smash'),
(13, 1, 100890, 0, 0, 31, 0, 3, 53268, 0, 0, 0, '', 'Sulfuras Smash - Target Sulfuras Smash'),
(13, 1, 100891, 0, 0, 31, 0, 3, 53268, 0, 0, 0, '', 'Sulfuras Smash - Target Sulfuras Smash'),
(13, 1, 100892, 0, 0, 31, 0, 3, 53268, 0, 0, 0, '', 'Sulfuras Smash - Target Sulfuras Smash'),
(13, 2, 98708, 0, 0, 31, 0, 3, 53363, 0, 0, 0, '', 'Sulfuras Smash -  Target Lava Wave'),
(13, 2, 100256, 0, 0, 31, 0, 3, 53363, 0, 0, 0, '', 'Sulfuras Smash - Target Lava Wave'),
(13, 2, 100257, 0, 0, 31, 0, 3, 53363, 0, 0, 0, '', 'Sulfuras Smash - Target Lava Wave'),
(13, 2, 100258, 0, 0, 31, 0, 3, 53363, 0, 0, 0, '', 'Sulfuras Smash - Target Lava Wave'),
(13, 4, 98708, 0, 0, 31, 0, 3, 53268, 0, 0, 0, '', 'Sulfuras Smash - Target Sulfuras Smash'),
(13, 4, 100256, 0, 0, 31, 0, 3, 53268, 0, 0, 0, '', 'Sulfuras Smash - Target Sulfuras Smash'),
(13, 4, 100257, 0, 0, 31, 0, 3, 53268, 0, 0, 0, '', 'Sulfuras Smash - Target Sulfuras Smash'),
(13, 4, 100258, 0, 0, 31, 0, 3, 53268, 0, 0, 0, '', 'Sulfuras Smash - Target Sulfuras Smash'),
(13, 1, 98951, 0, 0, 31, 0, 3, 53393, 0, 0, 0, '', 'Splitting Blow - Target Splitting Blow'),
(13, 1, 100883, 0, 0, 31, 0, 3, 53393, 0, 0, 0, '', 'Splitting Blow - Target Splitting Blow'),
(13, 1, 100884, 0, 0, 31, 0, 3, 53393, 0, 0, 0, '', 'Splitting Blow - Target Splitting Blow'),
(13, 1, 100885, 0, 0, 31, 0, 3, 53393, 0, 0, 0, '', 'Splitting Blow - Target Splitting Blow'),
(13, 1, 99012, 0, 0, 31, 0, 3, 53393, 0, 0, 0, '', 'Splitting Blow - Target Splitting Blow'),
(13, 1, 99051, 0, 0, 31, 0, 3, 53140, 0, 0, 0, '', 'Invoke Sons - Target Son Of Flame'),
(13, 1, 99054, 0, 0, 31, 0, 3, 53140, 0, 0, 0, '', 'Invoke Sons - Target Son Of Flame'),
(13, 1, 98497, 0, 0, 31, 0, 3, 53186, 0, 0, 0, '', 'Molten Seed - Target Molten Seed Caster'),
(13, 2, 98498, 0, 0, 31, 0, 3, 53189, 0, 0, 0, '', 'Molten Seed - Target Molten Elemental'),
(13, 2, 100579, 0, 0, 31, 0, 3, 53189, 0, 0, 0, '', 'Molten Seed - Target Molten Elemental'),
(13, 2, 100580, 0, 0, 31, 0, 3, 53189, 0, 0, 0, '', 'Molten Seed - Target Molten Elemental'),
(13, 2, 100581, 0, 0, 31, 0, 3, 53189, 0, 0, 0, '', 'Molten Seed - Target Molten Elemental'),
(13, 7, 100158, 0, 0, 31, 0, 3, 53189, 0, 0, 0, '', 'Molten Power - Target Molten Elemental'),
(13, 7, 100302, 0, 0, 31, 0, 3, 53189, 0, 0, 0, '', 'Molten Power - Target Molten Elemental'),
-- Engulfing Flames Near
(13, 1, 99172,  0, 0,  31, 0, 3, 53485, 338918, 0, 0, '', 'Engulfing Flames - Target Engulfing Flames'),
(13, 1, 99172,  0, 1,  31, 0, 3, 53485, 338917, 0, 0, '', 'Engulfing Flames - Target Engulfing Flames'),
(13, 1, 99172,  0, 2,  31, 0, 3, 53485, 338916, 0, 0, '', 'Engulfing Flames - Target Engulfing Flames'),
(13, 1, 99172,  0, 3,  31, 0, 3, 53485, 338910, 0, 0, '', 'Engulfing Flames - Target Engulfing Flames'),
(13, 1, 99172,  0, 4,  31, 0, 3, 53485, 338902, 0, 0, '', 'Engulfing Flames - Target Engulfing Flames'),
(13, 1, 99172,  0, 5,  31, 0, 3, 53485, 338888, 0, 0, '', 'Engulfing Flames - Target Engulfing Flames'),
(13, 1, 99172,  0, 6,  31, 0, 3, 53485, 338882, 0, 0, '', 'Engulfing Flames - Target Engulfing Flames'),
(13, 1, 99172,  0, 7,  31, 0, 3, 53485, 338873, 0, 0, '', 'Engulfing Flames - Target Engulfing Flames'),
(13, 1, 99172,  0, 8,  31, 0, 3, 53485, 338868, 0, 0, '', 'Engulfing Flames - Target Engulfing Flames'),
(13, 1, 99172,  0, 9,  31, 0, 3, 53485, 338869, 0, 0, '', 'Engulfing Flames - Target Engulfing Flames'),
(13, 1, 99172,  0, 10, 31, 0, 3, 53485, 338872, 0, 0, '', 'Engulfing Flames - Target Engulfing Flames'),
(13, 1, 99172,  0, 11, 31, 0, 3, 53485, 338879, 0, 0, '', 'Engulfing Flames - Target Engulfing Flames'),
(13, 1, 99172,  0, 12, 31, 0, 3, 53485, 338886, 0, 0, '', 'Engulfing Flames - Target Engulfing Flames'),
(13, 1, 99172,  0, 13, 31, 0, 3, 53485, 338899, 0, 0, '', 'Engulfing Flames - Target Engulfing Flames'),
(13, 1, 99172,  0, 14, 31, 0, 3, 53485, 338908, 0, 0, '', 'Engulfing Flames - Target Engulfing Flames'),
(13, 1, 99172,  0, 15, 31, 0, 3, 53485, 338913, 0, 0, '', 'Engulfing Flames - Target Engulfing Flames'),
(13, 1, 99172,  0, 16, 31, 0, 3, 53485, 338915, 0, 0, '', 'Engulfing Flames - Target Engulfing Flames'),
(13, 1, 99172,  0, 17, 31, 0, 3, 53485, 338919, 0, 0, '', 'Engulfing Flames - Target Engulfing Flames'),
(13, 1, 100175, 0, 0,  31, 0, 3, 53485, 338918, 0, 0, '', 'Engulfing Flames - Target Engulfing Flames'),
(13, 1, 100175, 0, 1,  31, 0, 3, 53485, 338917, 0, 0, '', 'Engulfing Flames - Target Engulfing Flames'),
(13, 1, 100175, 0, 2,  31, 0, 3, 53485, 338916, 0, 0, '', 'Engulfing Flames - Target Engulfing Flames'),
(13, 1, 100175, 0, 3,  31, 0, 3, 53485, 338910, 0, 0, '', 'Engulfing Flames - Target Engulfing Flames'),
(13, 1, 100175, 0, 4,  31, 0, 3, 53485, 338902, 0, 0, '', 'Engulfing Flames - Target Engulfing Flames'),
(13, 1, 100175, 0, 5,  31, 0, 3, 53485, 338888, 0, 0, '', 'Engulfing Flames - Target Engulfing Flames'),
(13, 1, 100175, 0, 6,  31, 0, 3, 53485, 338882, 0, 0, '', 'Engulfing Flames - Target Engulfing Flames'),
(13, 1, 100175, 0, 7,  31, 0, 3, 53485, 338873, 0, 0, '', 'Engulfing Flames - Target Engulfing Flames'),
(13, 1, 100175, 0, 8,  31, 0, 3, 53485, 338868, 0, 0, '', 'Engulfing Flames - Target Engulfing Flames'),
(13, 1, 100175, 0, 9,  31, 0, 3, 53485, 338869, 0, 0, '', 'Engulfing Flames - Target Engulfing Flames'),
(13, 1, 100175, 0, 10, 31, 0, 3, 53485, 338872, 0, 0, '', 'Engulfing Flames - Target Engulfing Flames'),
(13, 1, 100175, 0, 11, 31, 0, 3, 53485, 338879, 0, 0, '', 'Engulfing Flames - Target Engulfing Flames'),
(13, 1, 100175, 0, 12, 31, 0, 3, 53485, 338886, 0, 0, '', 'Engulfing Flames - Target Engulfing Flames'),
(13, 1, 100175, 0, 13, 31, 0, 3, 53485, 338899, 0, 0, '', 'Engulfing Flames - Target Engulfing Flames'),
(13, 1, 100175, 0, 14, 31, 0, 3, 53485, 338908, 0, 0, '', 'Engulfing Flames - Target Engulfing Flames'),
(13, 1, 100175, 0, 15, 31, 0, 3, 53485, 338913, 0, 0, '', 'Engulfing Flames - Target Engulfing Flames'),
(13, 1, 100175, 0, 16, 31, 0, 3, 53485, 338915, 0, 0, '', 'Engulfing Flames - Target Engulfing Flames'),
(13, 1, 100175, 0, 17, 31, 0, 3, 53485, 338919, 0, 0, '', 'Engulfing Flames - Target Engulfing Flames'),
(13, 1, 100176, 0, 0,  31, 0, 3, 53485, 338918, 0, 0, '', 'Engulfing Flames - Target Engulfing Flames'),
(13, 1, 100176, 0, 1,  31, 0, 3, 53485, 338917, 0, 0, '', 'Engulfing Flames - Target Engulfing Flames'),
(13, 1, 100176, 0, 2,  31, 0, 3, 53485, 338916, 0, 0, '', 'Engulfing Flames - Target Engulfing Flames'),
(13, 1, 100176, 0, 3,  31, 0, 3, 53485, 338910, 0, 0, '', 'Engulfing Flames - Target Engulfing Flames'),
(13, 1, 100176, 0, 4,  31, 0, 3, 53485, 338902, 0, 0, '', 'Engulfing Flames - Target Engulfing Flames'),
(13, 1, 100176, 0, 5,  31, 0, 3, 53485, 338888, 0, 0, '', 'Engulfing Flames - Target Engulfing Flames'),
(13, 1, 100176, 0, 6,  31, 0, 3, 53485, 338882, 0, 0, '', 'Engulfing Flames - Target Engulfing Flames'),
(13, 1, 100176, 0, 7,  31, 0, 3, 53485, 338873, 0, 0, '', 'Engulfing Flames - Target Engulfing Flames'),
(13, 1, 100176, 0, 8,  31, 0, 3, 53485, 338868, 0, 0, '', 'Engulfing Flames - Target Engulfing Flames'),
(13, 1, 100176, 0, 9,  31, 0, 3, 53485, 338869, 0, 0, '', 'Engulfing Flames - Target Engulfing Flames'),
(13, 1, 100176, 0, 10, 31, 0, 3, 53485, 338872, 0, 0, '', 'Engulfing Flames - Target Engulfing Flames'),
(13, 1, 100176, 0, 11, 31, 0, 3, 53485, 338879, 0, 0, '', 'Engulfing Flames - Target Engulfing Flames'),
(13, 1, 100176, 0, 12, 31, 0, 3, 53485, 338886, 0, 0, '', 'Engulfing Flames - Target Engulfing Flames'),
(13, 1, 100176, 0, 13, 31, 0, 3, 53485, 338899, 0, 0, '', 'Engulfing Flames - Target Engulfing Flames'),
(13, 1, 100176, 0, 14, 31, 0, 3, 53485, 338908, 0, 0, '', 'Engulfing Flames - Target Engulfing Flames'),
(13, 1, 100176, 0, 15, 31, 0, 3, 53485, 338913, 0, 0, '', 'Engulfing Flames - Target Engulfing Flames'),
(13, 1, 100176, 0, 16, 31, 0, 3, 53485, 338915, 0, 0, '', 'Engulfing Flames - Target Engulfing Flames'),
(13, 1, 100176, 0, 17, 31, 0, 3, 53485, 338919, 0, 0, '', 'Engulfing Flames - Target Engulfing Flames'),
(13, 1, 100177, 0, 0,  31, 0, 3, 53485, 338918, 0, 0, '', 'Engulfing Flames - Target Engulfing Flames'),
(13, 1, 100177, 0, 1,  31, 0, 3, 53485, 338917, 0, 0, '', 'Engulfing Flames - Target Engulfing Flames'),
(13, 1, 100177, 0, 2,  31, 0, 3, 53485, 338916, 0, 0, '', 'Engulfing Flames - Target Engulfing Flames'),
(13, 1, 100177, 0, 3,  31, 0, 3, 53485, 338910, 0, 0, '', 'Engulfing Flames - Target Engulfing Flames'),
(13, 1, 100177, 0, 4,  31, 0, 3, 53485, 338902, 0, 0, '', 'Engulfing Flames - Target Engulfing Flames'),
(13, 1, 100177, 0, 5,  31, 0, 3, 53485, 338888, 0, 0, '', 'Engulfing Flames - Target Engulfing Flames'),
(13, 1, 100177, 0, 6,  31, 0, 3, 53485, 338882, 0, 0, '', 'Engulfing Flames - Target Engulfing Flames'),
(13, 1, 100177, 0, 7,  31, 0, 3, 53485, 338873, 0, 0, '', 'Engulfing Flames - Target Engulfing Flames'),
(13, 1, 100177, 0, 8,  31, 0, 3, 53485, 338868, 0, 0, '', 'Engulfing Flames - Target Engulfing Flames'),
(13, 1, 100177, 0, 9,  31, 0, 3, 53485, 338869, 0, 0, '', 'Engulfing Flames - Target Engulfing Flames'),
(13, 1, 100177, 0, 10, 31, 0, 3, 53485, 338872, 0, 0, '', 'Engulfing Flames - Target Engulfing Flames'),
(13, 1, 100177, 0, 11, 31, 0, 3, 53485, 338879, 0, 0, '', 'Engulfing Flames - Target Engulfing Flames'),
(13, 1, 100177, 0, 12, 31, 0, 3, 53485, 338886, 0, 0, '', 'Engulfing Flames - Target Engulfing Flames'),
(13, 1, 100177, 0, 13, 31, 0, 3, 53485, 338899, 0, 0, '', 'Engulfing Flames - Target Engulfing Flames'),
(13, 1, 100177, 0, 14, 31, 0, 3, 53485, 338908, 0, 0, '', 'Engulfing Flames - Target Engulfing Flames'),
(13, 1, 100177, 0, 15, 31, 0, 3, 53485, 338913, 0, 0, '', 'Engulfing Flames - Target Engulfing Flames'),
(13, 1, 100177, 0, 16, 31, 0, 3, 53485, 338915, 0, 0, '', 'Engulfing Flames - Target Engulfing Flames'),
(13, 1, 100177, 0, 17, 31, 0, 3, 53485, 338919, 0, 0, '', 'Engulfing Flames - Target Engulfing Flames'),
(13, 1, 99216,  0, 0,  31, 0, 3, 53485, 338918, 0, 0, '', 'Engulfing Flames Near Visual - Target Engulfing Flames'),
(13, 1, 99216,  0, 1,  31, 0, 3, 53485, 338917, 0, 0, '', 'Engulfing Flames Near Visual - Target Engulfing Flames'),
(13, 1, 99216,  0, 2,  31, 0, 3, 53485, 338916, 0, 0, '', 'Engulfing Flames Near Visual - Target Engulfing Flames'),
(13, 1, 99216,  0, 3,  31, 0, 3, 53485, 338910, 0, 0, '', 'Engulfing Flames Near Visual - Target Engulfing Flames'),
(13, 1, 99216,  0, 4,  31, 0, 3, 53485, 338902, 0, 0, '', 'Engulfing Flames Near Visual - Target Engulfing Flames'),
(13, 1, 99216,  0, 5,  31, 0, 3, 53485, 338888, 0, 0, '', 'Engulfing Flames Near Visual - Target Engulfing Flames'),
(13, 1, 99216,  0, 6,  31, 0, 3, 53485, 338882, 0, 0, '', 'Engulfing Flames Near Visual - Target Engulfing Flames'),
(13, 1, 99216,  0, 7,  31, 0, 3, 53485, 338873, 0, 0, '', 'Engulfing Flames Near Visual - Target Engulfing Flames'),
(13, 1, 99216,  0, 8,  31, 0, 3, 53485, 338868, 0, 0, '', 'Engulfing Flames Near Visual - Target Engulfing Flames'),
(13, 1, 99216,  0, 9,  31, 0, 3, 53485, 338869, 0, 0, '', 'Engulfing Flames Near Visual - Target Engulfing Flames'),
(13, 1, 99216,  0, 10, 31, 0, 3, 53485, 338872, 0, 0, '', 'Engulfing Flames Near Visual - Target Engulfing Flames'),
(13, 1, 99216,  0, 11, 31, 0, 3, 53485, 338879, 0, 0, '', 'Engulfing Flames Near Visual - Target Engulfing Flames'),
(13, 1, 99216,  0, 12, 31, 0, 3, 53485, 338886, 0, 0, '', 'Engulfing Flames Near Visual - Target Engulfing Flames'),
(13, 1, 99216,  0, 13, 31, 0, 3, 53485, 338899, 0, 0, '', 'Engulfing Flames Near Visual - Target Engulfing Flames'),
(13, 1, 99216,  0, 14, 31, 0, 3, 53485, 338908, 0, 0, '', 'Engulfing Flames Near Visual - Target Engulfing Flames'),
(13, 1, 99216,  0, 15, 31, 0, 3, 53485, 338913, 0, 0, '', 'Engulfing Flames Near Visual - Target Engulfing Flames'),
(13, 1, 99216,  0, 16, 31, 0, 3, 53485, 338915, 0, 0, '', 'Engulfing Flames Near Visual - Target Engulfing Flames'),
(13, 1, 99216,  0, 17, 31, 0, 3, 53485, 338919, 0, 0, '', 'Engulfing Flames Near Visual - Target Engulfing Flames'),
-- Engulfing Flames Middle
(13, 1, 99235,  0, 0,  31, 0, 3, 53485, 338905, 0, 0, '', 'Engulfing Flames - Target Engulfing Flames'),
(13, 1, 99235,  0, 1,  31, 0, 3, 53485, 338903, 0, 0, '', 'Engulfing Flames - Target Engulfing Flames'),
(13, 1, 99235,  0, 2,  31, 0, 3, 53485, 338897, 0, 0, '', 'Engulfing Flames - Target Engulfing Flames'),
(13, 1, 99235,  0, 3,  31, 0, 3, 53485, 338890, 0, 0, '', 'Engulfing Flames - Target Engulfing Flames'),
(13, 1, 99235,  0, 4,  31, 0, 3, 53485, 338877, 0, 0, '', 'Engulfing Flames - Target Engulfing Flames'),
(13, 1, 99235,  0, 5,  31, 0, 3, 53485, 338862, 0, 0, '', 'Engulfing Flames - Target Engulfing Flames'),
(13, 1, 99235,  0, 6,  31, 0, 3, 53485, 338857, 0, 0, '', 'Engulfing Flames - Target Engulfing Flames'),
(13, 1, 99235,  0, 7,  31, 0, 3, 53485, 338854, 0, 0, '', 'Engulfing Flames - Target Engulfing Flames'),
(13, 1, 99235,  0, 8,  31, 0, 3, 53485, 338851, 0, 0, '', 'Engulfing Flames - Target Engulfing Flames'),
(13, 1, 99235,  0, 9,  31, 0, 3, 53485, 338853, 0, 0, '', 'Engulfing Flames - Target Engulfing Flames'),
(13, 1, 99235,  0, 10, 31, 0, 3, 53485, 338856, 0, 0, '', 'Engulfing Flames - Target Engulfing Flames'),
(13, 1, 99235,  0, 11, 31, 0, 3, 53485, 338860, 0, 0, '', 'Engulfing Flames - Target Engulfing Flames'),
(13, 1, 99235,  0, 12, 31, 0, 3, 53485, 338867, 0, 0, '', 'Engulfing Flames - Target Engulfing Flames'),
(13, 1, 99235,  0, 13, 31, 0, 3, 53485, 338880, 0, 0, '', 'Engulfing Flames - Target Engulfing Flames'),
(13, 1, 99235,  0, 14, 31, 0, 3, 53485, 338889, 0, 0, '', 'Engulfing Flames - Target Engulfing Flames'),
(13, 1, 99235,  0, 15, 31, 0, 3, 53485, 338901, 0, 0, '', 'Engulfing Flames - Target Engulfing Flames'),
(13, 1, 99235,  0, 16, 31, 0, 3, 53485, 338904, 0, 0, '', 'Engulfing Flames - Target Engulfing Flames'),
(13, 1, 100178, 0, 0,  31, 0, 3, 53485, 338905, 0, 0, '', 'Engulfing Flames - Target Engulfing Flames'),
(13, 1, 100178, 0, 1,  31, 0, 3, 53485, 338903, 0, 0, '', 'Engulfing Flames - Target Engulfing Flames'),
(13, 1, 100178, 0, 2,  31, 0, 3, 53485, 338897, 0, 0, '', 'Engulfing Flames - Target Engulfing Flames'),
(13, 1, 100178, 0, 3,  31, 0, 3, 53485, 338890, 0, 0, '', 'Engulfing Flames - Target Engulfing Flames'),
(13, 1, 100178, 0, 4,  31, 0, 3, 53485, 338877, 0, 0, '', 'Engulfing Flames - Target Engulfing Flames'),
(13, 1, 100178, 0, 5,  31, 0, 3, 53485, 338862, 0, 0, '', 'Engulfing Flames - Target Engulfing Flames'),
(13, 1, 100178, 0, 6,  31, 0, 3, 53485, 338857, 0, 0, '', 'Engulfing Flames - Target Engulfing Flames'),
(13, 1, 100178, 0, 7,  31, 0, 3, 53485, 338854, 0, 0, '', 'Engulfing Flames - Target Engulfing Flames'),
(13, 1, 100178, 0, 8,  31, 0, 3, 53485, 338851, 0, 0, '', 'Engulfing Flames - Target Engulfing Flames'),
(13, 1, 100178, 0, 9,  31, 0, 3, 53485, 338853, 0, 0, '', 'Engulfing Flames - Target Engulfing Flames'),
(13, 1, 100178, 0, 10, 31, 0, 3, 53485, 338856, 0, 0, '', 'Engulfing Flames - Target Engulfing Flames'),
(13, 1, 100178, 0, 11, 31, 0, 3, 53485, 338860, 0, 0, '', 'Engulfing Flames - Target Engulfing Flames'),
(13, 1, 100178, 0, 12, 31, 0, 3, 53485, 338867, 0, 0, '', 'Engulfing Flames - Target Engulfing Flames'),
(13, 1, 100178, 0, 13, 31, 0, 3, 53485, 338880, 0, 0, '', 'Engulfing Flames - Target Engulfing Flames'),
(13, 1, 100178, 0, 14, 31, 0, 3, 53485, 338889, 0, 0, '', 'Engulfing Flames - Target Engulfing Flames'),
(13, 1, 100178, 0, 15, 31, 0, 3, 53485, 338901, 0, 0, '', 'Engulfing Flames - Target Engulfing Flames'),
(13, 1, 100178, 0, 16, 31, 0, 3, 53485, 338904, 0, 0, '', 'Engulfing Flames - Target Engulfing Flames'),
(13, 1, 100179, 0, 0,  31, 0, 3, 53485, 338905, 0, 0, '', 'Engulfing Flames - Target Engulfing Flames'),
(13, 1, 100179, 0, 1,  31, 0, 3, 53485, 338903, 0, 0, '', 'Engulfing Flames - Target Engulfing Flames'),
(13, 1, 100179, 0, 2,  31, 0, 3, 53485, 338897, 0, 0, '', 'Engulfing Flames - Target Engulfing Flames'),
(13, 1, 100179, 0, 3,  31, 0, 3, 53485, 338890, 0, 0, '', 'Engulfing Flames - Target Engulfing Flames'),
(13, 1, 100179, 0, 4,  31, 0, 3, 53485, 338877, 0, 0, '', 'Engulfing Flames - Target Engulfing Flames'),
(13, 1, 100179, 0, 5,  31, 0, 3, 53485, 338862, 0, 0, '', 'Engulfing Flames - Target Engulfing Flames'),
(13, 1, 100179, 0, 6,  31, 0, 3, 53485, 338857, 0, 0, '', 'Engulfing Flames - Target Engulfing Flames'),
(13, 1, 100179, 0, 7,  31, 0, 3, 53485, 338854, 0, 0, '', 'Engulfing Flames - Target Engulfing Flames'),
(13, 1, 100179, 0, 8,  31, 0, 3, 53485, 338851, 0, 0, '', 'Engulfing Flames - Target Engulfing Flames'),
(13, 1, 100179, 0, 9,  31, 0, 3, 53485, 338853, 0, 0, '', 'Engulfing Flames - Target Engulfing Flames'),
(13, 1, 100179, 0, 10, 31, 0, 3, 53485, 338856, 0, 0, '', 'Engulfing Flames - Target Engulfing Flames'),
(13, 1, 100179, 0, 11, 31, 0, 3, 53485, 338860, 0, 0, '', 'Engulfing Flames - Target Engulfing Flames'),
(13, 1, 100179, 0, 12, 31, 0, 3, 53485, 338867, 0, 0, '', 'Engulfing Flames - Target Engulfing Flames'),
(13, 1, 100179, 0, 13, 31, 0, 3, 53485, 338880, 0, 0, '', 'Engulfing Flames - Target Engulfing Flames'),
(13, 1, 100179, 0, 14, 31, 0, 3, 53485, 338889, 0, 0, '', 'Engulfing Flames - Target Engulfing Flames'),
(13, 1, 100179, 0, 15, 31, 0, 3, 53485, 338901, 0, 0, '', 'Engulfing Flames - Target Engulfing Flames'),
(13, 1, 100179, 0, 16, 31, 0, 3, 53485, 338904, 0, 0, '', 'Engulfing Flames - Target Engulfing Flames'),
(13, 1, 100180, 0, 0,  31, 0, 3, 53485, 338905, 0, 0, '', 'Engulfing Flames - Target Engulfing Flames'),
(13, 1, 100180, 0, 1,  31, 0, 3, 53485, 338903, 0, 0, '', 'Engulfing Flames - Target Engulfing Flames'),
(13, 1, 100180, 0, 2,  31, 0, 3, 53485, 338897, 0, 0, '', 'Engulfing Flames - Target Engulfing Flames'),
(13, 1, 100180, 0, 3,  31, 0, 3, 53485, 338890, 0, 0, '', 'Engulfing Flames - Target Engulfing Flames'),
(13, 1, 100180, 0, 4,  31, 0, 3, 53485, 338877, 0, 0, '', 'Engulfing Flames - Target Engulfing Flames'),
(13, 1, 100180, 0, 5,  31, 0, 3, 53485, 338862, 0, 0, '', 'Engulfing Flames - Target Engulfing Flames'),
(13, 1, 100180, 0, 6,  31, 0, 3, 53485, 338857, 0, 0, '', 'Engulfing Flames - Target Engulfing Flames'),
(13, 1, 100180, 0, 7,  31, 0, 3, 53485, 338854, 0, 0, '', 'Engulfing Flames - Target Engulfing Flames'),
(13, 1, 100180, 0, 8,  31, 0, 3, 53485, 338851, 0, 0, '', 'Engulfing Flames - Target Engulfing Flames'),
(13, 1, 100180, 0, 9,  31, 0, 3, 53485, 338853, 0, 0, '', 'Engulfing Flames - Target Engulfing Flames'),
(13, 1, 100180, 0, 10, 31, 0, 3, 53485, 338856, 0, 0, '', 'Engulfing Flames - Target Engulfing Flames'),
(13, 1, 100180, 0, 11, 31, 0, 3, 53485, 338860, 0, 0, '', 'Engulfing Flames - Target Engulfing Flames'),
(13, 1, 100180, 0, 12, 31, 0, 3, 53485, 338867, 0, 0, '', 'Engulfing Flames - Target Engulfing Flames'),
(13, 1, 100180, 0, 13, 31, 0, 3, 53485, 338880, 0, 0, '', 'Engulfing Flames - Target Engulfing Flames'),
(13, 1, 100180, 0, 14, 31, 0, 3, 53485, 338889, 0, 0, '', 'Engulfing Flames - Target Engulfing Flames'),
(13, 1, 100180, 0, 15, 31, 0, 3, 53485, 338901, 0, 0, '', 'Engulfing Flames - Target Engulfing Flames'),
(13, 1, 100180, 0, 16, 31, 0, 3, 53485, 338904, 0, 0, '', 'Engulfing Flames - Target Engulfing Flames'),
(13, 1, 99217,  0, 0,  31, 0, 3, 53485, 338905, 0, 0, '', 'Engulfing Flames Middle Visual - Target Engulfing Flames'),
(13, 1, 99217,  0, 1,  31, 0, 3, 53485, 338903, 0, 0, '', 'Engulfing Flames Middle Visual - Target Engulfing Flames'),
(13, 1, 99217,  0, 2,  31, 0, 3, 53485, 338897, 0, 0, '', 'Engulfing Flames Middle Visual - Target Engulfing Flames'),
(13, 1, 99217,  0, 3,  31, 0, 3, 53485, 338890, 0, 0, '', 'Engulfing Flames Middle Visual - Target Engulfing Flames'),
(13, 1, 99217,  0, 4,  31, 0, 3, 53485, 338877, 0, 0, '', 'Engulfing Flames Middle Visual - Target Engulfing Flames'),
(13, 1, 99217,  0, 5,  31, 0, 3, 53485, 338862, 0, 0, '', 'Engulfing Flames Middle Visual - Target Engulfing Flames'),
(13, 1, 99217,  0, 6,  31, 0, 3, 53485, 338857, 0, 0, '', 'Engulfing Flames Middle Visual - Target Engulfing Flames'),
(13, 1, 99217,  0, 7,  31, 0, 3, 53485, 338854, 0, 0, '', 'Engulfing Flames Middle Visual - Target Engulfing Flames'),
(13, 1, 99217,  0, 8,  31, 0, 3, 53485, 338851, 0, 0, '', 'Engulfing Flames Middle Visual - Target Engulfing Flames'),
(13, 1, 99217,  0, 9,  31, 0, 3, 53485, 338853, 0, 0, '', 'Engulfing Flames Middle Visual - Target Engulfing Flames'),
(13, 1, 99217,  0, 10, 31, 0, 3, 53485, 338856, 0, 0, '', 'Engulfing Flames Middle Visual - Target Engulfing Flames'),
(13, 1, 99217,  0, 11, 31, 0, 3, 53485, 338860, 0, 0, '', 'Engulfing Flames Middle Visual - Target Engulfing Flames'),
(13, 1, 99217,  0, 12, 31, 0, 3, 53485, 338867, 0, 0, '', 'Engulfing Flames Middle Visual - Target Engulfing Flames'),
(13, 1, 99217,  0, 13, 31, 0, 3, 53485, 338880, 0, 0, '', 'Engulfing Flames Middle Visual - Target Engulfing Flames'),
(13, 1, 99217,  0, 14, 31, 0, 3, 53485, 338889, 0, 0, '', 'Engulfing Flames Middle Visual - Target Engulfing Flames'),
(13, 1, 99217,  0, 15, 31, 0, 3, 53485, 338901, 0, 0, '', 'Engulfing Flames Middle Visual - Target Engulfing Flames'),
(13, 1, 99217,  0, 16, 31, 0, 3, 53485, 338904, 0, 0, '', 'Engulfing Flames Middle Visual - Target Engulfing Flames'),
-- Engulfing Flames Far
(13, 1, 99236,  0, 0,  31, 0, 3, 53485, 338898, 0, 0, '', 'Engulfing Flames - Target Engulfing Flames'),
(13, 1, 99236,  0, 1,  31, 0, 3, 53485, 338892, 0, 0, '', 'Engulfing Flames - Target Engulfing Flames'),
(13, 1, 99236,  0, 2,  31, 0, 3, 53485, 338883, 0, 0, '', 'Engulfing Flames - Target Engulfing Flames'),
(13, 1, 99236,  0, 3,  31, 0, 3, 53485, 338865, 0, 0, '', 'Engulfing Flames - Target Engulfing Flames'),
(13, 1, 99236,  0, 4,  31, 0, 3, 53485, 338852, 0, 0, '', 'Engulfing Flames - Target Engulfing Flames'),
(13, 1, 99236,  0, 5,  31, 0, 3, 53485, 338844, 0, 0, '', 'Engulfing Flames - Target Engulfing Flames'),
(13, 1, 99236,  0, 6,  31, 0, 3, 53485, 338839, 0, 0, '', 'Engulfing Flames - Target Engulfing Flames'),
(13, 1, 99236,  0, 7,  31, 0, 3, 53485, 338837, 0, 0, '', 'Engulfing Flames - Target Engulfing Flames'),
(13, 1, 99236,  0, 8,  31, 0, 3, 53485, 338836, 0, 0, '', 'Engulfing Flames - Target Engulfing Flames'),
(13, 1, 99236,  0, 9,  31, 0, 3, 53485, 338838, 0, 0, '', 'Engulfing Flames - Target Engulfing Flames'),
(13, 1, 99236,  0, 10, 31, 0, 3, 53485, 338840, 0, 0, '', 'Engulfing Flames - Target Engulfing Flames'),
(13, 1, 99236,  0, 11, 31, 0, 3, 53485, 338843, 0, 0, '', 'Engulfing Flames - Target Engulfing Flames'),
(13, 1, 99236,  0, 12, 31, 0, 3, 53485, 338849, 0, 0, '', 'Engulfing Flames - Target Engulfing Flames'),
(13, 1, 99236,  0, 13, 31, 0, 3, 53485, 338866, 0, 0, '', 'Engulfing Flames - Target Engulfing Flames'),
(13, 1, 99236,  0, 14, 31, 0, 3, 53485, 338881, 0, 0, '', 'Engulfing Flames - Target Engulfing Flames'),
(13, 1, 99236,  0, 15, 31, 0, 3, 53485, 338891, 0, 0, '', 'Engulfing Flames - Target Engulfing Flames'),
(13, 1, 99236,  0, 16, 31, 0, 3, 53485, 338895, 0, 0, '', 'Engulfing Flames - Target Engulfing Flames'),
(13, 1, 99236,  0, 17, 31, 0, 3, 53485, 338885, 0, 0, '', 'Engulfing Flames - Target Engulfing Flames'),
(13, 1, 99236,  0, 18, 31, 0, 3, 53485, 338870, 0, 0, '', 'Engulfing Flames - Target Engulfing Flames'),
(13, 1, 99236,  0, 19, 31, 0, 3, 53485, 338861, 0, 0, '', 'Engulfing Flames - Target Engulfing Flames'),
(13, 1, 99236,  0, 20, 31, 0, 3, 53485, 338850, 0, 0, '', 'Engulfing Flames - Target Engulfing Flames'),
(13, 1, 99236,  0, 21, 31, 0, 3, 53485, 338841, 0, 0, '', 'Engulfing Flames - Target Engulfing Flames'),
(13, 1, 99236,  0, 22, 31, 0, 3, 53485, 338832, 0, 0, '', 'Engulfing Flames - Target Engulfing Flames'),
(13, 1, 99236,  0, 23, 31, 0, 3, 53485, 338830, 0, 0, '', 'Engulfing Flames - Target Engulfing Flames'),
(13, 1, 99236,  0, 24, 31, 0, 3, 53485, 338822, 0, 0, '', 'Engulfing Flames - Target Engulfing Flames'),
(13, 1, 99236,  0, 25, 31, 0, 3, 53485, 338834, 0, 0, '', 'Engulfing Flames - Target Engulfing Flames'),
(13, 1, 99236,  0, 26, 31, 0, 3, 53485, 338829, 0, 0, '', 'Engulfing Flames - Target Engulfing Flames'),
(13, 1, 99236,  0, 27, 31, 0, 3, 53485, 338831, 0, 0, '', 'Engulfing Flames - Target Engulfing Flames'),
(13, 1, 99236,  0, 28, 31, 0, 3, 53485, 338833, 0, 0, '', 'Engulfing Flames - Target Engulfing Flames'),
(13, 1, 99236,  0, 29, 31, 0, 3, 53485, 338842, 0, 0, '', 'Engulfing Flames - Target Engulfing Flames'),
(13, 1, 99236,  0, 30, 31, 0, 3, 53485, 338846, 0, 0, '', 'Engulfing Flames - Target Engulfing Flames'),
(13, 1, 99236,  0, 31, 31, 0, 3, 53485, 338855, 0, 0, '', 'Engulfing Flames - Target Engulfing Flames'),
(13, 1, 99236,  0, 32, 31, 0, 3, 53485, 338864, 0, 0, '', 'Engulfing Flames - Target Engulfing Flames'),
(13, 1, 99236,  0, 33, 31, 0, 3, 53485, 338871, 0, 0, '', 'Engulfing Flames - Target Engulfing Flames'),
(13, 1, 99236,  0, 34, 31, 0, 3, 53485, 338884, 0, 0, '', 'Engulfing Flames - Target Engulfing Flames'),
(13, 1, 100181, 0, 0,  31, 0, 3, 53485, 338898, 0, 0, '', 'Engulfing Flames - Target Engulfing Flames'),
(13, 1, 100181, 0, 1,  31, 0, 3, 53485, 338892, 0, 0, '', 'Engulfing Flames - Target Engulfing Flames'),
(13, 1, 100181, 0, 2,  31, 0, 3, 53485, 338883, 0, 0, '', 'Engulfing Flames - Target Engulfing Flames'),
(13, 1, 100181, 0, 3,  31, 0, 3, 53485, 338865, 0, 0, '', 'Engulfing Flames - Target Engulfing Flames'),
(13, 1, 100181, 0, 4,  31, 0, 3, 53485, 338852, 0, 0, '', 'Engulfing Flames - Target Engulfing Flames'),
(13, 1, 100181, 0, 5,  31, 0, 3, 53485, 338844, 0, 0, '', 'Engulfing Flames - Target Engulfing Flames'),
(13, 1, 100181, 0, 6,  31, 0, 3, 53485, 338839, 0, 0, '', 'Engulfing Flames - Target Engulfing Flames'),
(13, 1, 100181, 0, 7,  31, 0, 3, 53485, 338837, 0, 0, '', 'Engulfing Flames - Target Engulfing Flames'),
(13, 1, 100181, 0, 8,  31, 0, 3, 53485, 338836, 0, 0, '', 'Engulfing Flames - Target Engulfing Flames'),
(13, 1, 100181, 0, 9,  31, 0, 3, 53485, 338838, 0, 0, '', 'Engulfing Flames - Target Engulfing Flames'),
(13, 1, 100181, 0, 10, 31, 0, 3, 53485, 338840, 0, 0, '', 'Engulfing Flames - Target Engulfing Flames'),
(13, 1, 100181, 0, 11, 31, 0, 3, 53485, 338843, 0, 0, '', 'Engulfing Flames - Target Engulfing Flames'),
(13, 1, 100181, 0, 12, 31, 0, 3, 53485, 338849, 0, 0, '', 'Engulfing Flames - Target Engulfing Flames'),
(13, 1, 100181, 0, 13, 31, 0, 3, 53485, 338866, 0, 0, '', 'Engulfing Flames - Target Engulfing Flames'),
(13, 1, 100181, 0, 14, 31, 0, 3, 53485, 338881, 0, 0, '', 'Engulfing Flames - Target Engulfing Flames'),
(13, 1, 100181, 0, 15, 31, 0, 3, 53485, 338891, 0, 0, '', 'Engulfing Flames - Target Engulfing Flames'),
(13, 1, 100181, 0, 16, 31, 0, 3, 53485, 338895, 0, 0, '', 'Engulfing Flames - Target Engulfing Flames'),
(13, 1, 100181, 0, 17, 31, 0, 3, 53485, 338885, 0, 0, '', 'Engulfing Flames - Target Engulfing Flames'),
(13, 1, 100181, 0, 18, 31, 0, 3, 53485, 338870, 0, 0, '', 'Engulfing Flames - Target Engulfing Flames'),
(13, 1, 100181, 0, 19, 31, 0, 3, 53485, 338861, 0, 0, '', 'Engulfing Flames - Target Engulfing Flames'),
(13, 1, 100181, 0, 20, 31, 0, 3, 53485, 338850, 0, 0, '', 'Engulfing Flames - Target Engulfing Flames'),
(13, 1, 100181, 0, 21, 31, 0, 3, 53485, 338841, 0, 0, '', 'Engulfing Flames - Target Engulfing Flames'),
(13, 1, 100181, 0, 22, 31, 0, 3, 53485, 338832, 0, 0, '', 'Engulfing Flames - Target Engulfing Flames'),
(13, 1, 100181, 0, 23, 31, 0, 3, 53485, 338830, 0, 0, '', 'Engulfing Flames - Target Engulfing Flames'),
(13, 1, 100181, 0, 24, 31, 0, 3, 53485, 338822, 0, 0, '', 'Engulfing Flames - Target Engulfing Flames'),
(13, 1, 100181, 0, 25, 31, 0, 3, 53485, 338834, 0, 0, '', 'Engulfing Flames - Target Engulfing Flames'),
(13, 1, 100181, 0, 26, 31, 0, 3, 53485, 338829, 0, 0, '', 'Engulfing Flames - Target Engulfing Flames'),
(13, 1, 100181, 0, 27, 31, 0, 3, 53485, 338831, 0, 0, '', 'Engulfing Flames - Target Engulfing Flames'),
(13, 1, 100181, 0, 28, 31, 0, 3, 53485, 338833, 0, 0, '', 'Engulfing Flames - Target Engulfing Flames'),
(13, 1, 100181, 0, 29, 31, 0, 3, 53485, 338842, 0, 0, '', 'Engulfing Flames - Target Engulfing Flames'),
(13, 1, 100181, 0, 30, 31, 0, 3, 53485, 338846, 0, 0, '', 'Engulfing Flames - Target Engulfing Flames'),
(13, 1, 100181, 0, 31, 31, 0, 3, 53485, 338855, 0, 0, '', 'Engulfing Flames - Target Engulfing Flames'),
(13, 1, 100181, 0, 32, 31, 0, 3, 53485, 338864, 0, 0, '', 'Engulfing Flames - Target Engulfing Flames'),
(13, 1, 100181, 0, 33, 31, 0, 3, 53485, 338871, 0, 0, '', 'Engulfing Flames - Target Engulfing Flames'),
(13, 1, 100181, 0, 34, 31, 0, 3, 53485, 338884, 0, 0, '', 'Engulfing Flames - Target Engulfing Flames'),
(13, 1, 100182, 0, 0,  31, 0, 3, 53485, 338898, 0, 0, '', 'Engulfing Flames - Target Engulfing Flames'),
(13, 1, 100182, 0, 1,  31, 0, 3, 53485, 338892, 0, 0, '', 'Engulfing Flames - Target Engulfing Flames'),
(13, 1, 100182, 0, 2,  31, 0, 3, 53485, 338883, 0, 0, '', 'Engulfing Flames - Target Engulfing Flames'),
(13, 1, 100182, 0, 3,  31, 0, 3, 53485, 338865, 0, 0, '', 'Engulfing Flames - Target Engulfing Flames'),
(13, 1, 100182, 0, 4,  31, 0, 3, 53485, 338852, 0, 0, '', 'Engulfing Flames - Target Engulfing Flames'),
(13, 1, 100182, 0, 5,  31, 0, 3, 53485, 338844, 0, 0, '', 'Engulfing Flames - Target Engulfing Flames'),
(13, 1, 100182, 0, 6,  31, 0, 3, 53485, 338839, 0, 0, '', 'Engulfing Flames - Target Engulfing Flames'),
(13, 1, 100182, 0, 7,  31, 0, 3, 53485, 338837, 0, 0, '', 'Engulfing Flames - Target Engulfing Flames'),
(13, 1, 100182, 0, 8,  31, 0, 3, 53485, 338836, 0, 0, '', 'Engulfing Flames - Target Engulfing Flames'),
(13, 1, 100182, 0, 9,  31, 0, 3, 53485, 338838, 0, 0, '', 'Engulfing Flames - Target Engulfing Flames'),
(13, 1, 100182, 0, 10, 31, 0, 3, 53485, 338840, 0, 0, '', 'Engulfing Flames - Target Engulfing Flames'),
(13, 1, 100182, 0, 11, 31, 0, 3, 53485, 338843, 0, 0, '', 'Engulfing Flames - Target Engulfing Flames'),
(13, 1, 100182, 0, 12, 31, 0, 3, 53485, 338849, 0, 0, '', 'Engulfing Flames - Target Engulfing Flames'),
(13, 1, 100182, 0, 13, 31, 0, 3, 53485, 338866, 0, 0, '', 'Engulfing Flames - Target Engulfing Flames'),
(13, 1, 100182, 0, 14, 31, 0, 3, 53485, 338881, 0, 0, '', 'Engulfing Flames - Target Engulfing Flames'),
(13, 1, 100182, 0, 15, 31, 0, 3, 53485, 338891, 0, 0, '', 'Engulfing Flames - Target Engulfing Flames'),
(13, 1, 100182, 0, 16, 31, 0, 3, 53485, 338895, 0, 0, '', 'Engulfing Flames - Target Engulfing Flames'),
(13, 1, 100182, 0, 17, 31, 0, 3, 53485, 338885, 0, 0, '', 'Engulfing Flames - Target Engulfing Flames'),
(13, 1, 100182, 0, 18, 31, 0, 3, 53485, 338870, 0, 0, '', 'Engulfing Flames - Target Engulfing Flames'),
(13, 1, 100182, 0, 19, 31, 0, 3, 53485, 338861, 0, 0, '', 'Engulfing Flames - Target Engulfing Flames'),
(13, 1, 100182, 0, 20, 31, 0, 3, 53485, 338850, 0, 0, '', 'Engulfing Flames - Target Engulfing Flames'),
(13, 1, 100182, 0, 21, 31, 0, 3, 53485, 338841, 0, 0, '', 'Engulfing Flames - Target Engulfing Flames'),
(13, 1, 100182, 0, 22, 31, 0, 3, 53485, 338832, 0, 0, '', 'Engulfing Flames - Target Engulfing Flames'),
(13, 1, 100182, 0, 23, 31, 0, 3, 53485, 338830, 0, 0, '', 'Engulfing Flames - Target Engulfing Flames'),
(13, 1, 100182, 0, 24, 31, 0, 3, 53485, 338822, 0, 0, '', 'Engulfing Flames - Target Engulfing Flames'),
(13, 1, 100182, 0, 25, 31, 0, 3, 53485, 338834, 0, 0, '', 'Engulfing Flames - Target Engulfing Flames'),
(13, 1, 100182, 0, 26, 31, 0, 3, 53485, 338829, 0, 0, '', 'Engulfing Flames - Target Engulfing Flames'),
(13, 1, 100182, 0, 27, 31, 0, 3, 53485, 338831, 0, 0, '', 'Engulfing Flames - Target Engulfing Flames'),
(13, 1, 100182, 0, 28, 31, 0, 3, 53485, 338833, 0, 0, '', 'Engulfing Flames - Target Engulfing Flames'),
(13, 1, 100182, 0, 29, 31, 0, 3, 53485, 338842, 0, 0, '', 'Engulfing Flames - Target Engulfing Flames'),
(13, 1, 100182, 0, 30, 31, 0, 3, 53485, 338846, 0, 0, '', 'Engulfing Flames - Target Engulfing Flames'),
(13, 1, 100182, 0, 31, 31, 0, 3, 53485, 338855, 0, 0, '', 'Engulfing Flames - Target Engulfing Flames'),
(13, 1, 100182, 0, 32, 31, 0, 3, 53485, 338864, 0, 0, '', 'Engulfing Flames - Target Engulfing Flames'),
(13, 1, 100182, 0, 33, 31, 0, 3, 53485, 338871, 0, 0, '', 'Engulfing Flames - Target Engulfing Flames'),
(13, 1, 100182, 0, 34, 31, 0, 3, 53485, 338884, 0, 0, '', 'Engulfing Flames - Target Engulfing Flames'),
(13, 1, 100183, 0, 0,  31, 0, 3, 53485, 338898, 0, 0, '', 'Engulfing Flames - Target Engulfing Flames'),
(13, 1, 100183, 0, 1,  31, 0, 3, 53485, 338892, 0, 0, '', 'Engulfing Flames - Target Engulfing Flames'),
(13, 1, 100183, 0, 2,  31, 0, 3, 53485, 338883, 0, 0, '', 'Engulfing Flames - Target Engulfing Flames'),
(13, 1, 100183, 0, 3,  31, 0, 3, 53485, 338865, 0, 0, '', 'Engulfing Flames - Target Engulfing Flames'),
(13, 1, 100183, 0, 4,  31, 0, 3, 53485, 338852, 0, 0, '', 'Engulfing Flames - Target Engulfing Flames'),
(13, 1, 100183, 0, 5,  31, 0, 3, 53485, 338844, 0, 0, '', 'Engulfing Flames - Target Engulfing Flames'),
(13, 1, 100183, 0, 6,  31, 0, 3, 53485, 338839, 0, 0, '', 'Engulfing Flames - Target Engulfing Flames'),
(13, 1, 100183, 0, 7,  31, 0, 3, 53485, 338837, 0, 0, '', 'Engulfing Flames - Target Engulfing Flames'),
(13, 1, 100183, 0, 8,  31, 0, 3, 53485, 338836, 0, 0, '', 'Engulfing Flames - Target Engulfing Flames'),
(13, 1, 100183, 0, 9,  31, 0, 3, 53485, 338838, 0, 0, '', 'Engulfing Flames - Target Engulfing Flames'),
(13, 1, 100183, 0, 10, 31, 0, 3, 53485, 338840, 0, 0, '', 'Engulfing Flames - Target Engulfing Flames'),
(13, 1, 100183, 0, 11, 31, 0, 3, 53485, 338843, 0, 0, '', 'Engulfing Flames - Target Engulfing Flames'),
(13, 1, 100183, 0, 12, 31, 0, 3, 53485, 338849, 0, 0, '', 'Engulfing Flames - Target Engulfing Flames'),
(13, 1, 100183, 0, 13, 31, 0, 3, 53485, 338866, 0, 0, '', 'Engulfing Flames - Target Engulfing Flames'),
(13, 1, 100183, 0, 14, 31, 0, 3, 53485, 338881, 0, 0, '', 'Engulfing Flames - Target Engulfing Flames'),
(13, 1, 100183, 0, 15, 31, 0, 3, 53485, 338891, 0, 0, '', 'Engulfing Flames - Target Engulfing Flames'),
(13, 1, 100183, 0, 16, 31, 0, 3, 53485, 338895, 0, 0, '', 'Engulfing Flames - Target Engulfing Flames'),
(13, 1, 100183, 0, 17, 31, 0, 3, 53485, 338885, 0, 0, '', 'Engulfing Flames - Target Engulfing Flames'),
(13, 1, 100183, 0, 18, 31, 0, 3, 53485, 338870, 0, 0, '', 'Engulfing Flames - Target Engulfing Flames'),
(13, 1, 100183, 0, 19, 31, 0, 3, 53485, 338861, 0, 0, '', 'Engulfing Flames - Target Engulfing Flames'),
(13, 1, 100183, 0, 20, 31, 0, 3, 53485, 338850, 0, 0, '', 'Engulfing Flames - Target Engulfing Flames'),
(13, 1, 100183, 0, 21, 31, 0, 3, 53485, 338841, 0, 0, '', 'Engulfing Flames - Target Engulfing Flames'),
(13, 1, 100183, 0, 22, 31, 0, 3, 53485, 338832, 0, 0, '', 'Engulfing Flames - Target Engulfing Flames'),
(13, 1, 100183, 0, 23, 31, 0, 3, 53485, 338830, 0, 0, '', 'Engulfing Flames - Target Engulfing Flames'),
(13, 1, 100183, 0, 24, 31, 0, 3, 53485, 338822, 0, 0, '', 'Engulfing Flames - Target Engulfing Flames'),
(13, 1, 100183, 0, 25, 31, 0, 3, 53485, 338834, 0, 0, '', 'Engulfing Flames - Target Engulfing Flames'),
(13, 1, 100183, 0, 26, 31, 0, 3, 53485, 338829, 0, 0, '', 'Engulfing Flames - Target Engulfing Flames'),
(13, 1, 100183, 0, 27, 31, 0, 3, 53485, 338831, 0, 0, '', 'Engulfing Flames - Target Engulfing Flames'),
(13, 1, 100183, 0, 28, 31, 0, 3, 53485, 338833, 0, 0, '', 'Engulfing Flames - Target Engulfing Flames'),
(13, 1, 100183, 0, 29, 31, 0, 3, 53485, 338842, 0, 0, '', 'Engulfing Flames - Target Engulfing Flames'),
(13, 1, 100183, 0, 30, 31, 0, 3, 53485, 338846, 0, 0, '', 'Engulfing Flames - Target Engulfing Flames'),
(13, 1, 100183, 0, 31, 31, 0, 3, 53485, 338855, 0, 0, '', 'Engulfing Flames - Target Engulfing Flames'),
(13, 1, 100183, 0, 32, 31, 0, 3, 53485, 338864, 0, 0, '', 'Engulfing Flames - Target Engulfing Flames'),
(13, 1, 100183, 0, 33, 31, 0, 3, 53485, 338871, 0, 0, '', 'Engulfing Flames - Target Engulfing Flames'),
(13, 1, 100183, 0, 34, 31, 0, 3, 53485, 338884, 0, 0, '', 'Engulfing Flames - Target Engulfing Flames'),
(13, 1, 99218,  0, 0,  31, 0, 3, 53485, 338898, 0, 0, '', 'Engulfing Flames Far Visual - Target Engulfing Flames'),
(13, 1, 99218,  0, 1,  31, 0, 3, 53485, 338892, 0, 0, '', 'Engulfing Flames Far Visual - Target Engulfing Flames'),
(13, 1, 99218,  0, 2,  31, 0, 3, 53485, 338883, 0, 0, '', 'Engulfing Flames Far Visual - Target Engulfing Flames'),
(13, 1, 99218,  0, 3,  31, 0, 3, 53485, 338865, 0, 0, '', 'Engulfing Flames Far Visual - Target Engulfing Flames'),
(13, 1, 99218,  0, 4,  31, 0, 3, 53485, 338852, 0, 0, '', 'Engulfing Flames Far Visual - Target Engulfing Flames'),
(13, 1, 99218,  0, 5,  31, 0, 3, 53485, 338844, 0, 0, '', 'Engulfing Flames Far Visual - Target Engulfing Flames'),
(13, 1, 99218,  0, 6,  31, 0, 3, 53485, 338839, 0, 0, '', 'Engulfing Flames Far Visual - Target Engulfing Flames'),
(13, 1, 99218,  0, 7,  31, 0, 3, 53485, 338837, 0, 0, '', 'Engulfing Flames Far Visual - Target Engulfing Flames'),
(13, 1, 99218,  0, 8,  31, 0, 3, 53485, 338836, 0, 0, '', 'Engulfing Flames Far Visual - Target Engulfing Flames'),
(13, 1, 99218,  0, 9,  31, 0, 3, 53485, 338838, 0, 0, '', 'Engulfing Flames Far Visual - Target Engulfing Flames'),
(13, 1, 99218,  0, 10, 31, 0, 3, 53485, 338840, 0, 0, '', 'Engulfing Flames Far Visual - Target Engulfing Flames'),
(13, 1, 99218,  0, 11, 31, 0, 3, 53485, 338843, 0, 0, '', 'Engulfing Flames Far Visual - Target Engulfing Flames'),
(13, 1, 99218,  0, 12, 31, 0, 3, 53485, 338849, 0, 0, '', 'Engulfing Flames Far Visual - Target Engulfing Flames'),
(13, 1, 99218,  0, 13, 31, 0, 3, 53485, 338866, 0, 0, '', 'Engulfing Flames Far Visual - Target Engulfing Flames'),
(13, 1, 99218,  0, 14, 31, 0, 3, 53485, 338881, 0, 0, '', 'Engulfing Flames Far Visual - Target Engulfing Flames'),
(13, 1, 99218,  0, 15, 31, 0, 3, 53485, 338891, 0, 0, '', 'Engulfing Flames Far Visual - Target Engulfing Flames'),
(13, 1, 99218,  0, 16, 31, 0, 3, 53485, 338895, 0, 0, '', 'Engulfing Flames Far Visual - Target Engulfing Flames'),
(13, 1, 99218,  0, 17, 31, 0, 3, 53485, 338885, 0, 0, '', 'Engulfing Flames Far Visual - Target Engulfing Flames'),
(13, 1, 99218,  0, 18, 31, 0, 3, 53485, 338870, 0, 0, '', 'Engulfing Flames Far Visual - Target Engulfing Flames'),
(13, 1, 99218,  0, 19, 31, 0, 3, 53485, 338861, 0, 0, '', 'Engulfing Flames Far Visual - Target Engulfing Flames'),
(13, 1, 99218,  0, 20, 31, 0, 3, 53485, 338850, 0, 0, '', 'Engulfing Flames Far Visual - Target Engulfing Flames'),
(13, 1, 99218,  0, 21, 31, 0, 3, 53485, 338841, 0, 0, '', 'Engulfing Flames Far Visual - Target Engulfing Flames'),
(13, 1, 99218,  0, 22, 31, 0, 3, 53485, 338832, 0, 0, '', 'Engulfing Flames Far Visual - Target Engulfing Flames'),
(13, 1, 99218,  0, 23, 31, 0, 3, 53485, 338830, 0, 0, '', 'Engulfing Flames Far Visual - Target Engulfing Flames'),
(13, 1, 99218,  0, 24, 31, 0, 3, 53485, 338822, 0, 0, '', 'Engulfing Flames Far Visual - Target Engulfing Flames'),
(13, 1, 99218,  0, 25, 31, 0, 3, 53485, 338834, 0, 0, '', 'Engulfing Flames Far Visual - Target Engulfing Flames'),
(13, 1, 99218,  0, 26, 31, 0, 3, 53485, 338829, 0, 0, '', 'Engulfing Flames Far Visual - Target Engulfing Flames'),
(13, 1, 99218,  0, 27, 31, 0, 3, 53485, 338831, 0, 0, '', 'Engulfing Flames Far Visual - Target Engulfing Flames'),
(13, 1, 99218,  0, 28, 31, 0, 3, 53485, 338833, 0, 0, '', 'Engulfing Flames Far Visual - Target Engulfing Flames'),
(13, 1, 99218,  0, 29, 31, 0, 3, 53485, 338842, 0, 0, '', 'Engulfing Flames Far Visual - Target Engulfing Flames'),
(13, 1, 99218,  0, 30, 31, 0, 3, 53485, 338846, 0, 0, '', 'Engulfing Flames Far Visual - Target Engulfing Flames'),
(13, 1, 99218,  0, 31, 31, 0, 3, 53485, 338855, 0, 0, '', 'Engulfing Flames Far Visual - Target Engulfing Flames'),
(13, 1, 99218,  0, 32, 31, 0, 3, 53485, 338864, 0, 0, '', 'Engulfing Flames Far Visual - Target Engulfing Flames'),
(13, 1, 99218,  0, 33, 31, 0, 3, 53485, 338871, 0, 0, '', 'Engulfing Flames Far Visual - Target Engulfing Flames'),
(13, 1, 99218,  0, 34, 31, 0, 3, 53485, 338884, 0, 0, '', 'Engulfing Flames Far Visual - Target Engulfing Flames'),
(13, 1, 99125,  0, 0,  31, 0, 3, 53473, 0, 0, 0, '', 'Blazing Heat - Target Blazing Heat'),
(13, 1, 99145,  0, 0,  31, 0, 3, 53231, 0, 0, 0, '', 'Blazing Heat - Target Lava Scion'),
(13, 1, 99145,  0, 1,  31, 0, 3, 53140, 0, 0, 0, '', 'Blazing Heat - Target Son of Flame'),
(13, 1, 100344, 0, 0,  31, 0, 3, 52409, 0, 0, 0, '', 'Draw Out Firelord - Target Ragnaros'),
(13, 1, 100342, 0, 0,  31, 0, 3, 52409, 0, 0, 0, '', 'Draw Out Firelord - Target Ragnaros'),
(13, 1, 100345, 0, 0,  31, 0, 3, 52409, 0, 0, 0, '', 'Draw Out Firelord - Target Ragnaros'),
(13, 1, 100907, 0, 0,  31, 0, 3, 53500, 0, 0, 0, '', 'Freeze - Target Living Meteor'),
(13, 1, 100605, 0, 0,  31, 0, 3, 53186, 0, 0, 0, '', 'Empower Sulfuras - Target Molten Seed Caster'),
(13, 2, 100604, 0, 0,  31, 0, 3, 53186, 0, 0, 0, '', 'Empower Sulfuras - Target Molten Seed Caster'),
(13, 2, 100997, 0, 0,  31, 0, 3, 53186, 0, 0, 0, '', 'Empower Sulfuras - Target Molten Seed Caster'),
(13, 1, 100606, 0, 0,  31, 0, 3, 52409, 0, 0, 0, '', 'Empower Sulfuras Missile - Target Ragnaros'),
(13, 1, 100645, 0, 0,  31, 0, 3, 53952, 0, 0, 0, '', 'Entrapping Roots - Target Platform Stalker'),
(13, 3, 100653, 0, 0,  31, 0, 3, 52409, 0, 0, 0, '', 'Entrapping Roots - Target Ragnaros'),
(13, 3, 101237, 0, 0,  31, 0, 3, 52409, 0, 0, 0, '', 'Entrapping Roots - Target Ragnaros'),
(13, 1, 100906, 0, 0,  31, 0, 3, 54203, 0, 0, 0, '', 'Dreadflame Control Aura - Target Dreadflame Spawn'),
(13, 1, 100751, 0, 0,  31, 0, 3, 53952, 0, 0, 0, '', 'Cloudburst - Target Platform Stalker'),
(13, 1, 100472, 0, 0,  31, 0, 3, 53952, 0, 0, 0, '', 'Breadth of Frost Trigger - Target Platform Stalker'),
(13, 7, 100567, 0, 0,  31, 0, 3, 53500, 0, 0, 0, '', 'Breadth of Frost - Target Living Meteor'),
(13, 1, 101088, 0, 0,  31, 0, 3, 53500, 0, 0, 0, '', 'Lavalogged - Target Living Meteor'),
(13, 1, 101102, 0, 0,  31, 0, 3, 53500, 0, 0, 0, '', 'Lavalogged - Target Living Meteor');

DELETE FROM `spawn_group_template` WHERE `groupId` IN (458, 459);
INSERT INTO `spawn_group_template` (`groupId`, `groupName`, `groupFlags`) VALUES
(458, 'Firelands - Ragnaros', 4),
(459, 'Firelands - Ragnaros Stalkers', 4);

DELETE FROM `spawn_group` WHERE `groupId` IN (458, 459);
INSERT INTO `spawn_group` (`groupId`, `spawnType`, `spawnId`) VALUES
(458, 0, 338819),
(459, 0, 338823),
(459, 0, 338824),
(459, 0, 338825),
(459, 0, 338826),
(459, 0, 338827),
(459, 0, 338828),
(459, 0, 338835),
(459, 0, 338845),
(459, 0, 338859),
(459, 0, 338863),
(459, 0, 338876),
(459, 0, 338887),
(459, 0, 338894),
(459, 0, 338900),
(459, 0, 338907),
(459, 0, 338911),
(459, 0, 338914),
(459, 0, 338920),
(459, 0, 338921),
(459, 0, 338922),
(459, 0, 338923),
(459, 0, 338858),
(459, 0, 338874),
(459, 0, 338875),
(459, 0, 338822),
(459, 0, 338829),
(459, 0, 338830),
(459, 0, 338831),
(459, 0, 338832),
(459, 0, 338833),
(459, 0, 338834),
(459, 0, 338836),
(459, 0, 338837),
(459, 0, 338838),
(459, 0, 338839),
(459, 0, 338840),
(459, 0, 338841),
(459, 0, 338842),
(459, 0, 338843),
(459, 0, 338844),
(459, 0, 338846),
(459, 0, 338849),
(459, 0, 338850),
(459, 0, 338851),
(459, 0, 338852),
(459, 0, 338853),
(459, 0, 338854),
(459, 0, 338855),
(459, 0, 338856),
(459, 0, 338857),
(459, 0, 338860),
(459, 0, 338861),
(459, 0, 338862),
(459, 0, 338864),
(459, 0, 338865),
(459, 0, 338866),
(459, 0, 338867),
(459, 0, 338868),
(459, 0, 338869),
(459, 0, 338870),
(459, 0, 338871),
(459, 0, 338872),
(459, 0, 338873),
(459, 0, 338877),
(459, 0, 338879),
(459, 0, 338880),
(459, 0, 338881),
(459, 0, 338882),
(459, 0, 338883),
(459, 0, 338884),
(459, 0, 338885),
(459, 0, 338886),
(459, 0, 338888),
(459, 0, 338889),
(459, 0, 338890),
(459, 0, 338891),
(459, 0, 338892),
(459, 0, 338895),
(459, 0, 338897),
(459, 0, 338898),
(459, 0, 338899),
(459, 0, 338901),
(459, 0, 338902),
(459, 0, 338903),
(459, 0, 338904),
(459, 0, 338905),
(459, 0, 338908),
(459, 0, 338909),
(459, 0, 338910),
(459, 0, 338913),
(459, 0, 338915),
(459, 0, 338916),
(459, 0, 338917),
(459, 0, 338918),
(459, 0, 338919),
(459, 0, 338847),
(459, 0, 338848),
(459, 0, 338878),
(459, 0, 338893),
(459, 0, 338896),
(459, 0, 338906),
(459, 0, 338912);

DELETE FROM `areatrigger_scripts` WHERE `ScriptName`= 'at_fl_ragnaros_spawn';
INSERT INTO `areatrigger_scripts` (`entry`, `ScriptName`) VALUES
(6845, 'at_fl_ragnaros_spawn');

DELETE FROM `creature_template_movement` WHERE `CreatureId` IN (52409, 53086, 53266, 53268, 53363, 53140, 53420, 53186, 53485, 53797, 53798, 53799, 53876, 53875, 53920, 53952, 53729, 54074, 54127, 54203, 54147, 54155);
INSERT INTO `creature_template_movement` (`CreatureId`, `Ground`, `Swim`, `Flight`, `Rooted`) VALUES
-- Ragnaros
(52409, 1, 0, 0, 0),
(53797, 1, 0, 0, 0),
(53798, 1, 0, 0, 0),
(53799, 1, 0, 0, 0),
(53920, 1, 0, 0, 0),
-- Magma Trap
(53086, 1, 0, 1, 1),
-- Sulfuras Smash
(53266, 1, 0, 1, 1),
(53268, 1, 0, 1, 1),
-- Lava Wave
(53363, 1, 0, 1, 0),
-- Son of Flame
(53140, 1, 0, 0, 0),
-- Sulfuras, Hand of Ragnaros
(53420, 1, 0, 1, 0),
-- Molten Seed Caster
(53186, 1, 0, 1, 1),
-- Engulfing Flames
(53485, 1, 0, 1, 1),
-- Platform Stalker
(53952, 1, 0, 1, 1),
-- Magma
(53729, 0, 0, 1, 1),
-- Entrapping Roots
(54074, 1, 0, 1, 1),
-- Dreadflame Spawn
(54203, 1, 0, 1, 1),
-- Dreadflame
(54127, 1, 0, 1, 1),
-- Archdruid Hamuul Runetotem
(53876, 1, 0, 1, 0),
-- Malfurion Stormrage
(53875, 1, 0, 1, 0),
-- Cloudburst
(54147, 0, 0, 1, 1),
(54155, 0, 0, 1, 1);

DELETE FROM `spell_dbc` WHERE `Id`= 100170;
INSERT INTO `spell_dbc` (`Id`, `Attributes`, `AttributesEx`, `AttributesEx2`, `AttributesEx3`, `AttributesEx4`, `AttributesEx6`, `SpellAuraOptionsId`, `DurationIndex`, `SpellName`) VALUES
(100170, 0x00800180, 0x10000000, 0x00000005, 0x00100000, 0x00000080, 0x00000404, 7249, 21, '(Serverside/Non-DB2) Molten Seed');

DELETE FROM `spelleffect_dbc` WHERE `Id`= 160114;
INSERT INTO `spelleffect_dbc` (`Id`, `SpellID`, `Effect`, `EffectAura`, `EffectBasePoints`, `EffectIndex`, `Comment`) VALUES
(160114, 100170, 6, 61, 20, 0, '(Serverside/Non-DB2) Molten Seed');

UPDATE `instance_encounters` SET `creditType`= 1, `creditEntry`= 102237 WHERE `entry`= 1203;

DELETE FROM `spell_target_position` WHERE `ID` IN (101095, 101096, 100679);
INSERT INTO `spell_target_position` (`ID`, `EffectIndex`, `MapID`, `PositionX`, `PositionY`, `PositionZ`, `Orientation`, `VerifiedBuild`) VALUES
(101095, 0, 720, 1012.49, -57.2882, 55.3302, 3.533860683441162109, 15211),
(101096, 0, 720, 1012.49, -57.2882, 55.3302, 3.533860683441162109, 15211),
(100679, 0, 720, 1041.25, -57.4478, 55.5,    0,                    15595);

DELETE FROM `creature` WHERE `guid`= 339066;
DELETE FROM `creature_addon` WHERE `guid`= 339066;

UPDATE `creature_model_info` SET `BoundingRadius`= 0.75, `CombatReach`= 21 WHERE `DisplayID`= 38570;

DELETE FROM `spell_dbc` WHERE `Id`= 102237;
INSERT INTO `spell_dbc` (`Id`, `Attributes`, `AttributesEx`, `AttributesEx2`, `AttributesEx3`, `AttributesEx4`, `AttributesEx5`, `AttributesEx6`, `AttributesEx7`, `AttributesEx8`, `AttributesEx9`, `AttributesEx10`, `CastingTimeIndex`, `DurationIndex`, `RangeIndex`, `SchoolMask`, `SpellAuraOptionsId`, `SpellCastingRequirementsId`, `SpellCategoriesId`, `SpellClassOptionsId`, `SpellEquippedItemsId`, `SpellInterruptsId`, `SpellLevelsId`, `SpellTargetRestrictionsId`, `SpellName`) VALUES
(102237, 2843738368, 268436512, 540677, 269943552, 128, 393225, 5120, 33554432, 32, 0, 0, 0, 36, 13, 0, 38, 0, 0, 0, 0, 0, 0, 0, '(Serverside/Non-DB2) Ragnaros Kill Credit (DND)');
-- Cataclysm Raid Boss Armor
UPDATE `creature_classlevelstats` SET `basearmor`= 11977 WHERE `level`= 88;
DELETE FROM `spell_script_names` WHERE `ScriptName`= 'spell_sha_clearcasting';
INSERT INTO `spell_script_names` (`spell_id`, `ScriptName`) VALUES
(16246, 'spell_sha_clearcasting');
DROP TABLE IF EXISTS `spell_proc_event`;
DELETE FROM `spell_script_names` WHERE `ScriptName`= 'spell_pri_devouring_plague';
INSERT INTO `spell_script_names` (`spell_id`, `ScriptName`) VALUES
(2944, 'spell_pri_devouring_plague');
-- Shooting Stars
UPDATE `spell_proc` SET `SpellFamilyName`= 7, `ProcFlags`= 0 WHERE `SpellId`= -93398;
-- Telluric Currents
UPDATE `spell_proc` SET `ProcFlags`= 0 WHERE `SpellId`= -82984;
-- Thunderstruck
UPDATE `spell_proc` SET `ProcFlags`= 0 WHERE `SpellId`= -80979;

-- Long Arm of the Law
DELETE FROM `spell_proc` WHERE `SpellId`= -87168;
DELETE FROM `spell_script_names` WHERE `ScriptName`= 'spell_pal_long_arm_of_the_law';
UPDATE `spell_proc` SET `ProcFlags`= 0, `SpellTypeMask`= 1 WHERE `SpellId`= 79683;
UPDATE `spell_proc` SET `SpellFamilyMask0`= 0x20000000 | 0x2 | 0x1 | 0x10 | 0x200 | 0x40 | 0x20 | 0x20000 | 0x400000 | 0x1000 | 0x4 | 0x80 | 0x800000, `SpellFamilyMask1`= 0x8000 | 0x1000,  `SpellFamilyMask2`= 0x0, `ProcFlags`= 0, `SpellTypeMask`= 1 WHERE `SpellId`= 79684;
DELETE FROM `spell_proc` WHERE `SpellId` IN (55640, 75171);
INSERT INTO `spell_proc` (`SpellId`, `SpellTypeMask`, `SpellPhaseMask`, `Cooldown`) VALUES
(55640, 0x1 | 0x2, 0x1, 60000),
(75171, 0x1 | 0x2, 0x1, 64000);
UPDATE `spell_proc` SET `SpellTypeMask`= 0x1 | 0x2 WHERE `SpellId` IN (90848, 90886, 90888, 90892, 90897, 90899, 90990, 90993, 95878);
DELETE FROM `spell_script_names` WHERE `ScriptName` IN ('spell_throngus_flaming_arrow', 'spell_throngus_fixate_effect');
UPDATE `creature_template` SET `ScriptName`= '', `AIName`= 'NullCreatureAI' WHERE `entry`= 40228;
DELETE FROM `spell_group` WHERE `id`= 1151;
INSERT INTO `spell_group` (`id`, `spell_id`) VALUES
(1151, 32216),
(1151, 82368);

DELETE FROM `spell_group_stack_rules` WHERE `group_id`= 1151;
INSERT INTO `spell_group_stack_rules` (`group_id`, `stack_rule`) VALUES
(1151, 2);
DELETE FROM `spell_script_names` WHERE `ScriptName`= 'spell_warr_heroic_fury';
INSERT INTO `spell_script_names` (`spell_id`,`ScriptName`) VALUES
(60970, 'spell_warr_heroic_fury');

UPDATE `spell_proc` SET `SpellFamilyMask0`= 0x8 WHERE `SpellId`= -12311;
DELETE FROM `spell_script_names` WHERE `ScriptName`= 'spell_warr_enraged_regeneration';
INSERT INTO `spell_script_names` (`spell_id`, `ScriptName`) VALUES
(55694, 'spell_warr_enraged_regeneration');
DELETE FROM `spell_script_names` WHERE `ScriptName`= 'spell_item_herbouflage';
INSERT INTO `spell_script_names` (`spell_id`, `ScriptName`) VALUES
(88715, 'spell_item_herbouflage');

 -- Herbouflage Effect (DND)
SET @ENTRY := 51335;
DELETE FROM `smart_scripts` WHERE `entryOrGuid`= @ENTRY AND `source_type`= 0;
UPDATE `creature_template` SET `AIName`= "SmartAI", `ScriptName`= "", `flags_extra`= 128 WHERE `entry`= @ENTRY;
INSERT INTO `smart_scripts` (`entryorguid`, `source_type`, `id`, `link`, `event_type`, `event_phase_mask`, `event_chance`, `event_flags`, `event_param1`, `event_param2`, `event_param3`, `event_param4`, `action_type`, `action_param1`, `action_param2`, `action_param3`, `action_param4`, `action_param5`, `action_param6`, `target_type`, `target_param1`, `target_param2`, `target_param3`, `target_x`, `target_y`, `target_z`, `target_o`, `comment`) VALUES
(@ENTRY, 0, 0, 0, 63, 0, 100, 0, 0, 0, 0, 0, 11, 95003, 0, 0, 0, 0, 0, 1, 0, 0, 0, 0, 0, 0, 0, "When just created - Self: Cast spell Herbouflage (DND) (95003) on Self");
DELETE FROM `spell_script_names` WHERE `ScriptName` IN 
('spell_dru_pounce',
'spell_dru_ravage',
'spell_gen_shadowmeld');

INSERT INTO `spell_script_names` (`spell_id`, `ScriptName`) VALUES
(9005, 'spell_dru_pounce'),
(6785, 'spell_dru_ravage'),
(58984, 'spell_gen_shadowmeld');
DELETE FROM `creature_template_addon` WHERE `entry` IN (52654, 52806);
INSERT INTO `creature_template_addon` (`entry`, `bytes2`, `auras`) VALUES
(52654, 1, '70878'),
(52806, 1, '70878');

DELETE FROM `creature_addon` WHERE `guid` IN (313596, 313597, 313595, 313594, 313586, 313579, 313581, 313582, 313584, 313585, 313588);
INSERT INTO `creature_addon` (`guid`, `bytes1`, `bytes2`, `emote`, `auras`) VALUES
(313596, 0, 1, 333, ''),
(313597, 0, 1, 333, ''),
(313595, 0, 1, 333, ''),
(313594, 0, 1, 333, ''),
(313588, 1, 1, 0, '70878'),
(313585, 1, 1, 0, '70878'),
(313579, 1, 1, 0, '70878');

DELETE FROM `spelleffect_dbc` WHERE `Id`= 160115;
INSERT INTO `spelleffect_dbc` (`Id`, `Effect`, `EffectAura`, `EffectBasePoints`, `EffectMiscValue`, `EffectImplicitTargetA`, `EffectImplicitTargetB`, `SpellID`, `EffectIndex`, `Comment`) VALUES
(160115, 6, 26, 0, 0, 1, 0, 70878, 0, '(Serverside/Non-DB2) Root Self');

UPDATE `spell_dbc` SET `DurationIndex`= 21 WHERE `Id`= 70878;

 -- Bwemba
SET @ENTRY := 52654;
DELETE FROM `smart_scripts` WHERE `entryOrGuid` = @ENTRY AND `source_type` = 0;
UPDATE `creature_template` SET `AIName` = "SmartAI", `ScriptName` = "" WHERE `entry` = @ENTRY;
INSERT INTO `smart_scripts` (`entryorguid`, `source_type`, `id`, `link`, `event_type`, `event_phase_mask`, `event_chance`, `event_flags`, `event_param1`, `event_param2`, `event_param3`, `event_param4`, `action_type`, `action_param1`, `action_param2`, `action_param3`, `action_param4`, `action_param5`, `action_param6`, `target_type`, `target_param1`, `target_param2`, `target_param3`, `target_x`, `target_y`, `target_z`, `target_o`, `comment`) VALUES
(@ENTRY, 0, 0, 0, 60, 0, 100, 0, 1000, 4000, 4000, 4000, 10, 1, 274, 273, 0, 0, 0, 1, 0, 0, 0, 0, 0, 0, 0, "Every 4 seconds - Self: Play random emote: ONESHOT_TALK(DNR) (1), ONESHOT_NO(DNR) (274), ONESHOT_YES(DNR) (273),");

 -- Commander Sharp
SET @ENTRY := 53352;
DELETE FROM `smart_scripts` WHERE `entryOrGuid` = @ENTRY AND `source_type` = 0;
UPDATE `creature_template` SET `AIName` = "SmartAI", `ScriptName` = "" WHERE `entry` = @ENTRY;
INSERT INTO `smart_scripts` (`entryorguid`, `source_type`, `id`, `link`, `event_type`, `event_phase_mask`, `event_chance`, `event_flags`, `event_param1`, `event_param2`, `event_param3`, `event_param4`, `action_type`, `action_param1`, `action_param2`, `action_param3`, `action_param4`, `action_param5`, `action_param6`, `target_type`, `target_param1`, `target_param2`, `target_param3`, `target_x`, `target_y`, `target_z`, `target_o`, `comment`) VALUES
(@ENTRY, 0, 0, 0, 60, 0, 100, 0, 1000, 4000, 4000, 4000, 10, 1, 274, 5, 6, 0, 0, 1, 0, 0, 0, 0, 0, 0, 0, "Every 4 - 4 seconds (1 - 4s initially) - Self: Play random emote: ONESHOT_TALK(DNR) (1), ONESHOT_NO(DNR) (274), ONESHOT_EXCLAMATION(DNR) (5), ONESHOT_QUESTION (6),");
DELETE FROM `creature_text` WHERE `CreatureID` IN (55624);
INSERT INTO `creature_text` (`CreatureID`, `GroupID`, `ID`, `Text`, `Type`, `Language`, `Probability`, `Emote`, `Duration`, `Sound`, `BroadcastTextId`, `comment`) VALUES
(55624, 0, 0, 'I see you\'ve arrived. This is the eve of the sundering, when the collapse of the Well of Eternity fractured the continents of the world.', 12, 0, 100, 0, 0, 25961, 55271, 'Nozdormu to Player'),
(55624, 1, 0, 'Here, we will snatch up the Dragon Soul before it is lost to the mists of time.', 12, 0, 100, 0, 0, 25962, 55304, 'Nozdormu to Player'),
(55624, 2, 0, 'But first, you must bring down the protective wards of Azshara\'s Highborne lackeys. You will find them within the palace. I will scout on ahead.', 12, 0, 100, 0, 0, 25963, 55305, 'Nozdormu to Player'),
(55624, 3, 0, 'Good luck, heroes!', 12, 0, 100, 0, 0, 25964, 55306, 'Nozdormu to Player');

 -- Clientside area trigger 7387
SET @ENTRY := 7387;
DELETE FROM `areatrigger_scripts` WHERE `entry` = @ENTRY;
INSERT INTO `areatrigger_scripts` (`entry`, `ScriptName`) VALUES
(@ENTRY, "SmartTrigger");

DELETE FROM `smart_scripts` WHERE `entryOrGuid` = @ENTRY AND `source_type` = 2;
INSERT INTO `smart_scripts` (`entryorguid`, `source_type`, `id`, `link`, `event_type`, `event_phase_mask`, `event_chance`, `event_flags`, `event_param1`, `event_param2`, `event_param3`, `event_param4`, `action_type`, `action_param1`, `action_param2`, `action_param3`, `action_param4`, `action_param5`, `action_param6`, `target_type`, `target_param1`, `target_param2`, `target_param3`, `target_x`, `target_y`, `target_z`, `target_o`, `comment`) VALUES
(@ENTRY, 2, 0, 0, 46, 0, 100, 0, 0, 0, 0, 0, 45, 0, 1, 0, 0, 0, 0, 10, 358721, 0, 0, 0, 0, 0, 0, "On trigger - Creature with guid 358721: Set creature data #0 to 1");

 -- Nozdormu
SET @ENTRY := 55624;
DELETE FROM `smart_scripts` WHERE `entryOrGuid` = @ENTRY AND `source_type` = 0;
UPDATE `creature_template` SET `AIName` = "SmartAI", `ScriptName` = "" WHERE `entry` = @ENTRY;
INSERT INTO `smart_scripts` (`entryorguid`, `source_type`, `id`, `link`, `event_type`, `event_phase_mask`, `event_chance`, `event_flags`, `event_param1`, `event_param2`, `event_param3`, `event_param4`, `action_type`, `action_param1`, `action_param2`, `action_param3`, `action_param4`, `action_param5`, `action_param6`, `target_type`, `target_param1`, `target_param2`, `target_param3`, `target_x`, `target_y`, `target_z`, `target_o`, `comment`) VALUES
(@ENTRY, 0, 0, 0, 38, 0, 100, 1, 0, 1, 0, 0, 80, 5562400, 0, 0, 0, 0, 0, 1, 0, 0, 0, 0, 0, 0, 0, "On data[0] set to 1 - Self: Start timed action list id #5562400 (update out of combat)");

 -- Timed list 5562400
SET @ENTRY := 5562400;
DELETE FROM `smart_scripts` WHERE `entryOrGuid` = @ENTRY AND `source_type` = 9;
INSERT INTO `smart_scripts` (`entryorguid`, `source_type`, `id`, `link`, `event_type`, `event_phase_mask`, `event_chance`, `event_flags`, `event_param1`, `event_param2`, `event_param3`, `event_param4`, `action_type`, `action_param1`, `action_param2`, `action_param3`, `action_param4`, `action_param5`, `action_param6`, `target_type`, `target_param1`, `target_param2`, `target_param3`, `target_x`, `target_y`, `target_z`, `target_o`, `comment`) VALUES
(@ENTRY, 9, 0, 0, 0, 0, 100, 0, 0, 0, 0, 0, 1, 0, 0, 0, 0, 0, 0, 1, 0, 0, 0, 0, 0, 0, 0, "After 0 seconds - Self: Talk 0 to invoker"),
(@ENTRY, 9, 1, 0, 0, 0, 100, 0, 12500, 12500, 0, 0, 1, 1, 0, 0, 0, 0, 0, 1, 0, 0, 0, 0, 0, 0, 0, "After 12.5 seconds - Self: Talk 1 to invoker"),
(@ENTRY, 9, 2, 0, 0, 0, 100, 0, 6200, 6200, 0, 0, 1, 2, 0, 0, 0, 0, 0, 1, 0, 0, 0, 0, 0, 0, 0, "After 6.2 seconds - Self: Talk 2 to invoker"),
(@ENTRY, 9, 3, 0, 0, 0, 100, 0, 12000, 12000, 0, 0, 1, 3, 0, 0, 0, 0, 0, 1, 0, 0, 0, 0, 0, 0, 0, "After 12 seconds - Self: Talk 3 to invoker");
UPDATE `gameobject_template` SET `ScriptName`= 'go_end_time_time_transit_device' WHERE `entry` IN (209441, 209442);
UPDATE `gameobject_template` SET `ScriptName`= 'go_end_time_fragment_of_jainas_staff' WHERE `entry`= 209318;

UPDATE `gossip_menu_option` SET `OptionType`= 1 WHERE `MenuId`= 13321;

UPDATE `creature_template` SET `unit_flags`= 33587968, `unit_flags2`= 2099200, `AIName`= 'NullCreatureAI' WHERE `entry`= 54641;
UPDATE `creature_template` SET `unit_flags`= 33554432, `flags_extra`= `flags_extra` | 128, `AIName`= 'NullCreatureAI' WHERE `entry`= 54639;
UPDATE `creature_template` SET `unit_flags`= 33554432, `flags_extra`= `flags_extra` | 128, `ScriptName`= 'npc_echo_of_jaina_blink_target' WHERE `entry`= 54542;
UPDATE `creature_template` SET `unit_flags`= 33554432, `unit_flags2`= 34816, `flags_extra`= `flags_extra` | 128, `AIName`= 'NullCreatureAI' WHERE `entry`= 54446;

DELETE FROM `spawn_group_template` WHERE `groupId`= 460;
INSERT INTO `spawn_group_template` (`groupId`, `groupName`, `groupFlags`) VALUES
(460, 'End Time - Echo of Jaina - Jaina', 4);

DELETE FROM `spawn_group` WHERE `groupId`= 460;
INSERT INTO `spawn_group` (`groupId`, `spawnType`, `spawnId`) VALUES
(460, 0, 341769);

UPDATE `creature_template` SET `unit_flags`= 33088, `unit_flags2`= 2099200, `ScriptName`= 'boss_echo_of_jaina' WHERE `entry`= 54445;
UPDATE `creature_template` SET `flags_extra`= `flags_extra` | 128, `AIName`= 'NullCreatureAI' WHERE `entry`= 54494;

DELETE FROM `creature_text` WHERE `CreatureID`= 54445;
INSERT INTO `creature_text` (`CreatureID`, `GroupID`, `ID`, `Text`, `Type`, `Language`, `Probability`, `Emote`, `Duration`, `Sound`, `BroadcastTextId`, `comment`) VALUES
(54445, 0, 0, 'I don\'t know who you are, but I\'ll defend this shrine with my life. Leave, now, before we come to blows.', 12, 0, 100, 0, 0, 25920, 56573, 'Echo of Jaina - Intro'),
(54445, 1, 0, 'You asked for it.', 14, 0, 100, 0, 0, 25917, 53040, 'Echo of Jaina - Aggro'),
(54445, 2, 0, 'Why won\'t you give up?!', 14, 0, 100, 0, 0, 25926, 56580, 'Echo of Jaina - Blink 1'),
(54445, 2, 1, 'Perhaps this will cool your heads...', 14, 0, 100, 0, 0, 25924, 56578, 'Echo of Jaina - Blink 2'),
(54445, 2, 2, 'A little ice ought to quench the fire in your hearts...', 14, 0, 100, 0, 0, 25925, 56579, 'Echo of Jaina - Blink 3'),
(54445, 3, 0, 'I understand, now. Farewell, and good luck.', 12, 0, 100, 0, 0, 25919, 56574, 'Echo of Jaina - Death'),
(54445, 4, 0, 'You forced my hand.', 14, 0, 100, 0, 0, 25921, 56575, 'Echo of Jaina - Slay 1'),
(54445, 4, 1, 'I didn\'t want to do that.', 14, 0, 100, 0, 0, 25922, 56576, 'Echo of Jaina - Slay 2'),
(54445, 4, 2, 'I wish you\'d surrendered.', 14, 0, 100, 0, 0, 25923, 56577, 'Echo of Jaina - Slay 3');

DELETE FROM `spell_script_names` WHERE `ScriptName` IN 
('spell_echo_of_jaina_face_highest_threat_target',
'spell_echo_of_jaina_frost_blade',
'spell_echo_of_jaina_disable_stalker_search',
'spell_echo_of_jaina_blink',
'spell_echo_of_jaina_flarecore',
'spell_echo_of_jaina_flarecore_triggered',
'spell_echo_of_jaina_flarecore_periodic');

INSERT INTO `spell_script_names` (`spell_id`, `ScriptName`) VALUES
(107897, 'spell_echo_of_jaina_face_highest_threat_target'),
(101337, 'spell_echo_of_jaina_frost_blade'),
(101540, 'spell_echo_of_jaina_disable_stalker_search'),
(101812, 'spell_echo_of_jaina_blink'),
(101944, 'spell_echo_of_jaina_flarecore'),
(101616, 'spell_echo_of_jaina_flarecore_triggered'),
(101588, 'spell_echo_of_jaina_flarecore_periodic');

DELETE FROM `creature_template_movement` WHERE `CreatureId` IN (54494, 54446);
INSERT INTO `creature_template_movement` (`CreatureId`, `Ground`, `Swim`, `Flight`, `Rooted`) VALUES
(54494, 0, 0, 2, 0),
(54446, 0, 0, 2, 1);

DELETE FROM `conditions` WHERE `SourceEntry` IN (101812, 101540) AND `SourceTypeOrReferenceId`= 13;
INSERT INTO `conditions` (`SourceTypeOrReferenceId`, `SourceGroup`, `SourceEntry`, `SourceId`, `ElseGroup`, `ConditionTypeOrReference`, `ConditionTarget`, `ConditionValue1`, `ConditionValue2`, `ConditionValue3`, `NegativeCondition`, `ErrorType`, `ScriptName`, `Comment`) VALUES
(13, 1, 101812, 0, 0, 31, 0, 3, 54542, 0, 0, 0, '', 'Blink - Target Blink Target'),
(13, 2, 101540, 0, 0, 31, 0, 3, 54445, 0, 0, 0, '', 'Disable Stalker Search - Target Echo of Jaina');

DELETE FROM `creature_onkill_reward` WHERE `creature_id`= 54445;
INSERT INTO `creature_onkill_reward` (`creature_id`, `RewOnKillRepFaction1`, `MaxStanding1`, `IsTeamAward1`, `RewOnKillRepValue1`, `TeamDependent`, `CurrencyId1`, `CurrencyCount1`) VALUES
(54445, 1162, 7, 0, 250, 0, 395, 7000);

UPDATE `creature_template`SET `mingold`= 17000, `maxgold`= 23000 WHERE `entry`= 54445;
DELETE FROM `creature_loot_template` WHERE `Entry`= 54445;
INSERT INTO `creature_loot_template` (`Entry`, `Reference`, `Item`, `Chance`, `GroupId`, `MinCount`, `MaxCount`, `LootMode`) VALUES
(54445, 0, 72808, 20, 1, 1, 1, 1),
(54445, 0, 72809, 15, 1, 1, 1, 1),
(54445, 0, 72805, 5, 1, 1, 1, 1),
(54445, 0, 72801, 5, 1, 1, 1, 1),
(54445, 0, 72804, 5, 1, 1, 1, 1),
(54445, 0, 72802, 5, 1, 1, 1, 1),
(54445, 0, 72799, 5, 1, 1, 1, 1),
(54445, 0, 72803, 5, 1, 1, 1, 1),
(54445, 0, 72806, 5, 1, 1, 1, 1),
(54445, 0, 72798, 5, 1, 1, 1, 1),
(54445, 0, 72800, 5, 1, 1, 1, 1),
(54445, 0, 72807, 5, 1, 1, 1, 1);
DELETE FROM `spell_script_names` WHERE `ScriptName`='spell_gen_50pct_count_pct_from_max_hp' AND `spell_id`=48292;
DELETE FROM `spell_script_names` WHERE `ScriptName`='spell_dark_slash';
INSERT INTO `spell_script_names` (`spell_id`, `ScriptName`) VALUES
(48292, 'spell_dark_slash');
DELETE FROM `spell_script_names` WHERE `ScriptName`='spell_rog_vanish';
INSERT INTO `spell_script_names` (`spell_id`, `ScriptName`) VALUES
(-11327, 'spell_rog_vanish');
DELETE FROM `spell_script_names` WHERE `ScriptName`= 'spell_item_blaze_of_life';
INSERT INTO `spell_script_names` (`spell_id`, `ScriptName`) VALUES
(96966, 'spell_item_blaze_of_life'),
(97136, 'spell_item_blaze_of_life');
DELETE FROM `spell_script_names` WHERE `ScriptName` IN 
('spell_dru_t12_restoration_4p_bonus',
'spell_dru_firebloom');

INSERT INTO `spell_script_names` (`spell_id`, `ScriptName`) VALUES
(99015, 'spell_dru_t12_restoration_4p_bonus'),
(99017, 'spell_dru_firebloom');

DELETE FROM `spell_proc` WHERE `SpellId`= 99015;
INSERT INTO `spell_proc` (`SpellId`, `SpellFamilyName`, `SpellFamilyMask1`, `SpellTypeMask`, `SpellPhaseMask`) VALUES
(99015, 7, 0x2, 2, 2);
DELETE FROM `spell_proc` WHERE `SpellId` IN (-88820, 88819);
INSERT INTO `spell_proc` (`SpellId`, `SpellFamilyName`, `SpellFamilyMask0`, `SpellFamilyMask1`, `SpellFamilyMask2`, `SpellTypeMask`, `SpellPhaseMask`, `Charges`) VALUES
(-88820, 10, 0x80000000 | 0x40000000, 0x0, 0x400, 0x2, 1, 0),
(88819, 10, 0x200000, 0x10000, 0x0, 0x1 |0x2, 1, 1);
UPDATE `spell_proc` SET `SpellPhaseMask`= 1 WHERE `SpellId`= -81659;
DELETE FROM `spell_group_stack_rules` WHERE `group_id`= 1152;
INSERT INTO `spell_group_stack_rules` (`group_id`, `stack_rule`) VALUES
(1152, 3);

DELETE FROM `spell_group` WHERE `id`= 1152;
INSERT INTO `spell_group` (`id`, `spell_id`) VALUES
(1152, 24907),
(1152, 49868),
(1152, 2895);
DELETE FROM `world_map_template` WHERE `ScriptName`= 'world_map_deeprun_tram';

DELETE FROM `gameobject` WHERE `guid` IN (18802, 18803, 18804, 18805, 18806, 18807);
DELETE FROM `gameobject_addon` WHERE `guid` IN (18802, 18803, 18804, 18805, 18806, 18807);
INSERT INTO `gameobject` (`guid`, `id`, `map`, `zoneId`, `areaId`, `spawnMask`, `phaseId`, `position_x`, `position_y`, `position_z`, `orientation`, `rotation0`, `rotation1`, `rotation2`, `rotation3`, `spawntimesecs`, `animprogress`, `state`, `ScriptName`, `VerifiedBuild`) VALUES
(18802, 176080, 369, 0, 0, 1, 169, 4.58065,  28.2097,  7.01107, 1.5708, 0, 0, 0.7071066,  0.70710695, 120, 0, 24, '', 15211),
(18803, 176081, 369, 0, 0, 1, 169, 4.52807,  8.43529,  7.01107, 1.5708, 0, 0, 0.7071066,  0.70710695, 120, 0, 24, '', 15211),
(18804, 176082, 369, 0, 0, 1, 169, -45.4005, 2492.79,  6.9886,  1.5708, 0, 0, 0.7071066,  0.70710695, 120, 0, 24, '', 15211),
(18805, 176083, 369, 0, 0, 1, 169, -45.4007, 2512.15,  6.9886,  1.5708, 0, 0, 0.7071066,  0.70710695, 120, 0, 24, '', 15211),
(18806, 176084, 369, 0, 0, 1, 169, -45.3934, 2472.93,  6.9886,  1.5708, 0, 0, 0.7071066,  0.70710695, 120, 0, 24, '', 15211),
(18807, 176085, 369, 0, 0, 1, 169, 4.49883,  -11.3475, 7.01107, 1.5708, 0, 0, 0.7071066,  0.70710695, 120, 0, 24, '', 15211);

INSERT INTO `gameobject_addon` (`guid`, `parent_rotation2`, `parent_rotation3`) VALUES
(18802, 1, -0.0000000437114),
(18803, 1, -0.0000000437114),
(18804, 1, -0.0000000437114),
(18805, 1, -0.0000000437114),
(18806, 1, -0.0000000437114),
(18807, 1, -0.0000000437114);
DELETE FROM `spell_script_names` WHERE `ScriptName` IN ('spell_pal_improved_concentraction_aura_effect', 'spell_pal_improved_devotion_aura_effect', 'spell_pal_sanctified_retribution_effect');
DELETE FROM `game_weather` WHERE `zone`= 5034;
INSERT INTO `game_weather` (`zone`, `spring_storm_chance`, `summer_storm_chance`, `fall_storm_chance`, `winter_storm_chance`, `ScriptName`) VALUES
(5034, 15, 15, 15, 15, ''); 
-- Denounce Talent
DELETE FROM `spell_proc` WHERE `SpellId`= -31825;
INSERT INTO `spell_proc` (`SpellId`, `SpellFamilyName`, `SpellFamilyMask1`, `SpellTypeMask`, `SpellPhaseMask`, `HitMask`) VALUES
(-31825, 10, 0x2, 0x1, 0x2, 0x0);

-- Speed of Light Talent
DELETE FROM `spell_proc` WHERE `SpellId`= -85495;
INSERT INTO `spell_proc` (`SpellId`, `SpellFamilyName`, `SpellFamilyMask0`, `SpellTypeMask`, `SpellPhaseMask`, `HitMask`) VALUES
(-85495, 10, 0x400000, 0x4, 0x1, 0x0);

DELETE FROM `spell_script_names` WHERE `ScriptName`= 'spell_pal_speed_of_light';
INSERT INTO `spell_script_names` (`spell_id`, `ScriptName`) VALUES
(-85495, 'spell_pal_speed_of_light');
-- Judgements of the Just Talent
DELETE FROM `spell_proc` WHERE `SpellId`= -53695;
INSERT INTO `spell_proc` (`SpellId`, `SpellFamilyName`, `SpellFamilyMask0`, `SpellTypeMask`, `SpellPhaseMask`, `HitMask`) VALUES
(-53695, 10, 0x800000 , 0x1, 0x2, 0x0);

DELETE FROM `spell_script_names` WHERE `ScriptName`= 'spell_pal_judgements_of_the_just';
INSERT INTO `spell_script_names` (`spell_id`, `ScriptName`) VALUES
(-53695, 'spell_pal_judgements_of_the_just');
