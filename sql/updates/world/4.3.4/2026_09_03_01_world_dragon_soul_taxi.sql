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
DELETE FROM `gossip_menu_option` WHERE `MenuId` = 13411;
INSERT INTO `gossip_menu_option` (`MenuId`, `OptionIndex`, `OptionIcon`, `OptionText`, `OptionBroadcastTextId`, `OptionType`, `OptionNpcflag`, `VerifiedBuild`) VALUES
(13411, 0, 1, 'Fly me to the arena.', 0, 1, 1, 0);

-- 5) Spawn dos drakes no Summit (map 967), todas dificuldades do raid (10N/25N/10H/25H = spawnMask 15)
INSERT INTO `creature` (`guid`, `id`, `map`, `zoneId`, `areaId`, `spawnMask`, `phaseUseFlags`, `phaseMask`, `PhaseId`, `PhaseGroup`, `terrainSwapMap`, `modelid`, `equipment_id`, `position_x`, `position_y`, `position_z`, `orientation`, `spawntimesecs`, `spawndist`, `currentwaypoint`, `curhealth`, `curmana`, `MovementType`, `npcflag`, `unit_flags`, `dynamicflags`, `ScriptName`, `VerifiedBuild`) VALUES
(1770001, 57289, 967, 0, 0, 15, 0, 1, 0, 0, -1, 0, 0, -1781.19, -2375.12, 341.35, 0.00, 7200, 0, 0, 1, 0, 0, 1, 0, 0, '', 0),
(1770002, 57288, 967, 0, 0, 15, 0, 1, 0, 0, -1, 0, 0, -1777.19, -2375.12, 341.35, 0.00, 7200, 0, 0, 1, 0, 0, 1, 0, 0, '', 0);
