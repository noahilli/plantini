"""Build the nine Plantini explorer characters in Blender and export them.

Three women, three men, three non-binary characters, all in field-researcher
clothes (vests, binoculars, notebooks, safari hats ...) and deliberately
different in skin tone, age, hair, head covering, build and mobility. Each is a
fixed model; the app lets the player pick one (no character designer).

Run headless:   blender -b -P tools/blender/create_explorer_characters.py
Output:         apps/flutter/assets/characters/explorers.json
Contact sheet:  artifacts/3d/explorers/explorers.png  (Cycles, CPU)

Conventions (same as the world modules): z is up, a standing character stands
on z = 0.10 and looks towards -y (the camera of the level path). Colours are
exported as linear RGB like Blender's diffuse colour; the app applies lighting
and the display gamma.
"""
import json
import math
import sys
from pathlib import Path

import bmesh
import bpy
from mathutils import Euler, Matrix, Vector

ROOT = Path(__file__).resolve().parents[2]
OUT = ROOT / 'apps/flutter/assets/characters/explorers.json'
PREVIEW = ROOT / 'artifacts/3d/explorers'
EYE = '#231f1d'
BOOT_SOLE = '#2d2a28'


def linear(hex_colour, shade=1.0):
    h = hex_colour.lstrip('#')
    return [round(min(1.0, (int(h[i:i + 2], 16) / 255) ** 2.2 * shade), 4) for i in (0, 2, 4)]


class Part:
    """A bag of primitives in one colour, merged into one mesh."""

    def __init__(self, name, colour, shade=1.0, head=False, upper=True):
        self.name, self.colour, self.shade = name, colour, shade
        self.head = head          # keeps its width when the body is widened
        self.upper = upper        # moves down with a seated character
        self.bm = bmesh.new()

    def _place(self, verts, scale, loc, rot):
        m = Matrix.LocRotScale(Vector(loc), Euler(rot, 'XYZ'), Vector(scale))
        bmesh.ops.transform(self.bm, matrix=m, verts=verts)

    def box(self, loc, size, rot=(0, 0, 0)):
        self._place(bmesh.ops.create_cube(self.bm, size=1.0)['verts'], size, loc, rot)
        return self

    def sphere(self, loc, radii, rot=(0, 0, 0), seg=10, rings=6):
        r = bmesh.ops.create_uvsphere(self.bm, u_segments=seg, v_segments=rings, radius=1.0)
        self._place(r['verts'], radii, loc, rot)
        return self

    def cyl(self, loc, r_bottom, r_top, height, rot=(0, 0, 0), seg=10, squash=1.0):
        r = bmesh.ops.create_cone(self.bm, cap_ends=True, cap_tris=False, segments=seg,
                                  radius1=r_bottom, radius2=r_top, depth=height)
        self._place(r['verts'], (1, squash, 1), loc, rot)
        return self

    def export(self, width, dz):
        bmesh.ops.triangulate(self.bm, faces=self.bm.faces[:])
        self.bm.verts.ensure_lookup_table()
        w = 1.0 if self.head else width
        down = dz if self.upper else 0.0
        return {
            'name': self.name,
            'color': linear(self.colour, self.shade),
            'vertices': [[round(v.co.x * w, 3), round(v.co.y, 3), round(v.co.z + down, 3)] for v in self.bm.verts],
            'faces': [[v.index for v in f.verts] for f in self.bm.faces],
        }


# ---- building blocks ---------------------------------------------------------
def head(skin):
    p = Part('head', skin, head=True)
    p.sphere((0, 0, .95), (.175, .165, .175), seg=12, rings=8)
    p.cyl((0, 0, .80), .055, .055, .08)
    # Light eye whites with a dark pupil, so faces read on every skin tone.
    white = Part('eye whites', '#f1ede0', head=True)
    pupils = Part('pupils', EYE, head=True)
    for sx in (1, -1):
        white.box((sx * .065, -.156, .955), (.055, .02, .06))
        pupils.box((sx * .065, -.168, .952), (.03, .012, .04))
    return [p, white, pupils]


def hands(skin):
    p = Part('hands', skin)
    for sx in (1, -1):
        p.sphere((sx * .255, 0, .455), (.05, .05, .05), seg=8, rings=5)
    return [p]


