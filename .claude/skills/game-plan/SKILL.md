---
name: game-plan
description: Use for every request in this game repo that changes a file - a new game, feature, bug, feeling ("too hard"), art, sound, or release. Sorts the request to the right skill, makes a plan, quizzes the kid, and gets approval before any edit.
---

# Game plan: understand → plan → quiz → approve → build

## 0. First run done?
No `DESIGN.md`, and the parent did not say "skip the first run"? Stop. Do the first run in `AGENTS.md`.

## 1. Work out the request
Sort it, then go on:

| Request | Do |
|---|---|
| A quick question | Answer it. No plan. |
| "How does X work?", "explain …" | `explain` skill |
| A feeling ("too hard", "boring"), or "Tune round" | Section 5 |
| Setup or build trouble | `doctor` skill |
| A new game, or no `DESIGN.md` | `new-game` skill |
| A bug | `bug` skill |
| A new feature or change | `feature` skill |
| Art, sound, a background, or a level | `create-2d`, `create-3d`, `create-audio`, `create-background`, `create-environment` |
| Ship, release, publish | `ship` skill |
| Online rooms, "play with friends", GD-Sync keys | `online` skill |
| "Make a skill", "every time I say …" | `create-skill` skill |
| Anything else | Go on |

The skills use sections 2–3 below.

Read only the files you need. Find how to do it in Godot 4.7.2 on all 4 platforms.

## 2. Say if it is possible
- **Yes:** how it works, in 2–4 plain lines.
- **Yes, but big:** about how many steps, and a smaller version that fits.
- **Not possible here:** why (engine, platform, budget, or an `AGENTS.md` rule), how the real thing works, and the closest option.

Not in `DESIGN.md`? Ask: add it now, or put it in "Not in v1.0"?

A vague ask ("make it better")? Ask for the goal: what, why, and how the kid will know it worked. Ask "like what?" to get a "like X" example. Use it to understand; never copy it.

## 3. The gate: plan → quiz → build
Every skill that changes a file uses this gate. No edit before the kid passes the quiz and says yes.

1. **Teach the idea.** Explain how it will work in 2–4 plain lines. Use a game or a thing the kid knows. Not the code.
2. **Show the plan.** Write cards: ID, Input, Output, Done when. One card = 5–30 minutes. Bigger → more cards. Give each card numbered steps. One step = one change the kid can see, about 1 minute of your work. Show **Input / Output / Steps / Test**.
3. **Quiz.** Ask 2–3 short questions, one at a time. A small change (a typo, one number) needs 1 question. Ask the kid to predict or reason, not to repeat words:
   - "What will you see change when you press F5?"
   - "Why does <part> need to happen before <part>?"
   - "If I made <number> bigger, what would happen?"
   - "How will you test that it works?"
4. **Teach, don't tell.** A wrong or unsure answer? Never give the answer. Give the next hint, then ask again:
   1. A smaller question that leads to the answer ("What happens to the ball when it hits the floor?")
   2. Point to a line of the plan, or a thing in the game to look at
   3. A picture from real life with the same idea
   4. Still stuck after 3 hints? Say: "Ask me a question about the part that is not clear." Answer only that question, in a few lines, with a hint inside it, not the full answer. Then ask a **new** quiz question, not the same one.
   A right answer? Say what was right about it in one line. Then the next question.
5. **Approve.** All questions right? Ask "Approve this plan?" and stop.
   The kid says "just do it" or "skip the quiz"? Say once: "I build only what you understand. One question, then we go." Ask the easiest question.
6. **Build.** After a yes, add the cards to `PLAN.md`. Do **one step**, run the checks, then end with:
   `How: <one line>` and `▶ Play: <what to do> — look for <what>`. Stop.
7. Act on the kid's answer:
   - `ok` → the next step
   - a tweak ("faster") → change only that, then ▶ again
   - `bug: …` → fix it if it is inside the Output; if not, add it to Bugs
   - `idea: …` → add it to "Not in v1.0", then go on
   - `?` or `why?` → explain; do no more steps until the kid understands
8. Change only the Output files. Need more? Stop. Show the new plan and quiz on what changed.
9. After the last step, check "Done when" and tick the card. Ask "Ship it now?" Yes → `ship` skill. You do every git step; never ask the kid to.

## 4. A new game
Use the `new-game` skill.

## 5. A feeling: the tune loop
1. Ask the kid which number they think causes the feeling, and why. Hint with section 3 step 4; do not name it first. Then name 1–3 `Tune` values that can cause it. No value fits? Make a card instead.
2. Quiz with one question: "If I change <value> from <old> to <new>, what will you feel?" Then change **one** value. Say old → new. Ask the kid to play a full run.
3. Ask "keep or undo?". Add one line to `PLAYTEST.md`. Include the stats from `user://stats.json` if they exist.

## 6. Release
Use the `ship` skill.
