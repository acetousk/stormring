# What to say to Claude

Claude has **skills**. A skill is a set of steps that Claude follows the same way each time.
To start one, say its keyword in Claude Code, in your own words. Claude picks the skill.
To force a skill, type `/` and its name, for example `/bug`.

Every skill follows the same 5 rules:
1. Claude teaches how it will work and shows a plan.
2. Claude asks you 1–3 questions about the plan. **Wrong? You get a hint, not the answer.** Try again. After 3 hints, Claude asks you to ask **it** a question about the part that is not clear.
3. **Nothing changes until you get them right and say yes.**
4. Claude does one small step. **You press F5 and play.**
5. Nothing ships until **you can explain what is new.**

The questions are not a test you can fail. They make sure that **you** understand your own game. "Skip the quiz" does not work: Claude asks the easiest question instead.

## Skills

| Say this | Skill | What happens | What you do |
|---|---|---|---|
| "check my setup", "it won't build", "F5 does nothing" | `doctor` | Claude checks Godot, git, GitHub, and GD-Sync. You get a ✅/❌ list. It changes nothing. | Read the ❌ lines. Some are a parent job. |
| "make a game", "new game" | `new-game` | Questions one at a time → your design → 7 cards → your first game online (v0.1.0) | Answer, answer the quiz, approve, play after each step |
| `idea: …`, "add …", "can it …" | `feature` | Claude says if it fits, and offers a smaller version if it is big. Then it makes a plan and builds 1 step at a time. | Answer the quiz, approve, play |
| `bug: …`, "it crashed", "broken" | `bug` | Claude asks for proof, finds the cause, and fixes only that. | Paste the **exact** red line from Output, or send a screenshot. Help find the cause. Answer the quiz. Then play to check it. |
| "ship it", "release", "publish" | `ship` | Claude checks the game, picks the version, and sends it to GitHub. About 10 minutes later: web, phone, and PC. | Answer the quiz about what is new. Say **go**. Click **Allow** on the pop-ups. |
| "draw …", "a sprite for …", "new icon" | `create-2d` | Claude makes 2D art in your palette | Answer the quiz, approve. Then keep, change, or undo |
| "a model for …", "make a tree" | `create-3d` | Claude makes a 3D model from simple shapes in your palette | Answer the quiz, approve. Then keep, change, or undo |
| "a sound for …", "music" | `create-audio` | Claude writes a script that makes the sound, then plays it in the game | Answer the quiz, approve. Listen. Keep, change, or undo. |
| "a sky", "the background is boring", "make it night" | `create-background` | 2D: layers that move at different speeds. 3D: sky, sun, light. | Answer the quiz, approve. Check that you can still see the player |
| "make a level", "a bigger map", "random dungeons" | `create-environment` | Claude draws a text map first, then builds it after you say yes | Answer the quiz, approve the map, then run to each corner |
| "play with friends", "online", "rooms", "the code doesn't work" | `online` | Claude teaches how rooms work, then guides you to make your GD-Sync keys and put them in Godot and GitHub. Then you ship and test a room with a friend. | Answer the quiz. Click where Claude says. Paste keys only in Godot and GitHub, never in the chat. |
| "how does X work?", "explain …", "why does …" | `explain` | Claude reads the real code and explains how it works, step by step, with real numbers from your game. Then it asks you one question. | Answer the question. Say "more" to go one level deeper. |
| "make a skill", "every time I say X, do Y" | `create-skill` | Claude makes **your own** skill with your keyword | Answer the quiz about your skill, approve, then test it |
| "too hard", "boring", "feels slow" | (tune loop) | Claude asks which number you think causes it, then changes one number. You play a full run. | Say **keep** or **undo** |

## Answers during a step

| You say | Claude does |
|---|---|
| `ok` | The next step |
| a tweak (`faster`, `easier`) | Changes only that, then ▶ again |
| `bug: …` | Fixes it, or adds it to Bugs for later |
| `idea: …` | Saves it in "Not in v1.0". It does not do it now. |
| `?` or `why?` | Explains. It does no more steps until you get it. |
| `undo` | Press **Esc** twice in Claude Code and pick the step to go back to |