def shirt(colour, sleeves='long'):
    p = Part('shirt', colour)
    p.box((0, 0, .63), (.34, .21, .34))
    for sx in (1, -1):
        if sleeves == 'long':
            p.box((sx * .23, 0, .62), (.10, .14, .31))
        else:
            p.box((sx * .215, 0, .715), (.10, .14, .13))
    return [p]


def forearms(skin):
    p = Part('forearms', skin)
    for sx in (1, -1):
        p.box((sx * .245, 0, .585), (.065, .075, .17))
    return [p]


def collar(colour):
    return [Part('collar', colour, 1.15).cyl((0, 0, .805), .10, .09, .05)]


def vest(colour):
    p = Part('vest', colour)
    p.box((0, -.012, .64), (.375, .235, .29))
    pk = Part('pockets', colour, .78)
    for sx in (1, -1):
        # Stand clear of the vest front (y = -.1295): coplanar faces flicker
        # in the app's painter-sorted renderer.
        pk.box((sx * .09, -.15, .56), (.12, .03, .09))
        pk.box((sx * .09, -.15, .68), (.12, .03, .08))
    return [p, pk]


def long_coat(colour):
    p = Part('coat', colour)
    p.box((0, 0, .63), (.35, .215, .34))
    for sx in (1, -1):
        p.box((sx * .23, 0, .62), (.10, .14, .31))
    p.cyl((0, 0, .33), .25, .20, .30, seg=12, squash=.9)
    return [p, Part('coat hem', colour, .8).cyl((0, 0, .21), .255, .25, .03, seg=12, squash=.9)]


def poncho(colour):
    p = Part('poncho', colour)
    p.box((0, 0, .66), (.44, .27, .26))
    p.box((0, 0, .50), (.50, .30, .08))
    p.cyl((0, 0, .79), .12, .105, .06)
    return [p]


def raincoat(colour):
    p = Part('raincoat', colour)
    p.box((0, 0, .63), (.37, .23, .34))
    for sx in (1, -1):
        p.box((sx * .235, 0, .62), (.105, .15, .31))
    hood = Part('hood', colour, .9).sphere((0, .095, .84), (.16, .105, .10), seg=10, rings=5)
    return [p, hood]


def trousers(colour, cargo=False):
    p = Part('trousers', colour, upper=False)
    p.box((0, 0, .46), (.345, .215, .12))
    p.cyl((.085, 0, .30), .07, .07, .36)
    p.cyl((-.085, 0, .30), .07, .07, .36)
    out = [p]
    if cargo:
        pk = Part('cargo pockets', colour, .8, upper=False)
        for sx in (1, -1):
            pk.box((sx * .152, -.02, .36), (.04, .10, .10))
        out.append(pk)
    return out


def shorts(colour, skin):
    p = Part('shorts', colour, upper=False)
    p.box((0, 0, .46), (.345, .215, .12))
    p.cyl((.085, 0, .41), .08, .08, .14)
    p.cyl((-.085, 0, .41), .08, .08, .14)
    legs = Part('legs', skin, upper=False)
    legs.cyl((.085, 0, .225), .058, .056, .25)
    legs.cyl((-.085, 0, .225), .058, .056, .25)
    return [p, legs]


def boots(colour, tall=.12):
    p = Part('boots', colour, upper=False)
    s = Part('soles', BOOT_SOLE, upper=False)
    for sx in (1, -1):
        p.box((sx * .09, -.035, .15), (.11, .22, .09))
        s.box((sx * .09, -.035, .112), (.118, .23, .035))
        p.cyl((sx * .085, 0, .19 + tall / 2), .092, .094, tall, seg=8)
    return [p, s]


def hair_cap(colour, grow=1.0):
    return Part('hair', colour, head=True).sphere((0, .035, .985), (.185 * grow, .18 * grow, .165 * grow), seg=12, rings=7)


def fringe(colour):
    return Part('fringe', colour, head=True).box((0, -.14, 1.04), (.27, .05, .05))


def short_hair(colour):
    return [hair_cap(colour), fringe(colour)]


def afro_puffs(colour, band):
    p = hair_cap(colour)
    for sx in (1, -1):
        p.sphere((sx * .14, .03, 1.12), (.105, .105, .10), seg=10, rings=6)
    p.sphere((0, .09, 1.0), (.17, .08, .13), seg=8, rings=5)
    b = Part('headband', band, head=True).cyl((0, .005, 1.03), .186, .186, .04, seg=12)
    return [p, b]


