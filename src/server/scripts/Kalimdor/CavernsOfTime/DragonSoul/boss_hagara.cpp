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
    EVENT_END_SPECIAL_PHASE  = 16
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
    boss_hagara_the_stormbinder(Creature* creature) : BossAI(creature, DATA_HAGARA)
    {
        Initialize();
    }

    void Initialize()
    {
        circlePosition = 0;
        _phase = PHASE_INTRO;
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
        BossAI::JustEngagedWith(who);
        me->SetInCombatWithZone();
        if (instance)
        {
            instance->SetBossState(DATA_HAGARA, IN_PROGRESS);
            instance->SendEncounterUnit(ENCOUNTER_FRAME_ENGAGE, me);
        }
        Talk(SAY_AGGRO);
        DoCastSelf(SPELL_BERSERK, true);
        events.ScheduleEvent(EVENT_BERSERK, 8 * MINUTE * IN_MILLISECONDS);
        events.ScheduleEvent(EVENT_SHATTERED_ICE, 16s);
        events.ScheduleEvent(EVENT_FOCUSED_ASSAULT, 20s);
        events.ScheduleEvent(EVENT_ICY_TOMB, 30s);
        events.ScheduleEvent(EVENT_ICE_LANCE, 40s);
    }

