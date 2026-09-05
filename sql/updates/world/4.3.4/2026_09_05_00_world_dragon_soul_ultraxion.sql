-- ============================================================================
-- Dragon Soul: Ultraxion 55294 - ScriptName + SpellScript bindings
-- Refs: boss_ultraxion.cpp (DragonSoul::Ultraxion), dragon_soul.h, instance_dragon_soul.cpp
--       Spell.dbc 73253 recs FC=48 (59 spell IDs validados OK contra a DBC)
-- Gate: Ultraxion 5o boss DS spawnado apos Hagara 55689 DONE (SetBossState hook)
-- Apply AFTER base Cataclysm Preservation Project.
-- ============================================================================

-- 1) ScriptName boss (entry + dificuldades conhecidas do DS 4.3.4)
UPDATE `creature_template` SET `ScriptName`='boss_ultraxion' WHERE `entry`=55294;
UPDATE `creature_template` SET `ScriptName`='boss_ultraxion' WHERE `entry` IN (57958,57959,57960) AND (`ScriptName` IS NULL OR `ScriptName`='');

-- 2) Ascendentes dos Aspectos (alcancavel com FindNearestCreature 300yd no encontro)
UPDATE `creature_template` SET `ScriptName`='' WHERE `entry` IN (56103,56100,56099,56102,56101);

-- 3) SpellScripts
-- Unstable Monstrosity / Twilight Instability / Hour of Twilight / Fading Light / Heroic Will
-- Last Defender of Azeroth / Timeloop (IDs extraidos do Spell.dbc local, 0 missing)
DELETE FROM `spell_script_names` WHERE `spell_id` IN
(109176,106374,106375,103327,106371,106368,106369,106108,
 105925,105926,109075,109200,110068,110069,110070,110073,110074,110075,110078,110079,110080,
 106182,110327,106080,106226,106227,106224,105984,105992);

INSERT IGNORE INTO `spell_script_names` (`spell_id`,`ScriptName`) VALUES
-- twilight instability AoE (1/2) + dmg
(109176,'spell_ultraxion_twilight_instability'),
(106374,'spell_ultraxion_twilight_instability'),
-- hour of twilight dmg (soak check normal realm / heroic looming darkness)
(103327,'spell_ultraxion_hour_of_twilight_dmg'),
-- fading light: aura (durar aleatoria + kill/puxa Twilight Realm) + filtro DPS
(105925,'spell_ultraxion_fading_light'),
(105926,'spell_ultraxion_fading_light'),
(109075,'spell_ultraxion_fading_light'),
(109200,'spell_ultraxion_fading_light'),
(110068,'spell_ultraxion_fading_light'),
(110069,'spell_ultraxion_fading_light'),
(110070,'spell_ultraxion_fading_light'),
(110073,'spell_ultraxion_fading_light'),
(110074,'spell_ultraxion_fading_light'),
(110075,'spell_ultraxion_fading_light'),
(110078,'spell_ultraxion_fading_light'),
(110079,'spell_ultraxion_fading_light'),
(110080,'spell_ultraxion_fading_light'),
-- heroic will: remove -> Faded Into Twilight (threat reset)
(106108,'spell_ultraxion_heroic_will'),
-- last defender of azeroth: so tank recebe
(106182,'spell_ultraxion_last_defender_of_azeroth'),
(110327,'spell_ultraxion_last_defender_of_azeroth_dummy'),
(106080,'spell_ultraxion_last_defender_of_azeroth_dummy'),
(106226,'spell_ultraxion_last_defender_of_azeroth_dummy'),
(106227,'spell_ultraxion_last_defender_of_azeroth_dummy'),
(106224,'spell_ultraxion_last_defender_of_azeroth_dummy'),
-- timeloop: absorve morte, devolve 100% HP
(105984,'spell_ultraxion_time_loop'),
(105992,'spell_ultraxion_time_loop');
-- 4) Achievement Minutes to Midnight (6084) via aura 109188
-- DBC ACHIEVEMENT_CRITERIA 18391 (kill Ultraxion 55294) RequiredWorldStateID 6131 == 0
-- Aura 109188 e aplicada aos raiders (chain DBC 103327 -> 106370 -> 109188); reapply stack>1 = falha
DELETE FROM `spell_script_names` WHERE `spell_id`=109188;
INSERT IGNORE INTO `spell_script_names` (`spell_id`,`ScriptName`) VALUES
(109188,'spell_ultraxion_achievement_aura');

