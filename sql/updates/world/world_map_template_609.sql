-- ============================================================
-- Fix: world_map_set_faction_worldstates_609
-- Origem: src/server/game/Maps/MapManager.cpp:497 AddSC_BuiltInScripts()
--         new SplitByFactionMapScript("world_map_set_faction_worldstates_%u", mapEntry->ID)
--         para todo mapa IsWorldMap() && IsSplitByFaction(). Mapa 609 se qualifica.
-- Causa do erro: src/server/game/Globals/ObjectMgr.cpp:9354 LoadScriptNames()
--         SELECT DISTINCT(ScriptName) FROM world_map_template WHERE ScriptName <> ''
--         Map 609 sem ScriptName -> GetScriptId(...) == 0 -> ScriptMgr.cpp:827 erro.
-- Fix DB: setar ScriptName em world_map_template para MapId 609.
-- Aplicar no banco 'world'.
-- ============================================================

-- Tabela world_map_template tem so (mapID, ScriptName). Se nao existe linha p/ 609, o UPDATE afeta 0 rows.
-- O INSERT abaixo cria a linha (INSERT cobre caso inexistente, UPDATE cobre existente).
INSERT INTO world_map_template (mapID, ScriptName) VALUES (609, 'world_map_set_faction_worldstates_609')
ON DUPLICATE KEY UPDATE ScriptName = VALUES(ScriptName);
