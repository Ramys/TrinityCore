/*
 * TrinityCore 4.3.4 - Dragon Soul: Hagara the Stormbinder 55689
 * Port do MoP 5.4.8 (Legends-of-Azeroth boss_hagara.cpp) -> Cata 4.3.4
 * Ref: wowhead cata 55689 Hagara, warcraft.wiki Hagara_the_Stormbinder, Spell.dbc TCP
 * Padrao: struct : public BossAI + RegisterDragonSoulCreatureAI, SpellScript sem PrepareSpellScript
 *
 * Encontro: fases alternadas ice (Frozen Tempest, Binding Crystal 56136, Ice Wave 56104, Icicle 57867)
 *   e lightning (Lightning Storm, Crystal Conductor 56165, Bound Lightning Elemental 56700).
 *   Boss sempre spawnado em 967, gate Blizzlike sequencial por Yor'sahj DONE (JustEngagedWith -> Evade).
 */

#include "dragon_soul.h"
#include "ScriptedCreature.h"
#include "ScriptMgr.h"
#include "SpellScript.h"
#include "SpellAuraEffects.h"
#include "SpellInfo.h"
#include "SpellMgr.h"
#include "InstanceScript.h"
#include "ObjectAccessor.h"
#include "TemporarySummon.h"
#include "Player.h"
#include "Map.h"
#include "Containers.h"
#include <cmath>
#include <list>
#include <set>
#include <queue>
#include <vector>