def bob(colour):
    p = hair_cap(colour)
    p.box((0, .115, .90), (.36, .09, .30))
    for sx in (1, -1):
        p.box((sx * .178, .0, .89), (.055, .26, .27))
    return [p, fringe(colour)]


def locs(colour, bead):
    p = hair_cap(colour)
    b = Part('beads', bead, head=True)
    xs = (-.15, -.10, -.05, 0, .05, .10, .15)
    for i, x in enumerate(xs):
        y = .12 + .02 * math.cos(i)
        p.cyl((x, y, .74), .02, .022, .42, seg=6)
        b.sphere((x, y, .55 + .03 * (i % 3)), (.028, .028, .028), seg=6, rings=4)
    for sx in (1, -1):
        p.cyl((sx * .17, .05, .80), .02, .022, .30, seg=6)
    return [p, fringe(colour), b]


def hijab(colour):
    p = Part('hijab', colour, head=True)
    p.sphere((0, .05, .975), (.20, .20, .20), seg=12, rings=7)
    p.cyl((0, .035, .70), .26, .17, .24, seg=12, squash=.9)
    p.box((0, -.15, 1.035), (.31, .05, .06))
    for sx in (1, -1):
        p.box((sx * .165, -.05, .90), (.06, .20, .24))
    return [p]


def turban(colour, shade2=1.18):
    p = Part('turban', colour, head=True)
    p.sphere((0, .0, 1.05), (.205, .205, .105), seg=12, rings=6)
    p.sphere((0, -.015, 1.13), (.175, .175, .085), seg=12, rings=6)
    w = Part('turban folds', colour, shade2, head=True)
    w.box((0, -.185, 1.03), (.36, .06, .035), rot=(0, 0, math.radians(8)))
    w.box((0, -.17, 1.10), (.30, .06, .035), rot=(0, 0, math.radians(-10)))
    w.sphere((0, -.02, 1.205), (.085, .085, .06), seg=8, rings=4)
    return [p, w]


def beard(colour, full=True):
    p = Part('beard', colour, head=True)
    p.sphere((0, -.088, .875), (.11, .07, .085), seg=10, rings=6)
    if full:
        for sx in (1, -1):
            p.sphere((sx * .105, -.06, .905), (.05, .075, .075), seg=8, rings=5)
    return [p]


def curly_hair(colour):
    p = Part('curls', colour, head=True)
    for i in range(10):
        a = i / 10 * math.tau
        p.sphere((math.cos(a) * .12, .03 + math.sin(a) * .11, 1.04 + .03 * math.sin(a * 3)), (.085, .085, .08), seg=8, rings=5)
    p.sphere((0, .03, 1.11), (.10, .10, .075), seg=8, rings=5)
    p.sphere((0, .09, .95), (.17, .07, .13), seg=8, rings=5)
    return [p]


def ponytail(colour):
    p = hair_cap(colour)
    p.cyl((0, .19, .92), .045, .03, .26, rot=(math.radians(18), 0, 0), seg=8)
    p.sphere((0, .17, 1.04), (.05, .05, .05), seg=8, rings=5)
    return [p, fringe(colour)]


def undercut(colour):
    p = Part('undercut', colour, head=True)
    p.sphere((0, .02, .985), (.18, .172, .168), seg=12, rings=7)
    p.box((.03, -.13, 1.075), (.22, .07, .07), rot=(0, 0, math.radians(-12)))
    return [p]


def safari_hat(colour, band):
    p = Part('safari hat', colour, head=True)
    p.cyl((0, 0, 1.045), .33, .33, .02, seg=16)
    p.cyl((0, 0, 1.105), .17, .15, .12, seg=12)
    return [p, Part('hat band', band, head=True).cyl((0, 0, 1.065), .175, .175, .035, seg=12)]


def bucket_hat(colour):
    p = Part('bucket hat', colour, head=True)
    p.cyl((0, 0, 1.035), .27, .27, .03, seg=14)            # brim
    p.cyl((0, 0, 1.10), .185, .175, .12, seg=14)           # crown
    return [p]


def ranger_hat(colour, band):
    p = Part('ranger hat', colour, head=True)
    p.cyl((0, 0, 1.03), .27, .27, .022, seg=14)
    p.cyl((0, 0, 1.095), .15, .13, .11, seg=12)
    return [p, Part('ranger band', band, head=True).cyl((0, 0, 1.045), .155, .155, .03, seg=12)]


