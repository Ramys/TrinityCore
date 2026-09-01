/*
 * TrinityCore 4.3.4 - Dragon Soul: Morchok
 * Port MoP 5.4.8 (Legends-of-Azeroth) -> Cata 4.3.4
 * Ref: wowhead cata 55265 Morchok, EJ 4.3.4, Spell.dbc Cataclysm Preservation Project
 * Padrao: struct : public BossAI + RegisterDragonSoulCreatureAI, SpellScript sem PrepareSpellScript
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
#include "Map.h"
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
    SAY_GROUND1 = 6, // "The earth consumes you!" / Falling Fragments
    SAY_GROUND2 = 7, // "Feel the fury of the earth!" / Black Blood of the Earth
    SAY_CRYSTAL = 9, // "Flee, and die." / "Run, and perish."
    SAY_KILL    = 10,
    SAY_KOHCROM = 11, // "Kohcrom, crush them!"
    ANN_CRYSTAL = 12  // "%s summons a Resonating Crystal!"
};

enum Spells
{
    SPELL_BERSERK                   = 47008,
    SPELL_STOMP                     = 103414, // 1.5s cast, AoE 25y, double closest 2, +100% phys taken
    SPELL_CRUSH_ARMOR               = 103687, // -10% armor 20s stack 10
    SPELL_RESONATING_CRYSTAL        = 103640, // summon crystal
    SPELL_RESONATING_CRYSTAL_SUMMON = 103639, // trigger missile
    SPELL_RESONATING_CRYSTAL_DMG    = 103494, // explosion split 3/7
    SPELL_FURIOUS                   = 103846, // +20% dmg & +20% atk speed at 20% HP
    SPELL_EARTHEN_VORTEX            = 103821, // Pulls all players to boss & slows 50%
    SPELL_FALLING_FRAGMENTS         = 103176, // Channeled 5s, creates stone pillars for LoS
    SPELL_BLACK_BLOOD_OF_THE_EARTH  = 103785, // 5k Nature + 100% taken stack 6s
    SPELL_SUMMON_KOHCROM            = 109017, // Summon Kohcrom
    SPELL_MORCHOK_JUMP              = 109070  // Visual jump at 90%
};

enum Events
{
    EVENT_STOMP                  = 1,
    EVENT_CRUSH_ARMOR            = 2,
    EVENT_RESONATING_CRYSTAL     = 3,
    EVENT_EARTHEN_VORTEX         = 4,
    EVENT_BLACK_BLOOD            = 5,
    EVENT_BLACK_BLOOD_END        = 6,
    EVENT_BERSERK                = 7,
    EVENT_CONTINUE               = 8,
    EVENT_PHASE_FALLBACK         = 9
};

enum Phases
{
    PHASE_NORMAL      = 1,
    PHASE_BLACK_BLOOD = 2
};

enum Actions
{
    ACTION_CRYSTAL_EXPLODED    = 1,
    ACTION_KOHCROM_STOMP       = 2,
    ACTION_KOHCROM_CRYSTAL     = 3,
    ACTION_KOHCROM_VORTEX      = 4,
    ACTION_KOHCROM_BLACK_BLOOD = 5,
    ACTION_TWIN_LINK           = 6
};

enum DataMisc
{
    DATA_GUID_1           = 1,
    DATA_GUID_2           = 2,
    DATA_ALLOW_ACHIEV     = 3,
    DATA_KOHCROM_DONE     = 4
};

enum WorldStates
{
    WORLDSTATE_DONT_STAND_SO_CLOSE = 10003
};

struct boss_morchok : public BossAI
{
    boss_morchok(Creature* creature) : BossAI(creature, DATA_MORCHOK),
        _kohcrom(nullptr),
        _stompCount(0),
        _crystalCount(0),
        _kohcromSummoned(false),
        _isHeroic(false)
    {
        me->ApplySpellImmune(0, IMMUNITY_EFFECT, SPELL_EFFECT_KNOCK_BACK, true);
        me->ApplySpellImmune(0, IMMUNITY_MECHANIC, MECHANIC_GRIP, true);
        me->ApplySpellImmune(0, IMMUNITY_MECHANIC, MECHANIC_STUN, true);
        me->ApplySpellImmune(0, IMMUNITY_MECHANIC, MECHANIC_FEAR, true);
        me->ApplySpellImmune(0, IMMUNITY_STATE, SPELL_AURA_MOD_TAUNT, false);
        me->setActive(true);
    }

    Creature* _kohcrom;
    uint32 _stompCount;
    uint32 _crystalCount;
    bool _kohcromSummoned;
    bool _isHeroic;
    ObjectGuid _stompGuid1;
    ObjectGuid _stompGuid2;

    void Reset() override
    {
        _Reset();
        if (_kohcrom && _kohcrom->IsAlive())
            _kohcrom->DespawnOrUnsummon();
        _kohcrom = nullptr;
        _stompCount = 0;
        _crystalCount = 0;
        _kohcromSummoned = false;
        _stompGuid1 = ObjectGuid::Empty;
        _stompGuid2 = ObjectGuid::Empty;
        _isHeroic = me->GetMap()->IsHeroic();

        if (instance)
        {
            instance->SetBossState(DATA_MORCHOK, NOT_STARTED);
            if (auto* map = me->GetMap())
                map->SetWorldStateValue(WORLDSTATE_DONT_STAND_SO_CLOSE, 1, false);
        }
    }

    void JustEngagedWith(Unit* who) override
    {
        BossAI::JustEngagedWith(who);
        Talk(SAY_AGGRO);
        DoZoneInCombat();
        _isHeroic = me->GetMap()->IsHeroic();

        if (instance)
        {
            instance->SendEncounterUnit(ENCOUNTER_FRAME_ENGAGE, me);
            instance->SetBossState(DATA_MORCHOK, IN_PROGRESS);
        }

        events.SetPhase(PHASE_NORMAL);
        events.ScheduleEvent(EVENT_STOMP, 12s, 0, PHASE_NORMAL);
        events.ScheduleEvent(EVENT_CRUSH_ARMOR, 6s, 0, PHASE_NORMAL);
        events.ScheduleEvent(EVENT_RESONATING_CRYSTAL, 14s, 0, PHASE_NORMAL);
        events.ScheduleEvent(EVENT_PHASE_FALLBACK, 50s, 0, PHASE_NORMAL);
        events.ScheduleEvent(EVENT_BERSERK, 420s);
        _stompGuid1 = ObjectGuid::Empty;
        _stompGuid2 = ObjectGuid::Empty;
    }

    void JustDied(Unit* /*killer*/) override
    {
        _JustDied();
        Talk(SAY_DEATH);
        if (instance)
        {
            instance->SendEncounterUnit(ENCOUNTER_FRAME_DISENGAGE, me);
            instance->SetBossState(DATA_MORCHOK, DONE);
        }
        if (_kohcrom && _kohcrom->IsAlive())
            Unit::Kill(me, _kohcrom, false);
    }

    void EnterEvadeMode(EvadeReason why) override
    {
        BossAI::EnterEvadeMode(why);
        if (instance)
        {
            instance->SendEncounterUnit(ENCOUNTER_FRAME_DISENGAGE, me);
            instance->SetBossState(DATA_MORCHOK, FAIL);
        }
        if (_kohcrom && _kohcrom->IsAlive())
            _kohcrom->DespawnOrUnsummon();
        _DespawnAtEvade();
    }

    void SetGUID(ObjectGuid const& guid, int32 type) override
    {
        if (type == DATA_GUID_1)
            _stompGuid1 = guid;
        else if (type == DATA_GUID_2)
            _stompGuid2 = guid;
    }

    ObjectGuid GetGUID(int32 type) const override
    {
        if (type == DATA_GUID_1)
            return _stompGuid1;
        else if (type == DATA_GUID_2)
            return _stompGuid2;
        return ObjectGuid::Empty;
    }

    uint32 GetData(uint32 type) const override
    {
        if (type == DATA_KOHCROM_DONE)
            return uint32(_kohcromSummoned && _kohcrom && !_kohcrom->IsAlive() ? 1 : 0);
        return 0;
    }

    void SetData(uint32 type, uint32 data) override
    {
        if (type == DATA_ALLOW_ACHIEV)
            if (auto* map = me->GetMap())
                map->SetWorldStateValue(WORLDSTATE_DONT_STAND_SO_CLOSE, 0, false);
        (void)data;
    }

    void JustSummoned(Creature* summon) override
    {
        BossAI::JustSummoned(summon);
        if (summon->GetEntry() == NPC_KOHCROM)
        {
            _kohcrom = summon;
            summon->SetMaxHealth(me->GetMaxHealth());
            summon->SetHealth(me->GetHealth());
            summon->AI()->DoAction(ACTION_TWIN_LINK);
        }
    }

    void SummonKohcrom()
    {
        Talk(SAY_KOHCROM);
        if (SPELL_SUMMON_KOHCROM)
            DoCastSelf(SPELL_SUMMON_KOHCROM, true);

        if (!_kohcrom)
        {
            Position pos = me->GetPosition();
            float dx = 6.0f * std::cos(me->GetOrientation());
            float dy = 6.0f * std::sin(me->GetOrientation());
            pos.m_positionX += dx;
            pos.m_positionY += dy;
            if (TempSummon* k = me->SummonCreature(NPC_KOHCROM, pos, TEMPSUMMON_CORPSE_TIMED_DESPAWN, 30000))
            {
                _kohcrom = k;
                k->SetMaxHealth(me->GetMaxHealth());
                k->SetHealth(me->GetHealth());
                k->AI()->DoAction(ACTION_TWIN_LINK);
                if (Unit* victim = me->GetVictim())
                    k->EngageWithTarget(victim);
            }
        }
        if (SPELL_MORCHOK_JUMP)
            DoCastSelf(SPELL_MORCHOK_JUMP, true);
    }

    void DamageTaken(Unit* /*attacker*/, uint32& damage) override
    {
        if (!me->IsAlive())
            return;

        // FIX Normal: dano letal força morte (evita trava 1 HP por transição/fase)
        if (!_isHeroic && me->GetHealth() <= damage)
        {
            TC_LOG_DEBUG("scripts", "Morchok Normal: lethal {} vs hp {}, forcing JUST_DIED", damage, me->GetHealth());
            me->SetHealth(0);
            me->setDeathState(JUST_DIED);
            JustDied(nullptr);
            return;
        }

        if (_isHeroic && !_kohcromSummoned && me->HealthBelowPctDamaged(90, damage))
        {
            _kohcromSummoned = true;
            SummonKohcrom();
        }

        if (!me->HasAura(SPELL_FURIOUS) && me->HealthBelowPctDamaged(20, damage))
            DoCastSelf(SPELL_FURIOUS);

        // Shared Health Pool em Heroico
        if (_kohcrom && _kohcrom->IsAlive())
        {
            uint32 cur = me->GetHealth();
            if (damage < cur)
            {
                uint32 newHp = cur - damage;
                _kohcrom->SetHealth(newHp);
            }
            else
            {
                Unit::Kill(me, _kohcrom, false); // Kohcrom must die with Morchok
            }
        }
    }

    void DoAction(int32 action) override
    {
        if (action == ACTION_CRYSTAL_EXPLODED && events.IsInPhase(PHASE_NORMAL))
        {
            uint32 requiredCrystals = _isHeroic ? 4 : 2;
            if (++_crystalCount >= requiredCrystals)
            {
                StartBlackBloodPhase();
            }
        }
    }

    void StartBlackBloodPhase()
    {
        _crystalCount = 0;
        events.CancelEvent(EVENT_STOMP);
        events.CancelEvent(EVENT_CRUSH_ARMOR);
        events.CancelEvent(EVENT_RESONATING_CRYSTAL);
        events.CancelEvent(EVENT_PHASE_FALLBACK);
        events.SetPhase(PHASE_BLACK_BLOOD);
        events.ScheduleEvent(EVENT_EARTHEN_VORTEX, 500ms, 0, PHASE_BLACK_BLOOD);
    }

    void KilledUnit(Unit* victim) override
    {
        if (victim && victim->GetTypeId() == TYPEID_PLAYER)
            Talk(SAY_KILL);
    }

    void UpdateAI(uint32 diff) override
    {
        if (!UpdateVictim())
            return;

        if (me->GetDistance(me->GetHomePosition()) > 150.0f)
        {
            EnterEvadeMode(EVADE_REASON_SEQUENCE_BREAK);
            return;
        }

        events.Update(diff);

        if (me->HasUnitState(UNIT_STATE_CASTING))
            return;

        while (uint32 eventId = events.ExecuteEvent())
        {
            switch (eventId)
            {
                case EVENT_STOMP:
                {
                    _stompGuid1 = ObjectGuid::Empty;
                    _stompGuid2 = ObjectGuid::Empty;
                    DoCastAOE(SPELL_STOMP);
                    ++_stompCount;
                    if (_kohcrom && _kohcrom->IsAlive())
                        _kohcrom->AI()->DoAction(ACTION_KOHCROM_STOMP);
                    events.ScheduleEvent(EVENT_STOMP, Milliseconds(12000 + rand() % 2000), 0, PHASE_NORMAL);
                    break;
                }
                case EVENT_CRUSH_ARMOR:
                {
                    if (Unit* victim = me->GetVictim())
                        DoCast(victim, SPELL_CRUSH_ARMOR);
                    events.ScheduleEvent(EVENT_CRUSH_ARMOR, Milliseconds(10000 + rand() % 3000), 0, PHASE_NORMAL);
                    break;
                }
                case EVENT_RESONATING_CRYSTAL:
                {
                    if (Unit* target = SelectTarget(SELECT_TARGET_RANDOM, 0, 100.0f, true))
                        DoCast(target, SPELL_RESONATING_CRYSTAL);
                    Talk(SAY_CRYSTAL);
                    Talk(ANN_CRYSTAL);
                    if (_kohcrom && _kohcrom->IsAlive())
                        _kohcrom->AI()->DoAction(ACTION_KOHCROM_CRYSTAL);
                    events.ScheduleEvent(EVENT_RESONATING_CRYSTAL, Milliseconds(14000 + rand() % 2000), 0, PHASE_NORMAL);
                    break;
                }
                case EVENT_PHASE_FALLBACK:
                {
                    if (events.IsInPhase(PHASE_NORMAL))
                        StartBlackBloodPhase();
                    break;
                }
                case EVENT_EARTHEN_VORTEX:
                {
                    Talk(SAY_GROUND1);
                    DoCastAOE(SPELL_EARTHEN_VORTEX);
                    DoCastSelf(SPELL_FALLING_FRAGMENTS);
                    if (_kohcrom && _kohcrom->IsAlive())
                        _kohcrom->AI()->DoAction(ACTION_KOHCROM_VORTEX);
                    events.ScheduleEvent(EVENT_BLACK_BLOOD, 5s, 0, PHASE_BLACK_BLOOD);
                    break;
                }
                case EVENT_BLACK_BLOOD:
                {
                    Talk(SAY_GROUND2);
                    DoCastSelf(SPELL_BLACK_BLOOD_OF_THE_EARTH);
                    if (_kohcrom && _kohcrom->IsAlive())
                        _kohcrom->AI()->DoAction(ACTION_KOHCROM_BLACK_BLOOD);
                    events.ScheduleEvent(EVENT_BLACK_BLOOD_END, 17s, 0, PHASE_BLACK_BLOOD);
                    break;
                }
                case EVENT_BLACK_BLOOD_END:
                {
                    events.SetPhase(PHASE_NORMAL);
                    events.ScheduleEvent(EVENT_STOMP, 3s, 0, PHASE_NORMAL);
                    events.ScheduleEvent(EVENT_CRUSH_ARMOR, 6s, 0, PHASE_NORMAL);
                    events.ScheduleEvent(EVENT_RESONATING_CRYSTAL, 12s, 0, PHASE_NORMAL);
                    events.ScheduleEvent(EVENT_PHASE_FALLBACK, 50s, 0, PHASE_NORMAL);
                    break;
                }
                case EVENT_CONTINUE:
                {
                    me->SetReactState(REACT_AGGRESSIVE);
                    if (Unit* victim = me->GetVictim())
                        me->GetMotionMaster()->MoveChase(victim);
                    break;
                }
                case EVENT_BERSERK:
                    DoCastSelf(SPELL_BERSERK);
                    break;
                default:
                    break;
            }
        }

        DoMeleeAttackIfReady();
    }
};

