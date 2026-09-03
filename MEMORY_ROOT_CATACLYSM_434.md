# MEMORY ROOT: CATACLYSM 4.3.4

**Base**: [The-Cataclysm-Preservation-Project/TrinityCore](https://github.com/The-Cataclysm-Preservation-Project/TrinityCore) (master branch)
**Objetivo**: Referencia de API, padroes e convencoes do Cataclysm 4.3.4.15595. Sem MoP.

---

## 1. Estrutura de Scripts

```
src/server/scripts/
  Kalimdor/  EasternKingdoms/  Northrend/  Outland/
  Maelstrom/  Battlefield/  Events/  OutdoorPvP/
  Pet/  World/zone_xxxx.cpp  Spells/spell_xxxx.cpp  Custom/
```

Boss scripts: `instance_name.cpp` (instance) e `boss_name.cpp` (boss).

### AddSC_ registration

Toda funcao `AddSC_*` e' registrada em `scripts_init.cpp`:
```cpp
void AddSC_boss_example();
void AddSC_instance_example();
void AddScripts() { AddSC_boss_example(); AddSC_instance_example(); }
```
Sempre global. Nao criar funcoes `AddSC_` com linkage interno.

---

## 2. APIs Principais

### 2.1 EventMap

```cpp
enum Events { EVENT_ABILITY_1 = 1, EVENT_ABILITY_2 = 2, };
EventMap _events;

void Reset() override { _events.Reset(); }
void JustEngagedWith(Unit*) override { _events.ScheduleEvent(EVENT_ABILITY_1, 5s); }

void UpdateAI(uint32 diff) override
{
    if (!UpdateVictim()) return;
    _events.Update(diff);
    while (uint32 eventId = _events.ExecuteEvent())
    {
        switch (eventId)
        {
            case EVENT_ABILITY_1:
                DoCastVictim(SPELL_ABILITY_1);
                _events.Repeat(10s); break;
            case EVENT_ABILITY_2:
                if (Unit* t = SelectTarget(SELECT_TARGET_RANDOM, 0, 100.0f, true))
                    DoCast(t, SPELL_ABILITY_2);
                _events.Repeat(15s); break;
        }
    }
    DoMeleeAttackIfReady();
}
```

### 2.2 SpellScript / AuraScript

**CRITICO 4.3.4:** NAO existe `PrepareSpellScript()`. Scripts registrados via `RegisterSpellScript<ClassName>()`.

```cpp
class spell_example_effect : public SpellScript
{
    void HandleDummy(SpellEffIndex /*effIndex*/)
    {
        if (Unit* target = GetHitUnit())
            target->CastSpell(target, SPELL_EFFECT_EXAMPLE, true);
    }
    void Register() override
    {
        OnHit += SpellHitFn(spell_example_effect::HandleDummy);
    }
};
void AddSC_spell_example() { RegisterSpellScript<spell_example_effect>("spell_example_effect"); }
```

**SpellScript hooks:** `OnHit`, `AfterHit`, `OnLaunch`, `OnObjectPhaseTarget`, `CalcDamage`, `EffectSchoolDamage`.

**AuraScript hooks:** `DoEffectCalcDamageAndHealing` (NAO `DoEffectCalcDamage`), `OnEffectRemove`.

```cpp
class aura_example : public AuraScript
{
    void DoEffectCalcDamageAndHealing(AuraEffect const* /*aurEff*/, Unit* /*victim*/,
        int32& damageOrHealing, int32& /*flatMod*/, float& /*pctMod*/)
    {
        damageOrHealing /= 2;
    }
    void Register() override { DoEffectCalc += AuraEffectCalcDamageFn(aura_example::DoEffectCalcDamageAndHealing, EFFECT_0, SPELL_AURA_PERIODIC_DAMAGE); }
};
```

### 2.3 InstanceScript

```cpp
enum Data { DATA_BOSS_1 = 0, DATA_BOSS_2 = 1, MAX_ENCOUNTER = 2 };

struct instance_example : public InstanceScript
{
    instance_example(Map* map) : InstanceScript(map) { }
    void Initialize() override
    {
        SetHeaders("Instance Example");
        SetBossState(DATA_BOSS_1, NOT_STARTED);
        SetBossState(DATA_BOSS_2, NOT_STARTED);
    }
    ObjectGuid GetGuidData(uint32 type) const override { return ObjectGuid::Empty; }
    uint32 GetData(uint32 type) const override { return 0; }
    bool SetBossState(uint32 type, EncounterState state, Unit*) override
    {
        return InstanceScript::SetBossState(type, state);
    }
};
```

### 2.4 Acesso a Objetos

```cpp
// Players no mapa:
Map::PlayerList const& players = me->GetMap()->GetPlayers();
for (auto const& pair : players)
    if (Player* player = pair.GetSource()) { /* ... */ }

// Creature por entry:
std::list<Creature*> creatures;
me->GetCreatureListWithEntryInGrid(creatures, NPC_ENTRY, 200.0f);

// GameObjects (instance):
if (GameObject* go = GetGameObject(DATA_GUID))
    go->UseDoorOrButton();

// Distancia minima:
// Usar MINDISTANCE (1.0f) para melee range, nao hardcoded 5.0f.
```

---

## 3. Gotchas Especificos 4.3.4

### 3.1 Sem PrepareSpellScript
```cpp
// ERRADO (MoP+): PrepareSpellScript(spell_example_effect);
// CORRETO (4.3.4): RegisterSpellScript<spell_example_effect>("spell_example_effect");
```

### 3.2 Hooks void()
`OnHit` e `AfterHit` em SpellScript tem assinatura `void()` — sem parametro.

### 3.3 SelectTarget 6 parametros
```cpp
SelectTarget(SELECT_TARGET_RANDOM, 0, 100.0f, true);
//        ^type          ^index  ^dist   ^checkIfPlayer
```

### 3.4 Sem GetPlayerListInGrid
Usar `GetMap()->GetPlayers()` com iterador, ou `GetPlayersCountExceptGMs()`.

### 3.5 SetWorldStateValue
```cpp
DoUpdateWorldState(WORLD_STATE_ID, value);
```

### 3.6 EVADE_REASON_SEQUENCE_BREAK
Usar em `EnterEvadeMode()` quando boss perde target inesperadamente.

### 3.7 near / far macros Windows
Windows define `near`/`far` como macros. Evitar como nomes de variaveis:
```cpp
// ERRADO: void SetDistance(float near, float far);
// CORRETO: void SetDistance(float nearDist, float farDist);
```

### 3.8 Chrono + Rand MSVC workaround
```cpp
_events.Repeat(5s + std::chrono::milliseconds(rand() % 3000));
// ou
_events.RepeatEvent(5000 + (rand() % 3000)); // ms direto
```

### 3.9 Sem DoCastAOE
Nao existe `DoCastAOE()` em 4.3.4. Usar `DoCast(me, SPELL_ID)` ou `DoCastToAllUnitsInZone()`.

### 3.10 Sem GetDefaultMount
Handle mount data via spell ou DB direto.

### 3.11 CreatureTextMgr
```cpp
sCreatureTextMgr->SendChat(me, TEXT_INDEX, NULL, CHAT_MSG_ADDON, LANG_ADDON, TEXT_RANGE_NORMAL);
```

### 3.12 SpellInfo::GetEffect
Em 4.3.4: `SpellInfo::EffectInfo` struct com `Effect`, `BasePoints`, `Mechanic`. Nao confundir com API MoP `GetEffects()` iteravel.

### 3.13 DoEffectCalcDamageAndHealing
NAO `DoEffectCalcDamage`. Assinatura:
```cpp
void DoEffectCalcDamageAndHealing(AuraEffect const* aurEff, Unit* victim,
    int32& damageOrHealing, int32& flatMod, float& pctMod)
```

### 3.14 Position::m_orientation privado
`Position::m_orientation` é `private` (`Position.h:58`). Acesso direto não compila.
```cpp
// ERRADO:
float o = pos.m_orientation; pos.m_orientation = 3.14f;
// CORRETO:
float o = pos.GetOrientation(); pos.SetOrientation(3.14f);
Position p; p.Relocate(x, y, z, o);
```

### 3.15 ThreatManager::AddThreat (sem Creature::AddThreat)
`Creature` NÃO tem `AddThreat`. Usar `ThreatManager` via `Unit::GetThreatManager()` (`Unit.h:981`, `ThreatManager.h:377`).
```cpp
// ERRADO: creature->AddThreat(target, 10.0f);
// CORRETO:
creature->GetThreatManager().AddThreat(target, 10.0f, nullptr, true, true);
```

---

## 4. Conteudo Nao-Cata

Nao incluir nada de MoP (5.4.8), WotLK, ou expansions posteriores a 4.3.4.
Apis e padroes exclusivos de expansions anteriores nao existem aqui.
Se encontrar referencia a MoP em codigo, remover ou substituir por equivalente 4.3.4.

---

## 5. Regras de Escrita

- Documentacao em portugues pt-BR.
- C++ code blocks marcados com ` ```cpp `.
- SQL code blocks marcados com ` ```sql `.
- Usar 4 espacos para indentacao C++ (seguir `.clang-format` do projeto).
- Nao usar `using namespace std;` em headers.
- Headers incluir `#pragma once`.
- Enums para eventos e IDs: sempre `enum Events { ... }` com valores positivos.
- Commentar apenas codigo nao-obvio.

---

## 6. Formato de Commit

```
Core/Category: Short description

Detailed description if needed.
Fixes #issue_number
```

Categorias: `Core/Spells`, `Core/Creature`, `Core/Instances`, `Core/Maps`, `Core/Misc`, `DB/World`, `DB/Characters`, `DB/Auth`.

Exemplos:
```
Core/Spells: Fix spell_damage_done aura calculation
Core/Instances: Add DragonSoul instance script
DB/World: Update creature_text for Morchok encounter
```

---

## 7. Referencias

| Recurso | URL |
| :--- | :--- |
| TCP 4.3.4 upstream | https://github.com/The-Cataclysm-Preservation-Project/TrinityCore |
| Fork Ramys | https://github.com/Ramys/TrinityCore |
| CRULES.md | CRULES.md (regras de codificacao) |
| .clang-format | .clang-format (formatacao C++) |
| SpellDefines.h | src/server/game/Spells/SpellDefines.h |