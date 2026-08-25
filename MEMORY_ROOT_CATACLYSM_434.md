# MEMORY ROOT: CATACLYSM 4.3.4 (The-Cataclysm-Preservation-Project)

**Objetivo**: Migrar scripts de MoP (5.4.8) para Cataclysm (4.3.4) seguindo o padrão exato deste core.

---

## Seção 1: Estrutura de Scripts no Cataclysm

### Organização de Pastas
- `src/server/scripts/Battlefield/`
- `src/server/scripts/Commands/`
- `src/server/scripts/Custom/`
- `src/server/scripts/EasternKingdoms/` (inclui `ZulGurub/`, `ZulAman/`, `BastionOfTwilight/`, `ThroneOfTheTides/`, etc.)
- `src/server/scripts/Events/`
- `src/server/scripts/Kalimdor/` (inclui `CavernsOfTime/` com `DragonSoul/`, `EndTime/`, `HourOfTwilight/`, `WellOfEternity/`, além de `Firelands/`)
- `src/server/scripts/Maelstrom/`
- `src/server/scripts/Northrend/`
- `src/server/scripts/OutdoorPvP/`
- `src/server/scripts/Outland/`
- `src/server/scripts/Pet/`
- `src/server/scripts/Spells/`
- `src/server/scripts/World/`

### Classe Base para Scripts
- **Criaturas (Boss)**: `struct boss_name : public BossAI`
- **Criaturas (NPC)**: `struct npc_name : public ScriptedAI`
- **GameObjects**: `class go_name : public GameObjectScript`
- **Instâncias**: `class instance_name : public InstanceScript`
- **Quests**: Geralmente lógicas em `SpellScript` ou `CreatureAI`
- **Spells**: `struct spell_name : public SpellScript` ou `class spell_name : public SpellScriptLoader`

### Classe de IA para Chefões (BossAI)
Exemplo real (extraído de `src/server/scripts/EasternKingdoms/ZulGurub/boss_jindo_the_godbreaker.cpp`):

```cpp
struct boss_jindo_the_godbreaker : public BossAI
{
    boss_jindo_the_godbreaker(Creature* creature) : BossAI(creature, DATA_JINDO_THE_GODBREAKER)
    {
        Initialize();
    }

    void Initialize()
    {
        // reset vars
    }

    void Reset() override
    {
        _Reset();
        Initialize();
        events.SetPhase(PHASE_PRE_FIGHT);
    }

    void JustEngagedWith(Unit* who) override
    {
        BossAI::JustEngagedWith(who);
        instance->SendEncounterUnit(ENCOUNTER_FRAME_ENGAGE, me);
        Talk(SAY_AGGRO);
        events.SetPhase(PHASE_ONE);
        events.ScheduleEvent(EVENT_SHADOWS_OF_HAKKAR, 21s, 0, PHASE_ONE);
    }

    void UpdateAI(uint32 diff) override
    {
        if (!UpdateVictim() && !events.IsInPhase(PHASE_PRE_FIGHT))
            return;

        events.Update(diff);

        if (me->HasUnitState(UNIT_STATE_CASTING))
            return;

        while (uint32 eventId = events.ExecuteEvent())
        {
            switch (eventId)
            {
                case EVENT_SHADOWS_OF_HAKKAR:
                    DoCastSelf(SPELL_SHADOWS_OF_HAKKAR);
                    events.Repeat(19s, 20s); // range
                    break;
                // ...
            }
        }
        DoMeleeAttackIfReady();
    }
};
```
Nota: `events` (EventMap) já é membro herdado de `BossAI` — **não redeclarar** na struct do boss.
```

### Sistema de Eventos (EventMap)
- **Membro**: em bosses (`BossAI`), `EventMap events;` é herdado de `BossAI` (definido em `ScriptedCreature.h`). Em NPCs simples (`ScriptedAI`), declare membro próprio — convenção do core: `EventMap _events;`.
- **Agendamento**: `events.ScheduleEvent(EVENT_ID, 1s, 0, PHASE_ID);`
  - `1s`, `500ms` são literais crono (C++11/TC).
  - O 3º param é `group` (geralmente 0).
  - O 4º param é `phase`.
- **Atualização**: `events.Update(diff);`
- **Execução**: `while (uint32 eventId = events.ExecuteEvent()) { ... }`
- **Repeat**: `events.Repeat(20s);` ou `events.Repeat(19s, 20s);` (min, max).
- **Fases**: `events.SetPhase(PHASE_ID);` e `events.IsInPhase(PHASE_ID)`.

### Hooks de Combate
- `JustEngagedWith(Unit* who)` — hook de início de combate deste core (declarado em `CreatureAI.h`). O antigo `EnterCombat` **NÃO existe** neste core.
- `JustDied(Unit* killer)`
- `EnterEvadeMode(EvadeReason why)`
- `DamageTaken(Unit* attacker, uint32& damage)`
- `JustAppeared()`
- `MovementInform(uint32 type, uint32 id)`
- `JustSummoned(Creature* summon)`
- `SummonedCreatureDies(Creature* summon, Unit* killer)`
- `DoAction(int32 action)`
- `UpdateAI(uint32 diff)`

### Sistema de Textos (Talk)
- Método: `Talk(uint8 textId, WorldObject* target = nullptr)` ou apenas `Talk(SAY_AGGRO)`.
- Definição: `enum Yells { SAY_INTRO = 0, SAY_AGGRO = 1, ... };`
- Textos são gerenciados pelo `CreatureTextMgr`.

### Sistema de Instâncias (InstanceScript)
- Acesso: `instance` (membro herdado de `BossAI`).
- Métodos: `instance->SetData(uint32 type, uint32 data)`, `instance->GetData(uint32 type)`.
- Unidades: `instance->GetCreature(DATA_ENUM)`, `instance->SendEncounterUnit(...)`.
- Summons: `summons.Summon(summon)`, `summons.DespawnAll()`.

### Constantes e Defines
- Geralmente dentro do namespace do script ou no topo do arquivo.
- `enum Spells { SPELL_NAME = ID };`
- `enum Events { EVENT_NAME = 1 };` (Começa em 1).
- `enum Phases { PHASE_ONE = 1 };`
- `enum Yells { SAY_... = 0 };`
- `Position const PosName = { x, y, z, o };`

---

## Seção 2: Tabela de Equivalência de APIs (MoP → Cataclysm)

| MoP (5.4.8) | Cataclysm (4.3.4) | Observação |
|-------------|-------------------|-------------|
| `JustEngagedWith(Unit* who)` | `JustEngagedWith(Unit* who)` | Igual. |
| `EnterCombat(Unit* who)` | `JustEngagedWith(Unit* who)` | Hook renomeado. Este core possui apenas `JustEngagedWith`; `EnterCombat` não existe. |
| `events.ScheduleEvent(id, delay, group, flags)` | `events.ScheduleEvent(id, delay, group, phase)` | Cata usa `phase` como 4º param. `delay` usa chrono literals (`1s`, `500ms`). |
| `DoCast(target, spellId, triggerFlags)` | `DoCast(target, spellId)` ou `me->CastSpell(target, spellId, true/false)` | `DoCast` simples é comum. |
| `BossAI` | `BossAI` | Estrutura idêntica. Construtor: `boss_name(Creature* c) : BossAI(c, DATA_ID)`. |
| `Talk(id, target)` | `Talk(id, target)` | Igual. |
| `SummonCreature(id, pos, tempSummonType, duration)` | `me->SummonCreature(id, pos, tempSummonType, duration)` ou `map->SummonCreature(...)` | `Map::SummonCreature` usado para evitar phasing issues. |
| `instance->GetData()` | `instance->GetData()` | `instance` é membro direto em `BossAI`. |
| `uint32 diff` em `UpdateAI` | `uint32 diff` | Igual. |

---

## Seção 3: Conteúdo que NÃO existe no Cataclysm

- **Pandaria (scripts em `Pandaria/`)**: Não existe.
- **LFR (Flex raiding)**: Não existe (Cataclysm tem LFR básico, mas não o sistema flexível de MoP).
- **Challenge Modes**: Não existe.
- **Cenários (Scenarios)**: Não existe.
- **Bonus Roll**: Não existe.
- **Pet Battles**: Não existe.
- **Monk Class**: Não existe (Cataclysm termina antes do MoP).

Regra: scripts dessas categorias **não devem ser migrados**. Substituir por comentário:
`// MoP-only: [nome do conteúdo] - not available in Cataclysm 4.3.4`

