# CRULES — TrinityCore (Cataclysm) Code Rules for AI Agents

## 1. FUNDAMENTAL ARCHITECTURE

### 1.1 Core Principles
- **Fork:** Cataclysm Preservation Project (4.3.4)
- **Base:** TrinityCore
- **Language:** C++ (C++17 standard)
- **DB Engine:** MySQL/MariaDB
- **Build:** CMake + MSVC (Windows) or GCC/Clang (Linux)
- **No external scripting languages** — all scripts compile into core

### 1.2 Directory Layout
```
src/server/
├── game/           # Core game systems
│   ├── AI/         # Creature AI framework
│   │   ├── CoreAI/       # Base AI (CombatAI, PassiveAI, PetAI, etc)
│   │   ├── ScriptedAI/   # ScriptedAI, BossAI, WorldBossAI, EscortAI
│   │   └── SmartScripts/ # SmartAI database-driven system
│   ├── Achievements/     # Achievement system
│   ├── Spells/           # Spell system (Spell, Auras, SpellScript)
│   ├── Instances/        # InstanceScript framework
│   ├── Scripting/        # ScriptMgr — registration hub
│   └── ...
├── scripts/        # All script implementations
│   ├── EasternKingdoms/
│   ├── Kalimdor/
│   ├── Northrend/
│   ├── Outland/
│   ├── Cataclysm/
│   └── Custom/
sql/
├── base/           # World/Characters/Auth DB schemas
├── updates/        # Incremental SQL patches (world/characters/auth/hotfixes)
└── custom/         # Custom SQL additions
```

### 1.3 Script Registration Flow
```
ScriptMgr.h (RegisterCreatureScript, RegisterSpellScript, etc)
  → ScriptMgr.cpp (stores pointers)
    → ScriptSystem.cpp (loads scripts at startup)
      → CreatureScript::GetAI() returns AI instance per creature
```

---

## 2. CREATURE SCRIPT PATTERN (Bosses/Trash)

### 2.1 Template — Boss Script

```cpp
#include "ScriptMgr.h"
#include "InstanceScript.h"
#include "ScriptedCreature.h"
#include "SpellScript.h"
#include "SpellAuraEffects.h"
#include "Spell.h"
#include "MotionMaster.h"
#include "Map.h"
#include "Player.h"
#include "TemporarySummon.h"
#include "ObjectAccessor.h"

namespace ZoneName::BossName  // MUST be namespace
{
enum Texts
{
    SAY_AGGRO   = 0,
    SAY_KILL    = 1,
    SAY_DEATH   = 2,
    SAY_SPELL   = 3,
    SAY_SPECIAL = 4,
    EMOTE_WARN  = 5,
};

enum Spells
{
    SPELL_MAIN_ATTACK    = 12345,
    SPELL_SPECIAL        = 12346,
    SPELL_ENRAGE         = 26662,
};

enum Events
{
    EVENT_MAIN_ATTACK    = 1,
    EVENT_SPECIAL        = 2,
    EVENT_ENRAGE         = 3,
    EVENT_GROUP_SPECIAL  = 1,  // groups use EVENT_GROUP prefix
};

enum MiscData
{
    DATA_UNIQUE_TRACKER  = 1,
};

enum Actions
{
    ACTION_START_EVENT   = 1,
};

// Optional: predicate functor for target selection
class SomeTargetSelector
{
public:
    SomeTargetSelector(Creature* creature) : _creature(creature) { }
    bool operator()(Unit* unit) const { /* filter logic */ return true; }
private:
    Creature* _creature;
};

class boss_boss_name : public CreatureScript
{
public:
    boss_boss_name() : CreatureScript("boss_boss_name") { }

    struct boss_boss_nameAI : public BossAI
    {
        boss_boss_nameAI(Creature* creature) : BossAI(creature, DATA_BOSS_ID)
        {
            // constructor: initialize member variables
        }

        void Reset() override
        {
            _Reset();
            // schedule initial events
            events.ScheduleEvent(EVENT_MAIN_ATTACK, 5000);
            events.ScheduleEvent(EVENT_ENRAGE, 600000);
        }

        void JustEngagedWith(Unit* who) override
        {
            Talk(SAY_AGGRO);
            me->setActive(true);
            DoZoneInCombat();
            instance->SetBossState(DATA_BOSS_ID, IN_PROGRESS);
        }

        void JustDied(Unit* killer) override
        {
            Talk(SAY_DEATH);
            _JustDied();
        }

        void JustReachedHome() override
        {
            _JustReachedHome();
            instance->SetBossState(DATA_BOSS_ID, FAIL);
        }

        void KilledUnit(Unit* victim) override
        {
            if (victim->GetTypeId() == TYPEID_PLAYER)
                Talk(SAY_KILL);
        }

        void UpdateAI(uint32 diff) override
        {
            if (!UpdateVictim())
                return;

            events.Update(diff);

            if (me->HasUnitState(UNIT_STATE_CASTING))
                return;

            while (uint32 eventId = events.ExecuteEvent())
            {
                ExecuteEvent(eventId);
                if (me->HasUnitState(UNIT_STATE_CASTING))
                    return;
            }

            DoMeleeAttackIfReady();
        }

        void ExecuteEvent(uint32 eventId) override
        {
            switch (eventId)
            {
                case EVENT_MAIN_ATTACK:
                    DoCastVictim(SPELL_MAIN_ATTACK);
                    events.Repeat(8000, 12000);
                    break;
                case EVENT_SPECIAL:
                    if (Unit* target = SelectTarget(SELECT_TARGET_RANDOM, 0, 100.0f, true))
                        DoCast(target, SPELL_SPECIAL);
                    events.Repeat(15000, 20000);
                    break;
                case EVENT_ENRAGE:
                    DoCast(me, SPELL_ENRAGE, true);
                    break;
            }
        }

        // Optional: custom data get/set
        uint32 GetData(uint32 id) const override
        {
            if (id == DATA_UNIQUE_TRACKER)
                return _someValue;
            return 0;
        }

        void SetData(uint32 id, uint32 value) override
        {
            if (id == DATA_UNIQUE_TRACKER)
                _someValue = value;
        }

    private:
        uint32 _someValue = 0;
    };

    CreatureAI* GetAI(Creature* creature) const override
    {
        return GetIcecrownCitadelAI<boss_boss_nameAI>(creature);
    }
};

// Register at bottom of file or in zone registration
void AddSC_boss_boss_name()
{
    new boss_boss_name();
}
}
```

