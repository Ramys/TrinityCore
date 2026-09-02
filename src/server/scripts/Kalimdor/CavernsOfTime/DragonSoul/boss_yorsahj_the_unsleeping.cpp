/*
 * TrinityCore 4.3.4 - Dragon Soul: Yorsahj the Unsleeping 55312
 * DBC validados: 104849 Void Bolt, 105171 Deep Corruption, 105031 Digestive Acid,
 * 105033 Searing Blood, 105530 Mana Void trig 105534, 105539 Mana Diffusion, 105671 Psychic Slice
 * Adds: 55862-55867 globules, 56231 Mana Void, 56265 Forgotten One
 */
#include "dragon_soul.h"
#include "ScriptedCreature.h"
#include "ScriptMgr.h"
#include "SpellScript.h"
#include "SpellAuraEffects.h"
#include "SpellInfo.h"
#include "InstanceScript.h"
#include "ObjectAccessor.h"
#include "TemporarySummon.h"
#include "Player.h"
#include "Map.h"
#include "Containers.h"
#include <vector>
namespace DragonSoul::Yorsahj
{
enum Texts { SAY_AGGRO=0, SAY_DEATH=1, SAY_INTRO=2, SAY_KILL=3, SAY_GLOBULE=4, SAY_BERSERK=5 };
enum Spells
{
    SPELL_BERSERK=47008, SPELL_VOID_BOLT=104849,
    SPELL_ACIDIC_BLOOD=104898, SPELL_SHADOWED_BLOOD=104896, SPELL_GLOWING_BLOOD=104901,
    SPELL_CRIMSON_BLOOD=104897, SPELL_COBALT_BLOOD=104900, SPELL_BLACK_BLOOD=104894,
    SPELL_DIGESTIVE_ACID=105031, SPELL_DEEP_CORRUPTION=105171, SPELL_SEARING_BLOOD=105033,
    SPELL_MANA_VOID_SUMMON=105530, SPELL_MANA_VOID_DRAIN=105034, SPELL_MANA_DIFFUSION=105539,
    SPELL_MANA_VOID_TRIG=105534, SPELL_PSYCHIC_SLICE=105671, SPELL_CALL_BLOOD=105132
};
enum Events { EVENT_VOID_BOLT=1, EVENT_CALL_BLOOD=2, EVENT_BERSERK=4 };
enum Actions { ACTION_GLOBULE_REACHED=1 };
enum Points { POINT_BOSS=1 };
static uint32 const GLOBULE_ENTRIES[6]={ NPC_GLOBULE_ACIDIC, NPC_GLOBULE_SHADOWED, NPC_GLOBULE_GLOWING, NPC_GLOBULE_CRIMSON, NPC_GLOBULE_COBALT, NPC_GLOBULE_DARK };
struct boss_yorsahj_the_unsleeping : public BossAI
{
    boss_yorsahj_the_unsleeping(Creature* c) : BossAI(c, DATA_YORSAHJ_THE_UNSLEEPING), _isHeroic(false), _lastMask(0) {}
    void Reset() override
    {
        _Reset(); _isHeroic=me->GetMap()->IsHeroic(); _lastMask=0; _called=0;
        me->SetReactState(REACT_AGGRESSIVE);
        me->RemoveAurasDueToSpell(SPELL_ACIDIC_BLOOD); me->RemoveAurasDueToSpell(SPELL_SHADOWED_BLOOD);
        me->RemoveAurasDueToSpell(SPELL_GLOWING_BLOOD); me->RemoveAurasDueToSpell(SPELL_CRIMSON_BLOOD);
        me->RemoveAurasDueToSpell(SPELL_COBALT_BLOOD); me->RemoveAurasDueToSpell(SPELL_BLACK_BLOOD);
    }
    void JustEngagedWith(Unit* who) override
    {
        BossAI::JustEngagedWith(who);
        if (InstanceScript* inst=me->GetInstanceScript())
            if (inst->GetBossState(DATA_WARLORD_ZONOZZ)!=DONE) { EnterEvadeMode(); return; }
        Talk(SAY_AGGRO);
        events.ScheduleEvent(EVENT_VOID_BOLT, 8s);
        events.ScheduleEvent(EVENT_CALL_BLOOD, 30s);
        events.ScheduleEvent(EVENT_BERSERK, 360s);
    }
    void JustDied(Unit*) override { _JustDied(); Talk(SAY_DEATH); }
    void KilledUnit(Unit* v) override { if(v->GetTypeId()==TYPEID_PLAYER) Talk(SAY_KILL); }
    void JustSummoned(Creature* s) override
    {
        BossAI::JustSummoned(s);
        switch(s->GetEntry())
        {
            case NPC_GLOBULE_ACIDIC: case NPC_GLOBULE_SHADOWED: case NPC_GLOBULE_GLOWING:
            case NPC_GLOBULE_CRIMSON: case NPC_GLOBULE_COBALT: case NPC_GLOBULE_DARK:
                s->SetReactState(REACT_PASSIVE); s->SetSpeed(MOVE_RUN,0.9f);
                s->GetMotionMaster()->MovePoint(POINT_BOSS, me->GetPositionX(), me->GetPositionY(), me->GetPositionZ());
                break;
            case NPC_MANA_VOID: s->CastSpell(s, SPELL_MANA_VOID_DRAIN, true); s->SetReactState(REACT_PASSIVE); break;
            case NPC_FORGOTTEN_ONE:
                if(Unit* t=SelectTarget(SELECT_TARGET_RANDOM,0,0.0f,true)){ s->AI()->AttackStart(t); s->AddThreat(t,1000000.0f); }
                break;
            default: break;
        }
    }
    void SummonedCreatureDies(Creature* s, Unit*) override
    {
        if(s->GetEntry()==NPC_MANA_VOID){ s->CastSpell(s, SPELL_MANA_DIFFUSION, true); s->CastSpell(s, SPELL_MANA_VOID_TRIG, true); }
    }
    void DoAction(int32 a) override { if(a==ACTION_GLOBULE_REACHED){ _reached++; if(_reached>=_expected) ApplyBuffs(); } }
    void UpdateAI(uint32 diff) override
    {
        if(!UpdateVictim()) return;
        events.Update(diff);
        if(me->HasUnitState(UNIT_STATE_CASTING)) return;
        while(uint32 e=events.ExecuteEvent())
        {
            switch(e)
            {
                case EVENT_VOID_BOLT: if(Unit* t=me->GetVictim()) DoCast(t, SPELL_VOID_BOLT); events.ScheduleEvent(EVENT_VOID_BOLT,12s); break;
                case EVENT_CALL_BLOOD: Talk(SAY_GLOBULE); DoCastAOE(SPELL_CALL_BLOOD); SummonWave(); events.ScheduleEvent(EVENT_CALL_BLOOD,75s); break;
                case EVENT_BERSERK: Talk(SAY_BERSERK); DoCastAOE(SPELL_BERSERK); break;
                default: break;
            }
        }
        DoMeleeAttackIfReady();
    }
private:
    void SummonWave()
    {
        uint32 count = _isHeroic ? 4 : 3;
        _expected = count; _reached = 0; _curr.clear();
        std::vector<uint32> idx = {0,1,2,3,4,5};
        uint32 mask = 0; uint32 tries = 0;
        do
        {
            Trinity::Containers::RandomShuffle(idx);
            mask = 0; _curr.clear();
            for (uint32 i = 0; i < count; ++i)
            {
                uint32 ei = idx[i];
                _curr.push_back(GLOBULE_ENTRIES[ei]);
                mask |= (1u << ei);
            }
            tries++;
        } while (mask == _lastMask && tries < 10);
        _lastMask = mask;
        float step = float(M_PI * 2.0f / count);
        float base = frand(0.0f, float(M_PI * 2.0f));
        for (uint32 i = 0; i < _curr.size(); ++i)
        {
            float ang = base + i * step;
            float dist = 35.0f + frand(0.0f, 10.0f);
            float x = me->GetPositionX() + dist * std::cos(ang);
            float y = me->GetPositionY() + dist * std::sin(ang);
            float z = me->GetPositionZ();
            me->UpdateGroundPositionZ(x, y, z);
            me->SummonCreature(_curr[i], x, y, z, 0.0f, TEMPSUMMON_CORPSE_DESPAWN, 0);
        }
        _called++;
    }
    void ApplyBuffs()
    {
        for (uint32 entry : _curr)
        {
            switch (entry)
            {
                case NPC_GLOBULE_ACIDIC: DoCastAOE(SPELL_ACIDIC_BLOOD); DoCastAOE(SPELL_DIGESTIVE_ACID); break;
                case NPC_GLOBULE_SHADOWED: DoCastAOE(SPELL_SHADOWED_BLOOD); DoCastAOE(SPELL_DEEP_CORRUPTION); break;
                case NPC_GLOBULE_GLOWING: DoCastAOE(SPELL_GLOWING_BLOOD); break;
                case NPC_GLOBULE_CRIMSON: DoCastAOE(SPELL_CRIMSON_BLOOD); DoCastAOE(SPELL_SEARING_BLOOD); break;
                case NPC_GLOBULE_COBALT: DoCastAOE(SPELL_COBALT_BLOOD); me->SummonCreature(NPC_MANA_VOID, me->GetPositionX(), me->GetPositionY(), me->GetPositionZ(), 0.0f, TEMPSUMMON_CORPSE_TIMED_DESPAWN, 30000); break;
                case NPC_GLOBULE_DARK: DoCastAOE(SPELL_BLACK_BLOOD); for(uint32 i=0;i<3;++i){ float a=frand(0.0f,float(M_PI*2.0f)); float d=8.0f; float x=me->GetPositionX()+d*std::cos(a); float y=me->GetPositionY()+d*std::sin(a); float z=me->GetPositionZ(); me->UpdateGroundPositionZ(x,y,z); me->SummonCreature(NPC_FORGOTTEN_ONE,x,y,z,0.0f,TEMPSUMMON_CORPSE_TIMED_DESPAWN,30000);} break;
                default: break;
            }
        }
        _curr.clear();
    }
    bool _isHeroic; uint32 _lastMask; uint32 _called=0; uint32 _expected=0; uint32 _reached=0;
    std::vector<uint32> _curr;
};

struct npc_yorsahj_globule : public ScriptedAI
{
    npc_yorsahj_globule(Creature* c) : ScriptedAI(c) {}
    void Reset() override { me->SetReactState(REACT_PASSIVE); me->SetFlag(UNIT_FIELD_FLAGS, UNIT_FLAG_NOT_SELECTABLE | UNIT_FLAG_NON_ATTACKABLE); }
    void MovementInform(uint32 type, uint32 id) override
    {
        if (type == POINT_MOTION_TYPE && id == POINT_BOSS)
        {
            if (InstanceScript* inst = me->GetInstanceScript())
                if (Creature* boss = inst->GetCreature(DATA_YORSAHJ_THE_UNSLEEPING))
                {
                    boss->AI()->DoAction(ACTION_GLOBULE_REACHED);
                    me->DespawnOrUnsummon(500);
                }
        }
    }
    void UpdateAI(uint32) override {}
};

struct npc_yorsahj_mana_void : public ScriptedAI
{
    npc_yorsahj_mana_void(Creature* c) : ScriptedAI(c) {}
    void Reset() override { me->SetReactState(REACT_PASSIVE); me->AddAura(SPELL_MANA_VOID_DRAIN, me); }
    void JustDied(Unit*) override { DoCastAOE(SPELL_MANA_DIFFUSION); DoCastAOE(SPELL_MANA_VOID_TRIG); }
    void UpdateAI(uint32) override {}
};

struct npc_yorsahj_forgotten_one : public ScriptedAI
{
    npc_yorsahj_forgotten_one(Creature* c) : ScriptedAI(c) { _timer = 8000; }
    void Reset() override { _timer = 8000; }
    void JustEngagedWith(Unit*) override { _timer = 6000; }
    void UpdateAI(uint32 diff) override
    {
        if (!UpdateVictim()) return;
        if (_timer <= diff) { if(Unit* t=me->GetVictim()) DoCast(t, SPELL_PSYCHIC_SLICE); _timer = 12000; } else _timer -= diff;
        DoMeleeAttackIfReady();
    }
private: uint32 _timer;
};

struct spell_yorsahj_deep_corruption : public AuraScript
{
    void Register() override {}
};

} // namespace DragonSoul::Yorsahj
using namespace DragonSoul::Yorsahj;
void AddSC_boss_yorsahj_the_unsleeping()
{
    using namespace DragonSoul;
    RegisterDragonSoulCreatureAI(boss_yorsahj_the_unsleeping);
    RegisterCreatureAI(npc_yorsahj_globule);
    RegisterCreatureAI(npc_yorsahj_mana_void);
    RegisterCreatureAI(npc_yorsahj_forgotten_one);
    RegisterSpellScript(spell_yorsahj_deep_corruption);
}
