# Dark Touch — Game Design Document

**Dark Touch** is a roguelike where a spectral dark-magic arm raises fallen enemies into your army, played with WoW-style GCD and rotation combat using aimed abilities. This document contains only decisions made so far; everything undecided is listed in [Open questions](open-questions.md).

Companion documents: [Art direction](art-direction.md) · [Audio and music](audio-and-music.md) · [Lore](lore.md) · [Open questions](open-questions.md) · [Canon](canon.md)

## 1. Overview

**Your weapon is an arm of dark magic, spectral and glowing, that can raise fallen enemies to fight for you, and every run you grow a stronger undead army.**

| | |
| --- | --- |
| Title | Dark Touch |
| Genre | Roguelike with army building and aimed, rotation-based combat |
| Engine | Unreal Engine 5, Blueprints; C++ only where optimisation requires it |
| Camera | Directly behind and above the player, WoW-style, with zoom in and out |
| Platform | PC, mouse and keyboard. Controller support may be added later, so design choices should not block it |
| World | Cel'ardor (working name). See [Lore](lore.md) |
| Art style | Stylised, in the spirit of Fellowship. See [Art direction](art-direction.md) |
| Context | Built over 7 weeks for the ELVTR multi-agent AI course, using AI agents across production |

**Inspirations**

- **Solo Leveling:** the fantasy of getting your own soldiers, making them stronger and collecting different types of creatures.
- **World of Warcraft and Fellowship:** ability-bar combat with instants, cast times, a global cooldown and abilities that interact, except that abilities are aimed instead of tab-targeted.
- **Diablo 4:** unlockable variants on each ability for build depth.
- **Mythic+:** stackable difficulty tiers for replayability and challenge.

**What the player does**

- Fights with a kit of aimed abilities.
- Chooses, for each fallen enemy, whether to raise it as a soldier or reap it for power.
- Commands an army of up to 10 soldiers, organised into 3 command groups.
- Clears the level and its boss to win the run, then returns stronger.

**Story in one line:** a mage who lost an arm made a pact with a dark entity for a magic arm that casts on its own, and now raids the enemy army to protect the village where he woke up. Full story in [Lore](lore.md).

## 2. Core loop

**Fight, kill, then decide what each corpse becomes.**

![Core loop: fight, enemy dies, Raise or Reap](images/core-loop.svg)

Raising costs time and positioning but grows the army; reaping is instant and fuels your spenders. Across a run, the army you build and the Souls you gather carry you to the boss.

## 3. Combat

**Combat plays like a WoW ability bar, but every ability is aimed by the player.**

**Rules**

- Abilities are either instant or have a cast time.
- A **1-second global cooldown** applies to abilities.
- You cannot cast while moving, unless an ability specifically allows it.
- Taking a hit does not interrupt a cast; it **pushes the cast's progress back by 1.5 seconds**. Stuns do interrupt casts.
- Fillers build resources and spenders consume them, for single-target and AoE.
- **Damage is always a whole number.** Every damage value and every HP loss is rounded, so an attack never deals decimals.
- **No dodge.** The player has no dodge ability. Enemy windups, such as the Blademaster's parry, are answered by stopping a cast and moving away.

**Controls (mouse and keyboard).** All keys can be rebound. Default bindings: A, E, 1, 2, 3, 4, 5, and the same seven with Shift, for 14 bindable slots shared between spells, command groups and orders.

**Resources**

| Resource | Loop | Gained by | Spent on |
| --- | --- | --- | --- |
| Spirit | Main | To define | Spells and abilities; reviving starting soldiers |
| Souls | Short, Soul Shard-style | Killing enemies, reaping corpses; talents modify how they are gained | Spender abilities |

There is no currency: no gold, no shop.

**Abilities (first pass, names not final)**