namespace DragonSoul::Hagara
{
enum ScriptedTexts
{
    SAY_AGGRO     = 0,  // "You cross the Stormbinder! I'll slaughter you all."
    SAY_DEATH     = 1,  // "Cowards! You pack of weakling...dogs..."
    SAY_ICE_WAVE  = 2,  // "You can't outrun the storm." / "Die beneath the ice."
    SAY_ICELANCE  = 3,  // "You face more than my axes, this close." etc
    SAY_ICETOMB   = 4,  // "Stay, pup." / "Hold still."
    SAY_CRYSTAL   = 5,  // "The time I spent binding that, WASTED!" ... (crystal destroyed)
    SAY_LIGHTNING = 6,  // "Suffer the storm's wrath!" ...
    SAY_OVERLOAD  = 7,  // "What are you doing?" ... (electrocution/overload)
    SAY_FEEDBACK  = 8,  // "Aughhhh! Impossible!" (phase end)
    SAY_KILL      = 9,  // "You should have run, dog!" ...
    ANN_OVERLOAD  = 10  // emote anuncio overload
};

enum Spells
{
    SPELL_BERSERK                = 64238,
    SPELL_ICE_LANCE_DUMMY        = 105269, // visual spear
    SPELL_TARGET                 = 105285,
    SPELL_ICE_LANCE_CONE         = 105287,
    SPELL_ICE_LANCE_AOE          = 105298,
    SPELL_ICE_LANCE_SUMMON       = 105297,
    SPELL_ICE_LANCE_MISSILE      = 105313,
    SPELL_ICE_LANCE_DMG          = 105316,
    SPELL_ICY_TOMB_AOE           = 104448,
    SPELL_ICY_TOMB_DUMMY         = 104449,
    SPELL_ICY_TOMB               = 104451,
    SPELL_SHATTERED_ICE          = 105289,
    SPELL_FOCUSED_ASSAULT        = 107851,
    SPELL_FROZEN_TEMPEST         = 105256,
    SPELL_ICICLE                 = 109315,
    SPELL_ICICLE_AURA            = 92201,
    SPELL_ICE_WAVE               = 105265,
    SPELL_CRYSTALLINE_TETHER_1   = 105311,
    SPELL_CRYSTALLINE_OVERLOAD_1 = 105312,
    SPELL_WATERY_ENTRENCHMENT    = 110317,
    SPELL_FROSTFLAKE             = 109325,
    SPELL_FEEDBACK               = 108934,
    SPELL_WATER_SHIELD           = 105409,
    SPELL_LIGHTNING_STORM        = 105465,
    SPELL_LIGHTNING_STORM_DUMMY  = 105467,
    SPELL_CRYSTALLINE_TETHER_2   = 105482,
    SPELL_LIGHTNING_ROD_1        = 105343, // visual
    SPELL_LIGHTNING_ROD_2        = 109180, // visual
    SPELL_OVERLOAD_1             = 105487,
    SPELL_OVERLOAD_2             = 105481, // by elemental
    SPELL_LIGHTNING_CONDUIT_AOE  = 105377,
    SPELL_LIGHTNING_CONDUIT_DMG  = 105369,
    SPELL_LIGHTNING_CONDUIT_DUMMY_2 = 105371,
    SPELL_LIGHTNING_CONDUIT_DUMMY_1 = 105367,
    SPELL_STORM_PILLARS          = 109557,
    SPELL_STORM_PILLAR           = 109541,
    SPELL_HAGARA_LIGHTNING_AXES  = 109670,
    SPELL_HAGARA_FROST_AXES      = 109671
};

enum Events
{
    EVENT_SHATTERED_ICE   = 1,
    EVENT_FOCUSED_ASSAULT = 2,
    EVENT_ICY_TOMB        = 3,
    EVENT_ICE_LANCE       = 4,
    EVENT_FROZEN_TEMPEST_1 = 5,
    EVENT_FROZEN_TEMPEST_2 = 6,
    EVENT_ICICLE          = 7,
    EVENT_ICE_WAVE        = 8,
    EVENT_ICE_WAVE_MOVE   = 9,
    EVENT_FROSTFLAKE      = 10,
    EVENT_ELECTRICAL_STORM_1 = 11,
    EVENT_ELECTRICAL_STORM_2 = 12,
    EVENT_STORM_PILLARS   = 13,
    EVENT_BERSERK         = 14,
    EVENT_WATERY_ENTRENCHMENT = 15,
    EVENT_END_SPECIAL_PHASE  = 16,
    EVENT_OVERLOAD_END       = 17
};

enum MiscData
{
    ACTION_ICE_WAVE_MOVE    = 1,
    DATA_TRAPPED_PLAYER     = 2,
    DATA_ICE_LANCE_GUID     = 3,
    POINT_ICE_WAVE          = 4,
    POINT_ICE_WAVE_MOVE     = 5,
    DATA_CIRCLE_POINT       = 6,
    DATA_MAIN_WAVE          = 7,
    ACTION_CRYSTAL_DIED     = 8,
    DATA_CRYSTAL_OVERLOADED = 9,
    DATA_PHASE              = 10
};

// Plataforma da Hagara (mapeada do MoP, map 967 / zona Foco da Eternidade)
Position const centerPos = { 13587.4f, 13612.0f, 122.43f, 5.93f };

Position const icelancePos[3] =
{
    { 13555.495117f, 13641.369141f, 123.49f, 5.62f },
    { 13561.820313f, 13576.739258f, 123.49f, 0.89f },
    { 13631.335938f, 13604.969727f, 123.49f, 3.05f }
};

Position const frozencrystalPos[4] =
{
    { 13617.5f, 13580.9f, 123.567f, 2.35619f  },
    { 13557.4f, 13643.1f, 123.567f, 5.48033f  },
    { 13557.7f, 13580.7f, 123.567f, 0.802851f },
    { 13617.3f, 13643.5f, 123.567f, 3.94444f  }
};

Position const crystalconductorPos[8] =
{
    { 13587.3f, 13658.6f, 123.567f, 4.66003f },
    { 13541.8f, 13611.3f, 123.567f, 0.0f     },
    { 13587.4f, 13566.8f, 123.567f, 1.48353f },
    { 13633.0f, 13612.1f, 123.567f, 3.14159f },
    // +4 somente heroic 10 (mais conduites)
    { 13566.260742f, 13589.701172f, 123.49f, 0.79f },
    { 13608.689453f, 13589.539063f, 123.49f, 2.31f },
    { 13608.835938f, 13634.269531f, 123.49f, 3.91f },
    { 13566.288086f, 13634.226563f, 123.49f, 5.46f }
};


Position const circlePos[18][5] =
{
    {
        { 13588.195313f, 13560.274414f, 124.480095f, 3.046000f },
        { 13588.815430f, 13566.745117f, 123.483849f, 0.0f      },
        { 13589.292969f, 13571.721680f, 123.483849f, 0.0f      },
        { 13589.770508f, 13576.699219f, 123.483849f, 0.0f      },
        { 13590.247070f, 13581.675781f, 123.417847f, 0.0f      }
    },
    {
        { 13571.882813f, 13563.098633f, 124.480095f, 2.802526f },
        { 13574.044922f, 13569.228516f, 123.483849f, 0.0f      },
        { 13575.708008f, 13573.944336f, 123.483849f, 0.0f      },
        { 13577.371094f, 13578.659180f, 123.483849f, 0.0f      },
        { 13579.034180f, 13583.375000f, 123.052773f, 0.0f      }
    },
    {
        { 13554.680664f, 13572.165039f, 124.480095f, 2.288090f },
        { 13559.579102f, 13576.437500f, 123.483849f, 0.0f      },
        { 13563.346680f, 13579.724609f, 123.483849f, 0.0f      },
        { 13567.115234f, 13583.011719f, 123.483849f, 0.0f      },
        { 13570.882813f, 13586.297852f, 123.483849f, 0.0f      }
    },
    {
        { 13542.881836f, 13585.850586f, 124.480095f, 2.064251f },
        { 13548.606445f, 13588.929688f, 123.483849f, 0.0f      },
        { 13553.009766f, 13591.297852f, 123.483849f, 0.0f      },
        { 13557.413086f, 13593.666016f, 123.483849f, 0.0f      },
        { 13561.817383f, 13596.034180f, 123.218773f, 0.0f      }
    },
    {
        { 13536.680664f, 13603.588867f, 124.480095f, 1.710822f },
        { 13543.117188f, 13604.496094f, 123.483849f, 0.0f      },
        { 13548.068359f, 13605.194336f, 123.483849f, 0.0f      },
        { 13553.019531f, 13605.891602f, 123.483849f, 0.0f      },
        { 13557.970703f, 13606.589844f, 123.035400f, 0.0f      }
    },
    {
        { 13536.618164f, 13620.696289f, 124.480095f, 1.472240f },
        { 13543.086914f, 13620.056641f, 123.483856f, 0.0f      },
        { 13548.062500f, 13619.564453f, 123.483856f, 0.0f      },
        { 13553.038086f, 13619.072266f, 123.483849f, 0.0f      },
        { 13558.013672f, 13618.581055f, 123.228790f, 0.0f      }
    },

    {
        { 13542.865234f, 13637.391602f, 124.480095f, 0.953877f },
        { 13548.166992f, 13633.630859f, 123.483856f, 0.0f      },
        { 13552.245117f, 13630.738281f, 123.483849f, 0.0f      },
        { 13556.323242f, 13627.845703f, 123.483849f, 0.0f      },
        { 13560.402344f, 13624.953125f, 123.192871f, 0.0f      }
    },
    {
        { 13553.818359f, 13651.536133f, 124.480095f, 0.569032f },
        { 13557.320313f, 13646.060547f, 123.483856f, 0.0f      },
        { 13560.014648f, 13641.848633f, 123.483856f, 0.0f      },
        { 13562.708984f, 13637.635742f, 123.483849f, 0.0f      },
        { 13565.403320f, 13633.423828f, 123.483849f, 0.0f      }
    },
    {
        { 13570.151367f, 13660.645508f, 124.480095f, 0.282361f },
        { 13571.962891f, 13654.403320f, 123.483849f, 0.0f      },
        { 13573.355469f, 13649.600586f, 123.483849f, 0.0f      },
        { 13574.749023f, 13644.798828f, 123.483849f, 0.0f      },
        { 13576.141602f, 13639.997070f, 123.194534f, 0.0f      }
    },
    {
        { 13587.694336f, 13663.437500f, 124.480095f, 6.200338f },
        { 13587.156250f, 13656.959961f, 123.483849f, 0.0f      },
        { 13586.743164f, 13651.976563f, 123.483849f, 0.0f      },
        { 13586.329102f, 13646.994141f, 123.483849f, 0.0f      },
        { 13585.915039f, 13642.011719f, 123.132782f, 0.0f      }
    },
    {
        { 13604.433594f, 13660.982422f, 124.480095f, 5.846913f },
        { 13601.686523f, 13655.090820f, 123.483849f, 0.0f      },
        { 13599.574219f, 13650.559570f, 123.483849f, 0.0f      },
        { 13597.460938f, 13646.028320f, 123.483849f, 0.0f      },
        { 13595.348633f, 13641.496094f, 123.442535f, 0.0f      }
    },
    {
        { 13620.228516f, 13651.585938f, 124.480095f, 5.587738f },
        { 13616.063477f, 13646.595703f, 123.483849f, 0.0f      },
        { 13612.860352f, 13642.756836f, 123.483849f, 0.0f      },
        { 13609.656250f, 13638.917969f, 123.483849f, 0.0f      },
        { 13606.453125f, 13635.079102f, 122.912933f, 0.0f      }
    },

    {
        { 13631.908203f, 13638.895508f, 124.480095f, 5.104725f },
        { 13625.902344f, 13636.410156f, 123.483849f, 0.0f      },
        { 13621.282227f, 13634.498047f, 123.483849f, 0.0f      },
        { 13616.662109f, 13632.586914f, 123.483849f, 0.0f      },
        { 13612.041992f, 13630.674805f, 123.483849f, 0.0f      }
    },
    {
        { 13638.326172f, 13621.443359f, 124.480095f, 4.802349f },
        { 13631.852539f, 13620.859375f, 123.483849f, 0.0f      },
        { 13626.873047f, 13620.410156f, 123.483849f, 0.0f      },
        { 13621.892578f, 13619.960938f, 123.483849f, 0.0f      },
        { 13616.913086f, 13619.511719f, 123.314667f, 0.0f      }
    },
    {
        { 13638.371094f, 13604.269531f, 124.480095f, 4.539246f },
        { 13631.968750f, 13605.389648f, 123.483856f, 0.0f      },
        { 13627.042969f, 13606.250977f, 123.483849f, 0.0f      },
        { 13622.118164f, 13607.112305f, 123.483849f, 0.0f      },
        { 13617.192383f, 13607.973633f, 123.031342f, 0.0f      }
    },
    {
        { 13632.013672f, 13586.010742f, 124.480095f, 4.068014f },
        { 13626.817383f, 13589.915039f, 123.483856f, 0.0f      },
        { 13622.819336f, 13592.918945f, 123.483856f, 0.0f      },
        { 13618.822266f, 13595.921875f, 123.483849f, 0.0f      },
        { 13614.825195f, 13598.925781f, 123.286789f, 0.0f      }
    },
    {
        { 13621.313477f, 13572.966797f, 124.480095f, 3.734221f },
        { 13617.682617f, 13578.358398f, 123.483849f, 0.0f      },
        { 13614.890625f, 13582.505859f, 123.483849f, 0.0f      },
        { 13612.097656f, 13586.653320f, 123.483849f, 0.0f      },
        { 13609.304688f, 13590.800781f, 123.393356f, 0.0f      }
    },
    {
        { 13605.115234f, 13563.460938f, 124.480095f, 3.392572f },
        { 13603.500977f, 13569.756836f, 123.483849f, 0.0f      },
        { 13602.258789f, 13574.600586f, 123.483849f, 0.0f      },
        { 13601.017578f, 13579.444336f, 123.483849f, 0.0f      },
        { 13599.775391f, 13584.287109f, 123.296410f, 0.0f      }
    }
};


enum Adds
{
    NPC_FROZEN_TEMPEST        = 55370,
    NPC_BINDING_CRYSTAL       = 56136,
    NPC_ICE_WAVE              = 56104,
    NPC_ICE_LANCE             = 56108,
    NPC_ICY_TOMB              = 55695,
    NPC_ICICLE                = 57867,
    NPC_CRYSTAL_CONDUCTOR     = 56165,
    NPC_BOUND_LIGHTNING_ELEM  = 56700
};

enum Phases
{
    PHASE_INTRO     = 0,
    PHASE_ICE       = 1,
    PHASE_LIGHTNING = 2
};

class boss_hagara_the_stormbinder : public BossAI
{
public:
    boss_hagara_the_stormbinder(Creature* creature) : BossAI(creature, DATA_HAGARA_THE_STORMBINDER)
    {
        Initialize();
    }

