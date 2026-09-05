#include "AuraScript.h"
#include "SelectTarget.h"
/*
 * TrinityCore 4.3.4 - Dragon Soul: Ultraxion 55294
 * Port do Pandaria 5.4.8 (ultraxion_mop.cpp) -> Cata 4.3.4
 * Ref: Spell.dbc TCP 4.3.4 (spell IDs validados contra a DBC), warcraft.wiki Ultraxion
 * Padrao: struct : public BossAI + RegisterDragonSoulCreatureAI, Spell/AuraScript sem Prepare*.
 *
 * Mecanica (Blizzlike DS):
 *  - Spawn apos Hagara DONE (hook no instance_dragon_soul SetBossState).
 *  - Intro: spawn invisivel -> move pro piao -> Twilight Shift (puxa raid p/ Twilight Realm).
 *  - Unstable Monstrosity (soft enrage por stacks), Hour of Twilight (soak no Twilight Realm),
 *    Fading Light (expira -> kill Twilight Realm / puxa Normal Realm), Heroic Will (remove do Twilight Realm),
 *    Twilight Instability, Twilight Burst, bufes dos Aspectos (Thrall/Last Defender, Alextrasza/Gift,
 *    Ysera/Essence, Kalecgos/Source, Nozdormu/Timeloop).
 */

#include "dragon_soul.h"
#include "ScriptedCreature.h"
#include "ScriptMgr.h"
#include "SpellScript.h"
#include "SpellAuraEffects.h"
#include "SpellInfo.h"
#include "SpellDefines.h"
#include "GameObject.h"
#include "Player.h"
#include "InstanceScript.h"
#include "ObjectAccessor.h"
#include "TemporarySummon.h"
#include "Map.h"
#include "Containers.h"
#include <chrono>
#include <list>
#include <vector>

using namespace std::chrono_literals;

namespace DragonSoul::Ultraxion
{

enum ScriptedTexts
{
    SAY_AGGRO       = 0, // "Now is the Hour of Twilight!" 26314 VO_DS_ULTRAXION_AGGRO_01
    SAY_BERSERK     = 1, // "I WILL DRAG YOU WITH ME INTO FLAME AND DARKNESS!" 26315 VO_DS_ULTRAXION_BERSERK_01 (Twilight Eruption)
    SAY_DEATH       = 2, // "But...but...I am...Ul...trax...ionnnnnn..." 26316 VO_DS_ULTRAXION_DEATH_01
    SAY_INTRO_1     = 3, // "I am the beginning of the end..." 26317 VO_DS_ULTRAXION_INTRO_01
    SAY_INTRO_2     = 4, // "For this moment ALONE was I made..." 26318 VO_DS_ULTRAXION_INTRO_02
    SAY_KILL        = 5, // 26319/26320/26321 VO_DS_ULTRAXION_SLAY_01..03
    SAY_TWILIGHT    = 6, // "The final shred of light fades..." 26323 VO_DS_ULTRAXION_SPELL_01 (Hour of Twilight)
    SAY_UNSTABLE    = 7, // "Through the pain and fire my hatred burns!" 26324 VO_DS_ULTRAXION_SPELL_02 (More Unstable)

    // Aspectos (creature_text proprio por entry): ANN_THRALL_LAST_DEFENDER=8 (56103),
    // ANN_ALEXTRASZA_GIFT=6 (56099), ANN_YSERA_ESSENCE=5 (56100),
    // ANN_KALECGOS_SOURCE=5 (56101), ANN_NOZDORNU_TIMELOOP=2 (56102).
    ANN_THRALL_LAST_DEFENDER = 8,
    ANN_ALEXTRASZA_GIFT      = 6,
    ANN_YSERA_ESSENCE        = 5,
    ANN_KALECGOS_SOURCE      = 5,
    ANN_NOZDORNU_TIMELOOP    = 2,
};

enum WorldStates
{
    // DBC Achievement_Criteria 18391 (Ach 6084 "Minutes to Midnight") RequiredWorldStateID 6131 == 0 for success.
    // 0 = ninguem atingido 2x pela Hour of Twilight, 1 = falha (aura 109188 reapply stack>1).
    WORLDSTATE_MINUTES_TO_MIDNIGHT = 6131,
};
enum Spells
{
    SPELL_UNSTABLE_MONSTROSITY_1            = 106372, // 6 secs
    SPELL_UNSTABLE_MONSTROSITY_2            = 106376, // 5 secs
    SPELL_UNSTABLE_MONSTROSITY_3            = 106377, // 4 secs
    SPELL_UNSTABLE_MONSTROSITY_4            = 106378, // 3 secs
    SPELL_UNSTABLE_MONSTROSITY_5            = 106379, // 2 secs
    SPELL_UNSTABLE_MONSTROSITY_6            = 106380, // 1 secs
    SPELL_TWILIGHT_INSTABILITY_AOE_1        = 109176,
    SPELL_TWILIGHT_INSTABILITY_AOE_2        = 106374,
    SPELL_TWILIGHT_INSTABILITY_DMG          = 106375,
    SPELL_UNSTABLE_MONSTROSITY_DUMMY_1      = 106390,
    SPELL_UNSTABLE_MONSTROSITY_DUMMY_2      = 106381,

