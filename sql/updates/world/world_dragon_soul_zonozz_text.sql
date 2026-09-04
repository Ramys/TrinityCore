-- =================================================================
-- Warlord Zon'ozz 55308 - creature_text blizzlike dossiê Cata
-- Map: 967 Dragon Soul | BossAI: boss_warlord_zonozz.cpp
-- GroupIDs MUST match enum Texts: 0=AGGRO 1=DEATH 2=INTRO 3=KILL 4=SHADOWS 5=BLOOD 6=VOID
-- Type 14=YELL, 12=SAY. VO sound IDs 26335-26345. Dossie 20 falas (10 yells ShathYar +10 whispers inglês)
-- Apply AFTER world DB base. DELETE afeta só 55308.
-- =================================================================
DELETE FROM `creature_text` WHERE `CreatureID`=55308;

INSERT INTO `creature_text` (`CreatureID`, `GroupID`, `ID`, `Text`, `Type`, `Language`, `Probability`, `Emote`, `Duration`, `Sound`, `SoundType`, `BroadcastTextId`, `TextRange`, `comment`) VALUES
-- INTRO VO_DS_ZONOZZ_INTRO_01 sound 26337
(55308, 2, 0, 'Vwyq agth sshoq''meg N''Zoth vra zz shfk qwor ga''halahs agthu. Uulg''ma, ag qam.', 14, 0, 50, 0, 0, 26337, 0, 0, 0, 'Zonozz - INTRO ShathYar VO 26337'),
(55308, 2, 1, 'Once more shall the twisted flesh-banners of N''Zoth chitter and howl above the fly-blown corpse of this world. After millennia, we have returned.', 14, 0, 50, 0, 0, 26337, 0, 0, 0, 'Zonozz - INTRO inglês'),
-- AGGRO VO_DS_ZONOZZ_AGGRO_01 sound 26335
(55308, 0, 0, 'Zzof Shuul''wah. Thoq fssh N''Zoth!', 14, 0, 50, 0, 0, 26335, 0, 0, 0, 'Zonozz - AGGRO ShathYar VO 26335'),
(55308, 0, 1, 'Victory for Deathwing. For the glory of N''Zoth!', 14, 0, 50, 0, 0, 26335, 0, 0, 0, 'Zonozz - AGGRO inglês'),
-- BLOOD / Tantrum Black Blood of Go'rath VO_DS_ZONOZZ_SPELL_04 sound 26344 spell 104378
(55308, 5, 0, 'N''Zoth ga zyqtahg iilth.', 14, 0, 25, 0, 0, 26344, 0, 0, 0, 'Zonozz - BLOOD ShathYar VO 26344 104378'),
(55308, 5, 1, 'The will of N''Zoth corrupts you.', 14, 0, 25, 0, 0, 26344, 0, 0, 0, 'Zonozz - BLOOD inglês VO 26344'),
-- VOID VO_DS_ZONOZZ_SPELL_05 sound 26345 spell 103571 Void of the Unmaking
(55308, 6, 0, 'Gul''kafh an''qov N''Zoth.', 14, 0, 50, 0, 0, 26345, 0, 0, 0, 'Zonozz - VOID ShathYar VO 26345 103571'),
(55308, 6, 1, 'Gaze into the heart of N''Zoth.', 14, 0, 50, 0, 0, 26345, 0, 0, 0, 'Zonozz - VOID inglês VO 26345'),
-- SHADOWS Disrupting Shadows VO_DS_ZONOZZ_SPELL_01-03 sounds 26340/26342/26343 - random pool 3 falas
(55308, 4, 0, 'Sk''shgn eqnizz hoq.', 14, 0, 33.3, 0, 0, 26340, 0, 0, 0, 'Zonozz - SHADOWS ShathYar VO 26340'),
(55308, 4, 1, 'Your fear drives me.', 14, 0, 33.3, 0, 0, 26340, 0, 0, 0, 'Zonozz - SHADOWS inglês VO 26340'),
(55308, 4, 2, 'Sk''magg yawifk hoq.', 14, 0, 33.3, 0, 0, 26342, 0, 0, 0, 'Zonozz - SHADOWS feat2 ShathYar VO 26342'),
(55308, 4, 3, 'Your suffering strengthens me.', 14, 0, 33.3, 0, 0, 26342, 0, 0, 0, 'Zonozz - SHADOWS feat2 inglês VO 26342'),
(55308, 4, 4, 'Sk''uuyat guulphg hoq.', 14, 0, 33.4, 0, 0, 26343, 0, 0, 0, 'Zonozz - SHADOWS feat3 ShathYar VO 26343'),
(55308, 4, 5, 'Your agony sustains me.', 14, 0, 33.4, 0, 0, 26343, 0, 0, 0, 'Zonozz - SHADOWS feat3 inglês VO 26343'),
-- KILL VO_DS_ZONOZZ_SLAY_01-03 sounds 26338/26339/26341
(55308, 3, 0, 'Sk''tek agth nuq N''Zoth yyqzz.', 14, 0, 16.6, 0, 0, 26338, 0, 0, 0, 'Zonozz - KILL ShathYar VO 26338'),
(55308, 3, 1, 'Your skulls shall adorn N''Zoth''s writhing throne.', 14, 0, 16.6, 0, 0, 26338, 0, 0, 0, 'Zonozz - KILL inglês VO 26338'),
(55308, 3, 2, 'Sk''shuul agth vorzz N''Zoth naggwa''fssh.', 14, 0, 16.6, 0, 0, 26339, 0, 0, 0, 'Zonozz - KILL feat2 ShathYar VO 26339'),
(55308, 3, 3, 'Your deaths shall sing of N''Zoth''s unending glory.', 14, 0, 16.6, 0, 0, 26339, 0, 0, 0, 'Zonozz - KILL feat2 inglês VO 26339'),
(55308, 3, 4, 'Sk''yahf agth huqth N''Zoth qornaus.', 14, 0, 16.8, 0, 0, 26341, 0, 0, 0, 'Zonozz - KILL feat3 ShathYar VO 26341'),
(55308, 3, 5, 'Your souls shall sate N''Zoth''s endless hunger.', 14, 0, 16.8, 0, 0, 26341, 0, 0, 0, 'Zonozz - KILL feat3 inglês VO 26341'),
-- DEATH VO_DS_ZONOZZ_DEATH_01 sound 26336
(55308, 1, 0, 'Uovssh thyzz... qwaz...', 14, 0, 50, 0, 0, 26336, 0, 0, 0, 'Zonozz - DEATH ShathYar VO 26336'),
(55308, 1, 1, 'To have waited so long... for this...', 14, 0, 50, 0, 0, 26336, 0, 0, 0, 'Zonozz - DEATH inglês VO 26336');
