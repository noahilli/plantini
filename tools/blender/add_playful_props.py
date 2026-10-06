"""Furnish the three ecosystem modules with playful, readable little scenes.

    python3 tools/blender/create_ecosystem_modules.py   # only if meadow/alpine must be rebuilt
    python3 tools/blender/add_playful_props.py          # this file
    python3 tools/blender/add_night_lights.py           # lanterns and huts go AFTER the props

Run with plain Python (no Blender). It is idempotent: it first removes every
mesh whose name starts with "Prop " and builds them again from fixed seeds, so
running it twice gives the same file. The forest base (exported from Blender)
is never regenerated, only extended.

What the app does with the extra fields (see world_module.dart):

* `motion` `spin` / `flap` / `bob` / `hop` / `orbit` + `anim` {pivot, axis, amp,
  freq, phase, drift, radius, roll}: animated parts. `freq` is a whole number of
  cycles per 6 s loop so the animation closes seamlessly; keep it <= 3 (the app
  records 16 frames per loop).
* `shadow`: parts with the same id throw ONE shadow (plus a soft blot at the foot).
* `layer` `decal` / `decal2`: flat things on the ground, painted over the terrain
  and the water but under everything upright. Never put two decals on the same
  height without a different layer (the painter has no z-buffer).
* `glow` [r, g, b] (0..255): colour of a `glow` mesh when it lights up.
* `lamp` [x, y, z, radius]: a light source the night-lights script collects.
* `solid`: true keeps the huts and lanterns away from this prop.

Two variants per world (`variant` 0 and 1, different scenes and seeds) are
written; the app draws variant m % 2 in module m, so the same windmill does not
repeat every ten units. Everything stays inside the module (|x| < 5.3,
|y| < 4.6) and off the trail.
The visible band on a phone is only about x -3.7 .. 3.7: the scenes are placed
in the middle and behind the path, not at the far right.
"""
import json
import math
import random
import sys
from pathlib import Path

sys.path.insert(0, str(Path(__file__).resolve().parent))
from world_kit import ASSETS, GROUND, Kit, ball, beam, blade, box, disc, dome, frustum, merge, prism, quad_up, rot, strip_props  # noqa: E402

G = GROUND


def anim(kit, parts, motion, **params):
    """Give every part of a creature the same animation."""
    for m in parts:
        m['motion'] = motion
        m['anim'] = dict(params)
    return parts


def jitter(rng, a):
    return rng.uniform(-a, a)


# ---- small things (no shadow) -----------------------------------------------

def toadstool(k, x, y, s=1.0, cap='#d9402f', spots='#fff4e0', glow=None, shadow=None):
    k.add('toadstool stem', frustum(x, y, G, .045 * s, .035 * s, .13 * s, 6), '#f3e7d0', shadow=shadow)
    m = k.add('toadstool cap', dome(x, y, G + .1 * s, .13 * s, .09 * s, 7, 2), cap, shadow=shadow,
              motion='glow' if glow else 'none', glow=glow)
    rng = k.rng
    for i in range(3):
        a = rng.uniform(0, math.tau)
        r = .075 * s
        k.add('toadstool spot', dome(x + r * math.cos(a), y + r * math.sin(a), G + .1 * s + .055 * s, .028 * s, .02 * s, 5, 1),
              spots, motion='glow' if glow else 'none', glow=glow)
    return m


def toadstool_group(k, x, y, n=3, glow=None, cap='#d9402f'):
    for i in range(n):
        a = k.rng.uniform(0, math.tau)
        d = k.rng.uniform(.08, .22)
        toadstool(k, x + d * math.cos(a), y + d * math.sin(a), k.rng.uniform(.7, 1.25), cap=cap, glow=glow)


def fern(k, x, y, s=1.0):
    for i in range(7):
        a = i * math.tau / 7 + k.rng.uniform(-.2, .2)
        tip = [x + .3 * s * math.cos(a), y + .3 * s * math.sin(a), G + .1 * s]
        k.add('fern', blade([x, y, G + .02], tip, .09 * s, bend=.12 * s), '#3f9a4a', motion='plant')


def berry_bush(k, x, y, s=1.0):
    k.add('bush', ball(x, y, G + .13 * s, .24 * s, .24 * s, .17 * s, 6, 3), '#3f9a4a', shadow=f'bush{x:.2f}{y:.2f}')
    k.add('bush top', ball(x + .06 * s, y - .04 * s, G + .25 * s, .15 * s, .15 * s, .11 * s, 6, 3), '#58b058')
    for i in range(6):
        a = k.rng.uniform(0, math.tau)
        k.add('berry', ball(x + .2 * s * math.cos(a), y + .2 * s * math.sin(a), G + .16 * s + k.rng.uniform(0, .1) * s, .036 * s, seg=5, rings=2),
              '#d8283c')


def stump(k, x, y, s=1.0):
    k.add('stump', frustum(x, y, G, .15 * s, .13 * s, .16 * s, 7), '#7a5230', shadow=f'stump{x:.2f}{y:.2f}', solid=True)
    k.add('stump top', frustum(x, y, G + .16 * s, .125 * s, .125 * s, .012, 7), '#e0bd85')
    k.add('stump ring', frustum(x, y, G + .172 * s, .075 * s, .075 * s, .006, 7), '#c79b60')


def log(k, x, y, angle, length=.8, r=.1, solid=True):
    dx, dy = math.cos(angle) * length / 2, math.sin(angle) * length / 2
    group = f'log{x:.2f}{y:.2f}'
    k.add('log', beam([x - dx, y - dy, G + r], [x + dx, y + dy, G + r], r * 1.8), '#8a5a33', shadow=group, solid=solid)
    k.add('log end', beam([x + dx * 1.0, y + dy * 1.0, G + r], [x + dx * 1.03, y + dy * 1.03, G + r], r * 1.5), '#e0bd85')
    return group