struct npc_morchok_kohcrom : public BossAI
{
    npc_morchok_kohcrom(Creature* creature) : BossAI(creature, DATA_KOHCROM), _twin(nullptr)
    {
        me->ApplySpellImmune(0, IMMUNITY_EFFECT, SPELL_EFFECT_KNOCK_BACK, true);
        me->ApplySpellImmune(0, IMMUNITY_MECHANIC, MECHANIC_GRIP, true);
        me->ApplySpellImmune(0, IMMUNITY_MECHANIC, MECHANIC_STUN, true);
        me->ApplySpellImmune(0, IMMUNITY_MECHANIC, MECHANIC_FEAR, true);
        me->ApplySpellImmune(0, IMMUNITY_STATE, SPELL_AURA_MOD_TAUNT, false);
        me->setActive(true);
    }

    Creature* _twin;

    void Reset() override
    {
        _Reset();
        if (!_twin && instance)
            _twin = instance->GetCreature(DATA_MORCHOK);
    }

    void DoAction(int32 action) override
    {
        if (action == ACTION_TWIN_LINK)
        {
            if (instance)
                _twin = instance->GetCreature(DATA_MORCHOK);
        }
        else if (action == ACTION_KOHCROM_STOMP)
        {
            events.ScheduleEvent(EVENT_STOMP, 1500ms);
        }
        else if (action == ACTION_KOHCROM_CRYSTAL)
        {
            events.ScheduleEvent(EVENT_RESONATING_CRYSTAL, 1500ms);
        }
        else if (action == ACTION_KOHCROM_VORTEX)
        {
            DoCastAOE(SPELL_EARTHEN_VORTEX);
            DoCastSelf(SPELL_FALLING_FRAGMENTS);
        }
        else if (action == ACTION_KOHCROM_BLACK_BLOOD)
        {
            DoCastSelf(SPELL_BLACK_BLOOD_OF_THE_EARTH);
        }
    }

