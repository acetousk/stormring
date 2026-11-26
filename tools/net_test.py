#!/usr/bin/env python3
"""Net test: runs a host and a joiner with no windows, then checks they saw the same match.

Run from the project folder:   python3 tools/net_test.py
It takes about 1.5 minutes. Uses local mode (no key), so both copies run on this computer.
Set GODOT=/path/to/godot if `godot` is not on your PATH.
"""
import json
import os
import random
import subprocess
import sys
import tempfile
import time

PROJECT = os.path.dirname(os.path.dirname(os.path.abspath(__file__)))
GODOT = os.environ.get("GODOT", "godot")
MAX_SECONDS = 120

# How different the two copies may be and still count as "the same".
# (Moves are sent 20 times a second and smoothed, so spots lag a little,
#  most while someone falls or glides.)
POS_GAP = 5.0  # meters
HP_GAP = 24.0  # about two tomatoes
STORM_GAP = 2.0  # meters

results = []  # (ok, text)


def check(ok, text):
    results.append((ok, text))


def run_copy(role, code, log):
    cmd = [GODOT, "--headless", "--max-fps", "60", "--path", PROJECT,
           "--", f"--net-test={role}", f"--code={code}", f"--seconds={MAX_SECONDS}"]
    return subprocess.Popen(cmd, stdout=log, stderr=subprocess.STDOUT, text=True)


def save_log(log, name):
    """Keep the whole log in .godot/ (git-ignored) so it can be read after a red ❌."""
    log.seek(0)
    path = os.path.join(PROJECT, ".godot", name)
    with open(path, "w") as f:
        for l in log:
            if "Key must not be empty" not in l and "_unreliable_mac" not in l:
                f.write(l)
    return path


def read_log(log):
    log.seek(0)
    lines = [l.strip()[len("NETTEST: "):] for l in log if l.startswith("NETTEST: ")]
    snaps = {}
    for l in lines:
        if l.startswith("snap "):
            s = json.loads(l[len("snap "):])
            snaps[int(s["t"])] = s
    return lines, snaps


def dist(a, b):
    return sum((x - y) ** 2 for x, y in zip(a, b)) ** 0.5


def compare_fighters(t, kind, host_list, join_list):
    h = {f["path"]: f for f in host_list}
    j = {f["path"]: f for f in join_list}
    check(set(h) == set(j), f"{t} s  same {kind} on both ({len(h)} host, {len(j)} joiner)")
    for path in sorted(set(h) & set(j)):
        name = path.rsplit("/", 1)[-1]
        gap = dist(h[path]["pos"], j[path]["pos"])
        check(gap <= POS_GAP, f"{t} s  {kind[:-1]} {name} same spot (gap {gap:.1f} m)")
        hp_gap = abs(h[path]["hp"] - j[path]["hp"])
        check(hp_gap <= HP_GAP, f"{t} s  {kind[:-1]} {name} same HP (host {h[path]['hp']:.0f}, joiner {j[path]['hp']:.0f})")
        check(h[path]["out"] == j[path]["out"], f"{t} s  {kind[:-1]} {name} out on both or on neither")


def compare(t, h, j):
    compare_fighters(t, "players", h["players"], j["players"])
    compare_fighters(t, "bots", h["bots"], j["bots"])
    gap = dist(h["storm"]["center"], j["storm"]["center"])
    check(gap <= STORM_GAP, f"{t} s  storm middle matches (gap {gap:.1f} m)")
    r_gap = abs(h["storm"]["radius"] - j["storm"]["radius"])
    check(r_gap <= STORM_GAP, f"{t} s  storm size matches (host {h['storm']['radius']:.1f}, joiner {j['storm']['radius']:.1f})")
    check(sorted(h["chests_open"]) == sorted(j["chests_open"]),
          f"{t} s  same chests open (host {h['chests_open']}, joiner {j['chests_open']})")
    same_walls = len(h["walls"]) == len(j["walls"]) and all(
        any(dist(a, b) <= 0.5 for b in j["walls"]) for a in h["walls"])
    check(same_walls, f"{t} s  same walls ({len(h['walls'])} host, {len(j['walls'])} joiner)")
    if t >= 30:
        # The joiner opened a chest and built a wall at about 12-14 s.
        check(len(h["chests_open"]) >= 1, f"{t} s  the joiner's chest is open on the host")
        check(len(h["walls"]) >= 1, f"{t} s  the joiner's wall is on the host")


def main():
    code = str(random.randint(1000, 9999))
    print(f"Net test: room {code}. Starting host and joiner (about 1.5 minutes)...")
    with tempfile.TemporaryFile("w+") as host_log, tempfile.TemporaryFile("w+") as join_log:
        host = run_copy("host", code, host_log)
        time.sleep(2)  # Let the host make the room first.
        join = run_copy("join", code, join_log)
        try:
            host.wait(timeout=MAX_SECONDS + 30)
            join.wait(timeout=30)
        except subprocess.TimeoutExpired:
            host.kill()
            join.kill()
        host_lines, host_snaps = read_log(host_log)
        join_lines, join_snaps = read_log(join_log)
        logs = [save_log(host_log, "net_test_host.log"), save_log(join_log, "net_test_join.log")]

    joined = any("you are guest" in l for l in join_lines)
    check(joined, "joiner got into the room")
    check(any(l == "match started" for l in join_lines), "match started on the joiner")
    for t in (10, 30, 60):
        h, j = host_snaps.get(t), join_snaps.get(t)
        if h is None or j is None:
            who = " and ".join(n for n, s in (("host", h), ("joiner", j)) if s is None)
            check(False, f"{t} s  snapshot missing from {who}")
            continue
        compare(t, h, j)

    print()
    for ok, text in results:
        print(("✅ " if ok else "❌ ") + text)
    bad = sum(1 for ok, _ in results if not ok)
    print()
    if bad == 0:
        print(f"All {len(results)} checks passed: host and joiner saw the same match.")
    else:
        print(f"{bad} of {len(results)} checks failed.")
        print("Full logs:", *logs)
        if not joined:
            print("The joiner never found the room. Last joiner lines:")
            for l in join_lines[-5:]:
                print("   ", l)
            print("Local mode finds rooms with a UDP broadcast on this computer (ports 42354-42373).")
            print("Both copies must share one network: a firewall that blocks it, or a `godot`")
            print("that runs each copy in its own box with no network, stops the joiner.")
    sys.exit(1 if bad else 0)


if __name__ == "__main__":
    main()
