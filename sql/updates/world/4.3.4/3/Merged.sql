--
UPDATE `creature_template` SET `ScriptName`= 'boss_general_bjarngrim' WHERE `entry`= 28586;
UPDATE `creature_template` SET `ScriptName`= 'npc_bjarngrim_stormforged_lieutenant' WHERE `entry`= 29240;

DELETE FROM `spell_script_names` WHERE `ScriptName` IN
('spell_bjarngrim_defensive_stance_dummy',
'spell_bjarngrim_battle_stance_dummy',
'spell_bjarngrim_berserker_stance_dummy',
'spell_bjarngrim_charge_up',
'spell_bjarngrim_arc_weld');

INSERT INTO `spell_script_names` (`spell_id`,`ScriptName`) VALUES
(53790, 'spell_bjarngrim_defensive_stance_dummy'),
(53791, 'spell_bjarngrim_berserker_stance_dummy'),
(53792, 'spell_bjarngrim_battle_stance_dummy'),
(52098, 'spell_bjarngrim_charge_up'),
(59085, 'spell_bjarngrim_arc_weld');

DELETE FROM `creature_text` WHERE `CreatureID`= 28586;
INSERT INTO `creature_text` (`CreatureID`, `GroupID`, `ID`, `Text`, `Type`, `Language`, `Probability`, `Emote`, `Duration`, `Sound`, `BroadcastTextId`, `TextRange`, `comment`) VALUES
(28586, 0, 0, 'I am the greatest of my father\'s sons! Your end has come!', 14, 0, 100, 0, 0, 14149, 31407, 0, 'General Bjarngrim - Aggro'),
(28586, 1, 0, '%s switches to Defensive Stance!', 41, 0, 100, 0, 0, 0, 29834, 0, 'General Bjarngrim - Announce Defensive Stance'),
(28586, 2, 0, 'Give me your worst!', 14, 0, 100, 0, 0, 14150, 31408, 0, 'General Bjarngrim - Defensive Stance'),
(28586, 3, 0, '%s switches to Berserker Stance!', 41, 0, 100, 0, 0, 0, 29833, 0, 'General Bjarngrim - Announce Berserker Stance'),
(28586, 4, 0, 'GRAAAAAH! Behold the fury of iron and steel!', 14, 0, 100, 0, 0, 14152, 31410, 0, 'General Bjarngrim - Berserker Stance'),
(28586, 5, 0, '%s switches to Battle Stance!', 41, 0, 100, 0, 0, 0, 29832, 0, 'General Bjarngrim - Announce Battle Stance'),
(28586, 6, 0, 'Defend yourself, for all the good it will do!', 14, 0, 100, 0, 0, 14151, 31409, 0, 'General Bjarngrim - Battle Stance'),
(28586, 7, 0, 'So ends your curse.', 14, 0, 100, 0, 0, 14153, 31411, 0, 'General Bjarngrim - Slay 1'),
(28586, 7, 1, 'Flesh... is... weak!', 14, 0, 100, 0, 0, 14154, 31412, 0, 'General Bjarngrim - Slay 2'),
(28586, 7, 2, 'Bolvin umyol marnjar.', 14, 0, 100, 0, 0, 14155, 31413, 0, 'General Bjarngrim - Slay 3'),
(28586, 8, 0, 'How can it be...? Flesh is not... stronger!', 14, 0, 100, 0, 0, 14156, 31414, 0, 'General Bjarngrim - Death');

DELETE FROM `conditions` WHERE `SourceEntry` IN (56458) AND `SourceTypeOrReferenceId`= 13;
INSERT INTO `conditions` (`SourceTypeOrReferenceId`, `SourceGroup`, `SourceEntry`, `SourceId`, `ElseGroup`, `ConditionTypeOrReference`, `ConditionTarget`, `ConditionValue1`, `ConditionValue2`, `ConditionValue3`, `NegativeCondition`, `ErrorType`, `ScriptName`, `Comment`) VALUES
(13, 1, 56458, 0, 0, 31, 0, 3, 28586, 0, 0, 0, '', 'Charge Up - Target General Bjarngrim');

SET @CGUID := 126981;
SET @PATH := @CGUID * 10;
DELETE FROM `waypoint_data` WHERE `id`= @PATH;
INSERT INTO `waypoint_data` (`id`, `point`, `position_x`, `position_y`, `position_z`, `orientation`, `delay`) VALUES
(@PATH, 0, 1262.023, 9.344401, 33.21593, NULL, 0),
(@PATH, 1, 1262.031, 53.14377, 33.17394, NULL, 0),
(@PATH, 2, 1261.928, 98.94911, 33.50209, NULL, 6000),
(@PATH, 3, 1261.893, 60.51574, 33.17393, NULL, 0),
(@PATH, 4, 1261.886, 21.39475, 33.17399, NULL, 0),
(@PATH, 5, 1262.132, -26.1173, 33.50208, NULL, 6000),
(@PATH, 6, 1298.901, -26.74544, 37.24462, NULL, 0),
(@PATH, 7, 1331.648, -27.02919, 40.17395, NULL, 10000),
(@PATH, 8, 1354.665, -4.239692, 41.1354, NULL, 0),
(@PATH, 9, 1371.601, 12.65864, 48.57853, NULL, 0),
(@PATH, 10, 1394.671, 35.86361, 50.03335, NULL, 6000),
(@PATH, 11, 1370.748, 12.2143, 48.29315, NULL, 0),
(@PATH, 12, 1355.246, -3.361762, 41.45641, NULL, 0),
(@PATH, 13, 1332.481, -26.59397, 40.17395, NULL, 0),
(@PATH, 14, 1295.831, -26.50022, 36.55395, NULL, 0),
(@PATH, 15, 1262.658, -26.88303, 33.50208, NULL, 10000);

DELETE FROM `waypoint_scripts` WHERE `id`  IN (12698102, 12698101);

UPDATE `creature` SET `position_x`= 1262.2057, `position_y`= -1.0628986, `position_z`= 33.50208, `orientation`= 5.140983, `spawndist`= 0, `MovementType`= 2 WHERE `guid`= @CGUID;
DELETE FROM `creature_addon` WHERE `guid`= @CGUID;
INSERT INTO `creature_addon` (`guid`, `waypointPathId`, `bytes2`) VALUES
(@CGUID, @PATH, 1);

UPDATE `creature` SET `position_x`= 1265.8042, `position_y`= -4.6208167, `position_z`= 33.502056, `orientation`= 5.258189 WHERE `guid`= 126863;
UPDATE `creature` SET `position_x`= 1258.7352, `position_y`= -4.746479, `position_z`= 33.50209, `orientation`= 5.122859 WHERE `guid`= 126864;

DELETE FROM `spell_linked_spell` WHERE `spell_trigger`= -52098;

DELETE FROM `spawn_group_template` WHERE `groupId`= 325;
INSERT INTO `spawn_group_template` (`groupId`, `groupName`, `groupFlags`) VALUES
(325, 'Halls of Lightning - General Bjarngrim - Stormforged Lieutenants', 4);

DELETE FROM `spawn_group` WHERE `spawnId` IN (126863, 126864);
DELETE FROM `spawn_group` WHERE `groupId`= 325;
INSERT INTO `spawn_group` (`groupId`, `spawnType`, `spawnId`) VALUES
(325, 0, 126863),
(325, 0, 126864);
DELETE FROM `spell_script_names` WHERE `ScriptName` IN
('spell_warl_fear',
'spell_warl_glyph_of_fear',
'spell_pri_psychic_scream');

INSERT INTO `spell_script_names` (`spell_id`, `ScriptName`) VALUES
(5782, 'spell_warl_fear'),
(56244, 'spell_warl_glyph_of_fear'),
(8122, 'spell_pri_psychic_scream');
UPDATE `gossip_menu_option` SET `OptionType`= 3, `OptionNpcflag`= 0x80 WHERE `menuId`= 4107 AND `OptionIndex`= 0;
DELETE FROM `spell_script_names` WHERE `ScriptName`= 'spell_brc_aggro_nearby_targets';
INSERT INTO `spell_script_names` (`spell_id`, `ScriptName`) VALUES
(80196, 'spell_brc_aggro_nearby_targets');
-- Wasteland Outrider
UPDATE `creature_template_addon` SET `mount`= 37212 WHERE `entry`= 45905;
UPDATE `creature_loot_template` SET `QuestRequired`= 1 WHERE `Entry`= 45905 AND `Item`= 63081;

-- Warlord Ihsenn
UPDATE `creature_template_addon` SET `mount`= 37212 WHERE `entry`= 47755;
SET @ENTRY := 47755;
DELETE FROM `smart_scripts` WHERE `source_type` = 0 AND `entryOrGuid` = @ENTRY;
UPDATE `creature_template` SET `AIName` = 'SmartAI', `ScriptName` = '' WHERE `entry` = @ENTRY;
INSERT INTO `smart_scripts` (`entryorguid`, `source_type`, `id`, `link`, `event_type`, `event_phase_mask`, `event_chance`, `event_flags`, `event_param1`, `event_param2`, `event_param3`, `event_param4`, `action_type`, `action_param1`, `action_param2`, `action_param3`, `action_param4`, `action_param5`, `action_param6`, `target_type`, `target_param1`, `target_param2`, `target_param3`, `target_x`, `target_y`, `target_z`, `target_o`, `comment`) VALUES
(@ENTRY, 0, 0, 0, 63, 0, 100, 0, 0, 0, 0, 0, 11, 42459, 0, 0, 0, 0, 0, 1, 0, 0, 0, 0, 0, 0, 0, 'On just created - Self: Cast spell Dual Wield (42459) on Self'),
(@ENTRY, 0, 1, 0, 4, 0, 100, 0, 0, 0, 0, 0, 11, 6434, 0, 0, 0, 0, 0, 1, 0, 0, 0, 0, 0, 0, 0, 'On aggro - Self: Cast spell Slice and Dice (6434) on Self');


 -- Venomblood Scorpid
SET @ENTRY := 45859;
DELETE FROM `smart_scripts` WHERE `source_type` = 0 AND `entryOrGuid` = @ENTRY;
UPDATE `creature_template` SET `AIName` = '', `ScriptName` = '' WHERE `entry` = @ENTRY;

DELETE FROM `spell_script_names` WHERE `ScriptName`= 'spell_uldum_draining_venom';
INSERT INTO `spell_script_names` (`spell_id`, `ScriptName`) VALUES
(88882, 'spell_uldum_draining_venom');
DELETE FROM `item_loot_template` WHERE `Entry`= 67495;
INSERT INTO `item_loot_template` (`Entry`, `Item`, `Chance`, `LootMode`, `GroupId`, `MinCount`, `MaxCount`) VALUES
(67495, 52328, 0, 1, 1, 1, 2),
(67495, 52327, 0, 1, 1, 1, 2),
(67495, 52329, 0, 1, 1, 1, 2),
(67495, 52326, 0, 1, 1, 1, 2),
(67495, 52325, 0, 1, 1, 1, 2);
DELETE FROM `creature` WHERE `guid` IN (264981, 264983, 265265, 265267, 265269, 265272, 265286, 265291, 265293, 265295, 265297, 265300, 265404, 265411, 265420, 265422, 265424, 265435, 265437, 265444, 265446, 265451, 265453, 265571, 265574, 265579, 265593, 265597);
DELETE FROM `creature_addon` WHERE `guid` IN (264981, 264983, 265265, 265267, 265269, 265272, 265286, 265291, 265293, 265295, 265297, 265300, 265404, 265411, 265420, 265422, 265424, 265435, 265437, 265444, 265446, 265451, 265453, 265571, 265574, 265579, 265593, 265597);
DELETE FROM `spawn_group` WHERE `spawnType`= 0 AND `spawnId` IN (264981, 264983, 265265, 265267, 265269, 265272, 265286, 265291, 265293, 265295, 265297, 265300, 265404, 265411, 265420, 265422, 265424, 265435, 265437, 265444, 265446, 265451, 265453, 265571, 265574, 265579, 265593, 265597);

DELETE FROM `vehicle_template_accessory` WHERE `entry`= 45716;
INSERT INTO `vehicle_template_accessory` (`entry`, `accessory_entry`, `seat_id`, `minion`, `description`, `summontype`, `summontimer`) VALUES
(45716, 45715, 0, 0, 'Orsis Suviror Vehicle - Orsis Survivor', 8, 0);

