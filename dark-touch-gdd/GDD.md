# Dark Touch — Game Design Document

Companion documents: [Art direction](art-direction.md) · [Audio and music](audio-and-music.md) · [Lore](lore.md) · [Open questions](open-questions.md) · [Canon](canon.md)

## 1. Executive Summary

**Dark Touch is a roguelike where a spectral dark-magic arm raises fallen enemies into your army, played with WoW-style GCD and rotation combat using aimed abilities.** A mage who lost an arm made a pact with a dark entity; the cursed arm it gave him casts on its own and turns every kill into a potential soldier. Every corpse is a choice: raise it to grow the army, or reap it to fuel your spells. Hidden stat grades and ranks turn army building into a hunt for the perfect soldier.

| | |
| --- | --- |
| Genre | Roguelike with army building and aimed, rotation-based combat |
| Engine | Unreal Engine 5, Blueprints; C++ only where optimisation requires it |
| Camera | Directly behind and above the player, WoW-style, with zoom in and out |
| Platform | PC, mouse and keyboard; controller may come later, so nothing should block it |
| World and art | Cel'ardor, a continent at war ([Lore](lore.md)); stylised, in the spirit of Fellowship ([Art direction](art-direction.md)) |
| Music | Dark neoclassical, cello-led, adaptive to combat ([Audio and music](audio-and-music.md)) |
| Inspirations | Solo Leveling (raising soldiers), World of Warcraft and Fellowship (ability-bar combat), Diablo 4 (ability variants), Mythic+ (difficulty tiers) |
| Demo scope | One level ending with a boss; every spell available from the start |
| Production | Built over 7 weeks for the ELVTR multi-agent AI course by one designer and a team of 9 AI agents, each gated by the designer's approval |

## 2. Game Mechanics

### Core loop

**Fight, kill, then decide what each corpse becomes.** Raising costs time and positioning but grows the army; reaping is instant and fuels your spenders. Across a run, the army you build and the Souls you gather carry you to the boss.

![Core loop: fight, enemy dies, Raise or Reap](images/core-loop.svg)

### Combat

**Combat plays like a WoW ability bar, but every ability is aimed by the player.**

- Abilities are instant or have a cast time; a **1-second global cooldown** applies. No casting while moving, unless an ability allows it.
- Taking a hit does not interrupt a cast: it **pushes the cast back by 1.5 s**. Only stuns interrupt.
- **No dodge:** enemy windups, like the Blademaster's parry, are answered by stopping the cast and moving away.
- Fillers build Souls; spenders consume them. **Damage is always a whole number.**
- **Controls:** rebindable. Defaults A, E, 1–5 and Shift + the same: 14 slots for spells, command groups and orders.

| Resource | Role | Gained by | Spent on |
| --- | --- | --- | --- |
| Spirit | Main resource | To define | Abilities; reviving starting soldiers |
| Souls | Short loop, Soul Shard-style | Kills and Reap; talents change how | Spender abilities |

There is no currency: no gold, no shop.

**Work in progress:** the ability kit below is a first pass. It will be reworked into a proper rotation, with abilities that set each other up and interact, rather than just one filler and one spender per role.

| Ability | Role | Aiming |
| --- | --- | --- |
| Deathbolt | Single-target filler | Aimed |
| Unholy Impale | Single-target spender | Aimed |
| Splinters | AoE filler | Cone toward the aim |
| Death Nova | AoE spender | Ground circle |
| Grasp | Root | Ground circle |
| Swap | Swap places with a soldier | Aimed |
| Frenzy | Timed buff on soldiers | All soldiers |
| Death Trap | Placed trap, like WoW Hunter traps | Ground circle |
| Flying Filthy Dagger | Thrown dagger, poison debuff | Aimed |
| Raise | Turn a corpse into a soldier | Aimed |
| Reap | Consume a corpse for Souls and a 10 s buff | Aimed |

Names are not final, except Unholy Impale. Each ability has **two unlockable variants** (Diablo 4-style); Reap has three: HP regen, damage or speed. Soft-targeting assist vs raw aim is decided during prototyping.

