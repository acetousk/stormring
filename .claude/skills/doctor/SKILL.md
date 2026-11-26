---
name: doctor
description: Use on the first run, and when the kid or parent says "doctor", "check my setup", "it won't build", "F5 does nothing", or Godot, git, GitHub, GD-Sync, or the builds act wrong. Checks the install and says who fixes each problem. Changes no file.
---

# Doctor: check the install

Change no file. Run each check, then show one ✅/❌ list.

## 1. Checks

| # | Check | Command or place | ✅ when |
|---|---|---|---|
| 1 | Godot | `godot --version` | It matches `GODOT_VERSION` in `.github/workflows/release.yml` |
| 2 | Project opens | `godot --headless --import` | No `ERROR` lines |
| 3 | Game runs | `godot --headless --quit-after 60` | No `ERROR` or `SCRIPT ERROR` lines |
| 4 | Export presets | Read `export_presets.cfg` | `Android`, `Windows Desktop`, `Linux`, `Web` |
| 5 | Python (for `tools/`) | `python3 --version`, on Windows `py --version` | 3.10 or newer |
| 6 | Git name | `git config --get user.name` and `git config --get user.email` | Both set |
| 7 | GitHub remote | `git remote -v` | A `github.com` URL |
| 8 | Pipeline test | `git tag --sort=-v:refname` | `v0.0.1` or newer |
| 9 | Clean tree | `git status` | Say how many files changed. Not an error. |
| 10 | GD-Sync (after card G5) | `addons/GD-Sync/` exists, and `project.godot` has `GDSync` under `[autoload]` | Both |
| 11 | GD-Sync key (online builds) | `addons/GD-Sync/keys.cfg` exists. Check only that it exists. Never read it. | It exists |
| 12 | Folder trusted | Safe commands (`git status`, `git add`) run with no pop-up | No pop-up for them |

Run checks 1–3 with no `timeout`, `cd`, or `&&` around them, so they need no approval.

## 2. Common causes

| ❌ | Likely cause | Who fixes | Fix |
|---|---|---|---|
| 1 `godot` not found | Godot is not on PATH | Parent | `1-setup.md`, part A |
| 1 wrong version | Old Godot | Parent | Install the version from check 1 |
| 2 or 3 errors | A script error | Claude | Use the `bug` skill with the first error line |
| 4 missing preset | Starter files changed | Parent | Copy `export_presets.cfg` from the starter |
| 5 | Python is missing | Parent | python.org, and tick "Add to PATH" |
| 6 | Git has no name | Kid, with help | `git config --global user.name "…"` (the kid types it) |
| 7 or 8 | The repo is not set up | Parent | `1-setup.md`, part B |
| 10 | The plugin is off | Kid | Project → Project Settings → Plugins → GD-Sync → On |
| 11 | No key yet | Kid | The `online` skill |
| 12 | The folder is not trusted, so Claude Code ignores the allow list and asks for everything | Kid | Close Claude Code. Open it again in the game folder. Click **Yes, I trust this folder**. |
| GD-Sync login loops, or the robot check fails | A test or embedded browser | Kid | Log in with a normal browser (Chrome, Firefox, Edge) |
| Released builds can't host or join, Godot can | No GitHub secrets, or they came after the build | Kid | The `online` skill, step 5, then `ship` |
| The Android emulator shows no video (Linux only) | The x264 codec is missing | Parent | Install `x264-libs` (Fedora: RPM Fusion free) |

Builds red on GitHub? Ask the kid for the link to the failed run, or a screenshot of the red step. Read the error. Fix it only if it is in a file you may edit. Otherwise say it is a parent fix.

## 3. Report
1. The ✅/❌ list. One line each.
2. For each ❌: what it is for (one line), who fixes it, and the fix.
3. All ✅? Say "All good." Go back to what the kid asked for.
