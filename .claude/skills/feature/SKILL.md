---
name: feature
description: Use when the kid wants to add or change something in the game - "idea:", "add …", "can it …", "I want …", a new level, enemy, weapon, mode, menu, or setting. Checks it fits, makes sure the kid understands, then builds it one step at a time.
---

# Feature: fit → teach → plan → quiz → build

Use the gate in `game-plan` section 3: teach → plan → quiz (hints, never the answer) → approve → build. Sections 2–3 below are that gate.

## 1. Does it fit?
1. Read `DESIGN.md` and `PLAN.md`.
2. Say one of:
   - **Yes:** how it works, in 2–4 plain lines.
   - **Yes, but big:** about how many steps, and a smaller version (fewer than 10 steps).
   - **Not possible here:** why, and the closest option.
3. Not in `DESIGN.md`? Ask: "Add it now, or put it in 'Not in v1.0'?"
4. Online game? Say what the host runs and what each player sends.
5. Not kid-friendly (realistic guns, blood, gore)? Say why in one line (the game is for friends of all ages, and it is on a public page). Offer a friendly version with the same fun: splats, tags, bonks, or a "you are out" that is silly, not hurt. Example: a rifle → a tomato throw.

## 1b. A big change (a new theme or the whole game)
Many files change at once, so plan it in layers. Keep the game playable after each card.
1. **Design card first.** Update `DESIGN.md`: the new one sentence, the controls, the art, and a **word list** (old word → new word, for example "rifle → tomatoes"). The kid checks the list. Quiz: "What does <old word> become, and why?"
2. **One card per system** after that: the main action, then each other system (building, pickups, enemies), then art (`create-3d` or `create-2d`), then sound (`create-audio`), then the words on screen, then the player docs and ship.
3. Each card's Output lists every file it changes, including `scripts/tune.gd` names and the tests. Rename a `Tune` value only in the same card that changes every file that uses it.
4. Search the repo for each old word before the last card. Nothing left on screen or in the player docs.

## 2. Teach
Explain how it will work with a game the kid knows. Do not give the plan yet.

## 3. Plan
1. Cards `F<n>` (the next free number in `PLAN.md`): Input, Output, Done when. 5–30 minutes each.
2. Numbered steps. One step = one change the kid can see.
3. New art or sound? Make it its own step with a `create-*` skill.
4. New feel numbers go in `scripts/tune.gd`.
5. Show **Input / Output / Steps / Test**.
6. Quiz: 2–3 questions, one at a time, as in `game-plan` 3.3–3.4. Example: "When the enemy sees you, what does it do first?" Wrong → a hint, never the answer.
7. All right? Ask "Approve this plan?" and stop.

## 4. Build
One step, the checks, then `How:` and `▶ Play:`. Act on the kid's answer as in `game-plan` 3.7.

### 4a. Game feel check
A player must see and hear what happens. Use this list when you write the plan (section 3): each line that fits the feature becomes part of a step. Check it again before `▶ Play:`. A line is still missing? Show a new plan first, as for any change not in the approved plan.
- **Every action answers 3 ways:** a sound, a thing at that spot (a splat, a spark, floating words like "+1 tray"), and a change on the HUD.
- **Hits you make:** a marker on the crosshair and a sound. The player must know the hit landed.
- **Hits you take:** a mark on the screen edge on the side it came from, and a sound.
- **Danger:** say what it is, which way is safe, and how far (an arrow and meters).
- **First time:** a one-line tip at the top until the player does it once. Touch screens get touch words ("Tap THROW").
- **Who is who:** bots and players have names and look different (another colour each). Then a line like "Max splatted Rosa" makes sense.
- **Enemies react:** a hit enemy turns to the one who hit it.
- **Fair start:** the player starts in a safe place, never in danger from second 0.
- **Words agree:** the title, grade, and stats on one screen do not say opposite things (a win with an "F" reads wrong).

### 4b. Robot playtest (a change in how the game plays)
Test it with a robot player before the kid plays. The kid never runs it; you do.
1. No `tools/autoplay.gd` yet? Make it as its own step in the plan, once (`extends SceneTree`, called with `-s`). It:
   - loads the main scene, and plays like a simple player: `Input.action_press` and `Input.action_release` on the Input Map actions to move, jump, fire, and heal. `action_press` makes no mouse motion, so aim by turning the camera nodes directly (for example the yaw and pitch pivots) toward the nearest enemy.
   - prints one `PLAY` line every 2 seconds: time, what it is doing, the HUD numbers.
   - saves a screenshot every few seconds, and the first time something new happens, to `res://.godot/autoplay/` (in the project, so you can read it, and git-ignored). Use `ProjectSettings.globalize_path` for the path.
   - prints a `PLAY_END` line (how it ended, the score) and quits after the seconds you give.
2. Tell the kid: "A game window opens by itself for about 2 minutes. Do not click it." Then run it with a window, not `--headless` (screenshots need a screen): `godot --fixed-fps 30 -s res://tools/autoplay.gd -- 120`.
3. Read every line, then look at the screenshots. Look for: words on top of words, numbers that disagree, a stuck player, a match that ends too fast or never ends, and errors.
4. Balance change? Run it before and after. Put the numbers (time, score, place) in the "stats" column of `PLAYTEST.md`.
5. The robot finds bugs, not fun. Only the kid says if it is fun.

## 5. Done
1. Check "Done when" in play. Online feature: the 2-instance test.
2. Tick the card. Add `Added: <what the kid can do>` to `CHANGELOG.md`. From an issue? End the line with `(#N)`.
3. **Docs for players.** Does the feature change the controls, the rules, or how to play? Ask the kid: "A friend asks: how do I <use it>? What do you answer?" Wrong or unclear → a hint, never the answer. Write the kid's answer, tidied, in `README.md` (How to play, Controls) and, if friends may ask about it, as a question in `FAQ.md`.
4. Ask: "Ship it now?" Yes → `ship`.
