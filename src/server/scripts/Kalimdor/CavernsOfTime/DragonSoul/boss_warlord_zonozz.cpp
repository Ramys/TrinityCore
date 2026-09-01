/*
 * TrinityCore 4.3.4 - Dragon Soul: Warlord Zon'ozz
 * Port MoP 5.4.8 725 -> Cata 4.3.4
 * Ref: wowhead cata 55308, EJ 4.3.4, Spell.dbc Cataclysm Preservation Project
 *
 * Encounter flow:
 *   1. Boss spams Focused Anger (+dmg stacks), Psychic Drain (frontal cone heal),
 *      Disrupting Shadows (DoT on players, explodes on dispel).
 *   2. Boss summons Void of the Unmaking every ~90s.
 *   3. Void bounces between players. Each bounce adds stack of Void Diffusion Buff (106836)
 *      on the orb: +20% dmg, +20% size per stack.
 *   4. If Void reaches outer edge: Black Blood Eruption (108799) = 119400-120600 AoE knockup.
 *   5. If Void returns to boss: Void Diffusion debuff (104031) applied = +5% dmg taken per
 *      bounce stack. Focused Anger removed. Boss enters Tantrum phase.
 *   6. Tantrum phase: Boss teleports to center, casts Darkness (109413, visual), Tantrum
 *      (103953, 10s channel). Normal: Black Blood of Go'rath (104378, 15210-15990/s 30s).
 *      Heroic: tentacles spawn (Eyes/Flails/Claws) each applying 104377 (3220/2s).
 *   7. After 30s blood phase ends, boss re-engages. Void respawns after delay.
 *   8. Heroic tentacle counts: 10H=4E/2F/1C, 25H=8E/4F/2C. Normal: Eyes only (non-attackable).
 *   9. Achievement Ping-Pong Champion (worldstate 10019): 9+ bounces in single void.
 */
#include "dragon_soul.h"
#include "ScriptedCreature.h"
#include "ScriptMgr.h"
#include "SpellScript.h"
#include "SpellAuraEffects.h"
#include "SpellInfo.h"
#include "CreatureTextMgr.h"
#include "MoveSplineInit.h"
#include "ObjectAccessor.h"
#include "TemporarySummon.h"
#include "Player.h"
#include "InstanceScript.h"
#include "Map.h"
#include "Containers.h"
#include <cmath>

