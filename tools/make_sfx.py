#!/usr/bin/env python3
"""Makes the 6 Stormring lunchroom food fight sounds out of math and writes them to sounds/*.wav.

Run from the project folder:   python3 tools/make_sfx.py
Change a number below and run it again to change a sound.
Every sound is a list of numbers between -1 and 1 (where the speaker cone is),
22 050 of them per second.
"""
import math
import os
import random
import struct
import wave

RATE = 22050  # samples per second (enough for game sounds, small files)
OUT = os.path.join(os.path.dirname(os.path.dirname(os.path.abspath(__file__))), "sounds")
random.seed(7)  # Same sounds every time you run it.


def seconds(s):
    return range(int(s * RATE))


def fade(i, length, speed):
    """1 at the start, sliding down to 0. Bigger speed = shorter sound."""
    return math.exp(-speed * i / length)


def lowpass(samples, amount):
    """Makes a sound softer and duller. amount 0..1: bigger = duller."""
    out, last = [], 0.0
    for x in samples:
        last += (x - last) * (1 - amount)
        out.append(last)
    return out


def throw():
    # A whoosh: soft noise that swells and fades, like air past your arm.
    n = len(seconds(0.22))
    noise = [random.uniform(-1, 1) for _ in range(n)]
    noise = lowpass(noise, 0.85)
    out = []
    for i, x in enumerate(noise):
        swell = math.sin(math.pi * i / n) ** 2  # 0 → 1 → 0
        out.append(1.6 * x * swell)
    return out


def splat():
    # A wet "splut": a low blob that drops in pitch, plus a dull squish of noise.
    n = len(seconds(0.3))
    noise = lowpass([random.uniform(-1, 1) for _ in range(n)], 0.7)
    out, phase = [], 0.0
    for i in range(n):
        freq = 220 * fade(i, n, 2.5) + 60
        phase += 2 * math.pi * freq / RATE
        blob = math.sin(phase) * fade(i, n, 7)
        squish = noise[i] * fade(i, n, 10)
        out.append(0.55 * blob + 1.2 * squish)
    return out


def metal(i, partials, decay):
    """A ringing bit of metal: a few tones that do not fit together, fading out."""
    t = i / RATE
    return sum(a * math.sin(2 * math.pi * f * t) for f, a in partials) * math.exp(-decay * t)


def harvest():
    # A tray clink: you grab a plastic tray off the metal cart. A short "tink" and a rattle.
    n = len(seconds(0.22))
    out = [0.0] * n
    for k, start in enumerate([0, 900, 1700]):
        for j in range(n - start):
            out[start + j] += (0.5 - 0.12 * k) * metal(j, [(1850, 0.6), (2730, 0.3), (4100, 0.15)], 30)
    return out


def build():
    # A tray "clack": a flat hard slap, then a soft wobble, like a tray dropped on its edge.
    n = len(seconds(0.3))
    out = []
    for i in range(n):
        slap = random.uniform(-1, 1) * fade(i, n, 40)
        wobble = 0.45 * math.sin(2 * math.pi * (180 + 40 * math.sin(i / RATE * 60)) * i / RATE) * fade(i, n, 7)
        out.append(0.6 * slap + wobble)
    return lowpass(out, 0.35)


def bell():
    # The school bell: a little hammer hits a metal bell 22 times a second for 1.4 s.
    n = len(seconds(1.8))
    out = [0.0] * n
    hit_every = RATE // 22
    for start in range(0, int(1.4 * RATE), hit_every):
        for j in range(min(int(0.4 * RATE), n - start)):
            out[start + j] += 0.12 * metal(j, [(1180, 1.0), (2950, 0.5), (4400, 0.25)], 9)
    return out


def storm():
    # Jello spill wobble: a soft low wobble with "blub" bubbles on top.
    # Exactly 2 s, every wave fits a whole number of times, and every bubble
    # ends before 2 s, so it loops with no click.
    n = len(seconds(2.0))
    out = []
    for i in range(n):
        t = i / RATE
        hum = math.sin(2 * math.pi * 55 * t) + 0.4 * math.sin(2 * math.pi * 110 * t)
        wobble = 0.7 + 0.3 * math.sin(2 * math.pi * 2.0 * t)
        out.append(0.18 * hum * wobble)
    for start in [0.05, 0.35, 0.6, 0.95, 1.2, 1.5, 1.7]:
        b0, length = int(start * RATE), int(0.12 * RATE)
        base = random.uniform(180, 320)
        phase = 0.0
        for j in range(length):
            freq = base * (1 + 1.5 * j / length)  # Bubbles rise in pitch.
            phase += 2 * math.pi * freq / RATE
            out[b0 + j] += 0.35 * math.sin(phase) * math.sin(math.pi * j / length)
    return out


def write(name, samples):
    path = os.path.join(OUT, name + ".wav")
    with wave.open(path, "wb") as f:
        f.setnchannels(1)
        f.setsampwidth(2)  # 16-bit
        f.setframerate(RATE)
        f.writeframes(b"".join(
            struct.pack("<h", int(max(-1.0, min(1.0, s)) * 32767)) for s in samples))
    print("wrote", os.path.relpath(path), f"({len(samples) / RATE:.2f} s)")


if __name__ == "__main__":
    os.makedirs(OUT, exist_ok=True)
    for name, make in [("throw", throw), ("splat", splat), ("harvest", harvest),
                       ("build", build), ("storm", storm), ("bell", bell)]:
        write(name, make())
