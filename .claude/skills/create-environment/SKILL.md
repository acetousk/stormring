---
name: create-environment
description: Use when the game needs a level, map, arena, island, dungeon, track, or world layout - "make a level", "a bigger map", "add walls", "random dungeons". Builds the play area, its walls and props, spawn points, and limits, so it runs on web and phones.
---

# Create an environment (level or map)

Use the gate in `game-plan` section 3: teach → plan → quiz (hints, never the answer) → approve → build. One area or one level = one card.

## 1. Ask (one question at a time)
1. What is the place, and what happens there?
2. Made by hand (the same each time) or random each game (a seed)?
3. How big? Say it as time: "about 20 seconds to run across".
4. Online: where do 2–4 players start, and is it fair for each one?

**Teach, plan, quiz:** Explain how it works in 1–2 lines (for example: "the map is a grid; each letter becomes a tile or a wall"). Show the plan: the file, the way you make it (Claude, CC0, or the kid), and where it goes in the game. Quiz with 1–2 questions, one at a time (for example: "On the text map, where do you start, and where is the exit?"). Wrong → a hint as in `game-plan` 3.4, never the answer. All right? Ask "Approve this plan?" and stop.

## 2. Lay it out first
Draw a top-down text map in the plan, for example:
```
#########
#P..c..E#    P start  E enemy  c chest  # wall
#..###..#
#E..c..P#
#########
```
Show this map as part of the plan, before the quiz. The kid approves the map before you build it.

## 3. Build it
**2D**
- Tiles from `create-2d` in a `TileSet`, placed with a `TileMapLayer`.
- Random maps: a script `scripts/map_gen.gd` that fills the `TileMapLayer` from a seed. Check that each start can reach the goal.

**3D**
- Ground: a `MeshInstance3D` with a `PlaneMesh` or a few boxes, and a `StaticBody3D` with a simple collision shape.
- Props from `create-3d`. Many of the same → `MultiMeshInstance3D`.
- Walls and buildings: boxes with one collision box each.
- Bots that walk: a `NavigationRegion3D` (2D: `NavigationRegion2D`). Bake it after the layout is done.

**Both**
- Spawn points as `Marker2D` / `Marker3D` in a group `spawns`. The host picks them.
- Play-area limits: walls, water, or a kill floor. The player can never fall out of the world.
- Size numbers (width, number of enemies, chest count) go in `Tune`.

## 4. Speed
- Web and phones: aim for under about 200 visible meshes in 3D, and one shadow light.
- Big maps: hide far parts (`visibility_range_end` on `GeometryInstance3D`).
- Ask the kid to check speed on the web link and the phone after the next `ship`.

## 5. Show it
`▶ Play: run to each corner — look for walls you can't pass and no holes`. Ask "keep, change, or undo?".
