-- ============================================================
-- Dragon Soul: Warlord Zon'ozz 55308 - script + instance gate
-- Refs: boss_warlord_zonozz.cpp, dragon_soul.h, instance_dragon_soul.cpp
-- WoWhead: 55308 Normal/Heroic 10/25 - mesmo entry, gateado por Morchok DONE
-- Apply AFTER world DB base (Cataclysm Preservation Project).
-- ============================================================

-- 1) ScriptName: core precisa disto para instanciar AI correta
-- Zon'ozz já existe na core mas sem registro -> invisivel/mudo/sem AI
UPDATE `creature_template` SET `ScriptName` = 'boss_warlord_zonozz' WHERE `entry` = 55308;
UPDATE `creature_template` SET `ScriptName` = 'npc_warlord_zonozz_void_of_the_unmaking' WHERE `entry` = 55334;
UPDATE `creature_template` SET `ScriptName` = 'npc_warlord_zonozz_tentacle' WHERE `entry` IN (55416, 55417, 55418);

-- 2) Spell scripts: liga SpellScriptLoader aos spells
DELETE FROM `spell_script_names` WHERE `spell_id` IN (103434, 103948);
INSERT INTO `spell_script_names` (`spell_id`, `ScriptName`) VALUES
(103434, 'spell_warlord_zonozz_disrupting_shadows'), -- Disrupting Shadows aura (OnRemove dispel -> 103948)
(103948, 'spell_warlord_zonozz_disrupting_shadows'); -- Disrupting Shadows dmg (mesmo loader, fallback)

DELETE FROM `spell_script_names` WHERE `spell_id` IN (109874, 109875, 109876, 109877, 109878, 109879, 109880);
INSERT INTO `spell_script_names` (`spell_id`, `ScriptName`) VALUES
(109874, 'spell_warlord_zonozz_whisper'), -- whisper aggro (filtra player)
(109875, 'spell_warlord_zonozz_whisper'), -- whisper intro
(109876, 'spell_warlord_zonozz_whisper'), -- whisper death
(109877, 'spell_warlord_zonozz_whisper'), -- whisper kill
(109878, 'spell_warlord_zonozz_whisper'), -- whisper blood
(109879, 'spell_warlord_zonozz_whisper'), -- whisper shadows
(109880, 'spell_warlord_zonozz_whisper'); -- whisper void

-- 3) Spawn gate Blizzlike: Zon'ozz sempre spawnado, pull liberado só após Morchok DONE
-- C++ boss_warlord_zonozz.cpp:199 JustEngagedWith checks GetBossState(DATA_MORCHOK)!=DONE -> Evade
-- Se SELECT retornar 0 linhas, spawn faltando -> inserir
-- SELECT `guid`, `id`, `map`, `position_x`, `position_y`, `position_z`, `orientation`, `spawnMask` FROM `creature` WHERE `id`=55308 AND `map`=967;

-- Spawn retail 4.3.4 sniff: sala após Morchok (corredor para Yor'sahj)
-- Insere só se não existir (evita duplicar guid) - coluna correta `id` (não `id1`), erro 1054 fix
-- Compatível com DB atualizado (2025_03_11_03 DROP dynamicflags) e antigo: evita 1054 dynamicflags; wander_distance já fix spawndist
INSERT INTO `creature` (`guid`, `id`, `map`, `zoneId`, `areaId`, `spawnMask`, `phaseMask`, `modelid`, `position_x`, `position_y`, `position_z`, `orientation`, `spawntimesecs`, `wander_distance`, `currentwaypoint`, `curhealth`, `curmana`, `MovementType`, `npcflag`, `unit_flags`)
SELECT 900001, 55308, 967, 0, 0, 15, 1, 0, -13868.7, -12126.3, 271.0, 1.57, 120, 0, 0, 49237900, 0, 0, 0, 0
FROM DUAL WHERE NOT EXISTS (SELECT 1 FROM `creature` WHERE `id`=55308 AND `map`=967);

-- 4) Garante spawnMask 15 = todas dificuldades (10N/25N/10H/25H) em 967
UPDATE `creature` SET `spawnMask`=15 WHERE `id`=55308 AND `map`=967;
UPDATE `creature` SET `spawnMask`=15 WHERE `id`=55312 AND `map`=967; -- Yor'sahj 55312 futuro boss file
UPDATE `creature` SET `spawnMask`=15 WHERE `map`=967 AND `spawnMask`!=15;

-- 5) creature_text: GroupIDs DEVEM bater com enum Texts em boss_warlord_zonozz.cpp:
-- SAY_AGGRO=0 SAY_DEATH=1 SAY_INTRO=2 SAY_KILL=3 SAY_SHADOWS=4 SAY_BLOOD=5 SAY_VOID=6
-- Ver sql/custom/world/world_dragon_soul_zonozz_text.sql se mudo
