# CRULES ÔÇö TrinityCore Cata 4.3.4 Code Rules

## SUMARIO

1. [ESTRUTURA DO PROJETO](#1-estrutura-do-projeto)
2. [PADRAO DE SCRIPTS C++](#2-padrao-de-scripts-c)
3. [BOSS/RAID TEMPLATE](#3-bossraid-template)
4. [SPELL SYSTEM](#4-spell-system)
5. [SMART AI](#5-smart-ai)
6. [SQL PATTERNS](#6-sql-patterns)
7. [INSTANCE SCRIPT](#7-instance-script)
8. [GAMEOBJECTS](#8-gameobjects)
9. [QUESTS](#9-quests)
10. [ACHIEVEMENTS](#10-achievements)
11. [DAMAGE SYSTEM](#11-damage-system)
12. [CONVENCOES C++](#12-convencoes-c)
13. [SISTEMA DE EVENTOS](#13-sistema-de-eventos)
14. [MOVEMENT GENERATORS](#14-movement-generators)

---

## 1. ESTRUTURA DO PROJETO

```
src/server/
  game/
    Scripting/
      ScriptSystem.cpp        ÔÇö Registro de scripts
      ScriptSystem.h
    Spell/
      Spell.cpp               ÔÇö Core do sistema de spells
      Spell.h
      SpellEffect.cpp         ÔÇö Efeitos de spells
      SpellEffects.cpp
      SpellMgr.cpp
      SpellMgr.h
      SpellInfo.cpp
    AI/
      SmartAI.cpp             ÔÇö SmartAI framework
      SmartAI.h
      CreatureAI.cpp
      CreatureAI.h
    Entities/
      Player/
      Creature/
      GameObject/
      Unit/
    Quests/
      QuestDef.cpp
      QuestDef.h
    Achievements/
      AchievementMgr.cpp
      AchievementMgr.h
    Instances/
      InstanceScript.cpp
      InstanceScript.h
    Maps/
      Map.cpp
      InstanceMap.cpp
    BattleGround/
      BattleGround.cpp
      BattleGround.h
```

Scripts de boss ficam em:
```
src/server/scripts/  
  Kalimdor/
  EasternKingdoms/
  Northrend/
  Outland/
  Maelstrom/
  Battlefield/
  Events/
  OutdoorPvP/
  Pet/
  World/
    zone_xxxx.cpp
  Spells/
    spell_xxxx.cpp
  Custom/
```

---

## 2. PADRAO DE SCRIPTS C++

### 2.1 Headers obrigatorios

```cpp
#include "ScriptMgr.h"
#include "ScriptedCreature.h"
#include "ScriptedGossip.h"
#include "CreatureAI.h"
#include "Player.h"
#include "SpellInfo.h"
#include "SpellScript.h"
#include "SpellAuraEffects.h"
#include "GameObjectAI.h"
#include "InstanceScript.h"
```

### 2.2 Estrutura de script de criatura

```cpp
class npc_example : public CreatureScript
{
public:
    npc_example() : CreatureScript("npc_example") { }

    struct npc_exampleAI : public ScriptedAI
    {
        npc_exampleAI(Creature* creature) : ScriptedAI(creature) { }

        void Reset() override
        {
            _events.Reset();
        }

        void UpdateAI(uint32 diff) override
        {
            if (!UpdateVictim())
                return;

            _events.Update(diff);

            while (uint32 eventId = _events.ExecuteEvent())
            {
                switch (eventId)
                {
                    case EVENT_SPELL_EXAMPLE:
                        if (Unit* target = SelectTarget(SELECT_TARGET_RANDOM, 0, 100.0f, true))
                            DoCast(target, SPELL_EXAMPLE);
                        _events.Repeat(15000);
                        break;
                }
            }

            DoMeleeAttackIfReady();
        }

    private:
        EventMap _events;
    };

    CreatureAI* GetAI(Creature* creature) const override
    {
        return new npc_exampleAI(creature);
    }
};
```

### 2.3 Registro obrigatorio

```cpp
void AddSC_example()
{
    new npc_example();
}
```

No fim do arquivo. Nome da funcao = `AddSC_` + nome do arquivo.

Registrar no `<zona>_script_loader.cpp` da zona (ex.: `eastern_kingdoms_script_loader.cpp`), dentro de `AddSC_<zona>()`.

---

## 3. BOSS/RAID TEMPLATE

### 3.1 Estrutura completa de boss

```cpp
enum Spells
{
    SPELL_BOSS_FIREBALL        = 123456,
    SPELL_BOSS_AOE             = 123457,
    SPELL_BOSS_ENRAGE          = 123458,
    SPELL_BOSS_SUMMON          = 123459,
};

enum Events
{
    EVENT_BOSS_FIREBALL        = 1,
    EVENT_BOSS_AOE,
    EVENT_BOSS_ENRAGE,
    EVENT_BOSS_SUMMON,
    EVENT_BOSS_PHASE_TWO,
};

enum Phases
{
    PHASE_ONE                  = 1,
    PHASE_TWO,
};

enum Creatures
{
    NPC_BOSS_MINION            = 123456,
    NPC_BOSS_TRIGGER           = 123457,
};

enum GameObjects
{
    GO_BOSS_DOOR               = 123456,
    GO_BOSS_CHEST              = 123457,
};

class boss_example : public CreatureScript
{
public:
    boss_example() : CreatureScript("boss_example") { }

    struct boss_exampleAI : public BossAI
    {
        boss_exampleAI(Creature* creature) : BossAI(creature, DATA_BOSS_EXAMPLE)
        {
            _justSpawned = false;
        }

        void Reset() override
        {
            _Reset();  // BossAI::Reset()
            _phase = PHASE_ONE;
            _enraged = false;
            me->SetFloatValue(UNIT_FIELD_BOUNDINGRADIUS, 15.0f);
            me->SetFloatValue(UNIT_FIELD_COMBATREACH, 15.0f);
            me->SetHomePosition(me->GetPosition());
            SetCombatMovement(true);
        }

        void JustEngagedWith(Unit* who) override
        {
            _JustEngagedWith(who);  // BossAI::JustEngagedWith()

            // Notify InstanceScript
            if (instance)
                instance->SetBossState(DATA_BOSS_EXAMPLE, IN_PROGRESS);

            // Schedule events
            _events.ScheduleEvent(EVENT_BOSS_FIREBALL, 8000);
            _events.ScheduleEvent(EVENT_BOSS_AOE, 20000);
            _events.ScheduleEvent(EVENT_BOSS_ENRAGE, 60000);
            _events.ScheduleEvent(EVENT_BOSS_SUMMON, 15000);

            Talk(SAY_AGGRO);
            DoZoneInCombat();
        }

        void JustDied(Unit* killer) override
        {
            _JustDied();  // BossAI::JustDied()

            if (instance)
            {
                instance->SetBossState(DATA_BOSS_EXAMPLE, DONE);
                instance->SaveToDB();
            }

            // Spawn loot chest
            if (GameObject* chest = me->SummonGameObject(GO_BOSS_CHEST, posX, posY, posZ, 0.0f, 0, 0, 0, 0, 3600000))
                chest->SetLootRecipients(chest->GetLootRecipients());

            Talk(SAY_DEATH);
        }

        void JustReachedHome() override
        {
            _JustReachedHome();
            if (instance)
                instance->SetBossState(DATA_BOSS_EXAMPLE, FAIL);
        }

        void KilledUnit(Unit* victim) override
        {
            if (victim->GetTypeId() == TYPEID_PLAYER)
                Talk(SAY_KILL);
        }

        void EnterEvadeMode(EvadeReason why) override
        {
            BossAI::EnterEvadeMode(why);
        }

        void DamageTaken(Unit* attacker, uint32& damage, DamageEffectType damageType, SpellInfo const* spellInfo) override
        {
            // Phase transition at 50% HP
            if (!_phaseTwo && me->HealthBelowPctDamaged(50, damage))
            {
                _phaseTwo = true;
                _events.CancelEvent(EVENT_BOSS_FIREBALL);
                _events.CancelEvent(EVENT_BOSS_AOE);
                _events.ScheduleEvent(EVENT_BOSS_PHASE_TWO, 1000);

                me->SetFullHealth();
                Talk(SAY_PHASE_TWO);
            }

            // Enrage at 10%
            if (!_enraged && me->HealthBelowPctDamaged(10, damage))
            {
                _enraged = true;
                DoCast(me, SPELL_BOSS_ENRAGE);
                Talk(SAY_ENRAGE);
            }
        }

        void UpdateAI(uint32 diff) override
        {
            if (!UpdateVictim())
                return;

            _events.Update(diff);

            if (me->HasUnitState(UNIT_STATE_CASTING))
                return;

            while (uint32 eventId = _events.ExecuteEvent())
            {
                switch (eventId)
                {
                    case EVENT_BOSS_FIREBALL:
                        if (Unit* target = SelectTarget(SELECT_TARGET_RANDOM, 0, 100.0f, true))
                            DoCast(target, SPELL_BOSS_FIREBALL);
                        _events.Repeat(12000);
                        break;

                    case EVENT_BOSS_AOE:
                        DoCastAOE(SPELL_BOSS_AOE);
                        _events.Repeat(25000);
                        break;

                    case EVENT_BOSS_ENRAGE:
                        // Handled in DamageTaken
                        break;

                    case EVENT_BOSS_SUMMON:
                        for (int i = 0; i < 3; ++i)
                        {
                            float x, y, z;
                            me->GetRandomPoint(me->GetPositionX(), me->GetPositionY(), me->GetPositionZ(), 20.0f, x, y, z);
                            me->SummonCreature(NPC_BOSS_MINION, x, y, z, 0.0f, TEMPSUMMON_CORPSE_TIMED_DESPAWN, 30000);
                        }
                        _events.Repeat(30000);
                        break;

                    case EVENT_BOSS_PHASE_TWO:
                        DoCast(me, SPELL_BOSS_AOE);
                        _events.ScheduleEvent(EVENT_BOSS_FIREBALL, 5000);
                        _events.ScheduleEvent(EVENT_BOSS_AOE, 15000);
                        break;
                }
            }

            DoMeleeAttackIfReady();
        }

        void MoveInLineOfSight(Unit* who) override
        {
            // Trigger combat on sight
            if (!me->IsInCombat() && who->GetTypeId() == TYPEID_PLAYER && me->IsWithinDistInMap(who, 80.0f))
                AttackStart(who);
        }

        void SpellHit(Unit* caster, SpellInfo const* spell) override
        {
            if (spell->Id == SPELL_PLAYER_INTERRUPT)
            {
                // Boss reaction to interrupt
                DoCast(me, SPELL_BOSS_INTERRUPT_REACTION);
            }
        }

    private:
        uint8 _phase;
        bool _enraged;
        bool _phaseTwo;
    };

    CreatureAI* GetAI(Creature* creature) const override
    {
        return new boss_exampleAI(creature);
    }
};
```

### 3.2 BossAI vs ScriptedAI

| Classe | Quando usar |
|--------|------------|
| `BossAI` | Raids/Dungeons com InstanceScript |
| `ScriptedAI` | NPCs, world bosses, criaturas soltas |

BossAI ja tem:
- `instance` ponteiro pro InstanceScript (membro do BossAI)
- `_Reset()` / `_EnterCombat()` / `_JustDied()` (notificam instance)
- `_DespawnAtEvade()` (despawn minions no evade)
- Gerenciamento de summons (adds seguem boss no evade)

---

## 4. SPELL SYSTEM

### 4.1 Spell Script

```cpp
class spell_example : public SpellScriptLoader
{
public:
    spell_example() : SpellScriptLoader("spell_example") { }

    class spell_example_SpellScript : public SpellScript
    {
        PrepareSpellScript(spell_example_SpellScript);

        bool Validate(SpellInfo const* /*spellEntry*/) override
        {
            if (!sSpellMgr->GetSpellInfo(SPELL_EXAMPLE))
                return false;
            return true;
        }

        bool Load() override
        {
            return true;
        }

        void HandleAfterHit()
        {
            if (Unit* target = GetHitUnit())
            {
                // Apply custom effect
                target->CastSpell(target, SPELL_EXAMPLE_EFFECT, true);
            }
        }

        void Register() override
        {
            AfterHit += SpellHitFn(spell_example_SpellScript::HandleAfterHit);
        }
    };

    SpellScript* GetSpellScript() const override
    {
        return new spell_example_SpellScript();
    }
};
```

### 4.2 Aura Script

```cpp
class spell_example_aura : public AuraScript
{
    PrepareAuraScript(spell_example_aura);

    void OnApply(AuraEffect const* /*aurEff*/, AuraEffectHandleModes /*mode*/)
    {
        if (Unit* target = GetTarget())
        {
            // Apply logic
        }
    }

    void OnRemove(AuraEffect const* /*aurEff*/, AuraEffectHandleModes /*mode*/)
    {
        if (Unit* target = GetTarget())
        {
            // Remove logic
        }
    }

    void OnTick(AuraEffect const* aurEff)
    {
        if (Unit* target = GetTarget())
        {
            // Periodic effect
        }
    }

    void Register() override
    {
        OnEffectApply += AuraEffectApplyFn(spell_example_aura::OnApply, EFFECT_0, SPELL_AURA_PERIODIC_DAMAGE, AURA_EFFECT_HANDLE_REAL);
        OnEffectRemove += AuraEffectRemoveFn(spell_example_aura::OnRemove, EFFECT_0, SPELL_AURA_PERIODIC_DAMAGE, AURA_EFFECT_HANDLE_REAL);
        OnEffectPeriodic += AuraEffectPeriodicFn(spell_example_aura::OnTick, EFFECT_0, SPELL_AURA_PERIODIC_DAMAGE);
    }
};
```

### 4.3 Spell hooks disponiveis

| Hook | Descricao |
|------|-----------|
| `OnCast` | Quando spell comeca a ser castada |
| `AfterCast` | Depois do cast |
| `OnHit` | Quando spell acerta um alvo |
| `AfterHit` | Depois do hit |
| `OnEffectHit` | Quando um efeito especfico acerta |
| `OnEffectHitTarget` | Quando um efeito acerta o alvo |
| `CheckCast` | Validacao (retorna SPELL_CAST_OK ou erro) |
| `OnObjectAreaTargetSelect` | Filtragem de alvos area |
| `OnSingleTargetSelect` | Filtragem de alvo unico |

### 4.4 DBC SpellInfo fields importantes

```cpp
spellInfo->Id                 // ID da spell
spellInfo->SchoolMask         // Magic school
spellInfo->DurationEntry      // Duracao
spellInfo->Effects[EFFECT_0]  // Efeitos (SpellEffectEntry)
spellInfo->GetMaxTicks()      // Max ticks periodic
spellInfo->Effects[EFFECT_0].CalcValue(caster)   // Valor calculado
spellInfo->Effects[EFFECT_0].TargetA             // Tipo de alvo
```

### 4.5 Spell effect types comuns

```cpp
SPELL_AURA_PERIODIC_DAMAGE    // Dano periodico (DoT)
SPELL_AURA_PERIODIC_HEAL      // Heal periodico (HoT)
SPELL_AURA_MOD_DAMAGE_PERCENT_DONE  // Aumenta dano feito
SPELL_AURA_MOD_DAMAGE_PERCENT_TAKEN // Aumenta dano recebido
SPELL_AURA_MOD_STUN           // Stun
SPELL_AURA_MOD_FEAR           // Fear
SPELL_AURA_MOD_ROOT           // Root
SPELL_AURA_MOD_SILENCE        // Silence
SPELL_EFFECT_KNOCK_BACK       // Knockback
SPELL_EFFECT_LEAP             // Charge
SPELL_EFFECT_TELEPORT_UNITS   // Teleport
SPELL_EFFECT_SUMMON           // Summon
SPELL_EFFECT_CREATE_ITEM      // Criar item
```

---

## 5. SMART AI

### 5.1 Estrutura SmartAI no SQL

```sql
-- Evento basico: cast spell quando entra em combate
INSERT INTO `smart_scripts` (`entryorguid`, `source_type`, `id`, `link`, 
    `event_type`, `event_phase_mask`, `event_chance`, `event_flags`,
    `event_param1`, `event_param2`, `event_param3`, `event_param4`, `event_param5`,
    `action_type`, `action_param1`, `action_param2`, `action_param3`, `action_param4`, `action_param5`,
    `target_type`, `target_param1`, `target_param2`, `target_param3`, `target_param4`,
    `comment`)
VALUES
    (123456, 0, 0, 0,
     4, 0, 100, 0,           -- event_type 4 = OnAggro
     0, 0, 0, 0, 0,          -- event params
     11, 123456, 0, 0, 0, 0, -- action_type 11 = Cast spell, param1 = spell ID
     1, 0, 0, 0, 0,          -- target_type 1 = Self
     'NPC Example - Cast spell on aggro');
```

### 5.2 SmartAI event types

| event_type | Nome no core | Parametros |
|-----------|--------------|------------|
| 0 | SMART_EVENT_UPDATE_IC | initialMin, initialMax, repeatMin, repeatMax |
| 1 | SMART_EVENT_UPDATE_OOC | initialMin, initialMax, repeatMin, repeatMax |
| 2 | SMART_EVENT_HEALT_PCT | HPMin%, HPMax%, repeatMin, repeatMax |
| 3 | SMART_EVENT_MANA_PCT | ManaMin%, ManaMax%, repeatMin, repeatMax |
| 4 | SMART_EVENT_AGGRO | - |
| 5 | SMART_EVENT_KILL | cooldownMin, cooldownMax, playerOnly, creatureEntry |
| 6 | SMART_EVENT_DEATH | - |
| 7 | SMART_EVENT_EVADE | - |
| 8 | SMART_EVENT_SPELLHIT | spellId, schoolMask, cooldownMin, cooldownMax |
| 9 | SMART_EVENT_RANGE | minDist, maxDist, repeatMin, repeatMax |
| 10 | SMART_EVENT_OOC_LOS | noHostile, maxDist, cooldownMin, cooldownMax |
| 11 | SMART_EVENT_RESPAWN | type, mapId, zoneId |
| 12 | SMART_EVENT_TARGET_HEALTH_PCT | HPMin%, HPMax%, repeatMin, repeatMax |
| 13 | SMART_EVENT_VICTIM_CASTING | repeatMin, repeatMax, spellId |
| 16 | SMART_EVENT_FRIENDLY_MISSING_BUFF | spellId, radius, repeatMin, repeatMax |
| 22 | SMART_EVENT_RECEIVE_EMOTE | emoteId, cooldownMin, cooldownMax |
| 25 | SMART_EVENT_RESET | - |
| 31 | SMART_EVENT_SPELLHIT_TARGET | spellId, schoolMask, cooldownMin, cooldownMax |
| 34 | SMART_EVENT_MOVEMENTINFORM | movementType (POINT_MOTION_TYPE=8), pointId |
| 61 | SMART_EVENT_LINK | uso interno - encadeia acoes |
| 62 | SMART_EVENT_GOSSIP_SELECT | menuID, actionID |

Fonte da verdade: `enum SMART_EVENT` em `src/server/game/AI/SmartScripts/SmartScriptMgr.h`. Consultar la para a lista completa.

### 5.3 SmartAI action types

| action_type | Nome no core | Parametros |
|------------|--------------|------------|
| 1 | SMART_ACTION_TALK | groupId creature_text, duration, useTalkTarget |
| 2 | SMART_ACTION_SET_FACTION | factionId (0=default) |
| 5 | SMART_ACTION_PLAY_EMOTE | emoteId |
| 8 | SMART_ACTION_SET_REACT_STATE | 0=passive, 1=defensive, 2=aggressive |
| 9 | SMART_ACTION_ACTIVATE_GOBJECT | - |
| 11 | SMART_ACTION_CAST | spellId, castFlags, triggeredFlags |
| 12 | SMART_ACTION_SUMMON_CREATURE | creatureId, summonType, duration(ms), attackInvoker |
| 18/19 | SMART_ACTION_SET/REMOVE_UNIT_FLAG | flags, target |
| 21 | SMART_ACTION_ALLOW_COMBAT_MOVEMENT | 0=stop, else continue |
| 22 | SMART_ACTION_SET_EVENT_PHASE | phase |
| 23 | SMART_ACTION_INC_EVENT_PHASE | value (+/-) |
| 28 | SMART_ACTION_REMOVEAURASFROMSPELL | spellId (0=all), charges |
| 29 | SMART_ACTION_FOLLOW | distance, angle, endCreatureEntry, credit |
| 33 | SMART_ACTION_CALL_KILLEDMONSTER | creatureId |
| 34 | SMART_ACTION_SET_INST_DATA | field, data, type (0=SetData, 1=SetBossState) |
| 35 | SMART_ACTION_SET_INST_DATA64 | field |
| 37 | SMART_ACTION_DIE | - |
| 38 | SMART_ACTION_SET_IN_COMBAT_WITH_ZONE | - |
| 41 | SMART_ACTION_FORCE_DESPAWN | timer |
| 45 | SMART_ACTION_SET_DATA | field, data |
| 53 | SMART_ACTION_WP_START | run/walk, pathID, canRepeat, quest, despawntime, reactState |
| 54/55/56 | SMART_ACTION_WP_PAUSE/STOP/RESUME | time / despawnTime,quest / - |
| 59 | SMART_ACTION_SET_RUN | 0=walk, 1=run |
| 62 | SMART_ACTION_TELEPORT | mapId (xyz via target POSITION) |
| 64 | SMART_ACTION_STORE_TARGET_LIST | varID |
| 67/73/74 | CREATE/TRIGGER/REMOVE_TIMED_EVENT | id, minMax... / id / id |
| 71 | SMART_ACTION_EQUIP | entry, slotmask, slot1-3 |
| 75 | SMART_ACTION_ADD_AURA | spellId, targets |
| 81/82/83 | SET/ADD/REMOVE_NPC_FLAG | flags |
| 85 | SMART_ACTION_SELF_CAST | spellId, castFlags |
| 98 | SMART_ACTION_SEND_GOSSIP_MENU | menuId, optionId |
| 101 | SMART_ACTION_SET_HOME_POS | - |
| 104/105/106 | SET/ADD/REMOVE_GO_FLAG | flags |
| 107 | SMART_ACTION_SUMMON_CREATURE_GROUP | group, attackInvoker |
| 118 | SMART_ACTION_GO_SET_GO_STATE | state |
| 124 | SMART_ACTION_LOAD_EQUIPMENT | id |
| 134 | SMART_ACTION_INVOKER_CAST | spellId, castFlags |
| 136 | SMART_ACTION_SET_MOVEMENT_SPEED | movementType, speedInteger, speedFraction |

Fonte da verdade: `enum SMART_ACTION` em `src/server/game/AI/SmartScripts/SmartScriptMgr.h`. Consultar la para a lista completa.

### 5.4 SmartAI target types

| target_type | Nome no core | Parametros |
|-----------|--------------|------------|
| 0 | SMART_TARGET_NONE | - |
| 1 | SMART_TARGET_SELF | - |
| 2 | SMART_TARGET_VICTIM | - |
| 3 | SMART_TARGET_HOSTILE_SECOND_AGGRO | maxDist, playerOnly, powerType+1 |
| 4 | SMART_TARGET_HOSTILE_LAST_AGGRO | idem 3 |
| 5 | SMART_TARGET_HOSTILE_RANDOM | idem 3 |
| 6 | SMART_TARGET_HOSTILE_RANDOM_NOT_TOP | idem 3 |
| 7 | SMART_TARGET_ACTION_INVOKER | - |
| 8 | SMART_TARGET_POSITION | x, y, z nos params |
| 9 | SMART_TARGET_CREATURE_RANGE | entry(0=any), minDist, maxDist |
| 10 | SMART_TARGET_CREATURE_GUID | guid, entry |
| 11 | SMART_TARGET_CREATURE_DISTANCE | entry, maxDist |
| 13 | SMART_TARGET_GAMEOBJECT_RANGE | entry, minDist, maxDist |
| 17 | SMART_TARGET_PLAYER_RANGE | minDist, maxDist |
| 18 | SMART_TARGET_PLAYER_DISTANCE | maxDist |
| 19 | SMART_TARGET_CLOSEST_CREATURE | entry, maxDist, dead |
| 20 | SMART_TARGET_CLOSEST_GAMEOBJECT | entry, maxDist |
| 23 | SMART_TARGET_OWNER_OR_SUMMONER | - |
| 24 | SMART_TARGET_THREAT_LIST | maxDist |
| 27 | SMART_TARGET_LOOT_RECIPIENTS | - |
| 28 | SMART_TARGET_FARTHEST | maxDist, playerOnly, isInLos |

Fonte da verdade: `enum SMARTAI_TARGETS` em `src/server/game/AI/SmartScripts/SmartScriptMgr.h`.

---

## 6. SQL PATTERNS

### 6.1 Creature template

```sql
-- Entry principal do NPC
INSERT INTO `creature_template` (`entry`, `difficulty_entry_1`, `difficulty_entry_2`, `difficulty_entry_3`,
    `KillCredit1`, `KillCredit2`, `modelid1`, `modelid2`, `modelid3`, `modelid4`,
    `name`, `subname`, `IconName`, `gossip_menu_id`, `minlevel`, `maxlevel`,
    `exp`, `faction_A`, `faction_H`, `npcflag`, `speed_walk`, `speed_run`,
    `scale`, `rank`, `mindmg`, `maxdmg`, `dmgschool`, `attackpower`,
    `dmg_multiplier`, `baseattacktime`, `rangeattacktime`, `unit_class`, `unit_flags`,
    `unit_flags2`, `dynamicflags`, `family`, `trainer_type`, `trainer_spell`,
    `trainer_class`, `trainer_race`, `minrangedmg`, `maxrangedmg`, `rangedattackpower`,
    `type`, `type_flags`, `lootid`, `pickpocketloot`, `skinloot`,
    `resistance1`, `resistance2`, `resistance3`, `resistance4`, `resistance5`, `resistance6`,
    `spell1`, `spell2`, `spell3`, `spell4`, `spell5`, `spell6`,
    `PetSpellDataId`, `VehicleId`, `mingold`, `maxgold`, `AIName`, `MovementType`,
    `InhabitType`, `HoverHeight`, `Health_mod`, `Mana_mod`, `Mana_mod_extra`,
    `Armor_mod`, `RacialLeader`, `questItem1`, `questItem2`, `questItem3`, `questItem4`,
    `questItem5`, `questItem6`, `movementId`, `RegenHealth`, `equipment_id`,
    `mechanic_immune_mask`, `flags_extra`, `ScriptName`)
VALUES
    (123456, 0, 0, 0,
     0, 0, 12345, 0, 0, 0,
     'Exemplo Boss', 'Chefe da Masmorra', '', 0, 85, 85,
     3, 35, 35, 0, 1, 1.14286,
     1, 3, 500, 800, 0, 800,
     25, 2000, 2000, 2, 33685504,
     2048, 12, 0, 0, 0,
     0, 0, 400, 600, 110,
     7, 2097224, 123456, 0, 0,
     0, 0, 0, 0, 0, 0,
     0, 0, 0, 0, 0, 0,
     0, 0, 30000, 50000, 'SmartAI', 0,
     3, 1, 20, 1, 1,
     1, 0, 0, 0, 0, 0,
     0, 0, 150, 1, 0,
     8388624, 1, 'boss_example');
```

### 6.2 Creature equipment

```sql
INSERT INTO `creature_equip_template` (`entry`, `id`, `itemEntry1`, `itemEntry2`, `itemEntry3`)
VALUES (123456, 1, 12345, 0, 0);

INSERT INTO `creature_template_addon` (`entry`, `path_id`, `mount`, `bytes1`, `bytes2`, `emote`, `aiAnimKit`, `movementAnimKit`, `meleeAnimKit`, `auras`)
VALUES (123456, 0, 0, 0, 1, 0, 0, 0, 0, '');
```

### 6.3 Creature spawn

```sql
INSERT INTO `creature` (`guid`, `id`, `map`, `zoneId`, `areaId`, `spawnMask`,
    `phaseMask`, `modelid`, `equipment_id`, `position_x`, `position_y`, `position_z`,
    `orientation`, `spawntimesecs`, `spawndist`, `currentwaypoint`, `curhealth`,
    `curmana`, `MovementType`, `npcflag`, `unit_flags`, `dynamicflags`,
    `VerifiedBuild`)
VALUES
    (123456, 123456, 0, 0, 0, 1,
     1, 0, 1, x, y, z,
     o, 7200, 0, 0, 100000,
     0, 0, 0, 0, 0, 0);
```

### 6.4 Boss loot

```sql
INSERT INTO `creature_loot_template` (`entry`, `item`, `ChanceOrQuestChance`, `lootmode`,
    `groupid`, `mincountOrRef`, `maxcount`, `itemBonuses`)
VALUES
    (123456, 12345, 100, 1, 0, 1, 1, ''),  -- 100% drop
    (123456, 12346, 0, 1, 1, 1, 1, ''),    -- group 1 (drop one)
    (123456, 12347, 0, 1, 1, 1, 1, '');
```

### 6.5 Gameobject template

```sql
INSERT INTO `gameobject_template` (`entry`, `type`, `displayId`, `name`, `IconName`,
    `castBarCaption`, `unk1`, `faction`, `flags`, `size`,
    `questItem1`, `questItem2`, `questItem3`, `questItem4`, `questItem5`, `questItem6`,
    `data0`, `data1`, `data2`, `data3`, `data4`, `data5`,
    `data6`, `data7`, `data8`, `data9`, `data10`, `data11`,
    `data12`, `data13`, `data14`, `data15`, `data16`, `data17`,
    `data18`, `data19`, `data20`, `data21`, `data22`, `data23`,
    `AIName`, `ScriptName`)
VALUES
    (123456, 3, 12345, 'Porta do Boss', '',
     '', '', 114, 32, 1,
     0, 0, 0, 0, 0, 0,
     0, 0, 0, 0, 0, 0,
     0, 0, 0, 0, 0, 0,
     0, 0, 0, 0, 0, 0,
     0, 0, 0, 0, 0, 0,
     '', 'go_example_door');
```

Tipos de gameobject:
- `type=0` DOOR
- `type=3` CHEST
- `type=5` TRAP
- `type=8` SPELL_FOCUS
- `type=10` CHAIR
- `type=22` SPELL_CASTER
- `type=30` AREA_SCRIPT
- `type=31` CAMERA

### 6.6 Creature text

```sql
INSERT INTO `creature_text` (`entry`, `groupid`, `id`, `text`, `type`, `language`,
    `probability`, `emote`, `duration`, `sound`, `BroadcastTextId`, `TextRange`, `comment`)
VALUES
    (123456, 0, 0, 'Fools! You dare challenge me?', 14, 0,      -- 14 = yell
     100, 0, 0, 57224, BroadcastTextId, 0, 'boss_example aggro'),
    (123456, 1, 0, 'I will crush you all!', 14, 0,
     100, 0, 0, 57225, BroadcastTextId, 0, 'boss_example kill'),
    (123456, 2, 0, 'Impossible...', 14, 0,
     100, 0, 0, 57226, BroadcastTextId, 0, 'boss_example death');
```

groupid = categoria (0=aggro, 1=kill, 2=death, 3=spell, etc)
type: 12=chat, 14=yell, 16=whisper, 41=emote

---

## 7. INSTANCE SCRIPT

### 7.1 Header de instance

```cpp
enum InstanceEvents
{
    EVENT_INSTANCE_BOSS_ONE     = 1,
    EVENT_INSTANCE_BOSS_TWO,
};

enum InstanceData
{
    DATA_BOSS_EXAMPLE           = 0,
    DATA_BOSS_EXAMPLE_TWO,
    DATA_DOOR_EXAMPLE,
    DATA_EVENT_STATE,
    DATA_MAX_ENCOUNTER,
};

enum CreatureIds
{
    NPC_BOSS_EXAMPLE            = 123456,
    NPC_BOSS_EXAMPLE_TWO        = 123457,
    NPC_TRASH_MOB               = 123458,
};

enum GameObjectIds
{
    GO_BOSS_DOOR                = 123456,
    GO_BOSS_CHEST               = 123457,
    GO_EXIT_PORTAL              = 123458,
};

enum InstanceEncounterState
{
    NOT_STARTED   = 0,
    IN_PROGRESS   = 1,
    FAIL          = 2,
    DONE          = 3,
    SPECIAL       = 4,
};
```

### 7.2 InstanceScript implementation

```cpp
class instance_example : public InstanceMapScript
{
public:
    instance_example() : InstanceMapScript("instance_example", MapID) { }

    InstanceScript* GetInstanceScript(InstanceMap* map) const override
    {
        return new instance_example_InstanceMapScript(map);
    }

    struct instance_example_InstanceMapScript : public InstanceScript
    {
        instance_example_InstanceMapScript(Map* map) : InstanceScript(map)
        {
            SetHeaders("DATA");
            SetBossNumber(MAX_ENCOUNTER == 2 ? 2 : 0);
        }

        void Initialize() override
        {
            memset(&_encounters, 0, sizeof(_encounters));
            _doorGUID = 0;
            _chestGUID = 0;
            _bossOneGUID = 0;
            _bossTwoGUID = 0;
        }

        void OnCreatureCreate(Creature* creature) override
        {
            switch (creature->GetEntry())
            {
                case NPC_BOSS_EXAMPLE:
                    _bossOneGUID = creature->GetGUID();
                    break;
                case NPC_BOSS_EXAMPLE_TWO:
                    _bossTwoGUID = creature->GetGUID();
                    break;
            }
        }

        void OnGameObjectCreate(GameObject* go) override
        {
            switch (go->GetEntry())
            {
                case GO_BOSS_DOOR:
                    _doorGUID = go->GetGUID();
                    if (GetBossState(DATA_BOSS_EXAMPLE) == DONE)
                        go->SetGoState(GO_STATE_ACTIVE);
                    else
                        go->SetGoState(GO_STATE_READY);
                    break;
                case GO_BOSS_CHEST:
                    _chestGUID = go->GetGUID();
                    break;
            }
        }

        bool SetBossState(uint32 type, EncounterState state) override
        {
            if (!InstanceScript::SetBossState(type, state))
                return false;

            switch (type)
            {
                case DATA_BOSS_EXAMPLE:
                    if (state == DONE)
                    {
                        // Open door to next boss
                        if (GameObject* door = instance->GetGameObject(_doorGUID))
                            door->SetGoState(GO_STATE_ACTIVE);
                    }
                    break;
            }

            if (state == DONE)
                SaveToDB();

            return true;
        }

        void SetData(uint32 type, uint32 data) override
        {
            switch (type)
            {
                case DATA_EVENT_STATE:
                    _eventState = data;
                    break;
            }

            if (data == DONE)
                SaveToDB();
        }

        uint32 GetData(uint32 type) const override
        {
            switch (type)
            {
                case DATA_EVENT_STATE:
                    return _eventState;
            }
            return 0;
        }

        ObjectGuid GetGuidData(uint32 type) const override
        {
            switch (type)
            {
                case DATA_BOSS_EXAMPLE:
                    return _bossOneGUID;
                case DATA_BOSS_EXAMPLE_TWO:
                    return _bossTwoGUID;
                case DATA_DOOR_EXAMPLE:
                    return _doorGUID;
            }
            return ObjectGuid::Empty;
        }

        std::string GetSaveData() override
        {
            OUT_SAVE_INST_DATA;
            std::ostringstream saveStream;
            saveStream << "E X " << GetBossSaveData();
            IN_SAVE_INST_DATA;
            return saveStream.str();
        }

        void Load(char const* str) override
        {
            if (!str)
            {
                OUT_LOAD_INST_DATA_FAIL;
                return;
            }

            OUT_LOAD_INST_DATA(str);
            std::istringstream loadStream(str);
            char dataHead1, dataHead2;

            loadStream >> dataHead1 >> dataHead2;

            if (dataHead1 == 'E' && dataHead2 == 'X')
            {
                for (uint32 i = 0; i < MAX_ENCOUNTER; ++i)
                {
                    uint32 tmpState;
                    loadStream >> tmpState;
                    if (tmpState == IN_PROGRESS || tmpState > SPECIAL)
                        tmpState = NOT_STARTED;
                    SetBossState(i, EncounterState(tmpState));
                }
            }
            else
                OUT_LOAD_INST_DATA_FAIL;

            IN_LOAD_INST_DATA;
        }

    private:
        ObjectGuid _bossOneGUID;
        ObjectGuid _bossTwoGUID;
        ObjectGuid _doorGUID;
        ObjectGuid _chestGUID;
        uint32 _eventState;
        EncounterState _encounters[MAX_ENCOUNTER];
    };
};
```

### 7.3 InstanceSaveData state

Save como string com headers:
```
"E X 0 0 1"  (2 bosses: NOT_STARTED, NOT_STARTED, DONE)
```
Header = 2 chars unicos da instance pra validar load.

### 7.4 Door handling

```cpp
void UpdateDoorState(uint32 entry, bool open)
{
    if (GameObject* door = GetGameObject(entry))
        door->SetGoState(open ? GO_STATE_ACTIVE : GO_STATE_READY);
}
```

---

## 8. GAMEOBJECTS

### 8.1 GameObjectAI script

```cpp
class go_example_door : public GameObjectScript
{
public:
    go_example_door() : GameObjectScript("go_example_door") { }

    struct go_example_doorAI : public GameObjectAI
    {
        go_example_doorAI(GameObject* go) : GameObjectAI(go) { }

        bool OnGossipHello(Player* player) override
        {
            // Open door logic
            if (InstanceScript* instance = go->GetInstanceScript())
            {
                if (instance->GetBossState(DATA_BOSS_EXAMPLE) != DONE)
                {
                    player->GetSession()->SendNotification("The door is locked.");
                    return false;
                }
            }
            return false;  // false = don't use gossip
        }

        void OnStateChanged(GameObject* go, GO_STATE oldState, GO_STATE newState) override
        {
            // React to door open/close
        }
    };

    GameObjectAI* GetAI(GameObject* go) const override
    {
        return new go_example_doorAI(go);
    }
};
```

### 8.2 Gameobject types importantes

| type | Uso | data0 | data1 |
|------|-----|-------|-------|
| 0 (DOOR) | Porta | startOpen (0=T, 1=F) | lockId |
| 3 (CHEST) | Baus | lockId | lootId |
| 5 (TRAP) | Armadilha | spellId | radius |
| 8 (SPELL_FOCUS) | Foco de spell | focusId | dist |
| 22 (SPELL_CASTER) | Cast autom. | spellId | charges |
| 30 (AREA_SCRIPT) | Trigger script | - | - |

---

## 9. QUESTS

### 9.1 Quest script

```cpp
class spell_q_example : public SpellScriptLoader
{
public:
    spell_q_example() : SpellScriptLoader("spell_q_example") { }

    class spell_q_example_SpellScript : public SpellScript
    {
        PrepareSpellScript(spell_q_example_SpellScript);

        bool Validate(SpellInfo const* /*spell*/) override
        {
            return true;
        }

        void HandleQuestComplete()
        {
            if (Player* player = GetCaster()->ToPlayer())
            {
                if (player->GetQuestStatus(QUEST_EXAMPLE) == QUEST_STATUS_INCOMPLETE)
                {
                    player->CastedCreatureOrGO(NPC_EXAMPLE_CREDIT, ObjectGuid::Empty, GetSpellInfo()->Id);
                }
            }
        }

        void Register() override
        {
            AfterHit += SpellHitFn(spell_q_example_SpellScript::HandleQuestComplete);
        }
    };

    SpellScript* GetSpellScript() const override
    {
        return new spell_q_example_SpellScript();
    }
};
```

### 9.2 Quest template fields (DBC/DB)

```sql
INSERT INTO `quest_template` (`entry`, `Method`, `ZoneOrSort`, `SkillOrClass`,
    `MinLevel`, `QuestLevel`, `Type`, `RequiredRaces`,
    `QuestInfoID`, `RewardXP`, `RewardMoney`, `RewardMoneyMaxLevel`,
    `RewardSpell`, `RewardSpellCast`, `RewardMailTemplateId`, `RewardMailPeriod`,
    `SourceItemId`, `SourceSpellId`, `Flags`, `SpecialFlags`,
    `MinimapTargetMark`, `RewardTitleId`, `RequiredPlayerKills`, `RewardTalents`,
    `RewardArenaPoints`, `RewardSkillId`, `RewardSkillPoints`,
    `DetailsEmote1`, `DetailsEmote2`, `DetailsEmote3`, `DetailsEmote4`,
    `IncompleteEmote`, `CompleteEmote`, `OfferRewardEmote1`, `OfferRewardEmote2`,
    `OfferRewardEmote3`, `OfferRewardEmote4`,
    `StartScript`, `CompleteScript`,
    `LogTitle`, `LogDescription`, `QuestDescription`, `AreaDescription`,
    `QuestCompletionLog`, `RewardNextQuest`, `RewardXPDifficulty`,
    `RewardMoneyDifficulty`, `RewardMoneyMaxLevelDifficulty`,
    `RequiredNpcOrGo1`, `RequiredNpcOrGo2`, `RequiredNpcOrGo3`, `RequiredNpcOrGo4`,
    `RequiredNpcOrGoCount1`, `RequiredNpcOrGoCount2`, `RequiredNpcOrGoCount3`, `RequiredNpcOrGoCount4`,
    `ItemDrop1`, `ItemDrop2`, `ItemDropQuantity1`, `ItemDropQuantity2`)
VALUES
    (123456, 2, 0, 0,
     85, 85, 0, 0,
     0, 100000, 0, 0,
     0, 0, 0, 0,
     0, 0, 0, 0,
     0, 0, 0, 0,
     0, 0, 0,
     1, 0, 0, 0,
     0, 0, 0, 0, 0, 0,
     0, 0,
     'Matar Exemplo', 'Mate o Boss Exemplo', 'Descricao detalhada', '',
     '', 0, 0, 0, 0,
     123456, 0, 0, 0, 1, 0, 0, 0,
     0, 0, 0, 0);
```

### 9.3 Quest events

```cpp
// On quest accept
class player_quest_example : public PlayerScript
{
public:
    player_quest_example() : PlayerScript("player_quest_example") { }

    void OnQuestAccept(Player* player, Quest const* quest) override
    {
        if (quest->GetQuestId() == QUEST_EXAMPLE)
        {
            // Summon quest giver
        }
    }

    void OnQuestComplete(Player* player, Quest const* quest) override
    {
        if (quest->GetQuestId() == QUEST_EXAMPLE)
        {
            // Reward handling
        }
    }

    void OnQuestReward(Player* player, Quest const* quest, LootItemType type, uint32 opt) override
    {
        if (quest->GetQuestId() == QUEST_EXAMPLE)
        {
            // Post-reward
        }
    }
};
```

---

## 10. ACHIEVEMENTS

### 10.1 Achievement criteria

Achievements usam `CriteriaMgr` com `AchievementCriteriaEntry` do DBC.

IDS das criteria types:
```
CRITERIA_TYPE_KILL_CREATURE       = 1
CRITERIA_TYPE_COMPLETE_QUEST      = 7
CRITERIA_TYPE_REACH_LEVEL         = 13
CRITERIA_TYPE_BE_SPELL_TARGET     = 38
CRITERIA_TYPE_BE_SPELL_TARGET2    = 69
CRITERIA_TYPE_CAST_SPELL          = 64
CRITERIA_TYPE_WIN_BG              = 42
CRITERIA_TYPE_SCRIPT_EVENT        = 74
```

### 10.2 Achievement script

```cpp
class achievement_example : public AchievementCriteriaScript
{
public:
    achievement_example() : AchievementCriteriaScript("achievement_example") { }

    bool OnCheck(Player* source, Unit* target) override
    {
        // Check conditions
        if (!source || !target)
            return false;

        // Exemplo: boss killed sem ninguem morrer
        if (source->GetMap()->GetPlayersCountExceptGMs() != GetNumAlive())
            return false;

        return true;
    }
};

// Achievement boss kill condition
class achievement_kill_example : public AchievementCriteriaScript
{
public:
    achievement_kill_example() : AchievementCriteriaScript("achievement_kill_example") { }

    bool OnCheck(Player* source, Unit* /*target*/) override
    {
        if (!source)
            return false;

        // Check if player was in raid during kill
        return source->GetMap()->IsRaid();
    }
};
```

### 10.3 Achievement from instance

```cpp
// Dentro do BossAI::JustDied()
void JustDied(Unit* killer) override
{
    _JustDied();

    // Award achievement to all players
    Map::PlayerList const& players = me->GetMap()->GetPlayers();
    for (Map::PlayerList::const_iterator it = players.begin(); it != players.end(); ++it)
    {
        if (Player* player = it->GetSource())
        {
            if (player->IsAtGroupRewardDistance(me))
                player->CompletedAchievement(ACHIEVEMENT_EXAMPLE);
        }
    }
}
```

### 10.4 Achievement DBC fields relevantes

- `ID` ÔÇö ID do achievement
- `requiredFaction` ÔÇö -1=any, 0=horde, 1=ally
- `mapID` ÔÇö Mapa
- `reward.ItemID`, `reward.ItemCount` ÔÇö Recompensa
- `reward.TitleA`, `reward.TitleH` ÔÇö Titulos
- `criteriaTree` ÔÇö Arvore de criterios

---

## 11. DAMAGE SYSTEM

### 11.1 Damage calculation flow

```
Spell::CalculateDamage()
  -> Spell::CalculateDamageDone()
    -> Unit::ApplyTotalDmgModPctN(me)
    -> Unit::ApplyTotalDmgModPctA(me)
    -> Unit::SpellDamageBonusDone(me)
    -> Spell::CalculateDamageDoneForTarget(target)
      -> target->SpellDamageBonusTaken(damage)
      -> target->ApplyTotalDmgModPctN(target)
      -> target->ApplyTotalDmgModPctA(target)
```

### 11.2 Modificando dano em scripts

```cpp
// Aura que modifica dano feito
class spell_example_damage_done : public AuraScript
{
    PrepareAuraScript(spell_example_damage_done);

    void OnCalcDamage(Unit const* victim, int32& damage, SpellInfo const* spellInfo)
    {
        // +20% fire damage
        if (spellInfo->GetSchoolMask() & SPELL_SCHOOL_MASK_FIRE)
            damage += CalculatePct(damage, 20);
    }

    void Register() override
    {
        DoEffectCalcDamage += AuraEffectCalcDamageFn(spell_example_damage_done::OnCalcDamage, EFFECT_0, SPELL_AURA_DUMMY);
    }
};
```

### 11.3 Damage types

```cpp
SPELL_SCHOOL_MASK_NORMAL       = 1
SPELL_SCHOOL_MASK_FIRE         = 2
SPELL_SCHOOL_MASK_NATURE       = 4
SPELL_SCHOOL_MASK_FROST        = 8
SPELL_SCHOOL_MASK_SHADOW       = 16
SPELL_SCHOOL_MASK_ARCANE       = 32
SPELL_SCHOOL_MASK_HOLY         = 64
SPELL_SCHOOL_MASK_CHAOS        = 128

DamageEffectType:
DIRECT_DAMAGE                  = 0  // Hit direto
SPELL_DIRECT_DAMAGE            = 1  // Dano direto de spell
DOT                            = 2  // Dano periodico
HEAL                           = 3  // Cura
SELF_DAMAGE                    = 4  // Dano em si mesmo
```

### 11.4 Unit damage hooks

```cpp
void ModifyMeleeDamage(Unit* target, uint32& damage, CalcDamageInfo& info)
void ModifySpellDamageTaken(Unit* target, int32& damage, SpellInfo const* spellInfo)
void OnMeleeHit(Unit* target, uint32 damage)
void OnDamage(Unit* attacker, uint32 damage)
```

---

## 12. CONVENCOES C++

### 12.1 Naming

| Item | Padrao | Exemplo |
|------|--------|---------|
| Classes | PascalCase | `BossAI`, `SpellScript` |
| Metodos | PascalCase | `JustEngagedWith()`, `JustDied()` |
| Variaveis | _camelCase | `_events`, `_phase`, `_bossGUID` |
| Enums | UPPER_CASE | `DATA_BOSS_EXAMPLE`, `EVENT_FIREBALL` |
| Constantes | UPPER_CASE | `SPELL_EXAMPLE`, `NPC_EXAMPLE` |
| Namespace | lowercase | `Trinity::` |
| Macro | UPPER_CASE | `PREPARE_SPELL_SCRIPT` |
| Arquivos | lowercase_under | `boss_example.cpp` |
| ScriptName | lowercase_under | `"boss_example"` |

### 12.2 Indentacao e estilo

```cpp
// BRACES: next-line (Allman style)
class MyClass
{
public:
    void MyMethod()
    {
        if (condition)
        {
            // code
        }
        else
        {
            // code
        }

        switch (value)
        {
            case 1:
                break;
            default:
                break;
        }
    }
};

// INDENT: tabs (1 tab = 4 spaces)
// Access modifiers: 1 tab indent
// NO trailing whitespace
// Max line: 120 chars
// Space after if/while/for/switch
// No space after function name
```

### 12.3 Convencoes especificas TC

```cpp
// Usar ObjectGuid ao inves de uint64
ObjectGuid _creatureGUID;

// Usar enum class para constantes enum
enum class ExamplePhase : uint8
{
    ONE = 1,
    TWO = 2
};

// Getter/Setters do TC
me->GetGUID()           // ObjectGuid
me->GetEntry()          // uint32
me->GetMapId()          // uint32
me->GetInstanceScript() // InstanceScript*

// Casts
Unit::ToPlayer()        // -> Player*
Unit::ToCreature()      // -> Creature*
Unit::ToGameObject()    // -> GameObject*

// Map iteration
Map::PlayerList const& players = me->GetMap()->GetPlayers();

// String
std::string name = "boss_" + std::to_string(entry);

// Recomendado
ObjectGuid guid = ObjectGuid::Create<HighGuid::Creature>(entry, spawnId);
```

### 12.4 Registro de scripts

```cpp
// Adicionar no CMakeLists.txt da pasta:
// set(scripts_SRCS
//     .../boss_example.cpp
// )

// Adicionar no <zona>_script_loader.cpp (AddSC da zona):
// extern void AddSC_boss_example();
// [no map do loader]
// AddSC_boss_example();
```

---

## 13. SISTEMA DE EVENTOS

### 13.1 EventMap

```cpp
EventMap _events;

_events.ScheduleEvent(EVENT_ID, delay);              // Unico
_events.ScheduleEvent(EVENT_ID, minDelay, maxDelay); // Random
_events.Repeat(delay);                               // Repetir ultimo evento
_events.Repeat(min, max);
_events.CancelEvent(EVENT_ID);                       // Cancelar
_events.RescheduleEvent(EVENT_ID, delay);            // Reagendar
_events.Reset();                                     // Limpar tudo
_events.PopEvent();                                  // Executar e remover
_events.ExecuteEvent();                              // Pegar proximo evento valido

// Com delay-based
_events.ScheduleEvent(EVENT_ID, Seconds(15));
_events.ScheduleEvent(EVENT_ID, Minutes(2));

// Phase-aware
_events.ScheduleEvent(EVENT_ID, delay, PHASE_GROUP, PHASE_ONE);
_events.SetPhase(PHASE_TWO);
```

### 13.2 Phases

```cpp
// SMARTAI phases via event_phase_mask
// Masks sao bits: 1=phase1, 2=phase2, 4=phase3, 8=phase4

// C++ phases
enum Phases
{
    PHASE_ONE = 1,
    PHASE_TWO = 2,
};

uint8 _phase;

// Usar EventMap phase system
_events.SetPhase(PHASE_ONE);
_events.ScheduleEvent(EVENT_FIREBALL, 5000, 0, PHASE_ONE);
_events.ScheduleEvent(EVENT_AOE, 10000, 0, PHASE_TWO);
```

---

## 14. MOVEMENT GENERATORS

### 14.1 Tipos

```cpp
me->GetMotionMaster()->MovePoint(pointId, x, y, z);
me->GetMotionMaster()->MoveCharge(x, y, z, speed);
me->GetMotionMaster()->MoveChase(target, dist, angle);
me->GetMotionMaster()->MoveFollow(target, dist, angle);
me->GetMotionMaster()->MoveRandom(radius);
me->GetMotionMaster()->MoveIdle();
me->GetMotionMaster()->MoveJump(x, y, z, speed, gravity);
me->GetMotionMaster()->MoveKnockback(caster, speed, angle, height);
me->GetMotionMaster()->MovePath(pathId, repeat);
me->GetMotionMaster()->MoveFlee(fleeTarget, time);
me->GetMotionMaster()->MoveSeekAssistance(x, y, z);
me->GetMotionMaster()->MoveRotate(angle, direction);
me->GetMotionMaster()->MoveWaypoint(pathId);
```

### 14.2 MovementInform

```cpp
void MovementInform(uint32 type, uint32 id) override
{
    switch (type)
    {
        case POINT_MOTION_TYPE:
            if (id == POINT_LANDING)
            {
                // Arrived at point
                DoCast(me, SPELL_LAND_EFFECT);
            }
            break;
        case EFFECT_MOTION_TYPE:
            // Knockback landing
            break;
    }
}
```

Movement types (`MotionMaster.h`):
```
IDLE_MOTION_TYPE                = 0
RANDOM_MOTION_TYPE              = 1
WAYPOINT_MOTION_TYPE            = 2
CYCLIC_SPLINE_MOTION_TYPE       = 3   // MAX_DB_MOTION_TYPE = 4 (limite p/ DB)
CONFUSED_MOTION_TYPE            = 4
CHASE_MOTION_TYPE               = 5
HOME_MOTION_TYPE                = 6
FLIGHT_MOTION_TYPE              = 7
POINT_MOTION_TYPE               = 8
FLEEING_MOTION_TYPE             = 9
DISTRACT_MOTION_TYPE            = 10
ASSISTANCE_MOTION_TYPE          = 11
ASSISTANCE_DISTRACT_MOTION_TYPE = 12
TIMED_FLEEING_MOTION_TYPE       = 13
FOLLOW_MOTION_TYPE              = 14
ROTATE_MOTION_TYPE              = 15
EFFECT_MOTION_TYPE              = 16
SPLINE_CHAIN_MOTION_TYPE        = 17
FORMATION_MOTION_TYPE           = 18
```

---

## REGRA SUPREMA: FIEL

**NAO INVENTAR.**

TrinityCore tem estruturas fixas. Tudo que voce criar DEVE:
1. Usar classes existentes (`ScriptedAI`, `BossAI`, `SpellScriptLoader`, etc)
2. Seguir os mesmos headers/namespaces
3. Usar os mesmos hooks (UpdateAI, JustEngagedWith, JustDied, etc - `EnterCombat` NAO existe neste core)
4. Registrar scripts com `AddSC_` + `new ClassName()` OU macros `Register<Zona>CreatureAI()` / `RegisterSpellScript()`
5. Usar `_events` ScheduleEvent/ExecuteEvent (nao timer manual)
6. Usar `enum Spells/Events/Creatures/GameObjects` no topo
7. Boss em raid = BossAI + InstanceScript
8. NPC solto = ScriptedAI + SmartAI (SQL)
9. Dungeon = InstanceScript + BossAI para cada boss
10. Spell scripts = SpellScriptLoader + PrepareSpellScript

**Se nao existir no codigo original, nao implementar.** Usar SmartAI + SQL quando possivel antes de C++ script.
