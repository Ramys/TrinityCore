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

/*
 * Morchok - Dragon Soul (The Siege of Wyrmrest Temple)
 *
 * Referencia: wowpedia.fandom.com/wiki/Morchok e DOCX "Morchok_Boss_Reference".
 * Segue CRULES.md (Boss/Raid Template + BossAI) e MEMORY_ROOT_CATACLYSM_434.md
 * (namespace DragonSoul::Morchok, EventMap herdado, RegisterDragonSoulCreatureAI).
 *
 * IDs verificados em Wowhead (Cata 4.3.4, sobreviveram ao reuso no retail):
 *   Stomp = 103414 | Crush Armor = 103687 | Resonating Crystal = 103640 |
 *   Resonating Crystal (explosao) = 103494 | Black Blood of the Earth = 103785 | Furious = 103846
 * IDs marcados com @TODO DEVEM ser conferidos no Spell.dbc 4.3.4 (reusados no retail).
 */

#include "dragon_soul.h"
#include "CreatureAI.h"
#include "InstanceScript.h"
#include "Map.h"
#include "Player.h"
#include "ScriptedCreature.h"
#include "ScriptMgr.h"
#include "SpellInfo.h"
#include "TemporarySummon.h"
#include <chrono>

namespace DragonSoul::Morchok

{
// Acao para sincronizar o Kohcrom com o Morchok
constexpr int32 ACTION_SPAWN_KOHCROM = 1;

enum Texts
{
    SAY_INTRO_1                  = 0, // "No mortal shall turn me from my task!"
    SAY_INTRO_2                  = 1, // "Cowards! Weaklings! Come down and fight or I will bring you down!"
    SAY_INTRO_3                  = 2, // "I will turn this tower to rubble, and scatter it across the wastes."
    SAY_INTRO_4                  = 3, // "Wyrmrest will fall. All will be dust."
    SAY_AGGRO                    = 4, // "You seek to halt an avalanche. I will bury you."
    SAY_RESONATING_CRYSTAL       = 5, // "Flee, and die." / "Run, and perish."
    SAY_EARTHS_VENGEANCE         = 6, // "The stone calls... Earth's Vengeance" / "The ground shakes..."
    SAY_SUMMON_KOHCROM           = 7, // "You thought to fight me alone? The earth splits to swallow and crush you."
    SAY_RANDOM_KILL              = 8, // falas aleatorias ao matar um jogador
    SAY_DEATH                    = 9  // fala de morte
};

enum Spells
{
    // Morchok (verificados em Wowhead Cata 4.3.4)
    SPELL_STOMP                           = 103414, // divide dano entre alvos em 25 jardas, dobro nos 2 mais proximos
    SPELL_CRUSH_ARMOR                     = 103687, // somente Normal: -10% armadura, 10 stacks, 120% melee
    SPELL_RESONATING_CRYSTAL              = 103640, // lanca o cristal ressonante proximo a um jogador
    SPELL_RESONATING_CRYSTAL_DAMAGE       = 103494, // explosao: divide dano Shadow entre 3 (7 em 25m) mais proximos
    SPELL_BLACK_BLOOD_OF_THE_EARTH        = 103785, // Nature dmg/s + +100% Nature taken/s (20 stacks)
    SPELL_FURIOUS                         = 103846, // enrage parcial aos 20%: +30% atk speed, +20% dano

    // @TODO: VERIFICAR IDs NO SPELL.DBC 4.3.4 (reusados no retail atual)
    SPELL_THE_EARTH_CONSUMES_YOU          = 103558, // @TODO puxa jogadores + 5% HP/s por 5s
    SPELL_EARTHS_VENGEANCE                = 103548, // @TODO invoca pilares de rocha (abrigo)
    SPELL_EARTH_SHATTERING                = 103694, // @TODO Heroico: a cada 3o Stomp, dano em toda a raid
    SPELL_SUMMON_KOHCROM                  = 104161, // @TODO Heroico: invoca Kohcrom aos 90%
    SPELL_KOHCROM_VISUAL                  = 103807, // @TODO visual de separacao do gemeo
    SPELL_RESONATING_CRYSTAL_SUMMON       = 103641  // @TODO efeito que invoca a criatura do cristal
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
    EVENT_HARD_ENRAGE
};

enum Phases
{
    PHASE_NORMAL          = 1,
    PHASE_BLACK_BLOOD
};

constexpr std::chrono::seconds STOMP_INTERVAL(25);        // entre stomps
constexpr uint8  CRYSTALS_BEFORE_BLOOD = 2;               // 2 ciclos (Stomp+Crystal) antes da fase Black Blood
constexpr std::chrono::seconds BLACK_BLOOD_DURATION(12);  // tempo de canalizacao do sangue negro
constexpr std::chrono::minutes HARD_ENRAGE_TIME(7);       // enrage fixo de 7 minutos


struct boss_morchok : public BossAI
{
    boss_morchok(Creature* creature) : BossAI(creature, DATA_MORCHOK),
        _isKohcrom(creature->GetEntry() == NPC_KOHCROM)
    {
        Initialize();
    }

