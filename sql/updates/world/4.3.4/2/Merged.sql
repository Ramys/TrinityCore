UPDATE `spell_proc` SET `HitMask`= 0 WHERE `SpellId`= -9799;
DELETE FROM `spell_script_names` WHERE `ScriptName` = 'spell_gen_vehicle_control_link' AND `spell_id` IN (49078, 50343);
INSERT INTO `spell_script_names` (`spell_id`,`ScriptName`) VALUES
(49078, 'spell_gen_vehicle_control_link'),
(50343, 'spell_gen_vehicle_control_link');
DELETE FROM `spell_script_names` WHERE `ScriptName`= 'spell_hun_fire';
UPDATE `creature_template` SET `ScriptName`= 'npc_volkhan_molten_golem' WHERE `entry`= 28695;
UPDATE `creature_template` SET `mechanic_immune_mask`= `mechanic_immune_mask` | 0x2000000 | 0x100 WHERE `entry` IN (28587, 31536);

UPDATE `creature` SET `spawndist`= 0, `MovementType`= 0 WHERE `guid`= 126875;
DELETE FROM `creature_template_movement` WHERE `CreatureId`= 28823;
INSERT INTO `creature_template_movement` (`CreatureId`, `Ground`, `Swim`, `Flight`, `Rooted`) VALUES
(28823, 0, 0, 1, 1);

DELETE FROM `creature_text` WHERE `CreatureID`= 28587;
INSERT INTO `creature_text` (`CreatureID`, `GroupID`, `ID`, `Text`, `Type`, `Language`, `Probability`, `Emote`, `Duration`, `Sound`, `BroadcastTextId`, `comment`) VALUES
(28587, 0, 0, 'It is you who have destroyed my children? You... shall... pay!', 14, 0, 100, 0, 0, 13960, 31415, 'Volkhan - Aggro'),
(28587, 1, 0, '%s runs to his anvil!', 41, 0, 100, 0, 0, 0, 32214, 'Volkhan - Announce Run to Anvil'),
(28587, 2, 0, 'Nothing is wasted in the process. You will see....', 14, 0, 100, 0, 0, 13962, 31417, 'Volkhan - Run to Anvil'),
(28587, 2, 1, 'Life from lifelessness... death for you.', 14, 0, 100, 0, 0, 13961, 31416, 'Volkhan - Run to Anvil'),
(28587, 3, 0, 'All my work... undone!', 14, 0, 100, 0, 0, 13964, 31419, 'Volkhan - Shattering Stomp'),
(28587, 3, 1, 'I will crush you beneath my boots!', 14, 0, 100, 0, 0, 13963, 31418, 'Volkhan - Shattering Stomp'),
(28587, 4, 0, '%s prepares to shatter his Brittle Golems!', 41, 0, 100, 0, 0, 0, 29823, 'Volkhan - Announce Shattering Stomp'),
(28587, 5, 0, 'The master was right... to be concerned.', 14, 0, 100, 0, 0, 13968, 31423, 'Volkhan - Death');

DELETE FROM `conditions` WHERE `SourceEntry` IN (52661, 52654, 52238, 52387, 59528) AND `SourceTypeOrReferenceId`= 13;
INSERT INTO `conditions` (`SourceTypeOrReferenceId`, `SourceGroup`, `SourceEntry`, `SourceId`, `ElseGroup`, `ConditionTypeOrReference`, `ConditionTarget`, `ConditionValue1`, `ConditionValue2`, `ConditionValue3`, `NegativeCondition`, `ErrorType`, `ScriptName`, `Comment`) VALUES
(13, 1, 52661, 0, 0, 31, 0, 3, 28823, 0, 0, 0, '', 'Temper - Target Volkhan''s Anvil'),
(13, 1, 52654, 0, 0, 31, 0, 3, 28823, 0, 0, 0, '', 'Temper - Target Volkhan''s Anvil'),
(13, 1, 52238, 0, 0, 31, 0, 3, 28823, 0, 0, 0, '', 'Temper - Target Volkhan''s Anvil'),
(13, 1, 52387, 0, 0, 31, 0, 3, 28695, 0, 0, 0, '', 'Heat - Target Molten Golem'),
(13, 1, 59528, 0, 0, 31, 0, 3, 28695, 0, 0, 0, '', 'Heat - Target Molten Golem');

