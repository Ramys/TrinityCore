-- =========================================================
-- Dragon Soul: Darkhound taxi drakes (Valeera 57289, Eiendormi 57288)
-- Port do mecanismo do 5.4.8 (dragon_soul.cpp) para 4.3.4.
--   Mecanica: gossip teleport (NearTeleportTo) p/ arena do boss.
--   Valeera   -> Zon'ozz  ({-1743.6478, -1835.1325, -220.509, 4.53})
--   Eiendormi -> Yor'sahj ({-1854.2331, -3068.6586, -178.339, 0.46})
--   Gating: drake so abre gossip quando boss de destino liberado
--           (CheckRequiredBosses, em instance_dragon_soul.cpp).
-- Script: dragon_soul.cpp :: npc_dragon_soul_teleport (AddSC_dragon_soul)
-- Apply AFTER world database is loaded (The-Cataclysm-Preservation-Project base).
-- =========================================================

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


-- 1) ScriptName + GOSSIP npcflag (0x1) nos drakes
UPDATE `creature_template` SET `ScriptName` = 'npc_dragon_soul_teleport', `npcflag` = `npcflag` | 1 WHERE `entry` IN (57288, 57289);

-- 2) Texto do menu gossip (TextID 100000)
DELETE FROM `npc_text` WHERE `ID` = 100000;
INSERT INTO `npc_text` (`ID`, `text0_0`, `text0_1`, `BroadcastTextID0`, `lang0`, `Probability0`, `EmoteDelay0_0`, `Emote0_0`, `EmoteDelay0_1`, `Emote0_1`, `EmoteDelay0_2`, `Emote0_2`) VALUES
(100000, 'The darkhound awaits. Shall I fly you to the battle below?', '', 0, 0, 100, 0, 0, 0, 0, 0, 0);

-- 3) gossip_menu ligando MenuID 13411 ao texto
DELETE FROM `gossip_menu` WHERE `MenuID` = 13411;
INSERT INTO `gossip_menu` (`MenuID`, `TextID`, `VerifiedBuild`) VALUES
(13411, 100000, 0);

-- 4) Opcao -> dispara GossipSelect no script (OptionType=1 GOSSIP_OPTION_GOSSIP, OptionNpcflag=1 GOSSIP)
DELETE FROM `gossip_menu_option` WHERE `MenuID` = 13411;
INSERT INTO `gossip_menu_option` (`MenuID`, `OptionID`, `OptionIcon`, `OptionText`, `OptionBroadcastTextID`, `OptionType`, `OptionNpcFlag`, `VerifiedBuild`) VALUES
(13411, 0, 1, 'Fly me to the arena.', 0, 1, 1, 0);

-- 5) Spawn dos drakes na sala apos Morchok (map 967, zone 5892 Dragon Soul, area 5923 The Dragon Wastes) - Grade [28,27] Cell [5,3]/[5,4] Instance 1
-- Coord .gps solicitado: Valeera 57289 (-1789.48291, -2362.63818, 47.289059, 4.638559 FloorZ 47.288376) / Eiendormi 57288 (-1783.362793, -2419.810059, 45.673759, 1.734852 FloorZ 45.672554)
-- Todas dificuldades 10N/25N/10H/25H = spawnMask 15, phaseMask 1, VerifiedBuild 0 (compativel TDB root 2022 e DB migrado via header AUTO-FIX 1054)
DELETE FROM `creature` WHERE `guid` IN (1770001, 1770002);
DELETE FROM `creature` WHERE `id` IN (57288, 57289) AND `map`=967 AND `guid` NOT IN (1770001, 1770002);
INSERT INTO `creature` (`guid`, `id`, `map`, `zoneId`, `areaId`, `spawnMask`, `phaseUseFlags`, `phaseMask`, `PhaseId`, `PhaseGroup`, `terrainSwapMap`, `modelid`, `equipment_id`, `position_x`, `position_y`, `position_z`, `orientation`, `spawntimesecs`, `wander_distance`, `currentwaypoint`, `curhealth`, `curmana`, `MovementType`, `npcflag`, `unit_flags`, `ScriptName`, `VerifiedBuild`) VALUES
(1770001, 57289, 967, 5892, 5923, 15, 0, 1, 0, 0, -1, 0, 0, -1789.48291, -2362.63818, 47.289059, 4.638559, 7200, 0, 0, 1, 0, 0, 1, 0, '', 0),
(1770002, 57288, 967, 5892, 5923, 15, 0, 1, 0, 0, -1, 0, 0, -1783.362793, -2419.810059, 45.673759, 1.734852, 7200, 0, 0, 1, 0, 0, 1, 0, '', 0);