### Necromancy and the army

**Every corpse is a choice: Raise it into a soldier, or Reap it for power.**

- **Raise:** any mob at or below the player's level. Cast time, and the player must be close to the corpse, so raising mid-fight is a skill check. Each soldier takes a slot; **10 slots** max at endgame.
- **Reap:** instant. Grants Souls plus a 10-second buff for the player and the army, depending on the variant.
- **Behaviour:** with no orders, soldiers attack the first enemy they see. Soldiers are dragged into **3 command groups** and ordered group by group. Dismissing a soldier frees its slot; bound (starting) soldiers cannot be dismissed.

| Type | Behaviour | Targeting | Player ability |
| --- | --- | --- | --- |
| Guard | Sword-and-shield footman; sometimes shields up, standing and turning slowly | None | **Guard:** damage reduction for 1.5 s |
| Mage | Ranged arcane bolts; occasional long charged spell for massive damage | Biggest threat to it | TBD |
| Rogue | Dual blades, fast, high damage, squishier; 1 s windup, then dashes through normal mobs | Player and elites first | TBD |
| Tank | Armoured, slow, hits hard, very tough | None | **Taunt:** all nearby enemies focus the Tank, Rogues included |
| Blademaster | Two-handed elite class: sturdy, hard-hitting, fairly fast; occasional parry with a visible windup, sending damage back | None | **Parry:** sends an attack back at 2x damage |

**Elites:** any mob can be an elite: an aura, a slightly different palette, and a stat boost.

**Hunting for the right soldier.** Every mob has a random name. Alive, all mobs of a type share the same stats; hovering a corpse reveals its hidden **grades** and **rank**:

- **Grades**, one per stat: Vitality (max HP), Attack (damage), Speed (cast speed for ranged, movement speed for melee). S = 1.25x, A = 1x, B = 0.75x.
- **Rank**, inspired by Solo Leveling: Shadow (1), Asset (2), Ace (3), General (4). Rank boosts every stat without changing grades.
- **Effective stat = (Base × Grade) × (1 + (Level − 1) × 0.5)**: Shadow 1x, Asset 1.5x, Ace 2x, General 2.5x. Higher difficulty tiers give better grade odds.

### Run structure and progression

| Element | Decision |
| --- | --- |
| Levels | Demo: one level ending with a boss. Later: 3 medium levels, each ending with an elite or boss, 20–25 minutes |
| Layout | A mix of rooms and open areas, for emergent gameplay |
| Win / lose | Kill the final boss / player HP reaches 0 |
| Difficulty | Mythic+-style tiers: stronger mobs, better grade odds, more experience |

| What | Rule | Win | Death |
| --- | --- | --- | --- |
| Starting soldiers | 1, then up to 3 with levels and talents | Kept | Kept |
| Raised soldiers | Up to the 10-slot cap | Kept | Lost |
| Talismans | Only gear. Found in hidden chests or dropped by foes; 2 equipped before a run, each boosting one spell | To define | To define |
| Spells | Demo: all available from the start; experience and levels unlock variants | Kept | Kept |
| Talents | Passive; some change how Souls are gained | Kept | Kept |

A fallen starting soldier can be revived mid-run for a significant Spirit cost. When a run ends, every kept soldier revives automatically, so the player can retry immediately.

## 3. AI Architecture

**Each agent shapes a part of what the player sees, hears and fights; none of them ships anything without the designer's approval.**

