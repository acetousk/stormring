# PLAN

## This week
LR lunchroom: the food fight moves to a giant 80s school lunchroom, and everyone is a small kindergartner (v0.3.0).

## Cards
| ✓ | ID | Input | Output | Done when |
|---|---|---|---|---|
| ✓ | G1 Design + scope | Kid's answers | `DESIGN.md` | Kid says it matches |
| ✓ | G2a World + player | `DESIGN.md` | `scripts/tune.gd`, `scenes/main.tscn`, `scenes/player.tscn`, `scripts/player.gd`, `project.godot`, `PLAN.md` | You run and jump on the island with keyboard or gamepad |
| ✓ | G2b Camera + drop | G2a | `scenes/player.tscn`, `scripts/player.gd`, `scenes/main.tscn`, `scripts/tune.gd` | You glide down from 80 m, land, look, zoom, and can't leave the island |
| ✓ | G3a Loot + rifle | G2 | `scenes/main.tscn`, `scenes/chest.tscn`, `scripts/chest.gd`, `scripts/player.gd`, `scenes/hud.tscn`, `scripts/hud.gd`, `scripts/tune.gd`, `project.godot`, `DESIGN.md` | You open a chest, shoot a target, reload, and heal |
| ✓ | G3b Bots + win | G3a | `scenes/bot.tscn`, `scripts/bot.gd`, `scripts/health.gd`, `scripts/game.gd`, `scenes/main.tscn`, `scenes/hud.tscn`, `scripts/hud.gd`, `scripts/tune.gd` | 3 bots roam and fight; you win when last one left, lose at 0 HP |
| ✓ | B1 Build | G4 | `scripts/player.gd`, `scenes/player.tscn`, `scenes/wall.tscn`, `scripts/wall.gd`, `scripts/hud.gd`, `scenes/hud.tscn`, `scripts/tune.gd`, `project.godot`, `scenes/main.tscn`, `DESIGN.md`, `PLAN.md` | You harvest material, build green/red-checked walls on the grid, and a wall blocks bullets until it breaks |
| ✓ | G4 Storm | G3 | `scripts/storm.gd`, `scenes/main.tscn`, `scripts/tune.gd`, `scripts/bot.gd`, `scripts/hud.gd`, `scenes/hud.tscn`, `PLAN.md` | Storm waits, shrinks to 0, hurts anyone outside (more as it shrinks), bots run inside, HUD shows the timer |
| ✓ | G5a Lobby + see each other | G4, B1, GD-Sync docs | `scripts/net.gd`, `scenes/lobby.tscn`, `scripts/lobby.gd`, `scripts/game.gd`, `scripts/player.gd`, `scenes/player.tscn`, `scenes/main.tscn`, `project.godot`, `PLAN.md` | 2 windows join the same 4-digit room and see each other run and glide |
| ✓ | G5b Host runs the match | G5a | `scripts/net.gd`, `scripts/game.gd`, `scripts/bot.gd`, `scripts/storm.gd`, `scripts/chest.gd`, `scripts/player.gd`, `scripts/health.gd`, `scripts/wall.gd`, scenes, `PLAN.md`, `DESIGN.md` | 2 windows see the same bots, storm, chests; shots and walls work for both; one shared winner |
| ✓ | T1 Net test | G5b | `tools/net_test.py`, `tools/net_test.gd`, `scripts/net.gd` | `python3 tools/net_test.py` prints a ✅/❌ list comparing host and joiner |
| ✓ | G6a Flow + sound | G5b, `DESIGN.md` | `tools/make_sfx.py`, `sounds/*.wav`, `scripts/sfx.gd`, `scripts/player.gd`, `scripts/bot.gd`, `scripts/storm.gd`, `scripts/wall.gd`, `scripts/game.gd`, `scripts/tune.gd`, `project.godot`, `CREDITS.md` | 3 rounds in a row work, you hear all 5 sounds, silent until the first click |
| ✓ | G6b Touch | G6a | `scenes/touch.tscn`, `scripts/touch.gd`, `scenes/hud.tscn`, `scripts/player.gd`, `scripts/tune.gd` | With `force_touch` on, you play a full match with only the mouse as a finger |
|  | G7 Ship | G6, kid's fix | `project.godot`, `icon.svg`, `scenes/bot.tscn`, `DESIGN.md`, `CHANGELOG.md`, `README.md`, `PLAN.md`, tag `v0.2.0` | `v0.2.0` builds on GitHub; Solo runs smoothly on the web and the kid's phone |
| ✓ | F1 Hide online status in solo | Kid's bug report (v0.2.0) | `scripts/hud.gd`, `CHANGELOG.md`, `PLAN.md` | Solo shows no status line; online matches and the start screen still do |
| ✓ | F2 No key errors in local mode | Kid's bug report, `RequestProcessor.gd:273` | `scripts/health.gd`, `scripts/storm.gd`, `CHANGELOG.md`, `PLAN.md` | 2-window Output has no "Key must not be empty"; net test all ✅ (kid tested 2 windows: clean and working; net test could not run: joiner never found the room, likely the test terminal blocks local broadcasts, not proven; kid chose to ship v0.2.2 on the 2-window test) |
| ✓ | FF1 Food fight design | Kid: "no guns, a kid-friendly food fight" | `DESIGN.md`, `PLAN.md` | Kid says the design and the word list match |
| ✓ | FF2 Tomatoes + clean | FF1 | `scripts/food.gd`, `scenes/food.tscn`, `scripts/splat.gd`, `scenes/splat.tscn`, `scripts/player.gd`, `scripts/bot.gd`, `scripts/game.gd`, `scripts/health.gd`, `scenes/main.tscn`, `scripts/tune.gd`, `tools/net_test.gd` | A tomato flies in an arc and splats; splatted bots and players lose clean; net test all ✅ |
| ✓ | FF3 Spoon + toast | FF2 | `scripts/player.gd`, `scenes/wall.tscn`, `scripts/wall.gd`, `scripts/tune.gd` | The spoon scoops crumbs; a toast wall soaks up tomatoes until it falls apart |
| ✓ | FF4 Baskets + towels | FF2 | `scenes/chest.tscn`, `scripts/chest.gd`, `scripts/player.gd`, `scripts/tune.gd` | A picnic basket gives tomatoes and a towel; the towel wipes you clean |
| ✓ | FF5 Jelly storm + umbrella | FF2 | `scenes/main.tscn`, `scenes/player.tscn`, `scripts/player.gd` | The storm looks like jelly; an umbrella opens while you float down |
| ✓ | FF6 Art | FF2–FF5, `DESIGN.md` palette | `models/*.tscn`, `models/materials/*.tres`, `scenes/player.tscn`, `scenes/bot.tscn`, `scenes/main.tscn`, `icon.svg`, `CREDITS.md` | Chef, lunch buddies, broccoli, cheese, gingerbread houses, donuts; runs at 30 fps on the web |
| ✓ | FF7 Sounds | FF2 | `tools/make_sfx.py`, `sounds/*.wav`, `scripts/sfx.gd`, `CREDITS.md` | You hear throw, splat, crunch, toast pop, jelly bubbles |
| ✓ | FF8 Words | FF2–FF7 | `scripts/hud.gd`, `scenes/hud.tscn`, `scripts/touch.gd`, `scenes/lobby.tscn`, `scripts/game.gd` | No gun or HP word on any screen |
| ✓ | LR1 Lunchroom design | Maintainer: "a lunchroom food fight, all small kindergartners, the lunchroom seems large" | `DESIGN.md`, `PLAN.md` | The design and the word list match |
| ✓ | LR2 Lunchroom | LR1 | `scenes/main.tscn`, `models/*.tscn`, `models/materials/*.gdshader`, `scripts/game.gd` | 12 lunch tables, walls, windows, stage, counter; the room looks huge; 30 fps on the web |
| ✓ | LR3 Table start + napkin | LR2 | `scripts/player.gd`, `scenes/player.tscn`, `scripts/game.gd`, `scripts/tune.gd` | Each player starts on a table; the napkin opens when you fall fast; you land and steer |
| ✓ | LR4 Trays + lunch boxes | LR2 | `scenes/wall.tscn`, `scripts/wall.gd`, `scenes/chest.tscn`, `scripts/player.gd`, `scripts/tune.gd` | The spoon gets trays from tray carts; tray walls block tomatoes; lunch boxes give tomatoes and a napkin |
| ✓ | LR5 Jello spill | LR2 | `models/materials/jello.gdshader`, `scenes/main.tscn`, `scripts/storm.gd` | The spill looks like see-through green jello |
| ✓ | LR6 School screens | LR1 | `ui/school.tres`, `ui/*.gdshader`, `scenes/lobby.tscn`, `scenes/hud.tscn`, `scripts/hud.gd`, `scripts/touch.gd` | Chalkboard start screen, grade card, red slip, report card + gold star; fits at 720p |
| ✓ | LR7 Sounds | LR2 | `tools/make_sfx.py`, `sounds/*.wav`, `scripts/sfx.gd` | Tray clink, tray clack, and a school bell at the start |
| ✓ | LR8 Docs | LR1–LR7 | `README.md`, `FAQ.md`, `CHANGELOG.md`, `CREDITS.md`, `PLAYTEST.md`, `PLAN.md` | Player docs match the lunchroom |
| ✓ | LR9 Game feel | Maintainer: "improve gameplay and assets"; robot playtest (`tools/autoplay.gd`) | `scripts/hud.gd`, `scripts/food.gd`, `scripts/health.gd`, `scripts/bot.gd`, `scripts/game.gd`, `scripts/chest.gd`, `scripts/player.gd`, `scripts/sfx.gd`, `scripts/tune.gd`, `tools/make_sfx.py`, `sounds/*.wav`, `models/kid.tscn`, `models/buddy.tscn`, `tools/autoplay.gd` | You see and hear every hit, know who hit you and from where, tell the bots apart, and find the way out of the jello; the robot playtest has no errors |
|  | FF9 Docs + ship | LR8 | `README.md`, `FAQ.md`, `CHANGELOG.md`, `PLAYTEST.md`, `PLAN.md`, tag `v0.3.0` | Player docs match the game; `v0.3.0` builds; the web link plays the lunchroom food fight |

