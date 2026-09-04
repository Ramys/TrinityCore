-- ============================================================================
-- Dragon Soul: Hagara the Stormbinder 55689 - ScriptName + SpellScript + Spawn + Loot
-- Refs: boss_hagara.cpp (DragonSoul::Hagara), dragon_soul.h, instance_dragon_soul.cpp
--       SoundEntries.dbc 20874 recs (VO_DS_HAGARA_* 26190-26257 validado)
--       Spell.dbc 73253 recs FC=48 (38 IDs validados OK, 2x DoCast fix)
--       sql/old/4.3.4/.../2016_09_06_02_world.sql difficulty_entry 57462/57955/57956
--       sql/old/4.3.4/.../2016_10_09_02_world.sql creature_loot_template 55689 ~77 rows
-- Gate: Hagara 4o boss DS so apos Yor'sahj 55312 DONE (CheckRequiredBosses -> Evade)
-- Apply AFTER base Cataclysm Preservation Project.
-- ============================================================================

-- AUTO-FIX 1054: garante schema final antes dos INSERTs (idempotente, compat TDB root 2022 e DB migrado)
SET @has_spawndist := (SELECT COUNT(*) FROM INFORMATION_SCHEMA.COLUMNS WHERE TABLE_SCHEMA=DATABASE() AND TABLE_NAME='creature' AND COLUMN_NAME='spawndist');
SET @has_wander := (SELECT COUNT(*) FROM INFORMATION_SCHEMA.COLUMNS WHERE TABLE_SCHEMA=DATABASE() AND TABLE_NAME='creature' AND COLUMN_NAME='wander_distance');
SET @sql := IF(@has_spawndist=1 AND @has_wander=0, 'ALTER TABLE `creature` CHANGE COLUMN `spawndist` `wander_distance` FLOAT NOT NULL DEFAULT 0', 'SELECT 1');
PREPARE stmt FROM @sql; EXECUTE stmt; DEALLOCATE PREPARE stmt;
SET @has_dyn := (SELECT COUNT(*) FROM INFORMATION_SCHEMA.COLUMNS WHERE TABLE_SCHEMA=DATABASE() AND TABLE_NAME='creature' AND COLUMN_NAME='dynamicflags');
SET @sql := IF(@has_dyn=1, 'ALTER TABLE `creature` DROP COLUMN `dynamicflags`', 'SELECT 1');
PREPARE stmt FROM @sql; EXECUTE stmt; DEALLOCATE PREPARE stmt;
SET @has_optidx := (SELECT COUNT(*) FROM INFORMATION_SCHEMA.COLUMNS WHERE TABLE_SCHEMA=DATABASE() AND TABLE_NAME='gossip_menu_option' AND COLUMN_NAME='OptionIndex');
SET @sql := IF(@has_optidx=1, 'ALTER TABLE `gossip_menu_option` CHANGE `MenuId` `MenuID` int(10) unsigned NOT NULL DEFAULT 0', 'SELECT 1');
PREPARE stmt FROM @sql; EXECUTE stmt; DEALLOCATE PREPARE stmt;
SET @sql := IF(@has_optidx=1, 'ALTER TABLE `gossip_menu_option` CHANGE `OptionIndex` `OptionID` int(10) unsigned NOT NULL DEFAULT 0', 'SELECT 1');
PREPARE stmt FROM @sql; EXECUTE stmt; DEALLOCATE PREPARE stmt;
SET @has_bcid_old := (SELECT COUNT(*) FROM INFORMATION_SCHEMA.COLUMNS WHERE TABLE_SCHEMA=DATABASE() AND TABLE_NAME='gossip_menu_option' AND COLUMN_NAME='OptionBroadcastTextId');
SET @sql := IF(@has_bcid_old=1, 'ALTER TABLE `gossip_menu_option` CHANGE `OptionBroadcastTextId` `OptionBroadcastTextID` int(10) unsigned NOT NULL DEFAULT 0', 'SELECT 1');
PREPARE stmt FROM @sql; EXECUTE stmt; DEALLOCATE PREPARE stmt;
SET @has_action := (SELECT COUNT(*) FROM INFORMATION_SCHEMA.COLUMNS WHERE TABLE_SCHEMA=DATABASE() AND TABLE_NAME='gossip_menu_option' AND COLUMN_NAME='ActionMenuID');
SET @sql := IF(@has_action=0, 'ALTER TABLE `gossip_menu_option` ADD `ActionMenuID` int(10) unsigned NOT NULL DEFAULT 0 AFTER `OptionNpcFlag`', 'SELECT 1');
PREPARE stmt FROM @sql; EXECUTE stmt; DEALLOCATE PREPARE stmt;
SET @has_apoi := (SELECT COUNT(*) FROM INFORMATION_SCHEMA.COLUMNS WHERE TABLE_SCHEMA=DATABASE() AND TABLE_NAME='gossip_menu_option' AND COLUMN_NAME='ActionPoiID');
SET @sql := IF(@has_apoi=0, 'ALTER TABLE `gossip_menu_option` ADD `ActionPoiID` int(10) unsigned NOT NULL DEFAULT 0 AFTER `ActionMenuID`', 'SELECT 1');
PREPARE stmt FROM @sql; EXECUTE stmt; DEALLOCATE PREPARE stmt;
SET @has_boxcoded := (SELECT COUNT(*) FROM INFORMATION_SCHEMA.COLUMNS WHERE TABLE_SCHEMA=DATABASE() AND TABLE_NAME='gossip_menu_option' AND COLUMN_NAME='BoxCoded');
SET @sql := IF(@has_boxcoded=0, 'ALTER TABLE `gossip_menu_option` ADD `BoxCoded` tinyint(3) unsigned NOT NULL DEFAULT 0 AFTER `ActionPoiID`', 'SELECT 1');
PREPARE stmt FROM @sql; EXECUTE stmt; DEALLOCATE PREPARE stmt;
SET @has_boxmoney := (SELECT COUNT(*) FROM INFORMATION_SCHEMA.COLUMNS WHERE TABLE_SCHEMA=DATABASE() AND TABLE_NAME='gossip_menu_option' AND COLUMN_NAME='BoxMoney');
SET @sql := IF(@has_boxmoney=0, 'ALTER TABLE `gossip_menu_option` ADD `BoxMoney` int(10) unsigned NOT NULL DEFAULT 0 AFTER `BoxCoded`', 'SELECT 1');
PREPARE stmt FROM @sql; EXECUTE stmt; DEALLOCATE PREPARE stmt;
SET @has_boxtext := (SELECT COUNT(*) FROM INFORMATION_SCHEMA.COLUMNS WHERE TABLE_SCHEMA=DATABASE() AND TABLE_NAME='gossip_menu_option' AND COLUMN_NAME='BoxText');
SET @sql := IF(@has_boxtext=0, 'ALTER TABLE `gossip_menu_option` ADD `BoxText` mediumtext AFTER `BoxMoney`', 'SELECT 1');
PREPARE stmt FROM @sql; EXECUTE stmt; DEALLOCATE PREPARE stmt;
SET @has_boxbtid := (SELECT COUNT(*) FROM INFORMATION_SCHEMA.COLUMNS WHERE TABLE_SCHEMA=DATABASE() AND TABLE_NAME='gossip_menu_option' AND COLUMN_NAME='BoxBroadcastTextID');
SET @sql := IF(@has_boxbtid=0, 'ALTER TABLE `gossip_menu_option` ADD `BoxBroadcastTextID` int(10) unsigned NOT NULL DEFAULT 0 AFTER `BoxText`', 'SELECT 1');
PREPARE stmt FROM @sql; EXECUTE stmt; DEALLOCATE PREPARE stmt;


