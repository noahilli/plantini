"""Add the evening and night light sources to the three ecosystem modules.

* a small hut in the forest and in the mountains,
* lanterns along the trail in the forest and the meadow,
* a field of fireflies over the meadow (data only; the app animates them).

Run with Python (no Blender needed, like create_ecosystem_modules.py):

    python3 tools/blender/add_night_lights.py

It is idempotent: it removes what it added before (meshes named "Hut ..." and
"Lantern ...", plus the `lights` and `fireflies` keys) and builds it again, so
run it after any regeneration of the modules (create_ecosystem_modules.py
rebuilds meadow and alpine from scratch and drops these additions).

Meshes with motion `glow` are the lit parts (windows, lantern glass). The app
draws them pale by day and in full warm light in the evening and at night, and
puts a soft halo around every entry of `lights` ([x, y, z, radius]).
Positions are chosen against the module's own geometry so nothing stands in
the stream, on the trail or inside a tree.
"""
import json
import math
from pathlib import Path

ROOT = Path(__file__).resolve().parents[2]
ASSETS = ROOT / 'apps/flutter/assets/worlds'
GROUND = 0.08  # top of the grass plane


def linear(hex_colour):
    h = hex_colour.lstrip('#')
    return [round((int(h[i:i + 2], 16) / 255) ** 2.2, 4) for i in (0, 2, 4)]


def solid(name, points, faces, colour, motion='none'):
    """A convex solid whose triangles are wound to face outwards."""
    cx = sum(p[0] for p in points) / len(points)
    cy = sum(p[1] for p in points) / len(points)
    cz = sum(p[2] for p in points) / len(points)
    tris = []
    for face in faces:
        for i in range(1, len(face) - 1):
            a, b, c = face[0], face[i], face[i + 1]
            pa, pb, pc = points[a], points[b], points[c]
            u = [pb[k] - pa[k] for k in range(3)]
            v = [pc[k] - pa[k] for k in range(3)]
            n = [u[1] * v[2] - u[2] * v[1], u[2] * v[0] - u[0] * v[2], u[0] * v[1] - u[1] * v[0]]
            mid = [(pa[k] + pb[k] + pc[k]) / 3 - (cx, cy, cz)[k] for k in range(3)]
            if sum(n[k] * mid[k] for k in range(3)) < 0:
                b, c = c, b
            tris.append([a, b, c])
    return {'name': name, 'vertices': [[round(c, 4) for c in p] for p in points], 'faces': tris,
            'color': linear(colour), 'motion': motion, 'pivot': None, 'slot': None}


def rotate(points, x, y, angle):
    s, c = math.sin(angle), math.cos(angle)
    return [[x + p[0] * c - p[1] * s, y + p[0] * s + p[1] * c, p[2]] for p in points]


def box(name, x, y, z0, w, d, h, colour, angle=0.0, offset=(0, 0), motion='none'):
    """Box of size w x d x h standing on z0 at (x, y); `offset` is in the object's own frame."""
    ox, oy = offset
    pts = [[ox + sx * w / 2, oy + sy * d / 2, z0 + sz * h] for sz in (0, 1) for sy in (-1, 1) for sx in (-1, 1)]
    faces = [[0, 1, 3, 2], [4, 6, 7, 5], [0, 4, 5, 1], [2, 3, 7, 6], [0, 2, 6, 4], [1, 5, 7, 3]]
    return solid(name, rotate(pts, x, y, angle), faces, colour, motion)


def prism_roof(name, x, y, z0, w, d, rise, colour, angle=0.0):
    """Gable roof, ridge along the object's x axis."""
    pts = [[-w / 2, -d / 2, z0], [w / 2, -d / 2, z0], [w / 2, d / 2, z0], [-w / 2, d / 2, z0],
           [-w / 2, 0, z0 + rise], [w / 2, 0, z0 + rise]]
    faces = [[0, 1, 2, 3], [0, 1, 5, 4], [2, 3, 4, 5], [0, 3, 4], [1, 2, 5]]
    return solid(name, rotate(pts, x, y, angle), faces, colour)


