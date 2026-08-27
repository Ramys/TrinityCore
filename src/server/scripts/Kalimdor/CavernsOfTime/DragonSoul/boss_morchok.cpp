/*
 * TrinityCore 4.3.4 - Dragon Soul: Morchok
 * Ref: wowpedia Morchok, DOCX Morchok_Boss_Reference, adaptado de Legends-of-Azeroth (5.4.8).
 * Padrao do projeto: struct : public BossAI + RegisterDragonSoulCreatureAI.
 *
 * @TODO (verificar Spell.dbc 4.3.4 / creature_text):
 *  - Entries NPC_KOHCROM (55274) e NPC_RESONATING_CRYSTAL (55269) no creature_template.
 *  - IDs marcados @TODO em enum Spells.
 *  - Entradas de texto (SAY_*) em creature_text para NPC 55265.
 *  - ScriptName das adds no creature_template:
 *      NPC_KOHCROM        -> npc_morchok_kohcrom
 *      NPC_RESONATING_CRYSTAL -> npc_morchok_resonating_crystal
 */

#include "dragon_soul.h"
#include "ScriptedCreature.h"
#include "ScriptMgr.h"
#include "SpellScript.h"
#include "SpellAuraEffects.h"
#include "SpellInfo.h"
#include "GameObject.h"
#include "Player.h"
#include "InstanceScript.h"
#include "ObjectAccessor.h"
#include "TemporarySummon.h"
#include <cmath>
#include <list>

namespace DragonSoul::Morchok
{
enum ScriptedTexts
{
    SAY_AGGRO     = 0,
    SAY_DEATH     = 1,
    SAY_GROUND1   = 6,
    SAY_GROUND2   = 7,
    SAY_CRYSTAL   = 9,
    SAY_KILL      = 10,
    SAY_KOHCROM   = 11,
    ANN_CRYSTAL   = 12,
};

enum Spells
{
    SPELL_BERSERK                           = 47008,
    SPELL_STOMP                             = 103414,
    SPELL_CRUSH_ARMOR                       = 103687,
    SPELL_RESONATING_CRYSTAL                = 103640,
    SPELL_RESONATING_CRYSTAL_SUMMON         = 103641, // @TODO (5.4.8 usa 103639)
    SPELL_RESONATING_CRYSTAL_DMG            = 103494, // @TODO explosao AoE
    SPELL_FURIOUS                           = 103846,
    SPELL_BLACK_BLOOD_OF_THE_EARTH          = 103785,
    SPELL_EARTHS_VENGEANCE                  = 103548, // @TODO Heroico: pilares de abrigo
    SPELL_THE_EARTH_CONSUMES_YOU            = 103558, // @TODO Heroico: puxa + 5%HP/s
    SPELL_SUMMON_KOHCROM                    = 104161, // @TODO Heroico: invoca gemeo
    SPELL_KOHCROM_VISUAL                    = 103807, // @TODO visual da separacao
    SPELL_EARTH_SHATTERING                  = 103694, // @TODO Heroico: Stomp em toda a raid
};

enum Events
{
    EVENT_STOMP                 = 1,
    EVENT_CRUSH_ARMOR,
    EVENT_RESONATING_CRYSTAL,
    EVENT_THE_EARTH_CONSUMES_YOU,
    EVENT_EARTHS_VENGEANCE,
    EVENT_BLACK_BLOOD,
    EVENT_BLACK_BLOOD_END,
    EVENT_BERSERK,
};

enum Phases
{
    PHASE_NORMAL      = 1,
    PHASE_BLACK_BLOOD,
};

enum MiscData
{
    DATA_GUID_1   = 1,
    DATA_GUID_2   = 2,
    ACTION_TWIN_LINK = 100,
};

enum MiscTimers
{
    TIMER_STOMP              = 25000,
    TIMER_CRUSH_ARMOR        = 10000,
    TIMER_RESONATING_CRYSTAL = 12000,
    TIMER_BLACK_BLOOD        = 12000,
    TIMER_CONSUME            = 5000,
    TIMER_BERSERK            = 420000, // 7 min
    CRYSTALS_BEFORE_BLOOD    = 2,
};
struct boss_morchok : public BossAI
{
    boss_morchok(Creature* creature) : BossAI(creature, DATA_MORCHOK), _kohcrom(nullptr), _stompCount(0), _crystalCount(0), _kohcromSummoned(false)
    {
        me->ApplySpellImmune(0, IMMUNITY_EFFECT, SPELL_EFFECT_KNOCK_BACK, true);
        me->ApplySpellImmune(0, IMMUNITY_MECHANIC, MECHANIC_GRIP, true);
        me->ApplySpellImmune(0, IMMUNITY_STATE, SPELL_AURA_MOD_TAUNT, true);
        _isHeroic = me->GetMap()->IsHeroic();
    }

