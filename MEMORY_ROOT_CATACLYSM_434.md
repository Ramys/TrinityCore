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

## Seção 2b: SpellScript / AuraScript API (Cataclysm 4.3.4) — CRÍTICO p/ port de MoP

Diferenças confirmadas nos headers reais deste core (`src/server/game/Spells/SpellScript.h`, `src/server/game/AI/CoreAI/UnitAI.h`) e em scripts existentes (`boss_alizabal.cpp`, `boss_occuthar.cpp`, `boss_pit_lord_argaloth.cpp`, etc.):

1. **Não existe `PrepareSpellScript` nem `PrepareAuraScript`** (macro ausente neste fork). Remova essas linhas dos scripts portados de MoP.
2. **Registro de hooks via `.Register(...)` direto** — não use `+= SpellHitFn(...)` / `+= AuraEffectCalcDamageFn(...)` (estilo antigo do TC 3.3.5). Exemplos reais:
   - `OnObjectAreaTargetSelect.Register(&spell_x::FilterTargets, EFFECT_0, TARGET_UNIT_SRC_AREA_ENEMY);`
   - `OnHit.Register(&spell_x::HandleOnHit);`
   - `AfterHit.Register(&spell_x::HandleAfterHit);`
   - `DoEffectCalcDamageAndHealing.Register(&spell_x::OnCalc, EFFECT_0, SPELL_AURA_DUMMY);`
3. **`SpellObjectAreaTargetSelectFn` / `SpellHitFn` (typedefs de wrapper) NÃO existem.** Passe `&Classe::Metodo` direto ao `.Register`.
4. **`SelectAggroTarget` (enum em `UnitAI.h`):** valores = `SELECT_TARGET_RANDOM`, `SELECT_TARGET_MAXTHREAT`, `SELECT_TARGET_MINTHREAT`, `SELECT_TARGET_MAXDISTANCE`, `SELECT_TARGET_MINDISTANCE`. **Não existe `SELECT_TARGET_NEAREST`** — use `SELECT_TARGET_MINDISTANCE` para "alvo mais próximo". O `SELECT_TARGET_NEAREST` do MoP vira `MINDISTANCE`.
5. **Handler de dano de aura (4.3.4):** assinatura `void OnCalc(AuraEffect const* aurEff, Unit* victim, int32& damageOrHealing, int32& flatMod, float& pctMod)`; o hook chama-se `DoEffectCalcDamageAndHealing` (não `DoEffectCalcDamage`).
6. **`AddSC_*` DEVE ficar em escopo GLOBAL (FORA de `namespace`).** O script loader (`kalimdor_script_loader.cpp`) declara e chama `void AddSC_boss_xxx();` em escopo global. Se a função for definida DENTRO de `namespace DragonSoul::Morchok { ... }`, o nome mangled vira `?AddSC_boss_xxx@Morchok@DragonSoul@@YAXXZ` e não bate com o global `?AddSC_boss_xxx@@YAXXZ` → **LNK2019 (símbolo externo não resolvido)** no link do `worldserver`. Padrão correto (vide exemplo ultraxion na Seção 1): as structs ficam DENTRO do namespace e `AddSC_*` FICA FORA, usando `using namespace DragonSoul::Morchok;` no corpo para acessar os tipos. Esta foi a causa exata do erro de link no port de `boss_morchok.cpp` (a função estava dentro do namespace).

Estes pontos (1 a 6) são a causa raiz dos erros de compilação/link no port de `boss_morchok.cpp` (MoP 5.4.8 -> Cata 4.3.4).

### Seção 2c: Gotchas adicionais (port `boss_morchok.cpp`, Cata 4.3.4)

Validado na migração de `boss_morchok.cpp` (MoP 5.4.8 -> Cata 4.3.4). Complementa a Seção 2b:

1. **EventMap — `GetPhaseMask()`, não `GetPhase()`**: Cata 4.3.4 não tem `EventMap::GetPhase()`. Usar `events.GetPhaseMask()` (retorna `uint8`) para ler a máscara, ou `events.IsInPhase(uint8 phase)` para testar fase específica. Ambos existem em `EventMap.h`.
2. **`Map::GetPlayers()` retorna referência**: assinatura é `Map::PlayerList const& GetPlayers()`, NÃO preenche `std::list<Player*>&` out-param. Iterar o retorno:
   ```cpp
   Map::PlayerList const& players = me->GetMap()->GetPlayers();
   for (Map::PlayerList::const_iterator it = players.begin(); it != players.end(); ++it)
       if (Player* p = it->GetSource()) { /* ... */ }
   ```
