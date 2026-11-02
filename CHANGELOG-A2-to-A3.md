# Dark Touch GDD: changelog from Assignment 2 to today

**Compared versions:**
- **Assignment 2:** "Second Assignement Final Draft", 26 October 2026.
- **Today:** the project repository as of 2 November 2026.

Changes come from the designer's answers in the review inbox (IDs W1-…) and from his decisions in chat, during week 1 of production.

## Engine and how the game is built

- **Engine:** Unreal Engine 5.8. **All gameplay code is now C++, written by the agents.** Blueprints are thin subclasses that only assign assets, and the designer builds nothing by hand. This replaces "Blueprints, C++ only for optimisation".
- **Reusable systems** are C++ components in a `GameSystems` plugin, one module per system. Each has data tables, interfaces, delegates and an automation test for every rule with a number.
- **New production rules:**
  - **"Whole first, then polish":** a feature arrives complete on every layer, then gets polished.
  - **"Verify before handing over":** build, tests, PIE and log checks, enforced by a hook. After 3 failed tries, the error goes to the designer.
- **Python Editor Script Plugin:** enabled for editor tooling only (importing and retargeting animations). No gameplay logic in Python.

## Lore and world

- **Magic:** only the **dragonkin** can wield magic. A human body cannot withstand it without special gear.
- **Peoples:**
  - **Mage:** dragonkin.
  - **Guard, Rogue and Blademaster:** human. The Blademaster's gear grants him a little magic, and his reflecting parry is that magic.
  - **Tank and Berserker:** **bull warriors**, resistant to magic. They can infuse their gear but cannot cast spells.
- **The player** is now a **half-dragonkin, half-human** who had never wielded magic: the arm is his first magic. He used to be "a mage who lost an arm". The line "mages need both arms" is removed.

## Combat (week 1 prototype decisions)

- **Camera:**
  - Over the shoulder, with a fixed crosshair at the exact screen centre.
  - Spring arm offset (X=20, Y=50, Z=70), default length 200, mouse-wheel zoom from 50 to 600.
  - The mouse always controls the camera.
- **Aiming:** a trace from the camera through the crosshair; the spell leaves the hand toward the impact point. A switch compares raw aim with soft-target assist.
- **Moving and casting:** every instant spell can be cast while moving. The restriction now applies only to spells with a cast time.
- **GCD:**
  - Set per spell in the data.
  - Reap now has its own 0.5 s GCD; it used to be off the GCD.
  - The GCD starts at the beginning of the cast.
- **Spell queue,** WoW-style: the next spell can be pressed shortly before the end of the GCD or the cast. The queued button pulses gold. Stuns and jumps clear the queue.
- **Pushback:** every hit pushes the cast back 1.5 s, with no limit, down to 0 s. A stun cancels the cast. Moving or jumping cancels it with a grey "Cancelled" state.
- **Movement copies WoW:** 640 cm/s forward, sideways and backward, a WoW-like jump and gravity, no air control. Running backward turns the character around instead of a backpedal walk.
- **Keyboards:** QWERTY and AZERTY are both supported automatically, number row included.
- **Provisional week-1 numbers:** player 1000 HP, training dummy 400 HP, Deathbolt 60 damage, spell queue window 0.4 s, projectile 5000 cm/s.
- **Bull warriors** (Tank, Berserker) **cannot be stunned**, as enemies and as soldiers.

## Abilities

- **Death Nova renamed Raw Nova.** Deathbolt keeps its name, so all ability names are now final.
- **Power of Below:** lasts 15 s, every 120 s (provisional); unlocked by player level.
- **Splinters:** the cone is 40 m long (provisional, to check in play).

## Army and soldiers

- **Revives during combat:** casting **Raise on a dead summon** revives it.
- **Berserker targeting:** melee soldiers first, the strongest first.
- **Tank and Berserker** are marked as bull warriors in the soldier table.

## User interface

- **HUD:** the player's HP bar sits below the action bar; enemy HP bars float above their heads.
- **Enemy health bars:**
  - **Size and range:** 120 × 12 px, shown within 50 m, with no value text.
  - **Elites:** a gold frame.
  - **Names:** no name over a living mob. The name appears after its death, or when the unit is selected with a left click.
  - **Rank symbol** left of the bar: circle (Shadow), rhombus (Asset), rounded square (Ace), faceted diamond (General). The shapes are provisional.

## Art direction

- **The player is one skeletal mesh,** body and cursed arm together, with its own "Arm" material slot. It used to be 2 meshes; the split caused more problems than it solved. Only the long cloak strips are simulated cloth.
- **Enemy references** for the Berserker, Mage, Blademaster and Tank, with the key traits of each.
- **Bull warriors keep their hooves:** each hoof is weighted entirely to the `foot` bone, and the toe bones carry no weight.
- **Concept rules for 3D:**
  - Cloth stays short below the hips, so no cloth simulation is needed.
  - Weapons and shields are separate meshes attached to the hand.

## Animation (new section in the canon)

- **Sources:**
  - **Locomotion:** GASP.
  - **One-hand casts:** Rokoko free pack and Mixamo.
  - **Hit reactions:** Mixamo "Small" reacts only, played on the upper body so the character keeps running and never steps back.
- **Pipeline:**
  - Mixamo clips go through Mixamo Converter onto the UE5 Mannequin.
  - Raw FBX source files are never committed; only the imported assets are.

## Audio and music

- **No phonk for now.** It will be tested only if the music lacks impact; the cello stays the lead.

## The agent crew

- **Three new agents:** **Producer** (plan and milestones), **Level Designer** (sections, fights, boss, onboarding) and **Balance Analyst** (Python simulations of the numbers). The crew grows from 10 to 13 agents.
- **Review flow:** the Producer sets the week's goal, and the Balance Analyst checks the numbers before a build. Every builder verifies its own work before review.
- **Gameplay Programmer and Technical Director** now use the build and test scripts as well as the UE5 MCP.
- **Tokens:** the budget rises from about 6.3M to about 7M tokens, about $37 in API-equivalent value.

## Open questions

- **Closed:** names for Deathbolt and Death Nova, Power of Below's duration, cooldown and unlock, the Splinters cone length, Berserker targeting, revives during combat, how enemy health bars show rank and names, how much phonk to use.
- **Opened:** does the bull warriors' magic resistance become a combat rule (less spell damage, resistance to roots), or stay lore only?
- **Still open:** soft-target assist versus raw aim. A switch now lets the designer compare both in week 1.
