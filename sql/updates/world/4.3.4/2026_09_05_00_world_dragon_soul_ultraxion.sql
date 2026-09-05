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