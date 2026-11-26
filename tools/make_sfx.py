#!/usr/bin/env python3
"""Makes the 5 Stormring sounds out of math and writes them to sounds/*.wav.

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


def shot():
    # A burst of noise (the bang) on top of a low thump that drops in pitch.
    n = len(seconds(0.18))
    out, phase = [], 0.0
    for i in range(n):
        freq = 140 - 80 * i / n
        phase += 2 * math.pi * freq / RATE
        thump = math.sin(phase) * fade(i, n, 6)
        bang = random.uniform(-1, 1) * fade(i, n, 14)
        out.append(0.6 * bang + 0.5 * thump)
    return out


def hit():
    # A short bright blip: "I hit something".
    n = len(seconds(0.08))
    out, phase = [], 0.0
    for i in range(n):
        freq = 1400 - 600 * i / n
        phase += 2 * math.pi * freq / RATE
        square = 1.0 if math.sin(phase) > 0 else -1.0
        out.append(0.35 * square * fade(i, n, 5))
    return out


def harvest():
    # A wooden "tok": a mid tone that dies fast, plus a tiny click.
    n = len(seconds(0.12))
    out = []
    for i in range(n):
        t = i / RATE
        tone = math.sin(2 * math.pi * 320 * t) + 0.4 * math.sin(2 * math.pi * 710 * t)
        click = random.uniform(-1, 1) if i < 60 else 0.0
        out.append(0.5 * tone * fade(i, n, 9) + 0.3 * click)
    return out


def build():
    # Two low "thunks" close together: the wall slots into place.
    n = len(seconds(0.25))
    half = n // 2
    out = []
    for i in range(n):
        j = i if i < half else i - half
        freq = 180 if i < half else 120
        t = j / RATE
        out.append(0.6 * math.sin(2 * math.pi * freq * t) * fade(j, half, 7))
    return out


def storm():
    # A low hum that wobbles. Exactly 2 s and every wave fits a whole number
    # of times, so it loops with no click.
    n = len(seconds(2.0))
    out = []
    for i in range(n):
        t = i / RATE
        hum = math.sin(2 * math.pi * 55 * t) + 0.6 * math.sin(2 * math.pi * 82.5 * t) \
            + 0.3 * math.sin(2 * math.pi * 165 * t)
        wobble = 0.75 + 0.25 * math.sin(2 * math.pi * 1.0 * t)
        out.append(0.3 * hum * wobble)
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
    for name, make in [("shot", shot), ("hit", hit), ("harvest", harvest),
                       ("build", build), ("storm", storm)]:
        write(name, make())
