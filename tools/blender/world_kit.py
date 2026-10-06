"""Small low-poly kit for the world scripts: primitives, a mesh collector and a
free-space map that knows what already stands in a module.

Pure Python (no Blender). Coordinates are the app's: x to the right, y into the
picture, z up; a module is 11.5 x 10 units (x in -5.75..5.75, y in -5..5) and
the ground plane lies at z = 0.08. Every solid is wound so its triangles face
outwards (the painter has no z-buffer and the app shades by the face normal).
"""
import math
from pathlib import Path

ROOT = Path(__file__).resolve().parents[2]
ASSETS = ROOT / 'apps/flutter/assets/worlds'
GROUND = 0.08


def linear(hex_colour):
    """#rrggbb -> linear [r, g, b] like Blender's diffuse_color."""
    h = hex_colour.lstrip('#')
    if len(h) == 3:
        h = ''.join(c * 2 for c in h)
    return [round((int(h[i:i + 2], 16) / 255) ** 2.2, 4) for i in (0, 2, 4)]


def rot(points, cx, cy, angle):
    """Rotate points about the vertical axis through (cx, cy)."""
    s, c = math.sin(angle), math.cos(angle)
    return [[cx + (p[0] - cx) * c - (p[1] - cy) * s,
             cy + (p[0] - cx) * s + (p[1] - cy) * c, p[2]] for p in points]


def _outward(points, faces):
    """Flip triangles whose normal points towards the solid's centre."""
    n = len(points)
    cx = sum(p[0] for p in points) / n
    cy = sum(p[1] for p in points) / n
    cz = sum(p[2] for p in points) / n
    out = []
    for a, b, c in faces:
        pa, pb, pc = points[a], points[b], points[c]
        u = [pb[k] - pa[k] for k in range(3)]
        v = [pc[k] - pa[k] for k in range(3)]
        nrm = [u[1] * v[2] - u[2] * v[1], u[2] * v[0] - u[0] * v[2], u[0] * v[1] - u[1] * v[0]]
        mid = [(pa[k] + pb[k] + pc[k]) / 3 - (cx, cy, cz)[k] for k in range(3)]
        out.append([a, c, b] if sum(nrm[k] * mid[k] for k in range(3)) < 0 else [a, b, c])
    return out


# ---- shapes: each returns (vertices, faces) ---------------------------------

def frustum(x, y, z0, r0, r1, h, seg=7, tilt=0.0):
    """Closed cone/cylinder; r1 = 0 gives a cone. `tilt` leans the top in x."""
    ring = [[x + r0 * math.cos(i * math.tau / seg), y + r0 * math.sin(i * math.tau / seg), z0] for i in range(seg)]
    if r1 <= 1e-6:
        pts = ring + [[x + tilt, y, z0 + h], [x, y, z0]]
        faces = [[i, (i + 1) % seg, seg] for i in range(seg)]
        faces += [[seg + 1, (i + 1) % seg, i] for i in range(seg)]
        return pts, _outward(pts, faces)
    pts = ring + [[x + tilt + r1 * math.cos(i * math.tau / seg), y + r1 * math.sin(i * math.tau / seg), z0 + h]
                  for i in range(seg)]
    faces = []
    for i in range(seg):
        j = (i + 1) % seg
        faces += [[i, j, seg + j], [i, seg + j, seg + i]]
    pts.append([x, y, z0])
    pts.append([x + tilt, y, z0 + h])
    faces += [[2 * seg, (i + 1) % seg, i] for i in range(seg)]
    faces += [[2 * seg + 1, seg + i, seg + (i + 1) % seg] for i in range(seg)]
    return pts, _outward(pts, faces)