-- 5) creature_text Ultraxion 55294 (GroupID = enum ScriptedTexts boss_ultraxion.cpp)
-- SoundEntries.dbc 4.3.4 validado: aggro=26314, berserk(eruption)=26315, death=26316,
-- intro1=26317, intro2=26318, slay1-3=26319/26320/26321, spell1(HOT)=26323, spell2(Unstable)=26324
DELETE FROM `creature_text` WHERE `CreatureID`=55294;
INSERT INTO `creature_text` (`CreatureID`,`GroupID`,`ID`,`Text`,`Type`,`Language`,`Probability`,`Emote`,`Duration`,`Sound`,`SoundType`,`BroadcastTextId`,`TextRange`,`comment`) VALUES
(55294,0,0,'Now is the Hour of Twilight!',14,0,100,0,0,26314,0,0,0,'Ultraxion SAY_AGGRO VO_DS_ULTRAXION_AGGRO_01'),
(55294,1,0,'I WILL DRAG YOU WITH ME INTO FLAME AND DARKNESS!',14,0,100,0,0,26315,0,0,0,'Ultraxion SAY_BERSERK Twilight Eruption'),
(55294,2,0,'But...but...I am...Ul...trax...ionnnnnn...',14,0,100,0,0,26316,0,0,0,'Ultraxion SAY_DEATH VO_DS_ULTRAXION_DEATH_01'),
(55294,3,0,'I am the beginning of the end...the shadow which blots out the sun...the bell which tolls your doom...',14,0,100,0,0,26317,0,0,0,'Ultraxion SAY_INTRO_1 VO_DS_ULTRAXION_INTRO_01'),
(55294,4,0,'For this moment ALONE was I made. Look upon your death, mortals, and despair!',14,0,100,0,0,26318,0,0,0,'Ultraxion SAY_INTRO_2 VO_DS_ULTRAXION_INTRO_02'),
(55294,5,0,'Fall before Ultraxion!',14,0,34,0,0,26319,0,0,0,'Ultraxion SAY_KILL VO_DS_ULTRAXION_SLAY_01'),
(55294,5,1,'You have no hope!',14,0,33,0,0,26320,0,0,0,'Ultraxion SAY_KILL VO_DS_ULTRAXION_SLAY_02'),
(55294,5,2,'Hahahahahaha!',14,0,33,0,0,26321,0,0,0,'Ultraxion SAY_KILL VO_DS_ULTRAXION_SLAY_03'),
(55294,6,0,'The final shred of light fades, and with it, your pitiful mortal existence!',14,0,100,0,0,26323,0,0,0,'Ultraxion SAY_TWILIGHT Hour of Twilight VO_DS_ULTRAXION_SPELL_01'),
(55294,7,0,'Through the pain and fire my hatred burns!',14,0,100,0,0,26324,0,0,0,'Ultraxion SAY_UNSTABLE VO_DS_ULTRAXION_SPELL_02');

-- 6) creature_text Aspectos (invocados no encontro, Talk pelo boss AI via FindNearestCreature 300yd)
-- Thrall 56103 group 8 = Last Defender, Alextrasza 56099 group 6 = Gift of Life,
-- Ysera 56100 group 5 = Essence of Dreams, Kalecgos 56101 group 5 = Source of Magic,
-- Nozdormu 56102 group 2 = Timeloop
DELETE FROM `creature_text` WHERE `CreatureID` IN (56103,56099,56100,56101,56102);
INSERT INTO `creature_text` (`CreatureID`,`GroupID`,`ID`,`Text`,`Type`,`Language`,`Probability`,`Emote`,`Duration`,`Sound`,`SoundType`,`BroadcastTextId`,`TextRange`,`comment`) VALUES
(56103,8,0,'Strength of the Earth, hear my call! Shield them in this dark hour, the last defenders of Azeroth!',14,0,100,0,0,25907,0,0,0,'Thrall Last Defender VO_DS_THRALL_ULTRAXION_01'),
(56099,6,0,'Take heart, heroes, life will always blossom from the darkest soil!',14,0,100,0,0,26506,0,0,0,'Alexstrasza Gift of Life VO_DS_ALEXSTRAZA_ULTRAXION_01'),
(56100,5,0,'In dreams, we may overcome any obstacle.',14,0,100,0,0,26149,0,0,0,'Ysera Essence of Dreams VO_DS_YSERA_ULTRAXION_01'),
(56101,5,0,'Winds of the arcane be at their backs, and refresh them in this hour of darkness!',14,0,100,0,0,26267,0,0,0,'Kalecgos Source of Magic VO_DS_KALECGOS_ULTRAXION_01'),
(56102,2,0,'The cycle of time brings an end to all things.',14,0,100,0,0,25954,0,0,0,'Nozdormu Timeloop VO_DS_NOZDORMU_ULTRAXION_01');