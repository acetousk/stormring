---
name: new-game
description: Use when the kid wants to start a game ("make a game", "new game", "make a … clone"), or when there is no DESIGN.md. Takes the kid from an idea to a released v0.1.0 that plays online on all 4 platforms.
---

# New game: idea → v0.1.0

Use the gate in `game-plan` section 3: teach → plan → quiz (hints, never the answer) → approve → build. Do it for G1, and again at the start of each card G2–G7.

## 0. First run
No `DESIGN.md`? Do the first run in `AGENTS.md`. It uses the `doctor` skill.

## 1. The idea
- A copy of a real game ("a … clone")? Say **Not possible here**: we can't copy its name, characters, art, map, or music. Name the parts of the genre we can make. Offer an original game with those parts.
- Too big (open world, MMO, 100 players)? Offer a small version that fits the budget.

## 2. Card G1: design + scope (5 min)
Ask **one question at a time**. Wait for each answer.
1. 2D or 3D?
2. What are you?
3. How do you move?
4. What is the main action?
5. How do you win? How do you lose?
6. Online: 2–4 players. What does the host run (enemies, score, timer)?
7. A palette: show 3 choices of 5 hex colours with names. The kid picks one.

Write `DESIGN.md`. Count the steps for G2–G7. Over 65 steps? List the parts that cost the most. The kid cuts. Put the cuts in "Not in v1.0".

Show the plan for G2–G7. Quiz with 3 questions, one at a time, as in `game-plan` 3.3–3.4:
- "In your own words: what does the player do, and how do they win?"
- "Which card makes the game online, and what does the host do?"
- "After card G2, what will you see when you press F5?"

Wrong → a hint, never the answer. All right? Ask "Approve this plan?" and stop.

At the start of each card G2–G7: say what the card makes, then ask 1–2 questions about it (for example G4: "What will make you lose?"). Build after a right answer and a yes.

## 3. Cards G2–G7
Budget: about 75 minutes of your work, about 65 steps.

| Card | Budget | Steps |
|---|---|---|
| G2 Core loop | 15 min | World → `Tune` → player → movement → main action → camera → tune → stay inside the play area |
| G3 Goal | 10 min | One goal → progress display → enough for 1–3 minutes → win → a small effect |
| G4 Pressure | 10 min | One threat → its cost + a short safe time → display → lose → a 2nd threat or more speed → tune |
| G5 Online | 15 min | The kid installs GD-Sync → `scripts/net.gd` in local mode → host or join a room by a 4-digit code → sync the players → the host runs the game state → a 2-instance test. In solo, show no network text. Then the `online` skill for keys (needed by v0.1.0, so friends can join). |
| G6 Flow + sound + touch | 12 min | Start screen ("Click or tap to start") → end screen → play again 3 times → touch controls → sounds (`create-audio`) → the kid plays a full game and names one fix |
| G7 Ship | 8 min | Title + icon → the fix → use the `ship` skill for `v0.1.0` |

Art: use `create-2d` or `create-3d`, `create-background`, and `create-environment` inside the cards. Keep each asset to 1 step.

First playable: no animation, saving, or extra levels. Over the budget? Skip the tune and effect steps.

## 4. Human-only steps
Some steps need the kid's hands in Godot. Say exactly where to click. Then stop and wait for `done`:
- G5: AssetLib → search "GD-Sync" → Download → Install → Project → Project Settings → Plugins → GD-Sync → On.
- 2-instance test: Debug → Customize Run Instances → Enable Multiple Instances → 2 → F5.
- After your edits, Godot may ask "Reload from disk?". Tell the kid once: click **Reload**.

## 5. After v0.1.0
Ask what the kid wants next. Use `feature`, `bug`, or `game-plan` section 5 (tune).
