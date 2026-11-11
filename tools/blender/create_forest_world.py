"""Run inside Blender via its local MCP execute_code endpoint.

Creates an independent scene: never clears the user's current scene.
Procedural original assets, no third-party textures or paid asset services.
"""
import bpy
import math
import random
from pathlib import Path
from mathutils import Vector

random.seed(23)
ROOT = Path(__file__).resolve().parents[2] / 'artifacts/3d/forest-20260929-v1'
ROOT.mkdir(parents=True, exist_ok=True)
if (ROOT / 'plantini-forest.blend').exists():
    raise RuntimeError('Output already exists. Choose a new version directory.')
scene = bpy.data.scenes.new('Plantini • Waldlichtung')
bpy.context.window.scene = scene
scene.render.engine = 'CYCLES'
scene.cycles.samples = 32
scene.cycles.use_denoising = True
scene.render.resolution_x = 1600
scene.render.resolution_y = 1200
scene.render.resolution_percentage = 100
scene.render.image_settings.file_format = 'PNG'
scene.render.fps = 24
scene.frame_start = 1
scene.frame_end = 120
scene.world = bpy.data.worlds.new('Plantini warm sky')
scene.world.use_nodes = True
scene.world.node_tree.nodes['Background'].inputs[0].default_value = (0.68, 0.78, 0.78, 1)
scene.world.node_tree.nodes['Background'].inputs[1].default_value = .65

def material(name, color, roughness=.8):
    m = bpy.data.materials.new(name)
    m.diffuse_color = (*color, 1)
    m.use_nodes = True
    p = m.node_tree.nodes.get('Principled BSDF')
    p.inputs['Base Color'].default_value = (*color, 1)
    p.inputs['Roughness'].default_value = roughness
    return m

grass = material('Moss • pistachio', (.38, .53, .23))
soil = material('Island • warm clay', (.48, .29, .17))
bank = material('Bank • sand', (.78, .67, .43))
bark = material('Trunks • cinnamon', (.34, .19, .10))
leaves = [material('Canopy '+str(i), c) for i,c in enumerate([
    (.18,.36,.22), (.29,.47,.25), (.44,.58,.27), (.62,.67,.31)])]
stone = material('Pebbles • oat', (.68,.70,.58))
water = material('Stream • turquoise', (.10,.49,.53), .22)
foam = material('Ripples • mint', (.71,.92,.83), .35)
wood = material('Bridge • honey', (.59,.34,.16))
flower = material('Flower • butter', (.98,.72,.20))
petal = material('Flower • cream', (.99,.94,.76))
red = material('Mushroom • apricot', (.87,.37,.22))
floor = material('Studio • mist', (.76,.84,.77))

def assign(obj, name, mat):
    obj.name = name
    obj.data.materials.append(mat)
    return obj

def ico(name, loc, scale, mat, subdivisions=1):
    bpy.ops.mesh.primitive_ico_sphere_add(subdivisions=subdivisions, radius=1, location=loc)
    obj = assign(bpy.context.object, name, mat)
    obj.scale = scale
    return obj

def cube(name, loc, scale, mat, bevel=0):
    bpy.ops.mesh.primitive_cube_add(size=1, location=loc)
    obj = assign(bpy.context.object, name, mat)
    obj.scale = scale
    bpy.ops.object.transform_apply(location=False, rotation=False, scale=True)
    if bevel:
        mod = obj.modifiers.new('Soft toy edges', 'BEVEL')
        mod.width = bevel
        mod.segments = 2
        obj.modifiers.new('Weighted normals', 'WEIGHTED_NORMAL')
    return obj

def cylinder(name, loc, radius, depth, mat, vertices=8):
    bpy.ops.mesh.primitive_cylinder_add(vertices=vertices, radius=radius, depth=depth, location=loc)
    return assign(bpy.context.object, name, mat)

def key_loop(obj, prop, values):
    for frame,value in values:
        setattr(obj, prop, value)
        obj.keyframe_insert(data_path=prop, frame=frame)

def stream_x(y):
    return .25 + .65 * math.sin(y*.64)

# A small collectible-style island, not an infinite high-detail terrain.
base = cylinder('Rounded earth island', (0,0,-.52), 6.0, 1.0, soil, 12)
base.scale.y = .84
top = cylinder('Moss island top', (0,0,.025), 5.95, .12, grass, 12)
top.scale.y = .84

def ribbon(name, width, z, mat):
    vertices=[]
    for i in range(49):
        y=-4.7+i*9.4/48
        x=stream_x(y)
        vertices.extend([(x-width,y,z),(x+width,y,z)])
    faces=[(2*i,2*i+1,2*i+3,2*i+2) for i in range(48)]
    mesh=bpy.data.meshes.new(name)
    mesh.from_pydata(vertices,[],faces)
    obj=bpy.data.objects.new(name,mesh)
    scene.collection.objects.link(obj)
    assign(obj,name,mat)
    return obj

ribbon('Sandy stream banks', .77, .096, bank)
ribbon('Flowing woodland stream', .60, .108, water)
# Repeating visible water glints move downstream and loop every five seconds.
for i in range(19):
    y=-4.2+i*.45
    x=stream_x(y)+random.uniform(-.30,.30)
    ripple=ico('Animated water glint %02d'%i,(x,y,.135),(.12,.035,.012),foam)
    key_loop(ripple,'location',[(1,(x,y,.135)),(60,(x+.12,y-.25,.14)),(120,(x,y,.135))])

# Reused faceted canopy meshes. Each tree sways about its rooted pivot.
canopy_meshes=[]
for i in range(3):
    template=ico('Canopy prototype '+str(i),(0,0,-20),(1,1,1),leaves[i],2)
    canopy_meshes.append(template.data)
    bpy.data.objects.remove(template,do_unlink=True)