    SPELL_TWILIGHT_SHIFT_AOE                = 106369,
    SPELL_TWILIGHT_SHIFT                    = 106368,
    SPELL_HEROIC_WILL_AOE                   = 105554,
    SPELL_HEROIC_WILL                       = 106108,
    SPELL_FADED_INTO_TWILIGHT               = 105927,
    SPELL_ULTRAXION_NORMAL_REALM_COSMETIC   = 105929,

    SPELL_HOUR_OF_TWILIGHT                  = 106371,
    SPELL_HOUR_OF_TWILIGHT_DMG              = 103327,
    SPELL_HOUR_OF_TWILIGHT_1                = 106174, // remove heroic will
    SPELL_HOUR_OF_TWILIGHT_2                = 106370, // from player, force cast achievement

    SPELL_LOOMING_DARKNESS_DUMMY            = 106498,
    SPELL_LOOMING_DARKNESS_DMG              = 109231,

    SPELL_FADING_LIGHT_1                    = 105925, // from boss to player, triggered by hour of twilight, tank only
    SPELL_FADING_LIGHT_KILL                 = 105926, // kill player
    SPELL_FADING_LIGHT_AOE_1                = 109075, // from boss, triggered by 105925, dps
    SPELL_FADING_LIGHT_DUMMY                = 109200,

    SPELL_TWILIGHT_BURST                    = 106415,
    SPELL_TWILIGHT_ERUPTION                 = 106388,

    SPELL_LAST_DEFENDER_OF_AZEROTH          = 106182,
    SPELL_LAST_DEFENDER_OF_AZEROTH_DUMMY    = 110327,
    SPELL_LAST_DEFENDER_OF_AZEROTH_DRUID    = 106224,
    SPELL_LAST_DEFENDER_OF_AZEROTH_PALADIN  = 106226,
    SPELL_LAST_DEFENDER_OF_AZEROTH_DK       = 106227,
    SPELL_LAST_DEFENDER_OF_AZEROTH_WARRIOR  = 106080,

    SPELL_GIFT_OF_LIVE_AURA                 = 105896,
    SPELL_GIFT_OF_LIVE_1                    = 106042,
    SPELL_GIFT_OF_LIVE_2                    = 109345, // triggered by 106042 in 25 ppl

    SPELL_ESSENCE_OF_DREAMS_AURA            = 105900,
    SPELL_ESSENCE_OF_DREAMS_HEAL            = 105996,
    SPELL_ESSENCE_OF_DREAMS_1               = 106049,
    SPELL_ESSENCE_OF_DREAMS_2               = 109344, // triggered by 106049 in 25 ppl

    SPELL_SOURCE_OF_MAGIC_AURA              = 105903,
    SPELL_SOURCE_OF_MAGIC_1                 = 106050,
    SPELL_SOURCE_OF_MAGIC_2                 = 109347, // triggered by 106050 in 25 ppl

    SPELL_TIMELOOP                          = 105984,
    SPELL_TIMELOOP_HEAL                     = 105992,

    SPELL_ULTRAXION_ACHIEVEMENT_AURA        = 109188,
    SPELL_ULTRAXION_AHCIEVEMENT_FAILED      = 109194,
};

enum Events
{
    EVENT_ULTRAXION_SPAWNED     = 1,
    EVENT_MOVE                  = 2,
    EVENT_TALK_1                = 3,
    EVENT_TALK_2                = 4,
    EVENT_UNSTABLE_MONSTROSITY  = 5,
    EVENT_HOUR_OF_TWILIGHT      = 6,
    EVENT_CHECK_TARGET          = 7,
    EVENT_THRALL                = 8,
    EVENT_ALEXSTRASZA           = 9,
    EVENT_YSERA                 = 10,
    EVENT_KALECGOS              = 11,
    EVENT_NOZDORMU              = 12,
    EVENT_END_TALK              = 13,
    EVENT_NOZDORMU_2            = 14,
};

enum Adds
{
    GO_GIFT_OF_LIFE         = 209873,
    GO_ESSENCE_OF_DREAMS    = 209874,
    GO_SOURCE_OF_MAGIC      = 209875,
};

enum Actions
{
    ACTION_TWILIGHT_ERUPTION = 1,
};

// [0] spawn invisivel, [1] posicao final do piao (batalha).
// NOTE: coords placeholders derivadas do design 4.3.4 (piao do cume, Z ~250).
Position const ultraxionPos[] =
{
    { -1564.0f, -2369.0f, 250.083f, 3.28f },
    { -1564.0f, -2369.0f, 250.083f, 3.28f }
};
struct boss_ultraxionAI : public BossAI
{
    boss_ultraxionAI(Creature* creature) : BossAI(creature, DATA_ULTRAXION)
    {
        me->ApplySpellImmune(0, IMMUNITY_EFFECT, SPELL_EFFECT_KNOCK_BACK, true);
        me->ApplySpellImmune(0, IMMUNITY_MECHANIC, MECHANIC_GRIP, true);
        me->ApplySpellImmune(0, IMMUNITY_MECHANIC, MECHANIC_STUN, true);
        me->ApplySpellImmune(0, IMMUNITY_MECHANIC, MECHANIC_FEAR, true);
        me->ApplySpellImmune(0, IMMUNITY_MECHANIC, MECHANIC_ROOT, true);
        me->ApplySpellImmune(0, IMMUNITY_MECHANIC, MECHANIC_FREEZE, true);
        me->ApplySpellImmune(0, IMMUNITY_MECHANIC, MECHANIC_POLYMORPH, true);
        me->ApplySpellImmune(0, IMMUNITY_MECHANIC, MECHANIC_HORROR, true);
        me->ApplySpellImmune(0, IMMUNITY_MECHANIC, MECHANIC_SAPPED, true);
        me->ApplySpellImmune(0, IMMUNITY_MECHANIC, MECHANIC_CHARM, true);
        me->ApplySpellImmune(0, IMMUNITY_MECHANIC, MECHANIC_DISORIENTED, true);
        me->ApplySpellImmune(0, IMMUNITY_STATE, SPELL_AURA_MOD_CONFUSE, true);
        me->setActive(true);
        me->SetReactState(REACT_DEFENSIVE);
        me->SetFlag(UNIT_FIELD_FLAGS, UNIT_FLAG_IMMUNE_TO_PC | UNIT_FLAG_NOT_SELECTABLE);
        unstableCount = 0;
    }