namespace DragonSoul::Zonozz
{
enum Texts
{
    SAY_AGGRO   = 0, SAY_DEATH = 1, SAY_INTRO = 2, SAY_KILL  = 3,
    SAY_SHADOWS = 4, SAY_BLOOD = 5, SAY_VOID  = 6
};
enum Spells
{
    // Boss abilities
    SPELL_BERSERK                        = 26662,
    SPELL_FOCUSED_ANGER                  = 104543,
    SPELL_PSYCHIC_DRAIN                  = 104323,
    SPELL_PSYCHIC_DRAIN_DMG              = 104322,
    SPELL_DISRUPTING_SHADOWS             = 103434,
    SPELL_DISRUPTING_SHADOWS_DMG         = 103948,
    // Void of the Unmaking
    SPELL_VOID_OF_THE_UNMAKING_DMG       = 103521,
    SPELL_VOID_OF_THE_UNMAKING_VIS       = 109187,
    SPELL_VOID_OF_THE_UNMAKING_SUMMON    = 103571,
    SPELL_VOID_OF_THE_UNMAKING_PREV      = 103627,
    SPELL_VOID_OF_THE_UNMAKING_DUMMY     = 103946,
    // Void Diffusion
    SPELL_VOID_DIFFUSION_ORB_BUFF        = 106836,
    SPELL_VOID_DIFFUSION_DMG             = 103527,
    SPELL_VOID_DIFFUSION_DEBUFF          = 104031,
    // Black Blood / Tantrum phase
    SPELL_DARKNESS                       = 109413,
    SPELL_TANTRUM                        = 103953,
    SPELL_BLACK_BLOOD_OF_GORATH          = 104377,
    SPELL_BLACK_BLOOD_OF_GORATH_SELF     = 104378,
    SPELL_BLACK_BLOOD_ERUPTION           = 108799,
    SPELL_BLACK_BLOOD_ERUPTION_DMG       = 108794,
    SPELL_BLOOD_OF_GORATH_DUMMY          = 103932,
    // Tentacle abilities
    SPELL_EYE_OF_GORATH                  = 109190,
    SPELL_CLAW_OF_GORATH                 = 109191,
    SPELL_FLAIL_OF_GORATH                = 109193,
    SPELL_SLUDGE_SPEW                    = 110297,
    SPELL_WILD_FLAIL                     = 109199,
    SPELL_OOZE_SPIT                      = 109396,
    SPELL_SHADOW_GAZE                    = 104347,
    // Whispers
    SPELL_ZONOZZ_WHISPER_AGGRO           = 109874,
    SPELL_ZONOZZ_WHISPER_INTRO           = 109875,
    SPELL_ZONOZZ_WHISPER_DEATH           = 109876,
    SPELL_ZONOZZ_WHISPER_KILL            = 109877,
    SPELL_ZONOZZ_WHISPER_BLOOD           = 109878,
    SPELL_ZONOZZ_WHISPER_SHADOWS         = 109879,
    SPELL_ZONOZZ_WHISPER_VOID            = 109880,
    SPELL_VOID_IMMUNITY                  = 62371
};
enum Adds
{
    NPC_VOID_OF_THE_UNMAKING = 55334,
    NPC_EYE_OF_GORATH        = 55416,
    NPC_FLAIL_OF_GORATH      = 55417,
    NPC_CLAW_OF_GORATH       = 55418,
    NPC_ZONOZZ               = 55308
};
enum Events
{
    EVENT_BERSERK                = 1,
    EVENT_FOCUSED_ANGER          = 2,
    EVENT_PSYCHIC_DRAIN          = 3,
    EVENT_DISRUPTING_SHADOWS     = 4,
    EVENT_VOID_OF_THE_UNMAKING   = 5,
    EVENT_CHECK_DISTANCE         = 6,
    EVENT_CONTINUE               = 7,
    EVENT_UPDATE_AURA            = 8,
    EVENT_TANTRUM_1              = 9,
    EVENT_TANTRUM_2              = 10,
    EVENT_END_TANTRUM_1          = 11,
    EVENT_END_TANTRUM_2          = 12,
    EVENT_SLUDGE_SPEW            = 13,
    EVENT_WILD_FLAIL             = 14,
    EVENT_OOZE_SPIT              = 15,
    EVENT_SHADOW_GAZE            = 16
};
enum DataMisc
{
    DATA_ACHIEVE       = 2,
    DATA_PHASE_COUNT   = 3,
    DATA_VOID          = 4
};
enum WorldStates
{
    WORLDSTATE_PING_PONG_CHAMPION = 10019
};
const Position centerPos = { -1769.329956f, -1916.869995f, -226.28f, 0.0f };
const Position tentaclePos[14] =
{
    { -1702.57f, -1884.71f, -221.513f, 3.63f }, { -1801.84f, -1851.69f, -221.436f, 5.27f },
    { -1792.2f,  -1988.63f, -221.373f, 1.41f }, { -1834.55f, -1952.28f, -221.38f,  0.62f },
    { -1734.35f, -1983.18f, -221.445f, 2.14f }, { -1745.46f, -1847.31f, -221.437f, 4.43f },
    { -1839.37f, -1895.09f, -221.381f, 5.98f }, { -1696.95f, -1941.09f, -221.292f, 1.90f },
    { -1739.24f, -1885.62f, -226.28f, 4.44f },  { -1791.31f, -1885.34f, -226.06f, 4.94f },
    { -1801.41f, -1939.77f, -226.13f, 0.84f },  { -1759.51f, -1957.94f, -226.00f, 1.67f },
    { -1774.99f, -1937.95f, -226.35f, 1.30f },  { -1748.31f, -1901.34f, -226.17f, 3.87f }
};
const Position portalsPos = { -13629.0f, 12167.0f, 183.0f, 0.0f };

// =====================================================================
//  BOSS WARLORD ZONOZZ
// =====================================================================
struct boss_warlord_zonozz : public BossAI
{
    boss_warlord_zonozz(Creature* c) : BossAI(c, DATA_WARLORD_ZONOZZ), _phaseCount(0), _bIntro(false)
    {
        c->ApplySpellImmune(0, IMMUNITY_EFFECT, SPELL_EFFECT_KNOCK_BACK, true);
        c->ApplySpellImmune(0, IMMUNITY_MECHANIC, MECHANIC_GRIP, true);
        c->ApplySpellImmune(0, IMMUNITY_MECHANIC, MECHANIC_STUN, true);
        c->ApplySpellImmune(0, IMMUNITY_MECHANIC, MECHANIC_FEAR, true);
        c->ApplySpellImmune(0, IMMUNITY_MECHANIC, MECHANIC_ROOT, true);
        c->ApplySpellImmune(0, IMMUNITY_MECHANIC, MECHANIC_FREEZE, true);
        c->ApplySpellImmune(0, IMMUNITY_MECHANIC, MECHANIC_POLYMORPH, true);
        c->ApplySpellImmune(0, IMMUNITY_MECHANIC, MECHANIC_HORROR, true);
        c->ApplySpellImmune(0, IMMUNITY_MECHANIC, MECHANIC_SAPPED, true);
        c->ApplySpellImmune(0, IMMUNITY_MECHANIC, MECHANIC_CHARM, true);
        c->ApplySpellImmune(0, IMMUNITY_MECHANIC, MECHANIC_DISORIENTED, true);
        c->ApplySpellImmune(0, IMMUNITY_STATE, SPELL_AURA_MOD_CONFUSE, true);
        c->setActive(true);
    }