### 2.2 BossAI Class Hierarchy
```
BossAI : ScriptedAI : CreatureAI : UnitAI
├── instance* → InstanceScript pointer
├── events → EventMap (timed event scheduler)
├── summons → SummonList (auto-manages summoned creatures)
├── scheduler → TaskScheduler (alternative to EventMap)
├── _Reset()
├── _JustEngagedWith(Unit*)
├── _JustDied()
├── _JustReachedHome()
├── _DespawnAtEvade()
├── TeleportCheaters()
├── ExecuteEvent(uint32) → override for event-driven logic
└── ScheduleTasks() → alternative to Reset

WorldBossAI : ScriptedAI (for outdoor world bosses, no instance)
├── events, summons
├── _Reset(), _JustEngagedWith(), _JustDied()
```

### 2.3 ScriptedAI Key Methods
```cpp
// Target selection
Unit* SelectTarget(SelectTargetType type, uint32 offset, float dist, bool withAura, uint32 spellId);
// Movement
void SetCombatMovement(bool allow);
void DoStartMovement(Unit* target, float distance = 0, float angle = 0);
void DoStartNoMovement(Unit* target);
void DoStopAttack();
// Casting helpers
void DoCast(Unit* target, uint32 spellId, bool triggered = false);
void DoCastVictim(uint32 spellId, bool triggered = false);
void DoCastSelf(uint32 spellId, bool triggered = false);
void DoCastAOE(uint32 spellId, bool triggered = false);
// Spawn
Creature* DoSpawnCreature(uint32 entry, float x, float y, float z, float angle, uint32 type, uint32 despawnTime);
// Misc
void Talk(uint8 id);  // broadcast creature text
void DoZoneInCombat(Creature* creature = nullptr);
bool HealthBelowPct(uint32 pct);
bool HealthAbovePct(uint32 pct);
bool IsHeroic();
bool Is25ManRaid();
Difficulty GetDifficulty();
template<T> RAID_MODE(n10, n25, h10, h25);
template<T> DUNGEON_MODE(n5, h5);
```

### 2.4 EventMap System
```cpp
// Schedule
events.ScheduleEvent(eventId, delay, group = 0, phase = 0);
events.Repeat(delay);            // repeat same event
events.Repeat(min, max);         // repeat with random interval
events.RepeatEvent(delay);       // at end of ExecuteEvent
events.CancelEvent(eventId);
events.RescheduleEvent(eventId, delay);
events.RescheduleEvent(eventId, min, max);

// Groups
events.DelayEvents(delay, group);
events.CancelEventGroup(group);
events.RescheduleGroup(group, min, max);
events.ScheduleEvent(id, delay, group);
events.ScheduleEvent(id, min, max, group);  // random delay

// Execution
events.Update(diff);       // call in UpdateAI
uint32 id = events.ExecuteEvent();  // returns next ready event ID

// Query
events.IsInPhase(phase);
events.SetPhase(phase);
events.SetPhase(phase, group);  // clear group events, set phase
events.ClearPhase();
events.GetNextEventTime(eventId);
events.GetTimeUntilEvent(eventId);
```

---

## 3. INSTANCE SCRIPT PATTERN

### 3.1 Template — Instance Script

