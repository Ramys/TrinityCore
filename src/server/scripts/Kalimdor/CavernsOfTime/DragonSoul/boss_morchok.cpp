/*
 * TrinityCore 4.3.4 - Dragon Soul: Morchok
 * Ref: cata.wowhead.com / wowpedia Morchok (Dragon Soul, 4.3.4).
 * Padrao: struct : public BossAI + RegisterDragonSoulCreatureAI.
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
#include <vector>
#include <algorithm>

namespace DragonSoul::Morchok
{

enum ScriptedTexts
{
    SAY_AGGRO   = 0,
    SAY_DEATH   = 1,
    SAY_GROUND1 = 6,
    SAY_GROUND2 = 7,
    SAY_CRYSTAL = 9,
    SAY_KILL    = 10,
    SAY_KOHCROM = 11,
    ANN_CRYSTAL = 12
};

enum Spells
{
    SPELL_BERSERK                   = 47008,
    SPELL_STOMP                     = 103414,
    SPELL_CRUSH_ARMOR               = 103687,
    SPELL_RESONATING_CRYSTAL        = 103640,
    SPELL_RESONATING_CRYSTAL_DMG    = 103494,
    SPELL_FURIOUS                   = 103846,
    SPELL_BLACK_BLOOD_OF_THE_EARTH  = 103785,
    SPELL_EARTHS_VENGEANCE          = 103548,
    SPELL_THE_EARTH_CONSUMES_YOU    = 103558,
    SPELL_SUMMON_KOHCROM            = 104161,
    SPELL_KOHCROM_VISUAL            = 103807,
    SPELL_EARTH_SHATTERING          = 103694,
    SPELL_STOMP_VULNERABILITY       = 0    // @TODO: +50% Physical dmg taken 10s (Heroic Stomp). Verificar Spell.dbc 4.3.4.
};

enum Events
{
    EVENT_STOMP                  = 1,
    EVENT_CRUSH_ARMOR,
    EVENT_RESONATING_CRYSTAL,
    EVENT_THE_EARTH_CONSUMES_YOU,
    EVENT_EARTHS_VENGEANCE,
    EVENT_BLACK_BLOOD,
    EVENT_BLACK_BLOOD_END,
    EVENT_BERSERK
};

enum Phases
{
    PHASE_NORMAL      = 1,
    PHASE_BLACK_BLOOD
};

enum MiscData
{
    DATA_GUID_1      = 1,
    DATA_GUID_2      = 2,
    ACTION_TWIN_LINK = 100,
    ACTION_CRYSTAL_EXPLODED = 101
};

enum MiscTimers
{
    TIMER_STOMP               = 25000,
    TIMER_CRUSH_ARMOR         = 10000,
    TIMER_RESONATING_CRYSTAL  = 12000,
    TIMER_BLACK_BLOOD         = 12000,
    TIMER_CONSUME             = 5000,
    TIMER_BERSERK             = 420000,
    CRYSTALS_BEFORE_BLOOD     = 2
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
        if (!_isHeroic) // Crush Armor: somente Normal (Heroico nao usa - ref PDF)
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

        if (_isHeroic && !_kohcromSummoned && me->HealthBelowPctDamaged(90, damage))
        {
            _kohcromSummoned = true;
            SummonKohcrom();
        }

        if (!me->HasAura(SPELL_FURIOUS) && me->HealthBelowPctDamaged(20, damage))
            DoCastSelf(SPELL_FURIOUS);

        if (_kohcrom && _kohcrom->IsAlive())
            _kohcrom->SetHealth(me->GetHealth());
    }

    void DoAction(int32 action) override
    {
        // Cristal Ressonante explodiu -> conta para o ciclo do Black Blood (ref PDF: apos 2 cristais).
        if (action == ACTION_CRYSTAL_EXPLODED && events.GetPhaseMask() == PHASE_NORMAL)
        {
            if (++_crystalCount >= CRYSTALS_BEFORE_BLOOD)
            {
                _crystalCount = 0;
                events.CancelEvent(EVENT_STOMP);
                events.CancelEvent(EVENT_CRUSH_ARMOR);
                events.CancelEvent(EVENT_RESONATING_CRYSTAL);
                events.SetPhase(PHASE_BLACK_BLOOD);
                events.ScheduleEvent(EVENT_THE_EARTH_CONSUMES_YOU, std::chrono::milliseconds(500));
            }
        }
    }

    void KilledUnit(Unit* victim) override
    {
        if (victim && victim->GetTypeId() == TYPEID_PLAYER)
            Talk(SAY_KILL);
    }

    void JustDied(Unit* /*killer*/) override
    {
        _JustDied();
        if (instance)
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
        if (instance)
            instance->SendEncounterUnit(ENCOUNTER_FRAME_DISENGAGE, me);
        _DespawnAtEvade();
        if (instance)
            instance->SetBossState(DATA_MORCHOK, FAIL);
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
                        DoCastAOE(SPELL_EARTH_SHATTERING);
                    else
                        DoCastAOE(SPELL_STOMP);
                    ++_stompCount;
                    events.ScheduleEvent(EVENT_STOMP, std::chrono::milliseconds(TIMER_STOMP), 0, PHASE_NORMAL);
                    break;

                case EVENT_CRUSH_ARMOR:
                    if (Unit* victim = me->GetVictim())
                        DoCast(victim, SPELL_CRUSH_ARMOR);
                    events.ScheduleEvent(EVENT_CRUSH_ARMOR, std::chrono::milliseconds(TIMER_CRUSH_ARMOR), 0, PHASE_NORMAL);
                    break;

                case EVENT_RESONATING_CRYSTAL:
                    if (Unit* target = SelectTarget(SELECT_TARGET_RANDOM, 0, 100.0f, true))
                        DoCast(target, SPELL_RESONATING_CRYSTAL);
                    Talk(SAY_CRYSTAL);
                    // Gatilho do Black Blood movido para a explosao do cristal (DoAction).
                    events.ScheduleEvent(EVENT_RESONATING_CRYSTAL, std::chrono::milliseconds(TIMER_RESONATING_CRYSTAL), 0, PHASE_NORMAL);
                    break;

                case EVENT_THE_EARTH_CONSUMES_YOU:
                    DoCastAOE(SPELL_THE_EARTH_CONSUMES_YOU);
                    events.ScheduleEvent(EVENT_EARTHS_VENGEANCE, std::chrono::milliseconds(TIMER_CONSUME));
                    break;

                case EVENT_EARTHS_VENGEANCE:
                    DoCastAOE(SPELL_EARTHS_VENGEANCE);
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
    npc_morchok_kohcrom(Creature* creature) : BossAI(creature, DATA_MORCHOK), _twin(nullptr)
    {
        me->ApplySpellImmune(0, IMMUNITY_EFFECT, SPELL_EFFECT_KNOCK_BACK, true);
        me->ApplySpellImmune(0, IMMUNITY_MECHANIC, MECHANIC_GRIP, true);
        me->ApplySpellImmune(0, IMMUNITY_STATE, SPELL_AURA_MOD_TAUNT, true);
    }

    Creature* _twin;

    void Reset() override
    {
        _Reset();
        _twin = nullptr;
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
        events.ScheduleEvent(EVENT_STOMP, std::chrono::seconds(12), 0, PHASE_NORMAL);
        events.ScheduleEvent(EVENT_RESONATING_CRYSTAL, std::chrono::seconds(18), 0, PHASE_NORMAL);
        // Kohcrom (Heroico) NAO usa Crush Armor (ref PDF).
    }

    void DamageTaken(Unit* /*attacker*/, uint32& damage) override
    {
        if (!me->IsAlive())
            return;

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
                    DoCastAOE(SPELL_STOMP);
                    events.ScheduleEvent(EVENT_STOMP, std::chrono::milliseconds(TIMER_STOMP), 0, PHASE_NORMAL);
                    break;

                // Kohcrom (Heroico) NAO usa Crush Armor (ref PDF).
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
    npc_morchok_resonating_crystal(Creature* creature) : ScriptedAI(creature), _exploded(false), _timer(12000)
    {
    }

    bool _exploded;
    uint32 _timer;
    ObjectGuid _target;

    void IsSummonedBy(Unit* /*summoner*/) override
    {
        if (Unit* target = SelectTarget(SELECT_TARGET_RANDOM, 0, 100.0f, true))
            _target = target->GetGUID();
    }

    void UpdateAI(uint32 diff) override
    {
        if (_exploded)
            return;

        _timer -= diff;
        if (_timer <= 0)
        {
            _exploded = true;
            DoCastAOE(SPELL_RESONATING_CRYSTAL_DMG);
            if (InstanceScript* inst = instance)
                if (Creature* boss = inst->GetCreature(DATA_MORCHOK))
                    if (boss->IsAlive())
                        boss->AI()->DoAction(ACTION_CRYSTAL_EXPLODED);
            me->DespawnOrUnsummon(2000);
            return;
        }

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
            if (InstanceScript* inst = instance)
                if (Creature* boss = inst->GetCreature(DATA_MORCHOK))
                    if (boss->IsAlive())
                        boss->AI()->DoAction(ACTION_CRYSTAL_EXPLODED);
            me->DespawnOrUnsummon(2000);
        }
    }
};

