# Dark Touch GDD: changelog from Assignment 1 to Assignment 2

**Compared versions:**
- **Assignment 1:** "GDD - First Draft", 21 October 2026.
- **Assignment 2:** "Second Assignement Final Draft", 26 October 2026.

Both versions are in the submission repository `Charles7598/ELVTR-Assignement-Charles-Marchand`.

## New documents

- **`GDD-full.md`:** a full reference GDD of about 15 pages, with every rule in detail. It sits alongside the 6-page `GDD.md`.
- **`canon.md` becomes the AI-agent version of the GDD.** The three versions (6-page GDD, full GDD, canon) are now updated together whenever a fact changes.
- **New agent: the Environment Scraper.** It finds stylised level assets and posts them on a new Environment Board. The crew grows from 9 to 10 agents.
- **`data/mob-names.csv`:** a list of 200 European first names for the mobs' random names.
- **Images:** the validated main-character concept (front and back) and an arm reference.

## Combat

- **Moving and casting:** "no casting while moving" now has named exceptions: Splinters, Grasp, Frenzy, Hunger and Rot.
- **GCD:** the 1 s global cooldown now applies to every spell except Reap.
- **Cast times** are now set: Deathbolt 1.75 s; Unholy Impale and Death Nova 2 s.
- **Stun sources** are now named: the Mage's charged spell and the Blademaster's parry.
- **Damage** is always rounded **down** to a whole number. The direction was an open question before.
- **Controls:** the bar grows from 14 to 18 slots (A, E, R, F, 1–5, with and without Shift): 12 spells, 3 golden-slot abilities and 3 command-group keys.

## A real rotation

- **Rotation section:** the "work in progress" note is replaced by a full **Rotation** section, with a 6-step priority list. Fillers build Souls, spenders consume them.
- **Souls:** cap of 6, 3 per spender. Deathbolt gives 1, Splinters 1 (2 with a proc), Rot none.
- **Splinters proc:** each player hit has a 10% chance to give a free charge and double its next hit, with up to 2 procs held.
- **Free spender proc:** each enemy hit by Splinters has a 5% chance to make the next spender cost no Souls.
- **Power of Below,** a new offensive cooldown: GCD 0.75 s, cast times halved, spenders instant, Splinters recharging in 3 s.

## Abilities

- **Death Trap replaced by Hunger:** it eats one of your own soldiers to heal you, capped at 30–60% of your max HP depending on its rank. The soldier becomes a corpse again.
- **Flying Filthy Dagger replaced by Rot:** a hitscan curse that deals damage every second for 10 s and can sit on several enemies at once.
- **Splinters** is defined: instant, 30° cone from a narrow base, 2 charges recharging in 5 s each.
- **Reap** no longer gives Souls. It gives a 10 s buff plus a choice: 5 Spirit (left click) or 20% of max HP over a 2 s cast (right click).
- **Unlocks:** 7 spells are available at the start; 5 more (Grasp, Swap, Frenzy, Rot, Power of Below) unlock by player level. This replaces "all spells from the start".
- **Names:** all are final except Deathbolt and Death Nova.

## Resources and economy

- **Spirit** gets real numbers:
  - **Pool:** max 100 at level 1, +20 per level, no regeneration.
  - **Gains:** 50 on entering each section, 5 per Reap.
  - **Raise cost:** 50 (Shadow) to 150 (General), ±10 per grade, so 20 to 180.
  - **Revive cost:** 60% of the soldier's raise cost.
- **HP** has no regeneration; it is healed only by Hunger and by Reap for HP.
- **No currency:** there is still no gold and no shop.

## Necromancy and the army

- **Raise** costs Spirit by rank and grades. This replaces the rule "any mob at or below the player's level".
- **Orders:** each command group's key swaps the action bar to its orders: **Attack**, **Protect** and **Move**.
- **3 golden slots:** a soldier placed there gives its type's ability to the player as a spell.
- **Collection and Chosen:** the "starting soldiers" are replaced.
  - **The collection** holds every soldier raised and won with.
  - **Chosen:** each run, the player brings 0 to 3 of them, depending on player level.
- **Fallen soldiers:** any fallen soldier can be revived for 60% of its raise cost. A raised soldier not revived before the player leaves the section is lost for the run.
- **Elites become a capture system,** Pokémon-style. A raised elite goes to the collection at the base, keeps its status and stats, but is lost if the run is lost.
- **Ranks:**
  - **Display:** rank colours appear on health bars, as a faint aura on corpses and as a strong aura on soldiers.
  - **Grade widget:** aiming at a corpse shows its rank and grades; holding Alt shows every corpse at once.
  - **Formula:** it now uses the rank number instead of "level".
- **New soldier type: the Berserker.** It leaps onto its target and uses Whirlwind.
- **Mage and Blademaster:** the Mage's charged spell and the Blademaster's parry now **stun**.

## Run structure and progression

- **Level layout:** outdoors, 5 sections of about 5 fights, cleared in order with no going back. This replaces "a mix of rooms and open areas".
- **Difficulty:** endless Mythic+-style tiers, 20 being the top end game.
  - Enemies come in larger numbers and higher ranks: Asset from tier 3, Ace from tier 8, General from tier 14.
  - Above tier 20, each tier adds +20% HP and damage to enemies.
- **Player level:** max 15. Levels 2 to 15 unlock 5 spells, 6 variant slots and 3 Chosen slots (Level Unlocks board).
- **Talismans:** the target is 2 or 3 new ones per completed run.
- **Tuning boards** for the numbers: Level Unlocks and Rank Odds.

## Art direction

- **The main character's look is validated:** horned hood, golden mask with cyan eyes, olive mantle, dark leather armour with gold trims, no long coat.
- **The dark-magic arm** is defined: non-physical, translucent, cyan-turquoise, able to strike, grab and hold.
- **Readability palettes:** enemies are warm (burnt orange, ivory, warm steel), summons are cold (slate, ashen blue, emissive cyan). One material per type has a "Raised" switch.
- **Elites** get a richer enemy palette. Rank colours are refined.
- **Environment assets:** stylised and slightly desaturated, reviewed on the Environment Board.

## Production

- **Production line:** says the scope is knowingly ambitious, and that the designer will keep polishing for a month or more after the course.
- **Reusability rules:** generic data-driven systems, one README per system, and assets only under reusable licences.
- **Tokens:** the budget rises from about 6M to about 6.3M tokens with the Environment Scraper.

## Open questions

- **Closed:** the ability kit and rotation, casting while moving, Spirit gains, stun sources, damage rounding, the name list, how revives work, how elites are kept, the level rule for raising, the orders, how difficulty tiers scale.
- **Opened:** Power of Below's duration and cooldown, the Splinters cone length, the Berserker's details, whether the collection has a size limit, the special capture mechanic, revives during combat.