```cpp
#include "ScriptMgr.h"
#include "AreaBoundary.h"
#include "InstanceScript.h"
#include "Player.h"
#include "CreatureAI.h"
#include "GameObject.h"
#include "Map.h"
#include "ObjectMgr.h"

namespace ZoneName
{
// Identifier for data save/load
constexpr char const* DataHeader = "ZZ";
uint32 const EncounterCount = 5;

// Boundaries for each boss
BossBoundaryData const boundaries =
{
    { DATA_BOSS_1, new CircleBoundary(Position(x, y), radius) },
    { DATA_BOSS_2, new RectangleBoundary(x1, x2, y1, y2) },
};

// Door control for all encounters
DoorData const doorData[] =
{
    { GO_DOOR_ENTRY,     DATA_BOSS_1, DOOR_TYPE_ROOM },
    { GO_PASSAGE_DOOR,   DATA_BOSS_1, DOOR_TYPE_PASSAGE },
    { GO_SPAWN_HOLE,     DATA_BOSS_2, DOOR_TYPE_SPAWN_HOLE },
    { 0,                 0,           DOOR_TYPE_ROOM }, // END marker
};

class instance_zone_name : public InstanceMapScript
{
public:
    instance_zone_name() : InstanceMapScript("instance_zone_name", MAP_ID) { }

    struct instance_zone_name_InstanceMapScript : public InstanceScript
    {
        instance_zone_name_InstanceMapScript(InstanceMap* map)
            : InstanceScript(map)
        {
            SetHeaders(DataHeader);
            SetBossNumber(EncounterCount);
            LoadDoorData(doorData);
            LoadBossBoundaries(boundaries);
        }

        void OnCreatureCreate(Creature* creature) override
        {
            switch (creature->GetEntry())
            {
                case NPC_BOSS_1:
                    StoreCreature(DATA_BOSS_1, creature->GetGUID());
                    break;
                // ...
            }
        }

        void OnGameObjectCreate(GameObject* go) override
        {
            switch (go->GetEntry())
            {
                case GO_DOOR_ENTRY:
                    AddDoor(go, true);
                    break;
                // ...
            }
        }

        void OnUnitDeath(Unit* unit) override
        {
            Creature* creature = unit->ToCreature();
            if (!creature) return;
            if (creature->GetEntry() == NPC_BOSS_1)
                SetBossState(DATA_BOSS_1, DONE);
        }

        ObjectGuid GetGuidData(uint32 id) const override
        {
            return GetStoredCreature(id);
        }

        void SetData(uint32 id, uint32 value) override
        {
            // custom data storage
        }

        uint32 GetData(uint32 id) const override
        {
            return 0;
        }
    };

    InstanceScript* GetInstanceScript(InstanceMap* map) const override
    {
        return new instance_zone_name_InstanceMapScript(map);
    }
};

void AddSC_instance_zone_name()
{
    new instance_zone_name();
}
}
```

### 3.2 Instance Data Enums

```cpp
// In zone header file (e.g., zone_name.h)
enum DataTypes
{
    DATA_BOSS_1          = 0,
    DATA_BOSS_2          = 1,
    // ... sequential per encounter count

    // Additional data variables (after bosses)
    DATA_ACHIEVEMENT_1   = 10,
    DATA_SPECIAL_NPC     = 11,
    DATA_TRIGGER_OBJECT  = 12,
};

enum CreatureIds
{
    NPC_BOSS_1           = 50000,
    NPC_BOSS_2           = 50001,
    NPC_TRASH_1          = 50010,
    NPC_TRASH_2          = 50011,
};

enum GameObjectIds
{
    GO_DOOR_ENTRY        = 200000,
    GO_CHEST_10N         = 200001,
    GO_CHEST_25N         = 200002,
    GO_CHEST_10H         = 200003,
    GO_CHEST_25H         = 200004,
};

enum AchievementCriteriaIds
{
    CRITERIA_ACHIEV_10N  = 13000,
    CRITERIA_ACHIEV_25N  = 13001,
};
```

### 3.3 InstanceScript Essential API

```cpp
// Boss state management
void SetBossState(uint32 id, EncounterState state);
EncounterState GetBossState(uint32 id) const;
bool IsEncounterInProgress() const;

// Creature/GameObject storage
void StoreCreature(uint32 id, ObjectGuid guid);
ObjectGuid GetStoredCreature(uint32 id) const;

// Door management
void LoadDoorData(DoorData const* data);
void AddDoor(GameObject* door, bool add);
void UpdateDoorState(GameObject* door);

// Save/load
void SetHeaders(char const* header);
std::string GetSaveData();
void Load(char const* data);  // format: header B ossState data

// Misc
bool CheckAchievementCriteriaMeet(uint32 criteria_id, Player* source, Unit* target = nullptr);
void DoUseDoorOrButton(ObjectGuid guid, uint32 withRestoreTime = 0, bool useAlternativeState = false);
void DoRespawnGameObject(ObjectGuid guid, Seconds timeToRespawn = 300s);
void DoNearTeleportPlayers(Position const& pos);
```

---

## 4. SPELL SCRIPT PATTERN

### 4.1 SpellScript (behavior on cast)

```cpp
class spell_spell_name : public SpellScriptLoader
{
public:
    spell_spell_name() : SpellScriptLoader("spell_spell_name") { }

    class spell_spell_name_SpellScript : public SpellScript
    {
        PrepareSpellScript(spell_spell_name_SpellScript);

        bool Load() override
        {
            // validation
            return true;
        }

        void HandleOnHit()
        {
            if (Unit* target = GetHitUnit())
                GetCaster()->CastSpell(target, SPELL_EFFECT, true);
        }

        void Register() override
        {
            OnHit += SpellHitFn(spell_spell_name_SpellScript::HandleOnHit);
        }
    };

    SpellScript* GetSpellScript() const override
    {
        return new spell_spell_name_SpellScript();
    }
};
```

### 4.2 AuraScript (behavior on aura apply/tick/remove)