// Stomp: alvo atual e aliado mais proximo recebem dano dobrado.
class spell_morchok_stomp : public SpellScriptLoader
{
public:
    spell_morchok_stomp() : SpellScriptLoader("spell_morchok_stomp") { }

    class spell_morchok_stomp_SpellScript : public SpellScript
    {
        std::vector<ObjectGuid> _doubled;

        void FilterTargets(std::list<WorldObject*>& targets)
        {
            if (!GetCaster() || targets.empty())
                return;
            targets.sort(DistanceOrderPred(GetCaster()));
            uint8 count = 0;
            for (auto itr = targets.begin(); itr != targets.end() && count < 2; ++itr, ++count)
                _doubled.push_back((*itr)->GetGUID());
        }

        void CalculateDamage(Unit* victim, int32& damage, int32& /*flatMod*/, float& /*pctMod*/)
        {
            if (victim && std::find(_doubled.begin(), _doubled.end(), victim->GetGUID()) != _doubled.end())
                damage *= 2;
        }

        // Heroico: Stomp aumenta dano Fisico recebido em 50% por 10s (ref PDF).
        void HandleOnHit(SpellEffIndex /*effIndex*/)
        {
            if (GetCaster()->GetMap()->IsHeroic() && SPELL_STOMP_VULNERABILITY)
                if (Unit* hit = GetHitUnit())
                    GetCaster()->AddAura(SPELL_STOMP_VULNERABILITY, hit);
        }

        void Register() override
        {
            OnObjectAreaTargetSelect.Register(&spell_morchok_stomp_SpellScript::FilterTargets, EFFECT_0, TARGET_UNIT_DEST_AREA_ENEMY);
            CalcDamage.Register(&spell_morchok_stomp_SpellScript::CalculateDamage);
            OnEffectHitTarget.Register(&spell_morchok_stomp_SpellScript::HandleOnHit, EFFECT_0, SPELL_EFFECT_SCHOOL_DAMAGE);
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


// Black Blood of the Earth: raio de dano cresce a cada tick.
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

// Cristal Ressonante: dano dividido entre 3 (10m) ou 7 (25m) jogadores.
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