    void Reset() override
    {
        _Reset();

        RemoveEncounterAuras();
        DeleteGameObjects(GO_GIFT_OF_LIFE);
        DeleteGameObjects(GO_ESSENCE_OF_DREAMS);
        DeleteGameObjects(GO_SOURCE_OF_MAGIC);

        me->setActive(true);

        unstableCount = 0;

        me->SetHomePosition(ultraxionPos[1]);
        me->GetMap()->SetWorldStateValue(WORLDSTATE_MINUTES_TO_MIDNIGHT, 0, false);
    }

    void EnterEvadeMode(EvadeReason reason = EXECUTE_DIRECTLY) override
    {
        BossAI::EnterEvadeMode();
        if (InstanceScript* script = me->GetInstanceScript())
            script->SetBossState(DATA_ULTRAXION, FAIL);
    }

    void AttackStart(Unit* target) override
    {
        if (!target)
            return;

        if (me->Attack(target, true))
            DoStartNoMovement(target);
    }

    void IsSummonedBy(Unit* /*summoner*/) override
    {
        me->SetVisible(false);

        unstableCount = 0;

        RemoveEncounterAuras();
        DeleteGameObjects(GO_GIFT_OF_LIFE);
        DeleteGameObjects(GO_ESSENCE_OF_DREAMS);
        DeleteGameObjects(GO_SOURCE_OF_MAGIC);
        events.ScheduleEvent(EVENT_ULTRAXION_SPAWNED, 3s);
    }

    void JustEngagedWith(Unit* who) override
    {
        BossAI::JustEngagedWith(who);

        Talk(SAY_AGGRO);

        instance->DoRemoveAurasDueToSpellOnPlayers(SPELL_ULTRAXION_ACHIEVEMENT_AURA);
        RemoveEncounterAuras();
        DeleteGameObjects(GO_GIFT_OF_LIFE);
        DeleteGameObjects(GO_ESSENCE_OF_DREAMS);
        DeleteGameObjects(GO_SOURCE_OF_MAGIC);

        me->GetMap()->SetWorldStateValue(WORLDSTATE_MINUTES_TO_MIDNIGHT, 0, false);

        unstableCount = 0;

        DoCastAOE(SPELL_TWILIGHT_SHIFT_AOE, true);
        DoCastAOE(SPELL_HEROIC_WILL_AOE, true);

        events.ScheduleEvent(EVENT_UNSTABLE_MONSTROSITY, 1s);
        events.ScheduleEvent(EVENT_HOUR_OF_TWILIGHT, 45s);
        events.ScheduleEvent(EVENT_CHECK_TARGET, 4s);
        events.ScheduleEvent(EVENT_THRALL, 5s);
        events.ScheduleEvent(EVENT_ALEXSTRASZA, 80s);
        events.ScheduleEvent(EVENT_YSERA, 155s);
        events.ScheduleEvent(EVENT_KALECGOS, 215s);
        events.ScheduleEvent(EVENT_NOZDORMU, 5 * 60s);

        DoZoneInCombat();
        instance->SetBossState(DATA_ULTRAXION, IN_PROGRESS);
    }

    void DoAction(int32 action) override
    {
        if (action == ACTION_TWILIGHT_ERUPTION)
        {
            unstableCount = 7;
            events.RescheduleEvent(EVENT_UNSTABLE_MONSTROSITY, 1s);
        }
    }

