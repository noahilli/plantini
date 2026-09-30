"""Build the Plantini character kit in Blender and export it for the app.

The character is assembled from interchangeable parts (body, top, bottom,
shoes, hair, hat, glasses, backpack). Every part is a few dozen low-poly
primitives built with bmesh; the app recolours them (skin, hair, clothes) and
places the chosen parts together, so a character is only a small JSON record.

Run headless:   blender -b -P tools/blender/create_character_parts.py
Output:         apps/flutter/assets/characters/parts.json
Preview render: artifacts/3d/character-kit/kit.png (Cycles, CPU)

Conventions (same as the world modules): z is up, the character stands on
z = 0.10 and looks towards -y (the camera of the level path). Colours in the
export are the kit's defaults; `tint` names the colour the app substitutes and
`shade` scales it (soles, pompom, collar).
"""
import json
import math
import sys
from pathlib import Path

import bmesh
import bpy
from mathutils import Euler, Matrix, Vector

ROOT = Path(__file__).resolve().parents[2]
OUT = ROOT / 'apps/flutter/assets/characters/parts.json'
PREVIEW = ROOT / 'artifacts/3d/character-kit'

# Default (sRGB) tint colours used for the preview and as export defaults.
DEFAULT = {
    'skin': '#e8b98f', 'hair': '#5b3a22', 'top': '#3f7fd0', 'bottom': '#3d4860',
    'shoes': '#6a4428', 'hat': '#c67139', 'glasses': '#2d2a28',
    'backpack': '#d9602f', 'fixed-eye': '#231f1d', 'fixed-sole': '#f0ece2',
}


def srgb_to_linear(hex_colour):
    h = hex_colour.lstrip('#')
    return [round((int(h[i:i + 2], 16) / 255) ** 2.2, 4) for i in (0, 2, 4)]


class Part:
    """One recolourable piece: a bag of primitives merged into one mesh."""

    def __init__(self, name, tint, shade=1.0, hide_with_hat=False):
        self.name, self.tint, self.shade = name, tint, shade
        self.hide_with_hat = hide_with_hat
        self.bm = bmesh.new()

    def _add(self, result_verts, scale, loc, rot):
        m = Matrix.LocRotScale(Vector(loc), Euler(rot, 'XYZ'), Vector(scale))
        bmesh.ops.transform(self.bm, matrix=m, verts=result_verts)

    def box(self, loc, size, rot=(0, 0, 0)):
        r = bmesh.ops.create_cube(self.bm, size=1.0)
        self._add(r['verts'], size, loc, rot)
        return self

    def sphere(self, loc, radii, rot=(0, 0, 0), seg=10, rings=6):
        r = bmesh.ops.create_uvsphere(self.bm, u_segments=seg, v_segments=rings, radius=1.0)
        self._add(r['verts'], radii, loc, rot)
        return self

    def cyl(self, loc, r_bottom, r_top, height, rot=(0, 0, 0), seg=10, squash=1.0):
        r = bmesh.ops.create_cone(
            self.bm, cap_ends=True, cap_tris=False, segments=seg,
            radius1=r_bottom, radius2=r_top, depth=height)
        self._add(r['verts'], (1, squash, 1), loc, rot)
        return self

    def export(self):
        bmesh.ops.triangulate(self.bm, faces=self.bm.faces[:])
        self.bm.verts.ensure_lookup_table()
        vertices = [[round(v.co.x, 4), round(v.co.y, 4), round(v.co.z, 4)] for v in self.bm.verts]
        faces = [[v.index for v in f.verts] for f in self.bm.faces]
        return {
            'name': self.name, 'tint': self.tint, 'shade': self.shade,
            **({'hideWithHat': True} if self.hide_with_hat else {}),
            'vertices': vertices, 'faces': faces,
        }


KIT = {}          # 'category.style' -> [Part]


def add(category, style, *parts):
    KIT[f'{category}.{style}'] = list(parts)


# ---- body --------------------------------------------------------------------
# `head` and `eyes` keep their width when the app widens or narrows the body.
body_skin = Part('head', 'skin')
body_skin.sphere((0, 0, .95), (.175, .165, .175), seg=12, rings=8)
body_skin.cyl((0, 0, .80), .055, .055, .08)
limbs = Part('limbs', 'skin')
limbs.sphere((.255, 0, .455), (.05, .05, .05), seg=8, rings=5)
limbs.sphere((-.255, 0, .455), (.05, .05, .05), seg=8, rings=5)
eyes = Part('eyes', 'fixed-eye')
eyes.box((.065, -.158, .955), (.045, .025, .055))
eyes.box((-.065, -.158, .955), (.045, .025, .055))
add('body', 'base', body_skin, limbs, eyes)

