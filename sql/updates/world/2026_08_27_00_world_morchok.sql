-- Dragon Soul: Morchok
-- Refs: src/server/scripts/Kalimdor/CavernsOfTime/DragonSoul/boss_morchok.cpp
--       (struct boss_morchok : public BossAI + RegisterDragonSoulCreatureAI)
-- Apply AFTER world database is loaded (The-Cataclysm-Preservation-Project base).

-- 1) ScriptName
UPDATE `creature_template` SET `ScriptName` = 'boss_morchok'                    WHERE `entry` = 55265; -- Morchok
UPDATE `creature_template` SET `ScriptName` = 'npc_morchok_kohcrom'            WHERE `entry` = 57773; -- Kohcrom (Heroic)
UPDATE `creature_template` SET `ScriptName` = 'npc_morchok_resonating_crystal' WHERE `entry` = 55346; -- Resonating Crystal
UPDATE `creature_template` SET `ScriptName` = ''                               WHERE `entry` IN (55269, 55274, 57774, 57995, 57996) AND `ScriptName` IN ('npc_morchok_resonating_crystal', 'npc_morchok_kohcrom');

-- 2) creature_text — GroupIDs MUST match enum ScriptedTexts in boss_morchok.cpp
--    SAY_AGGRO=0, SAY_DEATH=1, SAY_GROUND1=6, SAY_GROUND2=7,
--    SAY_CRYSTAL=9, SAY_KILL=10, SAY_KOHCROM=11, ANN_CRYSTAL=12
DELETE FROM `creature_text` WHERE `CreatureID` = 55265;
INSERT INTO `creature_text` (`CreatureID`, `GroupID`, `ID`, `Type`, `Sound`, `Probability`, `comment`, `Text`) VALUES
-- SAY_AGGRO = 0
(55265, 0,  0, 14, 0, 100, 'Morchok - SAY_AGGRO',       'You seek to halt an avalanche. I will bury you.'),
-- SAY_DEATH = 1
(55265, 1,  0, 14, 0, 100, 'Morchok - SAY_DEATH',       'Impossible. This cannot be. The tower...must...fall.'),
-- SAY_GROUND1 = 6 (Falling Fragments)
(55265, 6,  0, 14, 0, 100, 'Morchok - SAY_GROUND1',     'The earth consumes you!'),
-- SAY_GROUND2 = 7 (Black Blood of the Earth)
(55265, 7,  0, 14, 0, 100, 'Morchok - SAY_GROUND2',     'Feel the fury of the earth!'),
-- SAY_CRYSTAL = 9
(55265, 9,  0, 14, 0, 100, 'Morchok - SAY_CRYSTAL',     'Flee, and die.'),
(55265, 9,  1, 14, 0, 100, 'Morchok - SAY_CRYSTAL',     'Run, and perish.'),
-- SAY_KILL = 10
(55265, 10, 0, 14, 0, 100, 'Morchok - SAY_KILL',        'I am unstoppable.'),
(55265, 10, 1, 14, 0, 100, 'Morchok - SAY_KILL',        'It was inevitable.'),
(55265, 10, 2, 14, 0, 100, 'Morchok - SAY_KILL',        'Ground to dust.'),
-- SAY_KOHCROM = 11
(55265, 11, 0, 14, 0, 100, 'Morchok - SAY_KOHCROM',     'Kohcrom, crush them!'),
-- ANN_CRYSTAL = 12 (emote announce)
(55265, 12, 0, 16, 0, 100, 'Morchok - ANN_CRYSTAL',     '%s summons a Resonating Crystal!');
