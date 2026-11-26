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

## 5. Done
1. Check "Done when" in play. Online feature: the 2-instance test.
2. Tick the card. Add `Added: <what the kid can do>` to `CHANGELOG.md`. From an issue? End the line with `(#N)`.
3. **Docs for players.** Does the feature change the controls, the rules, or how to play? Ask the kid: "A friend asks: how do I <use it>? What do you answer?" Wrong or unclear → a hint, never the answer. Write the kid's answer, tidied, in `README.md` (How to play, Controls) and, if friends may ask about it, as a question in `FAQ.md`.
4. Ask: "Ship it now?" Yes → `ship`.