    bool _bIntro;
    uint32 _phaseCount;

    void Reset() override
    {
        _Reset();
        me->SetReactState(REACT_AGGRESSIVE);
        _phaseCount = 0;
        if (auto* m = me->GetMap())
            m->SetWorldState(WORLDSTATE_PING_PONG_CHAMPION, 0);
        if (instance)
        {
            auto const& pl = me->GetMap()->GetPlayers();
            for (auto const& r : pl)
                if (Player* p = r.GetSource())
                {
                    p->RemoveAurasDueToSpell(SPELL_BLACK_BLOOD_OF_GORATH);
                    p->RemoveAurasDueToSpell(SPELL_BLACK_BLOOD_OF_GORATH_SELF);
                }
        }
    }

    void MoveInLineOfSight(Unit* who) override
    {
        if (_bIntro)
            return;
        if (who->GetTypeId() != TYPEID_PLAYER)
            return;
        if (!me->IsWithinDistInMap(who, 100.0f, false))
            return;
        Talk(SAY_INTRO);
        DoCastAOE(SPELL_ZONOZZ_WHISPER_INTRO, true);
        _bIntro = true;
    }

    void JustEngagedWith(Unit*) override
    {
        if (instance && instance->GetBossState(DATA_MORCHOK) != DONE)
        {
            EnterEvadeMode();
            auto const& pl = me->GetMap()->GetPlayers();
            for (auto const& r : pl)
                if (Player* p = r.GetSource())
                    if (p->IsWithinDist(me, 150.0f))
                        p->NearTeleportTo(portalsPos.GetPositionX(), portalsPos.GetPositionY(),
                                          portalsPos.GetPositionZ(), portalsPos.GetOrientation());
            return;
        }

        BossAI::JustEngagedWith(nullptr);
        if (instance)
            instance->SendEncounterUnit(ENCOUNTER_FRAME_ENGAGE, me);
        if (auto* m = me->GetMap())
            m->SetWorldState(WORLDSTATE_PING_PONG_CHAMPION, 0);

        _phaseCount = 0;
        me->SetReactState(REACT_AGGRESSIVE);
        Talk(SAY_AGGRO);
        DoCastAOE(SPELL_ZONOZZ_WHISPER_AGGRO, true);

        events.ScheduleEvent(EVENT_BERSERK, 6min);
        events.ScheduleEvent(EVENT_FOCUSED_ANGER, 10s);
        events.ScheduleEvent(EVENT_PSYCHIC_DRAIN, 13s);
        events.ScheduleEvent(EVENT_DISRUPTING_SHADOWS, 25s);
        events.ScheduleEvent(EVENT_VOID_OF_THE_UNMAKING, 5s);

        if (instance)
            instance->SetBossState(DATA_WARLORD_ZONOZZ, IN_PROGRESS);

        auto const& pl = me->GetMap()->GetPlayers();
        for (auto const& r : pl)
            if (Player* p = r.GetSource())
            {
                p->RemoveAurasDueToSpell(SPELL_BLACK_BLOOD_OF_GORATH);
                p->RemoveAurasDueToSpell(SPELL_BLACK_BLOOD_OF_GORATH_SELF);
            }

        std::list<Creature*> trash;
        GetCreatureListWithEntryInGrid(trash, me, NPC_EYE_OF_GORATH, 150.0f);
        GetCreatureListWithEntryInGrid(trash, me, NPC_FLAIL_OF_GORATH, 150.0f);
        GetCreatureListWithEntryInGrid(trash, me, NPC_CLAW_OF_GORATH, 150.0f);
        for (Creature* t : trash)
            if (t && t->IsAlive())
                t->SetInCombatWithZone();
    }