```cpp
class spell_aura_name : public SpellScriptLoader
{
public:
    spell_aura_name() : SpellScriptLoader("spell_aura_name") { }

    class spell_aura_name_AuraScript : public AuraScript
    {
        PrepareAuraScript(spell_aura_name_AuraScript);

        void OnApply(AuraEffect const* /*aurEff*/, AuraEffectHandleModes /*mode*/)
        {
            // ...
        }

        void OnRemove(AuraEffect const* /*aurEff*/, AuraEffectHandleModes /*mode*/)
        {
            // ...
        }

        void OnPeriodic(AuraEffect const* aurEff)
        {
            Unit* target = GetTarget();
            target->CastSpell(target, SPELL_PERIODIC_EFFECT, true);
        }

        void OnCalcAmount(AuraEffect const* /*aurEff*/, int32& amount, bool& /*canBeRecalculated*/)
        {
            amount = someFormula;
        }

        void Register() override
        {
            OnEffectApply += AuraEffectApplyFn(spell_aura_name_AuraScript::OnApply, EFFECT_0, SPELL_AURA_PERIODIC_DAMAGE, AURA_EFFECT_HANDLE_REAL);
            OnEffectRemove += AuraEffectRemoveFn(spell_aura_name_AuraScript::OnRemove, EFFECT_0, SPELL_AURA_PERIODIC_DAMAGE, AURA_EFFECT_HANDLE_REAL);
            OnEffectPeriodic += AuraEffectPeriodicFn(spell_aura_name_AuraScript::OnPeriodic, EFFECT_0, SPELL_AURA_PERIODIC_DAMAGE);
            DoEffectCalcAmount += AuraEffectCalcAmountFn(spell_aura_name_AuraScript::OnCalcAmount, EFFECT_0, SPELL_AURA_NONE);
        }
    };

    AuraScript* GetAuraScript() const override
    {
        return new spell_aura_name_AuraScript();
    }
};
```

### 4.3 SpellScript Hook Types

```cpp
// Casting phase
OnCast += SpellCastFn(func);              // after spell cast starts
OnPrepare += SpellPrepareFn(func);        // before cast starts

// Targets
OnObjectAreaTargetSelect += SpellObjectAreaTargetSelectFn(func, EFFECT_0, TARGET_UNIT_SRC_AREA_ENEMY);
OnObjectTargetSelect += SpellObjectTargetSelectFn(func, EFFECT_0, TARGET_UNIT_TARGET_ENEMY);

// Effects
OnEffectHit += SpellEffectFn(func, EFFECT_0, SPELL_EFFECT_SCHOOL_DAMAGE);
OnEffectLaunch += SpellEffectFn(func, EFFECT_1, SPELL_EFFECT_APPLY_AURA);
OnHit += SpellHitFn(func);              // after hit
AfterHit += SpellHitFn(func);           // after all effects

// Damage
OnCalcCritChance += SpellCritChanceFn(func);
OnCalcDamage += SpellDamageCalcFn(func);

// Misc
OnSummon += SpellSummonFn(func);
OnSummonDespawn += SpellSummonDespawnFn(func);
```

### 4.4 SpellScript Target Types (common)

```
TARGET_UNIT_TARGET_ENEMY
TARGET_UNIT_SRC_AREA_ENEMY
TARGET_UNIT_DEST_AREA_ENEMY
TARGET_UNIT_TARGET_ALLY
TARGET_UNIT_SRC_AREA_ALLY
TARGET_UNIT_DEST_AREA_ALLY
TARGET_UNIT_CONE_ENEMY_24
TARGET_UNIT_CONE_ENEMY_104
TARGET_DEST_DEST
TARGET_DEST_CASTER
TARGET_UNIT_CASTER
```

---

## 5. SMART AI (Database-Driven AI)

### 5.1 Table: `smart_scripts`
```sql
CREATE TABLE `smart_scripts` (
  `entryguid` INT UNSIGNED NOT NULL,        -- creature ID or GUID
  `source_type` TINYINT UNSIGNED NOT NULL,   -- 0=creature, 1=gameobject, 2=area trigger, 3=event, 9=instance script
  `id` SMALLINT UNSIGNED NOT NULL,           -- event index per source
  `link` SMALLINT UNSIGNED NOT NULL DEFAULT 0, -- linked event index
  `event_type` TINYINT UNSIGNED NOT NULL,    -- SMART_EVENT_*
  `event_phase_mask` INT UNSIGNED NOT NULL DEFAULT 0,
  `event_chance` TINYINT UNSIGNED NOT NULL DEFAULT 100,
  `event_flags` INT UNSIGNED NOT NULL DEFAULT 0,
  `event_param1` INT UNSIGNED NOT NULL DEFAULT 0,
  `event_param2` INT UNSIGNED NOT NULL DEFAULT 0,
  `event_param3` INT UNSIGNED NOT NULL DEFAULT 0,
  `event_param4` INT UNSIGNED NOT NULL DEFAULT 0,
  `event_param5` INT UNSIGNED NOT NULL DEFAULT 0,
  `action_type` TINYINT UNSIGNED NOT NULL,   -- SMART_ACTION_*
  `action_param1` INT UNSIGNED NOT NULL DEFAULT 0,
  `action_param2` INT UNSIGNED NOT NULL DEFAULT 0,
  `action_param3` INT UNSIGNED NOT NULL DEFAULT 0,
  `action_param4` INT UNSIGNED NOT NULL DEFAULT 0,
  `action_param5` INT UNSIGNED NOT NULL DEFAULT 0,
  `action_param6` INT UNSIGNED NOT NULL DEFAULT 0,
  `target_type` TINYINT UNSIGNED NOT NULL,   -- SMART_TARGET_*
  `target_param1` INT UNSIGNED NOT NULL DEFAULT 0,
  `target_param2` INT UNSIGNED NOT NULL DEFAULT 0,
  `target_param3` INT UNSIGNED NOT NULL DEFAULT 0,
  `timer_type` TINYINT UNSIGNED NOT NULL DEFAULT 0, -- 0=event->action, 1=action finished->next
  `comment` TEXT NOT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4;
```