DELETE FROM `spell_script_names` WHERE `ScriptName` IN 
('spell_volkhan_temper_dummy',
'spell_volkhan_cool_down',
'spell_volkhan_cosmetic_stun_immune_permanent',
'spell_volkhan_shattering_stomp');

INSERT INTO `spell_script_names` (`spell_id`, `ScriptName`) VALUES
(52654, 'spell_volkhan_temper_dummy'),
(52238, 'spell_volkhan_temper_dummy'),
(52441, 'spell_volkhan_cool_down'),
(59123, 'spell_volkhan_cosmetic_stun_immune_permanent'),
(52237, 'spell_volkhan_shattering_stomp'),
(59529, 'spell_volkhan_shattering_stomp');
DELETE FROM `creature_template_addon` WHERE `entry` IN (28961, 30980, 28965, 30982);
INSERT INTO `creature_template_addon` (`entry`,`bytes2`, `auras`) VALUES
(28961, 0, '52898'),
(30980, 0, '52898'),
(28965, 0, '52881'),
(30982, 0, '52881');

 -- Titanium Siegebreaker smart ai
SET @ENTRY := 28961;
DELETE FROM `smart_scripts` WHERE `source_type` = 0 AND `entryOrGuid` = @ENTRY;
UPDATE `creature_template` SET `AIName` = 'SmartAI', `ScriptName` = '' WHERE `entry` = @ENTRY;
INSERT INTO `smart_scripts` (`entryorguid`, `source_type`, `id`, `link`, `event_type`, `event_phase_mask`, `event_chance`, `event_flags`, `event_param1`, `event_param2`, `event_param3`, `event_param4`, `action_type`, `action_param1`, `action_param2`, `action_param3`, `action_param4`, `action_param5`, `action_param6`, `target_type`, `target_param1`, `target_param2`, `target_param3`, `target_x`, `target_y`, `target_z`, `target_o`, `comment`) VALUES
(@ENTRY, 0, 0, 0, 2, 0, 100, 514, 0, 40, 10000, 15000, 11, 52891, 7, 0, 0, 0, 0, 1, 0, 0, 0, 0, 0, 0, 0, 'When health between 0%-40%% (check every 10000 - 15000 ms) - Self: Cast spell Blade Turning (52891) with flags interrupt previous, triggered, Flag unknown 4 on Self'),
(@ENTRY, 0, 1, 0, 2, 0, 100, 516, 0, 50, 10000, 15000, 11, 59173, 7, 0, 0, 0, 0, 1, 0, 0, 0, 0, 0, 0, 0, 'When health between 0%-50%% (check every 10000 - 15000 ms) - Self: Cast spell Blade Turning (59173) with flags interrupt previous, triggered, Flag unknown 4 on Self'),
(@ENTRY, 0, 2, 3, 7, 0, 100, 512, 0, 0, 0, 0, 22, 5, 0, 0, 0, 0, 0, 1, 0, 0, 0, 0, 0, 0, 0, 'On evade - Set event phase to phase 5'),
(@ENTRY, 0, 3, 0, 61, 0, 100, 0, 0, 0, 0, 0, 40, 1, 0, 0, 0, 0, 0, 1, 0, 0, 0, 0, 0, 0, 0, 'On evade - Self: Set sheath to Melee'),
(@ENTRY, 0, 4, 0, 4, 0, 100, 512, 0, 0, 0, 0, 28, 16245, 0, 0, 0, 0, 0, 1, 0, 0, 0, 0, 0, 0, 0, 'On aggro - Self: Remove aura due to spell Freeze Anim (16245)'),
(@ENTRY, 0, 5, 6, 38, 0, 35, 512, 1, 1, 0, 0, 19, 33555200, 0, 0, 0, 0, 0, 1, 0, 0, 0, 0, 0, 0, 0, 'On data[1] set to 1 - Self: Remove UNIT_FLAGS to IMMUNE_TO_PC, IMMUNE_TO_NPC, NOT_SELECTABLE'),
(@ENTRY, 0, 6, 0, 61, 0, 100, 0, 0, 0, 0, 0, 49, 0, 0, 0, 0, 0, 0, 21, 80, 0, 0, 0, 0, 0, 0, 'On data[1] set to 1 - Self: Attack Closest player in 80 yards'),
(@ENTRY, 0, 7, 0, 2, 0, 100, 513, 0, 20, 0, 0, 11, 19134, 2, 0, 0, 0, 0, 24, 0, 0, 0, 0, 0, 0, 0, 'When health between 0%-20%% (check once) - Self: Cast spell Frightening Shout (19134) with flags triggered on Threat list'),
(@ENTRY, 0, 8, 0, 9, 0, 100, 512, 0, 5, 10000, 15000, 11, 52890, 2, 0, 0, 0, 0, 7, 0, 0, 0, 0, 0, 0, 0, 'When victim in range 0 - 5 yards (check every 10000 - 15000 ms) - Self: Cast spell Penetrating Strike (52890) with flags triggered on Victim'),
(@ENTRY, 0, 9, 10, 63, 0, 100, 0, 0, 0, 0, 0, 85, 16245, 0, 0, 0, 0, 0, 1, 0, 0, 0, 0, 0, 0, 0, 'On just created - Self: Cast spell Freeze Anim (16245) on self'),
(@ENTRY, 0, 10, 0, 61, 0, 100, 0, 0, 0, 0, 0, 18, 33555200, 0, 0, 0, 0, 0, 1, 0, 0, 0, 0, 0, 0, 0, 'On just created - Self: Set UNIT_FLAGS to IMMUNE_TO_PC, IMMUNE_TO_NPC, NOT_SELECTABLE');

 -- Titanium Thunderer smart ai