-- 1) ScriptName boss + difficulties (lootid herdado, ScriptName replica para entry dificuldade)
UPDATE `creature_template` SET `ScriptName`='boss_hagara_the_stormbinder' WHERE `entry`=55689;
UPDATE `creature_template` SET `ScriptName`='boss_hagara_the_stormbinder' WHERE `entry` IN (57462,57955,57956) AND (`ScriptName` IS NULL OR `ScriptName`='');

-- Replica lootid Boss para difficulties (mesmo padrao do 2026_09_03_00 loot fix do Morchok)
UPDATE `creature_template` SET `lootid`=55689 WHERE `entry` IN (57462,57955,57956) AND (`lootid` IS NULL OR `lootid`=0 OR `lootid` != 55689);

-- Adds (template deve existir na base CPP, apenas vincula AI)
UPDATE `creature_template` SET `ScriptName`='npc_hagara_the_stormbinder_frozen_binding_crystal' WHERE `entry`=56136;
UPDATE `creature_template` SET `ScriptName`='npc_hagara_the_stormbinder_ice_wave' WHERE `entry`=56104;
UPDATE `creature_template` SET `ScriptName`='npc_hagara_the_stormbinder_ice_lance' WHERE `entry`=56108;
UPDATE `creature_template` SET `ScriptName`='npc_hagara_the_stormbinder_icy_tomb' WHERE `entry`=55695;
UPDATE `creature_template` SET `ScriptName`='npc_hagara_the_stormbinder_collapsing_icicle' WHERE `entry`=57867;
UPDATE `creature_template` SET `ScriptName`='npc_hagara_the_stormbinder_crystal_conductor' WHERE `entry`=56165;
UPDATE `creature_template` SET `ScriptName`='npc_hagara_the_stormbinder_bound_lightning_elemental' WHERE `entry`=56700;
UPDATE `creature_template` SET `ScriptName`='npc_hagara_the_stormbinder_bound_lightning_elemental' WHERE `entry` IN (57463,58250,58251) AND (`ScriptName` IS NULL OR `ScriptName`='');

