# Stormring — Design

**One sentence:** You are a kindergartner in a giant 80s school lunchroom: jump off a lunch table with a napkin parachute, grab tomatoes from lunch boxes, build tray walls, and be the last one clean as the jello spill closes in.

**Kid-friendly:** no guns, no blood. Hits are tomato splats. At 0 clean you are "splatted" and out of the round.

## Basics
- **Type:** 3D food fight, last one clean wins
- **Camera:** third person, over the shoulder (SpringArm3D). Aim zooms in and slows the look.
- **Main action:** throw tomatoes and build tray walls

## Controls
| Action | Keyboard + mouse | Gamepad | Touch |
|---|---|---|---|
| Move | WASD | Left stick | Left stick |
| Look | Mouse | Right stick | Drag right side |
| Jump | Space | A | JUMP button |
| Throw / grab trays | Left click | RT | THROW button |
| Aim | Right click | LT | — (no aim on touch) |
| Spoon / tomatoes | 1 / 2 | D-pad left / right | Auto: spoon when close to a tray cart |
| Grab more tomatoes | R (or auto when empty) | RB | Auto when empty |
| Build mode | Q | Y | BUILD button |
| Action (open lunch box) | Hold E | X | Hold USE button |
| Wipe clean (napkin) | H | B | WIPE button |

## Win and lose
- **Win:** last one clean
- **Lose:** your clean meter reaches 0 (you are splatted)

## Players
- 1–4 real players online (GD-Sync) + 3 bots
- The host runs the bots, the jello spill, and the lunch boxes. Each player sends their own moves, throws, and builds.
- Start screen: Host (shows a 4-digit room code), Join (type the code), or Solo. The host presses Start.
- Tested by `python3 tools/net_test.py` (a host and a joiner play by themselves and compare).

## v0.3 (lunchroom food fight)
- **Setting:** a big American public-school lunchroom from the 1980s. Everyone is a small kindergartner, so the room feels huge.
- **Scale:** a kid is about 2.1 m tall in game units. Lunch tables are 26 m long with tops at 5.3 m. The room is 160×160 m and 32 m high. Small 0.7 m floor tiles and light haze make it look even bigger.
- **Room:** cinderblock walls (mint below, cream above, a tomato stripe), ceiling tiles and light strips, tall windows, 4 pillars, a stage with curtains, the lunch counter, a menu board ("Today's lunch: Tomato surprise"), a clock
- **Cover:** 12 lunch tables (run under them, or climb the benches), trash cans, giant milk cartons, pillars
- **Start:** each player starts on top of a different lunch table. The bell rings. Jump off: a paper-napkin parachute opens when you fall fast (over 7.5 m/s), then you sink at 3 m/s and steer at 8 m/s
- **Move:** run 7 m/s, jump 1.2 m (a normal jump never opens the napkin)
- **Spoon:** tap a tray cart for +1 tray, a tap every 0.3 s (max 30). Slot 1 = spoon, slot 2 = tomatoes
- **Build:** tray wall only (a giant lunch tray on its edge). 1 tray, 4 m grid snap, soaks up 150 splat, blocks tomatoes. Ghost piece is green = OK, purple = can't build
- **Tomatoes:** thrown in an arc (28 m/s, real gravity). 6 in your hands, a throw every 0.35 s, grab 6 more in 1.2 s. Each splat = −10 clean. Splats stay for 5 s
- **Lunch boxes:** 8 metal lunch boxes (hold E 0.5 s): tomatoes + 1 napkin (+50 clean over 3 s, max 2)
- **Clean meter:** 100, no shield. Your shirt turns more tomato red as you get messy. The HUD shows it as a grade (A+ to F)
- **Jello spill:** 1 phase. Waits 35 s, closes in from 80 m to 0 over 90 s. Outside, you lose 2 → 10 clean per second as it closes in
- **Bots:** 3 lunch buddies (cheese-yellow shirts, blue caps). Roam inside the circle (NavigationAgent3D), throw on sight (45 m, every 0.8 s, miss by 3 m far → 0.6 m near). They throw at each other too
- **HUD:** grade card (clean), pocket card (trays, napkins, tomatoes), kids left, jello clock, crosshair, a red slip "Get out of the jello spill!"
- **Screens:** chalkboard start screen; a report card at the end ("Splatted!" or "Last one clean!", grade, place, splats, time; a gold star when you win)

## Words (old → new)
| Old | New |
|---|---|
| rifle, bullet, shoot | tomatoes, throw |
| HP | clean (shown as a grade) |
| eliminated, eliminations | splatted, splats |
| players left | kids left |
| pickaxe, material | spoon, trays |
| wall | tray wall |
| chest, heal kit | lunch box, napkin |
| storm, shrinking | jello spill, spreading |
| glide | napkin parachute |
| island | lunchroom |

## Art
- Low-poly models from Godot primitive meshes in `models/`, shared palette materials in `models/materials/`
- Shaders: floor tiles, cinderblock walls, ceiling tiles, the jello wall (`models/materials/*.gdshader`)
- No sky: a closed room. One sun light through the windows, no real-time shadows, light fog. About 30 fps on web and phones

## UI style (80s school, skeuomorphic)
- **One bold thing:** the chalkboard start screen (green slate shader, oak frame, chalk tray, chalk-dust letters)
- **Everything else is quiet school paper:** index-card buttons (cream, red top line, ballpoint-blue text, a shadow that lifts on hover), a yellow highlighter for keyboard and gamepad focus, a red-pen grade, a red hall-pass slip for warnings, a manila report card
- **Type:** Godot's built-in font, made bolder (`ui/school.tres`). No downloaded fonts. Sentence case, no all caps
- Theme: `ui/school.tres`. Shaders: `ui/chalk.gdshader`, `ui/chalkboard.gdshader`. Gold star: `ui/gold_star.svg`

## Palette (80s school lunchroom)
| Name | Hex | Used for |
|---|---|---|
| Tomato | `#E63946` | tomatoes, splats, red pen, stripes |
| Cream | `#FFF1D6` | cards, napkins, upper walls |
| Mint | `#B8D8C0` | lower walls, floor tiles |
| Laminate | `#D8B98A` | table tops |
| Chrome | `#B8BEC4` | table legs, tray carts, latches |
| School blue | `#3A6EA5` | lunch boxes, trash cans, jeans |
| Orange | `#E8873A` | benches, trays |
| Crust | `#9C6B30` | trays, oak frame, hair |
| Cheese | `#F4C430` | bot shirts, gold star, highlighter |
| Jello | `#A7C957` | the jello spill |
| Chalkboard | `#2E4A3B` | start screen |
| Ballpoint | `#22408C` | text on cards |
| Dark | `#264653` | outlines, eyes |

## Sound
- `tools/make_sfx.py` writes WAVs: throw (whoosh), splat, harvest (tray clink), build (tray clack), storm (jello wobble), bell (school bell at the start)
- No sound before the first click or tap

## Not in v1.0 (later cards)
- More foods: pie (big splat), water balloon (wide splash), food rarity, 3 slots
- Ramp
- A lunch lady cart that drives a line across the room at the start
- 3 jello phases with a moving center
- Smart bots: loot, cover, build walls, wipe clean; up to 9 bots
- Splat feed, minimap circle, hit markers
- Effects: throw swoosh trail, splat ticks, harvest shake + "+10", jello heartbeat, napkin wind
- Crouch
- Online: a new host if the host leaves; host checks hits (fair play)

## M2 (much later)
- Stacked trays, ramps, edits; more foods; aprons (shields); squads; emotes
