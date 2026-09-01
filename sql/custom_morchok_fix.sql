-- Morchok fix: Falas 55265 (creature_text)
-- GroupID mapeia para enum ScriptedTexts em boss_morchok.cpp:
-- 0=AGGRO, 1=DEATH, 6=GROUND1, 7=GROUND2, 9=CRYSTAL, 10=KILL, 11=KOHCROM, 12=ANN_CRYSTAL
-- Type: 14 = CHAT_MSG_MONSTER_YELL, 41 = CHAT_MSG_RAID_BOSS_EMOTE

DELETE FROM `creature_text` WHERE `CreatureID`=55265 AND `GroupID` IN (0,1,6,7,9,10,11,12);

INSERT INTO `creature_text` (`CreatureID`, `GroupID`, `ID`, `Text`, `Type`, `Language`, `Probability`, `Emote`, `Duration`, `Sound`, `SoundType`, `BroadcastTextId`, `TextRange`, `comment`) VALUES
(55265, 0, 0, 'You seek to halt an avalanche. I will bury you.', 14, 0, 100, 0, 0, 24884, 0, 0, 0, 'Morchok - Aggro'),
(55265, 1, 0, 'You... still... stand...', 14, 0, 100, 0, 0, 0, 0, 0, 0, 'Morchok - Death'),
(55265, 6, 0, 'The earth consumes you!', 14, 0, 100, 0, 0, 0, 0, 0, 0, 'Morchok - The Earth Consumes You'),
(55265, 7, 0, 'Feel the fury of the earth!', 14, 0, 100, 0, 0, 0, 0, 0, 0, 'Morchok - Black Blood of the Earth'),
(55265, 9, 0, 'Flee, and die.', 14, 0, 50, 0, 0, 0, 0, 0, 0, 'Morchok - Resonating Crystal 1'),
(55265, 9, 1, 'Run, and perish.', 14, 0, 50, 0, 0, 0, 0, 0, 0, 'Morchok - Resonating Crystal 2'),
(55265, 10, 0, 'You are nothing.', 14, 0, 100, 0, 0, 0, 0, 0, 0, 'Morchok - Kill'),
(55265, 11, 0, 'Kohcrom, crush them!', 14, 0, 100, 0, 0, 0, 0, 0, 0, 'Morchok - Summon Kohcrom'),
(55265, 12, 0, 'Morchok conjures an explosive crystal!', 41, 0, 100, 0, 0, 0, 0, 0, 0, 'Morchok - Crystal Announce');