| Ability | Role | Aiming |
| --- | --- | --- |
| Deathbolt | Single-target filler | Aimed |
| Unholy Impale | Single-target spender | Aimed |
| Splinters | AoE filler | Cone toward the aim |
| Death Nova | AoE spender | Ground circle |
| Grasp | Root-style crowd control | Ground circle |
| Swap | Swap places with a soldier | Aimed |
| Frenzy | Timed buff on soldiers | All soldiers |
| Death Trap | Placed trap, like WoW's Hunter traps | Ground circle |
| Flying Filthy Dagger | Thrown dagger that applies a poison debuff | Aimed |
| Raise | Turn a corpse into a soldier | Aimed |
| Reap | Consume a corpse for Souls and a 10-second buff | Aimed |

Whether aimed abilities get a soft-targeting assist or stay pure raw aim will be decided during prototyping.

**Variants:** each ability has two unlockable variants, Diablo 4-style. Reap has three, each a 10-second stat buff: HP regeneration, damage boost or movement speed.

**Raising is a skill check.** Raising mid-fight is only possible if you play well, because of its cast time and the need to be close to the corpse.

## 4. Necromancy and the army

**Every corpse is a choice: Raise it into a soldier, or Reap it for power.**

**Raise**

- Performed with the dark-magic arm.
- Any mob can be raised, as long as the player's level is high enough. Example: the floor-1 boss could appear as a regular mob on floor 3, and become raisable there.
- Has a cast time and requires being close to the corpse, which makes raising during combat dangerous.
- Each raised soldier takes an army slot. Maximum: 10 slots at endgame.

**Reap**

- A separate ability that consumes a corpse instantly.
- Grants Souls plus a 10-second buff for the army and you, depending on the variant (HP regen, damage or speed).

**Soldier behaviour**

- With no orders, soldiers attack the first enemy they see.
- Orders and some spells direct them precisely.
- **Command groups:** an army UI tab where the player drags and drops soldiers into 3 groups, then gives orders group by group.
- Dismissing a soldier frees its slot. Bound (starting) soldiers cannot be dismissed.

**Soldier roster.** Each type fights as an enemy first and can be raised as a soldier. Each type gives the player a special ability.

| Type | Role and behaviour | Targeting | Player ability |
| --- | --- | --- | --- |
| Guard | Basic footman, sword and shield. Sometimes raises its shield to reduce damage, standing still and turning very slowly while doing so. | No particular rule | **Guard:** a temporary shield that reduces damage taken for 1.5 s |
| Mage | Ranged spellcaster throwing arcane bolts. Occasionally casts a long, charged spell (spirit-bomb style) thrown for massive damage. | Focuses the biggest threat to it | TBD |
| Rogue | Dual-blade warrior. Fast attacks, high damage, squishier than Guards. Can dash through normal monsters to reach its target, after a 1-second windup. | Focuses the player and elites first | TBD |
| Tank | Armoured, muscular, slow and heavy. Hits hard and is tough to kill. | No particular rule | **Taunt:** the Tank forces all nearby enemies to focus it, Rogues included |
| Blademaster | Elite-class two-handed warrior: sturdy, hits hard, fairly fast. Occasionally parries an attack or spell and sends the damage back to the attacker; a visible windup lets the player stop casting and move away to avoid the counter. | No particular rule | **Parry:** sends an attack back at 2x its damage |

**Elites.** Any mob can be an elite. An elite has an aura and a slightly different colour palette, and is granted a stat boost over the normal version.

**Names and stat grades: hunting for the right soldier.**