    void Initialize()
    {
        circlePosition = 0;
        _phase = PHASE_INTRO;
        _specialPhase = false;
        _crystalCount = 0;
        _icyTombLock = false;
        _tombCount = 0;
        _dummyfrif = false;
        _mainWave = false;
        _frozenTempestTimer = 0;
    }

    void Reset() override
    {
        _Reset();
        Initialize();
        events.Reset();
        summons.DespawnAll();
        me->SetReactState(REACT_DEFENSIVE);
        if (instance)
            instance->SendEncounterUnit(ENCOUNTER_FRAME_DISENGAGE, me);
    }

    void JustEngagedWith(Unit* who) override
    {
        if (instance && !instance->CheckRequiredBosses(DATA_HAGARA_THE_STORMBINDER, who ? who->ToPlayer() : nullptr))
        {
            EnterEvadeMode(EVADE_REASON_SEQUENCE_BREAK);
            return;
        }
        BossAI::JustEngagedWith(who);
        me->SetInCombatWithZone();
        if (instance)
        {
            instance->SetBossState(DATA_HAGARA_THE_STORMBINDER, IN_PROGRESS);
            instance->SendEncounterUnit(ENCOUNTER_FRAME_ENGAGE, me);
        }
        Talk(SAY_AGGRO);
        DoCastSelf(SPELL_BERSERK, true);
        events.ScheduleEvent(EVENT_BERSERK, 8 * MINUTE * IN_MILLISECONDS);
        if (urand(0, 1))
        {
            events.ScheduleEvent(EVENT_FROZEN_TEMPEST_1, 32s);
            DoCastSelf(SPELL_HAGARA_FROST_AXES, true);
        }
        else
        {
            events.ScheduleEvent(EVENT_ELECTRICAL_STORM_1, 32s);
            DoCastSelf(SPELL_HAGARA_LIGHTNING_AXES, true);
        }
        events.ScheduleEvent(EVENT_SHATTERED_ICE, urand(10500, 15000));
        events.ScheduleEvent(EVENT_FOCUSED_ASSAULT, 11s);
        events.ScheduleEvent(EVENT_ICY_TOMB, 20s);
        events.ScheduleEvent(EVENT_ICE_LANCE, 10s);
    }


    void KilledUnit(Unit* victim) override
    {
        if (victim && victim->GetTypeId() == TYPEID_PLAYER)
            Talk(SAY_KILL);
    }

    void JustDied(Unit*) override
    {
        _JustDied();
        Talk(SAY_DEATH);
        if (instance)
            instance->SendEncounterUnit(ENCOUNTER_FRAME_DISENGAGE, me);
    }

    void EnterEvadeMode(EvadeReason why) override
    {
        BossAI::EnterEvadeMode(why);
        events.Reset();
        summons.DespawnAll();
        me->RemoveAurasDueToSpell(SPELL_FROZEN_TEMPEST);
        me->RemoveAurasDueToSpell(SPELL_ICE_LANCE_AOE);
        me->RemoveAurasDueToSpell(SPELL_LIGHTNING_STORM);
        if (instance)
        {
            instance->SetBossState(DATA_HAGARA_THE_STORMBINDER, FAIL);
            instance->SendEncounterUnit(ENCOUNTER_FRAME_DISENGAGE, me);
        }
        _phase = PHASE_INTRO;
    }

    void JustSummoned(Creature* summon) override
    {
        BossAI::JustSummoned(summon);
        switch (summon->GetEntry())
        {
            case NPC_BINDING_CRYSTAL:
            case NPC_CRYSTAL_CONDUCTOR:
                summon->SetReactState(REACT_PASSIVE);
                break;
            default:
                break;
        }
    }

