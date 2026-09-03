-- =================================================================
-- Warlord Zon'ozz 55308 - creature_text
-- Map: 967 Dragon Soul | BossAI: boss_warlord_zonozz.cpp
-- GroupIDs MUST match enum Texts: 0=AGGRO 1=DEATH 2=INTRO 3=KILL 4=SHADOWS 5=BLOOD 6=VOID
-- Type 14 = YELL, 12 = SAY. Fix 1064: '' escape ok, final ; obrigatorio
-- Apply AFTER world DB base. DELETE afeta só 55308.
-- =================================================================
DELETE FROM `creature_text` WHERE `CreatureID`=55308;

INSERT INTO `creature_text` (`CreatureID`, `GroupID`, `ID`, `Text`, `Type`, `Language`, `Probability`, `Emote`, `Duration`, `Sound`, `SoundType`, `BroadcastTextId`, `TextRange`, `comment`) VALUES
(55308, 2, 0, 'Ak''agthshi ma uhnish, ak''uq shg''cul vwahuhn! H''iwn iggksh Phquathi gag OOU KAAXTH SHUUL!', 14, 0, 50, 0, 0, 0, 0, 0, 0, 'Zonozz - Intro ShathYar'),
(55308, 2, 1, 'Our numbers are endless, our power beyond reckoning! All who oppose the Destroyer will DIE A THOUSAND DEATHS!', 14, 0, 50, 0, 0, 0, 0, 0, 0, 'Zonozz - Intro'),
(55308, 0, 0, 'Iilth qi''uothk shn''ma yeh''glu Shath''Yar! H''IWN IILTH!', 14, 0, 50, 0, 0, 0, 0, 0, 0, 'Zonozz - Aggro ShathYar'),
(55308, 0, 1, 'You will drown in the blood of the Old Gods! ALL OF YOU!', 14, 0, 50, 0, 0, 0, 0, 0, 0, 'Zonozz - Aggro'),
(55308, 5, 0, 'KYTH ag''xig yyg''far IIQAATH ONGG!', 14, 0, 50, 0, 0, 0, 0, 0, 0, 'Zonozz - Blood ShathYar 1'),
(55308, 5, 1, 'SEE how we pour from the CURSED EARTH!', 14, 0, 50, 0, 0, 0, 0, 0, 0, 'Zonozz - Blood 1'),
(55308, 5, 2, 'UULL lwhuk H''IWN!', 14, 0, 50, 0, 0, 0, 0, 0, 0, 'Zonozz - Blood ShathYar 2'),
(55308, 5, 3, 'The DARKNESS devours ALL!', 14, 0, 50, 0, 0, 0, 0, 0, 0, 'Zonozz - Blood 2'),
(55308, 3, 0, 'Sk''yahf qi''plahf PH''MAGG!', 14, 0, 16.6, 0, 0, 0, 0, 0, 0, 'Zonozz - Kill ShathYar 1'),
(55308, 3, 1, 'Your soul will know ENDLESS TORMENT!', 14, 0, 16.6, 0, 0, 0, 0, 0, 0, 'Zonozz - Kill 1'),
(55308, 3, 2, 'H''iwn zaix Shuul''wah, PHQUATHI!', 14, 0, 16.6, 0, 0, 0, 0, 0, 0, 'Zonozz - Kill ShathYar 2'),
(55308, 3, 3, 'All praise Deathwing, THE DESTROYER!', 14, 0, 16.6, 0, 0, 0, 0, 0, 0, 'Zonozz - Kill 2'),
(55308, 3, 4, 'Shkul an''zig qvsakf KSSH''GA, ag''THYZAK agthu!', 14, 0, 16.6, 0, 0, 0, 0, 0, 0, 'Zonozz - Kill ShathYar 3'),
(55308, 3, 5, 'From its BLEAKEST DEPTHS, we RECLAIM this world!', 14, 0, 16.6, 0, 0, 0, 0, 0, 0, 'Zonozz - Kill 3'),
(55308, 1, 0, 'Ez, Shuul''wah! Sk''woth''gl yu''gaz yog''ghyl ilfah!', 14, 0, 50, 0, 0, 0, 0, 0, 0, 'Zonozz - Death ShathYar'),
(55308, 1, 1, 'O, Deathwing! Your faithful servant has failed you!', 14, 0, 50, 0, 0, 0, 0, 0, 0, 'Zonozz - Death');
