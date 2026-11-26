# Stormring

Glide onto an island, loot a rifle, build walls, and be the last one standing as the purple storm closes in.

A small 3D battle royale made with Godot 4.7.2. Play solo against 3 bots, or online with up to 4 friends.

## Play

- **Web:** https://acetousk.github.io/stormring/ (Chrome, Firefox, or Edge). Old version? Press Ctrl+Shift+R.
- **Android:** install **Obtainium**, tap **Add app**, and paste `https://github.com/acetousk/stormring`. Obtainium shows each update.
- **Windows:** on the [Releases page](https://github.com/acetousk/stormring/releases), download `stormring-<version>-windows.zip`. Unzip it and run the game. (Windows may warn about an unknown app: click "More info" → "Run anyway".)
- **Linux:** on the [Releases page](https://github.com/acetousk/stormring/releases), download `stormring-<version>-linux-x86_64.tar.gz`. Unpack it and run the game.
- Mac and iPhone: use the web version.

Online rooms in the web, phone, and PC builds need this repo's GD-Sync keys (the kit's `online` skill). Until then, rooms work only inside Godot (2 windows, local mode).

## How to play

1. On the start screen pick **Solo**, or **Host** (you get a 4-digit room code) or **Join** (type a friend's code).
2. You start high in the sky: glide down onto the island.
3. Hold **Use** on a chest to get a rifle and a heal kit.
4. Hit trees, rocks, and houses with the pickaxe for material, then build walls to block shots.
5. Stay inside the circle: the purple storm shrinks and hurts anyone outside.
6. Be the last one standing.

## Controls

| Action | Keyboard + mouse | Gamepad | Touch |
|---|---|---|---|
| Move | WASD | Left stick | Left stick |
| Look | Mouse | Right stick | Drag right side |
| Jump | Space | A | JUMP |
| Fire / harvest | Left click | RT | FIRE |
| Aim | Right click | LT | — |
| Pickaxe / rifle | 1 / 2 | D-pad left / right | Automatic |
| Reload | R (or auto) | RB | Automatic |
| Build mode | Q | Y | BUILD |
| Open chest | Hold E | X | Hold USE |
| Heal | H | B | HEAL |

## Online

Online play uses [GD-Sync](https://www.gd-sync.com/). In v0.2.0 the downloaded builds don't have an online key yet, so
**Host and Join only work when you run the game from the Godot editor** (same computer or Wi-Fi). Solo works everywhere.

## Help and feedback

- Questions and known problems: [FAQ.md](FAQ.md).
- Found a bug, or have an idea? [Report it here](https://github.com/acetousk/stormring/issues/new/choose). Do not write your real name, age, school, or where you live.

## For the developer

- Open the folder in Godot 4.7.2 and press F5.
- `python3 tools/make_sfx.py` remakes the sounds in `sounds/`.
- `python3 tools/net_test.py` runs a host and a joiner with no windows and checks they see the same match.
- Every feel number is in `scripts/tune.gd`. The plan is in `PLAN.md`, the design in `DESIGN.md`, assets in `CREDITS.md`.
