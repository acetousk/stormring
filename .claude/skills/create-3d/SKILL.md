---
name: create-3d
description: Use when a 3D game needs a model - a player, enemy, weapon, item, building, tree, rock, or vehicle. Builds original low-poly models from Godot primitive meshes in the DESIGN.md palette, so they run on web and phones.
---

# Create a 3D model

Use the gate in `game-plan` section 3: teach → plan → quiz (hints, never the answer) → approve → build. One model = one step.

## 1. Ask (one question at a time, skip what DESIGN.md already says)
1. What is it, and what does it do?
2. About how big, next to the player (the player is about 1.8 m)?
3. The 2–3 shapes that make it look right (for example "a box body, a round head, a cone hat").

**Teach, plan, quiz:** Explain how you will make it in 1–2 lines (for example: "3 boxes and a ball, each with a palette colour, put together in one scene"). Show the plan: the file, the way you make it (Claude, CC0, or the kid), and where it goes in the game. Quiz with 1–2 questions, one at a time (for example: "Why do we use only a few shapes, not many?"). Wrong → a hint as in `game-plan` 3.4, never the answer. All right? Ask "Approve this plan?" and stop.

## 2. Make it, in this order
1. **You make it from primitives.** One scene per model in `models/` (for example `models/tree.tscn`):
   - `Node3D` root → `MeshInstance3D` children with `BoxMesh`, `SphereMesh`, `CapsuleMesh`, `CylinderMesh`, `PrismMesh`, or `TorusMesh`.
   - A `StandardMaterial3D` per palette colour, saved as `.tres` in `models/materials/`, so models share them.
   - Collision: one simple shape on the body (box or capsule), not one per part.
2. **A CC0 model** (for example a kenney.nl kit, `.glb`). The kid downloads it and puts it in `models/`. You never download.
3. **The kid's own model** in Blender (free). Tell the kid: keep it low-poly (3–12 parts), use the palette colours as materials, apply the scale (Ctrl+A → Scale), then File → Export → glTF 2.0, format `.glb`, into `models/`. Godot imports it by itself.

## 3. Rules
- Use only the `DESIGN.md` palette. No textures in the first playable.
- Original only. Never copy another game's characters, weapons, or look.
- Keep it low: about 3–12 parts per model.
- Many of the same thing (trees, rocks, grass): use `MultiMeshInstance3D`, not hundreds of nodes.
- Make the front easy to see (a nose, a visor, or a colour stripe), so the kid can see where it faces. The front is -Z in Godot: eyes and noses go on the -Z side, so `look_at` turns it the right way. Imported `.glb` models face +Z: turn them 180° in their scene, or use `look_at(target, Vector3.UP, true)`.
- A character needs a head, a body, two arms, and eyes. Without arms or a face it looks like a block from far away.
- Many copies of one character (bots, enemies): give each copy its own palette colour (duplicate the material per copy). Never use a colour that has a meaning in the game for this (for example red = hurt).
- Add it to `CREDITS.md`: file, who made it, license.

## 4. Show it
Look at it yourself first: put it next to the player and take a screenshot. Run with a window (not `--headless`), wait for `await RenderingServer.frame_post_draw`, then `get_viewport().get_texture().get_image().save_png(...)` into `res://.godot/` (or use the robot playtest in `feature` 4b). Check the size, the colours, and the front. Then put it in the main scene in the same step. `▶ Play: <where to look> — look for <the model>`. Ask "keep, change, or undo?".