## Pop-ups
- **Allow** for `git tag` or `git push` during `ship`: this sends your game to GitHub. Click Allow.
- Any other pop-up you don't understand: click **No**, and ask Claude `what was that pop-up?`.
- Claude never asks you to type a command in a terminal. If it does, say: `use the skill, don't make me type commands`.

## How to ask: give Claude a goal
Claude works best when it knows **what you want**, **why**, and **how you will know it worked**.

| Weak ask | Strong ask |
|---|---|
| "make it better" | "the jump feels floaty. Goal: a short, snappy jump. Done when I can hop over a 1-tile gap and land fast." |
| "add enemies" | "add one enemy that chases me, so the level feels dangerous. Done when it catches me if I stand still for 3 seconds." |
| "fix it" | "bug: when I die the game freezes. Here is the red line: `<paste it>`" |
| "make a menu" | "a start screen with Play and Quit, so my friends know how to start. Done when Play starts the game on phone and PC." |

**Say "like X".** Name a game, film, or thing that has what you mean. It is the fastest way to explain a feel or a look:
- "a dash like in a platformer: quick, short, and you can do it in the air"
- "a sky like a sunset at the beach"
- "a sound like a coin falling in a jar"
- "enemies that move like a swarm of bees"

Claude uses "like X" to understand you. It makes **your own** version. It never copies another game's name, characters, art, levels, or music. If you ask for a copy ("make a … clone"), Claude says **Not possible here** and offers your own game with the same kind of fun.

More tips:
- **One thing at a time.** Finish one goal, play it, then ask for the next.
- **Say the feeling**, not the number: "too hard", "too slow", "boring after 1 minute". Claude finds the number.
- **Paste the exact error.** Do not write it from memory.
- **Ask `?` any time.** Claude stops and explains. Nothing ships that you can't explain.

## Art and sound: 3 ways
Use them in this order. Each new file goes in `CREDITS.md` with who made it and its license.

| | 1. Claude makes it | 2. Free stock (CC0) | 3. You make it |
|---|---|---|---|
| **2D art** (sprites, tiles, icons) | SVG shapes, or a script `tools/make_art.py` that draws pixel art from a letter grid. You can change one letter and run it again. | kenney.nl, opengameart.org (filter: CC0). You download it into `art/`. | **Krita** (painting), **Inkscape** (shapes), **LibreSprite** or **Piskel** (pixel art, Piskel runs in the browser). Save PNG or SVG into `art/`. |
| **3D models** | Simple shapes (boxes, balls, tubes) in your palette colours, put together in one scene | kenney.nl 3D kits (`.glb`). You download them into `models/`. | **Blender**: keep it low-poly, about 3–12 parts. File → Export → glTF 2.0 (`.glb`) into `models/`. |
| **Sound** | A script `tools/make_sfx.py` that makes each sound from math (pitch, length, fade) | kenney.nl audio, freesound.org (filter: CC0) | **jsfxr** (game sounds, in the browser), **Audacity** (record and edit), **LMMS** (music). Export WAV or OGG into `sounds/`. |

You download and you make. Claude never downloads files.

## 2D game or 3D game?
You pick it in the first questions (card G1). Both work on PC, phone, and web, and both work online.

| | 2D game | 3D game |
|---|---|---|
| You see | From the side or from the top, flat pictures | A world with depth, a camera behind or above you |
| Art | Sprites and tiles (`create-2d`) | Models from shapes (`create-3d`) or Blender |
| Levels | A tile map (`create-environment`) | Ground, walls, and props (`create-environment`) |
| Background | Layers that move at different speeds (`create-background`) | A sky, a sun, and light (`create-background`) |
| Speed on phones | Fast | Keep it simple: few lights, few objects, no big textures |
| Good first pick if | You want it done faster, or you like pixel art | You want to run around a world |

## My skills
Your own skills from `create-skill` go here, one line each: the keyword and what it does.

| Say this | Skill | What it does |
|---|---|---|