def flower_patch(k, x, y, n=7, colours=('#f4f1e6', '#f5c542', '#e86b9a', '#8a6be8'), r=.35, tall=(.12, .22)):
    for i in range(n):
        a, d = k.rng.uniform(0, math.tau), k.rng.uniform(0, r)
        fx, fy = x + d * math.cos(a), y + d * math.sin(a)
        h = k.rng.uniform(*tall)
        c = colours[i % len(colours)]
        k.add('flower stem', frustum(fx, fy, G, .014, .01, h, 4), '#3f8a3a', motion='plant')
        for j in range(5):
            b = j * math.tau / 5
            k.add('flower petal', dome(fx + .045 * math.cos(b), fy + .045 * math.sin(b), G + h, .045, .025, 5, 1), c, motion='plant')
        k.add('flower heart', dome(fx, fy, G + h, .03, .035, 5, 1), '#f5a623', motion='plant')


def butterfly(k, x, y, z, colour, phase, drift=(.5, .3, .08)):
    pivot = [x, y, z]
    params = dict(pivot=pivot, axis=[0, 1, 0], amp=.85, freq=3, phase=phase, drift=list(drift), driftFreq=1)
    wl = merge(blade([x, y, z], [x - .13, y + .02, z + .03], .1), blade([x, y, z], [x - .1, y - .02, z - .01], .08))
    wr = merge(blade([x, y, z], [x + .13, y + .02, z + .03], .1), blade([x, y, z], [x + .1, y - .02, z - .01], .08))
    parts = [
        k.add('butterfly wing', wl, colour, anim=dict(params)),
        k.add('butterfly wing', wr, colour, anim=dict(params, amp=-.85)),
        k.add('butterfly body', ball(x, y, z, .012, .045, .012, 4, 2), '#3a2a22', anim=dict(params, amp=0)),
    ]
    for m in parts:
        m['motion'] = 'flap'
        m['day'] = True  # not at night


def sign(k, x, y, angle=0.0, labels=2):
    group = f'sign{x:.2f}{y:.2f}'
    k.add('signpost', frustum(x, y, G, .035, .03, .72, 5), '#8a5a33', shadow=group, solid=True)
    for i in range(labels):
        z = G + .6 - i * .17
        side = 1 if i % 2 else -1
        k.add('signboard', box(x + side * .14, y - .02, z, .32, .03, .11, angle + side * .15), '#e6bd77' if i % 2 else '#f0d594', shadow=group)



# ---- more small scenes ----------------------------------------------------------

def mushroom_house(k, x, y):
    g = 'mushroomhouse'
    k.add('mushroom house stem', frustum(x, y, G, .24, .21, .4, 8), '#f3e7d0', shadow=g, solid=True)
    k.add('mushroom house cap', dome(x, y, G + .36, .46, .34, 8, 2), '#d9402f', shadow=g)
    for i in range(5):
        a = i * math.tau / 5 + .4
        k.add('mushroom house spot', dome(x + .33 * math.cos(a), y + .33 * math.sin(a), G + .36 + .2, .06, .045, 5, 1), '#fff4e0')
    k.add('mushroom house door', box(x - .06, y - .205, G, .15, .02, .26), '#6b4423')
    k.add('mushroom house window', box(x + .1, y - .2, G + .2, .09, .02, .09), '#f1e3b0', motion='glow', glow=[255, 205, 110],
          lamp=[x + .1, y - .24, G + .24, .9])
    k.add('mushroom house step', box(x - .06, y - .27, G, .22, .1, .04), '#9a9a95')


def well(k, x, y):
    g = 'well'
    k.add('well ring', frustum(x, y, G, .24, .22, .24, 8), '#a9a9a2', shadow=g, solid=True)
    k.add('well water', frustum(x, y, G + .22, .18, .18, .01, 8), '#2d6f9c')
    for sx in (-1, 1):
        k.add('well post', box(x + sx * .22, y, G + .1, .05, .05, .55), '#8a5a33', shadow=g)
    k.add('well beam', beam([x - .24, y, G + .6], [x + .24, y, G + .6], .05), '#7a5230', shadow=g)
    k.add('well roof', prism(x, y, G + .62, .6, .5, .22, 0), '#c0392b', shadow=g)
    k.add('well bucket', frustum(x + .1, y - .24, G, .06, .075, .09, 6), '#8a5a33')


def gnome(k, x, y, hat='#d9402f', face=None):
    k.add('gnome body', frustum(x, y, G, .065, .045, .1, 6), '#3d78c8')
    k.add('gnome head', ball(x, y, G + .13, .04, seg=5, rings=3), '#f0c9a0')
    k.add('gnome beard', frustum(x, y - .03, G + .06, .04, 0, .09, 5, tilt=0), '#f4f4f0')
    k.add('gnome hat', frustum(x, y, G + .14, .05, 0, .16, 6), hat)


def chapel(k, x, y):
    g = 'chapel'
    k.add('chapel wall', box(x, y, G, .5, .6, .38), '#f1ede4', shadow=g, solid=True)
    k.add('chapel roof', prism(x, y, G + .38, .6, .7, .22, math.pi / 2), '#b2443a', shadow=g)
    k.add('chapel tower', box(x, y + .18, G + .38, .2, .2, .3), '#f1ede4', shadow=g)
    k.add('chapel spire', frustum(x, y + .18, G + .68, .16, 0, .26, 4), '#b2443a', shadow=g)
    k.add('chapel door', box(x, y - .305, G, .14, .02, .24), '#5a3d28')
    k.add('chapel window', box(x + .17, y - .305, G + .17, .07, .02, .11), '#f1e3b0', motion='glow', glow=[255, 215, 120],
          lamp=[x + .17, y - .34, G + .22, .9])