-- Limpa vinculos errados (evita AI fantasma em adds de outros bosses)
UPDATE `creature_template` SET `ScriptName`='' WHERE `entry` IN (55334,55416,55417,55418,55346,57773,55265,55312) AND `ScriptName` LIKE 'npc_hagara%';

-- 2) Spell scripts (boss_hagara.cpp: 104448/104449 SpellScript, 104451/105367 AuraScript)
DELETE FROM `spell_script_names` WHERE `spell_id` IN (104448,104449,104451,105367);
INSERT INTO `spell_script_names` (`spell_id`,`ScriptName`) VALUES
(104448,'spell_hagara_the_stormbinder_icy_tomb_aoe'),
(104449,'spell_hagara_the_stormbinder_icy_tomb_dummy'),
(104451,'spell_hagara_the_stormbinder_icy_tomb'),
(105367,'spell_hagara_the_stormbinder_lightning_conduit');

-- 3) Spawn map 967 (Eye of Eternity / Dragon Soul) - sempre presente, gate via C++ Evade
-- Dev schema creature (world_database.sql): guid,id,map,zoneId,areaId,spawnMask,phaseUseFlags,phaseMask,PhaseId,PhaseGroup,terrainSwapMap,modelid,equipment_id,...
INSERT INTO `creature` (`guid`,`id`,`map`,`zoneId`,`areaId`,`spawnMask`,`phaseUseFlags`,`phaseMask`,`PhaseId`,`PhaseGroup`,`terrainSwapMap`,`modelid`,`equipment_id`,`position_x`,`position_y`,`position_z`,`orientation`,`spawntimesecs`,`wander_distance`,`currentwaypoint`,`curhealth`,`curmana`,`MovementType`,`npcflag`,`unit_flags`,`ScriptName`,`VerifiedBuild`)
SELECT 900003,55689,967,0,0,15,0,1,0,0,-1,0,0,13587.4,13612.0,122.43,5.93,120,0,0,42000000,0,0,0, 0, '',15595 FROM DUAL WHERE NOT EXISTS (SELECT 1 FROM `creature` WHERE `id`=55689 AND `map`=967);
UPDATE `creature` SET `spawnMask`=15 WHERE `id`=55689 AND `map`=967;
UPDATE `creature` SET `spawnMask`=15 WHERE `id` IN (56136,56104,56108,55695,57867,56165,56700) AND `map`=967;

-- Hagara texts - GroupID deve bater com enum ScriptedTexts boss_hagara.cpp
-- SAY_AGGRO=0 SAY_DEATH=1 SAY_ICE_WAVE=2 SAY_ICELANCE=3 SAY_ICETOMB=4 SAY_CRYSTAL=5 SAY_LIGHTNING=6 SAY_OVERLOAD=7 SAY_FEEDBACK=8 SAY_KILL=9 ANN_OVERLOAD=10
-- SoundEntries.dbc validado: 26227 AGGRO_01, 26243 DEATH_01, 26247/26248 GLACIER, 26244-26246 FROSTRAY, 26249/26250 ICETOMB, 26235-26241 CRYSTALDEAD, 26252/26253 LIGHTNING, 26228-26234 CIRCUIT, 26254-26257 SLAY
-- Quotes warcraft.wiki Hagara_the_Stormbinder