    void JustDied(Unit* /*killer*/) override
    {
        _JustDied();

        Talk(SAY_DEATH);

        RemoveEncounterAuras();
        DeleteGameObjects(GO_GIFT_OF_LIFE);
        DeleteGameObjects(GO_ESSENCE_OF_DREAMS);
        DeleteGameObjects(GO_SOURCE_OF_MAGIC);

        me->DespawnOrUnsummon(3000);
    }

    void KilledUnit(Unit* victim) override
    {
        if (victim && victim->GetTypeId() == TYPEID_PLAYER)
            Talk(SAY_KILL);
    }
void UpdateAI(uint32 diff) override
    {
        events.Update(diff);

        if (me->HasUnitState(UNIT_STATE_CASTING))
            return;

        if (uint32 eventId = events.ExecuteEvent())
        {
            switch (eventId)
            {
                case EVENT_ULTRAXION_SPAWNED:
                    Talk(SAY_INTRO_1);
                    me->SetVisible(true);
                    events.ScheduleEvent(EVENT_MOVE, 1s);
                    break;
                case EVENT_MOVE:
                    me->GetMotionMaster()->MovePoint(2, ultraxionPos[1]);
                    events.ScheduleEvent(EVENT_TALK_1, 7s);
                    break;
                case EVENT_TALK_1:
                    DoCastAOE(SPELL_TWILIGHT_SHIFT_AOE, true);
                    events.ScheduleEvent(EVENT_TALK_2, 4s);
                    break;
                case EVENT_TALK_2:
                    Talk(SAY_INTRO_2);
                    events.ScheduleEvent(EVENT_END_TALK, 15s);
                    break;
                case EVENT_END_TALK:
                    me->RemoveFlag(UNIT_FIELD_FLAGS, UNIT_FLAG_IMMUNE_TO_PC | UNIT_FLAG_NOT_SELECTABLE);
                    break;
                case EVENT_CHECK_TARGET:
                    if (Unit* victim = me->GetVictim())
                        if (!me->IsWithinMeleeRange(victim))
                            DoCastAOE(SPELL_TWILIGHT_BURST);
                    events.ScheduleEvent(EVENT_CHECK_TARGET, 4s);
                    break;
                case EVENT_THRALL:
                    if (Creature* pThrall = me->FindNearestCreature(NPC_THRALL_MADNESS_OF_DEATHWING, 300.0f))
                    {
                        pThrall->AI()->Talk(ANN_THRALL_LAST_DEFENDER);
                        pThrall->CastSpell(pThrall, SPELL_LAST_DEFENDER_OF_AZEROTH, true);
                    }
                    break;
                case EVENT_ALEXSTRASZA:
                    if (Creature* pAlextrasza = me->FindNearestCreature(NPC_ALEXSTRASZA_MADNESS_OF_DEATHWING, 300.0f))
                    {
                        pAlextrasza->AI()->Talk(ANN_ALEXTRASZA_GIFT);
                        pAlextrasza->CastSpell(pAlextrasza, SPELL_GIFT_OF_LIVE_1, true);
                    }
                    break;
                case EVENT_YSERA:
                    if (Creature* pYsera = me->FindNearestCreature(NPC_YSERA_MADNESS_OF_DEATHWING, 300.0f))
                    {
                        pYsera->AI()->Talk(ANN_YSERA_ESSENCE);
                        pYsera->CastSpell(pYsera, SPELL_ESSENCE_OF_DREAMS_1, true);
                    }
                    break;
case EVENT_KALECGOS:
                    if (Creature* pKalecgos = me->FindNearestCreature(NPC_KALECGOS_MADNESS_OF_DEATHWING, 300.0f))
                    {
                        pKalecgos->AI()->Talk(ANN_KALECGOS_SOURCE);
                        pKalecgos->CastSpell(pKalecgos, SPELL_SOURCE_OF_MAGIC_1, true);
                    }
                    break;
                case EVENT_NOZDORMU:
                    if (Creature* pNozdormu = me->FindNearestCreature(NPC_NOZDORMU_MADNESS_OF_DEATHWING, 300.0f))
                    {
                        pNozdormu->AI()->Talk(ANN_NOZDORNU_TIMELOOP);
                        pNozdormu->CastSpell(pNozdormu, SPELL_TIMELOOP, true);
                    }
                    events.ScheduleEvent(EVENT_NOZDORMU_2, 1s);
                    break;
                case EVENT_NOZDORMU_2:
                    if (Creature* pNozdormu = me->FindNearestCreature(NPC_NOZDORMU_MADNESS_OF_DEATHWING, 300.0f))
                        pNozdormu->GetMotionMaster()->MovePoint(0, pNozdormu->GetPositionX(), pNozdormu->GetPositionY(), pNozdormu->GetPositionZ() + 3);
                    break;
                case EVENT_UNSTABLE_MONSTROSITY:
                    unstableCount++;
                    switch (unstableCount)
                    {
                        case 1:
                            DoCastSelf(SPELL_UNSTABLE_MONSTROSITY_1, true);
                            break;
                        case 2:
                            me->RemoveAura(SPELL_UNSTABLE_MONSTROSITY_1);
                            DoCastSelf(SPELL_UNSTABLE_MONSTROSITY_2, true);
                            break;
                        case 3:
                            me->RemoveAura(SPELL_UNSTABLE_MONSTROSITY_2);
                            DoCastSelf(SPELL_UNSTABLE_MONSTROSITY_3, true);
                            break;
                        case 4:
                            Talk(SAY_UNSTABLE);
                            me->RemoveAura(SPELL_UNSTABLE_MONSTROSITY_3);
                            DoCastSelf(SPELL_UNSTABLE_MONSTROSITY_4, true);
                            break;
                        case 5:
                            me->RemoveAura(SPELL_UNSTABLE_MONSTROSITY_4);
                            DoCastSelf(SPELL_UNSTABLE_MONSTROSITY_5, true);
                            break;
                        case 6:
                            me->RemoveAura(SPELL_UNSTABLE_MONSTROSITY_5);
                            DoCastSelf(SPELL_UNSTABLE_MONSTROSITY_6, true);
                            break;
                        default:
                            break;
                    }
                    if (unstableCount >= 7)
                    {
                        Talk(SAY_BERSERK);
                        DoCastSelf(SPELL_TWILIGHT_ERUPTION);
                    }
                    else
                        events.ScheduleEvent(EVENT_UNSTABLE_MONSTROSITY, 1min);
                    break;
                case EVENT_HOUR_OF_TWILIGHT:
                    Talk(SAY_TWILIGHT);
                    DoCastSelf(SPELL_HOUR_OF_TWILIGHT);
                    events.ScheduleEvent(EVENT_HOUR_OF_TWILIGHT, 45s);
                    break;
                default:
                    break;
            }
        }

        if (!UpdateVictim())
            return;

        DoMeleeAttackIfReady();
    }
private:
    uint8 unstableCount;

