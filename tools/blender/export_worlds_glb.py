"""Write the three world modules as GLB files to look at them in any glTF viewer.

    python3 tools/blender/export_worlds_glb.py [output-dir]

Pure Python (no Blender). One file per world and prop variant, for example
`forest-v0.glb`: the base scenery plus the props of that variant, as one flat-coloured
mesh (vertex colours, no normals so a viewer shades every face flat, like the app).
Animated parts stand in their rest pose; the lights and shadows are not part of it.
Open the files with Blender, https://gltf-viewer.donmccurdy.com/ (drag and drop) or
any other viewer. The module is 11.5 x 10 units; z up in the JSON becomes y up here.
"""
import json
import struct
import sys
from pathlib import Path

ROOT = Path(__file__).resolve().parents[2]
ASSETS = ROOT / 'apps/flutter/assets/worlds'


def build(module, variant):
    pos, col, idx = [], [], []
    for m in module['meshes']:
        if m.get('variant') not in (None, variant):
            continue
        base = len(pos)
        r, g, b = m['color']
        for x, y, z in m['vertices']:
            pos.append((x, z, -y))  # z up -> y up, still a proper rotation
            col.append((r, g, b))
        for a, b2, c in m['faces']:
            idx += [base + a, base + b2, base + c]
    return pos, col, idx


def glb(pos, col, idx):
    pbytes = b''.join(struct.pack('<3f', *p) for p in pos)
    cbytes = b''.join(struct.pack('<3f', *c) for c in col)
    ibytes = b''.join(struct.pack('<I', i) for i in idx)
    blob = pbytes + cbytes + ibytes
    mins = [min(p[k] for p in pos) for k in range(3)]
    maxs = [max(p[k] for p in pos) for k in range(3)]
    doc = {
        'asset': {'version': '2.0', 'generator': 'plantini export_worlds_glb.py'},
        'scene': 0, 'scenes': [{'nodes': [0]}], 'nodes': [{'mesh': 0}],
        'materials': [{'pbrMetallicRoughness': {'baseColorFactor': [1, 1, 1, 1], 'metallicFactor': 0, 'roughnessFactor': 1},
                       'doubleSided': True}],
        'meshes': [{'primitives': [{'attributes': {'POSITION': 0, 'COLOR_0': 1}, 'indices': 2, 'material': 0}]}],
        'buffers': [{'byteLength': len(blob)}],
        'bufferViews': [
            {'buffer': 0, 'byteOffset': 0, 'byteLength': len(pbytes), 'target': 34962},
            {'buffer': 0, 'byteOffset': len(pbytes), 'byteLength': len(cbytes), 'target': 34962},
            {'buffer': 0, 'byteOffset': len(pbytes) + len(cbytes), 'byteLength': len(ibytes), 'target': 34963},
        ],
        'accessors': [
            {'bufferView': 0, 'componentType': 5126, 'count': len(pos), 'type': 'VEC3', 'min': mins, 'max': maxs},
            {'bufferView': 1, 'componentType': 5126, 'count': len(col), 'type': 'VEC3'},
            {'bufferView': 2, 'componentType': 5125, 'count': len(idx), 'type': 'SCALAR'},
        ],
    }
    js = json.dumps(doc, separators=(',', ':')).encode()
    js += b' ' * (-len(js) % 4)
    blob += b'\0' * (-len(blob) % 4)
    total = 12 + 8 + len(js) + 8 + len(blob)
    return (struct.pack('<4sII', b'glTF', 2, total) + struct.pack('<I4s', len(js), b'JSON') + js
            + struct.pack('<I4s', len(blob), b'BIN\0') + blob)


def main():
    out = Path(sys.argv[1]) if len(sys.argv) > 1 else ROOT / 'artifacts/3d/worlds'
    out.mkdir(parents=True, exist_ok=True)
    for world in ('forest', 'meadow', 'alpine'):
        module = json.loads((ASSETS / f'{world}_module.json').read_text())
        for variant in (0, 1):
            pos, col, idx = build(module, variant)
            path = out / f'{world}-v{variant}.glb'
            path.write_bytes(glb(pos, col, idx))
            print(f'{path}: {len(idx) // 3} triangles, {path.stat().st_size // 1024} KiB')


if __name__ == '__main__':
    main()
