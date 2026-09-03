/*
 * TrinityCore 4.3.4 - Dragon Soul: Yorsahj the Unsleeping 55312
 * Dossiê: 47M/90M/142M/232M HP, Enrage 10min 26662, 3 globules Normal / 4 Heroic
 * Spells: 104849 Void Bolt, 103628/105171 Deep Corruption, 105031 Digestive Acid,
 *  105033 Searing Blood, 105034/105530/105539 Mana Void/Diffusion, 103635 Fusing Vapors,
 *  104894 Black,104896 Shadowed,104897 Crimson,104898 Acidic,104900/105027 Cobalt,104901 Glowing
 * Adds: 55862 Acidic 55863 Shadowed 55864 Glowing 55865 Crimson 55866 Cobalt 55867 Dark
 *       56231 Mana Void 56265 Forgotten One 105671 Psychic Slice 105695 Fixate
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
#include <algorithm>
namespace DragonSoul::Yorsahj
{
enum Texts { SAY_AGGRO=0, SAY_DEATH=1, SAY_INTRO=2, SAY_KILL=3, SAY_GLOBULE=4, SAY_BERSERK=5 };
enum Spells
{
    SPELL_BERSERK               = 26662, // dossiê Enrage 10min (47008 legacy)
    SPELL_VOID_BOLT             = 104849, // 92.5-107.5k + 46-53k/2s DoT stack 5 ; LFR 108383 ; var 105416
    SPELL_VOID_BOLT_AOE         = 109549, // LFR Glowing variant
    SPELL_ACIDIC_BLOOD          = 104898,
    SPELL_SHADOWED_BLOOD        = 104896,
    SPELL_GLOWING_BLOOD         = 104901,
    SPELL_CRIMSON_BLOOD         = 104897,
    SPELL_COBALT_BLOOD          = 104900, // var 105027
    SPELL_COBALT_BLOOD_2        = 105027,
    SPELL_BLACK_BLOOD           = 104894, // var 109558 LFR
    SPELL_DIGESTIVE_ACID        = 105031, // 4m splash wipe
    SPELL_DEEP_CORRUPTION       = 105171, // var 103628 ; 5o heal explode 89-104k
    SPELL_DEEP_CORRUPTION_TRIG  = 103628,
    SPELL_SEARING_BLOOD         = 105033, // 55.2k Fire, 3 alvos 10p / 8 alvos 25p escala distância
    SPELL_MANA_VOID_SUMMON      = 105530,
    SPELL_MANA_VOID_DRAIN       = 105034, // leech 108222 ; drena 100% mana
    SPELL_MANA_VOID_TRIG        = 105534,
    SPELL_MANA_DIFFUSION        = 105539, // 30m devolve mana
    SPELL_FUSING_VAPORS         = 103635, // <50% cura 5% outros globules ; morte = imune fundido
    SPELL_PSYCHIC_SLICE         = 105671, // var 108922 Forgotten One
    SPELL_FIXATE                = 105695,
    SPELL_CALL_BLOOD            = 105132
};
enum Events
{
    EVENT_VOID_BOLT             = 1,
    EVENT_CALL_BLOOD            = 2,
    EVENT_BERSERK               = 3,
    EVENT_SUMMON_FORGOTTEN      = 4,
    EVENT_SEARING_BLOOD         = 5,
    EVENT_DIGESTIVE_ACID        = 6
};
enum Actions { ACTION_GLOBULE_REACHED=1, ACTION_GLOBULE_DIED=2 };
enum WorldStates
{
    // Taste the Rainbow! 6129 - DBC Achievement_Criteria 18495-18498 RequiredWorldStateID 6221-6224 ==1
    WORLDSTATE_TASTE_RAINBOW_BLACK_YELLOW  = 6221, // Black and Yellow - DARK 55867 + GLOWING 55864
    WORLDSTATE_TASTE_RAINBOW_RED_GREEN     = 6222, // Red and Green - CRIMSON 55865 + ACIDIC 55862
    WORLDSTATE_TASTE_RAINBOW_BLACK_BLUE    = 6223, // Black and Blue - DARK 55867 + COBALT 55866
    WORLDSTATE_TASTE_RAINBOW_PURPLE_YELLOW = 6224  // Purple and Yellow - SHADOWED 55863 + GLOWING 55864
};
enum Points { POINT_BOSS=1 };
static uint32 const GLOBULE_ENTRIES[6]={ NPC_GLOBULE_ACIDIC, NPC_GLOBULE_SHADOWED, NPC_GLOBULE_GLOWING, NPC_GLOBULE_CRIMSON, NPC_GLOBULE_COBALT, NPC_GLOBULE_DARK };
// Combinações blizzlike por dificuldade (dossiê seção 5.1/5.2)
static uint32 const NORMAL_COMBOS[6][3]=
{
    {NPC_GLOBULE_GLOWING, NPC_GLOBULE_DARK,    NPC_GLOBULE_COBALT}, // Y+B+Az - matar amarelo
    {NPC_GLOBULE_GLOWING, NPC_GLOBULE_SHADOWED,NPC_GLOBULE_COBALT}, // Y+Ro+Az - matar amarelo
    {NPC_GLOBULE_DARK,    NPC_GLOBULE_SHADOWED,NPC_GLOBULE_CRIMSON},// Pr+Ro+Vm - matar vermelho
    {NPC_GLOBULE_CRIMSON, NPC_GLOBULE_GLOWING, NPC_GLOBULE_ACIDIC}, // Vm+Y+Vd - matar verde (mais perigosa)
    {NPC_GLOBULE_ACIDIC,  NPC_GLOBULE_CRIMSON, NPC_GLOBULE_DARK},   // Vd+Vm+Pr - matar verde
    {NPC_GLOBULE_SHADOWED,NPC_GLOBULE_COBALT,  NPC_GLOBULE_ACIDIC}  // Ro+Az+Vd - matar verde
};
static uint32 const HEROIC_COMBOS[6][4]=
{
    {NPC_GLOBULE_GLOWING, NPC_GLOBULE_CRIMSON, NPC_GLOBULE_SHADOWED, NPC_GLOBULE_DARK}, // Y+Vm+Ro+Pr
    {NPC_GLOBULE_GLOWING, NPC_GLOBULE_SHADOWED,NPC_GLOBULE_COBALT,   NPC_GLOBULE_ACIDIC},// Y+Ro+Az+Vd
    {NPC_GLOBULE_GLOWING, NPC_GLOBULE_SHADOWED,NPC_GLOBULE_COBALT,   NPC_GLOBULE_DARK},  // Y+Ro+Az+Pr
    {NPC_GLOBULE_GLOWING, NPC_GLOBULE_ACIDIC,  NPC_GLOBULE_CRIMSON,  NPC_GLOBULE_DARK},  // Y+Vd+Vm+Pr - mais perigosa
    {NPC_GLOBULE_ACIDIC,  NPC_GLOBULE_COBALT,  NPC_GLOBULE_CRIMSON,  NPC_GLOBULE_DARK},  // Vd+Az+Vm+Pr
    {NPC_GLOBULE_ACIDIC,  NPC_GLOBULE_SHADOWED,NPC_GLOBULE_COBALT,   NPC_GLOBULE_DARK}   // Vd+Ro+Az+Pr
};
struct boss_yorsahj_the_unsleeping : public BossAI
{
    boss_yorsahj_the_unsleeping(Creature* c) : BossAI(c, DATA_YORSAHJ_THE_UNSLEEPING), _isHeroic(false), _lastMask(0) {}
    void Reset() override
    {
        _Reset();
        _isHeroic = me->GetMap()->IsHeroic();
        _lastMask = 0; _waveCount = 0;
        _expected = 0; _reached = 0; _deadCount = 0;
        _waveEntries.clear(); _absorbedEntries.clear(); _globuleGuids.clear();
        me->SetReactState(REACT_AGGRESSIVE);
        RemoveBloodAuras();
        events.Reset();
        summons.DespawnAll();
        if (Map* map = me->GetMap())
        {
            map->SetWorldStateValue(WORLDSTATE_TASTE_RAINBOW_BLACK_YELLOW, 0, false);
            map->SetWorldStateValue(WORLDSTATE_TASTE_RAINBOW_RED_GREEN, 0, false);
            map->SetWorldStateValue(WORLDSTATE_TASTE_RAINBOW_BLACK_BLUE, 0, false);
            map->SetWorldStateValue(WORLDSTATE_TASTE_RAINBOW_PURPLE_YELLOW, 0, false);
        }
    }
    void JustEngagedWith(Unit* who) override
    {
        if (InstanceScript* inst = me->GetInstanceScript())
            if (!inst->CheckRequiredBosses(DATA_YORSAHJ_THE_UNSLEEPING, who ? who->ToPlayer() : nullptr))
            {
                EnterEvadeMode(EVADE_REASON_SEQUENCE_BREAK);
                return;
            }
        BossAI::JustEngagedWith(who);
        Talk(SAY_AGGRO);
        events.ScheduleEvent(EVENT_VOID_BOLT, 8s);
        events.ScheduleEvent(EVENT_CALL_BLOOD, 30s);
        events.ScheduleEvent(EVENT_BERSERK, 600s);
    }
    void JustDied(Unit*) override { _JustDied(); Talk(SAY_DEATH); RemoveBloodAuras(); }
    void KilledUnit(Unit* v) override { if (v->GetTypeId() == TYPEID_PLAYER) Talk(SAY_KILL); }
    void JustSummoned(Creature* s) override
    {
        BossAI::JustSummoned(s);
        switch (s->GetEntry())
        {
            case NPC_GLOBULE_ACIDIC: case NPC_GLOBULE_SHADOWED: case NPC_GLOBULE_GLOWING:
            case NPC_GLOBULE_CRIMSON: case NPC_GLOBULE_COBALT: case NPC_GLOBULE_DARK:
                s->SetReactState(REACT_PASSIVE);
                s->SetSpeed(MOVE_RUN, 0.9f);
                s->GetMotionMaster()->MovePoint(POINT_BOSS, me->GetPositionX(), me->GetPositionY(), me->GetPositionZ());
                _globuleGuids.push_back(s->GetGUID());
                break;
            case NPC_MANA_VOID:
                s->CastSpell(s, SPELL_MANA_VOID_DRAIN, true);
                s->SetReactState(REACT_PASSIVE);
                break;
            case NPC_FORGOTTEN_ONE:
            {
                s->SetReactState(REACT_AGGRESSIVE);
                if (Unit* t = SelectTarget(SELECT_TARGET_RANDOM, 0, 100.0f, true))
                {
                    s->AI()->AttackStart(t);
                    s->GetThreatManager().AddThreat(t, 1000000.0f, nullptr, true, true);
                    s->CastSpell(t, SPELL_FIXATE, true);
                }
                break;
            }
            default: break;
        }
    }
    void SummonedCreatureDies(Creature* s, Unit*) override
    {
        if (s->GetEntry() == NPC_MANA_VOID)
        {
            s->CastSpell(s, SPELL_MANA_DIFFUSION, true);
            s->CastSpell(s, SPELL_MANA_VOID_TRIG, true);
        }
        if (s->GetEntry() == NPC_GLOBULE_ACIDIC || s->GetEntry() == NPC_GLOBULE_SHADOWED || s->GetEntry() == NPC_GLOBULE_GLOWING ||
            s->GetEntry() == NPC_GLOBULE_CRIMSON || s->GetEntry() == NPC_GLOBULE_COBALT || s->GetEntry() == NPC_GLOBULE_DARK)
            DoAction(ACTION_GLOBULE_DIED);
    }
    void DoAction(int32 a) override
    {
        if (a == ACTION_GLOBULE_REACHED)
        {
            if (_reached < _waveEntries.size())
                _absorbedEntries.push_back(_waveEntries[_reached + _deadCount]);
            _reached++;
            if (_reached + _deadCount >= _expected)
                ApplyBuffs();
        }
        else if (a == ACTION_GLOBULE_DIED)
        {
            _deadCount++;
            for (ObjectGuid guid : _globuleGuids)
                if (Creature* g = ObjectAccessor::GetCreature(*me, guid))
                    if (g->IsAlive())
                    {
                        g->SetFlag(UNIT_FIELD_FLAGS, UNIT_FLAG_NON_ATTACKABLE | UNIT_FLAG_NOT_SELECTABLE);
                        g->CastSpell(g, SPELL_FUSING_VAPORS, true);
                        g->SetSpeed(MOVE_RUN, 2.5f);
                        g->GetMotionMaster()->Clear();
                        g->GetMotionMaster()->MovePoint(POINT_BOSS, me->GetPositionX(), me->GetPositionY(), me->GetPositionZ());
                    }
            if (_reached + _deadCount >= _expected)
                ApplyBuffs();
        }
    }
    void UpdateAI(uint32 diff) override
    {
        if (!UpdateVictim()) return;
        events.Update(diff);
        if (me->HasUnitState(UNIT_STATE_CASTING)) return;
        while (uint32 e = events.ExecuteEvent())
        {
            switch (e)
            {
                case EVENT_VOID_BOLT:
                    if (Unit* t = me->GetVictim()) DoCast(t, SPELL_VOID_BOLT);
                    events.ScheduleEvent(EVENT_VOID_BOLT, me->HasAura(SPELL_GLOWING_BLOOD) ? 6s : 10s);
                    break;
                case EVENT_CALL_BLOOD:
                    RemoveBloodAuras();
                    events.CancelEvent(EVENT_SEARING_BLOOD);
                    events.CancelEvent(EVENT_DIGESTIVE_ACID);
                    events.CancelEvent(EVENT_SUMMON_FORGOTTEN);
                    Talk(SAY_GLOBULE);
                    DoCast(me, SPELL_CALL_BLOOD);
                    SummonWave();
                    events.ScheduleEvent(EVENT_CALL_BLOOD, 75s);
                    break;
                case EVENT_SEARING_BLOOD:
                    if (me->HasAura(SPELL_CRIMSON_BLOOD)) { DoCast(me, SPELL_SEARING_BLOOD); events.ScheduleEvent(EVENT_SEARING_BLOOD, 14s); }
                    break;
                case EVENT_DIGESTIVE_ACID:
                    if (me->HasAura(SPELL_ACIDIC_BLOOD)) { DoCast(me, SPELL_DIGESTIVE_ACID); events.ScheduleEvent(EVENT_DIGESTIVE_ACID, 10s); }
                    break;
                case EVENT_SUMMON_FORGOTTEN:
                    if (me->HasAura(SPELL_BLACK_BLOOD))
                    {
                        for (uint32 i = 0; i < 3; ++i)
                        {
                            float a = frand(0.0f, float(M_PI*2.0f)); float d = 8.0f;
                            float x = me->GetPositionX()+d*std::cos(a); float y = me->GetPositionY()+d*std::sin(a); float z = me->GetPositionZ();
                            me->UpdateGroundPositionZ(x,y,z);
                            me->SummonCreature(NPC_FORGOTTEN_ONE,x,y,z,0.0f,TEMPSUMMON_CORPSE_TIMED_DESPAWN,30000);
                        }
                        events.ScheduleEvent(EVENT_SUMMON_FORGOTTEN, 20s);
                    }
                    break;
                case EVENT_BERSERK: Talk(SAY_BERSERK); DoCast(me, SPELL_BERSERK); break;
                default: break;
            }
        }
        DoMeleeAttackIfReady();
    }
private:
    void RemoveBloodAuras()
    {
        me->RemoveAurasDueToSpell(SPELL_ACIDIC_BLOOD);
        me->RemoveAurasDueToSpell(SPELL_SHADOWED_BLOOD);
        me->RemoveAurasDueToSpell(SPELL_GLOWING_BLOOD);
        me->RemoveAurasDueToSpell(SPELL_CRIMSON_BLOOD);
        me->RemoveAurasDueToSpell(SPELL_COBALT_BLOOD);
        me->RemoveAurasDueToSpell(SPELL_COBALT_BLOOD_2);
        me->RemoveAurasDueToSpell(SPELL_BLACK_BLOOD);
        me->RemoveAurasDueToSpell(SPELL_DIGESTIVE_ACID);
        me->RemoveAurasDueToSpell(SPELL_DEEP_CORRUPTION);
        me->RemoveAurasDueToSpell(SPELL_DEEP_CORRUPTION_TRIG);
    }
    void SummonWave()
    {
        uint32 count = _isHeroic ? 4 : 3;
        _expected = count; _reached = 0; _deadCount = 0;
        _waveEntries.clear(); _absorbedEntries.clear(); _globuleGuids.clear();
        uint32 mask = 0; uint32 tries = 0;
        std::vector<uint32> chosen;
        do
        {
            uint32 idx = urand(0, 5);
            chosen.clear(); mask = 0;
            if (_isHeroic)
            {
                for (uint32 i = 0; i < 4; ++i)
                {
                    uint32 e = HEROIC_COMBOS[idx][i];
                    chosen.push_back(e);
                    for (uint32 k = 0; k < 6; ++k) if (GLOBULE_ENTRIES[k] == e) mask |= (1u << k);
                }
            }
            else
            {
                for (uint32 i = 0; i < 3; ++i)
                {
                    uint32 e = NORMAL_COMBOS[idx][i];
                    chosen.push_back(e);
                    for (uint32 k = 0; k < 6; ++k) if (GLOBULE_ENTRIES[k] == e) mask |= (1u << k);
                }
            }
            tries++;
        } while (mask == _lastMask && tries < 10);
        _lastMask = mask;
        _waveEntries = chosen;
        _waveCount++;
        for (uint32 entry : _waveEntries)
        {
            Position pos = GetGlobuleSpawnPos(entry);
            me->UpdateGroundPositionZ(pos.m_positionX, pos.m_positionY, pos.m_positionZ);
            me->SummonCreature(entry, pos.m_positionX, pos.m_positionY, pos.m_positionZ, 0.0f, TEMPSUMMON_CORPSE_DESPAWN, 0);
        }
    }
    Position GetGlobuleSpawnPos(uint32 entry) const
    {
        float angleDeg = 0.0f;
        switch (entry)
        {
            case NPC_GLOBULE_GLOWING:  angleDeg = 225.0f; break;
            case NPC_GLOBULE_ACIDIC:   angleDeg = 135.0f; break;
            case NPC_GLOBULE_CRIMSON:  angleDeg = 90.0f; break;
            case NPC_GLOBULE_SHADOWED: angleDeg = 45.0f; break;
            case NPC_GLOBULE_COBALT:   angleDeg = 0.0f; break;
            case NPC_GLOBULE_DARK:     angleDeg = 315.0f; break;
            default: angleDeg = frand(0.0f, 360.0f); break;
        }
        float angle = angleDeg * float(M_PI) / 180.0f + frand(-0.15f, 0.15f);
        float dist = 35.0f + frand(0.0f, 5.0f);
        Position p;
        p.Relocate(me->GetPositionX() + dist * std::cos(angle), me->GetPositionY() + dist * std::sin(angle), me->GetPositionZ(), 0.0f);
        return p;
    }
    void ApplyBuffs()
    {
        // Taste the Rainbow tracking: each absorbed combo sets required worldstate for 6129
        {
            std::vector<uint32> allAbsorbed;
            // Merge exactly what will be applied as buffs (same logic as toApply below)
            // 1) absorbed via reaching boss
            for (uint32 e : _absorbedEntries) allAbsorbed.push_back(e);
            // 2) fallback remainder not killed
            if (allAbsorbed.size() < _waveEntries.size())
            {
                uint32 waveRemain = _waveEntries.size() > (_reached + _deadCount) ? uint32(_waveEntries.size() - (_reached + _deadCount)) : 0;
                // toApply fallback already covers case allAbsorbed empty; mirror that
                if (allAbsorbed.empty() && !_waveEntries.empty())
                {
                    uint32 applyCount = _expected > _deadCount ? _expected - _deadCount : 0;
                    for (uint32 i = 0; i < applyCount && i < _waveEntries.size(); ++i)
                        if (std::find(allAbsorbed.begin(), allAbsorbed.end(), _waveEntries[i + _deadCount]) == allAbsorbed.end())
                            allAbsorbed.push_back(_waveEntries[i + _deadCount]);
                }
                else
                {
                    for (uint32 i = 0; i < waveRemain; ++i)
                    {
                        uint32 e = _waveEntries[_reached + _deadCount + i];
                        if (std::find(allAbsorbed.begin(), allAbsorbed.end(), e) == allAbsorbed.end())
                            allAbsorbed.push_back(e);
                    }
                }
            }
            bool hasBlack=false, hasYellow=false, hasRed=false, hasGreen=false, hasBlue=false, hasPurple=false;
            for (uint32 e : allAbsorbed)
            {
                if (e==NPC_GLOBULE_DARK) hasBlack=true;
                if (e==NPC_GLOBULE_GLOWING) hasYellow=true;
                if (e==NPC_GLOBULE_CRIMSON) hasRed=true;
                if (e==NPC_GLOBULE_ACIDIC) hasGreen=true;
                if (e==NPC_GLOBULE_COBALT) hasBlue=true;
                if (e==NPC_GLOBULE_SHADOWED) hasPurple=true;
            }
            if (Map* map = me->GetMap())
            {
                if (hasBlack && hasYellow) map->SetWorldStateValue(WORLDSTATE_TASTE_RAINBOW_BLACK_YELLOW, 1, false);
                if (hasRed && hasGreen) map->SetWorldStateValue(WORLDSTATE_TASTE_RAINBOW_RED_GREEN, 1, false);
                if (hasBlack && hasBlue) map->SetWorldStateValue(WORLDSTATE_TASTE_RAINBOW_BLACK_BLUE, 1, false);
                if (hasPurple && hasYellow) map->SetWorldStateValue(WORLDSTATE_TASTE_RAINBOW_PURPLE_YELLOW, 1, false);
            }
        }
        std::vector<uint32> toApply = _absorbedEntries;
        if (toApply.empty() && !_waveEntries.empty())
        {
            uint32 applyCount = _expected > _deadCount ? _expected - _deadCount : 0;
            for (uint32 i = 0; i < applyCount && i < _waveEntries.size(); ++i)
                toApply.push_back(_waveEntries[i + _deadCount]);
        }
        for (uint32 entry : toApply)
        {
            switch (entry)
            {
                case NPC_GLOBULE_ACIDIC:
                    DoCast(me, SPELL_ACIDIC_BLOOD);
                    DoCast(me, SPELL_DIGESTIVE_ACID);
                    events.ScheduleEvent(EVENT_DIGESTIVE_ACID, 8s);
                    break;
                case NPC_GLOBULE_SHADOWED:
                    DoCast(me, SPELL_SHADOWED_BLOOD);
                    DoCast(me, SPELL_DEEP_CORRUPTION);
                    break;
                case NPC_GLOBULE_GLOWING:
                    DoCast(me, SPELL_GLOWING_BLOOD);
                    break;
                case NPC_GLOBULE_CRIMSON:
                    DoCast(me, SPELL_CRIMSON_BLOOD);
                    DoCast(me, SPELL_SEARING_BLOOD);
                    events.ScheduleEvent(EVENT_SEARING_BLOOD, 10s);
                    break;
                case NPC_GLOBULE_COBALT:
                    DoCast(me, SPELL_COBALT_BLOOD);
                    DoCast(me, SPELL_COBALT_BLOOD_2);
                    me->SummonCreature(NPC_MANA_VOID, me->GetPositionX(), me->GetPositionY(), me->GetPositionZ(), 0.0f, TEMPSUMMON_CORPSE_TIMED_DESPAWN, 30000);
                    break;
                case NPC_GLOBULE_DARK:
                    DoCast(me, SPELL_BLACK_BLOOD);
                    for (uint32 i = 0; i < 3; ++i)
                    {
                        float a = frand(0.0f, float(M_PI*2.0f)); float d = 8.0f;
                        float x = me->GetPositionX()+d*std::cos(a); float y = me->GetPositionY()+d*std::sin(a); float z = me->GetPositionZ();
                        me->UpdateGroundPositionZ(x,y,z);
                        me->SummonCreature(NPC_FORGOTTEN_ONE,x,y,z,0.0f,TEMPSUMMON_CORPSE_TIMED_DESPAWN,30000);
                    }
                    events.ScheduleEvent(EVENT_SUMMON_FORGOTTEN, 20s);
                    break;
                default: break;
            }
        }
        _waveEntries.clear(); _absorbedEntries.clear(); _globuleGuids.clear();
    }
    bool _isHeroic; uint32 _lastMask; uint32 _waveCount = 0; uint32 _expected = 0; uint32 _reached = 0; uint32 _deadCount = 0;
    std::vector<uint32> _waveEntries; std::vector<uint32> _absorbedEntries; std::vector<ObjectGuid> _globuleGuids;
};

struct npc_yorsahj_globule : public ScriptedAI
{
    npc_yorsahj_globule(Creature* c) : ScriptedAI(c) {}
    void Reset() override
    {
        me->SetReactState(REACT_PASSIVE);
        me->RemoveFlag(UNIT_FIELD_FLAGS, UNIT_FLAG_NOT_SELECTABLE | UNIT_FLAG_NON_ATTACKABLE);
        // Fusing Vapors aura handled via boss DoAction on death; keep attackable
    }
    void DamageTaken(Unit* /*attacker*/, uint32& /*damage*/) override
    {
        if (me->HealthBelowPct(50))
        {
            // Fusing Vapors 103635: <50% cura 5% vida max dos outros globules ativos
            if (InstanceScript* inst = me->GetInstanceScript())
                if (Creature* boss = inst->GetCreature(DATA_YORSAHJ_THE_UNSLEEPING))
                    if (boss->IsAlive())
                    {
                        // heal other globules by 5% - find via boss summons is complex; fallback: cast visual 103635 self which DBC may handle
                        me->CastSpell(me, SPELL_FUSING_VAPORS, true);
                    }
        }
    }
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
    void UpdateAI(uint32 /*diff*/) override {}
};

