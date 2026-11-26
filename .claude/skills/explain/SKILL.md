---
name: explain
description: Use when the kid asks how something works - "how does X work?", "explain …", "what is …", "why does …", "what happens when I press jump?", "how does online work?". Explains the real system at a technical level, in plain words, from the real code in this repo. Changes no file.
---

# Explain: how a part really works

Goal: the kid understands the real mechanism, not only a picture of it. Teach the way a good teacher builds it from scratch: start small, use real numbers, follow the data step by step.

Change no file. Read only the files you need.

## 1. Find the part
1. Ask one question if it is unclear: "Which part: the jump, the enemies, online, the build, or something else?"
2. Find the real code: the scene, the script, and the function. Read it.

## 2. Explain in 5 parts
Keep each part short.

1. **One line:** what it does, in plain words.
   "The jump gives the player a fast speed up, and gravity pulls the speed down a bit each frame."
2. **A picture from real life** (one sentence). Then say where the picture stops being true.
   "Like throwing a ball up. But in the game, gravity is a number we pick."
3. **Follow it step by step, with real numbers from this game.** Use a numbered list or a small table. Each line is one thing the computer does.
   ```
   frame 0   you press jump   speed.y = -450
   frame 1   gravity adds 20  speed.y = -430   player moves up 7 px
   ...
   frame 23  speed.y = 0      the top of the jump
   ```
4. **The real code**, 3–10 lines, copied from the repo, with a plain comment on each line. Say the file and the function (`scripts/player.gd`, `_physics_process`).
5. **Where the numbers live:** the `Tune` value the kid can change, and what happens when it goes up or down.

## 3. Language
- Short sentences: max 20 words. Active voice. One idea per sentence.
- Simple, common words. One word = one meaning: do not say "speed" in one line and "velocity" in the next.
- A technical word is fine when it is the real name. Explain it the first time: "a **frame** is one picture; the game draws about 60 per second".
- No idioms, no filler. Use lists and tables for steps.
- Max about 15 lines in total. The kid can ask "more" for the next level down.

## 4. Check
1. Ask one question that needs real understanding. Not "did you get it?", but "If gravity was 40, would the jump be higher or lower? Why?"
2. A wrong answer → do not give the answer. Give one hint, then ask again, as in `game-plan` 3.4: a smaller question, then a line of the code or a thing in the game to look at, then a real-life picture. After 3 hints, say: "Ask me a question about the part that is not clear." Answer that question, then ask a new one.
3. A right answer → say what was right about it in one line.
3. Offer one small experiment the kid can do: "Press F5, open Remote → Tune, set `gravity` to 40, and jump. Look for a lower jump." A file change → use `game-plan` first.

## 5. Go deeper (only when the kid asks "more" or "why?")
Go one level down each time:
the game code → the Godot node that does the work (`CharacterBody2D.move_and_slide()`) → what Godot does each frame → the computer (CPU, GPU, memory) → the network or the build pipeline.
Stop at each level and check again.

## Good parts to explain
- The game loop: frames, `_process` and `_physics_process`, delta time.
- Scenes and nodes: the tree, and how scenes are put inside scenes.
- Input: a key press → an Input Map action → the code.
- Collisions: shapes, layers, and masks.
- Online with GD-Sync: the host, rooms and codes, what each player sends, quick and sure messages.
- Saving to `user://`.
- How `ship` works: commit → tag → GitHub Actions → 4 builds → Pages, Releases, and Obtainium.
- How `tools/make_sfx.py` turns numbers into sound, and how `make_art.py` turns letters into pixels.