    bool _isHeroic;
    bool _kohcromSummoned;
    uint8 _stompCount;
    uint8 _crystalCount;
    Creature* _kohcrom;

    void Reset() override
    {
        _Reset();
        _kohcrom = nullptr;
        _kohcromSummoned = false;
        _stompCount = 0;
        _crystalCount = 0;
        _isHeroic = me->GetMap()->IsHeroic();
        if (instance)
            instance->SetBossState(DATA_MORCHOK, NOT_STARTED);
    }

    void JustEngagedWith(Unit* who) override
    {
        BossAI::JustEngagedWith(who);
        Talk(SAY_AGGRO);
        events.SetPhase(PHASE_NORMAL);
        events.ScheduleEvent(EVENT_STOMP, std::chrono::seconds(8), 0, PHASE_NORMAL);
        if (!_isHeroic)
            events.ScheduleEvent(EVENT_CRUSH_ARMOR, std::chrono::seconds(5), 0, PHASE_NORMAL);
        events.ScheduleEvent(EVENT_RESONATING_CRYSTAL, std::chrono::seconds(14), 0, PHASE_NORMAL);
        events.ScheduleEvent(EVENT_BERSERK, std::chrono::milliseconds(TIMER_BERSERK));
        if (instance)
            instance->SetBossState(DATA_MORCHOK, IN_PROGRESS);
    }

    void SummonKohcrom()
    {
        Talk(SAY_KOHCROM);
        Position pos = me->GetPosition();
        float dx = 6.0f * std::cos(me->GetOrientation());
        float dy = 6.0f * std::sin(me->GetOrientation());
        pos.m_positionX += dx;
        pos.m_positionY += dy;
        if (TempSummon* k = me->SummonCreature(NPC_KOHCROM, pos, TEMPSUMMON_CORPSE_TIMED_DESPAWN, 30000))
        {
            _kohcrom = k;
            k->SetHealth(me->GetHealth());
            k->AI()->DoAction(ACTION_TWIN_LINK);
            if (Unit* victim = me->GetVictim())
                k->EngageWithTarget(victim);
        }
    }

    void DamageTaken(Unit* /*attacker*/, uint32& damage) override
    {
        if (!me->IsAlive())
            return;

        // Heroico: invoca Kohcrom aos 90% de vida.
        if (_isHeroic && !_kohcromSummoned && me->HealthBelowPctDamaged(90, damage))
        {
            _kohcromSummoned = true;
            SummonKohcrom();
        }

        // Furious aos 20%.
        if (!me->HasAura(SPELL_FURIOUS) && me->HealthBelowPctDamaged(20, damage))
            DoCastSelf(SPELL_FURIOUS);

        // Heroico: vida compartilhada (Morchok eh a barra real).
        if (_kohcrom && _kohcrom->IsAlive())
            _kohcrom->SetHealth(me->GetHealth());
    }

    void JustDied(Unit* /*killer*/) override
    {
        _JustDied();
        instance->SendEncounterUnit(ENCOUNTER_FRAME_DISENGAGE, me);
        Talk(SAY_DEATH);
        if (_kohcrom && _kohcrom->IsAlive())
            Unit::Kill(me, _kohcrom, false);
        if (instance)
            instance->SetBossState(DATA_MORCHOK, DONE);
    }