DELETE FROM `npc_spellclick_spells` WHERE `npc_entry` IN (45716, 45715);
INSERT INTO `npc_spellclick_spells` (`npc_entry`, `spell_id`, `cast_flags`, `user_type`) VALUES
(45716, 46598, 1, 0),
(45715, 85372, 1, 1);

UPDATE `creature_template` SET `npcflag`= 0x1000000 WHERE `entry`= 45715;
UPDATE `creature_template` SET `flags_extra`= 0x80 WHERE `entry`= 45716;

DELETE FROM `creature_template_movement` WHERE `CreatureId` IN (45715, 45716);
INSERT INTO `creature_template_movement` (`CreatureId`, `Ground`, `Swim`, `Flight`,`Rooted`) VALUES
(45715, 1, 0, 0, 0),
(45716, 0, 0, 1, 1);

DELETE FROM `creature_text` WHERE `CreatureID`= 45715;
INSERT INTO `creature_text` (`CreatureID`, `GroupID`, `ID`, `Text`, `Type`, `Language`, `Probability`, `Emote`, `Duration`, `Sound`, `BroadcastTextId`, `TextRange`, `comment`) VALUES
(45715, 0, 0, 'I... *cough*  I thank you, stranger.', 12, 0, 100, 0, 0, 0, 45820, 0, 'Orsis Survivor'),
(45715, 0, 1, 'I owe you my life.  My people have paid a high price for defying Deathwing.', 12, 0, 100, 0, 0, 0, 45821, 0, 'Orsis Survivor');

DELETE FROM `spell_script_names` WHERE `ScriptName`= 'spell_uldum_rescue_survivor';
INSERT INTO `spell_script_names` (`spell_id`, `ScriptName`) VALUES
(85372, 'spell_uldum_rescue_survivor');

DELETE FROM `conditions` WHERE `SourceTypeOrReferenceId`= 18 AND `SourceGroup`= 45715;
INSERT INTO `conditions` (`SourceTypeOrReferenceId`, `SourceGroup`, `SourceEntry`, `ConditionTypeOrReference`, `ConditionValue1`, `ScriptName`, `Comment`) VALUES
(18, 45715, 85372, 9, 27519, '', 'Required quest active for spellclick');
-- Kazemde Inkeeper
UPDATE `gossip_menu_option` SET `OptionNpcFlag`= 0x80, `OptionType`= 8 WHERE `MenuId`= 9868 AND `OptionIndex`= 0;
UPDATE `gossip_menu_option` SET `OptionNpcFlag`= 0x10000, `OptionType`= 3 WHERE `MenuId`= 9868 AND `OptionIndex`= 1;
UPDATE `gossip_menu_option` SET `OptionNpcFlag`= 0, `OptionType`= 0 WHERE `MenuId`= 9868 AND `OptionIndex`= 2;

-- Ramkahen resting area trigger
DELETE FROM `areatrigger_tavern` WHERE `id`= 6524;
INSERT INTO `areatrigger_tavern` (`id`, `name`) VALUES
(6524, 'Ramkahen');

-- Remove invalid loot from Mac Frog
UPDATE `creature_template` SET `lootid`= 0 WHERE `entry`= 50491;
DELETE FROM `creature_loot_template` WHERE `Entry`= 50491;
ALTER TABLE `gossip_menu_option` CHANGE `MenuId` `MenuID` int(10) unsigned NOT NULL DEFAULT 0;
ALTER TABLE `gossip_menu_option` CHANGE `OptionIndex` `OptionID` int(10) unsigned NOT NULL DEFAULT 0;
ALTER TABLE `gossip_menu_option` CHANGE `OptionBroadcastTextId` `OptionBroadcastTextID` int(10) unsigned NOT NULL DEFAULT 0;
ALTER TABLE `gossip_menu_option` ADD `ActionMenuID` int(10) unsigned NOT NULL DEFAULT 0 AFTER `OptionNpcFlag`;
ALTER TABLE `gossip_menu_option` ADD `ActionPoiID` int(10) unsigned NOT NULL DEFAULT 0 AFTER `ActionMenuID`;
ALTER TABLE `gossip_menu_option` ADD `BoxCoded` tinyint(3) unsigned NOT NULL DEFAULT 0 AFTER `ActionPoiID`;
ALTER TABLE `gossip_menu_option` ADD `BoxMoney` int(10) unsigned NOT NULL DEFAULT 0 AFTER `BoxCoded`;
ALTER TABLE `gossip_menu_option` ADD `BoxText` mediumtext AFTER `BoxMoney`;
ALTER TABLE `gossip_menu_option` ADD `BoxBroadcastTextID` int(10) unsigned NOT NULL DEFAULT 0 AFTER `BoxText`;

UPDATE `gossip_menu_option` gmo
  LEFT JOIN `gossip_menu_option_action` gmoa ON gmo.`MenuID` = gmoa.`MenuId` AND gmo.`OptionID` = gmoa.`OptionIndex`
  LEFT JOIN `gossip_menu_option_box` gmob ON gmo.`MenuId` = gmob.`MenuId` AND gmo.`OptionID` = gmob.`OptionIndex`
  SET gmo.`ActionMenuID` = COALESCE(gmoa.`ActionMenuId`, 0), gmo.`ActionPoiID` = COALESCE(gmoa.`ActionPoiId`, 0),
  gmo.`BoxCoded` = COALESCE(gmob.`BoxCoded`, 0), gmo.`BoxMoney` = COALESCE(gmob.`BoxMoney`, 0), gmo.`BoxText` = gmob.`BoxText`, gmo.`BoxBroadcastTextID` = COALESCE(gmob.`BoxBroadcastTextId`, 0);

DROP TABLE `gossip_menu_option_action`;
DROP TABLE `gossip_menu_option_box`;

ALTER TABLE `creature_trainer` CHANGE `CreatureId` `CreatureID` int(10) unsigned NOT NULL DEFAULT 0;
ALTER TABLE `creature_trainer` CHANGE `TrainerId` `TrainerID` int(10) unsigned NOT NULL DEFAULT 0;
ALTER TABLE `creature_trainer` CHANGE `MenuId` `MenuID` int(10) unsigned NOT NULL DEFAULT 0;
ALTER TABLE `creature_trainer` CHANGE `OptionIndex` `OptionID` int(10) unsigned NOT NULL DEFAULT 0;
DELETE FROM `spell_proc` WHERE `SpellId`= 85646;
INSERT INTO `spell_proc` (`SpellId`, `SpellFamilyName`, `SpellFamilyMask2`, `SpellTypeMask`, `SpellPhaseMask`) VALUES
(85646, 10, 0x4000, 2, 2);

DELETE FROM `spell_script_names` WHERE `ScriptName`= 'spell_pal_guarded_by_the_light';
INSERT INTO `spell_script_names` (`spell_id`, `ScriptName`) VALUES
(85646, 'spell_pal_guarded_by_the_light');
-- Avalanche cooldown
UPDATE `spell_proc` SET `ProcFlags`= 0, `Cooldown`= 10000 WHERE `SpellId`= 95472;
-- Hurricane Proc flags correction
UPDATE `spell_proc` SET `ProcFlags`= 0 WHERE `SpellId`= 94747;

-- Elemental Slayer
DELETE FROM `spell_enchant_proc_data` WHERE `EnchantID`= 4074;
INSERT INTO `spell_enchant_proc_data` (`EnchantID`, `Chance`, `ProcsPerMinute`, `HitMask`, `AttributesMask`) VALUES
(4074, 0, 2.5, 0, 0);
DELETE FROM `npc_vendor` WHERE `entry`= 3369;
INSERT INTO `npc_vendor` (`entry`, `slot`, `item`, `maxcount`, `ExtendedCost`, `type`, `PlayerConditionID`, `VerifiedBuild`) VALUES
(3369, 9, 30747, 0, 0, 1, 0, 15595), -- Gem Pouch
(3369, 8, 30748, 0, 0, 1, 0, 15595), -- Enchanter's Satchel
(3369, 7, 30745, 0, 0, 1, 0, 15595), -- Heavy Toolbox
(3369, 6, 30746, 0, 0, 1, 0, 15595), -- Mining Sack
(3369, 5, 60335, 0, 0, 1, 0, 15595), -- Thick Hide Pack
(3369, 4, 4499, 0, 0, 1, 0, 15595), -- Huge Brown Sack
(3369, 3, 4497, 0, 0, 1, 0, 15595), -- Heavy Brown Bag
(3369, 2, 4498, 0, 0, 1, 0, 15595), -- Brown Leather Satchel
(3369, 1, 4496, 0, 0, 1, 0, 15595); -- Small Brown Pouch
UPDATE `gossip_menu_option` SET `OptionType`= 1 WHERE `MenuID`= 12646;
DELETE FROM `conditions` WHERE `SourceTypeOrReferenceId`=15 AND `SourceGroup`=12646 AND SourceId = 0;
INSERT INTO `conditions` (`SourceTypeOrReferenceId`,`SourceGroup`,`SourceEntry`,`SourceId`,`ElseGroup`,`ConditionTypeOrReference`,`ConditionTarget`,`ConditionValue1`,`ConditionValue2`,`ConditionValue3`,`ErrorTextId`, `NegativeCondition`, `ScriptName`,`Comment`) VALUES
(15, 12646, 1, 0, 0, 13, 0, 1, 3, 2, 0, 0, "", "Show gossip if Anraphet or Earthrager Ptah have been defeated"),
(15, 12646, 1, 0, 1, 13, 0, 2, 3, 2, 0, 0, "", "Show gossip if Anraphet or Earthrager Ptah have been defeated"),
(15, 12646, 2, 0, 0, 13, 0, 3, 3, 2, 0, 0, "", "Show gossip if the Constructs of the Four Seats have been defeated"),
(15, 12646, 2, 0, 0, 13, 0, 4, 3, 2, 0, 0, "", "Show gossip if the Constructs of the Four Seats have been defeated"),
(15, 12646, 2, 0, 0, 13, 0, 5, 3, 2, 0, 0, "", "Show gossip if the Constructs of the Four Seats have been defeated"),
(15, 12646, 2, 0, 0, 13, 0, 6, 3, 2, 0, 0, "", "Show gossip if the Constructs of the Four Seats have been defeated");
UPDATE `spell_script_names` SET `spell_id`= -85639 WHERE `ScriptName`= 'spell_pal_guarded_by_the_light';
-- Use more appropriate name for distance used by random movement generator.
ALTER TABLE `creature`
	CHANGE COLUMN `spawndist` `wander_distance` FLOAT NOT NULL DEFAULT '0' AFTER `spawntimesecs`;

-- Update name used by chat command.
UPDATE `trinity_string` SET `content_default`='Wander distance changed to: %f' WHERE `entry`=297;
UPDATE `command` SET `name`='npc set wanderdistance', `help`='Syntax: .npc set wanderdistance #dist\r\n\r\nAdjust wander distance of selected creature to dist.' WHERE `name`='npc set spawndist';
ALTER TABLE `world_state` MODIFY `MapIDs` varchar(128) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NULL DEFAULT NULL AFTER `DefaultValue`;