### 5.2 Common SmartEvents
```
SMART_EVENT_AGGRO               (0)
SMART_EVENT_DEATH               (6)
SMART_EVENT_TIMED               (22)  - repeat every param1-param2 ms
SMART_EVENT_TIMED_OOC           (23)
SMART_EVENT_HP                  (9)
SMART_EVENT_TARGET_HP           (32)
SMART_EVENT_PHASE_CHANGE        (25)
SMART_EVENT_SPELLHIT            (10)
SMART_EVENT_SUMMONED_UNIT       (52)
SMART_EVENT_JUST_SUMMONED       (61)
SMART_EVENT_DATA_SET            (73)  - triggers on SetData
```

### 5.3 Common SmartActions
```
SMART_ACTION_TALK               (1)   - creature text
SMART_ACTION_SET_FACTION        (5)
SMART_ACTION_MOVEMENT           (10)
SMART_ACTION_CAST               (11)
SMART_ACTION_SUMMON_CREATURE    (15)
SMART_ACTION_SET_EVENT_PHASE    (30)
SMART_ACTION_SET_DATA           (35)  - calls SetData on scripts
SMART_ACTION_CALL_TIMED_ACTIONLIST (77) - run script9
SMART_ACTION_KILL_UNIT          (48)
```

### 5.4 SmartAI vs C++ Scripts Decision
```
Use SmartAI when:
  - Simple trash packs with basic abilities
  - NPCs with dialogue/emote sequences
  - Scripted events without complex mechanics
  - Achievements requiring simple conditions

Use C++ Scripts when:
  - Boss encounters with complex phase mechanics
  - Multi-target coordination
  - Custom targeting logic
  - Performance-critical AI
  - Complex spell interactions
```

---

## 6. ACHIEVEMENT SYSTEM

### 6.1 Criteria Data Types
```cpp
ACHIEVEMENT_CRITERIA_DATA_TYPE_NONE                 (0)
ACHIEVEMENT_CRITERIA_DATA_TYPE_T_CREATURE           (1)  -- kill creature_id
ACHIEVEMENT_CRITERIA_DATA_TYPE_T_PLAYER_CLASS_RACE  (2)
ACHIEVEMENT_CRITERIA_DATA_TYPE_T_PLAYER_LESS_HEALTH (3)
ACHIEVEMENT_CRITERIA_DATA_TYPE_S_AURA               (5)  -- player has aura
ACHIEVEMENT_CRITERIA_DATA_TYPE_T_AURA               (7)  -- target has aura
ACHIEVEMENT_CRITERIA_DATA_TYPE_VALUE                (8)  -- min value threshold
ACHIEVEMENT_CRITERIA_DATA_TYPE_T_LEVEL              (9)
ACHIEVEMENT_CRITERIA_DATA_TYPE_T_GENDER             (10)
ACHIEVEMENT_CRITERIA_DATA_TYPE_SCRIPT               (11) -- calls script hook
ACHIEVEMENT_CRITERIA_DATA_TYPE_MAP_DIFFICULTY       (12)
ACHIEVEMENT_CRITERIA_DATA_TYPE_MAP_PLAYER_COUNT     (13)
ACHIEVEMENT_CRITERIA_DATA_TYPE_INSTANCE_SCRIPT      (18) -- instance script checks
ACHIEVEMENT_CRITERIA_DATA_TYPE_MAP_ID               (20)
```

### 6.2 Achievement Criteria in SQL
```sql
-- achievement_criteria_data: define criteria requirements
INSERT INTO `achievement_criteria_data` (`criteria_id`, `type`, `value1`, `value2`, `ScriptName`) VALUES
(13000, 12, 0, 0, ''),           -- MapDifficulty
(13000, 18, 0, 0, '');           -- InstanceScript (script sets criteria met)
```

### 6.3 Achievement Check in InstanceScript
```cpp
// In boss script, mark achievement criteria
instance->UpdateAchievementCriteriaForAll(ACHIEVEMENT_CRITERIA_TYPE_BE_SPELL_TARGET, SPELL_SOME_EFFECT);

// Or let instance script check
bool CheckAchievementCriteriaMeet(uint32 criteria_id, Player* source, Unit* target = nullptr) override
{
    switch (criteria_id)
    {
        case CRITERIA_BOSS_KILL_NO_ADDS:
            return !_addsSpawned;
        default:
            return false;
    }
}

// Or in boss script after kill
if (instance && conditionMet)
    instance->DoCompleteAchievement(ACHIEVEMENT_ENTRY);
```

---

## 7. TRASH MOB PATTERN