    void DeleteGameObjects(uint32 entry)
    {
        std::list<GameObject*> gameobjects;
        me->GetGameObjectListWithEntryInGrid(gameobjects, entry, 300.0f);
        if (!gameobjects.empty())
            for (std::list<GameObject*>::iterator itr = gameobjects.begin(); itr != gameobjects.end(); ++itr)
                (*itr)->Delete();
    }

    void RemoveEncounterAuras()
    {
        instance->DoRemoveAurasDueToSpellOnPlayers(SPELL_ULTRAXION_ACHIEVEMENT_AURA);
        instance->DoRemoveAurasDueToSpellOnPlayers(SPELL_LOOMING_DARKNESS_DUMMY);
        instance->DoRemoveAurasDueToSpellOnPlayers(SPELL_LOOMING_DARKNESS_DMG);
        instance->DoRemoveAurasDueToSpellOnPlayers(SPELL_TWILIGHT_SHIFT);
        instance->DoRemoveAurasDueToSpellOnPlayers(SPELL_HEROIC_WILL_AOE);
        instance->DoRemoveAurasDueToSpellOnPlayers(SPELL_GIFT_OF_LIVE_AURA);
        instance->DoRemoveAurasDueToSpellOnPlayers(SPELL_ESSENCE_OF_DREAMS_AURA);
        instance->DoRemoveAurasDueToSpellOnPlayers(SPELL_SOURCE_OF_MAGIC_AURA);
        instance->DoRemoveAurasDueToSpellOnPlayers(SPELL_TIMELOOP);
        instance->DoRemoveAurasDueToSpellOnPlayers(SPELL_LAST_DEFENDER_OF_AZEROTH_DK);
        instance->DoRemoveAurasDueToSpellOnPlayers(SPELL_LAST_DEFENDER_OF_AZEROTH_PALADIN);
        instance->DoRemoveAurasDueToSpellOnPlayers(SPELL_LAST_DEFENDER_OF_AZEROTH_DRUID);
        instance->DoRemoveAurasDueToSpellOnPlayers(SPELL_LAST_DEFENDER_OF_AZEROTH_WARRIOR);
    }
};
struct spell_ultraxion_twilight_instability : public SpellScript
{
    void FilterTargets(std::list<WorldObject*>& targets)
    {
        if (!GetCaster())
            return;

        targets.remove_if(AuraCheck(SPELL_HEROIC_WILL, true));
    }

    void HandleScript()
    {
        if (!GetCaster() || !GetHitUnit())
            return;

        if (GetCaster()->HasUnitState(UNIT_STATE_CASTING))
            return;

        GetCaster()->CastSpell(GetHitUnit(), SPELL_TWILIGHT_INSTABILITY_DMG, true);
    }

    void Register() override
    {
        OnObjectAreaTargetSelect.Register(&spell_ultraxion_twilight_instability::FilterTargets, EFFECT_0, TARGET_UNIT_SRC_AREA_ENEMY);
        AfterHit.Register(&spell_ultraxion_twilight_instability::HandleScript);
    }

private:
    class AuraCheck
    {
    public:
        AuraCheck(uint32 spellId, bool present) : _spellId(spellId), _present(present) { }