- Every mob gets a random name drawn from a very large list, to give each one character.
- Alive, all mobs of a type share the same stats.
- Each mob has hidden grades, rolled at random, on 3 stats: **Vitality** (max HP), **Attack** (damage) and **Speed** (cast speed for ranged types, movement speed for melee types). Each stat gets its own grade: S = 1.25x the base stat, A = 1x, B = 0.75x.
- Each mob also has a **rank**, inspired by Solo Leveling's shadow grades: Shadow (level 1), Asset (level 2), Ace (level 3), General (level 4). The rank boosts all stats without changing their grades: a General with a B in Attack keeps that B.
- **Formula: (Base stat × Grade) × (1 + (Level − 1) × 0.5) = Effective stat**, so Shadow = 1x, Asset = 1.5x, Ace = 2x, General = 2.5x. Example: a General with B in Attack and base damage 10 deals (10 × 0.75) × 2.5 = 18.75, rounded to a whole number.
- Hovering a corpse reveals its name, grades and rank, so the player decides whether it is worth raising.
- Higher difficulty tiers give better odds of high grades.
- This turns army building into a hunt for the right soldier, giving the optimisation satisfaction (and friction) of gearing without using gear.

## 5. Run structure

**For now a run is one level ending with a boss; the 3-level structure is the target for later.**

| Element | Decision |
| --- | --- |
| Levels | Current scope: one level with a boss at the end. Later target: 3 medium levels, each ending with an elite or a boss |
| Layout | A mix of rooms and open areas, for emergent gameplay from the level design |
| Win condition | Kill the final boss |
| Lose condition | Player HP reaches 0 |
| Difficulty | Increasing tiers, like Mythic+: mobs have higher stats, better odds of high stat grades (so stronger soldiers to raise), and give more experience |
| Run length | 20–25 minutes for the 3-level version |

## 6. Progression

**You keep your starting soldiers no matter what; everything raised during a run is kept only if you win.**

| What | Rule | After a win | After a death |
| --- | --- | --- | --- |
| Starting soldiers | Brought into the run: 1, then up to 3 with levels and passive talents | Kept | Kept |
| Raised soldiers | Raised during the run, up to the 10-slot cap | Kept | Lost |
| Talismans | Found in hidden chests or dropped by fallen foes. The player equips 2 before a run; each boosts the stats of one specific spell, so the player enhances 2 favourite spells for the build. No armour or other gear. | To define | To define |
| Spells | Demo: every spell is available from the start; experience and levels unlock the spell variants | Kept | Kept |
| Talents | Passive talents; some change how Souls are gained | Kept | Kept |

**Reviving**

- A fallen starting soldier can be revived mid-run for a significant Spirit cost, so losing one hurts. Exact cost to be set in balancing.
- When a run ends, every soldier you keep revives automatically, so you can retry immediately with the same set.

**Roguelike randomness:** beyond your 1–3 starting soldiers, you have to build the rest of your army during each run.

## 7. Art and audio in brief

- **Art:** stylised, Fellowship-like. Every character uses the UE5 Mannequin skeleton; the player is two skeletal meshes, the body and the cursed arm, so the arm can carry its own effects. The arm must stand out in every animation, and soldiers show their rank with a coloured aura. Details in [Art direction](art-direction.md).
- **Audio:** dark neoclassical music with the cello always leading, adaptive layers for exploration, combat and boss, phonk elements under test, and an iconic cello motif when a soldier rises. Sound effects come from free, commercial-safe banks. Details in [Audio and music](audio-and-music.md).

## 8. AI agent team

**Each agent has one job, a prompt you can copy, and a known cost; the Game Director reviews everyone's work against the GDD.**

