-- Morchok 55265 loot fix 10N/10H/25N/25H
-- Causa: bypass DamageTaken SetHealth(0)+JUST_DIED(nullptr) quebra Killer/lootRecipient (Unit::Kill + _JustDied sem killer = sem loot)
--       + difficulty_entry 57409/57771/57772 sem lootid => loot zero em 25N/10H/25H quando CreatureTemplate dificuldade carregado
-- C++ fix: boss_morchok.cpp DamageTaken heroico espelha 1 HP em lethal (deixa core matar com attacker correto), JustDied(killer) propaga killer para twin
-- Refs: Creature::GetCreatureTemplate()->lootid em Unit::Kill -> Loot::FillLoot(lootid, creature->GetLootMode())
--       sql/old/4.3.4/world/12_2016_09_28/2016_09_20_08_world.sql difficulty_entry_1=57409 difficulty_entry_2=57771 difficulty_entry_3=57772 WHERE entry=55265
--       sql/old/4.3.4/world/13_2016_11_06/2016_10_09_02_world.sql DB Loot 55265 lootid=55265 lootmode 1
-- Apply AFTER base The-Cataclysm-Preservation-Project

-- 1) Replica lootid para templates de dificuldade (blizzlike 4.3.4: mesmo loot table para todas dificuldades, Entrys diferentes só para stats/model)
UPDATE `creature_template` SET `lootid` = 55265 WHERE `entry` IN (57409, 57771, 57772);

-- 2) Garante ScriptName ainda correto nas dificuldades (evita AI faltando se spawnado direto com entry dificuldade)
UPDATE `creature_template` SET `ScriptName` = 'boss_morchok' WHERE `entry` IN (57409, 57771, 57772) AND (`ScriptName` IS NULL OR `ScriptName` = '');

-- 3) Garante lootmode default 1 (se DB custom setou lootmode heroico 2/4, reset para 1 = todas dificuldades dropam)
-- Não altera loot entries heroicas separadas; só normaliza caso existam overrides
-- (comentado - descomentar se lootmode 2/4 causou loot vazio)
-- UPDATE `creature_loot_template` SET `lootmode` = 1 WHERE `entry` = 55265;

-- Verificação:
-- SELECT entry, lootid, difficulty_entry_1, difficulty_entry_2, difficulty_entry_3, ScriptName FROM creature_template WHERE entry IN (55265, 57409, 57771, 57772);
-- SELECT COUNT(*) FROM creature_loot_template WHERE entry=55265; -- deve ~85 linhas (old 2016_10_09 file)