    void SetData(uint32 type, uint32 data) override
    {
        switch (type)
        {
            case DATA_PHASE:
                _phase = data;
                break;
            case DATA_MAIN_WAVE:
                _mainWave = data != 0;
                break;
            case DATA_CRYSTAL_OVERLOADED:
                if (data)
                    events.ScheduleEvent(EVENT_END_SPECIAL_PHASE, 2500ms);
                break;
            default:
                break;
        }
    }

    uint32 GetData(uint32 type) const override
    {
        if (type == DATA_CIRCLE_POINT)
            return circlePosition;
        if (type == DATA_PHASE)
            return _phase;
        return 0;
    }

    void DoAction(int32 action) override
    {
        if (action == ACTION_ICE_WAVE_MOVE)
            events.ScheduleEvent(EVENT_ICE_WAVE_MOVE, 50ms);
        else if (action == ACTION_CRYSTAL_DIED && _crystalCount > 0)
        {
            _crystalCount--;
            if (_crystalCount == 0)
                events.ScheduleEvent(EVENT_END_SPECIAL_PHASE, 2500ms);
        }
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
                case EVENT_BERSERK:
                    DoCastSelf(SPELL_BERSERK, true);
                    break;
                case EVENT_SHATTERED_ICE:
                {
                    Unit* target = SelectTarget(SELECT_TARGET_RANDOM, 1, 0.0f, true);
                    if (!target)
                        target = SelectTarget(SELECT_TARGET_RANDOM, 0, 0.0f, true);
                    if (target)
                        DoCast(target, SPELL_SHATTERED_ICE);
                    events.ScheduleEvent(EVENT_SHATTERED_ICE, 10500ms);
                    break;
                }
                case EVENT_FOCUSED_ASSAULT:
                    DoCastVictim(SPELL_FOCUSED_ASSAULT);
                    events.ScheduleEvent(EVENT_FOCUSED_ASSAULT, 15s);
                    break;
                case EVENT_ICY_TOMB:
                    Talk(SAY_ICETOMB);
                    me->CastSpell(nullptr, SPELL_ICY_TOMB_AOE, CastSpellExtraArgs(SPELLVALUE_MAX_TARGETS, RAID_MODE(2, 5, 2, 6)));
                    events.ScheduleEvent(EVENT_ICY_TOMB, 20s);
                    break;
                case EVENT_ICE_LANCE:
                {
                    UnitList targets;
                    SelectTargetList(targets, 3, SELECT_TARGET_NEAREST, 0.0f, true);
                    if (targets.empty())
                        break;
                    Talk(SAY_ICELANCE);
                    uint8 i = 0;
                    for (UnitList::const_iterator itr = targets.begin(); itr != targets.end(); ++itr)
                    {
                        if (Creature* pLance = me->SummonCreature(NPC_ICE_LANCE, icelancePos[i], TEMPSUMMON_TIMED_DESPAWN, 15s))
                            pLance->AI()->SetGUID((*itr)->GetGUID(), DATA_ICE_LANCE_GUID);
                        ++i;
                    }
                    events.ScheduleEvent(EVENT_ICE_LANCE, 12s);
                    break;
                }

                case EVENT_FROZEN_TEMPEST_1:
                    events.CancelEvent(EVENT_SHATTERED_ICE);
                    events.CancelEvent(EVENT_ICY_TOMB);
                    events.CancelEvent(EVENT_ICE_LANCE);
                    events.CancelEvent(EVENT_FOCUSED_ASSAULT);
                    me->SetReactState(REACT_PASSIVE);
                    me->AttackStop();
                    me->NearTeleportTo(centerPos.GetPositionX(), centerPos.GetPositionY(), centerPos.GetPositionZ(), centerPos.GetOrientation());
                    events.ScheduleEvent(EVENT_FROZEN_TEMPEST_2, 1500ms);
                    break;
                case EVENT_FROZEN_TEMPEST_2:
                {
                    _specialPhase = true;
                    _crystalCount = 4;
                    _phase = PHASE_ICE;
                    for (uint8 i = 0; i < 4; ++i)
                        if (Creature* pCrystal = me->SummonCreature(NPC_BINDING_CRYSTAL, frozencrystalPos[i]))
                            pCrystal->CastSpell(me, SPELL_CRYSTALLINE_TETHER_1);
                    DoCastSelf(SPELL_FROZEN_TEMPEST);
                    events.ScheduleEvent(EVENT_ICE_WAVE, 6s);
                    events.ScheduleEvent(EVENT_ICICLE, 2s);
                    events.ScheduleEvent(EVENT_WATERY_ENTRENCHMENT, 7s);
                    events.ScheduleEvent(EVENT_END_SPECIAL_PHASE, 305s);
                    if (me->GetMap()->IsHeroic())
                        events.ScheduleEvent(EVENT_FROSTFLAKE, urand(2000, 5000));
                    break;
                }
                case EVENT_WATERY_ENTRENCHMENT:
                {
                    if (instance)
                    {
                        Map::PlayerList const& plrList = me->GetMap()->GetPlayers();
                        if (!plrList.isEmpty())
                        {
                            for (Map::PlayerList::const_iterator itr = plrList.begin(); itr != plrList.end(); ++itr)
                                if (Player* player = itr->GetSource())
                                {
                                    if (me->GetDistance(player) <= 23.0f)
                                    {
                                        if (!player->HasAura(SPELL_WATERY_ENTRENCHMENT))
                                            player->CastSpell(player, SPELL_WATERY_ENTRENCHMENT, true);
                                    }
                                    else
                                        player->RemoveAurasDueToSpell(SPELL_WATERY_ENTRENCHMENT);
                                }
                        }
                    }
                    events.ScheduleEvent(EVENT_WATERY_ENTRENCHMENT, 1s);
                    break;
                }
                case EVENT_ICE_WAVE:
                {
                    Talk(SAY_ICE_WAVE);
                    if (Creature* pWave = me->SummonCreature(NPC_ICE_WAVE, me->GetPosition(), TEMPSUMMON_TIMED_DESPAWN, 20s))
                    {
                        pWave->AI()->SetData(DATA_CIRCLE_POINT, 0);
                        pWave->AI()->SetData(DATA_MAIN_WAVE, 1);
                        pWave->GetMotionMaster()->MovePoint(POINT_ICE_WAVE, circlePos[0][0]);
                    }
                    if (Creature* pWave = me->SummonCreature(NPC_ICE_WAVE, me->GetPosition(), TEMPSUMMON_TIMED_DESPAWN, 20s))
                    {
                        pWave->AI()->SetData(DATA_CIRCLE_POINT, 5);
                        pWave->AI()->SetData(DATA_MAIN_WAVE, 1);
                        pWave->GetMotionMaster()->MovePoint(POINT_ICE_WAVE, circlePos[5][0]);
                    }
                    if (Creature* pWave = me->SummonCreature(NPC_ICE_WAVE, me->GetPosition(), TEMPSUMMON_TIMED_DESPAWN, 20s))
                    {
                        pWave->AI()->SetData(DATA_CIRCLE_POINT, 9);
                        pWave->AI()->SetData(DATA_MAIN_WAVE, 1);
                        pWave->GetMotionMaster()->MovePoint(POINT_ICE_WAVE, circlePos[9][0]);
                    }
                    if (Creature* pWave = me->SummonCreature(NPC_ICE_WAVE, me->GetPosition(), TEMPSUMMON_TIMED_DESPAWN, 20s))
                    {
                        pWave->AI()->SetData(DATA_CIRCLE_POINT, 14);
                        pWave->AI()->SetData(DATA_MAIN_WAVE, 1);
                        pWave->GetMotionMaster()->MovePoint(POINT_ICE_WAVE, circlePos[14][0]);
                    }
                    events.ScheduleEvent(EVENT_ICE_WAVE_MOVE, 12s);
                    break;
                }
                case EVENT_ICE_WAVE_MOVE:
                {
                    Talk(SAY_ICE_WAVE);
                    EntryCheckPredicate pred(NPC_ICE_WAVE);
                    summons.DoAction(ACTION_ICE_WAVE_MOVE, pred);
                    break;
                }
                case EVENT_ICICLE:
                {
                    UnitList targets;
                    SelectTargetList(targets, RAID_MODE(3, 7), SELECT_TARGET_RANDOM, 0.0f, true);
                    if (!targets.empty())
                        for (UnitList::const_iterator itr = targets.begin(); itr != targets.end(); ++itr)
                            DoCast((*itr), SPELL_ICICLE, true);
                    events.ScheduleEvent(EVENT_ICICLE, urand(8000, 9000));
                    break;
                }
                case EVENT_FROSTFLAKE:
                    DoCastAOE(SPELL_FROSTFLAKE, true);
                    events.ScheduleEvent(EVENT_FROSTFLAKE, urand(9000, 12000));
                    break;

                case EVENT_ELECTRICAL_STORM_1:
                    events.CancelEvent(EVENT_SHATTERED_ICE);
                    events.CancelEvent(EVENT_ICY_TOMB);
                    events.CancelEvent(EVENT_ICE_LANCE);
                    events.CancelEvent(EVENT_FOCUSED_ASSAULT);
                    me->SetReactState(REACT_PASSIVE);
                    me->AttackStop();
                    me->NearTeleportTo(centerPos.GetPositionX(), centerPos.GetPositionY(), centerPos.GetPositionZ(), centerPos.GetOrientation());
                    events.ScheduleEvent(EVENT_ELECTRICAL_STORM_2, 1500ms);
                    break;
                case EVENT_ELECTRICAL_STORM_2:
                {
                    _specialPhase = true;
                    _phase = PHASE_LIGHTNING;
                    Talk(SAY_LIGHTNING);
                    if (me->GetMap()->IsHeroic())
                    {
                        if (me->GetMap()->Is25ManRaid())
                        {
                            _crystalCount = 4;
                            for (uint8 i = 0; i < 4; ++i)
                                if (Creature* pConductor = me->SummonCreature(NPC_CRYSTAL_CONDUCTOR, crystalconductorPos[i]))
                                    pConductor->CastSpell(me, SPELL_CRYSTALLINE_TETHER_2);
                        }
                        else
                        {
                            _crystalCount = 8;
                            for (uint8 i = 0; i < 4; ++i)
                                if (Creature* pConductor = me->SummonCreature(NPC_CRYSTAL_CONDUCTOR, crystalconductorPos[i + 4]))
                                    pConductor->CastSpell(me, SPELL_CRYSTALLINE_TETHER_2);
                            for (uint8 i = 0; i < 4; ++i)
                                if (Creature* pConductor = me->SummonCreature(NPC_CRYSTAL_CONDUCTOR, crystalconductorPos[i]))
                                    pConductor->CastSpell(me, SPELL_CRYSTALLINE_TETHER_2);
                        }
                    }
                    else
                    {
                        _crystalCount = 4;
                        if (me->GetMap()->Is25ManRaid())
                            for (uint8 i = 0; i < 4; ++i)
                                if (Creature* pConductor = me->SummonCreature(NPC_CRYSTAL_CONDUCTOR, crystalconductorPos[i]))
                                    pConductor->CastSpell(me, SPELL_CRYSTALLINE_TETHER_2);
                        else
                            for (uint8 i = 0; i < 4; ++i)
                                if (Creature* pConductor = me->SummonCreature(NPC_CRYSTAL_CONDUCTOR, crystalconductorPos[i + 4]))
                                    pConductor->CastSpell(me, SPELL_CRYSTALLINE_TETHER_2);
                    }

                    me->SummonCreature(NPC_BOUND_LIGHTNING_ELEM, circlePos[0][3]);

                    DoCastSelf(SPELL_WATER_SHIELD);

                    events.ScheduleEvent(EVENT_END_SPECIAL_PHASE, 305s);
                    if (me->GetMap()->IsHeroic())
                        events.ScheduleEvent(EVENT_STORM_PILLARS, 5s);
                    break;
                }
                case EVENT_STORM_PILLARS:
                    DoCastAOE(SPELL_STORM_PILLARS, true);
                    events.ScheduleEvent(EVENT_STORM_PILLARS, urand(5000, 10000));
                    break;
                case EVENT_END_SPECIAL_PHASE:
                    _crystalCount = 0;
                    summons.DespawnEntry(NPC_CRYSTAL_CONDUCTOR);
                    summons.DespawnEntry(NPC_BOUND_LIGHTNING_ELEM);
                    summons.DespawnEntry(NPC_BINDING_CRYSTAL);
                    SpecialPhaseEnd();
                    break;
                default:
                    break;
            }
        }

