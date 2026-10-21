# Dark Touch — Art Direction

Part of the [Dark Touch GDD](GDD.md). Decisions only; open points are in [Open questions](open-questions.md).

## Style

Stylised, in the spirit of **Fellowship**. The world is Cel'ardor, a continent at war (see [Lore](lore.md)).

## Pipeline

1. Concept images created with GPT image generation.
2. 3D characters generated from those images with **Meshy AI**.
3. Characters rigged to the UE5 Mannequin skeleton (see below).

## Skeleton and character setup

- **Every character uses the UE5 Mannequin skeleton**, so animations are shared without retargeting.
- **The player is made of two skeletal meshes** on that same skeleton: the body without the right arm, and the cursed arm alone. The arm gets its own material and effects without touching the body.

## The weapon: the dark-magic arm

The player fights without a blade. One arm is spectral, glowing with dark magic, with clawed fingers and trailing wisps and particles. It is the game's visual signature and **must stand out in every animation**: casting, raising, reaping and idle all need a distinctive effect on the arm.

## Rank auras

A cool overlay on the character's skeletal mesh material, plus a little smoke whose colour shows the soldier's rank:

| Rank | Aura |
| --- | --- |
| Shadow | Pale green |
| Asset | Purple |
| Ace | Black |
| General | Red with a black outline |

## Elites

Any mob can be an elite: it has an aura, a slightly different colour palette, and a stat boost over the normal version.
