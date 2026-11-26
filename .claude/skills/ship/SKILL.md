---
name: ship
description: Use when the kid says "ship", "release", "publish", "put it online", "update my phone", or a card or fix ends with "ship it". Commits, tags, and pushes a release, then checks the builds and the web link.
---

# Ship: release a version

You do every git step. The kid only says "go" and clicks **Allow** on each pop-up. Never ask the kid to type a command.

## 1. Ready?
1. `git status`. Nothing changed and no new commits since the last tag? Say "Nothing new to ship." Stop.
2. Run the checks: `godot --headless --import`, then `godot --headless --quit-after 60`. Errors → use `bug`. Stop.
3. Tests in `tools/` (for example `python3 tools/net_test.py`)? Run them yourself. They fail → run the same test on the last released tag (`git worktree add .godot/last <tag>`, then `git worktree remove --force .godot/last`).
   - It passes there → the new change broke it. Use `bug`. Stop.
   - It fails there too → this computer blocks the test, not the change. Tell the kid in 1 line, in game words. Use the kid's own 2-window play test instead, and go on.
4. A step the kid has not played yet? Ask for one ▶ Play round first.
5. **Quiz: does the kid know what ships?** Read `CHANGELOG.md` since the last tag. Do not read the list to the kid. Ask, one at a time:
   - "What is new in this version? Say it in your own words."
   - "Pick one change. How does it work?"
   - "Who will get it, and where?" (web, phone, PC)
   Wrong or unsure → a hint as in `game-plan` 3.4, never the answer. After 3 hints, do step 4 of `game-plan` 3.4: the kid asks you a question. Do not ship a change the kid cannot explain.

## 2. Pick the version
Read `git tag --sort=-v:refname`. Ask the kid: "Is this only fixes, or something new?" Their answer picks the number:
- Only fixes → the patch goes up: `v1.2.0` → `v1.2.1`
- New features → the minor goes up: `v1.2.1` → `v1.3.0`
- The first playable → `v0.1.0`, or the next free minor if older tags exist.

In `CHANGELOG.md`, change "not released yet" to the version and today's date.

## 3. Tell the kid, then go
Say, in 3 lines:
> Ready to ship **v1.2.1**: <the 1–3 changes>.
> I'll save it (commit), name it (tag), and send it to GitHub (push). Claude Code shows a pop-up for the name and the send. Click **Allow** each time.
> Say **go**.

After `go`:
1. `git add` the changed files by name. Never `git add -A`. Never add secrets (`keys.cfg`, `*.keystore`).
2. `git commit -m "v1.2.1: <one line>"`
3. `git tag v1.2.1 -m "v1.2.1"` (exactly this form, so the pop-up matches)
4. `git push`, then `git push origin v1.2.1`

A command was denied? Do not try another form of it. Say once: "That pop-up needs a click on **Allow**. Say go when you're ready." Do not retry until the kid answers. Never ask the kid to do the git steps by hand, or a parent to change a setting. Never ask for Allow on a command that is not in this list.

## 4. After the push: the 4 platforms
One push of a `v*` tag builds all 4 platforms on GitHub (`.github/workflows/release.yml`), in about 10 minutes:

| Platform | Where the kid gets it | File on the Releases page | How to play |
|---|---|---|---|
| Web | GitHub Pages: `https://<user>.github.io/<repo>/` (the link in `README.md`) | none (the web page) | Open the link. Press Ctrl+Shift+R the first time after a new version. |
| Android | Obtainium, from the Releases page | `<game>-<version>.apk` | Obtainium → tap update. First time: add the repo URL in Obtainium. |
| Windows | The Releases page | `<game>-<version>-windows.zip` | Unzip, then double-click the `.exe`. Windows warns once: More info → Run anyway. |
| Linux | The Releases page | `<game>-<version>-linux-x86_64.tar.gz` | Extract, then double-click the `.x86_64` file (or right-click → Run as a program). |

macOS and iPhone are not supported: they need a paid Apple account.

Use plain words. Say what each new word means the first time: a **tag** is the version name; **Obtainium** is the phone app that updates the game; **Ctrl+Shift+R** makes the browser load the new version.

An online game with no GitHub secrets yet (the kid has not done the `online` skill)? Add: "Online rooms work only in Godot until we do the `online` steps."

Say:
> Sent! GitHub builds it now, about 10 minutes.
> Then play it: web — `<the Pages link>` (press Ctrl+Shift+R once). Phone — Obtainium, tap update. PC — `<the Releases page link>`: Windows zip or Linux file.
> Tell me what you see.

Check that all 4 built: the Releases page for the new version has 3 files (apk, windows zip, linux tar.gz), and the web page shows the new version. One is missing, a build is red, or the game did not change? Use `doctor`.