DELETE FROM `world_state` WHERE `ID` IN (601,602,801,804,922,923,1043,1044,1181,1182,1183,1184,1185,1186,1187,1188,1301,1302,1303,1304,1325,1326,1327,1328,1329,1330,1331,1332,1333,1334,1335,1336,1337,1338,1339,1340,1341,1342,1343,1344,1346,1347,1348,1349,1351,
1352,1355,1356,1357,1358,1359,1360,1361,1362,1363,1364,1365,1366,1367,1368,1370,1371,1372,1373,1374,1375,1376,1377,1378,1379,1380,1381,1382,1383,1384,1385,1387,1388,1389,1390,1392,1393,1394,1395,1545,1546,1547,1581,1582,1601,1664,1767,1768,1769,1770,1772,1773,
1774,1775,1776,1777,1778,1779,1780,1782,1783,1784,1785,1787,1788,1789,1790,1792,1793,1794,1795,1842,1843,1844,1845,1846,1955,1966,2338,2339,2718,2719,2720,2722,2723,2724,2725,2726,2727,2728,2729,2730,2731,2732,2733,2752,2753,3127,3128,3133,3134,3136,3557,3564,
3565,3571,3600,3601,3610,3614,3617,3620,3623,3626,3627,3628,3629,3630,3631,3632,3633,3634,3635,3636,3637,3638,3644,3645,3690,3849,3955,3956,4221,4222,4226,4227,4228,4229,4230,4232,4234,4235,4247,4248,4287,4289,4293,4294,4296,4297,4298,4299,4300,4301,4302,4303,
4304,4305,4306,4307,4308,4309,4310,4311,4312,4313,4314,4315,4317,4318,4319,4320,4321,4322,4323,4324,4325,4326,4327,4328,4339,4340,4341,4342,4343,4344,4345,4346,4347,4348,4352,4353,5834,8524,8529,8799,8805,8808,8809,8863,9808,9809,13401,15480,15481,17303,17322,
17323,17324,17325,17326,17327,17328,17329,17330,17331,17361,17362,17363,17364,17365,17366,17367,17368,17377,17712,17713,21322,21427);
INSERT INTO `world_state` (`ID`,`DefaultValue`,`MapIDs`,`AreaIDs`,`ScriptName`,`Comment`) VALUES
(601,1,'30,2197',NULL,'','Alterac Valley - Drek\'Thar alive'),
(602,1,'30,2197',NULL,'','Alterac Valley - Vandaar alive'),
(801,0,'30,2197',NULL,'','Alterac Valley - Irondeep Mine - owner'),
(804,0,'30,2197',NULL,'','Alterac Valley - Coldtooth Mine - owner'),
(922,200,'30,2197',NULL,'','Alterac Valley - Stormpike Soldier\'s Blood max'),
(923,0,'30,2197',NULL,'','Alterac Valley - Stormpike Soldier\'s Blood count'),
(1043,0,'30,2197',NULL,'','Alterac Valley - Storm Crystals count'),
(1044,200,'30,2197',NULL,'','Alterac Valley - Storm Crystals max'),
(1181,1,'30,2197',NULL,'','Alterac Valley - Dun Baldar South Bunker - Owner'),
(1182,1,'30,2197',NULL,'','Alterac Valley - Dun Baldar North Bunker - Owner'),
(1183,1,'30,2197',NULL,'','Alterac Valley - Icewing Bunker - Owner'),
(1184,1,'30,2197',NULL,'','Alterac Valley - Stonehearth Bunker - Owner'),
(1185,2,'30,2197',NULL,'','Alterac Valley - West Frostwolf Tower - Owner'),
(1186,2,'30,2197',NULL,'','Alterac Valley - East Frostwolf Tower - Owner'),
(1187,2,'30,2197',NULL,'','Alterac Valley - Tower Point - Owner'),
(1188,2,'30,2197',NULL,'','Alterac Valley - Iceblood Tower - Owner'),
(1301,0,'30,2197',NULL,'','Alterac Valley - Stonehearth Graveyard - Horde Controlled'),
(1302,1,'30,2197',NULL,'','Alterac Valley - Stonehearth Graveyard - Alliance Controlled'),
(1303,0,'30,2197',NULL,'','Alterac Valley - Stonehearth Graveyard - In Conflict'),
(1304,0,'30,2197',NULL,'','Alterac Valley - Stonehearth Graveyard - In Conflict'),
(1325,1,'30,2197',NULL,'','Alterac Valley - Stormpike Aid Station - Alliance Controlled'),
(1326,0,'30,2197',NULL,'','Alterac Valley - Stormpike Aid Station - In Conflict'),
(1327,0,'30,2197',NULL,'','Alterac Valley - Stormpike Aid Station - Horde Controlled'),
(1328,0,'30,2197',NULL,'','Alterac Valley - Stormpike Aid Station - In Conflict'),
(1329,0,'30,2197',NULL,'','Alterac Valley - Frostwolf Relief Hut - Alliance Controlled'),
(1330,1,'30,2197',NULL,'','Alterac Valley - Frostwolf Relief Hut - Horde Controlled'),
(1331,0,'30,2197',NULL,'','Alterac Valley - Frostwolf Relief Hut - In Conflict'),
(1332,0,'30,2197',NULL,'','Alterac Valley - Frostwolf Relief Hut - In Conflict'),
(1333,1,'30,2197',NULL,'','Alterac Valley - Stormpike Graveyard - Alliance Controlled'),
(1334,0,'30,2197',NULL,'','Alterac Valley - Stormpike Graveyard - Horde Controlled'),
(1335,0,'30,2197',NULL,'','Alterac Valley - Stormpike Graveyard - In Conflict'),
(1336,0,'30,2197',NULL,'','Alterac Valley - Stormpike Graveyard - In Conflict'),
(1337,0,'30,2197',NULL,'','Alterac Valley - Frostwolf Graveyard - Alliance Controlled'),
(1338,1,'30,2197',NULL,'','Alterac Valley - Frostwolf Graveyard - Horde Controlled'),
(1339,0,'30,2197',NULL,'','Alterac Valley - Frostwolf Graveyard - In Conflict'),
(1340,0,'30,2197',NULL,'','Alterac Valley - Frostwolf Graveyard - In Conflict'),
(1341,0,'30,2197',NULL,'','Alterac Valley - Snowfall Graveyard - Alliance Controlled'),
(1342,0,'30,2197',NULL,'','Alterac Valley - Snowfall Graveyard - Horde Controlled'),
(1343,0,'30,2197',NULL,'','Alterac Valley - Snowfall Graveyard - In Conflict'),
(1344,0,'30,2197',NULL,'','Alterac Valley - Snowfall Graveyard - In Conflict'),
(1346,0,'30,2197',NULL,'','Alterac Valley - Iceblood Graveyard - Alliance Controlled'),
(1347,1,'30,2197',NULL,'','Alterac Valley - Iceblood Graveyard - Horde Controlled'),
(1348,0,'30,2197',NULL,'','Alterac Valley - Iceblood Graveyard - In Conflict'),
(1349,0,'30,2197',NULL,'','Alterac Valley - Iceblood Graveyard - In Conflict'),
(1351,1,'30,2197',NULL,'','Alterac Valley - Balinda alive'),
(1352,1,'30,2197',NULL,'','Alterac Valley - Galvagar alive'),
(1355,0,'30,2197',NULL,'','Alterac Valley - Coldtooth Mine - Alliance Controlled'),
(1356,0,'30,2197',NULL,'','Alterac Valley - Coldtooth Mine - Horde Controlled'),
(1357,1,'30,2197',NULL,'','Alterac Valley - Coldtooth Mine - Kobold Controlled'),
(1358,0,'30,2197',NULL,'','Alterac Valley - Irondeep Mine - Alliance Controlled'),
(1359,0,'30,2197',NULL,'','Alterac Valley - Irondeep Mine - Horde Controlled'),
(1360,1,'30,2197',NULL,'','Alterac Valley - Irondeep Mine - Trogg Controlled'),
(1361,1,'30,2197',NULL,'','Alterac Valley - Dun Baldar South Bunker - Alliance Controlled'),
(1362,1,'30,2197',NULL,'','Alterac Valley - Dun Baldar North Bunker - Alliance Controlled'),
(1363,1,'30,2197',NULL,'','Alterac Valley - Icewing Bunker - Alliance Controlled'),
(1364,1,'30,2197',NULL,'','Alterac Valley - Stonehearth Bunker - Alliance Controlled'),
(1365,0,'30,2197',NULL,'','Alterac Valley - West Frostwolf Tower - Destroyed'),
(1366,0,'30,2197',NULL,'','Alterac Valley - East Frostwolf Tower - Destroyed'),
(1367,0,'30,2197',NULL,'','Alterac Valley - Tower Point - Destroyed'),
(1368,0,'30,2197',NULL,'','Alterac Valley - Iceblood Tower - Destroyed'),
(1370,0,'30,2197',NULL,'','Alterac Valley - Dun Baldar South Bunker - Destroyed'),
(1371,0,'30,2197',NULL,'','Alterac Valley - Dun Baldar North Bunker - Destroyed'),
(1372,0,'30,2197',NULL,'','Alterac Valley - Icewing Bunker - Destroyed'),
(1373,0,'30,2197',NULL,'','Alterac Valley - Stonehearth Bunker - Destroyed'),
(1374,0,'30,2197',NULL,'','Alterac Valley - Dun Baldar South Bunker - In Conflict'),
(1375,0,'30,2197',NULL,'','Alterac Valley - Dun Baldar North Bunker - In Conflict'),
(1376,0,'30,2197',NULL,'','Alterac Valley - Icewing Bunker - In Conflict'),
(1377,0,'30,2197',NULL,'','Alterac Valley - Stonehearth Bunker - In Conflict'),
(1378,0,'30,2197',NULL,'','Alterac Valley - Dun Baldar South Bunker - In Conflict'),
(1379,0,'30,2197',NULL,'','Alterac Valley - Dun Baldar North Bunker - In Conflict'),
(1380,0,'30,2197',NULL,'','Alterac Valley - Icewing Bunker - In Conflict'),
(1381,0,'30,2197',NULL,'','Alterac Valley - Stonehearth Bunker - In Conflict'),
(1382,1,'30,2197',NULL,'','Alterac Valley - West Frostwolf Tower - Horde Controlled'),
(1383,1,'30,2197',NULL,'','Alterac Valley - East Frostwolf Tower - Horde Controlled'),
(1384,1,'30,2197',NULL,'','Alterac Valley - Tower Point - Horde Controlled'),
(1385,1,'30,2197',NULL,'','Alterac Valley - Iceblood Tower - Horde Controlled'),
(1387,0,'30,2197',NULL,'','Alterac Valley - West Frostwolf Tower - In Conflict'),
(1388,0,'30,2197',NULL,'','Alterac Valley - East Frostwolf Tower - In Conflict'),
(1389,0,'30,2197',NULL,'','Alterac Valley - Tower Point - In Conflict'),
(1390,0,'30,2197',NULL,'','Alterac Valley - Iceblood Tower - In Conflict'),
(1392,0,'30,2197',NULL,'','Alterac Valley - West Frostwolf Tower - In Conflict'),
(1393,0,'30,2197',NULL,'','Alterac Valley - East Frostwolf Tower - In Conflict'),
(1394,0,'30,2197',NULL,'','Alterac Valley - Tower Point - In Conflict'),
(1395,0,'30,2197',NULL,'','Alterac Valley - Iceblood Tower - In Conflict'),
(1545,1,'489,726,2106',NULL,'','Warsong Gulch/Twin Peaks - Alliance flag state'),
(1546,1,'489,726,2106',NULL,'','Warsong Gulch/Twin Peaks - Horde flag state'),
(1547,0,'489,726,2106',NULL,'','Warsong Gulch/Twin Peaks - Neutral flag state'),
(1581,0,'489,726,2106',NULL,'','Warsong Gulch/Twin Peaks - Alliance flag captures'),
(1582,0,'489,726,2106',NULL,'','Warsong Gulch/Twin Peaks - Horde flag captures'),
(1601,3,'489,726,2106',NULL,'','Warsong Gulch/Twin Peaks - Max flag captures'),
(1664,1,'489,2106',NULL,'','Warsong Gulch - unknown state, enables Save the Day achievement (not the only requirement)'),
(1767,0,'529',NULL,'','Arathi Basin - Stables Alliance controlled'),
(1768,0,'529',NULL,'','Arathi Basin - Stables Horde controlled'),
(1769,0,'529',NULL,'','Arathi Basin - Stables Alliance - contested'),
(1770,0,'529',NULL,'','Arathi Basin - Stables Horde - contested'),
(1772,0,'529',NULL,'','Arathi Basin - Farm Alliance controlled'),
(1773,0,'529',NULL,'','Arathi Basin - Farm Horde controlled'),
(1774,0,'529',NULL,'','Arathi Basin - Farm Alliance - contested'),
(1775,0,'529',NULL,'','Arathi Basin - Farm Horde - contested'),
(1776,0,'529,566,761,968,1105,1681,2107,2177',NULL,'','Battlegrounds - Alliance resources'),
(1777,0,'529,566,761,968,1105,1681,2107,2177',NULL,'','Battlegrounds - Horde resources'),
(1778,0,'529,761,1681,2107,2177',NULL,'','Battlegrounds - Alliance bases'),
(1779,0,'529,761,1681,2107,2177',NULL,'','Battlegrounds - Horde bases'),
(1780,1500,'529,566,761,968,1105,1681,2107,2177',NULL,'','Battlegrounds - Max resources'),
(1782,0,'529',NULL,'','Arathi Basin - Blacksmith Alliance controlled'),
(1783,0,'529',NULL,'','Arathi Basin - Blacksmith Horde controlled'),
(1784,0,'529',NULL,'','Arathi Basin - Blacksmith Alliance - contested'),
(1785,0,'529',NULL,'','Arathi Basin - Blacksmith Horde - contested'),
(1787,0,'529',NULL,'','Arathi Basin - Gold Mine Alliance controlled'),
(1788,0,'529',NULL,'','Arathi Basin - Gold Mine Horde controlled'),
(1789,0,'529',NULL,'','Arathi Basin - Gold Mine Alliance - contested'),
(1790,0,'529',NULL,'','Arathi Basin - Gold Mine Horde - contested'),
(1792,0,'529',NULL,'','Arathi Basin - Lumber Mill Alliance controlled'),
(1793,0,'529',NULL,'','Arathi Basin - Lumber Mill Horde controlled'),
(1794,0,'529',NULL,'','Arathi Basin - Lumber Mill Alliance - contested'),
(1795,0,'529',NULL,'','Arathi Basin - Lumber Mill Horde - contested'),
(1842,1,'529',NULL,'','Arathi Basin - Stables uncontrolled POI'),
(1843,1,'529',NULL,'','Arathi Basin - Gold Mine uncontrolled POI'),
(1844,1,'529',NULL,'','Arathi Basin - Lumber Mill uncontrolled POI'),
(1845,1,'529',NULL,'','Arathi Basin - Farm uncontrolled POI'),
(1846,1,'529',NULL,'','Arathi Basin - Blacksmith uncontrolled POI'),
(1955,1400,'529,1681,2107,2177',NULL,'','Arathi Basin - Near victory resource level warning'),
(1966,1,'30,2197',NULL,'','Alterac Valley - Snowfall Graveyard - Uncontrolled'),
(2338,1,'489,2106',NULL,'','Warsong Gulch - Horde flag control state'),
(2339,1,'489,2106',NULL,'','Warsong Gulch - Alliance flag control state'),
(2718,0,'566',NULL,'','Eye of the Storm - Show capturing progress bar'),
(2719,50,'566',NULL,'','Eye of the Storm - Capturing progress bar current value'),
(2720,40,'566',NULL,'','Eye of the Storm - Capturing progress bar neutral zone size'),
(2722,1,'566,968',NULL,'','Eye of the Storm - Blood Elf Tower uncontrolled POI'),
(2723,0,'566,968',NULL,'','Eye of the Storm - Blood Elf Tower Alliance control POI'),
(2724,0,'566,968',NULL,'','Eye of the Storm - Blood Elf Tower Horde control POI'),
(2725,1,'566,968',NULL,'','Eye of the Storm - Fel Reaver Ruins uncontrolled POI'),
(2726,0,'566,968',NULL,'','Eye of the Storm - Fel Reaver Ruins Alliance control POI'),
(2727,0,'566,968',NULL,'','Eye of the Storm - Fel Reaver Ruins Horde control POI'),
(2728,1,'566,968',NULL,'','Eye of the Storm - Mage Tower uncontrolled POI'),
(2729,0,'566,968',NULL,'','Eye of the Storm - Mage Tower Horde control POI'),
(2730,0,'566,968',NULL,'','Eye of the Storm - Mage Tower Alliance control POI'),
(2731,1,'566,968',NULL,'','Eye of the Storm - Draenei Ruins uncontrolled POI'),
(2732,0,'566,968',NULL,'','Eye of the Storm - Draenei Ruins Alliance control POI'),
(2733,0,'566,968',NULL,'','Eye of the Storm - Draenei Ruins Horde control POI'),
(2752,0,'566,968',NULL,'','Eye of the Storm - Alliance bases controlled'),
(2753,0,'566,968',NULL,'','Eye of the Storm - Horde bases controlled'),
(3127,700,'30',NULL,'','Alterac Valley - Alliance Reinforcements'),
(3128,700,'30',NULL,'','Alterac Valley - Horde Reinforcements'),
(3133,1,'30',NULL,'','Alterac Valley - Show Horde Reinforcements'),
(3134,1,'30',NULL,'','Alterac Valley - Show Alliance Reinforcements'),
(3136,700,'30',NULL,'','Alterac Valley - Max Reinforcements'),
(3557,0,'607',NULL,'','Strand of the Ancients - Timer'),
(3564,0,'607',NULL,'','Strand of the Ancients - Show timer'),
(3565,0,'607',NULL,'','Strand of the Ancients - Show timer'),
(3571,0,'607',NULL,'','Strand of the Ancients - Show bonus timer'),
(3600,0,'559,562,572,617,618,980,1134,1504,1505,1552,1672,1825,1911,2167,2373,2509,2511,2547',NULL,'','Arenas - Green Team Players remaining'),
(3601,0,'559,562,572,617,618,980,1134,1504,1505,1552,1672,1825,1911,2167,2373,2509,2511,2547',NULL,'','Arenas - Gold Team Players remaining'),
(3610,1,'559,562,572,617,618,980,1134,1504,1505,1552,1672,1825,1911,2167,2373,2509,2511,2547',NULL,'','Arenas - Show players remaining'),
(3614,1,'607',NULL,'','Strand of the Ancients - Gate of the Purple Amethyst'),
(3617,1,'607',NULL,'','Strand of the Ancients - Gate of the Red Sun'),
(3620,1,'607',NULL,'','Strand of the Ancients - Gate of the Blue Sapphire'),
(3623,1,'607',NULL,'','Strand of the Ancients - Gate of the Green Emerald'),
(3626,0,'607',NULL,'','Strand of the Ancients - The Frostbreaker - Alliance Offense'),
(3627,0,'607',NULL,'','Strand of the Ancients - The Graceful Maiden - Alliance Offense'),
(3628,0,'607',NULL,'','Strand of the Ancients - The Blightbringer - Horde Offense'),
(3629,0,'607',NULL,'','Strand of the Ancients - The Casket Carrier - Horde Offense'),
(3630,0,'607',NULL,'','Strand of the Ancients - Alliance Defense'),
(3631,0,'607',NULL,'','Strand of the Ancients - Horde Defense'),
(3632,0,'607',NULL,'','Strand of the Ancients - East Graveyard - Horde Controlled'),
(3633,0,'607',NULL,'','Strand of the Ancients - West Graveyard - Horde Controlled'),
(3634,0,'607',NULL,'','Strand of the Ancients - South Graveyard - Horde Controlled'),
(3635,0,'607',NULL,'','Strand of the Ancients - West Graveyard - Alliance Controlled'),
(3636,0,'607',NULL,'','Strand of the Ancients - East Graveyard - Alliance Controlled'),
(3637,0,'607',NULL,'','Strand of the Ancients - South Graveyard - Alliance Controlled'),
(3638,1,'607',NULL,'','Strand of the Ancients - Gate of the Yellow Moon'),
(3644,0,'529,761,1681,2107,2177',NULL,'','Battlegrounds - Alliance overcame resource disadvantage'),
(3645,0,'529,761,1681,2107,2177',NULL,'','Battlegrounds - Horde overcame resource disadvantage'),
(3690,0,'607',NULL,'','Strand of the Ancients - Attacker team'),
(3849,1,'607',NULL,'','Strand of the Ancients - Chamber of Ancient Relics'),
(3955,0,'607',NULL,'','Strand of the Ancients - Destroyed Alliance vehicles'),
(3956,0,'607',NULL,'','Strand of the Ancients - Destroyed Horde vehicles'),
(4221,1,'628',NULL,'','Isle of Conquest - Show Alliance reinforcements'),
(4222,1,'628',NULL,'','Isle of Conquest - Show Horde reinforcements'),
(4226,400,'628',NULL,'','Isle of Conquest - Alliance reinforcements'),
(4227,400,'628',NULL,'','Isle of Conquest - Horde reinforcements'),
(4228,0,'628',NULL,'','Isle of Conquest - Workshop - In Conflict Alliance'),
(4229,0,'628',NULL,'','Isle of Conquest - Workshop - Alliance Controlled'),
(4230,0,'628',NULL,'','Isle of Conquest - Workshop - Horde Controlled'),
(4232,0,'628',NULL,'','Isle of Conquest - Workshop - Owner'),
(4234,0,'628',NULL,'','Isle of Conquest - Hangar - Owner'),
(4235,0,'628',NULL,'','Isle of Conquest - Docks - Owner'),
(4247,0,'489,726,2106',NULL,'','Warsong Gulch/Twin Peaks - Show timer'),
(4248,0,'489,726,2106',NULL,'','Warsong Gulch/Twin Peaks - Timer'),
(4287,0,'628',NULL,'','Isle of Conquest - Refinery - Owner'),
(4289,0,'628',NULL,'','Isle of Conquest - Quarry - Owner'),
(4293,0,'628',NULL,'','Isle of Conquest - Workshop - In Conflict Horde'),
(4294,1,'628',NULL,'','Isle of Conquest - Workshop - Uncontrolled'),
(4296,1,'628',NULL,'','Isle of Conquest - Hangar - Uncontrolled'),
(4297,0,'628',NULL,'','Isle of Conquest - Hangar - In Conflict Horde'),
(4298,0,'628',NULL,'','Isle of Conquest - Hangar - Horde Controlled'),
(4299,0,'628',NULL,'','Isle of Conquest - Hangar - Alliance Controlled'),
(4300,0,'628',NULL,'','Isle of Conquest - Hangar - In Conflict Alliance'),
(4301,1,'628',NULL,'','Isle of Conquest - Docks - Uncontrolled'),
(4302,0,'628',NULL,'','Isle of Conquest - Docks - In Conflict Horde'),
(4303,0,'628',NULL,'','Isle of Conquest - Docks - Horde Controlled'),
(4304,0,'628',NULL,'','Isle of Conquest - Docks - Alliance Controlled'),
(4305,0,'628',NULL,'','Isle of Conquest - Docks - In Conflict Alliance'),
(4306,1,'628',NULL,'','Isle of Conquest - Quarry - Uncontrolled'),
(4307,0,'628',NULL,'','Isle of Conquest - Quarry - In Conflict Horde'),
(4308,0,'628',NULL,'','Isle of Conquest - Quarry - Horde Controlled'),
(4309,0,'628',NULL,'','Isle of Conquest - Quarry - Alliance Controlled'),
(4310,0,'628',NULL,'','Isle of Conquest - Quarry - In Conflict Alliance'),
(4311,1,'628',NULL,'','Isle of Conquest - Refinery - Uncontrolled'),
(4312,0,'628',NULL,'','Isle of Conquest - Refinery - In Conflict Horde'),
(4313,0,'628',NULL,'','Isle of Conquest - Refinery - Horde Controlled'),
(4314,0,'628',NULL,'','Isle of Conquest - Refinery - Alliance Controlled'),
(4315,0,'628',NULL,'','Isle of Conquest - Refinery - In Conflict Alliance'),
(4317,1,'628',NULL,'','Isle of Conquest - Horde Front Gate'),
(4318,1,'628',NULL,'','Isle of Conquest - Horde West Gate'),
(4319,1,'628',NULL,'','Isle of Conquest - Horde East Gate'),
(4320,0,'628',NULL,'','Isle of Conquest - Horde East Gate - Destroyed'),
(4321,0,'628',NULL,'','Isle of Conquest - Horde West Gate - Destroyed'),
(4322,0,'628',NULL,'','Isle of Conquest - Horde Front Gate - Destroyed'),
(4323,0,'628',NULL,'','Isle of Conquest - Alliance Front Gate - Destroyed'),
(4324,0,'628',NULL,'','Isle of Conquest - Alliance West Gate - Destroyed'),
(4325,0,'628',NULL,'','Isle of Conquest - Alliance East Gate - Destroyed'),
(4326,1,'628',NULL,'','Isle of Conquest - Alliance East Gate'),
(4327,1,'628',NULL,'','Isle of Conquest - Alliance West Gate'),
(4328,1,'628',NULL,'','Isle of Conquest - Alliance Front Gate'),
(4339,1,'628',NULL,'','Isle of Conquest - Alliance Keep - Alliance Controlled'),
(4340,0,'628',NULL,'','Isle of Conquest - Alliance Keep - Horde Controlled'),
(4341,0,'628',NULL,'','Isle of Conquest - Alliance Keep - Uncontrolled'),
(4342,0,'628',NULL,'','Isle of Conquest - Alliance Keep - In Conflict Alliance'),
(4343,0,'628',NULL,'','Isle of Conquest - Alliance Keep - In Conflict Horde'),
(4344,0,'628',NULL,'','Isle of Conquest - Horde Keep - Alliance Controlled'),
(4345,1,'628',NULL,'','Isle of Conquest - Horde Keep - Horde Controlled'),
(4346,0,'628',NULL,'','Isle of Conquest - Horde Keep - Uncontrolled'),
(4347,0,'628',NULL,'','Isle of Conquest - Horde Keep - In Conflict Alliance'),
(4348,0,'628',NULL,'','Isle of Conquest - Horde Keep - In Conflict Horde'),
(4352,0,'607',NULL,'','Strand of the Ancients - Alliance Attacker'),
(4353,0,'607',NULL,'','Strand of the Ancients - Horde Attacker'),
(5834,0,'529,1681,2107,2177',NULL,'','Arathi Basin - Stables control state POI');