def dome(x, y, z0, r, h, seg=7, rings=2):
    """Half sphere (cap of a mushroom, a bush base) closed at the bottom."""
    pts = [[x, y, z0 + h]]
    for k in range(1, rings + 1):
        a = k / rings * math.pi / 2
        for i in range(seg):
            pts.append([x + r * math.sin(a) * math.cos(i * math.tau / seg),
                        y + r * math.sin(a) * math.sin(i * math.tau / seg),
                        z0 + h * math.cos(a)])
    faces = [[0, 1 + i, 1 + (i + 1) % seg] for i in range(seg)]
    for k in range(rings - 1):
        for i in range(seg):
            a, b = 1 + k * seg + i, 1 + k * seg + (i + 1) % seg
            c, d = a + seg, b + seg
            faces += [[a, c, b], [b, c, d]]
    centre = len(pts)
    pts.append([x, y, z0])
    last = 1 + (rings - 1) * seg
    faces += [[centre, last + (i + 1) % seg, last + i] for i in range(seg)]
    return pts, _outward(pts, faces)


def ball(x, y, z, rx, ry=None, rz=None, seg=6, rings=3, spin=0.0):
    """Faceted ellipsoid centred at (x, y, z): a UV sphere with `rings` bands."""
    ry = rx if ry is None else ry
    rz = rx if rz is None else rz
    pts = [[0, 0, rz]]
    for k in range(1, rings):
        a = k / rings * math.pi
        for i in range(seg):
            t = i * math.tau / seg + (k % 2) * math.tau / seg / 2
            pts.append([rx * math.sin(a) * math.cos(t), ry * math.sin(a) * math.sin(t), rz * math.cos(a)])
    pts.append([0, 0, -rz])
    faces = [[0, 1 + i, 1 + (i + 1) % seg] for i in range(seg)]
    for k in range(rings - 2):
        for i in range(seg):
            a, b = 1 + k * seg + i, 1 + k * seg + (i + 1) % seg
            c, d = a + seg, b + seg
            faces += [[a, c, b], [b, c, d]]
    last = 1 + (rings - 2) * seg
    bottom = len(pts) - 1
    faces += [[bottom, last + (i + 1) % seg, last + i] for i in range(seg)]
    pts = rot([[p[0], p[1], p[2]] for p in pts], 0, 0, spin)
    pts = [[x + p[0], y + p[1], z + p[2]] for p in pts]
    return pts, _outward(pts, faces)


def box(x, y, z0, w, d, h, angle=0.0, offset=(0.0, 0.0)):
    """Box of size w x d x h standing on z0 at (x, y), turned by `angle`."""
    ox, oy = offset
    pts = [[ox + sx * w / 2, oy + sy * d / 2, z0 + sz * h] for sz in (0, 1) for sy in (-1, 1) for sx in (-1, 1)]
    faces = [[0, 1, 3], [0, 3, 2], [4, 6, 7], [4, 7, 5], [0, 4, 5], [0, 5, 1],
             [2, 3, 7], [2, 7, 6], [0, 2, 6], [0, 6, 4], [1, 5, 7], [1, 7, 3]]
    pts = rot([[x + p[0], y + p[1], p[2]] for p in pts], x, y, angle)
    return pts, _outward(pts, faces)


def beam(p0, p1, thick, thick2=None):
    """Square bar between two 3D points (fence rails, handles, sail arms)."""
    thick2 = thick if thick2 is None else thick2
    d = [p1[k] - p0[k] for k in range(3)]
    ln = math.sqrt(sum(c * c for c in d))
    d = [c / ln for c in d]
    up = [0, 0, 1] if abs(d[2]) < .9 else [1, 0, 0]
    u = [d[1] * up[2] - d[2] * up[1], d[2] * up[0] - d[0] * up[2], d[0] * up[1] - d[1] * up[0]]
    lu = math.sqrt(sum(c * c for c in u))
    u = [c / lu for c in u]
    v = [d[1] * u[2] - d[2] * u[1], d[2] * u[0] - d[0] * u[2], d[0] * u[1] - d[1] * u[0]]
    pts = []
    for p, t in ((p0, thick), (p1, thick2)):
        for su, sv in ((-1, -1), (1, -1), (1, 1), (-1, 1)):
            pts.append([p[k] + (su * u[k] + sv * v[k]) * t / 2 for k in range(3)])
    faces = [[0, 1, 5], [0, 5, 4], [1, 2, 6], [1, 6, 5], [2, 3, 7], [2, 7, 6], [3, 0, 4], [3, 4, 7],
             [0, 2, 1], [0, 3, 2], [4, 5, 6], [4, 6, 7]]
    return pts, _outward(pts, faces)