    void JustEngagedWith(Unit* who) override
    {
        BossAI::JustEngagedWith(who);
        events.SetPhase(PHASE_NORMAL);
        if (!_twin && instance)
            _twin = instance->GetCreature(DATA_MORCHOK);
    }

    void DamageTaken(Unit* /*attacker*/, uint32& damage) override
    {
        if (!me->IsAlive())
            return;

        if (!_twin && instance)
            _twin = instance->GetCreature(DATA_MORCHOK);

        if (!me->HasAura(SPELL_FURIOUS) && me->HealthBelowPctDamaged(20, damage))
            DoCastSelf(SPELL_FURIOUS);

        // Shared Health Pool em Heroico: espelha dano de Kohcrom -> Morchok
        if (_twin && _twin->IsAlive())
        {
            uint32 cur = me->GetHealth();
            if (damage < cur)
            {
                uint32 newHp = cur - damage;
                _twin->SetHealth(newHp);
            }
            else
            {
                Unit::Kill(me, _twin, false); // Morchok must die with Kohcrom
            }
        }
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
                    break;
                case EVENT_RESONATING_CRYSTAL:
                    if (Unit* target = SelectTarget(SELECT_TARGET_RANDOM, 0, 100.0f, true))
                        DoCast(target, SPELL_RESONATING_CRYSTAL);
                    break;
                default:
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

    void IsSummonedBy(Unit* /*summoner*/) override
    {
        // Cristal Ressonante: 103640 invoca 55269 no chao. Retail 4.3.4: cristal fica parado 12s e explode (103494).
        // Nao deve perseguir jogador nem explodir ao tocar - corrige sumico rapido.
        me->SetReactState(REACT_PASSIVE);
        me->SetFlag(UNIT_FIELD_FLAGS, UNIT_FLAG_NOT_SELECTABLE | UNIT_FLAG_NON_ATTACKABLE);
        me->GetMotionMaster()->Clear();
        me->GetMotionMaster()->MoveIdle();
        // Garante display/aura visual se DBC nao aplicar automaticamente
    }

    void UpdateAI(uint32 diff) override
    {
        if (_exploded)
            return;

        // Timer 12s fixo - corrige underflow uint32 (_timer -= diff; if <=0) e explosao prematura por proximidade.
        if (_timer <= diff)
        {
            _exploded = true;
            DoCastAOE(SPELL_RESONATING_CRYSTAL_DMG);
            if (InstanceScript* inst = me->GetInstanceScript())
                if (Creature* boss = inst->GetCreature(DATA_MORCHOK))
                    if (boss->IsAlive())
                        boss->AI()->DoAction(ACTION_CRYSTAL_EXPLODED);
            me->DespawnOrUnsummon(2000);
            return;
        }
        else
            _timer -= diff;

        // Permanece no local de invocacao ate explodir - sem chase. Retail: cristal nao segue target.
    }
};

// Stomp: alvo atual e aliado mais proximo recebem dano dobrado. 4.3.4: SpellScript direto (sem SpellScriptLoader).
class spell_morchok_stomp : public SpellScript
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
        if (Creature* morchok = GetCaster()->ToCreature())
        {
            auto it = targets.begin();
            if (it != targets.end())
                morchok->AI()->SetGUID((*it)->GetGUID(), DATA_GUID_1);
            if (targets.size() > 1)
            {
                ++it;
                if (it != targets.end())
                    morchok->AI()->SetGUID((*it)->GetGUID(), DATA_GUID_2);
            }
        }
    }

    void CalculateDamage(Unit* victim, int32& damage, int32& /*flatMod*/, float& /*pctMod*/)
    {
        if (victim && std::find(_doubled.begin(), _doubled.end(), victim->GetGUID()) != _doubled.end())
            damage *= 2;
    }

    void Register() override
    {
        OnObjectAreaTargetSelect.Register(&spell_morchok_stomp::FilterTargets, EFFECT_0, TARGET_UNIT_SRC_AREA_ENEMY);
        OnObjectAreaTargetSelect.Register(&spell_morchok_stomp::FilterTargets, EFFECT_1, TARGET_UNIT_SRC_AREA_ENEMY);
        CalcDamage.Register(&spell_morchok_stomp::CalculateDamage);
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


// Black Blood of the Earth: raio de dano cresce a cada tick. 4.3.4: SpellScript direto.
class spell_morchok_black_blood_of_the_earth_dmg : public SpellScript
{
    void FilterTargets(std::list<WorldObject*>& targets)
    {
        if (!GetCaster() || targets.empty())
            return;
        // Achiev "Don't Stand So Close": se 2+ players <5y em 10m ou 2+ em 25m, falha
        if (Creature* caster = GetCaster()->ToCreature())
        {
            std::list<Player*> pls;
            GetPlayerListInGrid(pls, caster, 200.0f);
            for (Player* pl : pls)
            {
                std::list<Player*> nearPlayers;
                GetPlayerListInGrid(nearPlayers, pl, 5.0f);
                nearPlayers.remove_if([pl](Player* t){ return !t || t->GetGUID() == pl->GetGUID(); });
                uint32 allow = pl->GetMap()->Is25ManRaid() ? 1 : 0;
                if (nearPlayers.size() > allow)
                    if (InstanceScript* inst = caster->GetInstanceScript())
                        if (Creature* boss = inst->GetCreature(DATA_MORCHOK))
                            boss->AI()->SetData(DATA_ALLOW_ACHIEV, 0);
            }
        }
        if (AuraEffect const* aurEff = GetCaster()->GetAuraEffect(SPELL_BLACK_BLOOD_OF_THE_EARTH, EFFECT_0))
        {
            uint32 ticks = aurEff->GetTickNumber() + 1;
            targets.remove_if(DistanceCheck(GetCaster(), float(ticks * 4)));
        }
    }

    void Register() override
    {
        OnObjectAreaTargetSelect.Register(&spell_morchok_black_blood_of_the_earth_dmg::FilterTargets, EFFECT_0, TARGET_UNIT_DEST_AREA_ENEMY);
        OnObjectAreaTargetSelect.Register(&spell_morchok_black_blood_of_the_earth_dmg::FilterTargets, EFFECT_1, TARGET_UNIT_DEST_AREA_ENEMY);
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

// Cristal Ressonante: dano dividido entre 3 (10m) ou 7 (25m) jogadores. 4.3.4: SpellScript direto.
class spell_morchok_resonating_crystal_dmg : public SpellScript
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
        OnObjectAreaTargetSelect.Register(&spell_morchok_resonating_crystal_dmg::FilterTargets, EFFECT_0, TARGET_UNIT_DEST_AREA_ENEMY);
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

