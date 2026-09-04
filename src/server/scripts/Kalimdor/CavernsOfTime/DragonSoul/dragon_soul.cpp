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

#include "ScriptMgr.h"
#include "ScriptedCreature.h"
#include "ScriptedGossip.h"
#include "CreatureAI.h"
#include "Player.h"
#include "InstanceScript.h"
#include "dragon_soul.h"

namespace DragonSoul
{
Position const taxiPortalsPos[] =
{
    { -1743.6478f, -1835.1325f, -220.509f, 4.53f },
    { -1854.2331f, -3068.6586f, -178.339f, 0.46f }
};

uint32 GetPortalForEntry(uint32 entry)
{
    switch (entry)
    {
        case NPC_VALEERA:   return PORTAL_VALEERA;
        case NPC_EIENDORMI: return PORTAL_EIENDORMI;
        default:            break;
    }
    return 0;
}

enum
{
    GOSSIP_MENU_DRAGON_SOUL_TAXI = 13411 // menu de texto definido no DB (gossip_menu). Port do 5.4.8.
};

class npc_dragon_soul_teleport : public CreatureScript
{
public:
    npc_dragon_soul_teleport() : CreatureScript("npc_dragon_soul_teleport") { }

    struct npc_dragon_soul_teleportAI : public ScriptedAI
    {
        npc_dragon_soul_teleportAI(Creature* creature) : ScriptedAI(creature)
        {
            _instance = me->GetInstanceScript();
        }

        bool GossipHello(Player* player) override
        {
            // Drakes so oferecem o taxi quando o boss de destino esta liberado (gate via CheckRequiredBosses)
            if (!_instance || !CanFly(player))
                return false;

            player->PrepareGossipMenu(me, GOSSIP_MENU_DRAGON_SOUL_TAXI, true);
            player->SendPreparedGossip(me);
            return true;
        }

        bool GossipSelect(Player* player, uint32 menuId, uint32 /*gossipListId*/) override
        {
            // So consome a opcao do nosso menu; demais passam pro handler nativo
            if (menuId != GOSSIP_MENU_DRAGON_SOUL_TAXI)
                return false;

            player->PlayerTalkClass->SendCloseGossip();

            // Port do 5.4.8: teleport direto (NearTeleportTo) via gossip, sem waypoints nem summon
            if (CanFly(player))
            {
                uint32 portal = GetPortalForEntry(me->GetEntry());
                player->NearTeleportTo(taxiPortalsPos[portal]);
            }
            // Se o gate fechou entre Hello e Select, apenas fecha o menu (retorna true p/ nao reabrir nativamente)
            return true;
        }

    private:
        bool CanFly(Player* player) const
        {
            switch (me->GetEntry())
            {
                case NPC_VALEERA:
                    return _instance->CheckRequiredBosses(DATA_WARLORD_ZONOZZ, player);
                case NPC_EIENDORMI:
                    return _instance->CheckRequiredBosses(DATA_YORSAHJ_THE_UNSLEEPING, player);
                default:
                    break;
            }
            return false;
        }

        InstanceScript* _instance;
    };

    CreatureAI* GetAI(Creature* creature) const override
    {
        return new npc_dragon_soul_teleportAI(creature);
    }
};
}

void AddSC_dragon_soul()
{
    using namespace DragonSoul;
    new npc_dragon_soul_teleport();
}
