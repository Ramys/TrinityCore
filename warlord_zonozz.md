# Warlord Zon'ozz — Boss Reference (Cataclysm Classic / Dragon Soul)

> **Fonte principal:** <https://www.wowhead.com/cata/npc=55308/warlord-zonozz>
> **Boss do encounter #4 do raid Dragon Soul**, logo após Yor'sahj o Adormecido e antes de Hagara, a Tempestária.
>
> **Nota de idioma:** as descrições, nomes e IDs de spells são mantidos em inglês (idioma canônico do WoW e usados pelo seu AI agent). Texto explicativo em português.

---

## 1. Visão Geral do Boss

| Atributo                  | Valor                                                                                          |
|---------------------------|------------------------------------------------------------------------------------------------|
| **Nome**                  | Warlord Zon'ozz                                                                                |
| **NPC ID**                | `55308`                                                                                        |
| **Tipo**                  | Humanoid (Faceless One)                                                                       |
| **Level**                 | ?? (Boss) — Level 88 em escala técnica                                         |
| **Raid / Posição**        | Dragon Soul → 4º encontro (The Siege of Wyrmrest Temple)                                       |
| **Facção**                | Hostil a ambas as facções (servo de N'Zoth)                                                    |
| **Lore**                  | Warlord faceless que guerreou contra as forças de C'thun e Yogg-Saron há eras. Servo do Deus Antigo N'Zoth, liberado por Deathwing. |
| **Dificuldades**          | Raid Finder (10), Normal 10, Normal 25, Heroic 10, Heroic 25                                   |
| **Berserk**               | ~6 minutos (mata o raid após a 4ª fase negra em grupos com DPS abaixo da curva) |

---

## 2. Estrutura do Encounter

O combate tem **2 fases alternantes** que se repetem até o boss morrer:

1. **Phase 1 — Ping-Pong / Maw of Go'rath:** Zon'ozz invoca um Orbe (Void of the Unmaking) que deve ser ricocheteado entre grupos de jogadores antes de atingir o boss.
2. **Phase 2 — Black Blood Phase (Dark Phase):** Disparada quando o orbe atinge o boss. Zon'ozz fica vulnerável (+5% dano recebido por bounce acumulado) e o raid toma dano massivo. Em Heroico, surgem tentáculos (Eye of Go'rath, Flails, Claw of Go'rath).

O boss nunca morre se você não entrar na Phase 2 — o buff `Focused Anger` (104543) acumula indefinidamente, matando o tank se a Phase 1 se prolongar demais.

---

## 3. Abilities — Phase 1 (Ping-Pong)

> Spell IDs extraídos diretamente das páginas individuais do Wowhead.
> Valores de dano são os do **Normal 10 / Normal 25** (o tooltip do Wowhead mostra o valor 10-player). Para Heroic, multiplique aproximadamente por 2x.

### 3.1 Focused Anger — `spell=104543`

| Campo              | Valor                                                  |
|--------------------|--------------------------------------------------------|
| **ID**             | 104543                                                 |
| **Tipo**           | Buff do boss (passivo, stacks)                          |
| **Icon**           | `spell_shadow_unholyfrenzy`                            |
| **Cast time**      | Instant                                                |
| **Cooldown**       | Aplicado periodicamente (tick ~6s em média)            |
| **Stacks**         | Sim — acumula indefinidamente                          |
| **Efeito**         | +20% Physical damage done e +5% attack speed por stack |
| **Dispellável**    | Não                                                    |
| **Tooltip**        | *Physical damage increased by 20%. Attack speed increased by 5%.* |

**Mecânica:** Zon'ozz ganha esse buff continuamente durante a Phase 1. É o "enrage soft" — após ~4-5 stacks o dano no tank se torna insustentável, forçando o grupo a entregar o orbe ao boss.

---

### 3.2 Psychic Drain — `spell=104322`

| Campo              | Valor                                                                            |
|--------------------|----------------------------------------------------------------------------------|
| **ID**             | 104322                                                                           |
| **Tipo**           | Cone frontal de 30° (Shadow damage)                                              |
| **Icon**           | `ability_rogue_shadowstep`                                                       |
| **Cast time**      | Instant                                                                           |
| **Range**          | 100 yd (na prática o cone tem ~30-40 yd de alcance)                              |
| **Cooldown**       | ~12-15s (não tem cooldown exato no tooltip; está atrelado à AI do boss)          |
| **Dano (N10/N25)** | **166.500 a 193.500** Shadow damage                                              |
| **Leech**          | Zon'ozz se cura em **10x o dano causado** (ou seja, ~1,8M-2M de heal por cast)   |
| **Dispellável**    | Não                                                                              |
| **Mitigação**     | Reduzido por **Mortal Strike-style effects** (−healing received funciona no leech) |

**Mecânica:** Cone frontal em quem o boss está mirando. O tank deve virar o boss **fora do raid**. Mais de um tank posicionado incorretamente resulta em wipe imediato. MS-debuffs (Warrior, Hunter devilsaur, Rogue) reduzem drasticamente o heal do boss.

---

### 3.3 Disrupting Shadows — `spell=103434`

| Campo                | Valor                                                                                       |
|----------------------|---------------------------------------------------------------------------------------------|
| **ID**               | 103434                                                                                      |
| **Tipo**             | Magic debuff em alvos aleatórios (3 alvos simultâneos em 10m; 8 em 25m)                    |
| **Icon**             | `spell_shadow_shadowfury`                                                                   |
| **Cast time**        | Instant                                                                                     |
| **Cooldown**         | 3 sec (cooldown base)                                                                       |
| **Dano por tick**    | **42.099 a 48.926** Shadow damage a cada **2 segundos**                                    |
| **Knockback quando dispelado** | Em dificuldades non-LFR, dispelar causa **63.917 a 74.282** Shadow damage + knockback |
| **Tipo de aura**     | Magic (dispellável por Priest/Paladin/Mage/etc)                                            |
| **Duração**          | Enquanto não for dispelado                                                                  |
| **Tooltip buff**     | *Magic* — Deals 42.099 to 48.926 Shadow damage every 2 seconds.                             |

**Mecânica crítica:** NÃO dispelar aleatoriamente — o knockback pode arremessar jogadores no orbe (causando bounce extra e wipe). Só dispelar quando o jogador estiver topped e longe do orbe. Em LFR, o knockback é desativado.

---

### 3.4 Void of the Unmaking (summon do Orbe) — `spell=103571`

| Campo              | Valor                                                  |
|--------------------|--------------------------------------------------------|
| **ID**             | 103571                                                 |
| **NPC ID do orbe** | `55334` (Void of the Unmaking)                         |
| **Icon**           | `trade_engineering`                                    |
| **Cast time**      | Instant                                                |
| **Range**          | 40 yd                                                  |
| **Cooldown base**  | **8 segundos** (mas o spawn real entre phases depende do nº de bounces anteriores) |
| **Mecânica**       | Invoca o orbe **à frente do boss**; o orbe se move em linha reta na direção oposta ao boss, ricocheteando em jogadores |

**Regra de spawn entre fases:** menos bounces = mais tempo até o próximo orbe; mais bounces = orbe reaparece quase imediatamente após Phase 2. Por isso, 5 bounces é o número "ideal" para sincronizar cooldowns de healing.

---

### 3.5 Void Diffusion (buff do orbe por bounce) — `spell=106836`

| Campo              | Valor                                                                |
|--------------------|----------------------------------------------------------------------|
| **ID**             | 106836                                                               |
| **Aplicado em**    | O **orbe** (NPC 55334), a cada bounce num jogador                    |
| **Icon**           | `inv_misc_volatileshadow`                                            |
| **Range**          | 20 yd                                                                |
| **Stacks**         | Sim — +20% damage dealt por stack                                    |
| **Tooltip buff**   | *Damage dealt increased by 20%.*                                     |

**Mecânica:** Cada bounce aumenta o dano do próximo impacto do orbe em 20% (acumulativo). Quando o orbe atinge o boss, ele causa dano massivo ao raid dividido igualmente (ver 103527). Mais bounces = mais dano ao raid na transição, mas mais vulnerability no boss (+5% damage taken por bounce).

---

### 3.6 Void Diffusion (impacto no boss / raid damage) — `spell=103527`

| Campo                  | Valor                                                                                          |
|------------------------|------------------------------------------------------------------------------------------------|
| **ID**                 | 103527                                                                                         |
| **Icon**               | `inv_misc_volatileshadow`                                                                      |
| **Range**              | 20 yd                                                                                          |
| **Cast time**          | Instant                                                                                        |
| **Cooldown**           | 5 sec                                                                                          |
| **Dano**               | **807.300 Shadow damage dividido igualmente** entre todos os jogadores próximos               |
| **LFR mode**           | Dano base reduzido para **50.000**                                                             |
| **Buff aplicado ao raid** | *Shadow damage taken increased by 180000%* — dura ~1-2s, força stack imediato                  |
| **Buff aplicado ao boss** | +5% damage taken por bounce que o orbe acumulou (efetivamente o "damage amplification" da Phase 2) |

**Mecânica:** Quando o orbe atinge o boss (após N bounces), o raid toma 807.300 de dano dividido. Em 10-man isso é ~80.730 por jogador (1 bounce), crescendo com stacks do orbe. **Este é o trigger da Phase 2.**

---

## 4. Abilities — Phase 2 (Black Blood Phase)

> Disparada quando o orbe atinge o boss. Zon'ozz fica "vulnerável" e o raid toma dano massivo por ~15-30s.

### 4.1 Black Blood of Go'rath — `spell=104378` (raid aura principal)

| Campo              | Valor                                                                 |
|--------------------|-----------------------------------------------------------------------|
| **ID**             | 104378                                                                |
| **Icon**           | `ability_rogue_slaughterfromtheshadows`                               |
| **Tipo**           | Raid-wide pulsing aura (aplicada em todos)                            |
| **Cast time**      | Instant                                                               |
| **Duração**        | 30 segundos                                                           |
| **Dano por tick**  | **15.210 a 15.990** a cada **1 segundo** (~16k/s no raid inteiro)     |
| **Dispellável**    | Não                                                                   |
| **Tooltip buff**   | *Deals 15.210 to 15.990 damage every 1 second.* *(30 seconds remaining)* |

**Mecânica:** Este é o dano principal da Phase 2 — exige raid CDs (Tranquility, Spirit Link, Aura Mastery, Power Word: Barrier, Healing Tide etc) coordenados. Em grupos sub-370 ilvl, é a principal causa de wipe.

---

### 4.2 Black Blood of Go'rath — `spell=104377` (versão de NPC/trash)

| Campo              | Valor                                  |
|--------------------|----------------------------------------|
| **ID**             | 104377                                 |
| **Icon**           | `ability_rogue_slaughterfromtheshadows` |
| **Dano**           | **3.220** a cada **2 segundos**         |
| **Cast time**      | Instant                                |
| **Observação**     | Versão reduzida — provavelmente usada em trash/mobs no ambiente, ou versão alternativa da aura em 25-man (não confirmado) |

---

### 4.3 Black Blood Eruption — `spell=108794`

| Campo              | Valor                                                                                |
|--------------------|--------------------------------------------------------------------------------------|
| **ID**             | 108794                                                                               |
| **Icon**           | `ability_vehicle_oiljets`                                                            |
| **Range**          | Unlimited                                                                            |
| **Cast time**      | Instant                                                                              |
| **Dano**           | **119.400 a 120.600** Shadow damage + **knockback no ar**                             |
| **Trigger**        | Disparado quando o **Void of the Unmaking** atinge a borda externa do Maw of Go'rath |

**Mecânica:** Causado por posicionamento incorreto do orbe — se ele escapar para fora da área, todo o raid toma 120k + é arremessado no ar (quase sempre wipe). Mantenha o orbe no centro da arena.

---

### 4.4 Black Blood Eruption (com slow) — `spell=108799`

| Campo              | Valor                                                          |
|--------------------|----------------------------------------------------------------|
| **ID**             | 108799                                                         |
| **Icon**           | `ability_vehicle_oiljets`                                      |
| **Dano**           | **119.400 a 120.600** Shadow damage + **knockback no ar**      |
| **Slow**           | Movement speed reduzido em **75%** por 3 segundos             |
| **Aplicado por**   | NPC 55334 (Void of the Unmaking) quando toca jogadores         |

---

## 5. Abilities — Heroic (Tentáculos da Phase 2)

> Em Heroic, a Phase 2 adiciona **adds/tentáculos** que precisam ser mortos rapidamente. Cada tentáculo morto reduz 1 stack do debuff **Darkness** (109413), que é o verdadeiro killer da fase.

### 5.1 Tantrum — `spell=103953` (transição P1→P2)

| Campo              | Valor                                       |
|--------------------|---------------------------------------------|
| **ID**             | 103953                                      |
| **Icon**           | `trade_engineering`                         |
| **Tipo**           | Channel                                     |
| **Duração**        | **10 segundos** (channel)                   |
| **Mecânica**       | Zon'ozz "entra em colapso" e inicia a Phase 2; visual de animação destrambelhada |

Trigger: quando o orbe atinge o boss, Zon'ozz casta Tantrum por 10s, depois a Phase 2 realmente começa (aura 104378 aplicada, tentáculos spawnam em Heroic).

---

### 5.2 Darkness — `spell=109413`

| Campo              | Valor                                                                                       |
|--------------------|---------------------------------------------------------------------------------------------|
| **ID**             | 109413                                                                                      |
| **Icon**           | `ability_creature_poison_02`                                                                |
| **Tipo**           | Raid-wide debuff (Heroic only)                                                              |
| **Range**          | 150 yd (cobre a arena inteira)                                                              |
| **Stacks iniciais**| **8 stacks**                                                                                |
| **Dano por tick**  | ~**31.000** a cada 2s (8 stacks) — reduzido em ~4.400 por stack removido                    |
| **Redução de stack**| Cada tentáculo morto remove 1 stack                                                         |
| **Mecânica**       | Este é o verdadeiro killer da Phase 2 Heroic — não os tentáculos em si                      |

**Estratégia Heroic:** priorize Flails (2,4M HP) > Eyes (653k HP) > Claw. Quanto mais tentáculos você matar, menor o dano do Darkness no raid.

---

### 5.3 Eye of Go'rath → Shadow Gaze — `spell=109391`

| Campo              | Valor                                                            |
|--------------------|------------------------------------------------------------------|
| **ID**             | 109391                                                           |
| **Icon**           | `inv_misc_eye_03`                                                |
| **Cast time**      | 3 segundos                                                       |
| **Range**          | 100 yd                                                           |
| **Dano**           | **21.375 a 23.625** Shadow damage em um jogador aleatório        |
| **Dispellável**    | Não                                                              |
| **Trigger**        | Cast pelos olhos de tentáculo que spawnam na Phase 2 Heroic      |

**Dica Heroic (Zapph):** quando os olhos estão "crouched" (sem cast bar visível), eles ainda estão castando — interrupt reduz o dano da fase significativamente.

---

## 6. NPCs Relacionados

| NPC ID | Nome                      | Notas                                                            |
|--------|---------------------------|------------------------------------------------------------------|
| `55308`| Warlord Zon'ozz           | Boss principal                                                    |
| `55334`| Void of the Unmaking      | O orbe (ping-pong ball) — spawned via spell 103571               |
| (Heroic)| Eye of Go'rath           | Olho de tentáculo, casta Shadow Gaze (109391)                    |
| (Heroic)| Claw of Go'rath          | Tentáculo grande (tankável junto do boss) ~2,4M HP em 10H        |
| (Heroic)| Flail of Go'rath         | Tentáculos pequenos (2 spawns) ~272k HP em 10H                   |

---

## 7. Lista Completa de Spell IDs (Boss)

| ID      | Nome                                          | Categoria              |
|---------|-----------------------------------------------|------------------------|
| `104543`| Focused Anger                                 | P1 — Boss buff         |
| `104322`| Psychic Drain                                 | P1 — Cone attack       |
| `103434`| Disrupting Shadows                            | P1 — Magic debuff      |
| `103571`| Void of the Unmaking                          | P1 — Summon orb        |
| `106836`| Void Diffusion (buff do orbe)                 | P1 — Orb stacking buff |
| `103527`| Void Diffusion (dano raid + boss vulnerability)| P1→P2 — Transition     |
| `103953`| Tantrum                                       | P1→P2 — Channel (10s)  |
| `104378`| Black Blood of Go'rath (aura 16k/s)           | P2 — Raid AoE          |
| `104377`| Black Blood of Go'rath (3.2k/2s)              | P2 — Variant           |
| `108794`| Black Blood Eruption (knockback de borda)     | P2 — Fail mechanic     |
| `108799`| Black Blood Eruption (knockback + 75% slow)   | P2 — Orb hit           |
| `109391`| Shadow Gaze (Eye of Go'rath attack)           | P2 Heroic — Eye add    |
| `109413`| Darkness (8-stack raid debuff)                 | P2 Heroic — True killer|
| `109874`| Zon'ozz Whisper: Aggro                        | Script de voz (trigger)|
| `109877`| Zon'ozz Whisper: Slay                         | Script de voz (trigger)|
| `109878`| Zon'ozz Whisper: Phase                        | Script de voz (trigger)|

---

## 8. Estratégia Resumida (baseada nos comentários do Wowhead)

### Setup Recomendado (10-man Normal)
- **1 Tank** (2 se undergeared)
- **3 Healers** (em Heroic 10m; em Normal 10m pode 2-heal se overgeared)
- **6-7 DPS**

### Posicionamento
```
              [Ranged Group]
                    ↓
              [Orbe path]
                    ↓
              [Melee Group]
                    ↓
              [Boss → Tank]
```
- Boss virado **para o grupo de ranged** até o orbe spawnar
- Orbe spawna **sempre à frente do boss**
- Tank vira o boss 180° após o cast do orbe começar (posição do orbe já está travada)
- Melee fica atrás do boss, ranged fica a ~40 yd (max range) para dar tempo do orbe tornar-se "hittable"

### Número de Bounces Recomendados
| Setup                  | Sequência típica | Notas                                   |
|------------------------|------------------|-----------------------------------------|
| LFR                    | 0 (ignore)       | Stack no boss, tank & spank             |
| Normal 10 (geared)     | 5-5-5-5          | Mais seguro, sincroniza cooldowns      |
| Normal 10 (undergeared)| 7-3-3-3         | Mais bounces na 1ª fase, menos depois  |
| Heroic 10              | 7-5-5-5          | Mais stacks na 1ª para dano extra      |
| Heroic 25              | 5-5-5-5          | Padrão para grupos melee-heavy         |

### Timeline Típica
1. Pull — tank vira boss para ranged
2. Orbe spawna (8s após pull)
3. Tank vira boss 180° — ranged group toma o 1º bounce
4. 5 bounces entre ranged e melee
5. Melee sai do caminho → orbe atinge boss
6. **Phase 2** inicia (Tantrum, 10s)
7. Stack todo o raid — uso de raid CDs (Tranq, SLT, Aura Mastery, etc)
8. Hero/Bloodlust se a 4ª fase negra for a última
9. Fim da Phase 2 → voltar ao passo 1

### Mecânicas Críticas para Não Errar
- **Orbe "unhittable" window:** após cada bounce, o orbe fica **escuro** por 1-2s. Não dá para bater nele nesse momento — ele passa através dos jogadores. Fica brilhante quando pode ser batido novamente.
- **Disrupting Shadows:** nunca dispelar com orbe a caminho — knockback pode arremessar jogador no orbe
- **Psychic Drain:** tank **sempre** sozinho na frente do boss — cone de 30°
- **Black Blood Eruption:** nunca deixar o orbe escapar para a borda da arena

---

## 9. Quotes & Sound Files (20 quotes)

### Yells (Shout — `s1`)

| Quote (inglês) | Tradução Shath'Yar | Sound File |
|----------------|-------------------|------------|
| Gul'kafh an'qov N'Zoth. | (Gaze into the heart of N'Zoth) | `sound\CREATURE\WarlordZonozz\VO_DS_ZONOZZ_SPELL_05.OGG` |
| N'Zoth ga zyqtahg iilth. | (The will of N'Zoth corrupts you) | `sound\CREATURE\WarlordZonozz\VO_DS_ZONOZZ_SPELL_04.OGG` |
| Sk'magg yawifk hoq. | (Your suffering strengthens me) | `sound\CREATURE\WarlordZonozz\VO_DS_ZONOZZ_SPELL_02.OGG` |
| Sk'shgn eqnizz hoq. | (Your fear drives me) | `sound\CREATURE\WarlordZonozz\VO_DS_ZONOZZ_SPELL_01.OGG` |
| Sk'shuul agth vorzz N'Zoth naggwa'fssh. | (Your deaths shall sing of N'Zoth's unending glory) | `sound\CREATURE\WarlordZonozz\VO_DS_ZONOZZ_SLAY_02.OGG` |
| Sk'tek agth nuq N'Zoth yyqzz. | (Your skulls shall adorn N'Zoth's writhing throne) | `sound\CREATURE\WarlordZonozz\VO_DS_ZONOZZ_SLAY_01.OGG` |
| Sk'uuyat guulphg hoq. | (Your agony sustains me) | `sound\CREATURE\WarlordZonozz\VO_DS_ZONOZZ_SPELL_03.OGG` |
| Sk'yahf agth huqth N'Zoth qornaus. | (Your souls shall sate N'Zoth's endless hunger) | `sound\CREATURE\WarlordZonozz\VO_DS_ZONOZZ_SLAY_03.OGG` |
| Uovssh thyzz... qwaz... | (??) | `sound\CREATURE\WarlordZonozz\VO_DS_ZONOZZ_DEATH_01.OGG` |
| Zzof Shuul'wah. Thoq fssh N'Zoth! | (Victory for Deathwing. For the glory of N'Zoth!) | `sound\CREATURE\WarlordZonozz\VO_DS_ZONOZZ_AGGRO_01.OGG` |

### Whispers (Whisper — `s3`)

| Quote (inglês) |
|----------------|
| Gaze into the heart of N'Zoth. |
| The will of N'Zoth corrupts you. |
| To have waited so long... for this... |
| Victory for Deathwing. For the glory of N'Zoth! |
| Your agony sustains me. |
| Your deaths shall sing of N'Zoth's unending glory. |
| Your fear drives me. |
| Your skulls shall adorn N'Zoth's writhing throne. |
| Your souls shall sate N'Zoth's endless hunger. |
| Your suffering strengthens me. |

### Intro (no pull)
> *"Once more shall the twisted flesh-banners of N'Zoth chitter and howl above the fly-blown corpse of this world. After millennia, we have returned."*
> *Vwyq agth sshoq'meg N'Zoth vra zz shfk qwor ga'halahs agthu. Uulg'ma, ag qam.*
> Sound: `VO_DS_ZONOZZ_INTRO_01.OGG`

### Mapeamento Yell → Spell (do comentário Ketho)
| Yell em Shath'Yar     | Spell ID  | Spell nome              |
|-----------------------|-----------|-------------------------|
| Sk'shgn eqnizz hoq    | `104599`* | (Void Diffusion trigger)|
| Sk'uuyat guulphg hoq  | (sem spell direto) | (3º spell yell)|
| N'Zoth ga zyqtahg iilth | `104378` | Black Blood of Go'rath |
| Gul'kafh an'qov N'Zoth | `103571` | Void of the Unmaking |

*Nota: o spell ID 104599 listado no comentário Ketho aparece hoje no Wowhead como `"Bravado" Cologne` — provável reatribuição de ID em uma versão posterior do jogo. O trigger real do yell de Void Diffusion é interno.

---

## 10. Log Events por Spell (Combat Log — do comentário Ketho)

Estes são os eventos de combat log que cada spell dispara (útil para detectar via AddOn/WeakAura):

| Spell ID | Eventos de Combat Log |
|----------|------------------------|
| `104378` (Black Blood of Go'rath) | `SPELL_CAST_SUCCESS`, `SPELL_AURA_APPLIED`, `SPELL_PERIODIC_DAMAGE` |
| `104599` (Cologne/yell trigger) | `SPELL_CAST_SUCCESS`, `SPELL_AURA_APPLIED`, `SPELL_PERIODIC_DAMAGE` — **Magic Effect** |
| `109409` (Bravado cologne — possível placeholder para buff heroic) | `SPELL_AURA_APPLIED`, `SPELL_AURA_APPLIED_DOSE` |
| `104606` (Bravado cologne) | `SPELL_CAST_SUCCESS`, `SPELL_DAMAGE`, `SPELL_HEAL` |
| `109413` (Darkness) | `UNIT_SPELLCAST_SUCCEEDED` |
| `103953` (Tantrum) | `UNIT_SPELLCAST_SUCCEEDED` |
| `103571` (Void of the Unmaking) | `UNIT_SPELLCAST_SUCCEEDED` |
| `110305` (Bravado cologne) | `UNIT_SPELLCAST_SUCCEEDED` |
| `109874` (Whisper: Aggro) | `UNIT_SPELLCAST_SUCCEEDED` |
| `109878` (Whisper: Phase) | `UNIT_SPELLCAST_SUCCEEDED` |
| `109877` (Whisper: Slay) | `UNIT_SPELLCAST_SUCCEEDED` |
| `108799` (Black Blood Eruption slow) | `SPELL_CAST_SUCCESS`, `SPELL_AURA_APPLIED` |
| `108794` (Black Blood Eruption) | `SPELL_DAMAGE` |
| `106836` (Void Diffusion orb buff) | `SPELL_AURA_APPLIED`, `SPELL_AURA_APPLIED_DOSE` — **Stacks** |
| `104605` (Bravado Cologne placeholder) | `SPELL_DAMAGE` |

---

## 11. Loot Table

### Tokens de Tier (Chest/Gloves/etc) — Depende da dificuldade
- **Gauntlets of the Corrupted Protector** (`item=78178`) — Paladin, Hunter, Priest, Shaman
- **Gauntlets of the Corrupted Vanquisher** (`item=78173`) — Death Knight, Druid, Mage, Rogue
- **Gauntlets of the Corrupted Conqueror** (`item=78175`) — Warrior, Priest, Paladin, Warlock (verificar)

### Items Não-Token
- **Essence of Destruction** (`item=71998`) — crafting material para recipes de Dragon Soul
- **Elementium Gem Cluster** (`item=77952`) — contém gemas aleatórias

> Para a loot table completa por dificuldade, consulte:
> <https://www.wowhead.com/cata/npc=55308/warlord-zonozz#drops>

---

## 12. Berserk

- **Timer:** ~6 minutos (não confirmado oficialmente; alguns grupos reportam 5:30)
- **Sintoma:** matou o raid após a 4ª Phase 2 (grupos com 20k DPS por DPS)
- **Counter:** garanta DPS suficiente para terminar em ≤4 fases negras

---

## 13. Diferenças por Dificuldade (Resumo)

| Mecânica                  | LFR             | Normal 10/25       | Heroic 10/25                          |
|---------------------------|-----------------|--------------------|----------------------------------------|
| Disrupting Shadows knockback | Não (desativado) | Sim, no dispel    | Sim, no dispel                         |
| Dano base (Black Blood)   | Reduzido ~80%   | Padrão             | +50-100% (ver tooltip)                 |
| Tentáculos na Phase 2     | Não             | Não (decoração)    | Sim — Eye/Claw/Flail adds attackable    |
| Darkness debuff (109413)  | Não             | Não                | Sim — 8 stacks iniciais, reduzido por kill |
| Void Diffusion LFR damage | 50k ao invés de 807k | 807k split    | 807k split                              |
| HP do boss                | Reduzido        | Padrão             | +30% (10H) / +50% (25H) aprox         |

---

## 14. Referências / Fontes

- **Boss page:** <https://www.wowhead.com/cata/npc=55308/warlord-zonozz>
- **Encounter Journal (H25):** <https://www.wowhead.com/cata/npc=55308/warlord-zonozz/heroic-25-encounter-journal>
- **Encounter Journal (N10):** <https://www.wowhead.com/cata/npc=55308/warlord-zonozz/normal-10-encounter-journal>
- **Encounter Journal (H10):** <https://www.wowhead.com/cata/npc=55308/warlord-zonozz/heroic-10-encounter-journal>
- **Encounter Journal (N25):** <https://www.wowhead.com/cata/npc=55308/warlord-zonozz/normal-25-encounter-journal>
- **Wowpedia Wiki:** <http://www.wowpedia.org/Warlord_Zon%27ozz>
- **Void of the Unmaking NPC:** <https://www.wowhead.com/cata/npc=55334>
- **Spell pages individuais:** <https://www.wowhead.com/cata/spell={ID}> para cada spell listado acima

### Spells Individuais (links diretos)
- [104543 — Focused Anger](https://www.wowhead.com/cata/spell=104543)
- [104322 — Psychic Drain](https://www.wowhead.com/cata/spell=104322)
- [103434 — Disrupting Shadows](https://www.wowhead.com/cata/spell=103434)
- [103571 — Void of the Unmaking](https://www.wowhead.com/cata/spell=103571)
- [106836 — Void Diffusion (orb buff)](https://www.wowhead.com/cata/spell=106836)
- [103527 — Void Diffusion (raid damage)](https://www.wowhead.com/cata/spell=103527)
- [103953 — Tantrum](https://www.wowhead.com/cata/spell=103953)
- [104378 — Black Blood of Go'rath (16k/s)](https://www.wowhead.com/cata/spell=104378)
- [104377 — Black Blood of Go'rath (3.2k/2s)](https://www.wowhead.com/cata/spell=104377)
- [108794 — Black Blood Eruption (knockback)](https://www.wowhead.com/cata/spell=108794)
- [108799 — Black Blood Eruption (slow)](https://www.wowhead.com/cata/spell=108799)
- [109391 — Shadow Gaze](https://www.wowhead.com/cata/spell=109391)
- [109413 — Darkness](https://www.wowhead.com/cata/spell=109413)
- [109874 — Whisper: Aggro](https://www.wowhead.com/cata/spell=109874)
- [109877 — Whisper: Slay](https://www.wowhead.com/cata/spell=109877)
- [109878 — Whisper: Phase](https://www.wowhead.com/cata/spell=109878)

---

## 15. Notas para o AI Agent

- **IDs estáveis:** todos os spell IDs listados são estáveis entre Cataclysm Classic e o client original 4.3.
- **Variação de dano por dificuldade:** os valores listados são do **Normal 10**. Para Normal 25 multiplique por ~2.5x; Heroic 10 por ~1.5x; Heroic 25 por ~3x (estimativa — confirme no `?dd=` parameter da URL).
- **Boss AI loop:** utilize `UNIT_SPELLCAST_SUCCEEDED` para detectar `103571` (spawn do orbe) e `103953` (início da Phase 2). `104378` aplicado em jogadores = Phase 2 ativa.
- **Posicionamento do orbe:** o orbe se move em linha reta, ricocheteia ao tocar jogadores (não quando unhittable), e seu buff (106836) acumula.
- **Heroic add spawn:** `109413` (Darkness) é aplicado simultaneamente ao início da Phase 2 em Heroic. Counter o número de stacks monitorando `SPELL_AURA_APPLIED_DOSE`.
- **Para WeakAuras/Addons:** todos os spell IDs acima são válidos para registro em `COMBAT_LOG_EVENT_UNFILTERED` no client Cataclysm Classic 4.4+.