```cpp
// Simple trash: use CreatureScript with basic AI, or SmartAI
class npc_trash_mob : public CreatureScript
{
public:
    npc_trash_mob() : CreatureScript("npc_trash_mob") { }

    struct npc_trash_mobAI : public ScriptedAI
    {
        npc_trash_mobAI(Creature* creature) : ScriptedAI(creature) { }

        void Reset() override
        {
            _scheduler.Schedule(Seconds(5), [this](TaskContext context)
            {
                if (Unit* target = SelectTarget(SELECT_TARGET_RANDOM, 0, 30.0f, true))
                    DoCast(target, SPELL_TRASH_ABILITY);
                context.Repeat(Seconds(10), Seconds(15));
            });
        }

        void JustEngagedWith(Unit* /*who*/) override
        {
            DoZoneInCombat();
        }

        void UpdateAI(uint32 diff) override
        {
            if (!UpdateVictim())
                return;

            _scheduler.Update(diff);

            DoMeleeAttackIfReady();
        }

    private:
        TaskScheduler _scheduler;
    };

    CreatureAI* GetAI(Creature* creature) const override
    {
        return new npc_trash_mobAI(creature);
    }
};
```

---

## 8. QUEST SCRIPTS

### 8.1 Quest Script Registration
```cpp
class quest_quest_name : public QuestScript
{
public:
    quest_quest_name() : QuestScript("quest_quest_name") { }

    void OnQuestStatusChange(Player* player, Quest const* quest, QuestStatus /*oldStatus*/, QuestStatus newStatus) override
    {
        if (newStatus == QUEST_STATUS_COMPLETE)
        {
            // reward handling
        }
    }
};

// For quest objectives with GO/creature credit
class npc_quest_giver : public CreatureScript
{
    // ...
    void OnQuestAccept(Player* player, Creature* creature, Quest const* quest) override
    {
        if (quest->GetQuestId() == QUEST_ID)
            creature->CastSpell(player, SPELL_QUEST_ACCEPT_EFFECT, true);
    }
};
```

### 8.2 Quest Creature/GO Template
```cpp
class npc_quest_target : public CreatureScript
{
public:
    npc_quest_target() : CreatureScript("npc_quest_target") { }

    struct npc_quest_targetAI : public ScriptedAI
    {
        npc_quest_targetAI(Creature* creature) : ScriptedAI(creature) { }

        void sQuestReward(Player* player, Quest const* quest, uint32 /*opt*/) override
        {
            if (quest->GetQuestId() == QUEST_ID)
                // do something
        }
    };
};
```

---

## 9. CORE SYSTEMS REFERENCE

### 9.1 Damage Calculation
```
Physical: damage = (baseDamage + attackPower * multiplier) * armorReduction * anyMods
Spell:    damage = basePoints + spellPower * coeff * anyMods
Spell systems modify via:
- SpellScript: OnCalcDamage, OnCalcCritChance
- AuraScript: OnEffectCalcAmount, OnCalcPeriodic
- Unit::CalcDamage, Unit::SpellDamageBonusTaken
- Unit::DealDamage, Unit::DealSpellDamage
```

### 9.2 Creature Text
```cpp
// In creature_template addon: gossip_menu, npc_text, broadcast_text
// Use Talk(id) in C++ which uses broadcast_text from creature_text table

-- SQL: creature_text
INSERT INTO `creature_text` (`CreatureID`, `GroupID`, `ID`, `Text`, `Type`, `Language`, `Probability`, `Emote`, `Duration`, `Sound`, `BroadcastTextId`, `TextRange`, `comment`) VALUES
(36612, 0, 0, 'You will suffer for this trespass!', 14, 0, 100, 0, 0, 17495, 39801, 0, 'Lord Marrowgar SAY_AGGRO');
-- Type: 12=CHAT, 14=YELL, 41=EMOTE, 42=BOSS_EMOTE, 16=WHISPER
```

### 9.3 Boundary/Collision Types
```cpp
CircleBoundary(Position center, float radius);
RectangleBoundary(float x1, float x2, float y1, float y2);
EllipseBoundary(Position center, float radiusX, float radiusY);
ParallelogramBoundary(Position p1, Position p2, Position p3);
ZRangeBoundary(float zMin, float zMax);
```

### 9.4 Difficulty Detection
```cpp
IsHeroic()                    // 10H or 25H
Is25ManRaid()                 // 25N or 25H
GetDifficulty()               // enum Difficulty

RAID_MODE<uint32>(10n, 25n, 10h, 25h);
DUNGEON_MODE<uint32>(5n, 5h);
```

### 9.5 Typical Phase Transition Pattern
```cpp
// Phase 1 → Phase 2 at 70% HP
if (eventId == EVENT_CHECK_HEALTH_P2 && HealthBelowPct(70))
{
    events.PopEvent(EVENT_CHECK_HEALTH_P2);
    events.CancelEventGroup(EVENT_GROUP_P1);
    // transition effects
    events.ScheduleEvent(EVENT_P2_ABILITY, 5000);
    me->SetReactState(REACT_PASSIVE);
    me->AttackStop();
    // movement, visual, etc.
}

// Phase transition with movement
void MovementInform(uint32 type, uint32 pointId) override
{
    if (type != POINT_MOTION_TYPE && type != EFFECT_MOTION_TYPE)
        return;

    switch (pointId)
    {
        case POINT_LANDING:
            me->SetReactState(REACT_AGGRESSIVE);
            DoZoneInCombat();
            // schedule phase 2 events
            break;
    }
}
```

### 9.6 Summon Management
```cpp
// Auto-tracked via SummonList
DoSummon(NPC_ADD, spawnPos, TEMPSUMMON_CORPSE_TIMED_DESPAWN, 30000);
// SummonList stores GUIDs, auto-clears in _JustDied()/_Reset()
summons.DespawnEntry(NPC_ADD);
summons.DespawnAll();
summons.DoZoneInCombat();
```

---

