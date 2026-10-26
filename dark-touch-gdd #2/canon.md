# Dark Touch — Canon

Validated facts only. The Game Director reads this file first on every review.
Only the game designer validates a fact; agents may propose additions, never write them unapproved.
This is the AI-agent version of the GDD. Human versions: GDD.md (6 pages) and GDD-full.md (full reference).
Source of truth for anything not listed here: GDD-full.md and its companion documents.
When a fact changes, GDD.md, GDD-full.md and canon.md are updated together.
Last validated: 2026-10-26

## Identity
- Title: Dark Touch
- Genre: roguelike, army building, aimed WoW-style ability combat
- Engine: UE5, Blueprints; C++ only for optimisation
- Platform: PC, mouse and keyboard; controller may come later, so never block it
- Camera: behind and above the player, WoW-style, zoom in and out
- World: Cel'ardor (working name)
- Art style: stylised, in the spirit of Fellowship
- Story: a one-armed mage made a pact with an unknown dark entity for a magic arm that casts on its own; wakes in a village during a continent-wide war and raids the enemy army to protect it

## Combat rules
- Abilities are instant or have a cast time
- No casting while moving, except Splinters, Grasp, Frenzy, Hunger and Rot
- Global cooldown: 1 s, on every spell except Reap
- Cast times: Deathbolt 1.75 s; Unholy Impale and Death Nova 2 s
- Damage and HP loss are always rounded down to whole numbers
- No dodge: enemy windups are answered by stopping a cast and moving away
- Controls: rebindable; defaults A, E, R, F, 1-5 and Shift + the same (18 slots: 12 spells, 3 golden-slot abilities, 3 command-group keys)
- Taking a hit pushes the current cast back by 1.5 s; only stuns interrupt a cast
- Stun sources: the Mage's long charged spell, the Blademaster's parry
- Fillers build Souls, spenders consume them

## Resources
- Spirit: max 100 at level 1, +20 per player level (380 at level 15)
- Spirit: spent only on Raise and revives; revive cost = 60% of that soldier's raise cost, rounded down (revivePercent on the economy/spirit doc)
- Raise cost: Shadow 50, Asset 75, Ace 110, General 150; +10 per S grade, -10 per B grade (so 20 to 180); numbers on the Rank Odds board, economy/spirit doc; no other spell costs Spirit
- Spirit gains: 50 on entering each section (up to the cap), 5 per Reap, some variant passives; this exchange rate is intended; target: about 2-3 raises per section at tier 1; at tier 20 about 2-3 Generals per section
- HP: no regeneration over time; healed by Hunger and by Reap for HP (2 s cast, 20% of max HP)
- Spirit never regenerates over time; regained a little at each new section, by Reap, and by some variant passives
- Souls: short-loop resource, Soul Shard-style; kills and Reap give no Souls
- Souls: max 6; each spender costs 3; Deathbolt gives 1; Splinters gives 1 (2 with a proc); Rot gives 0
- No currency: no gold, no shop

## Abilities
- Names are final, except Deathbolt and Death Nova (to be renamed)
- Aimed: Deathbolt, Unholy Impale, Rot (hitscan), Swap, Raise, Reap (soft targeting decided in prototyping)
- Cone toward the aim: Splinters. Ground circle: Death Nova, Grasp. Aimed: Hunger
- 7 spells at the start (Deathbolt, Unholy Impale, Splinters, Death Nova, Raise, Reap, Hunger); 5 unlocked by player level (Grasp, Swap, Frenzy, Rot, Power of Below)
- Variants are equipped in variant slots unlocked by player level (6 by level 15); one variant per spell at most
- Deathbolt: single-target cast-time filler, last in priority
- Unholy Impale: single-target spender
- Splinters: instant AoE cone toward the aim, 30° wide, starting from a flat base about twice the player's width (hits enemies right next to him), rounded far edge; weak, builds Souls; 2 charges, 5 s recharge per charge (3 s during Power of Below)
- Splinters proc: any player hit except Splinters' own has 10% chance to grant a free Splinters charge and double its next hit; Rot's first hit 10%, later Rot ticks 1%; soldiers' hits never proc
- Splinters: up to 2 procs held, so at most both charges are empowered; never more than 2 charges, never more than double damage per charge
- Free spender proc: each enemy hit by Splinters has 5% chance to make the next spender cost no Souls; only one stored; AoE dominating the rotation is intended
- Splinters proc empowers the charge it grants; with 2 charges already, it empowers an existing charge; with 2 procs active, a third proc is lost
- Death Nova: AoE spender
- Grasp: root
- Swap: swap places with a soldier
- Frenzy: timed buff on soldiers
- Hunger (replaces Death Trap): instant, aimed; targets only the player's own soldiers; hitting one of your summons consumes it, healing the player by its remaining HP; castable while moving; 10 s cooldown; the eaten soldier becomes a corpse again, revivable for 60% of its raise cost (intended loop); Chosen cannot be eaten; heal capped by the eaten soldier's rank: max 30% of player max HP (Shadow), 40% (Asset), 50% (Ace), 60% (General)
- Rot (replaces Flying Filthy Dagger): instant, generates no Souls; hitscan curse on the aimed target, damage every 1 s for 10 s; can be on several enemies at once; recast on a cursed target refreshes the duration to 10 s (no stacking)
- Power of Below: personal offensive cooldown; GCD 0.75 s, cast times halved, spenders instant, Splinters recharge 3 s
- Base rotation (no talismans): spender (Unholy Impale ST / Death Nova AoE) if Souls capped (never overcap) > Splinters with proc > spender > Rot on main target if not cursed > Splinters > Deathbolt
- Reap: consume a corpse for a 10 s buff (no Souls) (variants: HP regen, damage, speed), plus a mouse choice after pressing Reap: left click = 5 Spirit (instant), right click = 20% of max HP (2 s cast, stand still, pushback applies); a corpse left by Hunger can be reaped too
- Reap base buff (no Reap variant equipped): every army soldier heals 1% of its HP per second for 10 s
- Each ability has 2 unlockable variants (Reap has 3); variants not yet defined

