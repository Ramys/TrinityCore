-- ============================================================
-- Dragon Soul: Yor'sahj the Unsleeping 55312 - script + spawn + texts
-- Refs: boss_yorsahj_the_unsleeping.cpp, dragon_soul.h, instance_dragon_soul.cpp
-- WoWhead: 55312 Normal/Heroic 10/25 - mesmo entry, gateado por Zon'ozz DONE
-- DBC validados dbc/enUS/Spell.dbc (fieldCount=48, Name col21):
--  104849 Void Bolt, 103628/105171 Deep Corruption, 105031 Digestive Acid,
--  105033 Searing Blood, 105530 Mana Void trig 105534, 105539 Mana Diffusion, 105671 Psychic Slice
--  104894 Black Blood, 104896 Shadowed/104897 Crimson/104898 Acidic/104900 Cobalt/104901 Glowing Blood
--  105027 Cobalt Blood, 47008 Berserk, 105132 Call Blood visual
-- Adds: 55862 Acidic verde /55863 Shadowed roxo /55864 Glowing amarelo /55865 Crimson vermelho /55866 Cobalt azul /55867 Dark preto
--       56231 Mana Void, 56265 Forgotten One
-- Apply AFTER world DB base (Cataclysm Preservation Project).
-- ============================================================

-- 1) ScriptName: core precisa disto para instanciar AI correta
UPDATE `creature_template` SET `ScriptName` = 'boss_yorsahj_the_unsleeping' WHERE `entry` = 55312;
UPDATE `creature_template` SET `ScriptName` = 'npc_yorsahj_globule' WHERE `entry` IN (55862, 55863, 55864, 55865, 55866, 55867);
UPDATE `creature_template` SET `ScriptName` = 'npc_yorsahj_mana_void' WHERE `entry` = 56231;
UPDATE `creature_template` SET `ScriptName` = 'npc_yorsahj_forgotten_one' WHERE `entry` = 56265;

-- Clean wrong assignments on triggers (evita AI em mobs errados)
UPDATE `creature_template` SET `ScriptName` = '' WHERE `entry` IN (55334, 55416, 55417, 55418) AND `ScriptName` LIKE 'npc_yorsahj%';

-- 2) Spell scripts: liga SpellScriptLoader aos spells (Deep Corruption aura)
DELETE FROM `spell_script_names` WHERE `spell_id` IN (105171, 103628, 105031, 105033, 105530, 105671);
INSERT INTO `spell_script_names` (`spell_id`, `ScriptName`) VALUES
(105171, 'spell_yorsahj_deep_corruption'),
(103628, 'spell_yorsahj_deep_corruption');

-- 3) Spawn gate Blizzlike: Yor'sahj sempre spawnado, pull liberado só após Zon'ozz DONE
-- C++ boss_yorsahj_the_unsleeping.cpp:JustEngagedWith checks GetBossState(DATA_WARLORD_ZONOZZ)!=DONE -> Evade
-- Se SELECT retornar 0 linhas, spawn faltando -> inserir
-- SELECT `guid`, `id`, `map`, `position_x`, `position_y`, `position_z`, `orientation`, `spawnMask` FROM `creature` WHERE `id`=55312 AND `map`=967;
-- Spawn retail sniff aproximado: sala após Zon'ozz (caminho para Hagara), Z valido via UpdateGroundPositionZ
INSERT INTO `creature` (`guid`, `id`, `map`, `zoneId`, `areaId`, `spawnMask`, `phaseMask`, `modelid`, `position_x`, `position_y`, `position_z`, `orientation`, `spawntimesecs`, `wander_distance`, `currentwaypoint`, `curhealth`, `curmana`, `MovementType`, `npcflag`, `unit_flags`)
SELECT 900002, 55312, 967, 0, 0, 15, 1, 0, -13530.5, -12105.8, 268.2, 1.57, 120, 0, 0, 49237900, 0, 0, 0, 0
FROM DUAL WHERE NOT EXISTS (SELECT 1 FROM `creature` WHERE `id`=55312 AND `map`=967);

