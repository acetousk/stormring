---
name: create-2d
description: Use when a game (2D or 3D) needs a sprite, tile, item, icon, button, or UI image, or a new look for its screens - "make the player look like …", "draw an enemy", "new icon", "make the menu look like …", "the screens look boring". Makes original art in the DESIGN.md palette, as SVG or as PNG from a script.
---

# Create 2D art

Use the gate in `game-plan` section 3: teach → plan → quiz (hints, never the answer) → approve → build. One asset = one step.

## 1. Ask (one question at a time, skip what DESIGN.md already says)
1. What is it, and what does it do in the game?
2. Size on screen: small (16–32 px), medium (64 px), or big (128+ px)?
3. Style from `DESIGN.md`: pixel art, flat shapes, or outline?

**Teach, plan, quiz:** Explain how you will make it in 1–2 lines (for example: "the script reads a grid of letters, and each letter is one palette colour pixel"). Show the plan: the file, the way you make it (Claude, CC0, or the kid), and where it goes in the game. Quiz with 1–2 questions, one at a time (for example: "If you change one letter in the grid, what changes in the game?"). Wrong → a hint as in `game-plan` 3.4, never the answer. All right? Ask "Approve this plan?" and stop.

## 2. Make it, in this order
1. **You make it.**
   - Flat shapes or outlines → an SVG file in `art/`. Godot imports SVG as an image.
   - Pixel art → a script `tools/make_art.py` that writes PNG files to `art/`. Use only the Python standard library (`zlib`, `struct`). Each sprite is a grid of palette letters in the script, so the kid can change a pixel and run it again.
2. **A CC0 asset** (for example from kenney.nl or opengameart.org, filtered to CC0). The kid downloads it and puts it in `art/`. You never download.
3. **The kid's own drawing.** Suggest a free program: Krita (painting), Inkscape (shapes, SVG), LibreSprite or Piskel (pixel art; Piskel runs in the browser). The kid saves PNG or SVG in `art/`, in the palette colours.

## 3. Rules
- Use only the `DESIGN.md` palette hex colours. One colour more needs the kid's yes.
- Original only. Never copy another game's characters or look.
- Pixel art: set `rendering/textures/canvas_textures/default_texture_filter` to Nearest in `project.godot` once.
- Make sure the player, enemies, and pickups look different by shape and colour, not by colour alone.
- Max 512 × 512 px per image (web and phones).
- Add every asset to `CREDITS.md`: file, who made it, license (`made with tools/make_art.py`, `CC0 from …`, or the kid's name).

## 4. Screens and menus ("make the screens look like …")
Use this for the start screen, the HUD, and the end screen, in 2D and 3D games.
1. **Ask what the look is made of.** One question: "What real thing do these screens look like?" (a school, a comic, a space ship). Write the answer and its colours in `DESIGN.md` under "UI style".
2. **One bold thing.** Pick one screen element to be the memorable one (for example a chalkboard start screen). Keep the rest quiet and simple. Ask the kid which element it is, as a quiz with a hint.
3. **One Theme.** Make one `ui/<name>.tres` Theme with the palette colours (StyleBoxFlat for panels and buttons, font sizes, a clear focus style for keyboard and gamepad). Set it on each screen's top Control. Do not colour each node by hand.
4. **Real things from simple parts:** StyleBoxFlat (borders, corners, shadows), a small `canvas_item` shader for a texture (chalk, paper, metal), and SVG for small pictures. No downloaded fonts: use Godot's built-in font, made bigger or bolder in the Theme.
5. **Words fit the look:** the HUD and buttons use game words in sentence case (for example "Report card", not "GAME OVER").
6. **Check it fits:** the text must be easy to read and fit on a 1280×720 window and on a phone. Hide the HUD behind the end screen.

## 5. Show it
Put it in the game in the same step. `▶ Play: <where to look> — look for <the new art>`. Ask "keep, change, or undo?".
