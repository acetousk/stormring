# Changelog

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