# ---- tops --------------------------------------------------------------------
def torso(p, w=.34, d=.21, z0=.46, z1=.80):
    p.box((0, 0, (z0 + z1) / 2), (w, d, z1 - z0))
    return p

tshirt = torso(Part('tshirt', 'top'))
tshirt.box((.215, 0, .715), (.10, .14, .13))
tshirt.box((-.215, 0, .715), (.10, .14, .13))
forearms = Part('forearms', 'skin')
for sx in (1, -1):
    forearms.box((sx * .245, 0, .585), (.065, .075, .17))
add('top', 'tshirt', tshirt, forearms)

hoodie = torso(Part('hoodie', 'top'), w=.37, d=.23)
for sx in (1, -1):
    hoodie.box((sx * .235, 0, .62), (.10, .14, .30), rot=(0, sx * .06, 0))
hoodie.sphere((0, .095, .83), (.15, .10, .10), seg=10, rings=5)
hoodie_pocket = Part('pocket', 'top', .88).box((0, -.12, .56), (.20, .03, .09))
add('top', 'hoodie', hoodie, hoodie_pocket)

jacket = torso(Part('jacket', 'top'), w=.36, d=.22)
for sx in (1, -1):
    jacket.box((sx * .23, 0, .62), (.10, .14, .31))
collar = Part('collar', 'top', 1.22).cyl((0, 0, .805), .10, .085, .05)
zip_line = Part('zip', 'top', .65).box((0, -.113, .63), (.025, .012, .32))
add('top', 'jacket', jacket, collar, zip_line)

sweater = torso(Part('sweater', 'top'), w=.36, d=.22)
for sx in (1, -1):
    sweater.box((sx * .23, 0, .62), (.10, .14, .31))
roll = Part('roll', 'top', 1.12).cyl((0, 0, .81), .10, .095, .06)
hem = Part('hem', 'top', .86).box((0, 0, .475), (.365, .225, .04))
add('top', 'sweater', sweater, roll, hem)

# ---- bottoms -----------------------------------------------------------------
def hips(p):
    return p.box((0, 0, .46), (.345, .215, .12))

trousers = hips(Part('trousers', 'bottom'))
trousers.cyl((.085, 0, .30), .07, .07, .36)
trousers.cyl((-.085, 0, .30), .07, .07, .36)
add('bottom', 'trousers', trousers)

shorts = hips(Part('shorts', 'bottom'))
shorts.cyl((.085, 0, .41), .08, .08, .14)
shorts.cyl((-.085, 0, .41), .08, .08, .14)
legs_shorts = Part('legs', 'skin')
legs_shorts.cyl((.085, 0, .225), .058, .056, .25)
legs_shorts.cyl((-.085, 0, .225), .058, .056, .25)
add('bottom', 'shorts', shorts, legs_shorts)

skirt = Part('skirt', 'bottom')
skirt.cyl((0, 0, .39), .27, .19, .22, seg=12, squash=.9)
skirt_hem = Part('skirt hem', 'bottom', .85).cyl((0, 0, .285), .275, .27, .03, seg=12, squash=.9)
legs_skirt = Part('legs', 'skin')
legs_skirt.cyl((.085, 0, .21), .058, .056, .22)
legs_skirt.cyl((-.085, 0, .21), .058, .056, .22)
add('bottom', 'skirt', skirt, skirt_hem, legs_skirt)

# ---- shoes -------------------------------------------------------------------
def shoe(p, sole, tall=0.0):
    for sx in (1, -1):
        p.box((sx * .09, -.035, .15), (.11, .22, .09))
        sole.box((sx * .09, -.035, .112), (.118, .23, .035))
        if tall:
            p.cyl((sx * .085, 0, .19 + tall / 2), .092, .094, tall, seg=8)
    return p

