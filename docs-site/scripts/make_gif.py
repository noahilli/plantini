#!/usr/bin/env python3
"""Assemble animation frames into a small looping GIF.

    make_gif.py <frames-dir> <out.gif> [--width 420] [--ms 1400] [--last-ms 2200]

Frames are PNGs sorted by name. Width is scaled, the palette is adaptive; the
result is kept small on purpose (the handbook ships these in the repository).
"""
import argparse
from pathlib import Path

from PIL import Image

ap = argparse.ArgumentParser()
ap.add_argument("frames")
ap.add_argument("out")
ap.add_argument("--width", type=int, default=420)
ap.add_argument("--ms", type=int, default=1400)
ap.add_argument("--last-ms", type=int, default=2200)
a = ap.parse_args()

files = sorted(Path(a.frames).glob("*.png"))
if not files:
    raise SystemExit(f"no frames in {a.frames}")
images = []
for f in files:
    im = Image.open(f).convert("RGB")
    h = round(im.height * a.width / im.width)
    images.append(im.resize((a.width, h), Image.LANCZOS))
quant = [im.quantize(colors=128, method=Image.Quantize.MEDIANCUT, dither=Image.Dither.FLOYDSTEINBERG) for im in images]
durations = [a.ms] * len(quant)
durations[-1] = a.last_ms
Path(a.out).parent.mkdir(parents=True, exist_ok=True)
quant[0].save(a.out, save_all=True, append_images=quant[1:], duration=durations, loop=0, optimize=True, disposal=2)
print(f"{a.out}: {len(quant)} frames, {Path(a.out).stat().st_size / 1024:.0f} KiB")