### G2a steps
1. `PLAN.md` + `Tune` autoload
2. Island, water, sky
3. Input Map (keyboard + gamepad)
4. Capsule player with gravity
5. Run 6 m/s
6. Jump 1.2 m

### G2b steps
7. SpringArm3D camera + look
8. Aim zoom + slower look
9. Glide start at 80 m
10. Invisible edge walls
11. Tune pass

### G3a steps
1. 2 box buildings, 10 trees, 8 rocks
2. 6 chests: hold E 0.5 s → rifle + heal kit
3. HUD: HP, ammo, heal kits, crosshair
4. Burst rifle: 3 × 12, 60 m, every 0.6 s, mag 15
5. Reload: R / RB or auto, 1.8 s
6. Heal kit: H / B, +50 HP over 3 s

### G3b steps
7. Navigation + 3 bots roam
8. Bot sight 50 m + shooting (30–60% accuracy)
9. Shared health: 0 HP → out
10. HUD: players left
11. Win / lose message + restart
12. Tune pass (bot aim)

### G4 steps
1. Purple see-through storm wall, radius 80, center near middle
2. Timer: wait 45 s, shrink to 0 over 90 s
3. Damage once per second outside: 2 → 10 HP as it shrinks
4. HUD: storm timer + "IN THE STORM!"
5. Bots outside walk inside first
6. Tune pass