    void Initialize()
    {
        _phase           = PHASE_NORMAL;
        _stompCount      = 0;
        _crystalCount    = 0;
        _furious         = false;
        _kohcromSpawned  = false;
        _inBlackBlood    = false;
        _twin            = nullptr;
        _isHeroic        = me->GetMap()->IsHeroic();
    }

    void Reset() override
    {
        _Reset();
        Initialize();
        events.SetPhase(PHASE_NORMAL);
    }

    void JustEngagedWith(Unit* who) override
    {
        BossAI::JustEngagedWith(who);
        instance->SendEncounterUnit(ENCOUNTER_FRAME_ENGAGE, me);

        if (!_isKohcrom)
            Talk(SAY_AGGRO);

        events.SetPhase(PHASE_NORMAL);
        events.ScheduleEvent(EVENT_STOMP, 8s, 0, PHASE_NORMAL);
        events.ScheduleEvent(EVENT_RESONATING_CRYSTAL, 14s, 0, PHASE_NORMAL);
        events.ScheduleEvent(EVENT_HARD_ENRAGE, HARD_ENRAGE_TIME, 0, PHASE_NORMAL);

        // Crush Armor so existe no modo Normal (DOCX 3.2)
        if (!_isHeroic)
            events.ScheduleEvent(EVENT_CRUSH_ARMOR, 10s, 0, PHASE_NORMAL);

        DoZoneInCombat();
    }

    void JustDied(Unit* /*killer*/) override
    {
        _JustDied();
        instance->SendEncounterUnit(ENCOUNTER_FRAME_DISENGAGE, me);
        Talk(SAY_DEATH);

        // Kohcrom compartilha o encontro: matar um encerra o outro
        if (Creature* twin = GetTwin())
            Unit::Kill(me, twin, false);

        if (!_isKohcrom && instance)
            instance->SetBossState(DATA_MORCHOK, DONE);
    }

    void EnterEvadeMode(EvadeReason why) override
    {
        instance->SendEncounterUnit(ENCOUNTER_FRAME_DISENGAGE, me);
        if (Creature* twin = GetTwin())
            twin->AI()->EnterEvadeMode(why);
        BossAI::EnterEvadeMode(why);
    }

    void JustSummoned(Creature* summon) override
    {
        if (summon->GetEntry() == NPC_RESONATING_CRYSTAL)
        {
            summon->SetReactState(REACT_PASSIVE);
            _summons.Summon(summon);
        }
    }


    void DamageTaken(Unit* /*attacker*/, uint32& damage) override
    {
        if (me->HealthBelowPctDamaged(20, damage) && !_furious)
        {
            DoCastSelf(SPELL_FURIOUS);
            _furious = true;
        }

        // Heroico: aos 90% de vida, Morchok se divide e cria Kohcrom
        if (_isHeroic && !_isKohcrom && !_kohcromSpawned && me->HealthBelowPctDamaged(90, damage))
        {
            _kohcromSpawned = true;
            Talk(SAY_SUMMON_KOHCROM);
            DoCastSelf(SPELL_KOHCROM_VISUAL);
            if (Creature* kohcrom = me->SummonCreature(NPC_KOHCROM, *me, TEMPSUMMON_MANUAL_DESPAWN, 0))
            {
                _twin = kohcrom;
                kohcrom->AI()->DoAction(ACTION_SPAWN_KOHCROM);
                kohcrom->SetHealth(me->GetHealth());
            }
        }

        // Kohcrom replica o dano; sincroniza a vida dos gemeos
        if (Creature* twin = _twin)
            twin->SetHealth(me->GetHealth());
    }

