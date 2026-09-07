-- ============================================================
-- Dragon Soul: Morchok - FIX consolidado (audio, spell link, lootid)
-- Aplica DEPOIS de 2026_08_27_00_world_morchok.sql e custom_morchok_fix.sql
-- para corrigir Sound=0 (fallas mudas de voz dessincronizadas) e link de spell.
-- ============================================================

-- 1) creature_text: sons corretos 26268-26288 (SoundEntries.dbc validado).
--    GroupID mapeia enum ScriptedTexts (boss_morchok.cpp):
--    0=AGGRO 1=DEATH 6=GROUND1 7=GROUND2 9=CRYSTAL 10=KILL 11=KOHCROM 12=ANN_CRYSTAL
--    Type 14=MONSTER_YELL, 16=EMOTE
DELETE FROM `creature_text` WHERE `CreatureID` = 55265;

INSERT INTO `creature_text` (`CreatureID`, `GroupID`, `ID`, `Text`, `Type`, `Language`, `Probability`, `Emote`, `Duration`, `Sound`, `SoundType`, `BroadcastTextId`, `TextRange`, `comment`) VALUES
-- SAY_AGGRO = 0 -> 26268 VO_DS_MORCHOK_AGGRO_01
(55265, 0, 0, 'You seek to halt an avalanche. I will bury you.', 14, 0, 100, 0, 0, 26268, 0, 0, 0, 'Morchok - SAY_AGGRO'),
-- SAY_DEATH = 1 -> 26269 VO_DS_MORCHOK_DEATH_01
(55265, 1, 0, 'Impossible. This cannot be. The tower...must...fall.', 14, 0, 100, 0, 0, 26269, 0, 0, 0, 'Morchok - SAY_DEATH'),
-- SAY_GROUND1 = 6 -> 26274 (Falling Fragments)
(55265, 6, 0, 'The earth consumes you!', 14, 0, 100, 0, 0, 26274, 0, 0, 0, 'Morchok - SAY_GROUND1'),
-- SAY_GROUND2 = 7 -> 26278 (Black Blood of the Earth)
(55265, 7, 0, 'Feel the fury of the earth!', 14, 0, 100, 0, 0, 26278, 0, 0, 0, 'Morchok - SAY_GROUND2'),
-- SAY_CRYSTAL = 9 -> 26283 / 26284 (2 takes)
(55265, 9, 0, 'Flee, and die.', 14, 0, 100, 0, 0, 26283, 0, 0, 0, 'Morchok - SAY_CRYSTAL 1'),
(55265, 9, 1, 'Run, and perish.', 14, 0, 100, 0, 0, 26284, 0, 0, 0, 'Morchok - SAY_CRYSTAL 2'),
-- SAY_KILL = 10 -> 26285 / 26286 / 26287
(55265, 10, 0, 'I am unstoppable.', 14, 0, 100, 0, 0, 26285, 0, 0, 0, 'Morchok - SAY_KILL 1'),
(55265, 10, 1, 'It was inevitable.', 14, 0, 100, 0, 0, 26286, 0, 0, 0, 'Morchok - SAY_KILL 2'),
(55265, 10, 2, 'Ground to dust.', 14, 0, 100, 0, 0, 26287, 0, 0, 0, 'Morchok - SAY_KILL 3'),
-- SAY_KOHCROM = 11 -> 26288 (summon Kohcrom)
(55265, 11, 0, 'Kohcrom, crush them!', 14, 0, 100, 0, 0, 26288, 0, 0, 0, 'Morchok - SAY_KOHCROM'),
-- ANN_CRYSTAL = 12 (emote announce) sem voz
(55265, 12, 0, '%s summons a Resonating Crystal!', 16, 0, 100, 0, 0, 0, 0, 0, 0, 'Morchok - ANN_CRYSTAL');

-- 2) spell_script_names: remover link invalido 103494 (TA 1 self-aura, nao tem
--    TARGET_UNIT_DEST_AREA_ENEMY) e garantir 103528 (trigger area) corretamente.
--    boss_morchok.cpp registra spell_morchok_resonating_crystal_dmg em EFFECT_1 TA 18/B16 -> 103528.
DELETE FROM `spell_script_names` WHERE `spell_id` IN (103414, 103494, 103528, 103785);

INSERT INTO `spell_script_names` (`spell_id`, `ScriptName`) VALUES
(103414, 'spell_morchok_stomp'),
(103528, 'spell_morchok_resonating_crystal_dmg'),
(103785, 'spell_morchok_black_blood_of_the_earth_dmg');

-- 3) lootid: garantir que entries Morchok apontem para loot table própria.
--    (Somente corrige se estiver zerado; nao inventa itens de loot.)
UPDATE `creature_template` SET `lootid` = `entry` WHERE `entry` IN (55265, 57409, 57771, 57772, 57773) AND `lootid` = 0;

-- 4) Verificacoes (rodar no console):
-- SELECT CreatureID, GroupID, ID, Type, Sound, Probability, comment FROM creature_text WHERE CreatureID=55265 ORDER BY GroupID, ID;
-- SELECT spell_id, ScriptName FROM spell_script_names WHERE spell_id IN (103414, 103494, 103528, 103785);
-- SELECT entry, lootid, difficulty_entry_1, difficulty_entry_2, difficulty_entry_3 FROM creature_template WHERE entry IN (55265, 57409, 57771, 57772, 57773);
-- SELECT Entry, Count(*) FROM creature_loot_template WHERE Entry IN (55265, 57409, 57771, 57772, 57773) GROUP BY Entry;