_sole = Part('soles', 'fixed-sole')
_s = shoe(Part('sneakers', 'shoes'), _sole)
add('shoes', 'sneakers', _s, _sole)
_sole = Part('soles', 'fixed-sole')
_b = shoe(Part('boots', 'shoes'), _sole, tall=.12)
add('shoes', 'boots', _b, _sole)
_sole = Part('soles', 'fixed-sole')
_r = shoe(Part('rain boots', 'shoes'), _sole, tall=.15)
add('shoes', 'rainboots', _r, _sole)

# ---- hair --------------------------------------------------------------------
def hair_cap(p, grow=1.0):
    p.sphere((0, .035, .985), (.185 * grow, .18 * grow, .165 * grow), seg=12, rings=7)
    return p


def fringe():
    # Hidden under hats: a fringe under a cap looks like a dark stripe.
    return Part('fringe', 'hair', hide_with_hat=True).box((0, -.14, 1.04), (.27, .05, .05))


add('hair', 'short', hair_cap(Part('short hair', 'hair')), fringe())
long_hair = hair_cap(Part('long hair', 'hair'))
long_hair.box((0, .12, .82), (.34, .07, .40))
long_hair.box((.165, .04, .88), (.05, .10, .26))
long_hair.box((-.165, .04, .88), (.05, .10, .26))
add('hair', 'long', long_hair, fringe())
bun = hair_cap(Part('bun', 'hair'))
bun.sphere((0, .05, 1.17), (.075, .075, .07), seg=8, rings=5)
add('hair', 'bun', bun, fringe())
pony = hair_cap(Part('ponytail', 'hair'))
pony.cyl((0, .19, .92), .045, .03, .26, rot=(math.radians(18), 0, 0), seg=8)
pony.sphere((0, .17, 1.04), (.05, .05, .05), seg=8, rings=5)
add('hair', 'ponytail', pony, fringe())
curly = Part('curly hair', 'hair')
for i in range(10):
    a = i / 10 * math.tau
    curly.sphere((math.cos(a) * .12, .03 + math.sin(a) * .11, 1.04 + .03 * math.sin(a * 3)), (.085, .085, .08), seg=8, rings=5)
curly.sphere((0, .03, 1.11), (.10, .10, .075), seg=8, rings=5)
curly.sphere((0, .09, .95), (.17, .07, .13), seg=8, rings=5)
add('hair', 'curly', curly)
buzz = Part('buzz cut', 'hair', .9)
buzz.sphere((0, .02, .985), (.18, .172, .168), seg=12, rings=7)
add('hair', 'buzz', buzz)

# ---- hats --------------------------------------------------------------------
cap = Part('cap', 'hat')
cap.sphere((0, .015, 1.0), (.195, .19, .15), seg=12, rings=6)
visor = Part('visor', 'hat', .85).box((0, -.205, 1.02), (.23, .13, .022), rot=(math.radians(-8), 0, 0))
button = Part('button', 'hat', 1.25).sphere((0, .015, 1.145), (.02, .02, .018), seg=6, rings=4)
add('hat', 'cap', cap, visor, button)

sunhat = Part('sunhat', 'hat')
sunhat.cyl((0, 0, 1.045), .37, .37, .02, seg=16)
sunhat.cyl((0, 0, 1.105), .17, .15, .12, seg=12)
band = Part('band', 'hat', .6).cyl((0, 0, 1.065), .175, .175, .035, seg=12)
add('hat', 'sunhat', sunhat, band)

beanie = Part('beanie', 'hat')
beanie.sphere((0, .015, 1.005), (.195, .19, .17), seg=12, rings=6)
rim = Part('rim', 'hat', .85).cyl((0, .01, .985), .195, .195, .075, seg=12)
pom = Part('pompom', 'hat', 1.3).sphere((0, .015, 1.19), (.055, .055, .055), seg=8, rings=5)
add('hat', 'beanie', beanie, rim, pom)

ranger = Part('ranger hat', 'hat')
ranger.cyl((0, 0, 1.03), .27, .27, .022, seg=14)
ranger.cyl((0, 0, 1.095), .15, .13, .11, seg=12)
ranger_band = Part('ranger band', 'hat', .6).cyl((0, 0, 1.045), .155, .155, .03, seg=12)
add('hat', 'ranger', ranger, ranger_band)

# ---- glasses -----------------------------------------------------------------
def frame_box(p, cx, w, h, t=.012):
    z = .965
    y = -.172
    p.box((cx, y, z + h / 2), (w, .012, t))
    p.box((cx, y, z - h / 2), (w, .012, t))
    p.box((cx - w / 2, y, z), (t, .012, h))
    p.box((cx + w / 2, y, z), (t, .012, h))