        DoMeleeAttackIfReady();
    }


private:
    uint32 circlePosition;
    uint32 _phase;
    bool _specialPhase;
    uint8 _crystalCount;
    bool _mainWave;
    bool _dummyfrif;
    bool _icyTombLock;
    uint8 _tombCount;
    uint32 _frozenTempestTimer;

    void SpecialPhaseEnd()
    {
        _specialPhase = false;
        events.CancelEvent(EVENT_ICICLE);
        events.CancelEvent(EVENT_WATERY_ENTRENCHMENT);
        events.CancelEvent(EVENT_STORM_PILLARS);
        events.CancelEvent(EVENT_FROSTFLAKE);
        events.CancelEvent(EVENT_END_SPECIAL_PHASE);

        me->RemoveAurasDueToSpell(SPELL_CRYSTALLINE_TETHER_1);
        me->RemoveAurasDueToSpell(SPELL_CRYSTALLINE_TETHER_2);
        me->RemoveAurasDueToSpell(SPELL_WATER_SHIELD);
        me->RemoveAurasDueToSpell(SPELL_FROZEN_TEMPEST);
        if (instance)
        {
            instance->DoRemoveAurasDueToSpellOnPlayers(SPELL_WATERY_ENTRENCHMENT);
            instance->DoRemoveAurasDueToSpellOnPlayers(SPELL_LIGHTNING_CONDUIT_DUMMY_1);
            instance->DoRemoveAurasDueToSpellOnPlayers(SPELL_LIGHTNING_CONDUIT_DUMMY_2);
        }

        DespawnCreatures(NPC_ICE_WAVE);
        summons.DespawnEntry(NPC_CRYSTAL_CONDUCTOR);
        summons.DespawnEntry(NPC_BOUND_LIGHTNING_ELEM);
        summons.DespawnEntry(NPC_BINDING_CRYSTAL);

        me->SetReactState(REACT_AGGRESSIVE);
        AttackStart(me->GetVictim());

        DoCastSelf(SPELL_FEEDBACK, true);

        events.ScheduleEvent(EVENT_ICE_LANCE, 12s);
        events.ScheduleEvent(EVENT_ICY_TOMB, 20s);
        events.ScheduleEvent(EVENT_FOCUSED_ASSAULT, 15s);
        events.ScheduleEvent(EVENT_SHATTERED_ICE, urand(20000, 30500));

        if (_phase == PHASE_LIGHTNING)
        {
            events.ScheduleEvent(EVENT_FROZEN_TEMPEST_1, 62s);
            me->RemoveAurasDueToSpell(SPELL_HAGARA_LIGHTNING_AXES);
            DoCastSelf(SPELL_HAGARA_FROST_AXES, true);
        }
        else if (_phase == PHASE_ICE)
        {
            events.ScheduleEvent(EVENT_ELECTRICAL_STORM_1, 62s);
            me->RemoveAurasDueToSpell(SPELL_HAGARA_FROST_AXES);
            DoCastSelf(SPELL_HAGARA_LIGHTNING_AXES, true);
        }
        _phase = PHASE_INTRO;
        Talk(SAY_FEEDBACK);
    }

    void IceWaveMove()
    {
        if (circlePosition >= 17)
            circlePosition = 0;
        if (Creature* pWave = me->SummonCreature(NPC_ICE_WAVE, circlePos[circlePosition][0], TEMPSUMMON_TIMED_DESPAWN, 20s))
        {
            pWave->AI()->SetData(DATA_CIRCLE_POINT, circlePosition);
            pWave->AI()->SetData(DATA_MAIN_WAVE, _mainWave ? 1 : 0);
            pWave->GetMotionMaster()->MovePoint(POINT_ICE_WAVE, circlePos[circlePosition][1]);
        }
        circlePosition++;
    }

    void DespawnCreatures(uint32 entry)
    {
        std::list<Creature*> creatures;
        GetCreatureListWithEntryInGrid(creatures, me, entry, 1000.0f);
        if (creatures.empty())
            return;
        for (std::list<Creature*>::iterator iter = creatures.begin(); iter != creatures.end(); ++iter)
            (*iter)->DespawnOrUnsummon();
    }
};