    void EnterEvadeMode(EvadeReason why) override
    {
        BossAI::EnterEvadeMode(why);
        instance->SendEncounterUnit(ENCOUNTER_FRAME_DISENGAGE, me);
        _DespawnAtEvade();
        if (instance)
            instance->SetBossState(DATA_MORCHOK, FAIL);
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
            switch (eventId)
            {
                case EVENT_STOMP:
                    if (_isHeroic && _stompCount % 3 == 2)
                        DoCastAOE(SPELL_EARTH_SHATTERING); // @TODO Heroico: todo o raid
                    else
                        DoCastVictim(SPELL_STOMP);
                    ++_stompCount;
                    events.ScheduleEvent(EVENT_STOMP, std::chrono::milliseconds(TIMER_STOMP), 0, PHASE_NORMAL);
                    break;

                case EVENT_CRUSH_ARMOR:
                    if (Unit* target = SelectTarget(SELECT_TARGET_MINDISTANCE, 0, 0.0f, true))
                        DoCast(target, SPELL_CRUSH_ARMOR);
                    events.ScheduleEvent(EVENT_CRUSH_ARMOR, std::chrono::milliseconds(TIMER_CRUSH_ARMOR), 0, PHASE_NORMAL);
                    break;

                case EVENT_RESONATING_CRYSTAL:
                    if (Unit* target = SelectTarget(SELECT_TARGET_RANDOM, 0, 100.0f, true))
                        DoCast(target, SPELL_RESONATING_CRYSTAL);
                    if (++_crystalCount >= CRYSTALS_BEFORE_BLOOD)
                    {
                        _crystalCount = 0;
                        events.CancelEvent(EVENT_STOMP);
                        if (!_isHeroic)
                            events.CancelEvent(EVENT_CRUSH_ARMOR);
                        events.CancelEvent(EVENT_RESONATING_CRYSTAL);
                        events.SetPhase(PHASE_BLACK_BLOOD);
                        events.ScheduleEvent(EVENT_THE_EARTH_CONSUMES_YOU, std::chrono::milliseconds(500));
                    }
                    else
                    {
                        events.ScheduleEvent(EVENT_RESONATING_CRYSTAL, std::chrono::milliseconds(TIMER_RESONATING_CRYSTAL), 0, PHASE_NORMAL);
                    }
                    break;

                case EVENT_THE_EARTH_CONSUMES_YOU:
                    DoCastAOE(SPELL_THE_EARTH_CONSUMES_YOU); // @TODO Heroico
                    events.ScheduleEvent(EVENT_EARTHS_VENGEANCE, std::chrono::milliseconds(TIMER_CONSUME));
                    break;

                case EVENT_EARTHS_VENGEANCE:
                    DoCastAOE(SPELL_EARTHS_VENGEANCE); // @TODO Heroico: pilares
                    events.ScheduleEvent(EVENT_BLACK_BLOOD, std::chrono::seconds(2));
                    break;

                case EVENT_BLACK_BLOOD:
                    DoCastSelf(SPELL_BLACK_BLOOD_OF_THE_EARTH);
                    events.ScheduleEvent(EVENT_BLACK_BLOOD_END, std::chrono::milliseconds(TIMER_BLACK_BLOOD));
                    break;

                case EVENT_BLACK_BLOOD_END:
                    events.SetPhase(PHASE_NORMAL);
                    events.ScheduleEvent(EVENT_STOMP, std::chrono::seconds(1), 0, PHASE_NORMAL);
                    events.ScheduleEvent(EVENT_RESONATING_CRYSTAL, std::chrono::milliseconds(TIMER_RESONATING_CRYSTAL), 0, PHASE_NORMAL);
                    if (!_isHeroic)
                        events.ScheduleEvent(EVENT_CRUSH_ARMOR, std::chrono::milliseconds(TIMER_CRUSH_ARMOR), 0, PHASE_NORMAL);
                    break;

                case EVENT_BERSERK:
                    DoCastSelf(SPELL_BERSERK);
                    break;
            }
        }

        DoMeleeAttackIfReady();
    }
};
struct npc_morchok_kohcrom : public BossAI
{
    npc_morchok_kohcrom(Creature* creature) : BossAI(creature, DATA_MORCHOK), _stompCount(0), _twin(nullptr)
    {
        me->ApplySpellImmune(0, IMMUNITY_EFFECT, SPELL_EFFECT_KNOCK_BACK, true);
        me->ApplySpellImmune(0, IMMUNITY_MECHANIC, MECHANIC_GRIP, true);
        me->ApplySpellImmune(0, IMMUNITY_STATE, SPELL_AURA_MOD_TAUNT, true);
    }

    uint8 _stompCount;
    Creature* _twin; // Morchok (barra de vida real)

    void Reset() override
    {
        _Reset();
        _twin = nullptr;
        _stompCount = 0;
    }

    void DoAction(int32 action) override
    {
        if (action == ACTION_TWIN_LINK && instance)
            _twin = instance->GetCreature(DATA_MORCHOK);
    }

    void JustEngagedWith(Unit* who) override
    {
        BossAI::JustEngagedWith(who);
        events.SetPhase(PHASE_NORMAL);
        events.ScheduleEvent(EVENT_STOMP, std::chrono::seconds(8), 0, PHASE_NORMAL);
        events.ScheduleEvent(EVENT_RESONATING_CRYSTAL, std::chrono::seconds(14), 0, PHASE_NORMAL);
    }