def pyramid(name, x, y, z0, base, rise, colour):
    pts = [[-base / 2, -base / 2, z0], [base / 2, -base / 2, z0], [base / 2, base / 2, z0],
           [-base / 2, base / 2, z0], [0, 0, z0 + rise]]
    faces = [[0, 1, 2, 3], [0, 1, 4], [1, 2, 4], [2, 3, 4], [3, 0, 4]]
    return solid(name, rotate(pts, x, y, 0), faces, colour)


def post(name, x, y, z0, radius, height, colour, sides=6):
    pts = [[radius * math.cos(i * math.tau / sides), radius * math.sin(i * math.tau / sides), z0 + h]
           for h in (0, height) for i in range(sides)]
    faces = [[i, (i + 1) % sides, sides + (i + 1) % sides, sides + i] for i in range(sides)]
    faces += [list(range(sides)), list(range(sides, 2 * sides))]
    return solid(name, rotate(pts, x, y, 0), faces, colour)


HUT_SCALE = 1.3


def hut(prefix, x, y, angle, stone):
    wall = '#8d8a82' if stone else '#8a5a30'
    roof = '#f4f6f8' if stone else '#5b6e3a'
    trim = '#5a4632'
    parts = [
        box(f'{prefix} wall', x, y, GROUND, .98, .8, .52, wall, angle),
        box(f'{prefix} base', x, y, GROUND, 1.04, .86, .1, '#6f6d68', angle),
        prism_roof(f'{prefix} roof', x, y, GROUND + .52, 1.22, 1.06, .36, roof, angle),
        box(f'{prefix} door', x, y, GROUND, .2, .03, .36, '#4a3322', angle, offset=(-.18, -.41)),
        box(f'{prefix} door frame', x, y, GROUND, .26, .02, .4, trim, angle, offset=(-.18, -.405)),
        box(f'{prefix} chimney', x, y, GROUND + .55, .13, .13, .5, '#76726a', angle, offset=(.3, .2)),
        box(f'{prefix} window front', x, y, GROUND + .22, .17, .03, .15, '#f1e3b0', angle, offset=(.25, -.41), motion='glow'),
        box(f'{prefix} window side', x, y, GROUND + .22, .03, .17, .15, '#f1e3b0', angle, offset=(.5, 0), motion='glow'),
        box(f'{prefix} window frame', x, y, GROUND + .2, .23, .02, .2, trim, angle, offset=(.25, -.405)),
    ]
    for part in parts:  # enlarge around the hut's own origin, keep it on the ground
        part['vertices'] = [[round(x + (vx - x) * HUT_SCALE, 4), round(y + (vy - y) * HUT_SCALE, 4),
                             round(GROUND + (vz - GROUND) * HUT_SCALE, 4)] for vx, vy, vz in part['vertices']]
    fx, fy = rotate([[.25 * HUT_SCALE, -.45 * HUT_SCALE, 0]], x, y, angle)[0][:2]
    return parts, [fx, fy, GROUND + .3 * HUT_SCALE, 1.25]


def lantern(prefix, x, y):
    parts = [
        box(f'{prefix} foot', x, y, GROUND, .16, .16, .08, '#6f6d68'),
        post(f'{prefix} post', x, y, GROUND, .032, .74, '#4a3322'),
        box(f'{prefix} glass', x, y, GROUND + .72, .13, .13, .17, '#f1e3b0', motion='glow'),
        pyramid(f'{prefix} cap', x, y, GROUND + .89, .22, .1, '#3a2a1a'),
    ]
    return parts, [x, y, GROUND + .8, 1.0]


