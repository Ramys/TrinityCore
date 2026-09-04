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
Position const taxiTowerPos = { -1789.48291f, -2362.63818f, 47.289059f, 4.638559f };

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
    GOSSIP_MENU_DRAGON_SOUL_TAXI = 13411, // menu ida torre -> boss (forward)
    GOSSIP_MENU_DRAGON_SOUL_RETURN = 13412 // menu volta arena -> torre (retorno apos Zon'ozz+Yor'sahj DONE)
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

        bool IsAtTower() const
        {
            // Torre central Wyrmrest: Z ~47, arenas Z ~-220/-178 -> distancia Z >150 separa
            return me->GetPositionZ() > 0.0f;
        }

        bool CanFlyForward(Player* player) const
        {
            if (!_instance) return false;
            switch (me->GetEntry())
            {
                case NPC_VALEERA:
                    return _instance->CheckRequiredBosses(DATA_WARLORD_ZONOZZ, player);
                case NPC_EIENDORMI:
                    return _instance->CheckRequiredBosses(DATA_YORSAHJ_THE_UNSLEEPING, player);
                default: break;
            }
            return false;
        }

        bool CanReturn() const
        {
            if (!_instance) return false;
            // Retorno so apos ambos Zon'ozz e Yor'sahj DONE (pedido: matar ambos libera portal volta torre)
            return _instance->GetBossState(DATA_WARLORD_ZONOZZ) == DONE
                && _instance->GetBossState(DATA_YORSAHJ_THE_UNSLEEPING) == DONE;
        }

        bool GossipHello(Player* player) override
        {
            if (!_instance)
                return false;

            if (IsAtTower())
            {
                if (!CanFlyForward(player))
                    return false;
                player->PrepareGossipMenu(me, GOSSIP_MENU_DRAGON_SOUL_TAXI, true);
                player->SendPreparedGossip(me);
                return true;
            }
            else
            {
                // Drake reverso na arena -> menu retorno
                if (!CanReturn())
                    return false;
                player->PrepareGossipMenu(me, GOSSIP_MENU_DRAGON_SOUL_RETURN, true);
                player->SendPreparedGossip(me);
                return true;
            }
        }

        bool GossipSelect(Player* player, uint32 menuId, uint32 /*gossipListId*/) override
        {
            if (menuId == GOSSIP_MENU_DRAGON_SOUL_TAXI && IsAtTower())
            {
                player->PlayerTalkClass->SendCloseGossip();
                if (CanFlyForward(player))
                {
                    uint32 portal = GetPortalForEntry(me->GetEntry());
                    player->NearTeleportTo(taxiPortalsPos[portal]);
                }
                return true;
            }
            if (menuId == GOSSIP_MENU_DRAGON_SOUL_RETURN && !IsAtTower())
            {
                player->PlayerTalkClass->SendCloseGossip();
                if (CanReturn())
                    player->NearTeleportTo(taxiTowerPos);
                return true;
            }
            return false;
        }

    private:
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