| Agent | Its effect on gameplay |
| --- | --- |
| Gameplay Programmer | Every rule in this document becomes a working system the player can feel: aimed casting with the 1.5 s pushback, Raise and Reap, army slots and command groups, grades and ranks, talismans and progression. |
| AI Director | Every enemy and soldier fights with its own readable personality: Rogues dash at the player, Tanks pull aggro with Taunt, Blademasters telegraph their parry. One behaviour per type serves both sides, so a creature you fought plays the same way once raised. |
| Game Feel Director | Every ability, hit, raise and button press has its own feel through hit-stop, camera shake, sound and UI feedback; fillers stay light, spenders hit hard, and raising a soldier is the signature moment. |
| Animation Scraper | Every action and ability has a validated animation on the shared UE5 Manny skeleton, so soldiers and enemies move consistently and the cursed arm stays readable. |
| UI Designer | The HUD makes the rules visible: the cast bar shows the 1.5 s pushback, the army panel shows names, grades and ranks, and command groups are a drag away. |
| Music Director | The cello-led score shifts between exploration, combat and boss layers, and every raise triggers the same iconic motif. |
| Sound Designer | Every ability and hit gets a distinct sound effect, so the player can read the fight by ear. |
| Technical Director | A full army of 10 soldiers plus enemies keeps a stable frame rate, and systems like casting, raising and slots never conflict. |
| Game Director | Everything above stays consistent with the GDD and with itself: one art style, one audio identity, one set of rules. |

**Review flow:** a builder agent finishes a task → the Technical Director checks that it works → the Game Director checks that it fits the game → the designer validates. Validated facts go into [canon.md](canon.md), which every agent reads first.

## 4. Technical Strategy

### Agent roles

| Agent | Model | What it does | Prompt | Tools and cost |
| --- | --- | --- | --- | --- |
| Gameplay Programmer | Claude Opus 5.5 | Builds the game's systems (abilities, casting, raising, army, grades, progression). For each one, explains how it will build it and waits for your validation; then builds it, you test it, and it iterates until you validate. | [Open prompt](agents/gameplay-programmer.md) | UE5 MCP, or written Blueprint specs. About 20–40k tokens per explanation (roughly $0.15–0.29) and 40–80k per build (roughly $0.29–0.58). |
| Game Director | Claude Opus 5.5 | Called at the end of every meaningful task. Checks the work against the GDD and against existing assets for consistency, then gives a verdict: approved, approved with notes, or changes required. Reviews only; you keep the final word. | [Open prompt](agents/game-director.md) | No external tools. About 10–20k tokens per review, roughly $0.07–0.15 per review. |
| Technical Director | Claude Opus 5.5 | Keeps the map of every system (systems.md). Checks that systems' inputs and outputs fit together, that each piece of data has one owner, and that systems stay loosely coupled. Reviews performance (army AI, Event Tick, arm effects, spawning) and proposes streamlining that keeps the polish. Reviews before the Game Director. | [Open prompt](agents/technical-director.md) | No external tools required; optional Unreal MCP and Unreal Insights captures. About 15–30k tokens per review, roughly $0.11–0.22 per review. |
| Game Feel Director | Claude Sonnet 5.5 | Gives every ability, hit, raise, button press and drag-and-drop its own distinct, polished feel: anticipation, impact, follow-through, camera shake, hit-stop, sound, UI feedback and the arm's effect. Writes a feel spec per interaction and reviews recordings with your 1–5 ratings. | [Open prompt](agents/game-feel-director.md) | No external tools required; reviews GIFs or short videos you record. About 5–10k tokens per spec (roughly $0.02–0.04) and 10–20k per review (roughly $0.04–0.07). |
| UI Designer | TBD | Designs one screen at a time, most important first (in-game HUD, army tab, builds tab, main menu…). Shows 4 mockups per screen, each with a different design intention, then iterates until you validate. Validated screens set the visual language for the next ones. | [Open prompt](agents/ui-designer.md) | HTML mockups at 1920x1080; optional image generation for style frames. About 20–40k tokens per round of 4 mockups; cost TBD with the model. |
| Music Director | Claude Sonnet 5.5 | Creates the music with AI tools: 3 tracks per round, waits for your feedback, iterates until you validate. Also makes the cello raise motif. | [Open prompt](agents/music-director.md) | ElevenLabs Music API, about $0.15 per minute (paid plan from $6/month); Stable Audio about $0.20 per generation; Suno free for exploration. About 5–8k tokens per round, roughly $0.02–0.03; a round of 3 two-minute tracks is about $0.90 in generation. |
| Sound Designer | Claude Haiku 5.5 | Reads the needed-sound list, finds 3 free commercial-safe sounds per entry in public sound banks, and posts them to the Sound Board for you to play, pick, or reject. | [Open prompt](agents/sound-designer.md) | Freesound API (free key), Kenney, OpenGameArt, Pixabay: free. About 4–8k tokens per entry, under $0.01 per entry. |
| AI Director | Claude Opus 5.5 | Owns the behaviour logic of every enemy and soldier, one shared version per type. Builds basic logic first; before each upgrade, presents how it will build it, what it costs and which details it recommends, discusses with you, and implements only once you confirm. | [Open prompt](agents/ai-director.md) | UE5 MCP. About 20–40k tokens per proposal round (roughly $0.15–0.29) and 40–80k per implemented stage (roughly $0.29–0.58). |
| Animation Scraper | Claude Sonnet 5.5 | Finds 2 candidate animations per action and ability, Manny-skeleton first (Fab, Mixamo and others), for you to validate or reject. Then downloads the validated ones, or gives you the link when it needs your account, and retargets them to the UE5 Manny skeleton. | [Open prompt](agents/animation-scraper.md) | UE5 MCP; Mixamo free with an Adobe account, Fab free to paid (you approve purchases). About 5–10k tokens per animation, roughly $0.02–0.04. |