| Agent | Model | What it does | Prompt | Tools and cost |
| --- | --- | --- | --- | --- |
| Game Director | Claude Opus 5.5 | Called at the end of every meaningful task. Checks the work against the GDD and against existing assets for consistency, then gives a verdict: approved, approved with notes, or changes required. Reviews only; you keep the final word. | [Open prompt](agents/game-director.md) | No external tools. About 10–20k tokens per review, roughly $0.07–0.15 per review. |
| Technical Director | Claude Opus 5.5 | Keeps the map of every system (systems.md). Checks that systems' inputs and outputs fit together, that each piece of data has one owner, and that systems stay loosely coupled. Reviews performance (army AI, Event Tick, arm effects, spawning) and proposes streamlining that keeps the polish. Reviews before the Game Director. | [Open prompt](agents/technical-director.md) | No external tools required; optional Unreal MCP and Unreal Insights captures. About 15–30k tokens per review, roughly $0.11–0.22 per review. |
| Game Feel Director | Claude Sonnet 5.5 | Gives every ability, hit, raise, button press and drag-and-drop its own distinct, polished feel: anticipation, impact, follow-through, camera shake, hit-stop, sound, UI feedback and the arm's effect. Writes a feel spec per interaction and reviews recordings with your 1–5 ratings. | [Open prompt](agents/game-feel-director.md) | No external tools required; reviews GIFs or short videos you record. About 5–10k tokens per spec (roughly $0.02–0.04) and 10–20k per review (roughly $0.04–0.07). |
| UI Designer | TBD | Designs one screen at a time, most important first (in-game HUD, army tab, builds tab, main menu…). Shows 4 mockups per screen, each with a different design intention, then iterates until you validate. Validated screens set the visual language for the next ones. | [Open prompt](agents/ui-designer.md) | HTML mockups at 1920x1080; optional image generation for style frames. About 20–40k tokens per round of 4 mockups; cost TBD with the model. |
| Music Director | Claude Sonnet 5.5 | Creates the music with AI tools: 3 tracks per round, waits for your feedback, iterates until you validate. Also makes the cello raise motif. | [Open prompt](agents/music-director.md) | ElevenLabs Music API, about $0.15 per minute (paid plan from $6/month); Stable Audio about $0.20 per generation; Suno free for exploration. About 5–8k tokens per round, roughly $0.02–0.03; a round of 3 two-minute tracks is about $0.90 in generation. |
| Sound Designer | Claude Haiku 5.5 | Reads the needed-sound list, finds 3 free commercial-safe sounds per entry in public sound banks, and posts them to the Sound Board for you to play, pick, or reject. | [Open prompt](agents/sound-designer.md) | Freesound API (free key), Kenney, OpenGameArt, Pixabay: free. About 4–8k tokens per entry, under $0.01 per entry. |
| AI Director | Claude Opus 5.5 | Owns the behaviour logic of every enemy and soldier, one shared version per type. Builds basic logic first; before each upgrade, presents how it will build it, what it costs and which details it recommends, discusses with you, and implements only once you confirm. | [Open prompt](agents/ai-director.md) | UE5 MCP. About 20–40k tokens per proposal round (roughly $0.15–0.29) and 40–80k per implemented stage (roughly $0.29–0.58). |
| Animation Scraper | Claude Sonnet 5.5 | Finds 2 candidate animations per action and ability, Manny-skeleton first (Fab, Mixamo and others), for you to validate or reject. Then downloads the validated ones, or gives you the link when it needs your account, and retargets them to the UE5 Manny skeleton. | [Open prompt](agents/animation-scraper.md) | UE5 MCP; Mixamo free with an Adobe account, Fab free to paid (you approve purchases). About 5–10k tokens per animation, roughly $0.02–0.04. |

**Sound review:** the [Dark Touch Sound Board](https://claude.ai/artifact/RfTmdaNEp5cF3bLusSwN8b) lists every needed sound with its 3 candidates. Play each one, pick the best, or press Find 3 more with an optional note; the agent's next pass replaces the candidates and never repeats a rejected sound.

Token figures are estimates. Dollar costs assume the API rates per million tokens (input / output): Opus 5.5 $4 / $20, Sonnet 5.5 $2 / $10, Haiku 5.5 $0.10 / $0.50 for prompts under 100k tokens, with about 80% of tokens read and 20% written; other agents, their interactions and the overall token budget are still to be defined.

**Canon file:** [canon.md](canon.md), next to this GDD, is a short list of facts only the designer validates; every agent reads it before working, and the Game Director checks each review against it first, falling back to this GDD when it is silent.