def frame_ring(p, cx, r, t=.013):
    z, y = .965, -.172
    for i in range(8):
        a = i / 8 * math.tau
        seg = 2 * r * math.sin(math.pi / 8)
        p.box((cx + math.cos(a) * r, y, z + math.sin(a) * r), (seg, .012, t), rot=(0, -(a + math.pi / 2), 0))

round_g = Part('round glasses', 'glasses')
frame_ring(round_g, .065, .05)
frame_ring(round_g, -.065, .05)
round_g.box((0, -.172, .975), (.03, .012, .012))
for sx in (1, -1):
    round_g.box((sx * .165, -.09, .975), (.012, .16, .012))
add('glasses', 'round', round_g)

square_g = Part('square glasses', 'glasses')
frame_box(square_g, .068, .10, .07)
frame_box(square_g, -.068, .10, .07)
square_g.box((0, -.172, .975), (.04, .012, .012))
for sx in (1, -1):
    square_g.box((sx * .17, -.09, .975), (.012, .16, .012))
add('glasses', 'square', square_g)

sun_g = Part('sunglasses', 'glasses')
sun_g.box((.068, -.173, .965), (.10, .014, .06))
sun_g.box((-.068, -.173, .965), (.10, .014, .06))
sun_g.box((0, -.173, .975), (.04, .014, .012))
for sx in (1, -1):
    sun_g.box((sx * .17, -.09, .975), (.012, .16, .012))
add('glasses', 'sunglasses', sun_g)

# ---- backpack ----------------------------------------------------------------
pack = Part('backpack', 'backpack')
pack.box((0, .16, .60), (.26, .13, .30))
flap = Part('flap', 'backpack', 1.18).box((0, .16, .73), (.27, .14, .07))
straps = Part('straps', 'backpack', .75)
for sx in (1, -1):
    straps.box((sx * .10, -.04, .72), (.04, .035, .20), rot=(0, 0, 0))
    straps.box((sx * .10, .065, .79), (.04, .20, .035))
add('backpack', 'rucksack', pack, flap, straps)

# ---- export ------------------------------------------------------------------
data = {
    'version': 1,
    'defaults': {k: srgb_to_linear(v) for k, v in DEFAULT.items()},
    'parts': {key: [p.export() for p in parts] for key, parts in KIT.items()},
}
OUT.parent.mkdir(parents=True, exist_ok=True)
OUT.write_text(json.dumps(data, separators=(',', ':')))
triangles = {k: sum(len(m['faces']) for m in v) for k, v in data['parts'].items()}
print(json.dumps({'path': str(OUT), 'parts': len(triangles), 'triangles': triangles}))