DELETE FROM `achievement_criteria_data` WHERE `ScriptName` IN (
'achievement_resilient_victory',
'achievement_bg_control_all_nodes',
'achievement_save_the_day',
'achievement_bg_ic_resource_glut',
'achievement_bg_ic_glaive_grave',
'achievement_bg_ic_mowed_down',
'achievement_bg_sa_artillery',
'achievement_sickly_gazelle',
'achievement_everything_counts',
'achievement_bg_av_perfection',
'achievement_bg_sa_defense_of_ancients',
'achievement_not_even_a_scratch'
);
DELETE FROM `world_state` WHERE `ID` IN (2313,2314,2317,2322,2323,2324,2325,2470,2471,2472,2473,2474,2475,2476,2478,2480,2481,2482,2483,2484,2485,2489,2490,2491,2493,2494,2495,2497,2502,
2503,2508,2509,2510,2512,2527,2528,2529,2533,2534,2535,2555,2556,2557,2558,2559,2560,2620,2621,2622,2623,2624,2625,2644,2645,2646,2647,2648,2649,2650,2651,2652,2655,2656,2657,2658,2659,
2660,2661,2662,2663,2664,2665,2666,2667,2668,2669,2670,2671,2672,2673,2676,2677,2681,2682,2683,2684,2685,2686,2688,2689,2690,2691,2692,2693,2694,2695,2696,2760,2761,2762,2763,2767,2768);
INSERT INTO `world_state` (`ID`,`DefaultValue`,`MapIDs`,`AreaIDs`,`ScriptName`,`Comment`) VALUES
(2313,0,'1','1377','','Silithus - Alliance Silithyst Collected'),
(2314,0,'1','1377','','Silithus - Horde Silithyst Collected'),
(2317,200,'1','1377','','Silithus - Max Silithyst'),
(2322,0,'1','1377','','Silithus - Sandworm N (unused)'),
(2323,0,'1','1377','','Silithus - Sandworm S (unused)'),
(2324,0,'1','1377','','Silithus - Sandworm SW (unused)'),
(2325,0,'1','1377','','Silithus - Sandworm E (unused)'),
(2470,0,'530','3483','','Hellfire Peninsula - The Stadium - Horde Controlled'),
(2471,0,'530','3483','','Hellfire Peninsula - The Stadium - Alliance Controlled'),
(2472,1,'530','3483','','Hellfire Peninsula - The Stadium - Neutral'),
(2473,0,'530','3483','','Hellfire Peninsula - Show Fort capture bar'),
(2474,50,'530','3483','','Hellfire Peninsula - Fort CaptureBar Value'),
(2475,20,'530','3483','','Hellfire Peninsula - Fort CaptureBar Neutral Zone Size'),
(2476,0,'530','3483','','Hellfire Peninsula - Alliance Forts Controlled'),
(2478,0,'530','3483','','Hellfire Peninsula - Horde Forts Controlled'),
(2480,0,'530','3483','','Hellfire Peninsula - The Overlook - Alliance Controlled'),
(2481,0,'530','3483','','Hellfire Peninsula - The Overlook - Horde Controlled'),
(2482,1,'530','3483','','Hellfire Peninsula - The Overlook - Neutral'),
(2483,0,'530','3483','','Hellfire Peninsula - Broken Hill - Alliance Controlled'),
(2484,0,'530','3483','','Hellfire Peninsula - Broken Hill - Horde Controlled'),
(2485,1,'530','3483','','Hellfire Peninsula - Broken Hill - Neutral'),
(2489,1,'530','3483','','Hellfire Peninsula - Show Horde Forts Controlled'),
(2490,1,'530','3483','','Hellfire Peninsula - Show Alliance Forts Controlled'),
(2491,0,'530','3518','','Nagrand - Halaa - Guards Remaining'),
(2493,15,'530','3518','','Nagrand - Halaa - Guards Max'),
(2494,50,'530','3518','','Nagrand - Halaa - CaptureBar Value'),
(2495,0,'530','3518','','Nagrand - Halaa - Show capture bar'),
(2497,0,'530','3518','','Nagrand - Halaa - CaptureBar Neutral Zone Size'),
(2502,0,'530','3518','','Nagrand - Halaa - Show Alliance Guards Remaining'),
(2503,0,'530','3518','','Nagrand - Halaa - Show Horde Guards Remaining'),
(2508,0,'530','3519','','Terokkar Forest - Show Locked time remaining (Neutral)'),
(2509,0,'530','3519','','Terokkar Forest - Locked time remaining hours'),
(2510,0,'530','3519','','Terokkar Forest - Locked time remaining minutes first digit'),
(2512,0,'530','3519','','Terokkar Forest - Locked time remaining minutes second digit'),
(2527,0,'530','3521','','Zangarmarsh - West Beacon Show CaptureBar'),
(2528,50,'530','3521','','Zangarmarsh - West Beacon CaptureBar Value'),
(2529,80,'530','3521','','Zangarmarsh - West Beacon CaptureBar Neutral Zone Size'),
(2533,0,'530','3521','','Zangarmarsh - East Beacon Show CaptureBar'),
(2534,50,'530','3521','','Zangarmarsh - East Beacon CaptureBar Value'),
(2535,80,'530','3521','','Zangarmarsh - East Beacon CaptureBar Neutral Zone Size'),
(2555,0,'530','3521','','Zangarmarsh - West Beacon - Alliance Controlled widget'),
(2556,0,'530','3521','','Zangarmarsh - West Beacon - Horde Controlled widget'),
(2557,1,'530','3521','','Zangarmarsh - West Beacon - Neutral widget'),
(2558,0,'530','3521','','Zangarmarsh - East Beacon - Alliance Controlled widget'),
(2559,0,'530','3521','','Zangarmarsh - East Beacon - Horde Controlled widget'),
(2560,1,'530','3521','','Zangarmarsh - East Beacon - Neutral widget'),
(2620,1,'530','3519','','Terokkar Forest - Show Towers Controlled'),
(2621,0,'530','3519','','Terokkar Forest - Alliance Towers Controlled'),
(2622,0,'530','3519','','Terokkar Forest - Horde Towers Controlled'),
(2623,0,'530','3519','','Terokkar Forest - Show Tower capture bar'),
(2624,80,'530','3519','','Terokkar Forest - Tower CaptureBar Neutral Zone Size'),
(2625,50,'530','3519','','Terokkar Forest - Tower CaptureBar Value'),
(2644,0,'530','3521','','Zangarmarsh - West Beacon - Alliance Controlled POI'),
(2645,0,'530','3521','','Zangarmarsh - West Beacon - Horde Controlled POI'),
(2646,1,'530','3521','','Zangarmarsh - West Beacon  POI'),
(2647,1,'530','3521','','Zangarmarsh - Twinspire Graveyard'),
(2648,0,'530','3521','','Zangarmarsh - Twinspire Graveyard - Alliance Controlled'),
(2649,0,'530','3521','','Zangarmarsh - Twinspire Graveyard - Horde Controlled'),
(2650,0,'530','3521','','Zangarmarsh - East Beacon - Alliance Controlled POI'),
(2651,0,'530','3521','','Zangarmarsh - East Beacon - Horde Controlled POI'),
(2652,1,'530','3521','','Zangarmarsh - East Beacon POI'),
(2655,0,'530','3521','','Zangarmarsh - Alliance Field Scout (ready)'),
(2656,1,'530','3521','','Zangarmarsh - Alliance Field Scout (not ready)'),
(2657,1,'530','3521','','Zangarmarsh - Horde Field Scout (not ready)'),
(2658,0,'530','3521','','Zangarmarsh - Horde Field Scout (ready)'),
(2659,0,'530','3518','','Nagrand - Wyvern Camp (East) - Alliance Uncontrolled'),
(2660,0,'530','3518','','Nagrand - Wyvern Camp (East) - Horde Controlled'),
(2661,0,'530','3518','','Nagrand - Wyvern Camp (East) - Alliance Controlled'),
(2662,0,'530','3518','','Nagrand - Wyvern Camp (North) - Alliance Uncontrolled'),
(2663,0,'530','3518','','Nagrand - Wyvern Camp (North) - Horde Controlled'),
(2664,0,'530','3518','','Nagrand - Wyvern Camp (North) - Alliance Controlled'),
(2665,0,'530','3518','','Nagrand - Wyvern Camp (West) - Horde Controlled'),
(2666,0,'530','3518','','Nagrand - Wyvern Camp (West) - Alliance Controlled'),
(2667,0,'530','3518','','Nagrand - Wyvern Camp (West) - Alliance Uncontrolled'),
(2668,0,'530','3518','','Nagrand - Wyvern Camp (South) - Horde Controlled'),
(2669,0,'530','3518','','Nagrand - Wyvern Camp (South) - Alliance Controlled'),
(2670,0,'530','3518','','Nagrand - Wyvern Camp (South) - Alliance Uncontrolled'),
(2671,1,'530','3518','','Nagrand - Halaa - Uncontrolled'),
(2672,0,'530','3518','','Nagrand - Halaa - Horde Controlled'),
(2673,0,'530','3518','','Nagrand - Halaa - Alliance Controlled'),
(2676,0,'530','3518','','Nagrand - Halaa - Alliance Capturing'),
(2677,0,'530','3518','','Nagrand - Halaa - Horde Capturing'),
(2681,1,'530','3519','','Terokkar Forest - Spirit Tower (NW) - Neutral'),
(2682,0,'530','3519','','Terokkar Forest - Spirit Tower (NW) - Horde Controlled'),
(2683,0,'530','3519','','Terokkar Forest - Spirit Tower (NW) - Alliance Controlled'),
(2684,0,'530','3519','','Terokkar Forest - Spirit Tower (N) - Alliance Controlled'),
(2685,0,'530','3519','','Terokkar Forest - Spirit Tower (N) - Horde Controlled'),
(2686,1,'530','3519','','Terokkar Forest - Spirit Tower (N) - Neutral'),
(2688,0,'530','3519','','Terokkar Forest - Spirit Tower (NE) - Alliance Controlled'),
(2689,0,'530','3519','','Terokkar Forest - Spirit Tower (NE) - Horde Controlled'),
(2690,1,'530','3519','','Terokkar Forest - Spirit Tower (NE) - Neutral'),
(2691,0,'530','3519','','Terokkar Forest - Spirit Tower (S) - Alliance Controlled'),
(2692,0,'530','3519','','Terokkar Forest - Spirit Tower (S) - Horde Controlled'),
(2693,1,'530','3519','','Terokkar Forest - Spirit Tower (S) - Neutral'),
(2694,0,'530','3519','','Terokkar Forest - Spirit Tower (SE) - Alliance Controlled'),
(2695,0,'530','3519','','Terokkar Forest - Spirit Tower (SE) - Horde Controlled'),
(2696,1,'530','3519','','Terokkar Forest - Spirit Tower (SE) - Neutral'),
(2760,0,'530','3518','','Nagrand - Wyvern Camp (South) - Horde Uncontrolled'),
(2761,0,'530','3518','','Nagrand - Wyvern Camp (West) - Horde Uncontrolled'),
(2762,0,'530','3518','','Nagrand - Wyvern Camp (North) - Horde Uncontrolled'),
(2763,0,'530','3518','','Nagrand - Wyvern Camp (East) - Horde Uncontrolled'),
(2767,0,'530','3519','','Terokkar Forest - Show Locked time remaining (Alliance)'),
(2768,0,'530','3519','','Terokkar Forest - Show Locked time remaining (Horde)');
DELETE FROM `world_state` WHERE `ID` IN (1941,1942,1943,2851,3695,4273,5360,5361,6306,6436,7671);
INSERT INTO `world_state` (`ID`,`DefaultValue`,`MapIDs`,`AreaIDs`,`ScriptName`,`Comment`) VALUES
(1941,0,NULL,NULL,'','Battleground Call to Arms - Alterac Valley'),
(1942,0,NULL,NULL,'','Battleground Call to Arms - Warsong Gulch'),
(1943,0,NULL,NULL,'','Battleground Call to Arms - Arathi Basin'),
(2851,0,NULL,NULL,'','Battleground Call to Arms - Eye of the Storm'),
(3695,0,NULL,NULL,'','Battleground Call to Arms - Strand of the Ancients'),
(4273,0,NULL,NULL,'','Battleground Call to Arms - Isle of Conquest'),
(5360,0,NULL,NULL,'','Battleground Call to Arms - The Battle for Gilneas'),
(5361,0,NULL,NULL,'','Battleground Call to Arms - Twin Peaks');
UPDATE `world_state` SET `Comment`='Battlegrounds - Horde bases' WHERE `ID`=1778;
UPDATE `world_state` SET `Comment`='Battlegrounds - Alliance bases' WHERE `ID`=1779;