for i,(x,y,s) in enumerate([(-3.8,2.1,1.1),(-2.3,3.1,1.2),(-.3,3.8,.9),(2,3.4,1.15),(3.6,2.3,1.05),(4,0,.85),(-4.3,-.2,.9),(-3,-1.1,.78),(2.9,-2.6,.7)]):
    pivot=bpy.data.objects.new('Tree %02d • sway'%i,None)
    scene.collection.objects.link(pivot)
    pivot.location=(x,y,.08)
    trunk=cylinder('Tree trunk',(0,0,.92*s),.15*s,1.84*s,bark)
    trunk.parent=pivot
    for j,(dx,dy,dz,sz) in enumerate([(-.35,0,1.65,.75),(.38,.06,1.8,.7),(0,0,2.25,.84)]):
        obj=bpy.data.objects.new('Reusable canopy',canopy_meshes[(i+j)%3])
        scene.collection.objects.link(obj)
        obj.parent=pivot
        obj.location=(dx*s,dy*s,dz*s)
        obj.scale=(sz*s,sz*s,sz*s*.96)
    angle=.022 if i%2 else -.022
    key_loop(pivot,'rotation_euler',[(1,(angle,0,0)),(60,(-angle,.015,0)),(120,(angle,0,0))])

# Bridge crosses the stream; simple repeating planks make the world readable.
for i in range(10):
    cube('Bridge plank %02d'%i,(-.78+i*.20,-.5,.26),(.18,.85,.12),wood,.025)
for y in [-.94,-.06]:
    for x in [-.84,1.04]:
        cylinder('Bridge post',(x,y,.57),.065,.65,bark)
    cube('Bridge handrail',(.1,y,.83),(2.1,.08,.08),wood,.02)

# A visible winding trail with six concept stations, not fabricated user progress.
for i in range(18):
    t=i/17
    x=-2.1+1.0*math.sin(t*4.7)
    y=-3.75+t*6.2
    ico('Trail stepping stone',(x,y,.15),(.29,.24,.09),bank)
for i in range(6):
    y=-3.5+i*1.1
    x=-2.1+math.sin((y+3.75)/6.2*4.7)
    cylinder('Level pedestal %02d'%(i+1),(x,y,.24),.36,.16,stone,12)
    cylinder('Level inset %02d'%(i+1),(x,y,.33),.24,.035,flower,12)

for i in range(34):
    x=random.uniform(-4.7,4.7); y=random.uniform(-3.9,3.9)
    if abs(x-stream_x(y))<1.0 or x*x+(y/ .84)**2>27: continue
    if i%3==0:
        ico('Faceted river pebble',(x,y,.15),(.22,.18,.20),stone)
    else:
        cylinder('Wildflower stem',(x,y,.23),.018,.28,leaves[0],5)
        ico('Flower center',(x,y,.40),(.055,.055,.04),flower)
        for j in range(5):
            a=j*math.tau/5
            ico('Repeated cream petal',(x+.08*math.cos(a),y+.08*math.sin(a),.39),(.065,.055,.027),petal)
for x,y in [(3,-1.2),(3.3,-1.0),(-3.7,1.0)]:
    cylinder('Mushroom stem',(x,y,.23),.07,.29,petal)
    ico('Mushroom cap',(x,y,.4),(.23,.23,.12),red,2)

# A friendly mini ranger beside the first station.
cylinder('Ranger body',(-2.95,-3.1,.43),.17,.48,leaves[0])
ico('Ranger face',(-2.95,-3.1,.83),(.20,.18,.20),bank,2)
cylinder('Ranger hat brim',(-2.95,-3.1,1.0),.28,.045,wood,12)
cylinder('Ranger hat top',(-2.95,-3.1,1.08),.17,.15,wood,8)
cube('Ranger backpack',(-2.95,-2.9,.52),(.27,.16,.31),red,.05)
for x in [-3.05,-2.85]:
    cube('Ranger boots',(x,-3.16,.17),(.13,.23,.14),bark,.025)

cube('Backdrop',(0,0,-1.1),(200,200,.08),floor)
bpy.ops.object.light_add(type='AREA',location=(-3,-4,10))
light=bpy.context.object
light.name='Soft afternoon sun'
light.data.energy=1500
light.data.shape='DISK'
light.data.size=7
light.rotation_euler=(Vector((0,0,0))-light.location).to_track_quat('-Z','Y').to_euler()
bpy.ops.object.camera_add(location=(11,-15,12))
camera=bpy.context.object
camera.name='Plantini orthographic showcase'
camera.rotation_euler=(Vector((0,0,.6))-camera.location).to_track_quat('-Z','Y').to_euler()
camera.data.type='ORTHO'
camera.data.ortho_scale=16
scene.camera=camera
scene.frame_set(30)
scene.render.filepath=str(ROOT/'plantini-forest.png')
bpy.ops.wm.save_as_mainfile(filepath=str(ROOT/'plantini-forest.blend'),copy=True)
# Export only this new scene, not the pre-existing user scene.
bpy.ops.object.select_all(action='DESELECT')
for obj in scene.objects:
    if obj.type=='MESH' and obj.name != 'Backdrop' or obj.type=='EMPTY':
        obj.select_set(True)
bpy.ops.export_scene.gltf(filepath=str(ROOT/'plantini-forest.glb'),export_format='GLB',use_selection=True,export_animations=True)
bpy.ops.render.render(write_still=True)
print('PLANTINI_WORLD_READY '+str(ROOT))