def blockers(module):
    """Vertices of everything a lantern or a hut must not stand in."""
    out = []
    for m in module['meshes']:
        n = m['name']
        if n in ('earth', 'grass') or n.startswith(('Hut ', 'Lantern ', 'station', 'trail', 'connector')):
            continue
        solid_thing = n.startswith(('Tree trunk', 'Pine trunk', 'Mountain', 'Alpine stone', 'Bridge', 'Reusable canopy',
                                    'Pine crown', 'Animated water', 'Sandy stream', 'Flowing woodland',
                                    'Faceted river', 'Meadow hummock'))
        if solid_thing:
            # Only what reaches into the height of a hut or lantern (roof ridge ~1.0).
            out.extend((v[0], v[1]) for v in m['vertices'] if GROUND - .05 < v[2] < 1.15)
    return out


def free(points, x, y, radius):
    return all((px - x) ** 2 + (py - y) ** 2 > radius ** 2 for px, py in points)


def trail_midpoints(module):
    s = module['slots']
    return [((s[i][0] + s[i + 1][0]) / 2, (s[i][1] + s[i + 1][1]) / 2,
             s[i + 1][0] - s[i][0], s[i + 1][1] - s[i][1]) for i in range(len(s) - 1)]


def lanterns_for(module, blocked):
    parts, lights = [], []
    for i, (mx, my, dx, dy) in enumerate(trail_midpoints(module)):
        length = math.hypot(dx, dy)
        nx, ny = -dy / length, dx / length
        for side in (1, -1):
            for gap in (.62, .8):
                x, y = mx + side * nx * gap, my + side * ny * gap
                if free(blocked, x, y, .38):
                    p, l = lantern(f'Lantern {i}', x, y)
                    parts += p
                    lights.append(l)
                    break
            else:
                continue
            break
    return parts, lights


def hut_for(module, blocked, candidates, stone):
    # Nearest to the middle of the picture first, so the hut is not cut off at the edge.
    for x, y, angle in sorted(candidates, key=lambda c: abs(c[0])):
        if free(blocked, x, y, .85 * HUT_SCALE):
            return hut('Hut', x, y, angle, stone), (x, y)
    return None, None


def main():
    layout = {
        'forest': {'lanterns': True, 'hut': [(x / 10, y / 10, .25) for x in range(20, 46, 3) for y in range(-44, -14, 4)], 'stone': False},
        'meadow': {'lanterns': True, 'hut': None, 'fireflies': {'count': 16, 'area': [-1.2, 5.0, -4.8, 4.8], 'z': [.3, 1.4]}},
        'alpine': {'lanterns': False, 'hut': [(x / 10, y / 10, .3) for x in range(22, 46, 3) for y in range(-40, 40, 4)], 'stone': True},
    }
    for world, cfg in layout.items():
        path = ASSETS / f'{world}_module.json'
        module = json.loads(path.read_text())
        module['meshes'] = [m for m in module['meshes'] if not m['name'].startswith(('Hut ', 'Lantern '))]
        module.pop('lights', None)
        module.pop('fireflies', None)
        blocked = blockers(module)
        added, lights = [], []
        if cfg.get('lanterns'):
            parts, ls = lanterns_for(module, blocked)
            added += parts
            lights += ls
        if cfg.get('hut'):
            result, at = hut_for(module, blocked, cfg['hut'], cfg['stone'])
            if result:
                added += result[0]
                lights.append(result[1])
                print(f'{world}: hut at {at}')
            else:
                raise SystemExit(f'{world}: no free place for the hut')
        if cfg.get('fireflies'):
            module['fireflies'] = cfg['fireflies']
        module['meshes'] += added
        module['lights'] = [[round(v, 3) for v in l] for l in lights]
        path.write_text(json.dumps(module, separators=(',', ':')))
        print(f'{world}: {len(added)} meshes, {len(lights)} lights, '
              f'{sum(len(m["faces"]) for m in added)} triangles')


if __name__ == '__main__':
    main()