DELETE FROM `world_state` WHERE `ID` IN (3191,3901);
INSERT INTO `world_state` (`ID`,`DefaultValue`,`MapIDs`,`AreaIDs`,`ScriptName`,`Comment`) VALUES
(3191,0,NULL,NULL,'','PvpSeason - Current season ID'),
(3901,0,NULL,NULL,'','PvpSeason - Previous season ID');
DELETE FROM `world_state` WHERE `ID` IN (2259,2260,2261,2262,2263,2264);
INSERT INTO `world_state` (`ID`,`DefaultValue`,`MapIDs`,`AreaIDs`,`ScriptName`,`Comment`) VALUES
(2259,0,NULL,NULL,'','Scourge Invasion - Winterspring Under Attack'),
(2260,0,NULL,NULL,'','Scourge Invasion - Azshara Under Attack'),
(2261,0,NULL,NULL,'','Scourge Invasion - Blasted Lands Under Attack'),
(2262,0,NULL,NULL,'','Scourge Invasion - Burning Steppes Under Attack'),
(2263,0,NULL,NULL,'','Scourge Invasion - Tanaris Under Attack'),
(2264,0,NULL,NULL,'','Scourge Invasion - Eastern Plaguelands Under Attack');
DELETE FROM `world_state` WHERE `ID` IN (3590,3591,3592,3603,3604,3605);
INSERT INTO `world_state` VALUES 
(3590,300,'609',NULL,'','Ebon Hold - Forces of the Light remaining'),
(3591,10000,'609',NULL,'','Ebon Hold - Forces of the Scourge Remaining'),
(3592,0,'609',NULL,'','Ebon Hold - Show Forces Remaining'),
(3603,0,'609',NULL,'','Ebon Hold - Show Minutes until battle'),
(3604,0,'609',NULL,'','Ebon Hold - Minutes until battle'),
(3605,0,'609',NULL,'','Ebon Hold - Battle in progress');
DELETE FROM `game_event` WHERE `eventEntry` IN (84, 85, 86);
INSERT INTO `game_event` (`eventEntry`, `start_time`, `end_time`, `occurence`, `length`, `description`) VALUES
(84, null, null, 5184000, 2592000, 'Arena Season 9'),
(85, null, null, 5184000, 2592000, 'Arena Season 10'),
(86, null, null, 5184000, 2592000, 'Arena Season 11');

