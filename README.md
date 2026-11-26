# Stormring

**Lunchroom Food Fight.** You are a kindergartner in a giant school lunchroom. Jump off a lunch table with a napkin parachute, grab tomatoes from lunch boxes, build tray walls, and be the last one clean as the jello spill closes in.

A small, kid-friendly 3D food fight made with Godot 4.7.2. No guns, no blood: only tomato splats. Play solo against 3 bots, or online with up to 4 friends.

## Play

- **Web:** https://acetousk.github.io/stormring/ (Chrome, Firefox, or Edge). Old version? Press Ctrl+Shift+R.
- **Android:** install **Obtainium**, tap **Add app**, and paste `https://github.com/acetousk/stormring`. Obtainium shows each update.
- **Windows:** on the [Releases page](https://github.com/acetousk/stormring/releases), download `stormring-<version>-windows.zip`. Unzip it and run the game. (Windows may warn about an unknown app: click "More info" → "Run anyway".)
- **Linux:** on the [Releases page](https://github.com/acetousk/stormring/releases), download `stormring-<version>-linux-x86_64.tar.gz`. Unpack it and run the game.
- Mac and iPhone: use the web version.

Online rooms in the web, phone, and PC builds need this repo's GD-Sync keys (the kit's `online` skill). Until then, rooms work only inside Godot (2 windows, local mode).

## How to play

1. On the start screen pick **Solo**, or **Host** (you get a 4-digit room code) or **Join** (type a friend's code).
2. You start on top of a lunch table. Jump off: your napkin opens and you float down.
3. Hold **Use** on a lunch box to get tomatoes and a napkin.
4. Throw tomatoes: aim with the dot in the middle. Tomatoes fly in an arc, so aim a bit high for far targets. Each splat makes someone less clean.
5. Tap the tray carts with the spoon to get trays. Then build tray walls to block tomatoes.
6. Too messy? Use a napkin to wipe clean.
7. Stay inside the circle: the green jello spill closes in and makes anyone outside messy.
8. Be the last one clean. At 0% clean you are splatted and out of the round.

## Controls

| Action | Keyboard + mouse | Gamepad | Touch |
|---|---|---|---|
| Move | WASD | Left stick | Left stick |
| Look | Mouse | Right stick | Drag right side |
| Jump | Space | A | JUMP |
| Throw / scoop | Left click | RT | THROW |
| Aim | Right click | LT | — |
| Spoon / tomatoes | 1 / 2 | D-pad left / right | Automatic |
| Grab more tomatoes | R (or auto) | RB | Automatic |
| Build mode | Q | Y | BUILD |
| Open lunch box | Hold E | X | Hold USE |
| Wipe clean (napkin) | H | B | WIPE |

## Online

Online play uses [GD-Sync](https://www.gd-sync.com/). The downloaded builds don't have an online key yet, so
**Host and Join only work when you run the game from the Godot editor** (same computer or Wi-Fi). Solo works everywhere.

## Help and feedback

- Questions and known problems: [FAQ.md](FAQ.md).
- Found a bug, or have an idea? [Report it here](https://github.com/acetousk/stormring/issues/new/choose). Do not write your real name, age, school, or where you live.

## For the developer

- Open the folder in Godot 4.7.2 and press F5.
- `python3 tools/make_sfx.py` remakes the sounds in `sounds/`.
- `python3 tools/net_test.py` runs a host and a joiner with no windows and checks they see the same match.
- Every feel number is in `scripts/tune.gd`. The plan is in `PLAN.md`, the design in `DESIGN.md`, assets in `CREDITS.md`.