def prism(x, y, z0, w, d, rise, angle=0.0, offset=(0.0, 0.0)):
    """Gable roof / tent: ridge along the object's x axis, closed."""
    ox, oy = offset
    pts = [[-w / 2, -d / 2, z0], [w / 2, -d / 2, z0], [w / 2, d / 2, z0], [-w / 2, d / 2, z0],
           [-w / 2, 0, z0 + rise], [w / 2, 0, z0 + rise]]
    faces = [[0, 1, 2], [0, 2, 3], [0, 1, 5], [0, 5, 4], [2, 3, 4], [2, 4, 5], [0, 3, 4], [1, 2, 5]]
    pts = rot([[x + ox + p[0], y + oy + p[1], p[2]] for p in pts], x, y, angle)
    return pts, _outward(pts, faces)


def disc(x, y, z, r, seg=8, angle=0.0, squash=1.0):
    """Flat polygon facing up (decals: lily pads, blankets, patches)."""
    pts = [[x, y, z]] + [[x + r * math.cos(angle + i * math.tau / seg),
                          y + r * squash * math.sin(angle + i * math.tau / seg), z] for i in range(seg)]
    faces = [[0, 1 + i, 1 + (i + 1) % seg] for i in range(seg)]
    return pts, faces


def quad_up(x, y, z, w, d, angle=0.0):
    """Flat rectangle facing up."""
    pts = [[-w / 2, -d / 2, 0], [w / 2, -d / 2, 0], [w / 2, d / 2, 0], [-w / 2, d / 2, 0]]
    pts = rot([[x + p[0], y + p[1], z] for p in pts], x, y, angle)
    return pts, [[0, 1, 2], [0, 2, 3]]


def blade(base, tip, width, bend=0.0, up=(0, 0, 1)):
    """A thin leaf/petal/wing/flag: two triangles from `base` to `tip`. `up` is the
    normal of the plane it lies in (z for leaves, y for things hanging in the
    picture plane such as sails and flags); `bend` pushes the middle along it."""
    d = [tip[k] - base[k] for k in range(3)]
    w = [up[1] * d[2] - up[2] * d[1], up[2] * d[0] - up[0] * d[2], up[0] * d[1] - up[1] * d[0]]
    ln = math.sqrt(sum(c * c for c in w)) or 1
    w = [c / ln * width / 2 for c in w]
    mid = [(base[k] + tip[k]) / 2 + up[k] * bend for k in range(3)]
    pts = [list(base), [mid[k] + w[k] for k in range(3)], [mid[k] - w[k] for k in range(3)], list(tip)]
    return pts, [[0, 1, 2], [1, 3, 2]]


def merge(*shapes):
    """Concatenate (vertices, faces) pairs into one."""
    pts, faces = [], []
    for p, f in shapes:
        base = len(pts)
        pts += p
        faces += [[a + base, b + base, c + base] for a, b, c in f]
    return pts, faces


# ---- collecting meshes ------------------------------------------------------