DELETE FROM `game_event_arena_seasons` WHERE `eventEntry` IN (84, 85, 86);
INSERT INTO `game_event_arena_seasons` (`eventEntry`, `season`) VALUES
(84, 9),
(85, 10),
(86, 11);
DELETE FROM `spawn_group_template` WHERE `groupId` BETWEEN 105 AND 124;
INSERT INTO `spawn_group_template` (`groupId`,`groupName`,`groupFlags`) VALUES
(105,'Nagrand - Halaa - Horde Controlled',32),
(106,'Nagrand - Halaa - Alliance Controlled',32),
(107,'Nagrand - Halaa - Wyvern Camp (East) - Horde Uncontrolled',32),
(108,'Nagrand - Halaa - Wyvern Camp (East) - Alliance Uncontrolled',32),
(109,'Nagrand - Halaa - Wyvern Camp (East) - Horde Controlled',32),
(110,'Nagrand - Halaa - Wyvern Camp (East) - Alliance Controlled',32),
(111,'Nagrand - Halaa - Wyvern Camp (North) - Horde Uncontrolled',32),
(112,'Nagrand - Halaa - Wyvern Camp (North) - Alliance Uncontrolled',32),
(113,'Nagrand - Halaa - Wyvern Camp (North) - Horde Controlled',32),
(114,'Nagrand - Halaa - Wyvern Camp (North) - Alliance Controlled',32),
(115,'Nagrand - Halaa - Wyvern Camp (West) - Horde Uncontrolled',32),
(116,'Nagrand - Halaa - Wyvern Camp (West) - Alliance Uncontrolled',32),
(117,'Nagrand - Halaa - Wyvern Camp (West) - Horde Controlled',32),
(118,'Nagrand - Halaa - Wyvern Camp (West) - Alliance Controlled',32),
(119,'Nagrand - Halaa - Wyvern Camp (South) - Horde Uncontrolled',32),
(120,'Nagrand - Halaa - Wyvern Camp (South) - Alliance Uncontrolled',32),
(121,'Nagrand - Halaa - Wyvern Camp (South) - Horde Controlled',32),
(122,'Nagrand - Halaa - Wyvern Camp (South) - Alliance Controlled',32),
(123,'Nagrand - Halaa - Horde Guards',32),
(124,'Nagrand - Halaa - Alliance Guards',32);

DELETE FROM `creature` WHERE `guid` BETWEEN 145427 AND 145466;
INSERT INTO `creature` (`guid`, `id`, `map`, `zoneId`, `areaId`, `spawnMask`, `phaseUseFlags`, `PhaseId`, `PhaseGroup`, `terrainSwapMap`, `modelid`, `equipment_id`, `position_x`, `position_y`, `position_z`, `orientation`, `spawntimesecs`, `wander_distance`, `currentwaypoint`, `curhealth`, `curmana`, `MovementType`, `npcflag`, `unit_flags`, `dynamicflags`, `ScriptName`, `VerifiedBuild`) VALUES
(145427, 18816, 530, 0, 0, 1, 0, 0, 0, -1, 0, 0, -1523.92, 7951.76, -17.6942, 3.51172, 1000000, 0, 0, 0, 0, 0, 0, 0, 0, '', 0),
(145428, 18821, 530, 0, 0, 1, 0, 0, 0, -1, 0, 0, -1527.75, 7952.46, -17.6948, 3.99317, 1000000, 0, 0, 0, 0, 0, 0, 0, 0, '', 0),
(145429, 21474, 530, 0, 0, 1, 0, 0, 0, -1, 0, 0, -1520.14, 7927.11, -20.2527, 3.39389, 1000000, 0, 0, 0, 0, 0, 0, 0, 0, '', 0),
(145430, 21484, 530, 0, 0, 1, 0, 0, 0, -1, 0, 0, -1524.84, 7930.34, -20.182, 3.6405, 1000000, 0, 0, 0, 0, 0, 0, 0, 0, '', 0),
(145431, 21483, 530, 0, 0, 1, 0, 0, 0, -1, 0, 0, -1570.01, 7993.8, -22.4505, 5.02655, 1000000, 0, 0, 0, 0, 0, 0, 0, 0, '', 0),
(145432, 18192, 530, 0, 0, 1, 0, 0, 0, -1, 0, 0, -1654.06, 8000.46, -26.59, 3.37, 1000000, 0, 0, 10000000, 0, 0, 0, 0, 0, '', 0),
(145433, 18192, 530, 0, 0, 1, 0, 0, 0, -1, 0, 0, -1487.18, 7899.1, -19.53, 0.954, 1000000, 0, 0, 10000000, 0, 0, 0, 0, 0, '', 0),
(145434, 18192, 530, 0, 0, 1, 0, 0, 0, -1, 0, 0, -1480.88, 7908.79, -19.19, 4.485, 1000000, 0, 0, 10000000, 0, 0, 0, 0, 0, '', 0),
(145435, 18192, 530, 0, 0, 1, 0, 0, 0, -1, 0, 0, -1540.56, 7995.44, -20.45, 0.947, 1000000, 0, 0, 10000000, 0, 0, 0, 0, 0, '', 0),
(145436, 18192, 530, 0, 0, 1, 0, 0, 0, -1, 0, 0, -1546.95, 8000.85, -20.72, 6.035, 1000000, 0, 0, 10000000, 0, 0, 0, 0, 0, '', 0),
(145437, 18192, 530, 0, 0, 1, 0, 0, 0, -1, 0, 0, -1595.31, 7860.53, -21.51, 3.747, 1000000, 0, 0, 10000000, 0, 0, 0, 0, 0, '', 0),
(145438, 18192, 530, 0, 0, 1, 0, 0, 0, -1, 0, 0, -1642.31, 7995.59, -25.8, 3.317, 1000000, 0, 0, 10000000, 0, 0, 0, 0, 0, '', 0),
(145439, 18192, 530, 0, 0, 1, 0, 0, 0, -1, 0, 0, -1545.46, 7995.35, -20.63, 1.094, 1000000, 0, 0, 10000000, 0, 0, 0, 0, 0, '', 0),
(145440, 18192, 530, 0, 0, 1, 0, 0, 0, -1, 0, 0, -1487.58, 7907.99, -19.27, 5.567, 1000000, 0, 0, 10000000, 0, 0, 0, 0, 0, '', 0),
(145441, 18192, 530, 0, 0, 1, 0, 0, 0, -1, 0, 0, -1651.54, 7988.56, -26.5289, 2.98451, 1000000, 0, 0, 10000000, 0, 0, 0, 0, 0, '', 0),
(145442, 18192, 530, 0, 0, 1, 0, 0, 0, -1, 0, 0, -1602.46, 7866.43, -22.1177, 4.74729, 1000000, 0, 0, 10000000, 0, 0, 0, 0, 0, '', 0),
(145443, 18192, 530, 0, 0, 1, 0, 0, 0, -1, 0, 0, -1591.22, 7875.29, -22.3536, 4.34587, 1000000, 0, 0, 10000000, 0, 0, 0, 0, 0, '', 0),
(145444, 18192, 530, 0, 0, 1, 0, 0, 0, -1, 0, 0, -1550.6, 7944.45, -21.63, 3.559, 1000000, 0, 0, 10000000, 0, 0, 0, 0, 0, '', 0),
(145445, 18192, 530, 0, 0, 1, 0, 0, 0, -1, 0, 0, -1545.57, 7935.83, -21.13, 3.448, 1000000, 0, 0, 10000000, 0, 0, 0, 0, 0, '', 0),
(145446, 18192, 530, 0, 0, 1, 0, 0, 0, -1, 0, 0, -1550.86, 7937.56, -21.7, 3.801, 1000000, 0, 0, 10000000, 0, 0, 0, 0, 0, '', 0),
(145447, 18817, 530, 0, 0, 1, 0, 0, 0, -1, 0, 0, -1591.18, 8020.39, -22.2042, 4.59022, 1000000, 0, 0, 0, 0, 0, 0, 0, 0, '', 0),
(145448, 18822, 530, 0, 0, 1, 0, 0, 0, -1, 0, 0, -1588, 8019, -22.2042, 4.06662, 1000000, 0, 0, 0, 0, 0, 0, 0, 0, '', 0),
(145449, 21485, 530, 0, 0, 1, 0, 0, 0, -1, 0, 0, -1521.93, 7927.37, -20.2299, 3.24631, 1000000, 0, 0, 0, 0, 0, 0, 0, 0, '', 0),
(145450, 21487, 530, 0, 0, 1, 0, 0, 0, -1, 0, 0, -1540.33, 7971.95, -20.7186, 3.07178, 1000000, 0, 0, 0, 0, 0, 0, 0, 0, '', 0),
(145451, 21488, 530, 0, 0, 1, 0, 0, 0, -1, 0, 0, -1570.01, 7993.8, -22.4505, 5.02655, 1000000, 0, 0, 0, 0, 0, 0, 0, 0, '', 0),
(145452, 18256, 530, 0, 0, 1, 0, 0, 0, -1, 0, 0, -1654.06, 8000.46, -26.59, 3.37, 1000000, 0, 0, 10000000, 0, 0, 0, 0, 0, '', 0),
(145453, 18256, 530, 0, 0, 1, 0, 0, 0, -1, 0, 0, -1487.18, 7899.1, -19.53, 0.954, 1000000, 0, 0, 10000000, 0, 0, 0, 0, 0, '', 0),
(145454, 18256, 530, 0, 0, 1, 0, 0, 0, -1, 0, 0, -1480.88, 7908.79, -19.19, 4.485, 1000000, 0, 0, 10000000, 0, 0, 0, 0, 0, '', 0),
(145455, 18256, 530, 0, 0, 1, 0, 0, 0, -1, 0, 0, -1540.56, 7995.44, -20.45, 0.947, 1000000, 0, 0, 10000000, 0, 0, 0, 0, 0, '', 0),
(145456, 18256, 530, 0, 0, 1, 0, 0, 0, -1, 0, 0, -1546.95, 8000.85, -20.72, 6.035, 1000000, 0, 0, 10000000, 0, 0, 0, 0, 0, '', 0),
(145457, 18256, 530, 0, 0, 1, 0, 0, 0, -1, 0, 0, -1595.31, 7860.53, -21.51, 3.747, 1000000, 0, 0, 10000000, 0, 0, 0, 0, 0, '', 0),
(145458, 18256, 530, 0, 0, 1, 0, 0, 0, -1, 0, 0, -1642.31, 7995.59, -25.8, 3.317, 1000000, 0, 0, 10000000, 0, 0, 0, 0, 0, '', 0),
(145459, 18256, 530, 0, 0, 1, 0, 0, 0, -1, 0, 0, -1545.46, 7995.35, -20.63, 1.094, 1000000, 0, 0, 10000000, 0, 0, 0, 0, 0, '', 0),
(145460, 18256, 530, 0, 0, 1, 0, 0, 0, -1, 0, 0, -1487.58, 7907.99, -19.27, 5.567, 1000000, 0, 0, 10000000, 0, 0, 0, 0, 0, '', 0),
(145461, 18256, 530, 0, 0, 1, 0, 0, 0, -1, 0, 0, -1651.54, 7988.56, -26.5289, 2.98451, 1000000, 0, 0, 10000000, 0, 0, 0, 0, 0, '', 0),
(145462, 18256, 530, 0, 0, 1, 0, 0, 0, -1, 0, 0, -1602.46, 7866.43, -22.1177, 4.74729, 1000000, 0, 0, 10000000, 0, 0, 0, 0, 0, '', 0),
(145463, 18256, 530, 0, 0, 1, 0, 0, 0, -1, 0, 0, -1591.22, 7875.29, -22.3536, 4.34587, 1000000, 0, 0, 10000000, 0, 0, 0, 0, 0, '', 0),
(145464, 18256, 530, 0, 0, 1, 0, 0, 0, -1, 0, 0, -1603.75, 8000.36, -24.18, 4.516, 1000000, 0, 0, 10000000, 0, 0, 0, 0, 0, '', 0),
(145465, 18256, 530, 0, 0, 1, 0, 0, 0, -1, 0, 0, -1585.73, 7994.68, -23.29, 4.439, 1000000, 0, 0, 10000000, 0, 0, 0, 0, 0, '', 0),
(145466, 18256, 530, 0, 0, 1, 0, 0, 0, -1, 0, 0, -1595.5, 7991.27, -23.53, 4.738, 1000000, 0, 0, 10000000, 0, 0, 0, 0, 0, '', 0);