class npc_hagara_the_stormbinder_ice_wave : public CreatureScript
{
public:
    npc_hagara_the_stormbinder_ice_wave() : CreatureScript("npc_hagara_the_stormbinder_ice_wave") { }

    struct npc_hagara_the_stormbinder_ice_waveAI : public ScriptedAI
    {
        npc_hagara_the_stormbinder_ice_waveAI(Creature* creature) : ScriptedAI(creature)
        {
            me->SetReactState(REACT_PASSIVE);
            circlePoint = 0;
            bDespawn = false;
            bMain = false;
            _instance = me->GetInstanceScript();
            SetCombatMovement(false);
        }

        void MovementInform(uint32 type, uint32 pointId) override
        {
            if (bDespawn)
                return;

            if (type == POINT_MOTION_TYPE)
            {
                if (pointId == POINT_ICE_WAVE_MOVE)
                {
                    if (bMain)
                    {
                        UpdateNextPoint();
                        for (uint8 i = 0; i < 4; ++i)
                        {
                            if (Creature* pWave = me->SummonCreature(NPC_ICE_WAVE, circlePos[circlePoint][i]))
                            {
                                pWave->SetSpeed(MOVE_RUN, 0.8f - 0.1f * i, true);
                                pWave->AI()->SetData(DATA_CIRCLE_POINT, circlePoint);
                                pWave->AI()->SetData(DATA_MAIN_WAVE, ((i == 0) ? 1 : 0));
                                pWave->GetMotionMaster()->MovePoint(POINT_ICE_WAVE_MOVE, circlePos[(circlePoint < 17 ? circlePoint + 1 : 0)][i]);
                            }
                        }
                    }
                    me->DespawnOrUnsummon(500);
                }
            }
        }

        void SetData(uint32 type, uint32 data) override
        {
            if (type == DATA_CIRCLE_POINT)
                circlePoint = (uint8)data;
            else if (type == DATA_MAIN_WAVE)
                bMain = (data != 0);
        }

        void DoAction(int32 action) override
        {
            if (action == ACTION_ICE_WAVE_MOVE)
                me->GetMotionMaster()->MovePoint(POINT_ICE_WAVE_MOVE, circlePos[UpdateNextPoint()][0]);
        }

        void UpdateAI(uint32 /*diff*/) override
        {
            if (bDespawn)
                return;

            if (_instance && _instance->GetBossState(DATA_HAGARA_THE_STORMBINDER) != IN_PROGRESS)
            {
                bDespawn = true;
                me->DespawnOrUnsummon(100);
            }
        }

    private:
        bool bDespawn;
        bool bMain;
        uint8 circlePoint;
        InstanceScript* _instance;

        uint8 UpdateNextPoint()
        {
            circlePoint++;
            if (circlePoint > 17)
                circlePoint = 0;
            return circlePoint;
        }
    };

    CreatureAI* GetAI(Creature* creature) const override
    {
        return GetDragonSoulAI<npc_hagara_the_stormbinder_ice_waveAI>(creature);
    }
};


class npc_hagara_the_stormbinder_frozen_binding_crystal : public CreatureScript
{
public:
    npc_hagara_the_stormbinder_frozen_binding_crystal() : CreatureScript("npc_hagara_the_stormbinder_frozen_binding_crystal") { }

    struct npc_hagara_the_stormbinder_frozen_binding_crystalAI : public ScriptedAI
    {
        npc_hagara_the_stormbinder_frozen_binding_crystalAI(Creature* creature) : ScriptedAI(creature)
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
            me->SetReactState(REACT_PASSIVE);
            _instance = me->GetInstanceScript();
            SetCombatMovement(false);
        }

