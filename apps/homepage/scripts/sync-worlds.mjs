#!/usr/bin/env node
// Copies the app's world modules (apps/flutter/assets/worlds/*_module.json) into
// public/worlds/ for the homepage's three.js scenes.
//
// The homepage shows ONE module per ecosystem, so only the base scenery and the
// props of variant 0 are taken. Lights, shadows and fireflies belong to the app's
// own renderer and are dropped; coordinates are rounded to 3 decimals; decals get
// a little height because three.js has a depth buffer (the app orders them
// instead) and would otherwise let the grass or the water cover them.
//
// Usage: node scripts/sync-worlds.mjs   (also `npm run worlds`)
import { readFile, writeFile, mkdir } from 'node:fs/promises';
import { fileURLToPath } from 'node:url';
import path from 'node:path';

const root = path.resolve(fileURLToPath(new URL('..', import.meta.url)));
const source = path.resolve(root, '../flutter/assets/worlds');
const target = path.join(root, 'public/worlds');
const round = (n) => Math.round(n * 1000) / 1000;
const lift = { decal: 0.012, decal2: 0.022 };

await mkdir(target, { recursive: true });
for (const [from, to] of [['forest', 'forest'], ['meadow', 'meadow'], ['alpine', 'alpine']]) {
  const module = JSON.parse(await readFile(path.join(source, `${from}_module.json`), 'utf8'));
  const meshes = module.meshes
    .filter((m) => m.variant === undefined || m.variant === null || m.variant === 0)
    .map((m) => {
      const dz = lift[m.layer] ?? 0;
      const out = {
        name: m.name,
        vertices: m.vertices.map(([x, y, z]) => [round(x), round(y), round(z + dz)]),
        faces: m.faces,
        color: m.color,
        motion: m.motion,
      };
      if (m.anim) out.anim = m.anim;
      return out;
    });
  const data = { version: module.version, length: module.length, slots: module.slots, meshes };
  await writeFile(path.join(target, `${to}.json`), JSON.stringify(data));
  const tris = meshes.reduce((n, m) => n + m.faces.length, 0);
  console.log(`${to}.json: ${meshes.length} meshes, ${tris} triangles`);
}
