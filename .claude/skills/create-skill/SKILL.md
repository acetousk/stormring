---
name: create-skill
description: Use when the kid wants their own shortcut or habit for Claude - "make a skill", "make a shortcut", "every time I say X, do Y", "remember to always …". Writes a new skill in .claude/skills/my-<name>/ that the kid understands and can turn on with a keyword.
---

# Create a skill (the kid's own shortcut)

Use the gate in `game-plan` section 3: teach → plan → quiz (hints, never the answer) → approve → build.

## 1. Find the habit
1. Ask: "What do you ask me again and again?" Get one real example from this chat or `PLAN.md`.
2. Ask: "What word or sentence will you say to start it?" (the keyword, for example `polish pass`).
3. Ask: "What do you want at the end?" (for example "every button has a click sound").

Not a good skill? Say so and offer the closest option:
- It happens once → a normal card with `feature`.
- It breaks a rule in `AGENTS.md` (skips approval, pushes without a pop-up, uses secrets, copies another game) → **Not possible here**, and why.
- An existing skill does it → name that skill and its keyword.

## 2. Teach
Explain what a skill is in 2 lines: "A skill is a note to me. When you say the keyword, I read the note and follow its steps, the same way each time."
Do not quiz yet. Show the plan first (section 3).

## 3. Plan
Show the skill in plain words before you write it:
- **Name:** `my-<name>` (lowercase, dashes)
- **Keyword:** what the kid says
- **Steps:** 3–7 numbered steps
- **Done when:** what the kid sees at the end

Quiz, as in `game-plan` 3.3–3.4, one question at a time:
- "What will you say to start it?"
- "What do I do first when you say it?"
- "What rule can your skill never skip?"

Wrong → a hint, never the answer. All right? Ask "Approve this skill?" and stop.

## 4. Write it
Write `.claude/skills/my-<name>/SKILL.md`:
```
---
name: my-<name>
description: Use when the kid says "<keyword>" or <2-3 other ways to say it>. <What it does, one line.>
---

# <Name>
Use the gate in `game-plan` section 3 (plan → quiz → approve), one step, How and ▶ Play lines.

1. ...
Done when: ...
```
Rules for the skill text:
- It may never skip the `game-plan` plan, quiz, and approval, the `ship` pop-ups, or any rule in `AGENTS.md`.
- Short, plain steps. Each step is one thing the kid can see.
- Only the kid's skills go in `my-*` folders. Never change the kit skills.

Add a line to `SKILLS.md` under "My skills": the keyword and what it does.

## 5. Test it
Say: "Start a new chat (or type `/clear`), then say **<keyword>**." Claude must say "Using my-<name>" at the start. Not used? Make the description match the kid's words better.
