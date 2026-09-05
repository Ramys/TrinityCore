/*
 * This file is part of the TrinityCore Project. See AUTHORS file for Copyright information
 *
 * This program is free software; you can redistribute it and/or modify it
 * under the terms of the GNU General Public License as published by the
 * Free Software Foundation; either version 2 of the License, or (at your
 * option) any later version.
 *
 * This program is distributed in the hope that it will be useful, but WITHOUT
 * ANY WARRANTY; without even the implied warranty of MERCHANTABILITY or
 * FITNESS FOR A PARTICULAR PURPOSE. See the GNU General Public License for
 * more details.
 *
 * You should have received a copy of the GNU General Public License along
 * with this program. If not, see <http://www.gnu.org/licenses/>.
 */

#include "InstanceScript.h"
#include "Player.h"
#include "ScriptMgr.h"
#include "dragon_soul.h"

namespace DragonSoul
{
ObjectData const creatureData[] =
{
    { NPC_MORCHOK,                          DATA_MORCHOK                            },
    { NPC_KOHCROM,                          DATA_KOHCROM                            },
    { NPC_WARLORD_ZONOZZ,                   DATA_WARLORD_ZONOZZ                     },
    { NPC_YORSAHJ_THE_UNSLEEPING,           DATA_YORSAHJ_THE_UNSLEEPING             },
    { NPC_HAGARA_THE_STORMBINDER,           DATA_HAGARA_THE_STORMBINDER             },
    { BOSS_MADNESS_OF_DEATHWING,            DATA_MADNESS_OF_DEATHWING               },
    { NPC_DEATHWING_MADNESS_OF_DEATHWING,   DATA_DEATHWING_MADNESS_OF_DEATHWING     },
    { NPC_THRALL_MADNESS_OF_DEATHWING,      DATA_THRALL_MADNESS_OF_DEATHWING        },
    { NPC_YSERA_MADNESS_OF_DEATHWING,       DATA_YSERA_MADNESS_OF_DEATHWING         },
    { NPC_ALEXSTRASZA_MADNESS_OF_DEATHWING, DATA_ALEXSTRASZA_MADNESS_OF_DEATHWING   },
    { NPC_NOZDORMU_MADNESS_OF_DEATHWING,    DATA_NOZDORMU_MADNESS_OF_DEATHWING      },
    { NPC_KALECGOS_MADNESS_OF_DEATHWING,    DATA_KALECGOS_MADNESS_OF_DEATHWING      },
    { NPC_TAIL_TENTACLE,                    DATA_TAIL_TENTACLE_MADNESS_OF_DEATHWING },
    { 0,                                    0                                       } // END
};

ObjectData const gameobjectData[] =
{
    { 0, 0 } // END
};

DoorData const doorData[] =
{
    { 0, 0, DOOR_TYPE_ROOM } // END
};

class instance_dragon_soul : public InstanceMapScript
{
public:
    instance_dragon_soul() : InstanceMapScript(DSScriptName, 967) { }

    struct instance_dragon_soul_InstanceMapScript : public InstanceScript
    {
        instance_dragon_soul_InstanceMapScript(InstanceMap* map) : InstanceScript(map)
        {
            SetHeaders(DataHeader);
            SetBossNumber(EncounterCount);
            LoadDoorData(doorData);
            LoadObjectData(creatureData, gameobjectData);
            _ultraxionSpawned = false;
        }

        void OnCreatureCreate(Creature* creature) override
        {
            InstanceScript::OnCreatureCreate(creature);

            switch (creature->GetEntry())
            {
                case NPC_MORCHOK:
                case NPC_KOHCROM:
                case NPC_WARLORD_ZONOZZ:
                case NPC_YORSAHJ_THE_UNSLEEPING:
                case NPC_HAGARA_THE_STORMBINDER:
                case NPC_NETHESTRASZ:
                case NPC_VALEERA:
                case NPC_EIENDORMI:
                case NPC_YSERA_MADNESS_OF_DEATHWING:
                case NPC_ALEXSTRASZA_MADNESS_OF_DEATHWING:
                case NPC_NOZDORMU_MADNESS_OF_DEATHWING:
                case NPC_KALECGOS_MADNESS_OF_DEATHWING:
                    creature->setActive(true); // Ugly as fuck but the boss area is just too big...
                    break;
                default:
                    break;
            }
        }

        void SpawnUltraxion()
        {
            if (!instance || !instance->GetMap())
                return;

            // Ultraxion arena on the Wyrmrest summit (map 967).
            // NOTE: coords [-1564,-2369,250.083] need confirmation against WoW DB / MMaps,
            // placeholder derived from the intended 4.3.4 design (summit Z ~250).
            Position ultraxionPos = {-1564.0f, -2369.0f, 250.083f, 3.28f};

            // Summon Ultraxion at the arena
            if (Creature* ultraxion = instance->GetMap()->SummonCreature(NPC_ULTRAXION, ultraxionPos))
            {
                ultraxion->SetReactState(REACT_PASSIVE);
                ultraxion->AI()->EnterEvadeMode();
                _ultraxionSpawned = true;
            }
        }

        // Hook Hagara's death to open the way to Ultraxion (5th boss).
        // BossAI::_JustDied() -> SetBossState(DATA_HAGARA_THE_STORMBINDER, DONE) lands here.
        bool SetBossState(uint32 id, EncounterState state) override
        {
            if (id == DATA_HAGARA_THE_STORMBINDER && state == DONE && !_ultraxionSpawned)
                SpawnUltraxion();
            return InstanceScript::SetBossState(id, state);
        }

        void OnPlayerEnter(Player* player) override
        {
            if (GetBossState(DATA_MADNESS_OF_DEATHWING) == DONE)
                player->CastSpell(player, SPELL_CALM_MAELSTROM_SKYBOX);
        }

        bool CheckRequiredBosses(uint32 bossId, Player const* player = nullptr) const override
        {
            if (_SkipCheckRequiredBosses(player))
                return true;

            switch (bossId)
            {
                case DATA_WARLORD_ZONOZZ:
                    // Blizzlike 4.3.4: Zon'ozz so libera apos Morchok DONE
                    return GetBossState(DATA_MORCHOK) == DONE;
                case DATA_YORSAHJ_THE_UNSLEEPING:
                    // Blizzlike sequencial: Yor'sahj so apos Zon'ozz DONE (2o -> 3o boss DS) - fix portal liberar antes do kill
                    return GetBossState(DATA_WARLORD_ZONOZZ) == DONE;
                case DATA_HAGARA_THE_STORMBINDER:
                    // Blizzlike sequencial: Hagara (4o boss) so apos Yor'sahj DONE
                    // C++ boss_hagara JustEngagedWith -> EnterEvadeMode(EVADE_REASON_SEQUENCE_BREAK) se Yor'sahj != DONE
                    // Ultraxion (5o boss) spawn e hook feito em SetBossState() quando Hagara -> DONE
                    return GetBossState(DATA_YORSAHJ_THE_UNSLEEPING) == DONE;
                default:
                    break;
            }
            return true;
        }

    private:
        bool _ultraxionSpawned;
    };

    InstanceScript* GetInstanceScript(InstanceMap* map) const override
    {
        return new instance_dragon_soul_InstanceMapScript(map);
    }
};
}

void AddSC_instance_dragon_soul()
{
    using namespace DragonSoul;
    new instance_dragon_soul();
}
