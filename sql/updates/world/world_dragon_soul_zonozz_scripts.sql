-- ============================================================
-- Dragon Soul: Warlord Zon'ozz 55308 - script + instance gate
-- Refs: boss_warlord_zonozz.cpp, dragon_soul.h, instance_dragon_soul.cpp
-- WoWhead: 55308 Normal/Heroic 10/25 - mesmo entry, gateado por Morchok DONE
-- Apply AFTER world DB base (Cataclysm Preservation Project).
-- ============================================================

-- 1) ScriptName: core precisa disto para instanciar AI correta
-- Zon'ozz já existe na core mas sem registro -> invisivel/mudo/sem AI
UPDATE `creature_template` SET `ScriptName` = 'boss_warlord_zonozz' WHERE `entry` = 55308;

-- 2) Spell scripts: liga SpellScriptLoader aos spells
DELETE FROM `spell_script_names` WHERE `spell_id` IN (103434, 103434, 103948);
INSERT INTO `spell_script_names` (`spell_id`, `ScriptName`) VALUES
(103434, 'spell_warlord_zonozz_disrupting_shadows'), -- Disrupting Shadows aura (OnRemove dispel -> 103948)
(103948, 'spell_warlord_zonozz_disrupting_shadows'); -- Disrupting Shadows dmg (mesmo loader, fallback)

-- whisper spells (filtra só players) - se seu core usar outros IDs, ajuste:
-- (descomente se precisar)
-- DELETE FROM `spell_script_names` WHERE `spell_id` IN (104543, 104323);
-- INSERT INTO `spell_script_names` (`spell_id`, `ScriptName`) VALUES
-- (104543, 'spell_warlord_zonozz_whisper'),
-- (104323, 'spell_warlord_zonozz_whisper');

-- 3) Verificação spawn: Zon'ozz deve existir em `creature` map 967
-- Se query abaixo retornar 0 linhas, spawn faltando -> inserir
-- SELECT `guid`, `id1`, `map`, `position_x`, `position_y`, `position_z`, `orientation`, `spawnMask` FROM `creature` WHERE `id1`=55308 AND `map`=967;
-- Spawn retail aproximado (ajuste se seu sniff divergir):
-- Corredor após Morchok, antes de Yor'sahj. Coords base sniff 4.3.4:
-- INSERT INTO `creature` (`guid`, `id1`, `map`, `zoneId`, `areaId`, `spawnMask`, `phaseMask`, `modelid`, `position_x`, `position_y`, `position_z`, `orientation`, `spawntimesecs`, `spawndist`, `currentwaypoint`, `curhealth`, `curmana`, `MovementType`, `npcflag`, `unit_flags`, `dynamicflags`) VALUES
-- (900001, 55308, 967, 0, 0, 15, 1, 0, 13698.0, 13600.0, 123.0, 0, 120, 0, 0, 10000000, 0, 0, 0, 0, 0)
-- ON DUPLICATE KEY UPDATE `spawnMask`=15;

-- 4) Garante spawnMask 15 (todas dificuldades) para DS map 967
-- Já existe em updates: UPDATE `creature` SET `spawnMask`=15 WHERE `map` IN (669,967);
-- Reaplique se seu DB ainda filtra:
-- UPDATE `creature` SET `spawnMask`=15 WHERE `id1`=55308 AND `map`=967;
-- UPDATE `creature` SET `spawnMask`=15 WHERE `id1`=55312 AND `map`=967; -- Yor'sahj (futuro boss file)

-- 5) creature_text: ver sql/custom_warlord_zonozz_text.sql (GroupIDs 0,1,2,3,5)
-- GroupIDs DEVEM bater com enum Texts em boss_warlord_zonozz.cpp:
-- SAY_AGGRO=0 SAY_DEATH=1 SAY_INTRO=2 SAY_KILL=3 SAY_SHADOWS=4 SAY_BLOOD=5 SAY_VOID=6