## Army
- Weapon: a spectral dark-magic arm (no blade): non-physical, translucent, glowing, with wisps and clawed fingers, yet able to strike, grab and hold things; it must stand out in every animation
- Raise: performed with the dark-magic arm, cost by rank and grades, cast time, must be close; any rank the player meets can be raised
- 10 army slots max at endgame
- No orders: soldiers attack the first enemy they see
- 3 command groups, set by drag and drop in the army tab; each group's hotkey selects it and swaps the action bar to the order bar (Attack, Protect, Move), like a WoW Rogue's stealth bar; giving an order swaps back to the spells instantly; pressing the group key again swaps back without an order
- All 10 army slots are open from the start
- Dismissing a soldier frees its slot
- 3 golden army slots: a soldier there gives its type ability to the player as a spell
- Orders: Attack, Protect (attack the biggest threat to the player), Move
- Collection: winning a run adds the soldiers raised and won with; Chosen (soldiers brought from it, 0-3 by player level) stay in it whatever happens
- Each run: bring up to 3 Chosen from the collection (none at level 1), raise the rest on the battlefield
- Raised soldiers: join the collection on a win; lost on a defeat
- Any fallen soldier can be revived for 60% of its raise cost; a raised soldier not revived before leaving the current section is lost for the run
- All kept soldiers revive automatically when a run ends

## Soldier roster (enemies and soldiers share it)
- Guard: sword and shield footman; sometimes shields up (stands, turns slowly). Player ability: Guard, damage reduction for 1.5 s
- Mage: ranged arcane bolts; occasional long charged spell for massive damage that stuns; focuses its biggest threat. Player ability: TBD
- Rogue: dual blades, fast, high damage, squishier than Guards; focuses player and elites; 1 s windup then dash through normal mobs. Player ability: TBD
- Tank: armoured, slow, hits hard, very tough. Player ability: Taunt (all nearby enemies focus the Tank, Rogues included)
- Blademaster: two-handed, sturdy, hits hard, fairly fast; occasional parry with a visible windup, sends damage back and stuns. Player ability: Parry (sends an attack back at 2x damage)
- Berserker: leaps onto its target; Whirlwind, a quick simple AoE around itself (not a long channel). Targeting and player ability: TBD
- Elites: any mob can be one; aura, slightly different palette, stat boost
- A raised elite is captured (Pokémon-style) and sent to the collection at the base, not to the run's army; every fallen elite can be captured, with no limit per run
- A captured elite keeps its elite status and stats, but is lost if the player loses the run (no death farming)
- Capture works like a normal raise for now; a special capture (rhythm mini-game?) is planned for later
- The base = the menu between runs, holding the collection: choose Chosen to bring (up to 3), talismans, difficulty
- Player level: max 15; levels 2-15 unlock 5 spells, 6 variant slots, 3 Chosen slots (first at level 2) (order on the Level Unlocks board); levels are gained at the end of a run; experience is kept even on a lost run
- At the base, a Rename button lets the player rename any soldier (optional)