class Kit:
    """Collects the meshes of one world and tracks the free ground."""

    PREFIX = 'Prop '

    def __init__(self, module, rng, variant=0):
        self.module = module
        self.rng = rng
        self.variant = variant
        self.meshes = []
        self.taken = []        # (x, y, radius) circles that are occupied
        self.water = []        # triangles of the stream / pond
        self.corridor = []     # path stations, to keep the trail open
        self._scan()

    def _scan(self):
        for m in self.module['meshes']:
            n = m['name']
            if n.startswith(self.PREFIX):
                continue
            v = m['vertices']
            if n.startswith(('Flowing woodland', 'Sandy stream')):
                for a, b, c in m['faces']:
                    self.water.append((v[a], v[b], v[c]))
            if n in ('earth', 'grass') or n.startswith(('Sandy', 'Flowing', 'Animated', 'trail', 'connector', 'station',
                                                        'Ranger', 'Hut ', 'Lantern', 'Flower', 'Petal', 'Meadow grass')):
                continue
            low = [p for p in v if p[2] < .55]
            if not low or max(p[2] for p in v) < .2:
                continue
            cx = sum(p[0] for p in low) / len(low)
            cy = sum(p[1] for p in low) / len(low)
            r = max(math.hypot(p[0] - cx, p[1] - cy) for p in low)
            if r > .05:
                self.taken.append((cx, cy, r + .12))
        s = self.module['slots']
        self.corridor = [(s[i][0], s[i][1], s[i + 1][0], s[i + 1][1]) for i in range(len(s) - 1)]

    # -- free space

    def in_water(self, x, y, margin=0.0):
        for a, b, c in self.water:
            if _inside(x, y, a, b, c):
                return True
        return False

    def near_trail(self, x, y, clearance=1.0):
        for x0, y0, x1, y1 in self.corridor:
            dx, dy = x1 - x0, y1 - y0
            t = max(0, min(1, ((x - x0) * dx + (y - y0) * dy) / (dx * dx + dy * dy)))
            if math.hypot(x - (x0 + t * dx), y - (y0 + t * dy)) < clearance:
                return True
        return False

    def free(self, x, y, r, water=False, trail=1.0, edge=.5):
        if abs(x) > 5.75 - edge or abs(y) > 5 - edge:
            return False
        if self.near_trail(x, y, trail + r * .5):
            return False
        if not water and self.in_water(x, y, r * .6):
            return False
        return all(math.hypot(x - tx, y - ty) > r + tr for tx, ty, tr in self.taken)

    def spot(self, r, region=None, tries=400, reserve=True, **kw):
        """Random free position of radius r; `region` = (x0, x1, y0, y1)."""
        x0, x1, y0, y1 = region or (-5.3, 5.3, -4.6, 4.6)
        for _ in range(tries):
            x, y = self.rng.uniform(x0, x1), self.rng.uniform(y0, y1)
            if self.free(x, y, r, **kw):
                if reserve:
                    self.taken.append((x, y, r))
                return x, y
        return None

    def reserve(self, x, y, r):
        self.taken.append((x, y, r))

    # -- adding meshes

    def add(self, name, shape, colour, motion='none', **extra):
        pts, faces = shape
        mesh = dict(name=self.PREFIX + name,
                    vertices=[[round(c, 4) for c in p] for p in pts],
                    faces=faces, color=linear(colour) if isinstance(colour, str) else colour,
                    motion=motion, pivot=None, slot=None)
        mesh.update({k: v for k, v in extra.items() if v is not None})
        # Two variants per world are drawn in alternate modules; their shadow
        # ids must not meet, and a lamp belongs to its own variant.
        mesh['variant'] = self.variant
        if mesh.get('shadow'):
            mesh['shadow'] = f'v{self.variant}:{mesh["shadow"]}'
        if mesh.get('lamp'):
            mesh['lamp'] = list(mesh['lamp']) + [self.variant]
        self.meshes.append(mesh)
        return mesh


def _inside(x, y, a, b, c):
    def side(p, q):
        return (x - q[0]) * (p[1] - q[1]) - (p[0] - q[0]) * (y - q[1])
    d1, d2, d3 = side(a, b), side(b, c), side(c, a)
    neg = d1 < 0 or d2 < 0 or d3 < 0
    pos = d1 > 0 or d2 > 0 or d3 > 0
    return not (neg and pos)


def strip_props(module):
    """Remove everything this kit added earlier (so the scripts can be re-run)."""
    module['meshes'] = [m for m in module['meshes'] if not m['name'].startswith(Kit.PREFIX)]