# ---- preview render ----------------------------------------------------------
def render_preview():
    """A contact sheet of a few combinations, rendered the way the app views them."""
    PREVIEW.mkdir(parents=True, exist_ok=True)
    scene = bpy.context.scene
    for o in list(bpy.data.objects):
        bpy.data.objects.remove(o, do_unlink=True)

    def material(rgb_linear):
        m = bpy.data.materials.new('m')
        m.use_nodes = True
        bsdf = m.node_tree.nodes['Principled BSDF']
        bsdf.inputs['Base Color'].default_value = (*rgb_linear, 1)
        bsdf.inputs['Roughness'].default_value = .85
        return m

    looks = [
        ('female', dict(top=('sweater', '#c5453f'), bottom=('skirt', '#2f4a7a'), shoes=('boots', '#553522'), hair=('long', '#3b2414'), hat=None, glasses=('round', '#2d2a28'), backpack=None, skin='#f3cfb0')),
        ('male', dict(top=('hoodie', '#2f7a58'), bottom=('trousers', '#3a3f4f'), shoes=('sneakers', '#d8d4c8'), hair=('short', '#1f1a16'), hat=('cap', '#e0a030'), glasses=None, backpack=('rucksack', '#d9602f'), skin='#c58c5c')),
        ('diverse', dict(top=('jacket', '#e0a030'), bottom=('shorts', '#46618f'), shoes=('rainboots', '#d8b030'), hair=('curly', '#a8431f'), hat=None, glasses=('square', '#8a2f57'), backpack=None, skin='#8a5a3b')),
        ('female', dict(top=('tshirt', '#7a5bd0'), bottom=('shorts', '#2d2a28'), shoes=('sneakers', '#c5453f'), hair=('ponytail', '#d9a441'), hat=('sunhat', '#e8d6a8'), glasses=('sunglasses', '#1b1b1b'), backpack=None, skin='#f0c8a0')),
        ('male', dict(top=('sweater', '#3f7fd0'), bottom=('trousers', '#6a5a3a'), shoes=('boots', '#3a2a1a'), hair=('buzz', '#3b2414'), hat=('beanie', '#c5453f'), glasses=None, backpack=('rucksack', '#3f7fd0'), skin='#e8b98f')),
        ('diverse', dict(top=('hoodie', '#c5453f'), bottom=('skirt', '#3d4860'), shoes=('rainboots', '#2f7a58'), hair=('bun', '#2a2a2a'), hat=('ranger', '#6b7f3a'), glasses=('round', '#d9602f'), backpack=('rucksack', '#e0a030'), skin='#6e4630')),
    ]
    xscale = {'female': .92, 'male': 1.08, 'diverse': 1.0}
    for i, (gender, look) in enumerate(looks):
        picks = [('body.base', {'skin': look['skin']})]
        for cat in ('top', 'bottom', 'shoes', 'hair', 'hat', 'glasses', 'backpack'):
            if look[cat]:
                style, colour = (look[cat], None) if isinstance(look[cat], str) else look[cat]
                picks.append((f'{cat}.{style}', {cat: colour}))
        for key, tints in picks:
            for part in KIT[key]:
                mesh = bpy.data.meshes.new(part.name)
                bm = part.bm.copy()
                bm.to_mesh(mesh)
                bm.free()
                obj = bpy.data.objects.new(part.name, mesh)
                scene.collection.objects.link(obj)
                colour = tints.get(part.tint) or DEFAULT.get(part.tint, '#888888')
                lin = [min(1, c * part.shade) for c in srgb_to_linear(colour)]
                obj.data.materials.append(material(lin))
                head_part = key.split('.')[0] in ('hair', 'hat', 'glasses') or part.name in ('head', 'eyes')
                obj.scale = (1 if head_part else xscale[gender], 1, 1)
                obj.location = (i * .95 - 2.4, 0, 0)
                for poly in mesh.polygons:
                    poly.use_smooth = False
    # Ground and light: a daylight sun from the front left, like the app's noon.
    bpy.ops.mesh.primitive_plane_add(size=12, location=(0, 0, .095))
    bpy.context.object.data.materials.append(material(srgb_to_linear('#b9c79a')))
    sun = bpy.data.lights.new('sun', 'SUN')
    sun.energy = 3.2
    sun_obj = bpy.data.objects.new('sun', sun)
    sun_obj.rotation_euler = (math.radians(50), 0, math.radians(-25))
    scene.collection.objects.link(sun_obj)
    cam = bpy.data.cameras.new('cam')
    cam.type = 'ORTHO'
    cam.ortho_scale = 6.0
    cam_obj = bpy.data.objects.new('cam', cam)
    # The path view: looking along +y, tilted down (oblique projection).
    tilt = 80 if '--front' in sys.argv else 55
    cam_obj.location = (0, -math.sin(math.radians(tilt)) * 8, .62 + math.cos(math.radians(tilt)) * 8)
    cam_obj.rotation_euler = (math.radians(tilt), 0, 0)
    scene.collection.objects.link(cam_obj)
    scene.camera = cam_obj
    scene.world = bpy.data.worlds.new('w')
    scene.world.use_nodes = True
    scene.world.node_tree.nodes['Background'].inputs[0].default_value = (.82, .88, .95, 1)
    scene.world.node_tree.nodes['Background'].inputs[1].default_value = .9
    scene.render.engine = 'CYCLES'
    scene.cycles.device = 'CPU'
    scene.cycles.samples = 24
    scene.cycles.use_denoising = False
    scene.render.resolution_x = 1800
    scene.render.resolution_y = 620
    scene.render.filepath = str(PREVIEW / ('kit-front.png' if '--front' in sys.argv else 'kit.png'))
    bpy.ops.render.render(write_still=True)
    print('preview', scene.render.filepath)


if '--no-render' not in sys.argv:
    render_preview()