def cow(k, x, y, angle=0.0):
    parts = []

    def part(name, shape, colour):
        pts, faces = shape
        pts = rot(pts, x, y, angle)
        parts.append(k.add(name, (pts, faces), colour))

    part('cow body', ball(x, y, G + .2, .09, .19, .1, 6, 3), '#f6f2ea')
    part('cow spot', ball(x + .04, y + .02, G + .27, .05, .07, .04, 5, 2), '#2a2a2a')
    part('cow spot', ball(x - .05, y - .08, G + .22, .045, .06, .05, 5, 2), '#2a2a2a')
    part('cow head', ball(x, y - .22, G + .26, .06, .07, .06, 5, 3), '#f6f2ea')
    part('cow muzzle', ball(x, y - .28, G + .24, .04, .03, .03, 4, 2), '#f0b6b0')
    part('cow horn', ball(x - .05, y - .21, G + .33, .012, .012, .035, 4, 2), '#e8dcc0')
    part('cow horn', ball(x + .05, y - .21, G + .33, .012, .012, .035, 4, 2), '#e8dcc0')
    part('cow bell', ball(x, y - .17, G + .19, .02, .02, .025, 4, 2), '#f2b827')
    for lx, ly in ((-.055, -.12), (.055, -.12), (-.055, .12), (.055, .12)):
        part('cow leg', frustum(x + lx, y + ly, G, .02, .017, .12, 4), '#d8d3c8')
    anim(k, parts, 'bob', amp=.012, freq=2, phase=(x * 7 % 1))
    k.reserve(x, y, .3)



# ---- forest ------------------------------------------------------------------

def camp(k):
    """A tent, a fire and two log seats by the river."""
    spot = k.spot(1.1, region=(-.3, 3.4, -.5, 3.8))
    if not spot:
        return
    x, y = spot
    tg = 'tent'
    k.add('tent', prism(x - .35, y + .1, G, .95, .8, .6, .2), '#f2e6c8', shadow=tg, solid=True)
    k.add('tent flap', prism(x - .35, y + .1, G + .02, .5, .81, .52, .2), '#d9402f')
    k.add('tent door', box(x - .35 - .08, y - .3, G, .22, .02, .36, .2), '#4a3322')
    k.add('tent pole', frustum(x - .35, y + .1, G + .55, .018, .012, .35, 4), '#8a5a33')
    flag = k.add('tent flag', blade([x - .35, y + .1, G + .85], [x - .35 + .24, y + .1, G + .8], .1, up=(0, 1, 0)), '#e8403a')
    flag['motion'] = 'flap'
    flag['anim'] = dict(pivot=[x - .35, y + .1, G + .85], axis=[0, 0, 1], amp=.5, freq=2)
    fx, fy = x + .6, y - .35
    for i in range(6):
        a = i * math.tau / 6
        k.add('fire stone', ball(fx + .17 * math.cos(a), fy + .17 * math.sin(a), G + .035, .06, .06, .045, 5, 2), '#8e8b86')
    k.add('fire log', beam([fx - .13, fy - .05, G + .05], [fx + .13, fy + .06, G + .09], .06), '#6b4423')
    k.add('fire log', beam([fx - .12, fy + .08, G + .09], [fx + .14, fy - .07, G + .05], .06), '#7a5230')
    k.add('flame', frustum(fx, fy, G + .08, .09, 0, .26, 6), '#ff8a2a', motion='glow', glow=[255, 190, 70],
          lamp=[fx, fy, G + .25, 1.05])
    k.add('flame core', frustum(fx, fy, G + .08, .05, 0, .17, 5), '#ffd25e', motion='glow', glow=[255, 232, 140])
    for sx, sy, a in ((fx - .55, fy - .1, 1.2), (fx + .1, fy - .62, .1)):
        log(k, sx, sy, a, .5, .09)
    k.reserve(fx, fy, .8)


def fairy_ring(k, region):
    spot = k.spot(.8, region=region)
    if not spot:
        return
    for i in range(7):
        a = i * math.tau / 7
        toadstool(k, spot[0] + .42 * math.cos(a), spot[1] + .3 * math.sin(a), .85, cap='#4fd0c8', spots='#e8fff8', glow=[110, 235, 220])


def squirrel(k, x, y):
    z = G + .2
    stump(k, x, y, 1.2)
    parts = [
        k.add('squirrel body', ball(x, y, z + .09, .08, .1, .09, 5, 3), '#c9772e'),
        k.add('squirrel tail', ball(x + .02, y + .13, z + .17, .055, .06, .14, 5, 3), '#e49a46'),
        k.add('squirrel head', ball(x, y - .08, z + .17, .055, seg=5, rings=3), '#c9772e'),
        k.add('squirrel ear', ball(x - .03, y - .08, z + .23, .018, seg=4, rings=2), '#c9772e'),
        k.add('squirrel ear', ball(x + .03, y - .08, z + .23, .018, seg=4, rings=2), '#c9772e'),
    ]
    anim(k, parts, 'hop', amp=.1, freq=2, phase=.15)