SET @ENTRY := 28965;
DELETE FROM `smart_scripts` WHERE `source_type` = 0 AND `entryOrGuid` = @ENTRY;
UPDATE `creature_template` SET `AIName` = 'SmartAI', `ScriptName` = '' WHERE `entry` = @ENTRY;
INSERT INTO `smart_scripts` (`entryorguid`, `source_type`, `id`, `link`, `event_type`, `event_phase_mask`, `event_chance`, `event_flags`, `event_param1`, `event_param2`, `event_param3`, `event_param4`, `action_type`, `action_param1`, `action_param2`, `action_param3`, `action_param4`, `action_param5`, `action_param6`, `target_type`, `target_param1`, `target_param2`, `target_param3`, `target_x`, `target_y`, `target_z`, `target_o`, `comment`) VALUES
(@ENTRY, 0, 0, 0, 2, 0, 100, 514, 0, 40, 12000, 18000, 11, 52879, 7, 0, 0, 0, 0, 1, 0, 0, 0, 0, 0, 0, 0, 'When health between 0%-40%% (check every 12000 - 18000 ms) - Self: Cast spell Deflection (52879) with flags interrupt previous, triggered, Flag unknown 4 on Self'),
(@ENTRY, 0, 1, 0, 2, 0, 100, 516, 0, 65, 12000, 18000, 11, 59181, 7, 0, 0, 0, 0, 1, 0, 0, 0, 0, 0, 0, 0, 'When health between 0%-65%% (check every 12000 - 18000 ms) - Self: Cast spell Deflection (59181) with flags interrupt previous, triggered, Flag unknown 4 on Self'),
(@ENTRY, 0, 2, 3, 7, 0, 100, 512, 0, 0, 0, 0, 22, 5, 0, 0, 0, 0, 0, 1, 0, 0, 0, 0, 0, 0, 0, 'On evade - Set event phase to phase 5'),
(@ENTRY, 0, 3, 0, 61, 0, 100, 0, 0, 0, 0, 0, 40, 1, 0, 0, 0, 0, 0, 1, 0, 0, 0, 0, 0, 0, 0, 'On evade - Self: Set sheath to Melee'),
(@ENTRY, 0, 4, 0, 4, 0, 100, 512, 0, 0, 0, 0, 28, 16245, 0, 0, 0, 0, 0, 1, 0, 0, 0, 0, 0, 0, 0, 'On aggro - Self: Remove aura due to spell Freeze Anim (16245)'),
(@ENTRY, 0, 5, 6, 38, 0, 35, 512, 1, 1, 0, 0, 19, 33555200, 0, 0, 0, 0, 0, 1, 0, 0, 0, 0, 0, 0, 0, 'On data[1] set to 1 - Self: Remove UNIT_FLAGS to IMMUNE_TO_PC, IMMUNE_TO_NPC, NOT_SELECTABLE'),
(@ENTRY, 0, 6, 0, 61, 0, 100, 0, 0, 0, 0, 0, 49, 0, 0, 0, 0, 0, 0, 21, 80, 0, 0, 0, 0, 0, 0, 'On data[1] set to 1 - Self: Attack Closest player in 80 yards'),
(@ENTRY, 0, 7, 0, 13, 0, 100, 515, 45000, 60000, 0, 0, 11, 52885, 2, 0, 0, 0, 0, 7, 0, 0, 0, 0, 0, 0, 0, 'When victim is casting anyspell (check once) - Self: Cast spell Deadly Throw (52885) with flags triggered on Victim'),
(@ENTRY, 0, 8, 0, 13, 0, 100, 517, 45000, 60000, 0, 0, 11, 59180, 2, 0, 0, 0, 0, 7, 0, 0, 0, 0, 0, 0, 0, 'When victim is casting anyspell (check once) - Self: Cast spell Deadly Throw (59180) with flags triggered on Victim'),
(@ENTRY, 0, 9, 0, 0, 0, 100, 514, 0, 5000, 7000, 15000, 11, 52904, 2, 0, 0, 0, 0, 5, 0, 0, 0, 0, 0, 0, 0, 'Every 7 - 15 seconds (0 - 5s initially) (IC) - Self: Cast spell Throw (52904) with flags triggered on Random hostile'),
(@ENTRY, 0, 10, 0, 0, 0, 100, 516, 0, 5000, 7000, 15000, 11, 59179, 2, 0, 0, 0, 0, 5, 0, 0, 0, 0, 0, 0, 0, 'Every 7 - 15 seconds (0 - 5s initially) (IC) - Self: Cast spell Throw (59179) with flags triggered on Random hostile'),
(@ENTRY, 0, 11, 12, 63, 0, 100, 0, 0, 0, 0, 0, 85, 16245, 0, 0, 0, 0, 0, 1, 0, 0, 0, 0, 0, 0, 0, 'On just created - Self: Cast spell Freeze Anim (16245) on self'),
(@ENTRY, 0, 12, 0, 61, 0, 100, 0, 0, 0, 0, 0, 18, 33555200, 0, 0, 0, 0, 0, 1, 0, 0, 0, 0, 0, 0, 0, 'On just created - Self: Set UNIT_FLAGS to IMMUNE_TO_PC, IMMUNE_TO_NPC, NOT_SELECTABLE');
DELETE FROM `creature_text` WHERE `CreatureID`= 28587 AND `GroupID`= 6;
INSERT INTO `creature_text` (`CreatureID`, `GroupID`, `ID`, `Text`, `Type`, `Language`, `Probability`, `Emote`, `Duration`, `Sound`, `BroadcastTextId`, `comment`) VALUES
(28587, 6, 0, 'The armies of iron will conquer all!', 14, 0, 100, 0, 0, 13965, 31420, 'Volkhan - Slay'),
(28587, 6, 1, 'Feh! Pathetic!', 14, 0, 100, 0, 0, 13966, 31421, 'Volkhan - Slay'),
(28587, 6, 2, 'You have cost me too much work!', 14, 0, 100, 0, 0, 13967, 31422, 'Volkhan - Slay');
DELETE FROM `spell_script_names` WHERE `ScriptName`= 'spell_dru_natures_bounty';
INSERT INTO `spell_script_names` (`spell_id`, `ScriptName`) VALUES
(-17074, 'spell_dru_natures_bounty');