def cap(colour):
    p = Part('cap', colour, head=True)
    p.sphere((0, .015, 1.0), (.195, .19, .15), seg=12, rings=6)
    v = Part('visor', colour, .85, head=True).box((0, -.205, 1.02), (.23, .13, .022), rot=(math.radians(-8), 0, 0))
    return [p, v]


def bandana(colour):
    p = Part('bandana', colour, head=True)
    p.cyl((0, 0, .805), .105, .10, .05)
    p.box((.075, -.085, .80), (.05, .04, .05), rot=(0, 0, math.radians(45)))
    return [p]


def glasses_round(colour):
    p = Part('glasses', colour, head=True)
    for cx in (.065, -.065):
        for i in range(8):
            a = i / 8 * math.tau
            seg = 2 * .05 * math.sin(math.pi / 8)
            p.box((cx + math.cos(a) * .05, -.172, .965 + math.sin(a) * .05), (seg, .012, .013), rot=(0, -(a + math.pi / 2), 0))
    p.box((0, -.172, .975), (.03, .012, .012))
    for sx in (1, -1):
        p.box((sx * .165, -.09, .975), (.012, .16, .012))
    return [p]


def glasses_square(colour):
    p = Part('glasses', colour, head=True)
    for cx in (.068, -.068):
        p.box((cx, -.172, .965 + .035), (.10, .012, .012))
        p.box((cx, -.172, .965 - .035), (.10, .012, .012))
        p.box((cx - .05, -.172, .965), (.012, .012, .07))
        p.box((cx + .05, -.172, .965), (.012, .012, .07))
    p.box((0, -.172, .975), (.04, .012, .012))
    for sx in (1, -1):
        p.box((sx * .17, -.09, .975), (.012, .16, .012))
    return [p]


def binoculars(colour='#2d2a28'):
    p = Part('binoculars', colour)
    for sx in (1, -1):
        p.cyl((sx * .045, -.15, .66), .035, .04, .11, rot=(math.pi / 2, 0, 0), seg=8)
    p.box((0, -.15, .66), (.05, .05, .04))
    lens = Part('lenses', '#8fb0c0')
    for sx in (1, -1):
        lens.cyl((sx * .045, -.208, .66), .026, .026, .008, rot=(math.pi / 2, 0, 0), seg=8)
    parts_lens = lens
    strap = Part('strap', '#6a4428')
    for sx in (1, -1):
        strap.box((sx * .075, -.14, .72), (.016, .02, .22), rot=(0, 0, sx * .25))
    return [p, strap, parts_lens]


def notebook(colour='#e0a030'):
    p = Part('notebook', colour)
    p.box((.30, -.07, .47), (.10, .02, .14), rot=(0, math.radians(18), 0))
    return [p, Part('notebook pages', '#f1ede0').box((.30, -.062, .47), (.085, .012, .125), rot=(0, math.radians(18), 0))]


def camera(colour='#2d2a28'):
    p = Part('camera', colour)
    p.box((.0, -.145, .62), (.13, .07, .09))
    p.cyl((0, -.19, .62), .035, .04, .05, rot=(math.pi / 2, 0, 0), seg=8)
    return [p, Part('camera strap', '#6a4428').box((0, -.14, .74), (.016, .02, .18))]


def rucksack(colour):
    p = Part('backpack', colour)
    p.box((0, .16, .60), (.26, .13, .30))
    flap = Part('flap', colour, 1.18).box((0, .16, .73), (.27, .14, .07))
    straps = Part('straps', colour, .75)
    for sx in (1, -1):
        straps.box((sx * .10, -.04, .72), (.04, .035, .20))
        straps.box((sx * .10, .065, .79), (.04, .20, .035))
    return [p, flap, straps]