def birdhouse(k, bx, by):
    k.add('birdhouse post', frustum(bx, by, G, .03, .025, .75, 5), '#8a5a33', shadow=f'bh{bx:.2f}', solid=True)
    k.add('birdhouse', box(bx, by, G + .72, .26, .22, .22), '#e8a24b', shadow=f'bh{bx:.2f}')
    k.add('birdhouse roof', prism(bx, by, G + .94, .34, .3, .16), '#c0392b')
    k.add('birdhouse hole', box(bx, by - .116, G + .78, .07, .012, .07), '#2a1a10')
    bird = [k.add('bird body', ball(bx + .22, by, G + .86, .05, .06, .045, 5, 3), '#3d8fd6'),
            k.add('bird tail', ball(bx + .22, by + .075, G + .87, .02, .05, .015, 4, 2), '#2a6aa8'),
            k.add('bird beak', frustum(bx + .22, by - .07, G + .86, .014, 0, .04, 4), '#f5a623')]
    anim(k, bird, 'bob', amp=.025, freq=3)


def butterflies(k, n, region):
    palette = ('#f08a24', '#5ba3e8', '#f5d33b', '#ee6fa0', '#fff4e6', '#b58cf0')
    for i in range(n):
        p = k.spot(.2, region=region, reserve=False, water=True)
        if p:
            butterfly(k, p[0], p[1], G + k.rng.uniform(.5, 1.0), palette[i % len(palette)], i / n)


def floating_leaves(k, n, region):
    """Leaves that drift and turn in the air under the crowns."""
    palette = ('#e8a33a', '#f2c744', '#8fc24a', '#d9702f')
    for i in range(n):
        p = k.spot(.15, region=region, reserve=False, water=True)
        if not p:
            continue
        x, y, z = p[0], p[1], G + k.rng.uniform(.5, 1.2)
        leaf = k.add('floating leaf', blade([x, y, z], [x + .09, y + .03, z + .01], .06, bend=.01), palette[i % len(palette)])
        leaf['motion'] = 'flap'
        leaf['anim'] = dict(pivot=[x, y, z], axis=[1, 0, 0], amp=1.1, freq=2, phase=i / n,
                            drift=[.3, .25, .12], driftFreq=1)


def forest(module, variant):
    k = Kit(module, random.Random(3101 + 17 * variant), variant)
    mid = (-1.3, 3.7, -4.5, 4.5)
    wide = (-5.2, 3.7, -4.5, 4.5)
    k.reserve(2.9, -3.0, 1.5)  # the hut (add_night_lights.py)
    if variant == 0:
        camp(k)
        fairy_ring(k, mid)
    else:
        spot = k.spot(.8, region=(-.3, 3.2, .2, 3.8))
        if spot:
            mushroom_house(k, *spot)
        fairy_ring(k, mid)
    for _ in range(7):
        p = k.spot(.3, region=mid)
        if p:
            toadstool_group(k, p[0], p[1], k.rng.choice((2, 3, 4)))
    for _ in range(3):
        p = k.spot(.25, region=wide)
        if p:
            stump(k, p[0], p[1], k.rng.uniform(.9, 1.25))
    for _ in range(2):
        p = k.spot(.5, region=mid)
        if p:
            log(k, p[0], p[1], k.rng.uniform(-.5, .5), k.rng.uniform(.7, 1.0))
    for _ in range(9):
        p = k.spot(.3, region=wide)
        if p:
            fern(k, p[0], p[1], k.rng.uniform(.8, 1.3))
    for _ in range(4):
        p = k.spot(.35, region=mid)
        if p:
            berry_bush(k, p[0], p[1], k.rng.uniform(.9, 1.3))
    for _ in range(4):
        p = k.spot(.45, region=mid, reserve=False)
        if p:
            flower_patch(k, p[0], p[1], 6, r=.3)
    p = k.spot(.5, region=(-1.0, 3.4, -4.0, 4.0))
    if p:
        squirrel(k, *p) if variant == 0 else birdhouse(k, *p)
    p = k.spot(.5, region=(-.8, 3.2, -4.2, 4.0))
    if p:
        birdhouse(k, *p) if variant == 0 else sign(k, p[0], p[1])
    p = k.spot(.5, region=(-1.0, 3.5, -4.2, 4.2))
    if p and variant == 0:
        sign(k, p[0], p[1])
    butterflies(k, 5, mid)
    floating_leaves(k, 7, mid)
    return k


# ---- meadow -------------------------------------------------------------------

def sunflower(k, x, y, h=1.0):
    k.add('sunflower stem', frustum(x, y, G, .03, .022, h, 5), '#3f8a3a', motion='plant')
    k.add('sunflower leaf', blade([x, y, G + h * .35], [x + .24, y - .03, G + h * .45], .12, bend=.04), '#4aa04a', motion='plant')
    k.add('sunflower petals', dome(x, y - .03, G + h - .02, .17, .05, 8, 1), '#f7c52b', motion='plant')
    k.add('sunflower heart', dome(x, y - .06, G + h + .01, .09, .05, 7, 1), '#6b4423', motion='plant')


def windmill(k, x, y):
    g = 'windmill'
    k.add('windmill tower', frustum(x, y, G, .55, .38, 1.35, 8), '#efe2c6', shadow=g, solid=True)
    k.add('windmill band', frustum(x, y, G + .5, .49, .47, .12, 8), '#c9573f')
    k.add('windmill roof', frustum(x, y, G + 1.33, .5, 0, .5, 8), '#b2443a', shadow=g)
    k.add('windmill door', box(x, y - .5, G, .2, .03, .36, 0), '#5a3d28')
    k.add('windmill window', box(x + .02, y - .43, G + .75, .15, .03, .17, 0), '#f1e3b0', motion='glow', glow=[255, 215, 120],
          lamp=[x, y - .5, G + .84, 1.0])
    hub = [x, y - .4, G + 1.0]
    k.add('windmill hub', ball(hub[0], hub[1], hub[2], .07, seg=6, rings=2), '#7a5230', shadow=g)
    sails = []
    for i in range(4):
        a = i * math.pi / 2 + math.pi / 4
        tip = [hub[0] + math.cos(a) * .95, hub[1] - .02, hub[2] + math.sin(a) * .95]
        sails.append(k.add('windmill arm', beam(hub, tip, .05), '#7a5230'))
        near = [hub[0] + math.cos(a) * .15, hub[1] - .035, hub[2] + math.sin(a) * .15]
        sails.append(k.add('windmill sail', blade(near, [tip[0], tip[1] - .015, tip[2]], .24, up=(0, 1, 0)), '#fbf3dc'))
    anim(k, sails, 'spin', pivot=hub, axis=[0, 1, 0], freq=1)


