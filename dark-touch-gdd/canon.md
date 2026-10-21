# Dark Touch — Canon

Validated facts only. The Game Director reads this file first on every review.
Only the game designer validates a fact; agents may propose additions, never write them unapproved.
Source of truth for anything not listed here: GDD.md and its companion documents.
Last validated: 2026-10-21

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
- No casting while moving, unless an ability says otherwise
- Global cooldown: 1 s
- Damage and HP loss are always rounded to whole numbers
- No dodge: enemy windups are answered by stopping a cast and moving away
- Controls: rebindable; defaults A, E, 1-5 and Shift + the same (14 slots for spells, command groups, orders)
- Taking a hit pushes the current cast back by 1.5 s; only stuns interrupt a cast
- Fillers build Souls, spenders consume them

## Resources
- Spirit: abilities and reviving starting soldiers
- Souls: short-loop resource, Soul Shard-style; gained by kills and Reap
- No currency: no gold, no shop

## Abilities (names not final unless marked)
- Aimed: Deathbolt, Unholy Impale, Flying Filthy Dagger, Swap, Raise, Reap (soft targeting decided in prototyping)
- Cone toward the aim: Splinters. Ground circle: Death Nova, Grasp, Death Trap
- Demo: all spells available from the start; experience and levels unlock variants
- Deathbolt: single-target filler
- Unholy Impale: single-target spender
- Splinters: AoE filler
- Death Nova: AoE spender
- Grasp: root
- Swap: swap places with a soldier
- Frenzy: timed buff on soldiers
- Death Trap: placed trap
- Flying Filthy Dagger: thrown dagger, poison debuff
- Reap: consume a corpse for Souls + 10 s buff (variants: HP regen, damage, speed)
- Each ability has 2 unlockable variants (Reap has 3); variants not yet defined

## Army
- Weapon: a spectral dark-magic arm (no blade); it must stand out in every animation
- Raise: performed with the dark-magic arm, cast time, must be close, any mob at or below player level
- 10 army slots max at endgame
- No orders: soldiers attack the first enemy they see
- 3 command groups, set by drag and drop in the army tab
- Dismissing a soldier frees its slot; bound (starting) soldiers cannot be dismissed
- Starting soldiers: 1, up to 3 with levels and talents; never lost
- Raised soldiers: kept only on a win
- All kept soldiers revive automatically when a run ends

## Soldier roster (enemies and soldiers share it)
- Guard: sword and shield footman; sometimes shields up (stands, turns slowly). Player ability: Guard, damage reduction for 1.5 s
- Mage: ranged arcane bolts; occasional long charged spell for massive damage; focuses its biggest threat. Player ability: TBD
- Rogue: dual blades, fast, high damage, squishier than Guards; focuses player and elites; 1 s windup then dash through normal mobs. Player ability: TBD
- Tank: armoured, slow, hits hard, very tough. Player ability: Taunt (all nearby enemies focus the Tank, Rogues included)
- Blademaster: two-handed, sturdy, hits hard, fairly fast; occasional parry with a visible windup, sends damage back. Player ability: Parry (sends an attack back at 2x damage)
- Elites: any mob can be one; aura, slightly different palette, stat boost

## Names and grades
- Every mob gets a random name from a very large list
- Alive, all mobs of a type share the same stats
- Hidden grades rolled at random, one per stat: Vitality (max HP), Attack (damage), Speed (cast speed for ranged, movement speed for melee)
- Grades: S = 1.25x, A = 1x, B = 0.75x
- Rank (Solo Leveling-inspired): Shadow = 1, Asset = 2, Ace = 3, General = 4; boosts all stats, never changes grades
- Effective stat = (Base x Grade) x (1 + (Level − 1) x 0.5): Shadow 1x, Asset 1.5x, Ace 2x, General 2.5x
- Hovering a corpse shows its name, grades and rank
- Higher difficulty tiers: better odds of high grades

## Gear
- Talismans only, no armour: found in hidden chests or dropped by foes
- Equip 2 before a run; each boosts the stats of one specific spell

## Run
- Current scope: one level with a boss at the end
- Win: kill the boss. Lose: player HP reaches 0
- Difficulty tiers like Mythic+: stronger mobs, better grade odds, more experience

## Art
- Concepts: GPT images → 3D with Meshy AI
- All characters use the UE5 Mannequin skeleton (shared animations, no retargeting)
- Player = 2 skeletal meshes on that skeleton: body without the right arm + the cursed arm alone
- Rank aura: overlay on the skeletal mesh material + small smoke; Shadow pale green, Asset purple, Ace black, General red with black outline

## Audio
- Dark neoclassical; the cello always leads the melody
- Phonk elements (slowed drums, sub-bass) only under the cello, still being tested
- Adaptive layers: exploration, combat, boss
- Raising a soldier has an iconic cello motif
- Sound effects: free, commercial-safe only (CC0, Pixabay, CC-BY with credits)

## Validated assets
(Add one line per validated asset: name, file, date.)