    void DamageTaken(Unit* /*attacker*/, uint32& damage) override
    {
        if (!me->IsAlive())
            return;

        // Vida compartilhada: dano ao gemeo reduz a barra real (Morchok).
        if (_twin && _twin->IsAlive())
        {
            _twin->SetHealth(_twin->GetHealth() - damage);
            me->SetHealth(_twin->GetHealth());
        }

        if (!me->HasAura(SPELL_FURIOUS) && me->HealthBelowPctDamaged(20, damage))
            DoCastSelf(SPELL_FURIOUS);
    }

    void JustDied(Unit* /*killer*/) override
    {
        _JustDied();
        if (_twin && _twin->IsAlive())
            Unit::Kill(me, _twin, false);
    }

    void EnterEvadeMode(EvadeReason why) override
    {
        BossAI::EnterEvadeMode(why);
        if (_twin && _twin->IsAlive())
            _twin->AI()->EnterEvadeMode(why);
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
            switch (eventId)
            {
                case EVENT_STOMP:
                    if (_stompCount % 3 == 2)
                        DoCastAOE(SPELL_EARTH_SHATTERING); // @TODO Heroico: todo o raid
                    else
                        DoCastVictim(SPELL_STOMP);
                    ++_stompCount;
                    events.ScheduleEvent(EVENT_STOMP, std::chrono::milliseconds(TIMER_STOMP), 0, PHASE_NORMAL);
                    break;

                case EVENT_RESONATING_CRYSTAL:
                    if (Unit* target = SelectTarget(SELECT_TARGET_RANDOM, 0, 100.0f, true))
                        DoCast(target, SPELL_RESONATING_CRYSTAL);
                    events.ScheduleEvent(EVENT_RESONATING_CRYSTAL, std::chrono::milliseconds(TIMER_RESONATING_CRYSTAL), 0, PHASE_NORMAL);
                    break;
            }
        }

        DoMeleeAttackIfReady();
    }
};

struct npc_morchok_resonating_crystal : public ScriptedAI
{
    npc_morchok_resonating_crystal(Creature* creature) : ScriptedAI(creature), _exploded(false) { }

    bool _exploded;
    ObjectGuid _target;

    void IsSummonedBy(Unit* /*summoner*/) override
    {
        if (Unit* target = SelectTarget(SELECT_TARGET_RANDOM, 0, 100.0f, true))
            _target = target->GetGUID();
    }

    void UpdateAI(uint32 /*diff*/) override
    {
        if (_exploded)
            return;

        Unit* target = ObjectAccessor::GetUnit(*me, _target);
        if (!target)
        {
            if (Unit* t = SelectTarget(SELECT_TARGET_RANDOM, 0, 100.0f, true))
                _target = t->GetGUID();
            else
            {
                _exploded = true;
                me->DespawnOrUnsummon();
                return;
            }
            target = ObjectAccessor::GetUnit(*me, _target);
            if (!target)
                return;
        }

        if (me->GetDistance(target) > 3.0f)
            me->GetMotionMaster()->MovePoint(0, target->GetPositionX(), target->GetPositionY(), target->GetPositionZ());
        else
        {
            _exploded = true;
            DoCastAOE(SPELL_RESONATING_CRYSTAL_DMG);
            me->DespawnOrUnsummon(2000);
        }
    }
};
// Stomp: registra os 2 jogadores mais proximos (levam dano dobrado).
class spell_morchok_stomp : public SpellScriptLoader
{
public:
    spell_morchok_stomp() : SpellScriptLoader("spell_morchok_stomp") { }

    class spell_morchok_stomp_SpellScript : public SpellScript
    {


        void FilterTargets(std::list<WorldObject*>& targets)
        {
            if (!GetCaster() || targets.empty())
                return;
            if (Creature* mor = GetCaster()->ToCreature())
            {
                targets.sort(DistanceOrderPred(GetCaster()));
                auto itr = targets.begin();
                mor->AI()->SetGUID((*itr)->GetGUID(), DATA_GUID_1);
                if (targets.size() > 1)
                {
                    ++itr;
                    mor->AI()->SetGUID((*itr)->GetGUID(), DATA_GUID_2);
                }
            }
        }

        void Register() override
        {
            OnObjectAreaTargetSelect.Register(&spell_morchok_stomp_SpellScript::FilterTargets, EFFECT_0, TARGET_UNIT_DEST_AREA_ENEMY);
        }

