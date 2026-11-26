# Stormring — Design

**One sentence:** Glide onto an island, loot a rifle, build walls, and be the last one standing as the purple storm closes in.

## Basics
- **Type:** 3D battle royale
- **Camera:** third person, over the shoulder (SpringArm3D). Aim zooms in and slows the look.
- **Main action:** shoot and build

## Controls
| Action | Keyboard + mouse | Gamepad | Touch |
|---|---|---|---|
| Move | WASD | Left stick | Left stick |
| Look | Mouse | Right stick | Drag right side |
| Jump | Space | A | Jump button |
| Fire / harvest | Left click | RT | FIRE button |
| Aim | Right click | LT | — (no aim on touch) |
| Pickaxe / rifle | 1 / 2 | D-pad left / right | Auto: pickaxe when close to a tree, rock, or house |
| Reload | R (or auto when empty) | RB | Auto when empty |
| Build mode | Q | Y | BUILD button |
| Action (open chest) | Hold E | X | Hold USE button |
| Heal | H | B | HEAL button |

## Win and lose
- **Win:** last one standing
- **Lose:** your HP reaches 0

## Players
- 1–4 real players online (GD-Sync) + 3 bots
- The host runs the bots, storm, and chests. Each player sends their own moves, shots, and builds.
- Start screen: Host (shows a 4-digit room code), Join (type the code), or Solo. The host presses Start.
- Tested by `python3 tools/net_test.py` (a host and a joiner play by themselves and compare).

## v0.1 (first playable)
- **Island:** 160×160 m, water around the edge, 2 spots with box buildings, trees, rocks
- **Drop:** start high in the sky, glide down (8 m/s down, 10 m/s steer)
- **Move:** run 7 m/s, jump 1.2 m
- **Pickaxe:** +10 material per hit, a swing every 0.3 s (max 300). Slot 1 = pickaxe, slot 2 = rifle
- **Build:** Wall only. 10 material, 4 m grid snap, 150 HP, blocks shots. Ghost piece is green = OK, purple = can't build
- **Gun:** Burst rifle (3×12 dmg, burst every 0.6 s, mag 15, 60 m, reload 1.8 s), unlimited ammo with reloads
- **Chests:** 6 chests (hold E 0.5 s): Burst rifle + 1 heal kit (+50 HP, 3 s, max 2)
- **Health:** 100 HP, no shield
- **Storm:** 1 phase. Waits 35 s, shrinks from 80 m to 0 over 90 s. Outside hurts 2 → 10 HP/s as it shrinks
- **Bots:** 3 bots. Roam inside the circle (NavigationAgent3D), shoot on sight (raycast 50 m, 20% accuracy far → 60% near). They fight each other too. Bots are Water teal, players are Dark (purple is only for the storm).
- **HUD:** HP, material, ammo, players left, storm timer, crosshair
- **Screens:** start ("Click or tap to start"), end (place, eliminations, time)

## Art
- Godot primitive meshes with palette materials, ProceduralSkyMaterial, SVG UI and icon
- Few lights, no real-time shadows on web, about 30 fps on web and phones

## Palette (Sunset Isle + purple storm)
| Name | Hex |
|---|---|
| Sand | `#E9C46A` |
| Grass | `#6A994E` |
| Water | `#2A9D8F` |
| Dark | `#264653` |
| Storm purple | `#7B2CBF` |

## Sound
- `tools/make_sfx.py` writes WAVs: shot, hit, harvest, build, storm
- No sound before the first click or tap

## Not in v1.0 (later cards)
- Scatter gun, gun rarity (common/rare/epic), 3 slots
- Ramp
- Sky barge drop on a random line
- 3 storm phases with a moving center
- Smart bots: loot, cover, build walls, heal; up to 9 bots
- Kill feed, minimap circle, hit markers
- Effects: muzzle flash, tracer, hit/kill ticks, harvest shake + "+10", storm wall shader + heartbeat, glide wind
- Crouch
- Online: a new host if the host leaves; host checks hits (anti-cheat)

## M2 (much later)
- Floors, roofs, edits; more guns; shields; cars; squads; emotes