        bool operator()(WorldObject* unit)
        {
            if (!unit->ToUnit())
                return true;

            if (_present)
                return unit->ToUnit()->HasAura(_spellId);
            else
                return !unit->ToUnit()->HasAura(_spellId);
        }

    private:
        uint32 _spellId;
        bool _present;
    };
};

struct spell_ultraxion_hour_of_twilight_dmg : public SpellScript
{
    void HandleHitTarget(SpellEffIndex /*effIndex*/)
    {
        if (!GetCaster() || !GetCaster()->GetInstanceScript())
            return;

        if (!GetCaster()->GetMap()->IsHeroic())
            return;

        if (Unit* target = GetHitUnit())
            if (!target->HasAura(SPELL_LOOMING_DARKNESS_DUMMY))
                target->CastSpell(target, SPELL_LOOMING_DARKNESS_DUMMY);
    }

    void FilterTargetsDamage(std::list<WorldObject*>& targets)
    {
        if (!GetCaster())
            return;

        targets.remove_if(AuraCheck(SPELL_HEROIC_WILL, true));

        uint32 minPlayers = 1;
        switch (GetCaster()->GetMap()->GetDifficulty())
        {
            case RAID_DIFFICULTY_10MAN_NORMAL: minPlayers = 1; break;
            case RAID_DIFFICULTY_10MAN_HEROIC: minPlayers = 2; break;
            case RAID_DIFFICULTY_25MAN_NORMAL: minPlayers = 3; break;
            case RAID_DIFFICULTY_25MAN_HEROIC: minPlayers = 5; break;
            default: break;
        }

        if (targets.size() < minPlayers)
            if (Creature* pUltraxion = GetCaster()->ToCreature())
                pUltraxion->AI()->DoAction(ACTION_TWILIGHT_ERUPTION);
    }

    void FilterTargetsDarkness(std::list<WorldObject*>& targets)
    {
        if (!GetCaster())
            return;

        targets.remove_if(AuraCheck(SPELL_HEROIC_WILL, true));
        targets.remove_if(AuraCheck(SPELL_LOOMING_DARKNESS_DUMMY, false));
    }

    void FilterTargetsAchievement(std::list<WorldObject*>& targets)
    {
        if (!GetCaster())
            return;

        targets.remove_if(AuraCheck(SPELL_HEROIC_WILL, true));
    }

    void Register() override
    {
        OnEffectHitTarget.Register(&spell_ultraxion_hour_of_twilight_dmg::HandleHitTarget, EFFECT_0, SPELL_EFFECT_SCHOOL_DAMAGE);
        OnObjectAreaTargetSelect.Register(&spell_ultraxion_hour_of_twilight_dmg::FilterTargetsDamage, EFFECT_0, TARGET_UNIT_SRC_AREA_ENTRY);
        OnObjectAreaTargetSelect.Register(&spell_ultraxion_hour_of_twilight_dmg::FilterTargetsDarkness, EFFECT_1, TARGET_UNIT_SRC_AREA_ENTRY);
        OnObjectAreaTargetSelect.Register(&spell_ultraxion_hour_of_twilight_dmg::FilterTargetsAchievement, EFFECT_2, TARGET_UNIT_SRC_AREA_ENTRY);
    }

private:
    class AuraCheck
    {
    public:
        AuraCheck(uint32 spellId, bool present) : _spellId(spellId), _present(present) { }

        bool operator()(WorldObject* unit)
        {
            if (!unit->ToUnit())
                return true;

            if (_present)
                return unit->ToUnit()->HasAura(_spellId);
            else
                return !unit->ToUnit()->HasAura(_spellId);
        }

    private:
        uint32 _spellId;
        bool _present;
    };
};
struct spell_ultraxion_fading_light_aura : public AuraScript
{
    void OnApply(AuraEffect const* aurEff, AuraEffectHandleModes /*mode*/)
    {
        if (!GetCaster())
            return;

        Aura* aura = aurEff->GetBase();

        uint32 duration = urand((GetCaster()->GetMap()->IsHeroic() ? 3000 : 5000), 9000);
        aura->SetDuration(duration);
        aura->SetMaxDuration(duration);
    }

    void OnRemove(AuraEffect const* /*aurEff*/, AuraEffectHandleModes /*mode*/)
    {
        if (GetTarget())
        {
            if (InstanceScript* script = GetTarget()->GetInstanceScript())
                if (script->GetBossState(DATA_ULTRAXION) != IN_PROGRESS)
                    return;
            if (GetTarget()->HasAura(SPELL_TWILIGHT_SHIFT))
                GetTarget()->CastSpell(GetTarget(), SPELL_FADING_LIGHT_KILL, true);
            else if (GetTarget()->HasAura(SPELL_HEROIC_WILL))
                GetTarget()->CastSpell(GetTarget(), SPELL_TWILIGHT_SHIFT, true);
        }
    }