def wheelchair(frame='#2d2a28', seat='#3f4a60'):
    f = Part('wheelchair frame', frame, upper=False)
    f.box((0, .02, .30), (.31, .30, .03))
    f.box((0, .165, .47), (.31, .03, .30))
    for sx in (1, -1):
        f.box((sx * .165, .0, .40), (.03, .26, .03))        # armrests
        f.box((sx * .165, .0, .35), (.03, .03, .10))
        f.cyl((sx * .11, -.30, .15), .045, .045, .05, rot=(0, math.pi / 2, 0), seg=8)   # front casters
        f.box((sx * .11, -.28, .22), (.03, .03, .16))
    f.box((0, -.34, .135), (.26, .12, .02))                  # footplate
    cushion = Part('seat cushion', seat, upper=False).box((0, .0, .335), (.29, .28, .04))
    wheels = Part('wheels', '#1b1b1b', upper=False)
    hubs = Part('wheel rims', '#b8b8b2', upper=False)
    for sx in (1, -1):
        wheels.cyl((sx * .225, .07, .36), .26, .26, .03, rot=(0, math.pi / 2, 0), seg=16)
        hubs.cyl((sx * .24, .07, .36), .21, .21, .012, rot=(0, math.pi / 2, 0), seg=16)
        wheels.cyl((sx * .245, .07, .36), .045, .045, .03, rot=(0, math.pi / 2, 0), seg=8)
    return [f, cushion, wheels, hubs]


def seated_legs(trouser, shoe):
    p = Part('seated legs', trouser, upper=False)
    s = Part('seated shoes', shoe, upper=False)
    for sx in (1, -1):
        p.box((sx * .085, -.12, .375), (.115, .27, .115))
        p.box((sx * .085, -.255, .25), (.105, .105, .24))
        s.box((sx * .085, -.29, .165), (.11, .20, .08))
    hip = Part('seated hips', trouser, upper=False).box((0, 0, .39), (.345, .215, .12))
    return [hip, p, s]


# ---- the nine explorers ------------------------------------------------------
def build_all():
    cast = []

    def add(cid, name, group, blurb, width, parts, dz=0.0):
        flat = [p for group_parts in parts for p in group_parts]
        cast.append({'id': cid, 'name': name, 'group': group, 'blurb': blurb, 'width': width, 'dz': dz, 'parts': flat})

    # Women
    skin = '#6e4630'
    add('amara', 'Amara', 'female', 'Vogelkundlerin mit Fernglas', .94, [
        head(skin), hands(skin), afro_puffs('#1b1410', '#e0a030'),
        shirt('#2f7a58'), vest('#c9b27a'), binoculars(), trousers('#7a6a48', cargo=True), boots('#553522'),
    ])
    skin = '#f0c8a0'
    add('mei', 'Mei', 'female', 'Botanikerin mit Notizbuch', .92, [
        head(skin), hands(skin), bob('#17130f'), bucket_hat('#6b7f3a'), glasses_round('#2d2a28'),
        shirt('#e8e4d8'), vest('#d9602f'), collar('#e8e4d8'), notebook(), trousers('#3d4860'), boots('#553522'),
    ])
    skin = '#c58c5c'
    add('samira', 'Samira', 'female', 'Geologin mit Rucksack', .95, [
        head(skin), hands(skin), hijab('#2f7a7a'),
        long_coat('#b8a46a'), rucksack('#d9602f'), binoculars('#3a2a1a'), trousers('#3d4860'), boots('#553522'),
    ])
    # Men
    skin = '#e8b98f'
    add('heinrich', 'Heinrich', 'male', 'Förster im Ruhestand', 1.08, [
        head(skin), hands(skin), short_hair('#9a9a98'), beard('#d8d8d4'), ranger_hat('#6b7f3a', '#3a2a1a'),
        glasses_square('#2d2a28'), shirt('#e8e4d8'), vest('#4f6b3a'), rucksack('#6a4428'), trousers('#6a5a3a'), boots('#3a2a1a'),
    ])
    skin = '#c58c5c'
    add('mateo', 'Mateo', 'male', 'Insektenforscher mit Kamera', 1.06, [
        head(skin), hands(skin), curly_hair('#1f1a16'), cap('#2f7a58'),
        shirt('#3f7fd0', sleeves='short'), forearms(skin), vest('#c5453f'), camera(), shorts('#7a6a48', skin), boots('#553522', tall=.1),
    ])
    skin = '#9c6b45'
    add('arjun', 'Arjun', 'male', 'Ökologe im Gelände', 1.10, [
        head(skin), hands(skin), turban('#2f4a7a'), beard('#1f1a16'),
        shirt('#e8e4d8'), vest('#8a5a30'), rucksack('#3f7fd0'), trousers('#3d4860'), boots('#3a2a1a'),
    ])
    # Non-binary
    skin = '#f6d9c0'
    add('robin', 'Robin', 'diverse', 'Pilzsucher*in im Regenmantel', 1.0, [
        head(skin), hands(skin), undercut('#3fb0a8'), glasses_round('#d9602f'),
        raincoat('#e0a030'), binoculars(), shorts('#2f4a7a', skin), boots('#2f7a58', tall=.15),
    ])
    skin = '#5b3a26'
    add('nia', 'Nia', 'diverse', 'Feldforscher*in mit Rollstuhl', 1.0, [
        head(skin), hands(skin), locs('#1b1410', '#e0a030'), safari_hat('#c9b27a', '#6a4428'),
        shirt('#7a5bd0', sleeves='short'), forearms(skin), vest('#4f6b3a'), notebook('#d9602f'),
        wheelchair(), seated_legs('#3d4860', '#553522'),
    ], dz=-.075)
    skin = '#e8b98f'
    add('kai', 'Kai', 'diverse', 'Wanderer*in mit Bandana', 1.0, [
        head(skin), hands(skin), ponytail('#3b2414'), bandana('#c5453f'),
        shirt('#e8e4d8'), poncho('#4f6b3a'), rucksack('#e0a030'), trousers('#6a5a3a', cargo=True), boots('#3a2a1a'),
    ])
    return cast


