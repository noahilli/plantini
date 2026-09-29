"""Generate repeatable meadow/alpine meshes; optionally materialize in Blender.

Run with Python for bundled JSON, or execute this file in Blender for editable
scenes too. Uses only authored primitives and the existing Plantini ranger/path.
No downloaded textures, external assets or changes to existing Blender scenes.
"""
import copy
import json
import math
import random
from pathlib import Path

ROOT = Path(__file__).resolve().parents[2]
ASSETS = ROOT / 'apps/flutter/assets/worlds'
SOURCE = json.loads((ASSETS / 'forest_module.json').read_text())


def generate(kind):
    rng = random.Random(2909 if kind == 'meadow' else 2910)
    world = {k: copy.deepcopy(SOURCE[k]) for k in ('version', 'length', 'slots')}
    world['meshes'] = [copy.deepcopy(m) for m in SOURCE['meshes']
                       if m['name'] in ('earth', 'grass', 'station', 'station top', 'trail', 'connector')
                       or m['motion'] == 'ranger']
    meshes = world['meshes']
    for m in meshes:
        if m['name'] == 'grass':
            m['color'] = [.48, .64, .23] if kind == 'meadow' else [.35, .48, .36]
        if m['name'] == 'earth' and kind == 'alpine':
            m['color'] = [.38, .40, .42]

    def mesh(name, vertices, faces, color, motion='none'):
        meshes.append(dict(name=name, vertices=vertices, faces=faces,
                           color=color, motion=motion, slot=None))

    def cone(name, x, y, z, radius, height, color, top=0, motion='none', sides=7):
        vertices = [[x + r*math.cos(i*math.tau/sides),
                     y + r*math.sin(i*math.tau/sides), z+h]
                    for r, h in ((radius, 0), (top, height)) for i in range(sides)]
        faces = []
        for i in range(sides):
            j = (i+1) % sides
            faces.extend([[i, j, sides+j], [i, sides+j, sides+i]])
        faces += [[sides, sides+i, sides+i+1] for i in range(1, sides-1)]
        mesh(name, vertices, faces, color, motion)

    def flower(x, y, h, color):
        cone('Flower stem', x, y, .08, .025, h, [.15, .35, .08], .018, 'plant', 5)
        for i in range(5):
            a = i*math.tau/5
            cone('Petal', x+.105*math.cos(a), y+.105*math.sin(a), h+.07,
                 .105, .05, color, .055, 'plant', 5)
        cone('Flower heart', x, y, h+.12, .075, .045, [.98, .61, .08], .05, 'plant')

    if kind == 'meadow':
        # Rounded pond with a sandy margin, entirely within the repeatable tile.
        cone('Sandy stream pond', 1.7, .7, .08, 1.48, .01, [.75, .66, .36], 1.48, sides=16)
        cone('Flowing woodland pond', 1.7, .7, .10, 1.30, .01, [.10, .56, .57], 1.30, sides=16)
        for i in range(8):
            x, y = 1.7+rng.uniform(-.8, .8), .7+rng.uniform(-.8, .8)
            cone('Animated water glint', x, y, .125, .10, .008, [.64, .92, .85], .10, 'water', 5)
        for x, y in [(3.3, 2.2), (3.0, -.7), (.2, 1.7)]:
            for j in range(4):
                cone('Reed', x+j*.08, y, .1, .035, .6+j*.06, [.29, .44, .10], .01, 'plant')
        # Open flowers, tufts and low rolling hummocks leave the trail clear.
        for x, y, r in [(3.6, -3.4, 1.2), (4.3, 3.4, 1.0), (-4.7, 2.6, .8)]:
            cone('Meadow hummock', x, y, .08, r, .5, [.43, .59, .20], r*.35, sides=9)
        colors = [[.95, .88, .61], [.73, .33, .46], [.50, .35, .75], [.98, .68, .13]]
        for i in range(70):
            x, y = rng.uniform(-5.1, 5.1), rng.uniform(-4.6, 4.6)
            if -3.5 < x < -1.0 or (x-1.7)**2+(y-.7)**2 < 2.7:
                continue
            flower(x, y, rng.uniform(.22, .50), colors[i % len(colors)])
        for i in range(35):
            x, y = rng.uniform(-5.2, 5.2), rng.uniform(-4.7, 4.7)
            if -3.4 < x < -1.2 or (x-1.7)**2+(y-.7)**2 < 2.7:
                continue
            cone('Meadow grass', x, y, .08, .13, .42, [.26, .47, .12], motion='plant', sides=4)
    else:
        # Angular peaks on the right keep the playable left-hand route readable.
        for x, y, r, h in [(3.8, -3.0, 1.6, 2.5), (4.2, 1.2, 1.4, 3.0), (2.9, 3.5, 1.3, 2.2)]:
            cone('Mountain granite', x, y, .08, r, h*.70, [.40, .46, .49], r*.30, sides=5)
            cone('Snow cap', x, y, .08+h*.70, r*.30, h*.30, [.91, .96, .98], sides=5)
        # Same boundary position on both ends, so the stream joins every tile.
        for name, width, z, color in [('Sandy stream gravel', .54, .085, [.56, .62, .60]),
                                      ('Flowing woodland alpine', .36, .105, [.13, .54, .67])]:
            vs = []
            for i in range(21):
                y = -5+i*.5
                x = .5+.30*math.sin((y+5)*math.tau/10)
                vs.extend([[x-width, y, z], [x+width, y, z]])
            fs = []
            for i in range(20):
                a = i*2
                fs.extend([[a, a+1, a+3], [a, a+3, a+2]])
            mesh(name, vs, fs, color)
        for i in range(14):
            y = -4.5+i*.67
            x = .5+.30*math.sin((y+5)*math.tau/10)
            cone('Animated water alpine', x, y, .12, .07, .008, [.77, .94, .96], .07, 'water', 5)
        for x, y in [(-4.7, -3.5), (-4.6, 2.5), (1.8, -1.0), (2.0, 2.0)]:
            cone('Pine trunk', x, y, .08, .09, .7, [.32, .22, .15], .07)
            for z, r in [(.45, .62), (.85, .48), (1.2, .32)]:
                cone('Pine crown', x, y, z, r, .85, [.12, .30, .24], motion='tree')
        for i in range(32):
            x, y = rng.uniform(-5.1, 1.8), rng.uniform(-4.5, 4.5)
            if -3.5 < x < -1.0 or abs(x-.5) < .7:
                continue
            if i % 3 == 0:
                cone('Alpine stone', x, y, .08, .25, .24, [.49, .56, .55], .13, sides=5)
            else:
                flower(x, y, .19, [.86, .90, .92] if i % 2 else [.26, .29, .79])
    return world


def materialize(world, kind):
    """Create a separately named scene; never clear or overwrite user scenes."""
    import bpy
    scene = bpy.data.scenes.new('Plantini • ' + kind.title() + ' Module')
    materials = {}
    for item in world['meshes']:
        mesh = bpy.data.meshes.new(item['name'])
        mesh.from_pydata(item['vertices'], [], item['faces'])
        mesh.update()
        obj = bpy.data.objects.new(item['name'], mesh)
        scene.collection.objects.link(obj)
        rgb = tuple(item['color'])
        if rgb not in materials:
            mat = bpy.data.materials.new(kind + ' palette')
            mat.diffuse_color = (*rgb, 1)
            materials[rgb] = mat
        mesh.materials.append(materials[rgb])
        obj['motion'] = item['motion']
    return scene


for kind in ('meadow', 'alpine'):
    world = generate(kind)
    (ASSETS / f'{kind}_module.json').write_text(json.dumps(world, separators=(',', ':')))
    try:
        import bpy
    except ImportError:
        pass
    else:
        materialize(world, kind)
    print(kind, len(world['meshes']), 'meshes', sum(len(m['faces']) for m in world['meshes']), 'triangles')