DELETE FROM `creature_text` WHERE `CreatureID`=55689;
INSERT INTO `creature_text` (`CreatureID`,`GroupID`,`ID`,`Text`,`Type`,`Language`,`Probability`,`Emote`,`Duration`,`Sound`,`SoundType`,`BroadcastTextId`,`TextRange`,`comment`) VALUES
(55689,0,0,'You cross the Stormbinder! I''ll slaughter you all.',14,0,100,0,0,26227,0,0,0,'Hagara SAY_AGGRO VO_DS_HAGARA_AGGRO_01'),
(55689,1,0,'Cowards! You pack of weakling...dogs...',14,0,100,0,0,26243,0,0,0,'Hagara SAY_DEATH VO_DS_HAGARA_DEATH_01'),
(55689,2,0,'You can''t outrun the storm.',14,0,50,0,0,26247,0,0,0,'Hagara SAY_ICE_WAVE GLACIER_01'),
(55689,2,1,'Die beneath the ice.',14,0,50,0,0,26248,0,0,0,'Hagara SAY_ICE_WAVE GLACIER_02'),
(55689,3,0,'You face more than my axes, this close.',14,0,34,0,0,26244,0,0,0,'Hagara SAY_ICELANCE FROSTRAY_01'),
(55689,3,1,'See what becomes of those who stand before me!',14,0,33,0,0,26245,0,0,0,'Hagara SAY_ICELANCE FROSTRAY_02'),
(55689,3,2,'Feel a chill up your spine...?',14,0,33,0,0,26246,0,0,0,'Hagara SAY_ICELANCE FROSTRAY_03'),
(55689,4,0,'Stay, pup.',14,0,50,0,0,26249,0,0,0,'Hagara SAY_ICETOMB ICETOMB_01'),
(55689,4,1,'Hold still.',14,0,50,0,0,26250,0,0,0,'Hagara SAY_ICETOMB ICETOMB_02'),
(55689,5,0,'The time I spent binding that, WASTED!',14,0,15,0,0,26235,0,0,0,'Hagara SAY_CRYSTAL CRYSTALDEAD_01'),
(55689,5,1,'You''ll PAY for that.',14,0,14,0,0,26236,0,0,0,'Hagara SAY_CRYSTAL CRYSTALDEAD_02'),
(55689,5,2,'Enough!',14,0,14,0,0,26237,0,0,0,'Hagara SAY_CRYSTAL CRYSTALDEAD_03'),
(55689,5,3,'Again?!',14,0,14,0,0,26238,0,0,0,'Hagara SAY_CRYSTAL CRYSTALDEAD_04'),
(55689,5,4,'Impudent pup!',14,0,14,0,0,26239,0,0,0,'Hagara SAY_CRYSTAL CRYSTALDEAD_05'),
(55689,5,5,'You dare?!',14,0,14,0,0,26240,0,0,0,'Hagara SAY_CRYSTAL CRYSTALDEAD_06'),
(55689,5,6,'The one remaining is still enough to finish you.',14,0,15,0,0,26241,0,0,0,'Hagara SAY_CRYSTAL CRYSTALDEAD_07'),
(55689,6,0,'Suffer the storm''s wrath!',14,0,50,0,0,26252,0,0,0,'Hagara SAY_LIGHTNING LIGHTNING_01'),
(55689,6,1,'Thunder and lightning dance at my call!',14,0,50,0,0,26253,0,0,0,'Hagara SAY_LIGHTNING LIGHTNING_02'),
(55689,7,0,'What are you doing?',14,0,15,0,0,26228,0,0,0,'Hagara SAY_OVERLOAD CIRCUIT_01'),
(55689,7,1,'You''re toying with death.',14,0,14,0,0,26229,0,0,0,'Hagara SAY_OVERLOAD CIRCUIT_02'),
(55689,7,2,'You think you can play with my lightning?',14,0,14,0,0,26230,0,0,0,'Hagara SAY_OVERLOAD CIRCUIT_03'),
(55689,7,3,'No!',14,0,14,0,0,26231,0,0,0,'Hagara SAY_OVERLOAD CIRCUIT_04'),
(55689,7,4,'More... lightning...',14,0,14,0,0,26233,0,0,0,'Hagara SAY_OVERLOAD CIRCUIT_05'),
(55689,7,5,'Enough of your games!',14,0,14,0,0,26232,0,0,0,'Hagara SAY_OVERLOAD CIRCUIT_06'),
(55689,7,6,'You won''t live to do it again.',14,0,15,0,0,26234,0,0,0,'Hagara SAY_OVERLOAD CIRCUIT_07'),
(55689,8,0,'Aughhhh! Impossible!',14,0,100,0,0,0,0,0,'Hagara SAY_FEEDBACK phase end'),
(55689,9,0,'You should have run, dog!',14,0,25,0,0,26255,0,0,0,'Hagara SAY_KILL SLAY_01'),
(55689,9,1,'Feh! Down, pup.',14,0,25,0,0,26254,0,0,0,'Hagara SAY_KILL SLAY_02'),
(55689,9,2,'A waste of my time.',14,0,25,0,0,26256,0,0,0,'Hagara SAY_KILL SLAY_03'),
(55689,9,3,'Pathetic.',14,0,25,0,0,26257,0,0,0,'Hagara SAY_KILL SLAY_04'),
(55689,10,0,'%s begins to overload!',16,0,100,0,0,0,0,0,'Hagara ANN_OVERLOAD emote');