    void JustDied(Unit*) override
    {
        _JustDied();
        Talk(SAY_DEATH);
        DoCastAOE(SPELL_ZONOZZ_WHISPER_DEATH, true);
        if (instance)
            instance->SendEncounterUnit(ENCOUNTER_FRAME_DISENGAGE, me);
        auto const& pl = me->GetMap()->GetPlayers();
        for (auto const& r : pl)
            if (Player* p = r.GetSource())
            {
                p->RemoveAurasDueToSpell(SPELL_BLACK_BLOOD_OF_GORATH);
                p->RemoveAurasDueToSpell(SPELL_BLACK_BLOOD_OF_GORATH_SELF);
            }
    }

    void EnterEvadeMode(EvadeReason why) override
    {
        BossAI::EnterEvadeMode(why);
        if (instance)
            instance->SendEncounterUnit(ENCOUNTER_FRAME_DISENGAGE, me);
        summons.DespawnAll();
        me->RemoveAurasDueToSpell(SPELL_VOID_OF_THE_UNMAKING_PREV);
        me->RemoveAurasDueToSpell(SPELL_VOID_DIFFUSION_DEBUFF);
        me->RemoveAurasDueToSpell(SPELL_FOCUSED_ANGER);
        me->RemoveAurasDueToSpell(SPELL_DARKNESS);
        auto const& pl = me->GetMap()->GetPlayers();
        for (auto const& r : pl)
            if (Player* p = r.GetSource())
                p->RemoveAurasDueToSpell(SPELL_BLACK_BLOOD_OF_GORATH);
    }

    void JustSummoned(Creature* s) override
    {
        BossAI::JustSummoned(s);
        switch (s->GetEntry())
        {
            case NPC_VOID_OF_THE_UNMAKING:
                s->SetOrientation(me->GetOrientation());
                break;
            case NPC_EYE_OF_GORATH:
                if (!me->GetMap()->IsHeroic())
                {
                    s->SetFlag(UNIT_FIELD_FLAGS, UNIT_FLAG_NON_ATTACKABLE | UNIT_FLAG_NOT_SELECTABLE);
                    s->SetReactState(REACT_PASSIVE);
                }
                [[fallthrough]];
            case NPC_CLAW_OF_GORATH:
            case NPC_FLAIL_OF_GORATH:
                if (me->GetMap()->IsHeroic())
                    DoCastAOE(SPELL_BLACK_BLOOD_OF_GORATH, true);
                break;
            default: break;
        }
    }

    void SummonedCreatureDies(Creature* s, Unit*) override
    {
        BossAI::SummonedCreatureDies(s, nullptr);
        if (s->GetEntry() == NPC_EYE_OF_GORATH || s->GetEntry() == NPC_CLAW_OF_GORATH || s->GetEntry() == NPC_FLAIL_OF_GORATH)
        {
            auto const& pl = me->GetMap()->GetPlayers();
            for (auto const& r : pl)
                if (Player* p = r.GetSource())
                    if (Aura* a = p->GetAura(SPELL_BLACK_BLOOD_OF_GORATH))
                    {
                        if (a->GetStackAmount() > 1) a->ModStackAmount(-1);
                        else p->RemoveAurasDueToSpell(SPELL_BLACK_BLOOD_OF_GORATH);
                    }
        }
    }

    void SetData(uint32 t, uint32 d) override
    {
        if (t == DATA_ACHIEVE)
        {
            if (auto* m = me->GetMap()) m->SetWorldState(WORLDSTATE_PING_PONG_CHAMPION, 1);
        }
        else if (t == DATA_VOID)
        {
            me->CastCustomSpell(SPELL_VOID_DIFFUSION_DEBUFF, SPELLVALUE_AURA_STACK, int32(d), me, true);
            if (me->GetMap()->IsHeroic()) DoCastSelf(SPELL_VOID_OF_THE_UNMAKING_PREV, true);
            me->RemoveAurasDueToSpell(SPELL_FOCUSED_ANGER);
            events.CancelEvent(EVENT_FOCUSED_ANGER);
            events.CancelEvent(EVENT_DISRUPTING_SHADOWS);
            events.CancelEvent(EVENT_PSYCHIC_DRAIN);
            events.CancelEvent(EVENT_VOID_OF_THE_UNMAKING);
            events.ScheduleEvent(EVENT_TANTRUM_1, 1500ms);
            _phaseCount++;
        }
    }