def hives(k, x, y):
    for sx in (-.3, .3):
        g = f'hive{sx}'
        for lx, ly in ((-.1, -.08), (.1, -.08), (-.1, .08), (.1, .08)):
            k.add('hive leg', frustum(x + sx + lx, y + ly, G, .02, .02, .13, 4), '#7a5230')
        k.add('hive', box(x + sx, y, G + .13, .26, .24, .24), '#efc357', shadow=g, solid=True)
        k.add('hive stripe', box(x + sx, y, G + .22, .27, .25, .04), '#d9a02a')
        k.add('hive roof', prism(x + sx, y, G + .37, .32, .3, .1), '#c9573f')
        k.add('hive door', box(x + sx, y - .121, G + .16, .08, .01, .03), '#3a2a1a')
    for i in range(5):
        a = i * math.tau / 5
        bx, by, bz = x + .5 * math.cos(a), y - .4 + .3 * math.sin(a), G + .35 + .1 * (i % 2)
        bee = [k.add('bee', ball(bx, by, bz, .028, .04, .028, 4, 2), '#f4c20d'),
               k.add('bee stripe', ball(bx, by - .005, bz, .03, .012, .03, 4, 2), '#2a2118'),
               k.add('bee wing', box(bx, by, bz + .03, .06, .035, .004), '#e8f4ff')]
        anim(k, bee, 'orbit', pivot=[bx, by, bz], radius=.32, freq=2, phase=i / 5, amp=.04)
        for m in bee:
            m['day'] = True


def scarecrow(k, x, y):
    g = 'scarecrow'
    k.add('scarecrow post', frustum(x, y, G, .03, .025, 1.0, 5), '#8a5a33', shadow=g, solid=True)
    k.add('scarecrow arms', beam([x - .35, y, G + .75], [x + .35, y, G + .75], .04), '#8a5a33', shadow=g)
    k.add('scarecrow shirt', box(x, y, G + .5, .28, .16, .3), '#3d78c8', shadow=g)
    k.add('scarecrow head', ball(x, y, G + .92, .1, seg=6, rings=3), '#e9c46a')
    k.add('scarecrow hat', frustum(x, y, G + 1.0, .17, .07, .1, 6), '#8a5a33')
    k.add('scarecrow hat top', frustum(x, y, G + 1.1, .07, .05, .09, 6), '#6b4423')
    for sx in (-1, 1):
        k.add('scarecrow straw', blade([x + sx * .35, y, G + .75], [x + sx * .46, y, G + .66], .06), '#e9c46a', motion='plant')


def farm_corner(k, x, y):
    """A short fence, two round hay bales and a wheelbarrow full of flowers."""
    for i in range(5):
        px = x - 1.0 + i * .5
        k.add('fence post', box(px, y, G, .06, .06, .42), '#b88a55', shadow='fence', solid=True)
        if i:
            for z in (.14, .3):
                k.add('fence rail', beam([px - .5, y, G + z], [px, y, G + z], .035), '#cf9d63')
    for hx, hy in ((x - .4, y + .55), (x + .35, y + .6)):
        g = f'hay{hx:.2f}'
        k.add('haybale', beam([hx - .22, hy, G + .2], [hx + .22, hy, G + .2], .4), '#e3c25d', shadow=g, solid=True)
        k.add('haybale end', beam([hx + .22, hy, G + .2], [hx + .235, hy, G + .2], .3), '#c9a23a')
    wx, wy = x + .1, y - .6
    k.add('wheelbarrow tray', box(wx, wy, G + .12, .26, .34, .1), '#c0392b', shadow='barrow', solid=True)
    k.add('wheelbarrow wheel', frustum(wx, wy - .22, G, .09, .09, .04, 6), '#2f2f2f')
    for sx in (-1, 1):
        k.add('wheelbarrow handle', beam([wx + sx * .1, wy + .15, G + .14], [wx + sx * .12, wy + .5, G + .25], .03), '#8a5a33')
    for c, ox, oy in (('#e8438d', -.05, -.02), ('#f5c542', .06, .05), ('#fff4e6', -.04, .09)):
        k.add('barrow flower', ball(wx + ox, wy + oy, G + .23, .06, seg=5, rings=2), c)


def picnic(k, x, y):
    red, white = [], []
    for i in range(4):
        for j in range(4):
            (red if (i + j) % 2 == 0 else white).append(quad_up(x - .45 + i * .225 + .1125, y - .45 + j * .225 + .1125, G + .012, .225, .225, .15))
    k.add('blanket red', merge(*red), '#d9402f', layer='decal')
    k.add('blanket white', merge(*white), '#fbf3e4', layer='decal')
    k.add('basket', box(x + .1, y + .05, G + .012, .22, .16, .1, .2), '#c68d4a', shadow='picnic')
    k.add('basket handle', beam([x, y, G + .17], [x + .2, y + .1, G + .17], .02), '#a77038')
    for c, ox, oy in (('#d8283c', -.25, -.15), ('#7ac14a', -.3, -.05), ('#f5c542', -.18, .18)):
        k.add('apple', ball(x + ox, y + oy, G + .045, .045, seg=5, rings=3), c)