    void Register() override
    {
        AfterEffectApply.Register(&spell_ultraxion_fading_light_aura::OnApply, EFFECT_0, SPELL_AURA_PERIODIC_DUMMY, AURA_EFFECT_HANDLE_REAL);
        AfterEffectRemove.Register(&spell_ultraxion_fading_light_aura::OnRemove, EFFECT_0, SPELL_AURA_PERIODIC_DUMMY, AURA_EFFECT_HANDLE_REAL);
    }
};

struct spell_ultraxion_fading_light : public SpellScript
{
    void FilterTargets(std::list<WorldObject*>& targets)
    {
        if (!GetCaster())
            return;

        targets.remove_if(DPSCheck());

        if (Creature* pUltraxion = GetCaster()->ToCreature())
            if (Unit* target = pUltraxion->AI()->SelectTarget(SELECT_TARGET_TOPAGGRO, 0, 0.0f, true))
                targets.remove(target);

        uint32 minPlayers = 1;
        switch (GetCaster()->GetMap()->GetDifficulty())
        {
            case RAID_DIFFICULTY_10MAN_HEROIC: minPlayers = 2; break;
            case RAID_DIFFICULTY_25MAN_NORMAL: minPlayers = 3; break;
            case RAID_DIFFICULTY_25MAN_HEROIC: minPlayers = 6; break;
            default: break;
        }

        if (targets.size() > minPlayers)
            Trinity::Containers::RandomResize(targets, minPlayers);
    }

    void Register() override
    {
        if (m_scriptSpellId == SPELL_FADING_LIGHT_AOE_1 ||
            m_scriptSpellId == 110080 ||
            m_scriptSpellId == 110079 ||
            m_scriptSpellId == 110078)
            OnObjectAreaTargetSelect.Register(&spell_ultraxion_fading_light::FilterTargets, EFFECT_0, TARGET_UNIT_SRC_AREA_ENTRY);
    }

private:
    class DPSCheck
    {
    public:
        bool operator()(WorldObject* unit)
        {
            if (unit->GetTypeId() != TYPEID_PLAYER)
                return true;

            switch (unit->ToPlayer()->GetPrimaryTalentTree(unit->ToPlayer()->GetActiveSpec()))
            {
                case TALENT_TREE_WARRIOR_PROTECTION:
                case TALENT_TREE_PALADIN_HOLY:
                case TALENT_TREE_PALADIN_PROTECTION:
                case TALENT_TREE_PRIEST_DISCIPLINE:
                case TALENT_TREE_PRIEST_HOLY:
                case TALENT_TREE_DEATH_KNIGHT_BLOOD:
                case TALENT_TREE_SHAMAN_RESTORATION:
                case TALENT_TREE_DRUID_RESTORATION:
                    return true;
                default:
                    return false;
            }
        }
    };
};
struct spell_ultraxion_last_defender_of_azeroth : public SpellScript
{
    void FilterTargets(std::list<WorldObject*>& targets)
    {
        if (!GetCaster())
            return;

        targets.remove_if(TankCheck());
    }

    void Register() override
    {
        OnObjectAreaTargetSelect.Register(&spell_ultraxion_last_defender_of_azeroth::FilterTargets, EFFECT_0, TARGET_UNIT_SRC_AREA_ENTRY);
        OnObjectAreaTargetSelect.Register(&spell_ultraxion_last_defender_of_azeroth::FilterTargets, EFFECT_1, TARGET_UNIT_SRC_AREA_ENTRY);
    }

private:
    class TankCheck
    {
    public:
        TankCheck() { }

        bool operator()(WorldObject* unit)
        {
            if (unit->GetTypeId() != TYPEID_PLAYER)
                return true;

            switch (unit->ToPlayer()->GetPrimaryTalentTree(unit->ToPlayer()->GetActiveSpec()))
            {
                case TALENT_TREE_WARRIOR_PROTECTION:
                case TALENT_TREE_PALADIN_PROTECTION:
                case TALENT_TREE_DEATH_KNIGHT_BLOOD:
                    return false;
                case TALENT_TREE_DRUID_FERAL_COMBAT:
                    if (unit->ToPlayer()->HasAura(5487)) // Bear form
                        return false;
                    else
                        return true;
                default:
                    return true;
            }
        }
    };
};

struct spell_ultraxion_last_defender_of_azeroth_dummy : public SpellScript
{
    void HandleDummy(SpellEffIndex /*effIndex*/)
    {
        if (!GetCaster() || !GetHitUnit())
            return;

        if (GetHitUnit()->GetTypeId() != TYPEID_PLAYER)
            return;

        switch (GetHitUnit()->ToPlayer()->GetPrimaryTalentTree(GetHitUnit()->ToPlayer()->GetActiveSpec()))
        {
            case TALENT_TREE_WARRIOR_PROTECTION:
                GetHitUnit()->CastSpell(GetHitUnit(), SPELL_LAST_DEFENDER_OF_AZEROTH_WARRIOR, true);
                break;
            case TALENT_TREE_PALADIN_PROTECTION:
                GetHitUnit()->CastSpell(GetHitUnit(), SPELL_LAST_DEFENDER_OF_AZEROTH_PALADIN, true);
                break;
            case TALENT_TREE_DEATH_KNIGHT_BLOOD:
                GetHitUnit()->CastSpell(GetHitUnit(), SPELL_LAST_DEFENDER_OF_AZEROTH_DK, true);
                break;
            case TALENT_TREE_DRUID_FERAL_COMBAT:
                GetHitUnit()->CastSpell(GetHitUnit(), SPELL_LAST_DEFENDER_OF_AZEROTH_DRUID, true);
                break;
            default:
                break;
        }
    }