---

## Seção 4: Regras de Migração

1. **Estilo de Código**: O script migrado DEVE usar `struct` para AI de criaturas, `enum` para IDs, e `EventMap` para eventos.
2. **Nomenclatura**:
   - Boss: `struct boss_name : public BossAI`
   - NPC: `struct npc_name : public ScriptedAI`
   - Spell: `struct spell_name : public SpellScript`
3. **Nunca invente IDs** – consulte Wowhead Cata.
4. **Preserve a lógica** (timers, fases, condições) – altere apenas API e IDs.
5. **Quando não tiver certeza sobre uma API**, escreva da forma mais parecida possível com o estilo do Cata e marque com `// @TODO: VERIFICAR API NO REPO CATACLYSM`.
6. **Remova ou comente funcionalidades exclusivas do MoP**.
7. **Ao final, liste todas as dúvidas e pendências** para validação manual.
8. **Registro**: Use `RegisterZoneCreatureAI` ou macros específicos da zona (`RegisterZulGurubCreatureAI`).
9. **Namespaces**: Use `namespace ZoneName::ScriptName { ... }` para organização.

---

## Exemplo de Migração (Referência)

### Entrada (MoP):
```cpp
class boss_ultraxion : public CreatureScript
{
    struct boss_ultraxionAI : public BossAI
    {
        void JustEngagedWith(Unit* who) override
        {
            events.ScheduleEvent(EVENT_HOUR_OF_TWILIGHT, 15000);
        }
    };
};
```

### Saída (Cataclysm):
```cpp
namespace DragonSoul::Ultraxion
{
struct boss_ultraxion : public BossAI
{
    boss_ultraxion(Creature* creature) : BossAI(creature, DATA_ULTRAXION) { }

    void JustEngagedWith(Unit* who) override
    {
        BossAI::JustEngagedWith(who);
        instance->SendEncounterUnit(ENCOUNTER_FRAME_ENGAGE, me);
        events.ScheduleEvent(EVENT_HOUR_OF_TWILIGHT, 15s, 0, PHASE_ONE);
    }
};
}

void AddSC_boss_ultraxion()
{
    using namespace DragonSoul::Ultraxion;
    RegisterDragonSoulCreatureAI(boss_ultraxion);
}
```

Observações sobre o padrão de saída:
- Struct **sem sufixo** `AI` (padrão atual do core, ex.: `struct boss_jindo_the_godbreaker : public BossAI`).
- `events` herdado de `BossAI` — sem redeclaração.
- Registro usa a macro da zona (`RegisterZulGurubCreatureAI`, `RegisterDragonSoulCreatureAI`, etc.) dentro de `AddSC_*`, com `using namespace` do script.
