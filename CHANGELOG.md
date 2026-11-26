# Changelog

## Not released yet

- Added: you see and hear your hits: "Splat!" on the crosshair and a hit sound.
- Added: when a tomato hits you, tomato mess shows on the side of the screen it came from, with an "ouch".
- Added: a splat feed in the top left ("Max splatted Rosa").
- Added: the lunch buddies have names over their heads and different shirt colors.
- Added: a floating tomato shows each lunch box you have not opened yet.
- Added: tips at the top for your first match: jump off the table, open a lunch box, throw, wipe with a napkin, and build a tray wall.
- Changed: the clean card says "Clean (0% = out)".
- Added: outside the jello, an arrow and the meters to the safe middle.
- Added: "+6 tomatoes +1 napkin" and "+1 tray" float up when you get them. New sounds for loot and for a kid who is out.
- Added: tomatoes leave a short trail, so you can follow them.
- Added: the kids have arms.
- Changed: a bot turns on whoever splats it, and wipes with a napkin when it gets messy.
- Changed: the report card says who splatted you ("Splatted by Max!"), and the camera turns to them. A win always gets an A+.
- Fixed: you could start on a table outside the jello circle and get messy from the first second.
- Fixed: a tomato close to the camera filled the whole screen.

## v0.3.0 — 2026-11-26 — Lunchroom Food Fight

- Changed: Stormring is now a kid-friendly food fight in a giant 80s school lunchroom. No guns: you throw tomatoes that fly in an arc and splat.
- Changed: everyone is a small kindergartner, so the lunchroom is huge. You start on top of a lunch table.
- Changed: jump off a table and a napkin parachute opens. You float down and steer.
- Changed: HP is now your clean meter, shown as a grade (A+ to F). Your shirt turns red as you get messy.
- Changed: the pickaxe is a spoon. Tap tray carts for trays, then build tray walls.
- Changed: chests are lunch boxes with tomatoes and a napkin (napkins wipe you clean).
- Changed: the storm is a green jello spill that closes in.
- Changed: new school look: a chalkboard start screen, index-card buttons, a report card with a gold star when you win.
- Changed: new sounds: throw, splat, tray clink, tray clack, jello wobble, and a school bell at the start.
- Added: the Android version. Install it with Obtainium.

## v0.2.4 — 2026-11-26

- Fixed: the web version goes live (the web page was not set up yet).

## v0.2.3 — 2026-11-26

- Added: a FAQ page and forms to report a bug, an idea, or a question.
- Fixed: the web and PC versions now come out even when the Android version can't be built.

## v0.2.2 — 2026-11-25

- Fixed: local-mode tests (2 windows) filled Output with "Key must not be empty". Player, bot, and storm syncs now send the sure way in local mode.

## v0.2.1 — 2026-11-25

- Fixed: in solo, the top left said "Connecting…" / "Could not connect" all match. Now it only shows in online matches.

## v0.2.0 — 2026-11-25 — Stormring, first playable

(v0.1.x were an earlier game in this repo.)

- Island with water, box buildings, trees, rocks, and 6 chests
- Glide down from 80 m, run, jump, third-person camera with aim zoom
- Burst rifle, reload, heal kits, pickaxe harvesting
- Build walls on a 4 m grid (green = OK, purple = can't); walls block shots and can break
- 3 bots that roam, shoot, and fight each other (now teal, so they don't look like the storm)
- Purple storm: waits 35 s, shrinks over 90 s, hurts more as it shrinks
- Win / lose screen with place, eliminations, and time; play again or go back to the start screen
- Start screen: Solo, Host (4-digit room code), Join
- Online with GD-Sync (local mode in the editor): the host runs bots, storm, chests, walls, and who wins
- `tools/net_test.py`: an automatic host-vs-joiner check
- 5 sounds made by `tools/make_sfx.py`; silent until your first click or tap
- Touch controls on phones: left stick, drag to look, FIRE / JUMP / BUILD / USE / HEAL, auto-pickaxe
- Stormring title and icon