    private:
        class DistanceOrderPred
        {
        public:
            DistanceOrderPred(WorldObject* searcher) : _searcher(searcher) { }
            bool operator()(WorldObject* a, WorldObject* b) const
            {
                return _searcher->GetExactDist(a) < _searcher->GetExactDist(b);
            }
        private:
            WorldObject* _searcher;
        };
    };

    SpellScript* GetSpellScript() const override { return new spell_morchok_stomp_SpellScript(); }
};

// Black Blood of the Earth: raio de dano cresce a cada tick (jogadores distantes sao poupados).
class spell_morchok_black_blood_of_the_earth_dmg : public SpellScriptLoader
{
public:
    spell_morchok_black_blood_of_the_earth_dmg() : SpellScriptLoader("spell_morchok_black_blood_of_the_earth_dmg") { }

    class spell_morchok_black_blood_of_the_earth_dmg_SpellScript : public SpellScript
    {


        void FilterTargets(std::list<WorldObject*>& targets)
        {
            if (!GetCaster() || targets.empty())
                return;
            if (AuraEffect const* aurEff = GetCaster()->GetAuraEffect(SPELL_BLACK_BLOOD_OF_THE_EARTH, EFFECT_0))
            {
                uint32 ticks = aurEff->GetTickNumber() + 1;
                targets.remove_if(DistanceCheck(GetCaster(), float(ticks * 4)));
            }
        }

        void Register() override
        {
            OnObjectAreaTargetSelect.Register(&spell_morchok_black_blood_of_the_earth_dmg_SpellScript::FilterTargets, EFFECT_0, TARGET_UNIT_DEST_AREA_ENEMY);
            OnObjectAreaTargetSelect.Register(&spell_morchok_black_blood_of_the_earth_dmg_SpellScript::FilterTargets, EFFECT_1, TARGET_UNIT_DEST_AREA_ENEMY);
        }

    private:
        class DistanceCheck
        {
        public:
            DistanceCheck(Unit* searcher, float distance) : _searcher(searcher), _distance(distance) { }
            bool operator()(WorldObject* unit) const { return _searcher->GetDistance2d(unit) > _distance; }
        private:
            Unit* _searcher;
            float _distance;
        };
    };

    SpellScript* GetSpellScript() const override { return new spell_morchok_black_blood_of_the_earth_dmg_SpellScript(); }
};

// Cristal Ressonante: dano dividido entre os jogadores mais proximos (3 em 10m, 7 em 25m).
class spell_morchok_resonating_crystal_dmg : public SpellScriptLoader
{
public:
    spell_morchok_resonating_crystal_dmg() : SpellScriptLoader("spell_morchok_resonating_crystal_dmg") { }

    class spell_morchok_resonating_crystal_dmg_SpellScript : public SpellScript
    {


        void FilterTargets(std::list<WorldObject*>& targets)
        {
            if (!GetCaster() || targets.empty())
                return;
            uint32 maxTargets = GetCaster()->GetMap()->Is25ManRaid() ? 7 : 3;
            targets.sort(DistanceOrderPred(GetCaster()));
            if (targets.size() > maxTargets)
                targets.resize(maxTargets);
        }

        void Register() override
        {
            OnObjectAreaTargetSelect.Register(&spell_morchok_resonating_crystal_dmg_SpellScript::FilterTargets, EFFECT_0, TARGET_UNIT_DEST_AREA_ENEMY);
        }

    private:
        class DistanceOrderPred
        {
        public:
            DistanceOrderPred(WorldObject* searcher) : _searcher(searcher) { }
            bool operator()(WorldObject* a, WorldObject* b) const
            {
                return _searcher->GetExactDist(a) < _searcher->GetExactDist(b);
            }
        private:
            WorldObject* _searcher;
        };
    };

    SpellScript* GetSpellScript() const override { return new spell_morchok_resonating_crystal_dmg_SpellScript(); }
};
} // namespace DragonSoul::Morchok

void AddSC_boss_morchok()
{
    using namespace DragonSoul;
    using namespace DragonSoul::Morchok;
    RegisterDragonSoulCreatureAI(boss_morchok);
    RegisterDragonSoulCreatureAI(npc_morchok_kohcrom);
    RegisterCreatureAI(npc_morchok_resonating_crystal);
    RegisterSpellScript(spell_morchok_stomp);
    RegisterSpellScript(spell_morchok_black_blood_of_the_earth_dmg);
    RegisterSpellScript(spell_morchok_resonating_crystal_dmg);
}