DELETE FROM `gameobject` WHERE `guid` BETWEEN 23273 AND 23297;
INSERT INTO `gameobject` (`guid`, `id`, `map`, `zoneId`, `areaId`, `spawnMask`, `phaseUseFlags`, `PhaseId`, `PhaseGroup`, `terrainSwapMap`, `position_x`, `position_y`, `position_z`, `orientation`, `rotation0`, `rotation1`, `rotation2`, `rotation3`, `spawntimesecs`, `animprogress`, `state`, `ScriptName`, `VerifiedBuild`) VALUES
(23273, 182210, 530, 0, 0, 1, 0, 0, 0, -1, -1572.57, 7945.3, -22.475, 2.05949, 0, 0, 0.857167, 0.515038, 0, 0, 1, '', 0),
(23274, 182267, 530, 0, 0, 1, 0, 0, 0, -1, -1815.8, 8036.51, -26.2354, -2.89725, 0, 0, 0.992546, -0.121869, 0, 0, 1, '', 0),   -- NA_ROOST_S
(23275, 182280, 530, 0, 0, 1, 0, 0, 0, -1, -1507.95, 8132.1, -19.5585, -1.3439, 0, 0, 0.622515, -0.782608, 0, 0, 1, '', 0),    -- NA_ROOST_W
(23276, 182281, 530, 0, 0, 1, 0, 0, 0, -1, -1384.52, 7779.33, -11.1663, -0.575959, 0, 0, 0.284015, -0.95882, 0, 0, 1, '', 0),  -- NA_ROOST_N
(23277, 182282, 530, 0, 0, 1, 0, 0, 0, -1, -1650.11, 7732.56, -15.4505, -2.80998, 0, 0, 0.986286, -0.165048, 0, 0, 1, '', 0),  -- NA_ROOST_E
(23278, 182222, 530, 0, 0, 1, 0, 0, 0, -1, -1825.4, 8039.26, -26.08, -2.89725, 0, 0, 0.992546, -0.121869, 0, 0, 1, '', 0),     -- NA_BOMB_WAGON_S
(23279, 182272, 530, 0, 0, 1, 0, 0, 0, -1, -1515.37, 8136.91, -20.42, -1.3439, 0, 0, 0.622515, -0.782608, 0, 0, 1, '', 0),     -- NA_BOMB_WAGON_W
(23280, 182273, 530, 0, 0, 1, 0, 0, 0, -1, -1377.95, 7773.44, -10.31, -0.575959, 0, 0, 0.284015, -0.95882, 0, 0, 1, '', 0),    -- NA_BOMB_WAGON_N
(23281, 182274, 530, 0, 0, 1, 0, 0, 0, -1, -1659.87, 7733.15, -15.75, -2.80998, 0, 0, 0.986286, -0.165048, 0, 0, 1, '', 0),    -- NA_BOMB_WAGON_E
(23282, 182266, 530, 0, 0, 1, 0, 0, 0, -1, -1815.8, 8036.51, -26.2354, -2.89725, 0, 0, 0.992546, -0.121869, 0, 0, 1, '', 0),   -- NA_DESTROYED_ROOST_S
(23283, 182275, 530, 0, 0, 1, 0, 0, 0, -1, -1507.95, 8132.1, -19.5585, -1.3439, 0, 0, 0.622515, -0.782608, 0, 0, 1, '', 0),    -- NA_DESTROYED_ROOST_W
(23284, 182276, 530, 0, 0, 1, 0, 0, 0, -1, -1384.52, 7779.33, -11.1663, -0.575959, 0, 0, 0.284015, -0.95882, 0, 0, 1, '', 0),  -- NA_DESTROYED_ROOST_N
(23285, 182277, 530, 0, 0, 1, 0, 0, 0, -1, -1650.11, 7732.56, -15.4505, -2.80998, 0, 0, 0.986286, -0.165048, 0, 0, 1, '', 0),  -- NA_DESTROYED_ROOST_E
(23286, 182301, 530, 0, 0, 1, 0, 0, 0, -1, -1815.8, 8036.51, -26.2354, -2.89725, 0, 0, 0.992546, -0.121869, 0, 0, 1, '', 0),   -- NA_ROOST_S
(23287, 182302, 530, 0, 0, 1, 0, 0, 0, -1, -1507.95, 8132.1, -19.5585, -1.3439, 0, 0, 0.622515, -0.782608, 0, 0, 1, '', 0),    -- NA_ROOST_W
(23288, 182303, 530, 0, 0, 1, 0, 0, 0, -1, -1384.52, 7779.33, -11.1663, -0.575959, 0, 0, 0.284015, -0.95882, 0, 0, 1, '', 0),  -- NA_ROOST_N
(23289, 182304, 530, 0, 0, 1, 0, 0, 0, -1, -1650.11, 7732.56, -15.4505, -2.80998, 0, 0, 0.986286, -0.165048, 0, 0, 1, '', 0),  -- NA_ROOST_E
(23290, 182305, 530, 0, 0, 1, 0, 0, 0, -1, -1825.4, 8039.26, -26.08, -2.89725, 0, 0, 0.992546, -0.121869, 0, 0, 1, '', 0),     -- NA_BOMB_WAGON_S
(23291, 182306, 530, 0, 0, 1, 0, 0, 0, -1, -1515.37, 8136.91, -20.42, -1.3439, 0, 0, 0.622515, -0.782608, 0, 0, 1, '', 0),     -- NA_BOMB_WAGON_W
(23292, 182307, 530, 0, 0, 1, 0, 0, 0, -1, -1377.95, 7773.44, -10.31, -0.575959, 0, 0, 0.284015, -0.95882, 0, 0, 1, '', 0),    -- NA_BOMB_WAGON_N
(23293, 182308, 530, 0, 0, 1, 0, 0, 0, -1, -1659.87, 7733.15, -15.75, -2.80998, 0, 0, 0.986286, -0.165048, 0, 0, 1, '', 0),    -- NA_BOMB_WAGON_E
(23294, 182297, 530, 0, 0, 1, 0, 0, 0, -1, -1815.8, 8036.51, -26.2354, -2.89725, 0, 0, 0.992546, -0.121869, 0, 0, 1, '', 0),   -- NA_DESTROYED_ROOST_S
(23295, 182298, 530, 0, 0, 1, 0, 0, 0, -1, -1507.95, 8132.1, -19.5585, -1.3439, 0, 0, 0.622515, -0.782608, 0, 0, 1, '', 0),    -- NA_DESTROYED_ROOST_W
(23296, 182299, 530, 0, 0, 1, 0, 0, 0, -1, -1384.52, 7779.33, -11.1663, -0.575959, 0, 0, 0.284015, -0.95882, 0, 0, 1, '', 0),  -- NA_DESTROYED_ROOST_N
(23297, 182300, 530, 0, 0, 1, 0, 0, 0, -1, -1650.11, 7732.56, -15.4505, -2.80998, 0, 0, 0.986286, -0.165048, 0, 0, 1, '', 0);  -- NA_DESTROYED_ROOST_E

UPDATE `gameobject_template_addon` SET `flags`=0x20 WHERE `entry` IN (182266,182275,182276,182277,182297,182298,182299,182300,182222,182272,182273,182274,182305,182306,182307,182308);

DELETE FROM `spawn_group` WHERE `spawnId` BETWEEN 145427 AND 145466 AND `spawnType`=0;
DELETE FROM `spawn_group` WHERE `spawnId` BETWEEN 23273 AND 23297 AND `spawnType`=1;
INSERT INTO `spawn_group` (`groupId`,`spawnType`,`spawnId`) VALUES
(105,0,145427),
(105,0,145428),
(105,0,145429),
(105,0,145430),
(105,0,145431),
(123,0,145432),
(123,0,145433),
(123,0,145434),
(123,0,145435),
(123,0,145436),
(123,0,145437),
(123,0,145438),
(123,0,145439),
(123,0,145440),
(123,0,145441),
(123,0,145442),
(123,0,145443),
(123,0,145444),
(123,0,145445),
(123,0,145446),
(106,0,145447),
(106,0,145448),
(106,0,145449),
(106,0,145450),
(106,0,145451),
(124,0,145452),
(124,0,145453),
(124,0,145454),
(124,0,145455),
(124,0,145456),
(124,0,145457),
(124,0,145458),
(124,0,145459),
(124,0,145460),
(124,0,145461),
(124,0,145462),
(124,0,145463),
(124,0,145464),
(124,0,145465),
(124,0,145466),
(122,1,23274),
(118,1,23275),
(114,1,23276),
(110,1,23277),
(122,1,23278),
(118,1,23279),
(114,1,23280),
(110,1,23281),
(120,1,23282),
(116,1,23283),
(112,1,23284),
(108,1,23285),
(121,1,23286),
(117,1,23287),
(113,1,23288),
(109,1,23289),
(121,1,23290),
(117,1,23291),
(113,1,23292),
(109,1,23293),
(119,1,23294),
(115,1,23295),
(111,1,23296),
(107,1,23297);