def pond_life(k, variant):
    """Lily pads, lotus, ducks and a frog on the pond (centre (1.7, .7), radius 1.3)."""
    pond = (1.7, .7)
    for i in range(7):
        a, d = k.rng.uniform(0, math.tau), k.rng.uniform(.2, 1.0)
        px, py = pond[0] + d * math.cos(a), pond[1] + d * math.sin(a) * .85
        k.add('lily pad', disc(px, py, G + .085, k.rng.uniform(.1, .17), 8, a), '#4aa04a', layer='decal2')
        if i % 3 == variant:
            for j in range(6):
                b = j * math.tau / 6
                k.add('lotus petal', dome(px + .04 * math.cos(b), py + .04 * math.sin(b), G + .09, .035, .045, 5, 1), '#f58fb4')
    radii = ((.55, 0.0), (.85, .5)) if variant == 0 else ((.45, .25), (.7, .75), (.95, 0.0))
    for i, (r, ph) in enumerate(radii):
        px, py = pond[0] + r + .05, pond[1] - .05
        bz = G + .1
        parts = [k.add('duck body', ball(px, py, bz + .04, .06, .09, .05, 5, 3), '#fff9ec'),
                 k.add('duck head', ball(px, py + .08, bz + .11, .04, seg=5, rings=3), '#3a8f5a' if i == 0 else '#fff9ec'),
                 k.add('duck beak', frustum(px, py + .12, bz + .1, .018, 0, .05, 4), '#f58b1f'),
                 k.add('duck tail', ball(px, py - .09, bz + .07, .03, .03, .03, 4, 2), '#fff9ec')]
        anim(k, parts, 'orbit', pivot=[px, py, bz], radius=r, freq=1, phase=ph, amp=.0)
    if variant == 0:
        fx, fy = pond[0] - .3, pond[1] + .4
        k.add('frog pad', disc(fx, fy, G + .088, .17, 8), '#3f9a45', layer='decal2')
        frog = [k.add('frog body', ball(fx, fy, G + .13, .06, .07, .045, 5, 3), '#58b84a'),
                k.add('frog eye', ball(fx - .03, fy - .04, G + .18, .018, seg=4, rings=2), '#ffffff'),
                k.add('frog eye', ball(fx + .03, fy - .04, G + .18, .018, seg=4, rings=2), '#ffffff')]
        anim(k, frog, 'hop', amp=.12, freq=1, phase=.5)


def bunny(k, x, y):
    parts = [k.add('bunny body', ball(x, y, G + .1, .09, .12, .09, 5, 3), '#f4efe6'),
             k.add('bunny head', ball(x, y - .1, G + .18, .06, seg=5, rings=3), '#f4efe6'),
             k.add('bunny ear', ball(x - .025, y - .1, G + .31, .015, .015, .08, 4, 2), '#f4efe6'),
             k.add('bunny ear', ball(x + .025, y - .1, G + .31, .015, .015, .08, 4, 2), '#f1bcc4'),
             k.add('bunny tail', ball(x, y + .12, G + .1, .035, seg=4, rings=2), '#ffffff')]
    anim(k, parts, 'hop', amp=.14, freq=3, phase=.1)


def meadow(module, variant):
    k = Kit(module, random.Random(3102 + 17 * variant), variant)
    mid = (-1.3, 3.7, -4.5, 4.5)
    if variant == 0:
        p = k.spot(1.1, region=(1.0, 3.3, 1.8, 4.0))
        if p:
            windmill(k, *p)
        p = k.spot(1.0, region=(-1.0, 1.6, -4.2, -1.2))
        if p:
            hives(k, *p)
        p = k.spot(.6, region=(.4, 3.4, -3.6, -.4))
        if p:
            scarecrow(k, *p)
        p = k.spot(1.1, region=(.6, 3.3, -4.3, -2.0))
        if p:
            farm_corner(k, *p)
        p = k.spot(.9, region=(-1.0, 2.2, 1.0, 4.0))
        if p:
            picnic(k, *p)
    else:
        p = k.spot(.7, region=(.6, 3.4, 2.0, 4.0))
        if p:
            well(k, *p)
        for _ in range(4):
            q = k.spot(.2, region=(-1.0, 3.5, -4.2, 4.2))
            if q:
                gnome(k, q[0], q[1], hat=('#d9402f', '#3d78c8', '#f5c542', '#4aa04a')[_])
        p = k.spot(1.0, region=(.2, 3.2, -4.2, -1.4))
        if p:
            hives(k, *p)
        p = k.spot(.6, region=(-1.0, 2.0, 1.0, 4.0))
        if p:
            scarecrow(k, *p)
        p = k.spot(1.1, region=(.6, 3.3, -4.3, -2.0))
        if p:
            farm_corner(k, *p)
    pond_life(k, variant)
    for _ in range(5):
        p = k.spot(.25, region=(-1.0, 3.6, -4.4, 4.4))
        if p:
            sunflower(k, p[0], p[1], k.rng.uniform(.8, 1.15))
    for _ in range(5):
        p = k.spot(.45, region=mid, reserve=False)
        if p:
            flower_patch(k, p[0], p[1], 8, r=.35, tall=(.16, .32))
    p = k.spot(.4, region=(-1.0, 2.0, -3.0, 3.5))
    if p:
        bunny(k, *p)
    butterflies(k, 6, mid)
    return k


# ---- alpine -------------------------------------------------------------------

