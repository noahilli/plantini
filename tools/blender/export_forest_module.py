"""Export the authored Blender world into a compact platform-neutral mesh module.
No changes to the source scene. Consumed by Flutter's small orthographic renderer.
"""
import bpy, json, math
from pathlib import Path

scene = bpy.data.scenes.get('Plantini • Waldlichtung')
if scene is None:
    raise RuntimeError('Open plantini-forest.blend before exporting')
previous = scene.frame_current
scene.frame_set(1)
result = {'version': 1, 'length': 10, 'slots': [[-2.4 + .55*math.sin(i*math.tau/5), -4+i*1.6, .34] for i in range(6)], 'meshes': []}

def append(name, vertices, faces, color, motion='none', pivot=None, slot=None):
    result['meshes'].append({'name':name, 'vertices':vertices, 'faces':faces, 'color':color, 'motion':motion, 'pivot':pivot, 'slot':slot})

def box(name,x,y,z,w,l,h,color,slot=None):
    vs=[[x+dx*w/2,y+dy*l/2,z+dz*h/2] for dx,dy,dz in [(-1,-1,-1),(1,-1,-1),(1,1,-1),(-1,1,-1),(-1,-1,1),(1,-1,1),(1,1,1),(-1,1,1)]]
    fs=[[0,2,1],[0,3,2],[4,5,6],[4,6,7],[0,1,5],[0,5,4],[1,2,6],[1,6,5],[2,3,7],[2,7,6],[3,0,4],[3,4,7]]
    append(name,vs,fs,color,slot=slot)

box('earth',0,0,-.45,11.5,10,.9,[.48,.29,.17])
box('grass',0,0,.02,11.5,10,.12,[.38,.53,.23])
skip=('Rounded earth','Moss island','Backdrop','Trail stepping','Level pedestal','Level inset')
for obj in scene.objects:
    if obj.type != 'MESH' or obj.name.startswith(skip): continue
    mesh=obj.data
    mesh.calc_loop_triangles()
    vs=[]
    for v in mesh.vertices:
        p=obj.matrix_world @ v.co
        if obj.name.startswith('Ranger'):
            p.x += 2.95
            p.y += 3.1
        if obj.name.startswith(('Sandy stream','Flowing woodland')):
            p.x -= .65*math.sin(p.y*.64)*(abs(p.y)/4.7)**8
            p.y *= 5/4.7
        vs.append([round(float(a),4) for a in p])
    fs=[list(t.vertices) for t in mesh.loop_triangles]
    color=list(mesh.materials[0].diffuse_color[:3]) if mesh.materials else [.5,.5,.5]
    parent=obj.parent
    motion='tree' if parent and 'sway' in parent.name else 'water' if obj.name.startswith('Animated water') else 'none'
    if obj.name.startswith('Ranger'): motion='ranger'
    append(obj.name,vs,fs,color,motion,list(parent.location) if motion=='tree' else None)
for i,(x,y,z) in enumerate(result['slots']):
    box('station',x,y,.17,.65,.65,.20,[.70,.72,.60],i)
    box('station top',x,y,.28,.49,.49,.04,[.96,.75,.30],i)
    if i<5:
        nx,ny,_=result['slots'][i+1]
        for j in range(1,4):
            t=j/4
            box('trail',x*(1-t)+nx*t,y*(1-t)+ny*t,.115,.24,.30,.04,[.78,.67,.43],i)
# Path and water connectors land on the same coordinates at +/-5.
for y in [-4.8,-4.4,4.4,4.8]:
    box('connector',-2.4,y,.115,.24,.30,.04,[.78,.67,.43])
scene.frame_set(previous)
out=Path(__file__).resolve().parents[2] / 'apps/flutter/assets/worlds/forest_module.json'
out.write_text(json.dumps(result,separators=(',',':')))
print(json.dumps({'path':str(out),'meshes':len(result['meshes']),'triangles':sum(len(m['faces']) for m in result['meshes'])}))