DELETE FROM `spell_proc` WHERE `SpellId`= -17074;
INSERT INTO `spell_proc` (`SpellId`, `SpellFamilyName`, `SpellFamilyMask0`, `ProcFlags`, `SpellTypeMask`, `SpellPhaseMask`, `Chance`) VALUES
(-17074, 7, 0x10, 0x4000, 0x4, 0x2, 100);
UPDATE `spell_script_names` SET `spell_id`= 11327 WHERE `ScriptName`= 'spell_rog_vanish';
UPDATE `spell_custom_attr` SET `attributes`= 0x2000 WHERE `entry`= 79461;
DELETE FROM `spell_script_names` WHERE `ScriptName`= 'spell_dk_dark_simulacrum';
INSERT INTO `spell_script_names` (`spell_id`, `ScriptName`) VALUES
(77606, 'spell_dk_dark_simulacrum');

DELETE FROM `spell_proc` WHERE `SpellId` IN (77606, 77616);
INSERT INTO `spell_proc` (`SpellId`, `SpellTypeMask`, `SpellPhaseMask`) VALUES
(77606 , 0x1 | 0x2 | 0x4, 0x1),
(77616 , 0x1 | 0x2 | 0x4, 0x1);
DELETE FROM `spell_script_names` WHERE `ScriptName`='spell_rog_pickpocket';
INSERT INTO `spell_script_names` (`spell_id`,`ScriptName`) VALUES
(921,'spell_rog_pickpocket');
ALTER TABLE `world_states`   
	ADD COLUMN `ScriptName` VARCHAR(64) NOT NULL AFTER `MapID`,
	CHANGE `Comment` `Comment` TEXT CHARSET utf8mb4 COLLATE utf8mb4_unicode_ci;