    uint32 GetData(uint32 t) const override { if (t == DATA_PHASE_COUNT) return _phaseCount; return 0; }
    void KilledUnit(Unit* v) override { if (v && v->GetTypeId() == TYPEID_PLAYER) Talk(SAY_KILL); }
    void UpdateAI(uint32 diff) override
    {
        if (!UpdateVictim()) return;
        if (me->GetDistance(me->GetHomePosition()) > 150.0f)
        { EnterEvadeMode(EvadeReason::EVADE_REASON_OTHER); return; }
        events.Update(diff);
        if (me->HasUnitState(UNIT_STATE_CASTING)) return;
        while (uint32 e = events.ExecuteEvent())
        {
            switch (e)
            {
                case EVENT_BERSERK: DoCastSelf(SPELL_BERSERK); break;
                case EVENT_FOCUSED_ANGER: DoCastSelf(SPELL_FOCUSED_ANGER); events.ScheduleEvent(EVENT_FOCUSED_ANGER, 6500ms); break;
                case EVENT_PSYCHIC_DRAIN: if (Unit* v = me->GetVictim()) DoCast(v, SPELL_PSYCHIC_DRAIN); events.ScheduleEvent(EVENT_PSYCHIC_DRAIN, 20s); break;
                case EVENT_DISRUPTING_SHADOWS: Talk(SAY_SHADOWS); DoCastAOE(SPELL_DISRUPTING_SHADOWS); DoCastAOE(SPELL_ZONOZZ_WHISPER_SHADOWS, true); events.ScheduleEvent(EVENT_DISRUPTING_SHADOWS, 25s); break;
                case EVENT_VOID_OF_THE_UNMAKING: summons.DespawnEntry(NPC_VOID_OF_THE_UNMAKING); Talk(SAY_VOID); DoCastSelf(SPELL_VOID_OF_THE_UNMAKING_SUMMON); DoCastAOE(SPELL_ZONOZZ_WHISPER_VOID, true); events.ScheduleEvent(EVENT_VOID_OF_THE_UNMAKING, 90s); break;
                case EVENT_TANTRUM_1: me->SetReactState(REACT_PASSIVE); me->AttackStop(); me->NearTeleportTo(centerPos.GetPositionX(), centerPos.GetPositionY(), centerPos.GetPositionZ(), centerPos.GetOrientation()); events.ScheduleEvent(EVENT_TANTRUM_2, 3s); break;
                case EVENT_TANTRUM_2:
                {
                    Talk(SAY_BLOOD); DoCastSelf(SPELL_DARKNESS, true);
                    if (!me->GetMap()->IsHeroic()) DoCastAOE(SPELL_BLACK_BLOOD_OF_GORATH_SELF, true);
                    DoCastSelf(SPELL_TANTRUM); DoCastAOE(SPELL_ZONOZZ_WHISPER_BLOOD, true);
                    if (me->GetMap()->IsHeroic()) { if (me->GetMap()->Is25ManRaid()) SpawnRandomTentacles(8, 4, 2); else SpawnRandomTentacles(4, 2, 1); }
                    else { if (me->GetMap()->Is25ManRaid()) SpawnRandomTentacles(8, 0, 0); else SpawnRandomTentacles(4, 0, 0); }
                    events.ScheduleEvent(EVENT_END_TANTRUM_1, 11s);
                    events.ScheduleEvent(EVENT_END_TANTRUM_2, 30s);
                    break;
                }
                case EVENT_END_TANTRUM_1: me->SetReactState(REACT_AGGRESSIVE); if (Unit* v = me->GetVictim()) AttackStart(v); else if (Unit* t = SelectTarget(SELECT_TARGET_RANDOM, 0)) AttackStart(t); break;
                case EVENT_END_TANTRUM_2:
                    if (!me->GetMap()->IsHeroic()) summons.DespawnEntry(NPC_EYE_OF_GORATH); else summons.DespawnAll();
                    me->RemoveAurasDueToSpell(SPELL_VOID_OF_THE_UNMAKING_PREV);
                    events.ScheduleEvent(EVENT_VOID_OF_THE_UNMAKING, 13s);
                    events.ScheduleEvent(EVENT_FOCUSED_ANGER, 6s);
                    events.ScheduleEvent(EVENT_DISRUPTING_SHADOWS, 6s);
                    events.ScheduleEvent(EVENT_PSYCHIC_DRAIN, 21s);
                    break;
                default: break;
            }
        }
        DoMeleeAttackIfReady();
    }
private:
    void SpawnRandomTentacles(uint32 maxEyes, uint32 maxFlails, uint32 maxClaws)
    {
        if (maxEyes > 8) maxEyes = 8; if (maxFlails > 4) maxFlails = 4; if (maxClaws > 2) maxClaws = 2;
        for (uint8 i = 0; i < maxEyes; ++i) me->SummonCreature(NPC_EYE_OF_GORATH, tentaclePos[i], TEMPSUMMON_CORPSE_TIMED_DESPAWN, 3000);
        for (uint8 i = 8; i < 8 + maxFlails; ++i) me->SummonCreature(NPC_FLAIL_OF_GORATH, tentaclePos[i], TEMPSUMMON_CORPSE_TIMED_DESPAWN, 3000);
        for (uint8 i = 12; i < 12 + maxClaws; ++i) me->SummonCreature(NPC_CLAW_OF_GORATH, tentaclePos[i], TEMPSUMMON_CORPSE_TIMED_DESPAWN, 3000);
    }
};

// =====================================================================
//  NPC: Void of the Unmaking (ping-pong orb)
// =====================================================================
struct npc_warlord_zonozz_void_of_the_unmaking : public ScriptedAI
{
    npc_warlord_zonozz_void_of_the_unmaking(Creature* c) : ScriptedAI(c), _bAura(false), _bExplode(false)
    {
        c->SetReactState(REACT_PASSIVE);
        c->SetCanFly(true);
        c->SetDisableGravity(true);
        c->ApplySpellImmune(0, IMMUNITY_EFFECT, SPELL_EFFECT_KNOCK_BACK, true);
        c->ApplySpellImmune(0, IMMUNITY_MECHANIC, MECHANIC_GRIP, true);
        SetCombatMovement(false);
    }
    EventMap _events;
    bool _bAura;
    bool _bExplode;
    void IsSummonedBy(Unit*) override
    {
        if (SPELL_VOID_IMMUNITY) me->CastSpell(me, SPELL_VOID_IMMUNITY, true);
        me->SetSpeed(MOVE_RUN, 0.6f, true);
        me->SetSpeed(MOVE_WALK, 0.6f, true);
        me->SetSpeed(MOVE_FLIGHT, 0.6f, true);
        _events.ScheduleEvent(EVENT_CHECK_DISTANCE, 5s);
        _events.ScheduleEvent(EVENT_CONTINUE, 5s);
    }
    void DamageTaken(Unit*, uint32& d) override { d = 0; }
    void UpdateAI(uint32 diff) override
    {
        if (_bExplode) return;
        if (!UpdateVictim()) { if (!me->IsInCombat()) return; }
        if (centerPos.GetExactDist2d(me->GetPositionX(), me->GetPositionY()) > 95.0f)
        {
            _bExplode = true; _events.Reset(); me->StopMoving();
            if (SPELL_BLACK_BLOOD_ERUPTION) DoCastAOE(SPELL_BLACK_BLOOD_ERUPTION);
            else if (SPELL_BLACK_BLOOD_ERUPTION_DMG) DoCastAOE(SPELL_BLACK_BLOOD_ERUPTION_DMG);
            me->DespawnOrUnsummon(5000);
            return;
        }
        _events.Update(diff);
        while (uint32 e = _events.ExecuteEvent())
        {
            switch (e)
            {
                case EVENT_CONTINUE:
                    if (SPELL_VOID_OF_THE_UNMAKING_VIS) DoCastSelf(SPELL_VOID_OF_THE_UNMAKING_VIS, true);
                    _bAura = true;
                    _MovePosition(200.0f, me->GetOrientation());
                    break;
                case EVENT_CHECK_DISTANCE:
                {
                    if (!_bAura) { _events.ScheduleEvent(EVENT_CHECK_DISTANCE, 500ms); break; }
                    if (Player* pl = me->FindNearestPlayer(5.0f))
                    {
                        if (Aura const* a = me->GetAura(SPELL_VOID_DIFFUSION_ORB_BUFF))
                            if (a->GetStackAmount() >= 9)
                                if (InstanceScript* inst = me->GetInstanceScript())
                                    if (Creature* z = ObjectAccessor::GetCreature(*me, inst->GetGuidData(DATA_WARLORD_ZONOZZ)))
                                        z->AI()->SetData(DATA_ACHIEVE, 1);
                        me->RemoveAurasDueToSpell(SPELL_VOID_OF_THE_UNMAKING_VIS); _bAura = false;
                        if (SPELL_VOID_DIFFUSION_DMG) DoCastAOE(SPELL_VOID_DIFFUSION_DMG);
                        // CORE FIX: add Void Diffusion Buff stack on each bounce (+20% dmg/size)
                        if (Aura* buff = me->GetAura(SPELL_VOID_DIFFUSION_ORB_BUFF))
                            buff->ModStackAmount(1);
                        else
                            DoCastSelf(SPELL_VOID_DIFFUSION_ORB_BUFF, true);
                        me->StopMoving();
                        float ang = me->GetAngle(pl->GetPositionX(), pl->GetPositionY());
                        if (me->NormalizeOrientation(me->GetOrientation() - ang) < (M_PI / 4.0f))
                            ang = me->GetOrientation();
                        _MovePosition(200.0f, ang + float(M_PI));
                        _events.ScheduleEvent(EVENT_UPDATE_AURA, 4s);
                        _events.ScheduleEvent(EVENT_CHECK_DISTANCE, 4s);
                    }
                    else if (Creature* z = me->FindNearestCreature(NPC_ZONOZZ, 5.0f))
                    {
                        uint8 st = 1;
                        if (Aura const* a = me->GetAura(SPELL_VOID_DIFFUSION_ORB_BUFF))
                            st = a->GetStackAmount();
                        z->AI()->SetData(DATA_VOID, st);
                        _events.Reset(); me->StopMoving(); me->DespawnOrUnsummon(2000);
                    }
                    else _events.ScheduleEvent(EVENT_CHECK_DISTANCE, 200ms);
                    break;
                }
                case EVENT_UPDATE_AURA:
                    if (SPELL_VOID_OF_THE_UNMAKING_VIS) DoCastSelf(SPELL_VOID_OF_THE_UNMAKING_VIS, true);
                    _bAura = true;
                    break;
                default: break;
            }
        }
    }
private:
    void _MovePosition(float dist, float angle)
    {
        angle = me->NormalizeOrientation(angle);
        float cur = 5.0f;
        Movement::MoveSplineInit init(me);
        bool done = false;
        while (!done)
        {
            float x = me->GetPositionX() + (cur * std::cos(angle));
            float y = me->GetPositionY() + (cur * std::sin(angle));
            float z = me->GetPositionZ();
            float cd = centerPos.GetExactDist2d(x, y);
            if (cd > 100.0f || cur > dist) done = true;
            else { G3D::Vector3 pt; pt.x = x; pt.y = y; if (cd > 40.0f) z = -225.0f + ((cd - 40.0f) * 0.1333f); else z = -225.0f; pt.z = z; init.Path().push_back(pt); cur += 5.0f; }
        }
        if (!init.Path().empty()) { init.SetWalk(false); init.Launch(); }
    }
};

// =====================================================================
//  NPC: Go'rath Tentacles (Eye / Flail / Claw)
// =====================================================================
struct npc_warlord_zonozz_tentacle : public ScriptedAI
{
    npc_warlord_zonozz_tentacle(Creature* c) : ScriptedAI(c)
    {
        c->ApplySpellImmune(0, IMMUNITY_EFFECT, SPELL_EFFECT_KNOCK_BACK, true);
        c->ApplySpellImmune(0, IMMUNITY_MECHANIC, MECHANIC_GRIP, true);
        c->ApplySpellImmune(0, IMMUNITY_MECHANIC, MECHANIC_STUN, true);
        c->ApplySpellImmune(0, IMMUNITY_MECHANIC, MECHANIC_FEAR, true);
        c->ApplySpellImmune(0, IMMUNITY_MECHANIC, MECHANIC_ROOT, true);
        c->ApplySpellImmune(0, IMMUNITY_MECHANIC, MECHANIC_FREEZE, true);
        c->ApplySpellImmune(0, IMMUNITY_MECHANIC, MECHANIC_POLYMORPH, true);
        c->ApplySpellImmune(0, IMMUNITY_MECHANIC, MECHANIC_HORROR, true);
        c->ApplySpellImmune(0, IMMUNITY_MECHANIC, MECHANIC_SAPPED, true);
        c->ApplySpellImmune(0, IMMUNITY_MECHANIC, MECHANIC_CHARM, true);
        c->ApplySpellImmune(0, IMMUNITY_MECHANIC, MECHANIC_DISORIENTED, true);
        SetCombatMovement(false);
    }
    EventMap _events;
    void Reset() override { _events.Reset(); }
    void JustEngagedWith(Unit*) override
    {
        switch (me->GetEntry())
        {
            case NPC_FLAIL_OF_GORATH: _events.ScheduleEvent(EVENT_SLUDGE_SPEW, 10s); _events.ScheduleEvent(EVENT_WILD_FLAIL, 15s); break;
            case NPC_CLAW_OF_GORATH: _events.ScheduleEvent(EVENT_OOZE_SPIT, 8s); break;
            case NPC_EYE_OF_GORATH: _events.ScheduleEvent(EVENT_SHADOW_GAZE, 3s); break;
            default: break;
        }
    }
    void UpdateAI(uint32 diff) override
    {
        if (!UpdateVictim()) return;
        _events.Update(diff);
        while (uint32 e = _events.ExecuteEvent())
        {
            switch (e)
            {
                case EVENT_SLUDGE_SPEW: if (Unit* t = SelectTarget(SELECT_TARGET_RANDOM, 0, 0.0f, true)) DoCast(t, SPELL_SLUDGE_SPEW); _events.ScheduleEvent(EVENT_SLUDGE_SPEW, 12s); break;
                case EVENT_WILD_FLAIL: DoCastAOE(SPELL_WILD_FLAIL); _events.ScheduleEvent(EVENT_WILD_FLAIL, 7s); break;
                case EVENT_OOZE_SPIT: if (!me->IsWithinMeleeRange(me->GetVictim())) if (Unit* t = SelectTarget(SELECT_TARGET_RANDOM, 0, 0.0f, true)) DoCast(t, SPELL_OOZE_SPIT); _events.ScheduleEvent(EVENT_OOZE_SPIT, 6s); break;
                case EVENT_SHADOW_GAZE: if (Unit* t = SelectTarget(SELECT_TARGET_RANDOM, 0, 0.0f, true, -int32(SPELL_SHADOW_GAZE))) DoCast(t, SPELL_SHADOW_GAZE); _events.ScheduleEvent(EVENT_SHADOW_GAZE, 8s); break;
                default: break;
            }
        }
        if (me->GetEntry() != NPC_EYE_OF_GORATH) DoMeleeAttackIfReady();
    }
};

// =====================================================================
//  SPELL: Disrupting Shadows - remove by enemy spell triggers explosion
// =====================================================================
struct spell_warlord_zonozz_disrupting_shadows : public AuraScript
{
    void OnRemove(AuraEffect const*, AuraEffectHandleModes)
    {
        if (GetTargetApplication()->GetRemoveMode().HasFlag(AuraRemoveFlags::ByEnemySpell))
            if (Unit* t = GetTarget()) t->CastSpell(t, SPELL_DISRUPTING_SHADOWS_DMG, true);
    }
    void Register() override { AfterEffectRemove.Register(&spell_warlord_zonozz_disrupting_shadows::OnRemove, EFFECT_0, SPELL_AURA_PERIODIC_DAMAGE, AURA_EFFECT_HANDLE_REAL); }
};

// =====================================================================
//  SPELL: Whisper - filter players only
// =====================================================================
struct spell_warlord_zonozz_whisper : public SpellScript
{
    void SelectTargets(std::list<WorldObject*>& targets) { targets.remove_if([](WorldObject* t) { return t->GetTypeId() != TYPEID_PLAYER; }); }
    void Register() override { OnObjectAreaTargetSelect.Register(&spell_warlord_zonozz_whisper::SelectTargets, EFFECT_0, TARGET_UNIT_SRC_AREA_ENEMY); }
};

} // namespace DragonSoul::Zonozz

using namespace DragonSoul::Zonozz;

void AddSC_boss_warlord_zonozz()
{
    using namespace DragonSoul;
    RegisterDragonSoulCreatureAI(boss_warlord_zonozz);
    RegisterCreatureAI(npc_warlord_zonozz_void_of_the_unmaking);
    RegisterCreatureAI(npc_warlord_zonozz_tentacle);
    RegisterSpellScript(spell_warlord_zonozz_disrupting_shadows);
    RegisterSpellScript(spell_warlord_zonozz_whisper);
}