def cairn(k, x, y, s=1.0):
    g = f'cairn{x:.2f}{y:.2f}'
    z = G
    for i, (r, h) in enumerate(((.17, .1), (.14, .09), (.11, .08), (.08, .07))):
        k.add('cairn stone', ball(x + k.rng.uniform(-.015, .015), y, z + h / 2, r * s, r * s, h / 2 * s * 1.4, 6, 3),
              ('#8b8f94', '#a2a7ab', '#7c8186', '#b2b6b9')[i], shadow=g, solid=True)
        z += h * s * .8


def edelweiss(k, x, y, s=1.0):
    k.add('edelweiss stem', frustum(x, y, G, .012, .01, .13 * s, 4), '#6b8f5a', motion='plant')
    for i in range(7):
        a = i * math.tau / 7
        k.add('edelweiss petal', blade([x, y, G + .13 * s], [x + .085 * s * math.cos(a), y + .085 * s * math.sin(a), G + .14 * s], .05 * s),
              '#fbfbf2', motion='plant')
    k.add('edelweiss heart', dome(x, y, G + .125 * s, .028 * s, .03 * s, 5, 1), '#e9c46a', motion='plant')


def gentian(k, x, y):
    k.add('gentian stem', frustum(x, y, G, .01, .008, .09, 4), '#4d8f4d', motion='plant')
    k.add('gentian', dome(x, y, G + .08, .04, .06, 5, 2), '#2f5fd0', motion='plant')


def peak(k, x, y, r, h, rock='#8a8f96', snow='#f4f8fb', name='peak'):
    g = f'{name}{x:.1f}{y:.1f}'
    k.add(f'{name} rock', frustum(x, y, G, r, r * .26, h * .7, 6), rock, shadow=g, solid=True)
    k.add(f'{name} snow', frustum(x, y, G + h * .7, r * .26, 0, h * .3, 6), snow, shadow=g)
    k.add(f'{name} ridge', frustum(x + r * .55, y - r * .1, G, r * .6, 0, h * .55, 5), '#7d838b', shadow=g)


def prayer_flags(k, x, y):
    for sx in (-.65, .65):
        k.add('flag pole', frustum(x + sx, y, G, .03, .022, .9, 5), '#8a5a33', shadow=f'pole{sx}', solid=True)
    for i, c in enumerate(('#3d78c8', '#f5f5f0', '#d9402f', '#4aa04a', '#f5c542')):
        fx = x - .55 + i * .27
        fz = G + .82 - abs(i - 2) * .02 - .02
        f = k.add('prayer flag', blade([fx, y, fz + .01], [fx + .02, y, fz - .17], .2, up=(0, 1, 0)), c)
        f['motion'] = 'flap'
        f['anim'] = dict(pivot=[fx, y, fz], axis=[0, 0, 1], amp=.35, freq=2, phase=i * .17)
    k.add('flag string', beam([x - .65, y, G + .87], [x + .65, y, G + .87], .012), '#5a4632')


def footbridge(k, bx, by):
    k.reserve(bx, by, .9)
    for i in range(8):
        k.add('bridge plank', box(bx - .5 + i * .14 + .07, by, G + .06, .12, .5, .03), '#b88a55')
    for sy in (-.26, .26):
        k.add('bridge rail', beam([bx - .5, by + sy, G + .22], [bx + .6, by + sy, G + .22], .035), '#8a5a33', shadow='bridge')
        for sx in (-.5, .6):
            k.add('bridge post', frustum(bx + sx, by + sy, G, .03, .03, .26, 4), '#7a5230', shadow='bridge')


def ibex(k, x, y):
    k.add('ibex rock', ball(x, y, G + .14, .38, .3, .16, 6, 3), '#777c82', shadow='ibexrock', solid=True)
    z = G + .3
    k.add('ibex body', ball(x, y, z + .15, .22, .1, .12, 6, 3), '#a7937a')
    k.add('ibex neck', ball(x - .16, y, z + .26, .06, .06, .12, 5, 3), '#a7937a')
    k.add('ibex head', ball(x - .2, y, z + .39, .05, .06, .05, 5, 3), '#a7937a')
    for sy in (-.02, .02):
        k.add('ibex horn', blade([x - .2, y + sy, z + .43], [x - .08, y + sy, z + .55], .035, bend=.04, up=(0, 1, 0)), '#4a3a2a')
    for lx, ly in ((-.14, -.05), (-.14, .05), (.14, -.05), (.14, .05)):
        k.add('ibex leg', frustum(x + lx, y + ly, z - .02, .018, .015, .15, 4), '#7c6b58')


def marmot(k, x, y):
    k.add('burrow', disc(x, y, G + .014, .17, 7), '#4a3a2a', layer='decal')
    m = [k.add('marmot body', ball(x, y + .04, G + .09, .085, .1, .08, 5, 3), '#8e6b46'),
         k.add('marmot head', ball(x, y - .06, G + .15, .055, seg=5, rings=3), '#a07a52'),
         k.add('marmot ear', ball(x - .035, y - .06, G + .21, .014, seg=4, rings=2), '#6b4a2e'),
         k.add('marmot ear', ball(x + .035, y - .06, G + .21, .014, seg=4, rings=2), '#6b4a2e')]
    anim(k, m, 'bob', amp=.03, freq=2, phase=.2)