## 10. SQL UPDATE CONVENTIONS

### 10.1 File Naming
```
sql/updates/world/YYYY_MM_DD_00_zone_name.sql
sql/updates/characters/YYYY_MM_DD_00_description.sql
```

### 10.2 Common World DB Updates
```sql
-- Creature spawn
DELETE FROM `creature` WHERE `id1` = NPC_ID;
INSERT INTO `creature` (`id1`, `map`, `zoneId`, `areaId`, `position_x`, `position_y`, `position_z`, `orientation`, `spawnMask`, `curhealth`) VALUES
(NPC_ID, MAP_ID, ZONE_ID, AREA_ID, x, y, z, o, 15, health);

-- Creature template
UPDATE `creature_template` SET `ScriptName` = 'boss_boss_name', `minlevel` = 87, `maxlevel` = 87, `faction` = 16, ... WHERE `entry` = NPC_ID;

-- Creature text
DELETE FROM `creature_text` WHERE `CreatureID` = NPC_ID;
INSERT INTO `creature_text` (`CreatureID`, `GroupID`, `ID`, `Text`, `Type`, `Language`, `Probability`, `Emote`, `Duration`, `Sound`, `comment`) VALUES
(NPC_ID, 0, 0, 'Aggro text!', 14, 0, 100, 0, 0, 0, 'Boss SAY_AGGRO');

-- Creature loot
DELETE FROM `creature_loot_template` WHERE `Entry` = NPC_ID;
INSERT INTO `creature_loot_template` (`Entry`, `Item`, `Chance`, `MinCount`, `MaxCount`) VALUES
(NPC_ID, ITEM_ID, 100, 1, 1);

-- Spells
DELETE FROM `creature_template_spell` WHERE `CreatureID` = NPC_ID;
INSERT INTO `creature_template_spell` (`CreatureID`, `Index`, `Spell`, `Type`) VALUES
(NPC_ID, 0, SPELL_ID, 0);

-- SmartAI
DELETE FROM `smart_scripts` WHERE `entryguid` = NPC_ID AND `source_type` = 0;
INSERT INTO `smart_scripts` (`entryguid`, `source_type`, `id`, `link`, `event_type`, `event_phase_mask`, `event_chance`, `event_flags`, `event_param1`, `event_param2`, `event_param3`, `event_param4`, `event_param5`, `action_type`, `action_param1`, `action_param2`, `action_param3`, `action_param4`, `action_param5`, `action_param6`, `target_type`, `target_param1`, `target_param2`, `target_param3`, `comment`) VALUES
(NPC_ID, 0, 0, 0, 0, 0, 100, 0, 0, 0, 0, 0, 0, 11, SPELL_ID, 0, 0, 0, 0, 0, 2, 0, 0, 0, 'Aggro - Cast spell');

-- Achievements
DELETE FROM `achievement_criteria_data` WHERE `criteria_id` = CRITERIA_ID;
INSERT INTO `achievement_criteria_data` (`criteria_id`, `type`, `value1`, `value2`, `ScriptName`) VALUES
(CRITERIA_ID, 18, 0, 0, '');

-- Instance encounter
DELETE FROM `instance_encounter` WHERE `entry` = NPC_ID;
INSERT INTO `instance_encounter` (`entry`, `creditType`, `creditEntry`, `lastEncounterDungeon`) VALUES
(NPC_ID, 0, NPC_ID, 0);

-- Gameobject spawn
DELETE FROM `gameobject` WHERE `id` = GO_ID;
INSERT INTO `gameobject` (`id`, `map`, `zoneId`, `areaId`, `position_x`, `position_y`, `position_z`, `orientation`, `rotation0`, `rotation1`, `rotation2`, `rotation3`, `spawnMask`, `animprogress`, `state`) VALUES
(GO_ID, MAP, ZONE, AREA, x, y, z, o, 0, 0, sin(o/2), cos(o/2), 15, 100, 1);
```

---

## 11. NEW BOSS/RAID CREATION CHECKLIST

### Phase 1: SQL Setup
- [ ] `creature_template` — entry, model, faction, level, health, armor, damage, loot
- [ ] `creature_template_addon` — auras, mount, bytes
- [ ] `creature_equip_template` — weapons
- [ ] `creature_text` — dialogue lines
- [ ] `creature_loot_template` — loot table
- [ ] `creature` — spawn location in world
- [ ] `gameobject_template` — doors, chests
- [ ] `gameobject` — spawn positions
- [ ] `instance_encounter` — encounter registration
- [ ] `achievement_criteria_data` — if achievements
- [ ] spawn/set up trash packs in area

### Phase 2: Header File
- [ ] `zone_name.h` — DataTypes, CreatureIds, GameObjectIds, AchievementCriteriaIds, shared spells, actions

### Phase 3: Instance Script
- [ ] `instance_zone_name.cpp`:
  - [ ] `BossBoundaryData` — boss room boundaries
  - [ ] `DoorData` — door/encounter linkage
  - [ ] `OnCreatureCreate` — store boss GUIDs
  - [ ] `OnGameObjectCreate` — add doors/objects
  - [ ] Save/Load data
  - [ ] Achievement criteria checks