        void JustDied(Unit* /*killer*/) override
        {
            DoCastSelf(SPELL_CRYSTALLINE_OVERLOAD_1, true);

            if (_instance)
                if (Creature* pHagara = ObjectAccessor::GetCreature(*me, _instance->GetGuidData(DATA_HAGARA_THE_STORMBINDER)))
                {
                    pHagara->RemoveAurasDueToSpell(SPELL_CRYSTALLINE_TETHER_1);
                    pHagara->AI()->DoAction(ACTION_CRYSTAL_DIED);
                }

            me->DespawnOrUnsummon(2000);
        }

    private:
        InstanceScript* _instance;
    };

    CreatureAI* GetAI(Creature* creature) const override
    {
        return GetDragonSoulAI<npc_hagara_the_stormbinder_frozen_binding_crystalAI>(creature);
    }
};

class npc_hagara_the_stormbinder_crystal_conductor : public CreatureScript
{
public:
    npc_hagara_the_stormbinder_crystal_conductor() : CreatureScript("npc_hagara_the_stormbinder_crystal_conductor") { }

    struct npc_hagara_the_stormbinder_crystal_conductorAI : public ScriptedAI
    {
        npc_hagara_the_stormbinder_crystal_conductorAI(Creature* creature) : ScriptedAI(creature)
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
            me->SetReactState(REACT_PASSIVE);
            _instance = me->GetInstanceScript();
            _overloaded = false;
            SetCombatMovement(false);
        }

        void SpellHit(Unit* caster, const SpellInfo* spell) override
        {
            if ((spell->Id == SPELL_OVERLOAD_2 || spell->Id == SPELL_LIGHTNING_CONDUIT_DUMMY_1) && !_overloaded)
            {
                _overloaded = true;
                DoCastSelf(SPELL_LIGHTNING_ROD_2, true);
                Talk(ANN_OVERLOAD);
                _events.ScheduleEvent(EVENT_OVERLOAD_END, 2s);
            }
            else if (spell->Id == SPELL_OVERLOAD_1)
            {
                if (_instance)
                    if (Creature* pHagara = ObjectAccessor::GetCreature(*me, _instance->GetGuidData(DATA_HAGARA_THE_STORMBINDER)))
                        pHagara->AI()->DoAction(ACTION_CRYSTAL_DIED);
            }
        }

        void UpdateAI(uint32 diff) override
        {
            _events.Update(diff);
            while (uint32 e = _events.ExecuteEvent())
            {
                if (e == EVENT_OVERLOAD_END)
                {
                    if (_instance)
                        if (Creature* pHagara = ObjectAccessor::GetCreature(*me, _instance->GetGuidData(DATA_HAGARA_THE_STORMBINDER)))
                            pHagara->AI()->DoAction(ACTION_CRYSTAL_DIED);
                    me->DespawnOrUnsummon();
                }
            }
        }

    private:
        InstanceScript* _instance;
        bool _overloaded;
        EventMap _events;
    };

    CreatureAI* GetAI(Creature* creature) const override
    {
        return GetDragonSoulAI<npc_hagara_the_stormbinder_crystal_conductorAI>(creature);
    }
};


class npc_hagara_the_stormbinder_icy_tomb : public CreatureScript
{
public:
    npc_hagara_the_stormbinder_icy_tomb() : CreatureScript("npc_hagara_the_stormbinder_icy_tomb") { }

    struct npc_hagara_the_stormbinder_icy_tombAI : public ScriptedAI
    {
        npc_hagara_the_stormbinder_icy_tombAI(Creature* creature) : ScriptedAI(creature)
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
            trappedPlayer = ObjectGuid::Empty;
            existenceCheckTimer = 1000;
            SetCombatMovement(false);
        }

        void Reset() override
        {
            me->SetReactState(REACT_PASSIVE);
        }

        void SetGUID(ObjectGuid guid, int32 type) override
        {
            if (type == DATA_TRAPPED_PLAYER)
            {
                trappedPlayer = guid;
                existenceCheckTimer = 1000;
            }
        }

        void JustDied(Unit* /*killer*/) override
        {
            if (Player* player = ObjectAccessor::GetPlayer(*me, trappedPlayer))
            {
                trappedPlayer = ObjectGuid::Empty;
                player->RemoveAurasDueToSpell(SPELL_ICY_TOMB);
            }
            me->DespawnOrUnsummon(800);
        }

        void UpdateAI(uint32 diff) override
        {
            if (!trappedPlayer)
                return;

            if (existenceCheckTimer <= diff)
            {
                Player* player = ObjectAccessor::GetPlayer(*me, trappedPlayer);
                if (!player || player->isDead() || !player->HasAura(SPELL_ICY_TOMB))
                {
                    JustDied(me);
                    me->DespawnOrUnsummon();
                    return;
                }
                existenceCheckTimer = 1000;
            }
            else
                existenceCheckTimer -= diff;
        }

    private:
        ObjectGuid trappedPlayer;
        uint32 existenceCheckTimer;
    };

    CreatureAI* GetAI(Creature* creature) const override
    {
        return GetDragonSoulAI<npc_hagara_the_stormbinder_icy_tombAI>(creature);
    }
};

class npc_hagara_the_stormbinder_ice_lance : public CreatureScript
{
public:
    npc_hagara_the_stormbinder_ice_lance() : CreatureScript("npc_hagara_the_stormbinder_ice_lance") { }

    struct npc_hagara_the_stormbinder_ice_lanceAI : public ScriptedAI
    {
        npc_hagara_the_stormbinder_ice_lanceAI(Creature* creature) : ScriptedAI(creature)
        {
            me->SetFlag(UNIT_FIELD_FLAGS, UNIT_FLAG_NOT_SELECTABLE);
            targetPlayer = ObjectGuid::Empty;
            SetCombatMovement(false);
        }

        void Reset() override
        {
            me->SetReactState(REACT_PASSIVE);
        }

        void SetGUID(ObjectGuid guid, int32 type) override
        {
            if (type == DATA_ICE_LANCE_GUID)
            {
                targetPlayer = guid;
                if (Player* player = ObjectAccessor::FindPlayer(guid))
                    DoCast(player, SPELL_TARGET);
                else
                    me->DespawnOrUnsummon();
            }
        }

        ObjectGuid GetGUID(int32 type) const override
        {
            if (type == DATA_ICE_LANCE_GUID)
                return targetPlayer;
            return ObjectGuid::Empty;
        }

    private:
        ObjectGuid targetPlayer;
    };

    CreatureAI* GetAI(Creature* creature) const override
    {
        return GetDragonSoulAI<npc_hagara_the_stormbinder_ice_lanceAI>(creature);
    }
};

class npc_hagara_the_stormbinder_collapsing_icicle : public CreatureScript
{
public:
    npc_hagara_the_stormbinder_collapsing_icicle() : CreatureScript("npc_hagara_the_stormbinder_collapsing_icicle") { }