    void DoAction(int32 action) override
    {
        if (action == ACTION_SPAWN_KOHCROM)
        {
            _isKohcrom = true;
            if (Creature* mor = instance ? instance->GetCreature(NPC_MORCHOK) : nullptr)
                _twin = mor;
            if (Player* target = me->SelectNearestPlayer(100.0f))
                AttackStart(target);
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
                case EVENT_STOMP:
                {
                    if (_inBlackBlood)
                        break;

                    // Heroico: a cada 3o Stomp torna-se Earth Shattering (raide inteira)
                    if (_isHeroic && (_stompCount > 0 && _stompCount % 3 == 2))
                        DoCastSelf(SPELL_EARTH_SHATTERING);
                    else
                        DoCastSelf(SPELL_STOMP);

                    ++_stompCount;
                    events.Repeat(STOMP_INTERVAL);
                    break;
                }
                case EVENT_CRUSH_ARMOR:
                {
                    if (Unit* victim = me->GetVictim())
                        DoCast(victim, SPELL_CRUSH_ARMOR);
                    events.Repeat(12s);
                    break;
                }
                case EVENT_RESONATING_CRYSTAL:
                {
                    if (_inBlackBlood)
                        break;

                    Talk(SAY_RESONATING_CRYSTAL);
                    if (Unit* target = SelectTarget(SELECT_TARGET_RANDOM, 0, 100.0f, true))
                        DoCast(target, SPELL_RESONATING_CRYSTAL);

                    if (++_crystalCount >= CRYSTALS_BEFORE_BLOOD)
                    {
                        _crystalCount = 0;
                        _inBlackBlood = true;
                        // Cancela os eventos normais pendentes para evitar duplicacao
                        events.CancelEvent(EVENT_STOMP);
                        events.CancelEvent(EVENT_CRUSH_ARMOR);
                        events.CancelEvent(EVENT_RESONATING_CRYSTAL);
                        events.SetPhase(PHASE_BLACK_BLOOD);
                        events.ScheduleEvent(EVENT_THE_EARTH_CONSUMES_YOU, 2s, 0, PHASE_BLACK_BLOOD);
                    }
                    else
                    {
                        events.Repeat(STOMP_INTERVAL);
                    }
                    break;
                }
                case EVENT_THE_EARTH_CONSUMES_YOU:
                {
                    Talk(SAY_EARTHS_VENGEANCE);
                    DoCastSelf(SPELL_THE_EARTH_CONSUMES_YOU);
                    events.ScheduleEvent(EVENT_EARTHS_VENGEANCE, 1s, 0, PHASE_BLACK_BLOOD);
                    break;
                }
                case EVENT_EARTHS_VENGEANCE:
                {
                    DoCastSelf(SPELL_EARTHS_VENGEANCE);
                    events.ScheduleEvent(EVENT_BLACK_BLOOD, 1s, 0, PHASE_BLACK_BLOOD);
                    break;
                }
                case EVENT_BLACK_BLOOD:
                {
                    DoCastSelf(SPELL_BLACK_BLOOD_OF_THE_EARTH);
                    events.ScheduleEvent(EVENT_BLACK_BLOOD_END, BLACK_BLOOD_DURATION, 0, PHASE_BLACK_BLOOD);
                    break;
                }
                case EVENT_BLACK_BLOOD_END:
                {
                    _inBlackBlood = false;
                    events.SetPhase(PHASE_NORMAL);
                    // Ao terminar o sangue, Morchok da um Stomp imediato (DOCX 3.7)
                    events.ScheduleEvent(EVENT_STOMP, 1s, 0, PHASE_NORMAL);
                    events.ScheduleEvent(EVENT_RESONATING_CRYSTAL, 7s, 0, PHASE_NORMAL);
                    break;
                }
                case EVENT_HARD_ENRAGE:
                {
                    // Enrage fixo: dizima a raide
                    Map::PlayerList const& players = me->GetMap()->GetPlayers();
                    for (Map::PlayerList::const_iterator it = players.begin(); it != players.end(); ++it)
                        if (Player* player = it->GetSource())
                            if (player->IsAlive())
                                Unit::Kill(me, player, false);
                    break;
                }
                default:
                    break;
            }
        }

        DoMeleeAttackIfReady();
    }


private:
    Creature* GetTwin() const
    {
        return _twin;
    }

    bool _isKohcrom;
    bool _isHeroic;
    uint8 _phase;
    uint32 _stompCount;
    uint8 _crystalCount;
    bool _furious;
    bool _kohcromSpawned;
    bool _inBlackBlood;
    Creature* _twin;
};

void AddSC_boss_morchok()
{
    using namespace DragonSoul;
    using namespace DragonSoul::Morchok;
    RegisterDragonSoulCreatureAI(boss_morchok);
}

    }