cast = build_all()
OUT.parent.mkdir(parents=True, exist_ok=True)
data = {
    'version': 2,
    'characters': [{
        'id': c['id'], 'name': c['name'], 'group': c['group'], 'blurb': c['blurb'],
        'meshes': [p.export(c['width'], c['dz']) for p in c['parts']],
    } for c in cast],
}
OUT.write_text(json.dumps(data, separators=(',', ':')))
print(json.dumps({'path': str(OUT), 'bytes': OUT.stat().st_size,
                  'triangles': {c['id']: sum(len(m['faces']) for m in d['meshes']) for c, d in zip(cast, data['characters'])}}))


# ---- contact sheet -------------------------------------------------------------
def render_preview():
    PREVIEW.mkdir(parents=True, exist_ok=True)
    scene = bpy.context.scene
    for o in list(bpy.data.objects):
        bpy.data.objects.remove(o, do_unlink=True)

    def material(rgb):
        m = bpy.data.materials.new('m')
        m.use_nodes = True
        b = m.node_tree.nodes['Principled BSDF']
        b.inputs['Base Color'].default_value = (*rgb, 1)
        b.inputs['Roughness'].default_value = .85
        return m

    for i, c in enumerate(data['characters']):
        for part in c['meshes']:
            mesh = bpy.data.meshes.new(part['name'])
            mesh.from_pydata(part['vertices'], [], part['faces'])
            mesh.update()
            obj = bpy.data.objects.new(part['name'], mesh)
            scene.collection.objects.link(obj)
            obj.data.materials.append(material(part['color']))
            obj.location = ((i % 9) * .95 - 3.8, 0, 0)
    bpy.ops.mesh.primitive_plane_add(size=14, location=(0, 0, .095))
    bpy.context.object.data.materials.append(material(linear('#b9c79a')))
    sun = bpy.data.lights.new('sun', 'SUN')
    sun.energy = 3.2
    so = bpy.data.objects.new('sun', sun)
    so.rotation_euler = (math.radians(50), 0, math.radians(-25))
    scene.collection.objects.link(so)
    cam = bpy.data.cameras.new('cam')
    cam.type = 'ORTHO'
    cam.ortho_scale = 8.6
    co = bpy.data.objects.new('cam', cam)
    tilt = 80 if '--front' in sys.argv else 55
    co.location = (0, -math.sin(math.radians(tilt)) * 8, .62 + math.cos(math.radians(tilt)) * 8)
    co.rotation_euler = (math.radians(tilt), 0, 0)
    scene.collection.objects.link(co)
    scene.camera = co
    scene.world = bpy.data.worlds.new('w')
    scene.world.use_nodes = True
    scene.world.node_tree.nodes['Background'].inputs[0].default_value = (.82, .88, .95, 1)
    scene.render.engine = 'CYCLES'
    scene.cycles.device = 'CPU'
    scene.cycles.samples = 24
    scene.cycles.use_denoising = False
    scene.render.resolution_x = 2400
    scene.render.resolution_y = 560
    scene.render.filepath = str(PREVIEW / ('explorers-front.png' if '--front' in sys.argv else 'explorers.png'))
    bpy.ops.render.render(write_still=True)


if '--no-render' not in sys.argv:
    render_preview()