    void Register() override
    {
        OnEffectHitTarget.Register(&spell_ultraxion_last_defender_of_azeroth_dummy::HandleDummy, EFFECT_0, SPELL_EFFECT_DUMMY);
    }
};

struct spell_ultraxion_heroic_will : public AuraScript
{
    void OnRemove(AuraEffect const* /*aurEff*/, AuraEffectHandleModes /*mode*/)
    {
        if (GetTarget())
            if (InstanceScript* script = GetTarget()->GetInstanceScript())
                if (script->GetBossState(DATA_ULTRAXION) == IN_PROGRESS)
                    GetTarget()->CastSpell(GetTarget(), SPELL_FADED_INTO_TWILIGHT, true);
    }

    void Register() override
    {
        AfterEffectRemove.Register(&spell_ultraxion_heroic_will::OnRemove, EFFECT_0, SPELL_AURA_MOD_PACIFY_SILENCE, AURA_EFFECT_HANDLE_REAL);
    }
};

struct spell_ultraxion_time_loop : public AuraScript
{
    bool Load() override
    {
        return GetUnitOwner()->GetTypeId() == TYPEID_PLAYER;
    }

    void CalculateAmount(AuraEffect const* /*aurEff*/, int32& amount, bool& /*canBeRecalculated*/)
    {
        amount = -1;
    }

    void Absorb(AuraEffect* aurEff, DamageInfo& dmgInfo, uint32& absorbAmount)
    {
        Unit* victim = GetTarget();
        int32 remainingHealth = victim->GetHealth() - dmgInfo.GetDamage();

        if (remainingHealth <= 0)
        {
            absorbAmount = dmgInfo.GetDamage();
            CastSpellExtraArgs args(SPELLVALUE_BASE_POINT0, int32(victim->GetMaxHealth()));
            args.SetTriggerFlags(TRIGGERED_FULL_MASK);
            victim->CastSpell(victim, SPELL_TIMELOOP_HEAL, args);
            aurEff->GetBase()->Remove();
        }
        else
        {
            absorbAmount = 0;
        }
    }

    void Register() override
    {
        DoEffectCalcAmount.Register(&spell_ultraxion_time_loop::CalculateAmount, EFFECT_1, SPELL_AURA_SCHOOL_ABSORB);
        OnEffectAbsorb.Register(&spell_ultraxion_time_loop::Absorb, EFFECT_1);
    }
};

struct spell_ultraxion_achievement_aura : public AuraScript
{
    // 109188 reapply stack>1 = raider atingido pela Hour of Twilight 2x -> worldstate 6131 = 1 (falha)
    void HandleAuraEffectApply(AuraEffect const* /*aurEff*/, AuraEffectHandleModes /*mode*/)
    {
        if (GetStackAmount() > 1 && GetOwner() && GetOwner()->ToUnit())
            GetOwner()->ToUnit()->GetMap()->SetWorldStateValue(WORLDSTATE_MINUTES_TO_MIDNIGHT, 1, false);
    }

    void Register() override
    {
        OnEffectApply += AuraEffectApplyFn(&spell_ultraxion_achievement_aura::HandleAuraEffectApply, EFFECT_0, SPELL_AURA_PERIODIC_DUMMY, AURA_EFFECT_HANDLE_REAPPLY);
    }
};

} // namespace DragonSoul::Ultraxion

using namespace DragonSoul::Ultraxion;

void AddSC_boss_ultraxion()
{
    using namespace DragonSoul;
    RegisterDragonSoulCreatureAI(boss_ultraxion);
    RegisterSpellScript(spell_ultraxion_twilight_instability);
    RegisterSpellScript(spell_ultraxion_hour_of_twilight_dmg);
    RegisterSpellAndAuraScriptPair(spell_ultraxion_fading_light, spell_ultraxion_fading_light_aura);
    RegisterSpellScript(spell_ultraxion_last_defender_of_azeroth);
    RegisterSpellScript(spell_ultraxion_last_defender_of_azeroth_dummy);
    RegisterSpellScript(spell_ultraxion_heroic_will);
    RegisterSpellScript(spell_ultraxion_time_loop);
    RegisterSpellScript(spell_ultraxion_achievement_aura);
}