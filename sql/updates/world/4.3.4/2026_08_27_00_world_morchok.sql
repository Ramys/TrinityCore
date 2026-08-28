-- Dragon Soul: Morchok
-- Refs: src/server/scripts/Kalimdor/CavernsOfTime/DragonSoul/boss_morchok.cpp
--       (struct boss_morchok : public BossAI + RegisterDragonSoulCreatureAI)
-- Apply AFTER world database is loaded (The-Cataclysm-Preservation-Project base).

-- 1) ScriptName: obrigatorio para o core instanciar o AI correto.
UPDATE `creature_template` SET `ScriptName` = 'boss_morchok'                    WHERE `entry` = 55265; -- Morchok
UPDATE `creature_template` SET `ScriptName` = 'npc_morchok_kohcrom'            WHERE `entry` = 55274; -- Kohcrom (Heroic)
UPDATE `creature_template` SET `ScriptName` = 'npc_morchok_resonating_crystal' WHERE `entry` = 55269; -- Resonating Crystal

-- 2) creature_text: Talk() ids usados no boss_morchok.cpp.
--    SAY_AGGRO=0, SAY_CRYS=1, SAY_KOHCROM=2, SAY_VORTEX=3,
--    SAY_BLACK_BLOOD=4, SAY_DEATH=5, SAY_KILL=6 (grupos 0..6).
--    Type 14 = Yell. BroadcastTextId 0 (usa coluna Text). Preencher com
--    BroadcastText.dbc 4.3.4 se os IDs forem conhecidos.
--    Quotes extraidas do PDF "Morchok_Boss_Reference".
DELETE FROM `creature_text` WHERE `CreatureID` = 55265;
INSERT INTO `creature_text` (`CreatureID`, `GroupID`, `ID`, `Type`, `Sound`, `Probability`, `comment`, `Text`) VALUES
(55265, 0, 0, 14, 0, 100, 'Morchok - SAY_AGGRO',       'You seek to halt an avalanche. I will bury you.'),
(55265, 1, 0, 14, 0, 100, 'Morchok - SAY_CRYS',        'Flee and die!'),
(55265, 1, 1, 14, 0, 100, 'Morchok - SAY_CRYS',        'Run, and perish.'),
(55265, 2, 0, 14, 0, 100, 'Morchok - SAY_KOHCROM',     'You thought to fight me alone? The earth splits to swallow and crush you.'),
(55265, 3, 0, 14, 0, 100, 'Morchok - SAY_VORTEX',      'The stone calls...'),
(55265, 3, 1, 14, 0, 100, 'Morchok - SAY_VORTEX',      'The ground shakes...'),
(55265, 3, 2, 14, 0, 100, 'Morchok - SAY_VORTEX',      'The rocks tremble...'),
(55265, 3, 3, 14, 0, 100, 'Morchok - SAY_VORTEX',      'The surface quakes...'),
(55265, 4, 0, 14, 0, 100, 'Morchok - SAY_BLACK_BLOOD', '...and the black blood of the earth consumes you.'),
(55265, 4, 1, 14, 0, 100, 'Morchok - SAY_BLACK_BLOOD', '...and there is no escape from the old gods.'),
(55265, 4, 2, 14, 0, 100, 'Morchok - SAY_BLACK_BLOOD', '...and the rage of the true gods follows.'),
(55265, 4, 3, 14, 0, 100, 'Morchok - SAY_BLACK_BLOOD', '...and you drown in the hate of The Master.'),
(55265, 5, 0, 14, 0, 100, 'Morchok - SAY_DEATH',       'Impossible. This cannot be. The tower...must...fall.'),
(55265, 6, 0, 14, 0, 100, 'Morchok - SAY_KILL',        'I am unstoppable.'),
(55265, 6, 1, 14, 0, 100, 'Morchok - SAY_KILL',        'It was inevitable.'),
(55265, 6, 2, 14, 0, 100, 'Morchok - SAY_KILL',        'Ground to dust.');