DELETE FROM `conditions` WHERE `SourceTypeOrReferenceId`=33 AND `SourceEntry` BETWEEN 105 AND 124;
INSERT INTO `conditions` (`SourceTypeOrReferenceId`, `SourceGroup`, `SourceEntry`, `SourceId`, `ElseGroup`, `ConditionTypeOrReference`, `ConditionTarget`, `ConditionValue1`, `ConditionValue2`, `ConditionValue3`, `NegativeCondition`, `ErrorType`, `ErrorTextId`, `ScriptName`, `Comment`) VALUES
(33, 0, 105, 0, 0, 11, 0, 2672, 1, 0, 0, 0, 0, '', 'Halaa - Spawn Horde NPCs when Horde controls it'),
(33, 0, 106, 0, 0, 11, 0, 2673, 1, 0, 0, 0, 0, '', 'Halaa - Spawn Alliance NPCs when Alliance controls it'),
(33, 0, 107, 0, 0, 11, 0, 2763, 1, 0, 0, 0, 0, '', 'Halaa - Wyvern Camp (East) - Horde Uncontrolled'),
(33, 0, 108, 0, 0, 11, 0, 2659, 1, 0, 0, 0, 0, '', 'Halaa - Wyvern Camp (East) - Alliance Uncontrolled'),
(33, 0, 109, 0, 0, 11, 0, 2660, 1, 0, 0, 0, 0, '', 'Halaa - Wyvern Camp (East) - Horde Controlled'),
(33, 0, 110, 0, 0, 11, 0, 2661, 1, 0, 0, 0, 0, '', 'Halaa - Wyvern Camp (East) - Alliance Controlled'),
(33, 0, 111, 0, 0, 11, 0, 2762, 1, 0, 0, 0, 0, '', 'Halaa - Wyvern Camp (North) - Horde Uncontrolled'),
(33, 0, 112, 0, 0, 11, 0, 2662, 1, 0, 0, 0, 0, '', 'Halaa - Wyvern Camp (North) - Alliance Uncontrolled'),
(33, 0, 113, 0, 0, 11, 0, 2663, 1, 0, 0, 0, 0, '', 'Halaa - Wyvern Camp (North) - Horde Controlled'),
(33, 0, 114, 0, 0, 11, 0, 2664, 1, 0, 0, 0, 0, '', 'Halaa - Wyvern Camp (North) - Alliance Controlled'),
(33, 0, 115, 0, 0, 11, 0, 2761, 1, 0, 0, 0, 0, '', 'Halaa - Wyvern Camp (West) - Horde Uncontrolled'),
(33, 0, 116, 0, 0, 11, 0, 2667, 1, 0, 0, 0, 0, '', 'Halaa - Wyvern Camp (West) - Alliance Uncontrolled'),
(33, 0, 117, 0, 0, 11, 0, 2665, 1, 0, 0, 0, 0, '', 'Halaa - Wyvern Camp (West) - Horde Controlled'),
(33, 0, 118, 0, 0, 11, 0, 2666, 1, 0, 0, 0, 0, '', 'Halaa - Wyvern Camp (West) - Alliance Controlled'),
(33, 0, 119, 0, 0, 11, 0, 2760, 1, 0, 0, 0, 0, '', 'Halaa - Wyvern Camp (South) - Horde Uncontrolled'),
(33, 0, 120, 0, 0, 11, 0, 2670, 1, 0, 0, 0, 0, '', 'Halaa - Wyvern Camp (South) - Alliance Uncontrolled'),
(33, 0, 121, 0, 0, 11, 0, 2668, 1, 0, 0, 0, 0, '', 'Halaa - Wyvern Camp (South) - Horde Controlled'),
(33, 0, 122, 0, 0, 11, 0, 2669, 1, 0, 0, 0, 0, '', 'Halaa - Wyvern Camp (South) - Alliance Controlled'),
(33, 0, 123, 0, 0, 11, 0, 2672, 1, 0, 0, 0, 0, '', 'Halaa - Spawn Horde guards when Horde controls it'),
(33, 0, 124, 0, 0, 11, 0, 2673, 1, 0, 0, 0, 0, '', 'Halaa - Spawn Alliance guards when Alliance controls it');
DELETE FROM `spawn_group_template` WHERE `groupId` BETWEEN 125 AND 127;
INSERT INTO `spawn_group_template` (`groupId`,`groupName`,`groupFlags`) VALUES
(125,'Zangarmarsh - Twinspire Graveyard',32),
(126,'Zangarmarsh - Twinspire Graveyard - Alliance Controlled',32),
(127,'Zangarmarsh - Twinspire Graveyard - Horde Controlled',32);

DELETE FROM `creature` WHERE `guid` IN (12529,12530);
DELETE FROM `creature_addon` WHERE `guid` IN (12529,12530);
INSERT INTO `creature` (`guid`, `id`, `map`, `zoneId`, `areaId`, `spawnMask`, `phaseUseFlags`, `PhaseId`, `PhaseGroup`, `terrainSwapMap`, `modelid`, `equipment_id`, `position_x`, `position_y`, `position_z`, `orientation`, `spawntimesecs`, `wander_distance`, `currentwaypoint`, `curhealth`, `curmana`, `MovementType`, `npcflag`, `unit_flags`, `dynamicflags`, `ScriptName`, `VerifiedBuild`) VALUES
(12529, 18564, 530, 0, 0, 1, 0, 0, 0, -1, 0, 0, 296.625, 7818.4, 42.6294, 5.18363, 1000000, 0, 0, 0, 0, 0, 0, 0, 0, '', 0),
(12530, 18581, 530, 0, 0, 1, 0, 0, 0, -1, 0, 0, 374.395, 6230.08, 22.8351, 0.593412, 1000000, 0, 0, 0, 0, 0, 0, 0, 0, '', 0);

DELETE FROM `gameobject` WHERE `guid`=22991 AND `id`=182527;
DELETE FROM `gameobject` WHERE `guid` BETWEEN 23298 AND 23302;
INSERT INTO `gameobject` (`guid`, `id`, `map`, `zoneId`, `areaId`, `spawnMask`, `phaseUseFlags`, `PhaseId`, `PhaseGroup`, `terrainSwapMap`, `position_x`, `position_y`, `position_z`, `orientation`, `rotation0`, `rotation1`, `rotation2`, `rotation3`, `spawntimesecs`, `animprogress`, `state`, `ScriptName`, `VerifiedBuild`) VALUES
(23298, 182529, 530, 0, 0, 1, 0, 0, 0, -1, 253.54, 7083.81, 36.7728, -0.017453, 0, 0, 0.008727, -0.999962, 0, 0, 1, '', 0),
(23299, 182527, 530, 0, 0, 1, 0, 0, 0, -1, 253.54, 7083.81, 36.7728, -0.017453, 0, 0, 0.008727, -0.999962, 0, 0, 1, '', 0),
(23300, 182528, 530, 0, 0, 1, 0, 0, 0, -1, 253.54, 7083.81, 36.7728, -0.017453, 0, 0, 0.008727, -0.999962, 0, 0, 1, '', 0),
(23301, 182523, 530, 0, 0, 1, 0, 0, 0, -1, 303.243, 6841.36, 40.1245, -1.58825, 0, 0, 0.71325, -0.700909, 0, 0, 1, '', 0),
(23302, 182522, 530, 0, 0, 1, 0, 0, 0, -1, 336.466, 7340.26, 41.4984, -1.58825, 0, 0, 0.71325, -0.700909, 0, 0, 1, '', 0);

DELETE FROM `spawn_group` WHERE `spawnId` BETWEEN 23298 AND 23300 AND `spawnType`=1;
INSERT INTO `spawn_group` (`groupId`,`spawnType`,`spawnId`) VALUES
(125,1,23298),
(126,1,23299),
(127,1,23300);

DELETE FROM `conditions` WHERE `SourceTypeOrReferenceId`=33 AND `SourceEntry` BETWEEN 125 AND 127;
INSERT INTO `conditions` (`SourceTypeOrReferenceId`, `SourceGroup`, `SourceEntry`, `SourceId`, `ElseGroup`, `ConditionTypeOrReference`, `ConditionTarget`, `ConditionValue1`, `ConditionValue2`, `ConditionValue3`, `NegativeCondition`, `ErrorType`, `ErrorTextId`, `ScriptName`, `Comment`) VALUES
(33, 0, 125, 0, 0, 11, 0, 2647, 1, 0, 0, 0, 0, '', 'Zangarmarsh - Twinspire Graveyard neutral'),
(33, 0, 126, 0, 0, 11, 0, 2648, 1, 0, 0, 0, 0, '', 'Zangarmarsh - Twinspire Graveyard - Alliance Controlled'),
(33, 0, 127, 0, 0, 11, 0, 2649, 1, 0, 0, 0, 0, '', 'Zangarmarsh - Twinspire Graveyard - Horde Controlled');
DELETE FROM `gameobject` WHERE `guid` BETWEEN 23303 AND 23313;
INSERT INTO `gameobject` (`guid`, `id`, `map`, `zoneId`, `areaId`, `spawnMask`, `phaseUseFlags`, `PhaseId`, `PhaseGroup`, `terrainSwapMap`, `position_x`, `position_y`, `position_z`, `orientation`, `rotation0`, `rotation1`, `rotation2`, `rotation3`, `spawntimesecs`, `animprogress`, `state`, `ScriptName`, `VerifiedBuild`) VALUES
(23303, 183104, 530, 0, 0, 1, 0, 0, 0, -1, -3081.65, 5335.03, 17.1853, -2.146750, 0, 0, 0.878817, -0.477159, 0, 0, 1, '', 0),
(23304, 183411, 530, 0, 0, 1, 0, 0, 0, -1, -2939.90, 4788.73, 18.9870, 2.775070, 0, 0, 0.983255, 0.182236, 0, 0, 1, '', 0),
(23305, 183412, 530, 0, 0, 1, 0, 0, 0, -1, -3174.94, 4440.97, 16.2281, 1.867500, 0, 0, 0.803857, 0.594823, 0, 0, 1, '', 0),
(23306, 183413, 530, 0, 0, 1, 0, 0, 0, -1, -3603.31, 4529.15, 20.9077, 0.994838, 0, 0, 0.477159, 0.878817, 0, 0, 1, '', 0),
(23307, 183414, 530, 0, 0, 1, 0, 0, 0, -1, -3812.37, 4899.30, 17.7249, 0.087266, 0, 0, 0.043619, 0.999048, 0, 0, 1, '', 0),
(23308, 182175, 530, 0, 0, 1, 0, 0, 0, -1, -471.462, 3451.09, 34.6432, 0.174533, 0, 0, 0.087156, 0.996195, 0, 0, 1, '', 0),
(23309, 182174, 530, 0, 0, 1, 0, 0, 0, -1, -184.889, 3476.93, 38.2050, -0.017453, 0, 0, 0.008727, -0.999962, 0, 0, 1, '', 0),
(23310, 182173, 530, 0, 0, 1, 0, 0, 0, -1, -290.016, 3702.42, 56.6729, 0.034907, 0, 0, 0.017452, 0.999848, 0, 0, 1, '', 0),
(23311, 183514, 530, 0, 0, 1, 0, 0, 0, -1, -467.078, 3528.17, 64.7121, 3.14159, 0, 0, 1.000000, 0.000000, 0, 0, 1, '', 0),
(23312, 182525, 530, 0, 0, 1, 0, 0, 0, -1, -187.887, 3459.38, 60.0403, -3.12414, 0, 0, 0.999962, -0.008727, 0, 0, 1, '', 0),
(23313, 183515, 530, 0, 0, 1, 0, 0, 0, -1, -289.610, 3696.83, 75.9447, 3.12414, 0, 0, 0.999962, 0.008727, 0, 0, 1, '', 0);
DELETE FROM `spell_script_names` WHERE `ScriptName`= 'spell_item_obsidian_armor';
INSERT INTO `spell_script_names` (`spell_id`, `ScriptName`) VALUES
(27539, 'spell_item_obsidian_armor');

DELETE FROM `spell_proc` WHERE `SpellId`= 27539;
INSERT INTO `spell_proc` (`SpellId`, `SpellTypeMask`, `Cooldown`) VALUES
(27539, 0x1, 10000); -- 10s cooldown
