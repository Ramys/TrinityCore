-- Morchok fix: Cristal 103494 + Falas 55265
-- Parte 1: Falas (creature_text) - corrige Talk() que so fazia aggro porque faltavam linhas
-- groupid mapeia para enum ScriptedTexts em boss_morchok.cpp: 0=AGGRO, 1=DEATH, 6=GROUND1, 7=GROUND2, 9=CRYSTAL, 10=KILL, 11=KOHCROM, 12=ANNOUNCE
DELETE FROM creature_text WHERE entry=55265 AND groupid IN (0,1,6,7,9,10,11,12);
INSERT INTO creature_text (entry, groupid, id, text, type, language, probability, emote, duration, sound, BroadcastTextID, comment) VALUES
(55265, 0, 0, 'You seek to halt an avalanche. I will bury you.', 1, 0, 100, 0, 0, 24884, 0, 'Morchok - Aggro'),
(55265, 1, 0, 'You... still... stand...', 1, 0, 100, 0, 0, 0, 0, 'Morchok - Death'),
(55265, 6, 0, 'The earth consumes you!', 1, 0, 100, 0, 0, 0, 0, 'Morchok - The Earth Consumes You'),
(55265, 7, 0, 'Feel the fury of the earth!', 1, 0, 100, 0, 0, 0, 0, 'Morchok - Black Blood of the Earth'),
(55265, 9, 0, 'Flee, and die.', 1, 0, 100, 0, 0, 0, 0, 'Morchok - Resonating Crystal 1'),
(55265, 9, 1, 'Run, and perish.', 1, 0, 100, 0, 0, 0, 0, 'Morchok - Resonating Crystal 2'),
(55265,10, 0, 'You are nothing.', 1, 0, 100, 0, 0, 0, 0, 'Morchok - Kill'),
(55265,11, 0, 'Kohcrom, crush them!', 1, 0, 100, 0, 0, 0, 0, 'Morchok - Summon Kohcrom'),
(55265,12, 0, 'Morchok conjures an explosive crystal!', 2, 0, 100, 0, 0, 0, 0, 'Morchok - Crystal Announce');