3. **`creature_text` — coluna `CreatureID` (não `entry`)**: schema usa `CreatureID` como 1ª coluna. Insert posicional padrão do repo: `(CreatureID, GroupID, ID, Text, Type, Language, Probability, Emote, Duration, Sound, BroadcastTextId, ...)`. Usar `entry` quebra a query. `Talk(SAY_*)` usa `GroupID`+`ID` (ambos começam em 0).
4. **IDs de spell/script Cata 4.3.4 ≠ MoP 5.4.8**: Morchok usa faixa `103xxx` (ex.: `103414`, `103687`, `103640`, `103494`, `103846`, `103785`, `103548`, `103558`, `104161`). Sempre re-verificar no `Spell.dbc` 4.3.4 (regra 3 da Seção 4). Não reaproveitar IDs do MoP.
5. **SpellScript hooks (Cata 4.3.4, `SpellScript.h`)**: NÃO usar `+= SpellEffectFn` (padrão antigo do TC). Registrar via `.Register()`:
   - `OnEffectHitTarget` (por alvo, handler `void(SpellEffIndex)`, disponibiliza `GetHitUnit()`): `OnEffectHitTarget.Register(&Classe::Handle, EFFECT_0, SPELL_EFFECT_SCHOOL_DAMAGE);` — usar para lógica por alvo (ex.: debuff heroico em `spell_morchok_stomp`).
   - `OnHit` / `BeforeHit` / `AfterHit` são `HitHook` = `HookHandler<void>` → handler `void()` (SEM args). Não servem para `GetHitUnit()` nem `SpellEffIndex`.
   - `CalcDamage` (`DamageAndHealingCalcHook`): handler `void(Unit* victim, int32& damage, int32& flatMod, float& pctMod)`; registrar `CalcDamage.Register(&Classe::CalculateDamage);`.
   - `OnObjectAreaTargetSelect`: `OnObjectAreaTargetSelect.Register(&Classe::Filter, EFFECT_0, TARGET_UNIT_DEST_AREA_ENEMY);`.
   - Erro comum (causou falha de compilação no port): `OnHit.Register(&Classe::Handle, EFFECT_0)` — `OnHit` handler é `void()` e `HitHook::Register` não aceita `EFFECT_0`. Use `OnEffectHitTarget` para alvo+índice.
6. **Frases de kill**: override `KilledUnit(Unit* victim)` -> `Talk(SAY_KILL)` para reproduzir as falas de kill do PDF.
7. **Exemplo `boss_ultraxion.cpp` é conceitual**: as Seções 1/4 citam `boss_ultraxion.cpp`, que NÃO existe neste fork. São apenas ilustrativos do padrão `namespace Zone::Boss { struct ... }; void AddSC_*()` fora do namespace. Usar `boss_jindo_the_godbreaker.cpp` (ZulGurub) como referência real compilável.
8. **World States em Maps**: `Map::SetWorldStateValue(uint32 variable, int32 value, bool hidden = false)` (em MoP era `Map::SetWorldState(variable, value)`).
9. **`CreatureAI::EvadeReason`**: Em Cata 4.3.4, `EnterEvadeMode(EvadeReason why)` requer argumento explícito (ex: `EnterEvadeMode(EVADE_REASON_OTHER)`). O enum usa `EVADE_REASON_SEQUENCE_BREAK` (e não `EVADE_REASON_SEQUENCE`).
10. **`SelectTarget` com Aura**: A assinatura completa é `SelectTarget(SelectAggroTarget targetType, uint32 offset = 0, float dist = 0.0f, bool playerOnly = false, bool withTank = true, int32 aura = 0)`. Nunca passar `aura` como 5º argumento, pois ele converte `int32 -> bool` para `withTank`. Sempre passe `withTank` explicitamente se passar `aura`.
11. **`FindNearestPlayer`**: Não existe em `Unit`/`Creature` no Cata 4.3.4. Buscar jogadores via `GetPlayerListInGrid(players, dist)` e ordenar com `players.sort(Trinity::ObjectDistanceOrderPred(me))` ou iterar com predicates.
12. **`UNIT_FLAG_DISABLE_MOVE`**: Flag exclusiva de MoP (5.x). Em Cata 4.3.4, imobilização de script é feita com `UNIT_FLAG_NOT_SELECTABLE | UNIT_FLAG_NON_ATTACKABLE`, `SetReactState(REACT_PASSIVE)` ou MotionMaster.
13. **`Unit::SetSpeed`**: Aceita 2 argumentos `(UnitMoveType type, float rate)`, sem o 3º booleano `forced` de MoP.
14. **`Creature::SetInCombatWithZone`**: Não existe em `Creature`. Chamar `if (c->AI()) c->AI()->DoZoneInCombat()`.
15. **`UnitAI::SetGUID`**: Assinatura em Cata 4.3.4 é `void SetGUID(ObjectGuid const& guid, int32 type) override` (requer `ObjectGuid const&`, não `uint64` ou tipo sem const ref).
16. **Literais Chrono em Expressões Aritméticas**: Evitar misturar chrono literals com funções randômicas (`12s + urand(...)`) para evitar falhas de dedução de template do MSVC; usar inteiros milissegundos explícitos (`12000 + urand(...)`).

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
9. **Namespaces**: Use `namespace ZoneName::ScriptName { ... }` para organizar structs/classes. A função `AddSC_*` fica FORA do namespace (escopo global) — ver Seção 2b ponto 6.

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