### B1 steps
1. Slots: 1 pickaxe, 2 rifle (D-pad left/right)
2. Pickaxe: +10 material per hit (max 300)
3. Build mode Q / Y: ghost wall on 4 m grid
4. Ghost green / red
5. Place wall: −10 material, 150 HP, blocks bullets
6. Tune pass

### G5a steps
1. `net.gd`: local mode in the editor, online mode in builds; "Connecting…" → "Connected"
2. Lobby screen: Host (4-digit code), Join (type code), Solo
3. One player per person; you only move your own player and camera
4. Movement sync, 20 per second, smoothed

### G5b steps
5. Host runs bots + storm; others copy
6. Chests: hold E asks the host; host opens for everyone
7. Shots: "I hit X" goes to the host; host takes the HP
8. Walls: build asks the host; host places for everyone
9. Win / lose: host decides; each screen shows its own place
10. 2-window test + Tune pass (kid chose: the T1 net test counts; `net_send_rate` stays 20)

### T1 steps
1. Test driver: host makes a room, joiner joins, host starts
2. Joiner actions: open a chest, build a wall, shoot a bot
3. Snapshots at 10 / 30 / 60 s into a file
4. `net_test.py` runs both and prints ✅ / ❌

### G6a steps
1. Play again 3 times (solo restarts; online back to the start screen, host again)
2. `make_sfx.py` writes 5 WAVs: shot, hit, harvest, build, storm
3. `Sfx` autoload: sound at a spot, nothing before the first click/tap
4. Sounds in: shots, hits, pickaxe, wall placed, storm hum outside
5. Tune pass: `sfx_volume`