    struct npc_hagara_the_stormbinder_collapsing_icicleAI : public ScriptedAI
    {
        npc_hagara_the_stormbinder_collapsing_icicleAI(Creature* creature) : ScriptedAI(creature)
        {
            SetCombatMovement(false);
        }

        void IsSummonedBy(Unit* /*summoner*/) override
        {
            _events.ScheduleEvent(EVENT_ICICLE, 6s);
        }

        void UpdateAI(uint32 diff) override
        {
            _events.Update(diff);
            if (_events.ExecuteEvent())
                DoCastSelf(SPELL_ICICLE_AURA);
        }

    private:
        EventMap _events;
    };

    CreatureAI* GetAI(Creature* creature) const override
    {
        return GetDragonSoulAI<npc_hagara_the_stormbinder_collapsing_icicleAI>(creature);
    }
};


struct spell_hagara_the_stormbinder_icy_tomb_aoe : public SpellScript
{
    void FilterTargets(std::list<WorldObject*>& targets)
    {
        if (!GetCaster() || !GetCaster()->GetVictim())
            return;

        if (targets.size() > 1)
            targets.remove(GetCaster()->GetVictim());
    }

    void HandleScript(SpellEffIndex /*effIndex*/)
    {
        if (!GetCaster() || !GetHitUnit())
            return;

        GetCaster()->CastSpell(GetHitUnit(), SPELL_ICY_TOMB_DUMMY, true);
    }

    void Register() override
    {
        OnObjectAreaTargetSelect.Register(&spell_hagara_the_stormbinder_icy_tomb_aoe::FilterTargets, EFFECT_0, TARGET_UNIT_SRC_AREA_ENEMY);
        OnEffectHitTarget.Register(&spell_hagara_the_stormbinder_icy_tomb_aoe::HandleScript, EFFECT_0, SPELL_EFFECT_DUMMY);
    }
};

struct spell_hagara_the_stormbinder_icy_tomb_dummy : public SpellScript
{
    void HandleScript(SpellEffIndex /*effIndex*/)
    {
        if (!GetCaster() || !GetHitUnit())
            return;

        GetCaster()->CastSpell(GetHitUnit(), SPELL_ICY_TOMB, true);
    }

    void Register() override
    {
        OnEffectHitTarget.Register(&spell_hagara_the_stormbinder_icy_tomb_dummy::HandleScript, EFFECT_0, SPELL_EFFECT_DUMMY);
    }
};

struct spell_hagara_the_stormbinder_icy_tomb : public AuraScript
{
    void OnApply(AuraEffect const* aurEff, AuraEffectHandleModes /*mode*/)
    {
        if (!GetCaster() || !GetUnitOwner())
            return;

        Position pos = GetUnitOwner()->GetPosition();
        if (TempSummon* summon = GetCaster()->SummonCreature(NPC_ICY_TOMB, pos))
            summon->AI()->SetGUID(GetUnitOwner()->GetGUID(), DATA_TRAPPED_PLAYER);
    }

    void Register() override
    {
        OnEffectApply.Register(&spell_hagara_the_stormbinder_icy_tomb::OnApply, EFFECT_0, SPELL_AURA_MOD_STUN, AURA_EFFECT_HANDLE_REAL);
    }
};


struct spell_hagara_the_stormbinder_lightning_conduit : public AuraScript
{
    class AnyPlayerOrCrystalCheck
    {
    public:
        AnyPlayerOrCrystalCheck(WorldObject const* obj, float range) : _obj(obj), _range(range) { }
        bool operator()(Player* u)
        {
            if (u->GetGUID() == _obj->GetGUID())
                return false;
            if (u->HasAura(SPELL_LIGHTNING_CONDUIT_DUMMY_1))
                return false;
            if (!u->IsAlive())
                return false;
            if (!_obj->IsWithinDistInMap(u, _range))
                return false;
            return true;
        }
    private:
        WorldObject const* _obj;
        float _range;
    };

    void HandlePeriodicTick(AuraEffect const* /*aurEff*/)
    {
        if (!GetCaster() || !GetTarget())
            return;

        Creature* hagara = GetCaster()->FindNearestCreature(NPC_HAGARA_THE_STORMBINDER, 200.0f, true);
        if (!hagara || hagara->AI()->GetData(DATA_PHASE) != PHASE_LIGHTNING)
            return;

        GetCaster()->CastSpell(GetTarget(), SPELL_LIGHTNING_CONDUIT_DMG, true);

        std::list<Player*> players;
        AnyPlayerOrCrystalCheck check(GetTarget(), 10.0f);
        Trinity::PlayerListSearcher<AnyPlayerOrCrystalCheck> searcher(GetTarget(), players, check);
        GetTarget()->VisitNearbyObject(10.0f, searcher);

        if (Creature* pCrystal = GetTarget()->FindNearestCreature(NPC_CRYSTAL_CONDUCTOR, 10.0f))
            if (!pCrystal->AI()->GetData(DATA_CRYSTAL_OVERLOADED))
                GetTarget()->CastSpell(pCrystal, SPELL_LIGHTNING_CONDUIT_DUMMY_1, true);

        if (!GetCaster() || !GetTarget())
            return;

        if (!players.empty())
        {
            for (std::list<Player*>::const_iterator itr = players.begin(); itr != players.end(); ++itr)
            {
                GetTarget()->CastSpell((*itr), SPELL_LIGHTNING_CONDUIT_DUMMY_1, true);
                (*itr)->CastSpell(GetTarget(), SPELL_LIGHTNING_CONDUIT_DUMMY_2, true);
            }
        }
    }

    void Register() override
    {
        OnEffectPeriodic.Register(&spell_hagara_the_stormbinder_lightning_conduit::HandlePeriodicTick, EFFECT_1, SPELL_AURA_PERIODIC_DUMMY);
    }
};

} // namespace DragonSoul::Hagara

using namespace DragonSoul::Hagara;

void AddSC_boss_hagara()
{
    using namespace DragonSoul;
    RegisterDragonSoulCreatureAI(boss_hagara_the_stormbinder);
    RegisterCreatureAI(npc_hagara_the_stormbinder_ice_wave);
    RegisterCreatureAI(npc_hagara_the_stormbinder_frozen_binding_crystal);
    RegisterCreatureAI(npc_hagara_the_stormbinder_crystal_conductor);
    RegisterCreatureAI(npc_hagara_the_stormbinder_icy_tomb);
    RegisterCreatureAI(npc_hagara_the_stormbinder_ice_lance);
    RegisterCreatureAI(npc_hagara_the_stormbinder_collapsing_icicle);
    RegisterSpellScript(spell_hagara_the_stormbinder_icy_tomb_aoe);
    RegisterSpellScript(spell_hagara_the_stormbinder_icy_tomb_dummy);
    RegisterAuraScript(spell_hagara_the_stormbinder_icy_tomb);
    RegisterAuraScript(spell_hagara_the_stormbinder_lightning_conduit);
}