RENAME TABLE `world_states` TO `world_state`;
ALTER TABLE `world_state` CHANGE `MapID` `MapIDs` varchar(64) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci DEFAULT NULL;
DROP TABLE IF EXISTS `battlefield_template`;
CREATE TABLE `battlefield_template` (
  `TypeId` tinyint(3) unsigned NOT NULL,
  `ScriptName` varchar(64) NOT NULL,
  `comment` text,
  PRIMARY KEY(`TypeId`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

INSERT INTO `battlefield_template` (`TypeId`, `ScriptName`, `comment`) VALUES
(1, 'battlefield_wg', NULL),
(2, 'battlefield_tb', NULL);
DELETE FROM `world_state` WHERE `ID` IN (3490,3491,3680,3681,3698,3699,3700,3701,3702,3703,3704,3705,3706,3710,3711,3712,3713,3714,3749,3750,3751,3752,3753,3754,3755,3756,3757,3758,3759,3760,3761,3762,3763,3764,3765,3766,3767,3768,3769,3770,3771,3772,3773,3781,3801,3802,3803,4022,4023,4024,4025,4354);
INSERT INTO `world_state` (`ID`,`DefaultValue`,`MapIDs`,`Comment`, `ScriptName`) VALUES
(3490,0,'571,2118','Wintergrasp - Number of Horde vehicles',''),
(3491,0,'571,2118','Wintergrasp - Horde vehicle limit',''),
(3680,0,'571,2118','Wintergrasp - Number of Alliance vehicles',''),
(3681,0,'571,2118','Wintergrasp - Alliance vehicle limit',''),
(3698,0,'571,2138','Wintergrasp - Workshop',''),
(3699,0,'571,2138','Wintergrasp - Workshop',''),
(3700,0,'571,2138','Wintergrasp - Workshop',''),
(3701,0,'571,2138','Wintergrasp - Workshop',''),
(3702,0,'571,2138','Wintergrasp - Workshop',''),
(3703,0,'571,2138','Wintergrasp - Workshop',''),
(3704,0,'571,2138','Wintergrasp - Tower',''),
(3705,0,'571,2138','Wintergrasp - Tower',''),
(3706,0,'571,2138','Wintergrasp - Tower',''),
(3710,0,'571,2118','Wintergrasp - Show timer to battle end',''),
(3711,0,'571,2138','Wintergrasp - Keep tower',''),
(3712,0,'571,2138','Wintergrasp - Keep tower',''),
(3713,0,'571,2138','Wintergrasp - Keep tower',''),
(3714,0,'571,2138','Wintergrasp - Keep tower',''),
(3749,0,'571,2119','Wintergrasp - Wall',''),
(3750,0,'571,2120','Wintergrasp - Wall',''),
(3751,0,'571,2121','Wintergrasp - Wall',''),
(3752,0,'571,2122','Wintergrasp - Wall',''),
(3753,0,'571,2123','Wintergrasp - Wall',''),
(3754,0,'571,2124','Wintergrasp - Wall',''),
(3755,0,'571,2125','Wintergrasp - Wall',''),
(3756,0,'571,2126','Wintergrasp - Wall',''),
(3757,0,'571,2127','Wintergrasp - Wall',''),
(3758,0,'571,2128','Wintergrasp - Wall',''),
(3759,0,'571,2129','Wintergrasp - Wall',''),
(3760,0,'571,2130','Wintergrasp - Wall',''),
(3761,0,'571,2131','Wintergrasp - Wall',''),
(3762,0,'571,2132','Wintergrasp - Wall',''),
(3763,0,'571,2138','Wintergrasp - Keep gate',''),
(3764,0,'571,2133','Wintergrasp - Wall',''),
(3765,0,'571,2134','Wintergrasp - Wall',''),
(3766,0,'571,2134','Wintergrasp - Wall',''),
(3767,0,'571,2135','Wintergrasp - Wall',''),
(3768,0,'571,2134','Wintergrasp - Wall',''),
(3769,0,'571,2136','Wintergrasp - Wall',''),
(3770,0,'571,2134','Wintergrasp - Wall',''),
(3771,0,'571,2134','Wintergrasp - Wall',''),
(3772,0,'571,2138','Wintergrasp - Wall',''),
(3773,0,'571,2138','Wintergrasp - Relic gate',''),
(3781,0,'571,2118','Wintergrasp - Battle end time',''),
(3801,0,'571,2118','Wintergrasp - Show timer for next battle',''),
(3802,0,'571,2118','Wintergrasp - Defender',''),
(3803,0,'571,2118','Wintergrasp - Attacker',''),
(4022,0,'571,2118','Wintergrasp - Number of Horde wins as attacker',''),
(4023,0,'571,2118','Wintergrasp - Number of Alliance wins as attacker',''),
(4024,0,'571,2118','Wintergrasp - Number of Horde wins as defender',''),
(4025,0,'571,2118','Wintergrasp - Number of Alliance wins as defender',''),
(4354,0,'571,2118','Wintergrasp - Next battle start time','');
ALTER TABLE `world_state` CHANGE `ScriptName` `ScriptName` VARCHAR(64) CHARSET utf8mb4 COLLATE utf8mb4_unicode_ci DEFAULT '' NOT NULL;
ALTER TABLE `world_state` ADD `AreaIDs` varchar(255) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci DEFAULT NULL AFTER `MapIDs`;

UPDATE `world_state` SET `MapIDs`='571,2118',`AreaIDs`='4197,10176' WHERE `ID` IN (3490,3491,3680,3681,3698,3699,3700,3701,3702,3703,3704,3705,3706,3710,3711,3712,3713,3714,3749,3750,3751,3752,3753,3754,3755,3756,3757,3758,3759,3760,3761,3762,3763,3764,3765,3766,3767,3768,3769,3770,3771,3772,3773,3781,3801,3802,3803,4022,4023,4024,4025,4354);
DELETE FROM `world_state` WHERE `ID` IN (5332,5333,5334,5344,5346,5347,5348,5349,5350,5384,5385,5387,5418,5419,5420,5421,5422,5423,5424,5425,5426,5427,5428,5429,5430,5431,5432,5433,5434,5435,5436,5437,5438,5439,5440,5441,5442,5443,5444,5445,5446,5447,5451,5452,5453,5454,5455,5456,5469,5470,5546,5547,5684);
INSERT INTO `world_state` (`ID`, `DefaultValue`, `MapIDs`, `AreaIDs`, `ScriptName`, `Comment`) VALUES
(5332, 0, '732', '5095,5389', '', 'Tol Barad - Next battle start time'),
(5333, 0, '732', '5095', '', 'Tol Barad - Battle end time'),
(5334, 0, '732', '5095,5389', '', 'Tol Barad - Controlling faction'),
(5344, 0, '732', '5095', '', 'Tol Barad - In progress'),
(5346, 0, '732', '5095', '', 'Tol Barad - Show timer to battle end'),
(5347, 0, '732', '5095', '', 'Tol Barad - Number of destroyed towers'),
(5348, 0, '732', '5095', '', 'Tol Barad - Number of captured buildings'),
(5349, 0, '732', '5095', '', 'Tol Barad - Show number of captured buildings'),
(5350, 0, '732', '5095', '', 'Tol Barad - Show number of destroyed towers'),
(5384, 0, '732', '5095,5389', '', 'Tol Barad - Show if Horde is controlling'),
(5385, 0, '732', '5095,5389', '', 'Tol Barad - Show if Alliance is controlling'),
(5387, 0, '732', '5095,5389', '', 'Tol Barad - Show timer for next battle'),
(5418, 0, '732', '5095', '', 'Tol Barad - Ironclad Garrison controlled by Horde'),
(5419, 0, '732', '5095', '', 'Tol Barad - Ironclad Garrison being captured by Horde'),
(5420, 0, '732', '5095', '', 'Tol Barad - Ironclad Garrison neutral'),
(5421, 0, '732', '5095', '', 'Tol Barad - Ironclad Garrison being captured by Alliance'),
(5422, 0, '732', '5095', '', 'Tol Barad - Ironclad Garrison controlled by Alliance'),
(5423, 0, '732', '5095', '', 'Tol Barad - Warden\'s Vigil controlled by Horde'),
(5424, 0, '732', '5095', '', 'Tol Barad - Warden\'s Vigil being captured by Horde'),
(5425, 0, '732', '5095', '', 'Tol Barad - Warden\'s Vigil neutral'),
(5426, 0, '732', '5095', '', 'Tol Barad - Warden\'s Vigil being captured by Alliance'),
(5427, 0, '732', '5095', '', 'Tol Barad - Warden\'s Vigil controlled by Alliance'),
(5428, 0, '732', '5095', '', 'Tol Barad - Slagworks controlled by Horde'),
(5429, 0, '732', '5095', '', 'Tol Barad - Slagworks being captured by Horde'),
(5430, 0, '732', '5095', '', 'Tol Barad - Slagworks neutral'),
(5431, 0, '732', '5095', '', 'Tol Barad - Slagworks being captured by Alliance'),
(5432, 0, '732', '5095', '', 'Tol Barad - Slagworks controlled by Alliance'),
(5433, 0, '732', '5095', '', 'Tol Barad - West Spire Horde controlled'),
(5434, 0, '732', '5095', '', 'Tol Barad - West Spire Horde controlled, damaged'),
(5435, 0, '732', '5095', '', 'Tol Barad - West Spire destroyed'),
(5436, 0, '732', '5095', '', 'Tol Barad - West Spire Alliance controlled'),
(5437, 0, '732', '5095', '', 'Tol Barad - West Spire Alliance controlled, damaged'),
(5438, 0, '732', '5095', '', 'Tol Barad - South Spire Horde controlled'),
(5439, 0, '732', '5095', '', 'Tol Barad - South Spire Horde controlled, damaged'),
(5440, 0, '732', '5095', '', 'Tol Barad - South Spire destroyed'),
(5441, 0, '732', '5095', '', 'Tol Barad - South Spire Alliance controlled'),
(5442, 0, '732', '5095', '', 'Tol Barad - South Spire Alliance controlled, damaged'),
(5443, 0, '732', '5095', '', 'Tol Barad - East Spire Horde controlled'),
(5444, 0, '732', '5095', '', 'Tol Barad - East Spire Horde controlled, damaged'),
(5445, 0, '732', '5095', '', 'Tol Barad - East Spire destroyed'),
(5446, 0, '732', '5095', '', 'Tol Barad - East Spire Alliance controlled'),
(5447, 0, '732', '5095', '', 'Tol Barad - East Spire Alliance controlled, damaged'),
(5451, 0, '732', '5095', '', 'Tol Barad - East Spire uncontrolled'),
(5452, 0, '732', '5095', '', 'Tol Barad - East Spire damaged'),
(5453, 0, '732', '5095', '', 'Tol Barad - West Spire uncontrolled'),
(5454, 0, '732', '5095', '', 'Tol Barad - West Spire damaged'),
(5455, 0, '732', '5095', '', 'Tol Barad - South Spire uncontrolled'),
(5456, 0, '732', '5095', '', 'Tol Barad - South Spire damaged'),
(5469, 0, '732', '5095', '', 'Tol Barad - Baradin Hold controlled by Horde'),
(5470, 0, '732', '5095', '', 'Tol Barad - Baradin Hold controlled by Alliance'),
(5546, 0, '732', '5095,5389', '', 'Tol Barad - Show if Alliance is attacking'),
(5547, 0, '732', '5095,5389', '', 'Tol Barad - Show if Horde is attacking'),
(5684, 0, '732', '5095', '', 'Tol Barad - Preparation');
DELETE FROM `world_state` WHERE `ID` IN (2436,2453,2454,2540,2541,2784,2842,3104,3106,3479,3480,3486,3504,3524,3581,3582,3583,3584,3585,3810,3815,3816,3931,3932,4116,4129,4131,4162,4389,4390,4408,4882,4884,4903,4904,4940,4941,4942,5049,5050,5051,5636);
INSERT INTO `world_state` (`ID`,`DefaultValue`,`MapIDs`,`AreaIDs`,`Comment`) VALUES
(2436,0,'560','','The Escape from Durnholde - Incendiary Bombs Set'),
(2453,0,'534','','The Battle for Mount Hyjal - Show enemy count'),
(2454,0,'534','','The Battle for Mount Hyjal - Enemy count'),
(2540,100,'269','','Opening of the Dark Portal - Medivh\'s Shield Remaining'),
(2541,0,'269','','Opening of the Dark Portal - Show instance status'),
(2784,0,'269','','Opening of the Dark Portal - Time Rifts Opened'),
(2842,0,'534','','The Battle for Mount Hyjal - Wave counter'),
(3104,0,'568','','Zul\'Aman - Show timer'),
(3106,15,'568','','Zul\'Aman - Timer'),
(3479,0,'595','','The Culling of Stratholme - Show Plagued Crates Revealed'),
(3480,0,'595','','The Culling of Stratholme - Plagued Crates Revealed'),
(3486,0,'578','','The Oculus - Centrifuge Constructs Remaining'),
(3504,0,'595','','The Culling of Stratholme - Scourge Wave'),
(3524,0,'578','','The Oculus - Show Centrifuge Constructs Remaining'),
(3581,0,'595','','The Culling of Stratholme - Elder\'s Square Gate wave marker'),
(3582,0,'595','','The Culling of Stratholme - Festival Lane Gate wave marker'),
(3583,0,'595','','The Culling of Stratholme - King\'s Square Fountain wave marker'),
(3584,0,'595','','The Culling of Stratholme - Market Row Gate wave marker'),
(3585,0,'595','','The Culling of Stratholme - Town Hall wave marker'),
(3810,0,'608','','Violet Hold - Portals Opened'),
(3815,100,'608,1544','','Violet Hold - Prison Seal Integrity'),
(3816,0,'608,1544','','Violet Hold - Show'),
(3931,25,'595','','The Culling of Stratholme - Guardian time remaining'),
(3932,0,'595','','The Culling of Stratholme - Show Guardian time remaining'),
(4116,0,'603','','Ulduar - Yogg-Saron keepers active'),
(4129,4,'603','','Ulduar - Flame Leviathan destroyed towers'),
(4131,0,'603','','Ulduar - Algalon timer'),
(4162,0,'603','','Ulduar - Razorscale music'),
(4389,50,'649','','Trial of the Crusader - Attempts remaining'),
(4390,0,'649','','Trial of the Crusader - Show attempts remaining'),
(4408,0,'649','','Trial of the Crusader - Player death count'),
(4882,0,'668','','Halls of Reflection - Spirit Wave '),
(4884,0,'668','','Halls of Reflection - Show Spirit Wave '),
(5049,50,'724','','The Ruby Sanctum - Halion\'s corporeality (Normal)'),
(5050,50,'724','','The Ruby Sanctum - Halion\'s corporeality (Twilight)'),
(5051,0,'724','','The Ruby Sanctum - Show Halion\'s corporeality'),
(5636,0,'603','','Ulduar - Show Algalon timer');

DELETE FROM `achievement_criteria_data` WHERE `ScriptName` IN ('achievement_orbital_bombardment','achievement_orbital_devastation','achievement_nuked_from_orbit','achievement_orbit_uary');
UPDATE `spell_proc` SET `Cooldown`= 8 WHERE `SpellId`= -29074; -- Master of Elements
UPDATE `spell_proc` SET `Cooldown`= 8 WHERE `SpellId`= 10400; -- Flametongue (Passive)
UPDATE `spell_proc` SET `Cooldown`= 100 WHERE `SpellId`= 56835; -- Reaping (Passive)
UPDATE `spell_proc` SET `Cooldown`= 500 WHERE `SpellId`= 16164; -- Elemental Focus
UPDATE `spell_proc` SET `Cooldown`= 500 WHERE `SpellId`= 56821; -- Glyph of Sinister Strike

-- Arcane Concentration
DELETE FROM `spell_proc` WHERE `SpellId` IN (11213, 12574, 12575, -11213);
INSERT INTO `spell_proc` (`SpellId`, `SpellFamilyName`, `SpellTypeMask`, `SpellPhaseMask`, `Cooldown`) VALUES
(-11213, 3, 1, 2, 15000);
UPDATE `spell_proc` SET `SpellFamilyName`= 11, `ProcFlags`= 0, `SpellFamilyMask0`= 0x40 | 0x80 | 0x100, `SpellFamilyMask2`= 0x10 | 0x40000 | 0x10000 WHERE `SpellId`= -16180;
DELETE FROM `spell_script_names` WHERE `ScriptName`= 'spell_mage_ignite_periodic';
INSERT INTO `spell_script_names` (`spell_id`, `ScriptName`) VALUES
(12654, 'spell_mage_ignite_periodic');