def eagle(k, ex, ey, ez):
    wings = [k.add('eagle wing', blade([ex, ey, ez], [ex - .5, ey - .1, ez + .05], .22, bend=.02), '#4b3a2a'),
             k.add('eagle wing', blade([ex, ey, ez], [ex + .5, ey - .1, ez + .05], .22, bend=.02), '#4b3a2a'),
             k.add('eagle body', ball(ex, ey, ez, .06, .16, .05, 5, 3), '#4b3a2a'),
             k.add('eagle head', ball(ex, ey + .17, ez + .02, .045, seg=5, rings=3), '#f4f0e6')]
    anim(k, wings, 'orbit', pivot=[ex, ey, ez], radius=1.5, freq=1, phase=.0, amp=.12)
    for m in wings:
        m['day'] = True


def alpine(module, variant):
    k = Kit(module, random.Random(3103 + 17 * variant), variant)
    k.reserve(3.2, -3.0, 1.4)  # the hut (add_night_lights.py), clear of the mountains
    # a layered range at the back and a lone horn on the right; the stream (x ~ .5) stays open
    ranges = (((3.4, 3.6, 1.2, 2.5), (4.7, 1.0, 1.0, 2.2), (2.6, 4.4, .8, 1.7), (-4.6, 3.9, .9, 1.9)),
              ((3.0, 4.0, 1.1, 2.3), (4.8, 2.0, 1.0, 2.6), (4.4, -.6, .8, 1.6), (-4.7, 4.0, .8, 1.6)))[variant]
    for x, y, r, h in ranges:
        peak(k, x, y, r, h)
        k.reserve(x, y, r)
    for _ in range(5):
        p = k.spot(.4, region=(-1.0, 3.8, -4.2, 3.0))
        if p:
            x, y = p
            s = k.rng.uniform(.8, 1.3)
            k.add('boulder', ball(x, y, G + .2 * s, .3 * s, .26 * s, .22 * s, 6, 3), '#868b92', shadow=f'rock{x:.2f}', solid=True)
            k.add('boulder snow', ball(x, y, G + .31 * s, .2 * s, .17 * s, .09 * s, 6, 2), '#f4f8fb')
    for _ in range(2):
        p = k.spot(.35, region=(-1.0, 3.2, -4.0, 3.5))
        if p:
            cairn(k, p[0], p[1], k.rng.uniform(.9, 1.3))
    p = k.spot(.5, region=(-.8, 2.6, -4.2, -1.0))
    if p:
        sign(k, p[0], p[1], 0.0)
    p = k.spot(1.0, region=(-.2, 2.4, .2, 3.6))
    if p:
        prayer_flags(k, *p)
    footbridge(k, .5, -2.0 if variant == 0 else 1.2)
    if variant == 0:
        p = k.spot(.6, region=(.2, 3.4, -4.0, -.2))
        if p:
            ibex(k, *p)
        p = k.spot(.4, region=(-1.0, 2.4, 1.0, 4.0))
        if p:
            marmot(k, *p)
        eagle(k, 1.0, 1.6, 2.7)
    else:
        p = k.spot(.8, region=(1.6, 3.4, -1.4, 2.0))
        if p:
            chapel(k, *p)
        for i in range(2):
            p = k.spot(.45, region=(-1.0, 2.6, -4.0, 1.0))
            if p:
                cow(k, p[0], p[1], k.rng.uniform(-.6, .6))
        eagle(k, 2.2, 2.4, 2.9)
    for _ in range(14):
        p = k.spot(.2, region=(-1.1, 3.8, -4.4, 4.4), reserve=False)
        if p:
            edelweiss(k, p[0], p[1], k.rng.uniform(.9, 1.3))
    for _ in range(14):
        p = k.spot(.2, region=(-1.1, 3.8, -4.4, 4.4), reserve=False)
        if p:
            gentian(k, p[0], p[1])
    for _ in range(4):
        p = k.spot(.35, region=(-1.1, 3.2, -4.0, 3.5))
        if p:
            x, y = p
            k.add('alpenrose bush', ball(x, y, G + .12, .22, .2, .13, 6, 3), '#2f7d52')
            for _i in range(7):
                a = k.rng.uniform(0, math.tau)
                k.add('alpenrose', dome(x + .15 * math.cos(a), y + .14 * math.sin(a), G + .2 + k.rng.uniform(0, .05), .045, .04, 5, 1), '#e8508a')
    for _ in range(3):
        p = k.spot(.5, region=(1.5, 4.0, -3.5, 3.0), reserve=False)
        if p:
            k.add('snow patch', disc(p[0], p[1], G + .014, k.rng.uniform(.25, .45), 7, k.rng.uniform(0, 6), .8), '#f4f8fb', layer='decal')
    tp = k.spot(.8, region=(1.2, 3.5, -.2, 2.8))
    if tp:
        k.add('tarn', disc(tp[0], tp[1], G + .012, .55, 10, .3, .8), '#bfe6ef', layer='decal')
        k.add('tarn ice', disc(tp[0] + .1, tp[1] - .05, G + .02, .3, 8, .8, .7), '#e8f8fb', layer='decal2')
    return k


# ---- run ----------------------------------------------------------------------

WORLDS = {'forest': forest, 'meadow': meadow, 'alpine': alpine}


def main():
    for name, build in WORLDS.items():
        path = ASSETS / f'{name}_module.json'
        module = json.loads(path.read_text())
        strip_props(module)
        meshes, total = [], 0
        for variant in (0, 1):
            kit = build(module, variant)
            meshes += kit.meshes
            total += sum(len(m['faces']) for m in kit.meshes)
            print(f'{name} variant {variant}: {len(kit.meshes)} prop meshes, '
                  f'{sum(len(m["faces"]) for m in kit.meshes)} triangles')
        module['meshes'] += meshes
        path.write_text(json.dumps(module, separators=(',', ':')))
        print(f'{name}: {len(module["meshes"])} meshes in total, {total} prop triangles in the file')


if __name__ == '__main__':
    main()