-- 4) Garante spawnMask 15 = todas dificuldades (10N/25N/10H/25H) em 967
UPDATE `creature` SET `spawnMask`=15 WHERE `id`=55312 AND `map`=967;
UPDATE `creature` SET `spawnMask`=15 WHERE `id` IN (55862,55863,55864,55865,55866,55867,56231,56265) AND `map`=967;
UPDATE `creature` SET `spawnMask`=15 WHERE `map`=967 AND `spawnMask`!=15;

-- 5) creature_text: GroupIDs DEVEM bater com enum Texts em boss_yorsahj_the_unsleeping.cpp:
-- SAY_AGGRO=0 SAY_DEATH=1 SAY_INTRO=2 SAY_KILL=3 SAY_GLOBULE=4 SAY_BERSERK=5
-- Type 14=Yell. Sound IDs validados via dbc/enUS/SoundEntries.dbc 26326-26334:
--  26326 VO_DS_YORSAHJ_AGGRO_01, 26327 DEATH_01, 26328 INTRO_01, 26329 SLAY_01, 26330 SLAY_02, 26331 SLAY_03, 26332 SPELL_01, 26333 SPELL_02, 26334 SPELL_03
-- Quotes Wowhead n10 sniff / EJ 4.3.4 - Sound 0 = mudo (fix Morchok-like 26268). Texto inglês primário, voz toca ShathYar.
DELETE FROM `creature_text` WHERE `CreatureID`=55312;
INSERT INTO `creature_text` (`CreatureID`, `GroupID`, `ID`, `Text`, `Type`, `Language`, `Probability`, `Emote`, `Duration`, `Sound`, `SoundType`, `BroadcastTextId`, `TextRange`, `comment`) VALUES
(55312, 0, 0, 'You will drown in the blood of the Old Gods! ALL OF YOU!', 14, 0, 100, 0, 0, 26326, 0, 0, 0, 'Yorsahj - SAY_AGGRO VO_DS_YORSAHJ_AGGRO_01'),
(55312, 1, 0, 'O, Deathwing! Your faithful servant has failed you!', 14, 0, 100, 0, 0, 26327, 0, 0, 0, 'Yorsahj - SAY_DEATH VO_DS_YORSAHJ_DEATH_01'),
(55312, 2, 0, 'Our numbers are endless, our power beyond reckoning! All who oppose the Destroyer will DIE A THOUSAND DEATHS!', 14, 0, 100, 0, 0, 26328, 0, 0, 0, 'Yorsahj - SAY_INTRO VO_DS_YORSAHJ_INTRO_01'),
(55312, 3, 0, 'Your soul will know ENDLESS TORMENT!', 14, 0, 33, 0, 0, 26329, 0, 0, 0, 'Yorsahj - SAY_KILL 1 VO_DS_YORSAHJ_SLAY_01'),
(55312, 3, 1, 'All praise Deathwing, THE DESTROYER!', 14, 0, 33, 0, 0, 26330, 0, 0, 0, 'Yorsahj - SAY_KILL 2 VO_DS_YORSAHJ_SLAY_02'),
(55312, 3, 2, 'From its BLEAKEST DEPTHS, we RECLAIM this world!', 14, 0, 34, 0, 0, 26331, 0, 0, 0, 'Yorsahj - SAY_KILL 3 VO_DS_YORSAHJ_SLAY_03'),
(55312, 4, 0, 'The DARKNESS devours ALL!', 14, 0, 33, 0, 0, 26333, 0, 0, 0, 'Yorsahj - SAY_GLOBULE VO_DS_YORSAHJ_SPELL_02'),
(55312, 4, 1, 'SEE how we pour from the CURSED EARTH!', 14, 0, 33, 0, 0, 26334, 0, 0, 0, 'Yorsahj - SAY_GLOBULE VO_DS_YORSAHJ_SPELL_03'),
(55312, 4, 2, 'I summon the blood!', 14, 0, 34, 0, 0, 26332, 0, 0, 0, 'Yorsahj - SAY_GLOBULE VO_DS_YORSAHJ_SPELL_01 - text sniff pendente, wowhead mostra ''?'''),
(55312, 5, 0, 'Enough!', 14, 0, 100, 0, 0, 0, 0, 0, 0, 'Yorsahj - SAY_BERSERK sem VO DBC');
