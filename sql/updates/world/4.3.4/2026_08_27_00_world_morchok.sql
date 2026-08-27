-- Dragon Soul: Morchok
-- Refs: src/server/scripts/Kalimdor/CavernsOfTime/DragonSoul/boss_morchok.cpp
--       (struct boss_morchok : public BossAI + RegisterDragonSoulCreatureAI)
-- Apply AFTER world database is loaded (The-Cataclysm-Preservation-Project base).

-- 1) ScriptName: obrigatorio para o core instanciar o AI correto.
UPDATE `creature_template` SET `ScriptName` = 'boss_morchok'                    WHERE `entry` = 55265; -- Morchok
UPDATE `creature_template` SET `ScriptName` = 'npc_morchok_kohcrom'            WHERE `entry` = 55274; -- Kohcrom (Heroic)
UPDATE `creature_template` SET `ScriptName` = 'npc_morchok_resonating_crystal' WHERE `entry` = 55269; -- Resonating Crystal

-- 2) creature_text: Talk() ids usados no script.
--    SAY_AGGRO=0, SAY_DEATH=1, SAY_GROUND1=6, SAY_GROUND2=7,
--    SAY_CRYSTAL=9, SAY_KILL=10, SAY_KOHCROM=11, ANN_CRYSTAL=12
-- @TODO: preencher `text` / `BroadcastTextId` com dados oficiais do cliente 4.3.4
--        (BroadcastText.dbc). Vazio = Talk vira no-op (sem crash).
DELETE FROM `creature_text` WHERE `entry` = 55265;
INSERT INTO `creature_text` (`entry`, `groupid`, `id`, `type`, `sound`, `probability`, `comment`, `text`) VALUES
(55265, 0,  0, 14, 0, 100, 'Morchok - SAY_AGGRO',    ''),
(55265, 1,  0, 14, 0, 100, 'Morchok - SAY_DEATH',    ''),
(55265, 6,  0, 14, 0, 100, 'Morchok - SAY_GROUND1',  ''),
(55265, 7,  0, 14, 0, 100, 'Morchok - SAY_GROUND2',  ''),
(55265, 9,  0, 14, 0, 100, 'Morchok - SAY_CRYSTAL',  ''),
(55265, 10, 0, 14, 0, 100, 'Morchok - SAY_KILL',     ''),
(55265, 11, 0, 14, 0, 100, 'Morchok - SAY_KOHCROM',  ''),
(55265, 12, 0, 16, 0, 100, 'Morchok - ANN_CRYSTAL',  '');