**Sound review:** the [Dark Touch Sound Board](https://claude.ai/artifact/RfTmdaNEp5cF3bLusSwN8b) lists every needed sound with its 3 candidates: play, pick, or ask for 3 more.

### Token budget

**The agents run on a Claude Pro subscription: $20 per month, about $40 for the 7-week course.** Claude Code is included, and its usage shares the same limits as claude.ai: a limit that resets every five hours, plus a weekly limit. Opus agents use those limits faster than Sonnet or Haiku, so the heaviest work is spread across sessions; usage credits can be enabled if a limit blocks a deadline. The per-use costs in the table above are API-equivalent figures, for reference.

| Agent | Model | Assumed workload over 7 weeks | Tokens |
| --- | --- | --- | --- |
| Gameplay Programmer | Opus 5.5 | ~15 systems, each explained, built and fixed twice | ~1.8M |
| Game Director | Opus 5.5 | 60 reviews | ~0.9M |
| Technical Director | Opus 5.5 | 40 reviews | ~0.9M |
| AI Director | Opus 5.5 | 6 proposal rounds, 4 implemented stages | ~0.4M |
| Game Feel Director | Sonnet 5.5 | 15 specs, 20 reviews | ~0.4M |
| UI Designer | TBD | 8 screens × 3 rounds | ~0.7M |
| Animation Scraper | Sonnet 5.5 | 40 animations | ~0.3M |
| Music Director | Sonnet 5.5 | 10 rounds | ~0.1M |
| Sound Designer | Haiku 5.5 | 30 sounds × 2 rounds | ~0.4M |
| **Total** | | | **~6M** |

**Outside the subscription:** about $10 of music generation, and an ElevenLabs plan from $6 per month while its API is used. API-equivalent value of the token total, without the UI Designer: about $32 (Opus 5.5 $4 / $20, Sonnet 5.5 $2 / $10, Haiku 5.5 $0.10 / $0.50 per million input / output tokens, assuming 80% read and 20% written).

**Cost levers:** canon.md stays short so agents read it instead of the whole GDD; reviewers receive only what changed; Game Director reviews are batched after several small tasks.

### How the agents run (proposed setup, to confirm in week 1)

- **Claude Code**, included in Pro, opened in the project's git repository.
- **Each agent is a Claude Code subagent:** a file in `.claude/agents/` holding its prompt from the [agents](agents/) folder and its model (Opus, Sonnet or Haiku). Agents that build in the engine get the UE5 MCP.
- **The main session acts as producer:** the designer asks for a task, it hands the task to the right agent, then to the Technical Director and the Game Director for review.
- **Shared memory lives in files** in the repository: canon.md, systems.md, feel.md, animations.md, reviews.md. Git keeps the history of every change.
- **Every validation gate is the designer**, answering in the session; sounds are reviewed on the Sound Board.