### G6b steps
6. Touch controls only on touch screens; `Tune.force_touch` shows them on PC
7. Left stick moves
8. Drag right side to look
9. Buttons: Fire, Jump, Build, Use, Heal
10. Auto-pickaxe (touch): fire at tree/rock/house swings the pickaxe
11. Full match; kid names one fix (→ G7). Kid said "ok": no fix named.

### G7 steps
1. Title "My Game" → "Stormring"
2. Icon: purple storm ring around a green island (`icon.svg`)
3. The fix: bots Water teal `#2A9D8F` (kid: "bots look like the storm far away")
4. `CHANGELOG.md` + `README.md`
5. Ask, then tag `v0.2.0` (v0.1.x tags are from the kid's first game)
6. Kid checks speed: web link + phone. Web ✓ (v0.2.0 released, solo plays). Phone: later, phone not set up yet.

### F1 steps
1. Hide the online status line in solo matches (start screen keeps it)


### FF2 steps
1. A tomato: a red ball with a stem, flies in an arc, splats on what it touches
2. A splat: a red puddle and drops that fade after 5 s (40 at most)
3. Throw: aim with the crosshair, the arc lands on that spot
4. Every screen sees each tomato; only the thrower's copy counts
5. Bots throw too, and miss more from far away
6. Clean meter: the shirt goes red as you get messy

### FF3 steps
1. Pickaxe → spoon: scoop crumbs from trees, cheese, and houses
2. Walls → toast walls, with a crust edge

### FF4 steps
1. Chests → picnic baskets (red cloth lid, handle)
2. Heal kits → towels

### FF5 steps
1. The storm: purple jelly, wobbly
2. An umbrella opens over you while you float down

### FF6 steps
1. Chef player, lunch-buddy bots
2. Broccoli trees, cheese wedges, gingerbread houses, donuts
3. Icon: a tomato with a splat

### FF7 steps
1. throw, splat, harvest (crunch), build (toast pop), storm (jelly bubbles)

### FF8 steps
1. HUD, touch buttons (THROW, WIPE), start screen ("Food Fight"), end screen ("Splatted!", "Last one clean!")

### LR2 steps
1. Room 160×160 m, 32 m high: cinderblock walls, ceiling tiles, windows, pillars, stage, counter, menu board, clock
2. 12 lunch tables (tops at 5.3 m, chrome posts you can run between), benches, trash cans, milk cartons, tray carts
3. Small floor tiles and light haze, so the room looks even bigger

### LR3 steps
1. No sky drop: each player starts on a different table; the bell rings
2. The napkin opens when you fall faster than 7.5 m/s; then sink at 3 m/s and steer

### LR4 steps
1. Toast walls → giant tray walls; crumbs → trays (from tray carts)
2. Picnic baskets → metal lunch boxes; towels → napkins

### LR5 steps
1. The jello spill: see-through green with a bright edge and slow moving bands

### LR6 steps
1. One bold thing: the chalkboard start screen. Everything else is school paper
2. Grade card (A+ to F), pocket card, red slip, report card with a gold star

### LR7 steps
1. harvest = tray clink, build = tray clack, new bell

### FF9 steps
1. README, FAQ, CHANGELOG match the lunchroom food fight
2. Ask, then tag `v0.3.0`

## Bugs
- Fixed (F2, v0.2.2): local mode flooded Output with "Key must not be empty" (GD-Sync `_unreliable_mac` has no key in local mode). MoveSync + StormSync now reliable in local mode only.
- Fixed (T1): joiner's chest/wall requests were lost. GD-Sync's send-to-one-player keeps only 30 bits of the host's ID. Now `Net.tell_host` sends to everyone and only the host acts.
- Fixed (T1): joiner never got control of their player. The host said "this one is yours" before the player existed on the joiner's screen. Now the host waits 1 s first.
- Fixed (FF2 test): `net_test.py` "No room NNNN" was the test computer, not the game. GD-Sync local mode finds rooms by UDP broadcast, and the old test sandbox blocked it. With the local network open, all 69 checks pass.
- Bots don't path around tray walls (map is baked at start). Fix with the smart bots card.