## Names and grades
- Every mob gets a random name from a list of 200 European first names (data/mob-names.csv)
- Alive, all mobs of a type share the same stats
- Hidden grades rolled at random, one per stat: Vitality (max HP), Attack (damage), Speed (cast speed for ranged, movement speed for melee)
- Grades: S = 1.25x, A = 1x, B = 0.75x
- Rank (Solo Leveling-inspired): Shadow = 1, Asset = 2, Ace = 3, General = 4; boosts all stats, never changes grades
- A better rank almost always means a better soldier (intended); grades decide within a rank
- Difficulty tiers are endless; tier 20 = top end game; beating a tier unlocks the next
- Up to tier 20, enemies get stronger through their number and ranks
- Above tier 20: odds and enemy numbers stay as at tier 20; each tier adds +20% damage and HP to every enemy (21: +20%, 22: +40%...); enemies only, not kept when raised or captured
- Enemies per fight: a random number in a range per tier (2-3 at tier 1, 12-15 at tier 20), on the Rank Odds board
- Ranks by tier: Asset from tier 3, Ace from tier 8, General from tier 14; exact rank and grade odds live on the Rank Odds board (source of truth)
- A Chosen above the tier's highest rank fights at that rank
- "Level" means only the player's level (1-15); ranks use a rank number (1-4)
- Effective stat = (Base x Grade) x (1 + (Rank number − 1) x 0.5): Shadow 1x, Asset 1.5x, Ace 2x, General 2.5x
- Rank on enemies: shown on the health bar (default modern WoW retail nameplate style), no effect on the body
- Elites: gold outline on the health bar
- Rank on corpses: faint aura, weaker than on summons but visible
- Rank on summons: an aura that dominates the summon palette
- Aiming at a corpse opens a world widget above it: name, rank, grade of each stat; gold outline for elites
- Holding Alt shows all health bars and all corpse widgets at once
- Higher difficulty tiers: better odds of high grades

## Gear
- Talismans only, no armour: found in hidden chests or dropped by foes
- Talisman target: 2–3 new talismans unlocked per completed run (drop rate set once fight sizes are known)
- Equip 2 before a run; each boosts the stats of one specific spell

## Run
- Current scope: one level with a boss at the end
- The level is outdoors, 5 sections per run, each of about 5 fights, cleared one after another; no going back to a previous section
- Win: kill the boss. Lose: player HP reaches 0
- Difficulty tiers like Mythic+: stronger mobs, better grade odds, more experience

## Art
- Concepts: GPT images → 3D with Meshy AI
- All characters use the UE5 Mannequin skeleton (shared animations, no retargeting)
- Player = 2 skeletal meshes on that skeleton: body without the right arm + the cursed arm alone
- Main character look: horned hood, ornate golden mask with glowing cyan eyes, tattered olive-green mantle, dark leather armour with gold trims and chains, no long coat (trousers, straps, wrapped boots), athletic build close to Manny; reference images/main-character.png
- The dark-magic arm is cyan-turquoise
- Rank colours: Shadow pale green, Asset purple, Ace black with thin silver edge, General deep red with black outline
- Summon aura: overlay on the skeletal mesh material + small smoke, dominates the base material
- Enemy palette (warm): burnt orange #C8641E, ivory #E8DCC0, warm steel #9A9590, tan leather #8A5A34, warm skin #C99A7A
- Summon palette (cold): slate #5E6670, ashen blue-grey #3E4650, corpse pale #A9B0B0, emissive cyan #3FE0D0
- One material per type; a Raised parameter switches enemy palette to summon palette
- Elites: enemy palette, richer: darker saturated orange, dark-bronze armour, bigger trims

## Audio
- Dark neoclassical; the cello always leads the melody
- Phonk elements (slowed drums, sub-bass) only under the cello, still being tested
- Adaptive layers: exploration, combat, boss
- Raising a soldier has an iconic cello motif
- Sound effects: free, commercial-safe only (CC0, Pixabay, CC-BY with credits)

## Production rules
- Everything must be reusable in a future project: generic systems as Actor Components driven by data tables or data assets, interfaces, event dispatchers and Gameplay Tags
- Generic systems in /Game/Systems/<SystemName>/ (or a plugin); Dark Touch content in /Game/DarkTouch/; generic never references Dark Touch content
- Generic names; a README.md per system; systems.md marks each system reusable or game-specific
- Assets (animations, sounds, music) only under licences that allow reuse; source and licence recorded

## Tuning boards (source of truth for data tables)
- Level Unlocks board: https://claude.ai/artifact/NqX8sL4fDcjPXyauHew4vz (ArtifactData collection "progression", doc "order": unlocks for levels 2-15 in order)
- Rank Odds board: https://claude.ai/artifact/DfuKmSVMsquH5RjLVcJHt3 (ArtifactData collection "tiers", one doc per tier, plus collection "economy", doc "spirit": raise costs by rank, grade adjustments, revive % of raise cost (revivePercent), section entry, reap, max Spirit base and per level; tiers docs: enemiesMin, enemiesMax, then shadow, asset, ace, general, gradeS, gradeA, gradeB as whole %)
- Tiers above the last row use the last row's odds

## Validated assets
(Add one line per validated asset: name, file, date.)
- Main character concept, front and back: images/main-character.png, 2026-10-22