### Phase 4: Boss Scripts
- [ ] `boss_boss_name.cpp`:
  - [ ] `enum Texts, Spells, Events, MiscData, Actions`
  - [ ] `boss_boss_name` class (CreatureScript)
  - [ ] `boss_boss_nameAI : BossAI`
  - [ ] `Reset()` — schedule initial events
  - [ ] `JustEngagedWith()` — aggro, zone combat, set boss state
  - [ ] `JustDied()` — death actions
  - [ ] `UpdateAI()` — main loop
  - [ ] `ExecuteEvent()` — event handler
  - [ ] Phase transitions if multi-phase
  - [ ] MovementInform if platform/position movement
  - [ ] Spell scripts for custom abilities
  - [ ] Achievements: SetData/GetData for tracking

### Phase 5: Registration
- [ ] Register `AddSC_instance_zone_name()`
- [ ] Register `AddSC_boss_boss_name()`
- [ ] Add to zone's CMakeLists.txt or script loader

### Phase 6: Testing
- [ ] Verify boss spawns and engages
- [ ] Test all abilities (cast, damage, timing)
- [ ] Test phase transitions
- [ ] Test achievements
- [ ] Test save/load (instance data persistence)
- [ ] Test both 10N, 25N, 10H, 25H difficulties
- [ ] Test loot distribution

---

## 12. COMMON MISTAKES TO AVOID

```cpp
// WRONG: Not checking UNIT_STATE_CASTING before casting
void UpdateAI(uint32 diff) { /* cast directly without check */ }

// RIGHT: Check casting state
void UpdateAI(uint32 diff)
{
    if (!UpdateVictim()) return;
    events.Update(diff);
    if (me->HasUnitState(UNIT_STATE_CASTING)) return;
    // ... execute events then
    DoMeleeAttackIfReady();
}

// WRONG: Re-scheduling in UpdateAI instead of ExecuteEvent
// WRONG: Not calling DoMeleeAttackIfReady()
// WRONG: Forgetting events.Repeat() — event fires once then dies
// WRONG: Using raw numbers instead of named enums
// WRONG: Not namespace-wrapping the boss script
// WRONG: Overwriting _JustDied without calling _base functions
// WRONG: Not calling instance->SetBossState(IN_PROGRESS) on engage
// WRONG: Casting without checking if target is valid
```

---

## 13. REGISTRATION FUNCTIONS

Each .cpp file must have a registration function near the bottom:

```cpp
// Zone/Instance
void AddSC_instance_zone_name()
{
    new instance_zone_name();
}

// Boss
void AddSC_boss_boss_name()
{
    new boss_boss_name();
}

// Spell
void AddSC_spell_spell_name()
{
    new spell_spell_name();
}

// NPC
void AddSC_npc_npc_name()
{
    new npc_npc_name();
}
```

Registration functions are called in `ScriptLoader.cpp` or auto-loaded if using modern ScriptMgr.

---

## 14. KEY FILES REFERENCE

```
Core Scripting Framework:
  src/server/game/Scripting/ScriptMgr.h          — All script registration macros
  src/server/game/Scripting/ScriptSystem.h        — Script loading

AI Framework:
  src/server/game/AI/ScriptedAI/ScriptedCreature.h — ScriptedAI, BossAI, WorldBossAI
  src/server/game/AI/CoreAI/UnitAI.h              — Base UnitAI
  src/server/game/AI/CoreAI/CombatAI.h            — CombatAI template
  src/server/game/AI/CoreAI/GameObjectAI.h        — GameObject AI

Instance System:
  src/server/game/Instances/InstanceScript.h       — InstanceScript base class
  src/server/game/Instances/MapBoundary.h          — Boundary definitions

Spell System:
  src/server/game/Spells/SpellScript.h             — SpellScript, AuraScript
  src/server/game/Spells/Spell.h                   — Spell class
  src/server/game/Spells/SpellAuraEffects.h        — AuraEffect

Achievement System:
  src/server/game/Achievements/AchievementMgr.h    — Achievement criteria types, data

Database/SmartAI:
  src/server/game/AI/SmartScripts/SmartScript.h    — SmartAI script handler
  src/server/game/AI/SmartScripts/SmartScriptMgr.h — SmartAI event/action enums

Zone Scripts (examples to follow):
  src/server/scripts/Northrend/IcecrownCitadel/    — Full raid reference
  src/server/scripts/Cataclysm/                    — Cata encounters
```

---

## 15. RULES SUMMARY

1. **Namespace EVERY boss script** — `namespace ZoneName::BossName`
2. **Use enums** for texts, spells, events, misc data — never raw numbers in logic
3. **BossAI preferred** for instance bosses. WorldBossAI for outdoor. ScriptedAI for trash.
4. **Check UNIT_STATE_CASTING** before casting in UpdateAI
5. **Call _base methods** in overrides (_Reset, _JustDied, etc.)
6. **Call instance->SetBossState** on engage/die/evade
7. **DoZoneInCombat()** and **me->setActive(true)** on engage
8. **Events: schedule once in Reset**, repeat in ExecuteEvent
9. **Re-schedule with events.Repeat()** — don't schedule from ExecuteEvent
10. **Always call DoMeleeAttackIfReady()** in UpdateAI for melee bosses
11. **No magic numbers** in SQL — use named IDs
12. **RAID_MODE/DUNGEON_MODE** for difficulty-scaled values
13. **SmartAI** for simple AI; **C++** for complex encounters
14. **Achievement check via InstanceScript::CheckAchievementCriteriaMeet**
15. **Comment every SQL insert** describing what it does
16. **One registration function per file** (AddSC_...)