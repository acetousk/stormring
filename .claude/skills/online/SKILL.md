---
name: online
description: Use when the kid wants to play with friends on other computers or phones - "online", "rooms", "play with friends", "host a room", "the room code doesn't work", "GD-Sync key", or after card G5 works in Godot. Sets up GD-Sync keys so the released builds can host and join rooms, then tests a real room.
---

# Online: rooms for the released game

Use the gate in `game-plan` section 3: teach → plan → quiz (hints, never the answer) → approve → build.
You never see, ask for, or store a key. The kid pastes keys only into the GD-Sync window in Godot and into GitHub.

## 0. Ready?
- Card G5 works in Godot first: 2 windows (Debug → Customize Run Instances → 2), one hosts, one joins. Not yet? Do G5 with `new-game` or `feature`.
- `doctor` checks 10–11. Check 11 ✅ (`keys.cfg` exists) means step 2 is done on this computer.

## 1. Teach
Say, in game words:
- In Godot, both windows are on one computer, so they find each other with no key ("local mode").
- Friends on other computers meet on the GD-Sync server. The server lets in only games with your **keys**: a public key (like a username) and a private key (like a password).
- A room code is 4 digits. The host gets it and tells friends. Max 4 players. Private: no one finds it without the code.
- Your builds on GitHub get the keys from GitHub **secrets**. A secret is a locked box: the build can use it, nobody can read it.

## 2. Plan (show it, then quiz)
| # | Step | Who | Where |
|---|---|---|---|
| 1 | Log in at gd-sync.com in a **normal** browser (Chrome, Firefox, Edge). The robot check fails in test or embedded browsers. | Kid | gd-sync.com |
| 2 | Make a game in the dashboard with the game's name. Open **API Keys** → Create. | Kid | gd-sync.com |
| 3 | Save both keys in Bitwarden, in the "GD-Sync" item. | Kid | Bitwarden |
| 4 | In Godot: **Project → Tools → GD-Sync**. Paste both keys. Save. This writes `addons/GD-Sync/keys.cfg`, which git ignores. | Kid | Godot |
| 5 | On GitHub: the repo → **Settings → Secrets and variables → Actions → New repository secret**. Name `GDSYNC_PUBLIC_KEY`, paste the public key. Again for `GDSYNC_PRIVATE_KEY`. Names exactly like this. | Kid (or parent) | github.com |
| 6 | Ship a new version with `ship`. Only builds made after step 5 have the keys. | Claude + kid | Claude Code |
| 7 | Room test (section 4) | Kid + a friend | Web + phone or PC |

Quiz, one at a time, as in `game-plan` 3.3–3.4. Examples:
- "Why does the game work in 2 Godot windows, but not yet for a friend on a phone?"
- "Where do the keys go, and where must they never go?"
- "You added the secrets. Why do you still need to ship?"
All right? Ask "Approve this plan?" and stop.

## 3. Do it, one step at a time
Give one step, wait for `done`, then the next. Say exactly where to click.
- Never ask the kid to paste a key in the chat. A key shows up in the chat anyway? Say: "Delete that key in GD-Sync and make a new one." Do not repeat it.
- Do not read `keys.cfg`. Check only that it exists.
- `git status` shows `keys.cfg`? Stop. `.gitignore` is wrong; it is a parent fix.

## 4. Room test (after the ship builds, about 10 minutes)
1. The kid opens the web link (Ctrl+Shift+R once) and clicks **Host**. They read the 4-digit code.
2. A friend (or the kid's phone or PC download) clicks **Join** and types the code.
3. Both see each other move. The host's game runs the shared parts (storm, enemies, score, timer).

| What the kid sees | Likely cause | Fix |
|---|---|---|
| "Connecting…" forever, or a key error | The secrets are missing, misnamed, or added after this build | Check the 2 names in GitHub. Ship again. |
| Works in Godot, fails in a download | The build is older than the secrets | Ship again |
| "No room" | A wrong code, or the host left | Host again, read the code out slowly |
| Works on PC, not on the web | A web-only problem | `bug` skill with the browser console line (F12 → Console) |
| Lag with 4 players | Too much sent each frame | `feature`: send less often |

Works? Add `Added: online rooms with friends` to `CHANGELOG.md` if it is not there. Update the "Online" part of `README.md`: how to host and join, max 4 players.

## Limits (say them once)
- Free GD-Sync plan: 4 players per room, 200 MB a day for the whole game.
- The keys belong to the kid's GD-Sync account. A new computer needs step 4 again (from Bitwarden).
