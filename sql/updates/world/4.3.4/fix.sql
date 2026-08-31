-- ============================================================
-- Morchok (Dragon Soul) - script DB assignments
-- Fonte: boss_morchok.cpp :: AddSC_boss_morchok()
-- ============================================================

-- 1) Kohcrom creature AI (NPC_KOHCROM = 55274, dragon_soul.h)
UPDATE creature_template SET ScriptName = 'npc_morchok_kohcrom' WHERE entry = 55274;

-- 2) Spell scripts -> liga SpellScriptLoader ao spell ID
DELETE FROM spell_script_names WHERE spell_id IN (103414, 103494, 103785);
INSERT INTO spell_script_names (spell_id, ScriptName) VALUES
(103414, 'spell_morchok_stomp'),                       -- Stomp
(103494, 'spell_morchok_resonating_crystal_dmg'),      -- Resonating Crystal (dano)
(103785, 'spell_morchok_black_blood_of_the_earth_dmg');-- Black Blood of the Earth (dano)
