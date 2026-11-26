---
name: create-background
description: Use when the game needs a background, sky, or menu backdrop - "add a sky", "the background is boring", "make it night", "a title screen picture". 2D - layered parallax art. 3D - a sky, light colour, and fog. Uses the DESIGN.md palette.
---

# Create a background

Use the gate in `game-plan` section 3: teach → plan → quiz (hints, never the answer) → approve → build. One background = one step.

## 1. Ask
1. Where (game, title screen, end screen)?
2. Time and mood: day, sunset, night, storm, underground, space?
3. Busy or calm? The background must never hide the player, enemies, or pickups.

**Teach, plan, quiz:** Explain how it works in 1–2 lines (for example: "far layers move slower than near ones, so it looks deep"). Show the plan: the file, the way you make it (Claude, CC0, or the kid), and where it goes in the game. Quiz with 1–2 questions, one at a time (for example: "Which layer moves faster when you run: the near hills or the far sky?"). Wrong → a hint as in `game-plan` 3.4, never the answer. All right? Ask "Approve this plan?" and stop.

## 2. 2D
1. 2–3 layers, far to near. Make each one with `create-2d` (SVG shapes work well: hills, clouds, stars).
2. Put each layer in a `Parallax2D` node. Far layers move slower (`scroll_scale` 0.2–0.5).
3. Far layers use the palette's darkest or lightest colour, with low contrast. The game layer has the strongest contrast.
4. Title screen: one layer, plus the game title as a `Label` with a theme font.

## 3. 3D
1. A `WorldEnvironment` in the main scene with an `Environment` resource:
   - Sky: `ProceduralSkyMaterial`. Set the top, horizon, and ground colours from the palette.
   - Ambient light from the sky, so dark sides are not black.
   - Fog: only if the mood needs it. Test it on the Web build. If it does not show there, take it out.
2. One `DirectionalLight3D` as the sun. Its angle and colour set the time of day.
3. Night: a dark blue sky, a low cool light, and bright palette colours on the things the player must see.

## 4. Rules
- Compatibility renderer: no volumetric fog, no SDFGI, no screen-space effects.
- Make sure the main action is easy to see on a phone screen in the sun.
- Add the art to `CREDITS.md`.

## 5. Show it
`▶ Play: <where> — look for <the new background>`, and check the player is still easy to see. Ask "keep, change, or undo?".