struct npc_yorsahj_mana_void : public ScriptedAI
{
    npc_yorsahj_mana_void(Creature* c) : ScriptedAI(c) {}
    void Reset() override
    {
        me->SetReactState(REACT_PASSIVE);
        me->RemoveFlag(UNIT_FIELD_FLAGS, UNIT_FLAG_NOT_SELECTABLE | UNIT_FLAG_NON_ATTACKABLE);
        me->AddAura(SPELL_MANA_VOID_DRAIN, me);
    }
    void JustDied(Unit*) override
    {
        DoCast(me, SPELL_MANA_DIFFUSION);
        DoCast(me, SPELL_MANA_VOID_TRIG);
    }
    void UpdateAI(uint32 /*diff*/) override {}
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
    bool Validate(SpellInfo const* /*spell*/) override { return true; }

    void HandleProc(AuraEffect const* /*aurEff*/, ProcEventInfo& eventInfo)
    {
        // Dossiê 8: cada 5o heal/absorção num jogador detona 89-104k Sombra raid inteira
        // 105171 aplicado em todos jogadores 25s; contador por alvo
        if (!eventInfo.GetActionTarget() || !eventInfo.GetActor())
            return;
        Unit* target = eventInfo.GetActionTarget();
        Unit* healer = eventInfo.GetActor();
        if (!target || !healer)
            return;
        // ignora self-heals tanque dossiê: Death Strike 49998 / Word of Glory 85673 nunca stack
        // Esses spells não disparam proc se filtro DBC excluir; fallback check por SpellId
        if (SpellInfo const* si = eventInfo.GetSpellInfo())
            if (si->Id == 49998 || si->Id == 85673)
                return;
        // Usa stack amount do aura como contador simplificado (blizzlike: aura stack 5 dispara)
        if (Aura* aura = target->GetAura(SPELL_DEEP_CORRUPTION))
        {
            aura->SetStackAmount(aura->GetStackAmount() + 1);
            if (aura->GetStackAmount() >= 5)
            {
                // detona raid
                if (Unit* caster = GetCaster())
                    caster->CastSpell(target, 105173, true); // Deep Corruption explosion (DBC 105173)
                aura->SetStackAmount(0);
                aura->RefreshDuration();
            }
        }
    }

    void Register() override
    {
        OnEffectProc.Register(&spell_yorsahj_deep_corruption::HandleProc, EFFECT_0, SPELL_AURA_DUMMY);
    }
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
