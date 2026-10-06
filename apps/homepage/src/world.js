// Turns the app's exported Blender modules (assets/worlds/*_module.json) into
// three.js geometry. Blender is z-up; three.js is y-up: (x, y, z) -> (x, z, -y).
// Meshes are merged per behaviour so a whole ecosystem costs a handful of draw
// calls: static, swaying vegetation, water glints, animated props and the explorer figure.
import * as THREE from 'three';
import { mergeGeometries } from 'three/examples/jsm/utils/BufferGeometryUtils.js';

const cache = new Map();

export function loadWorldData(url) {
  if (!cache.has(url)) {
    cache.set(url, fetch(url).then((response) => {
      if (!response.ok) throw new Error(`World ${url}: HTTP ${response.status}`);
      return response.json();
    }));
  }
  return cache.get(url);
}

function toThree([x, y, z]) {
  return [x, z, -y];
}

function meshGeometry(mesh, { sway = false, phase = 0 } = {}) {
  const positions = [];
  const colors = [];
  const color = new THREE.Color().setRGB(...mesh.color, THREE.SRGBColorSpace);
  let minY = Infinity;
  let maxY = -Infinity;
  const vertices = mesh.vertices.map(toThree);
  for (const [, y] of vertices) {
    minY = Math.min(minY, y);
    maxY = Math.max(maxY, y);
  }
  const height = Math.max(maxY - minY, 1e-3);
  const weights = [];
  for (const face of mesh.faces) {
    for (const index of face) {
      const vertex = vertices[index];
      positions.push(vertex[0], vertex[1], vertex[2]);
      colors.push(color.r, color.g, color.b);
      weights.push((vertex[1] - minY) / height);
    }
  }
  const geometry = new THREE.BufferGeometry();
  geometry.setAttribute('position', new THREE.Float32BufferAttribute(positions, 3));
  geometry.setAttribute('color', new THREE.Float32BufferAttribute(colors, 3));
  geometry.computeVertexNormals(); // non-indexed: flat, low-poly look
  if (sway || phase) {
    const amplitude = (mesh.motion === 'tree' ? 0.1 : 0.16) * height;
    geometry.setAttribute('aWeight', new THREE.Float32BufferAttribute(weights, 1));
    geometry.setAttribute('aPhase', new THREE.Float32BufferAttribute(new Array(weights.length).fill(phase), 1));
    geometry.setAttribute('aAmp', new THREE.Float32BufferAttribute(new Array(weights.length).fill(amplitude), 1));
  }
  return geometry;
}

// Props that move (windmill sails, wings, ducks, bees, hopping animals) carry
// their animation in vertex attributes and run in ONE shader, the same
// formulas as WorldMesh.coordsAt in the app (apps/flutter/.../world_module.dart):
// a loop is 6 s and every frequency is a whole number, so it closes.
const ANIM_KIND = { spin: 1, flap: 2, bob: 3, hop: 4, orbit: 5 };

function animGeometry(mesh) {
  const geometry = meshGeometry(mesh);
  const a = mesh.anim;
  const count = geometry.attributes.position.count;
  const pivot = toThree(a.pivot ?? [0, 0, 0]);
  const axis = toThree(a.axis ?? [0, 0, 1]);
  const drift = a.drift ?? [0, 0, 0];
  // aB: orbit radius or flap drift frequency, then the drift (bob: the roll) in Blender axes.
  const second = mesh.motion === 'orbit' ? (a.radius ?? 1) : (a.driftFreq ?? 1);
  const b = mesh.motion === 'bob' ? [second, a.roll ?? 0, 0, 0] : [second, ...drift];
  const fill = (values) => Array.from({ length: count }, () => values).flat();
  geometry.setAttribute('aPivot', new THREE.Float32BufferAttribute(fill(pivot), 3));
  geometry.setAttribute('aAxis', new THREE.Float32BufferAttribute(fill(axis), 3));
  geometry.setAttribute('aA', new THREE.Float32BufferAttribute(fill([ANIM_KIND[mesh.motion], a.amp ?? 0, a.freq ?? 1, a.phase ?? 0]), 4));
  geometry.setAttribute('aB', new THREE.Float32BufferAttribute(fill(b), 4));
  return geometry;
}

function merge(geometries) {
  return geometries.length ? mergeGeometries(geometries, false) : null;
}

export function buildWorld(data, time) {
  const buckets = { static: [], sway: [], water: [], ranger: [], anim: [] };
  let counter = 0;
  for (const mesh of data.meshes) {
    counter += 1;
    const phase = (counter * 2.399963) % (Math.PI * 2); // golden angle: neighbours sway out of step
    if (mesh.anim && ANIM_KIND[mesh.motion]) buckets.anim.push(animGeometry(mesh));
    else if (mesh.motion === 'tree' || mesh.motion === 'plant') buckets.sway.push(meshGeometry(mesh, { sway: true, phase }));
    else if (mesh.motion === 'water') buckets.water.push(meshGeometry(mesh, { phase }));
    else if (mesh.motion === 'ranger') buckets.ranger.push(meshGeometry(mesh));
    else buckets.static.push(meshGeometry(mesh));
  }

  const group = new THREE.Group();

  const solid = new THREE.MeshLambertMaterial({ vertexColors: true, side: THREE.DoubleSide });
  const staticGeometry = merge(buckets.static);
  if (staticGeometry) group.add(new THREE.Mesh(staticGeometry, solid));

  const swaying = new THREE.MeshLambertMaterial({ vertexColors: true, side: THREE.DoubleSide });
  swaying.onBeforeCompile = (shader) => {
    shader.uniforms.uTime = time;
    shader.vertexShader = shader.vertexShader
      .replace('#include <common>', '#include <common>\nattribute float aWeight; attribute float aPhase; attribute float aAmp; uniform float uTime;')
      .replace('#include <begin_vertex>', `#include <begin_vertex>
        float sway = aWeight * aWeight * aAmp;
        transformed.x += sin(uTime * 1.25 + aPhase) * sway;
        transformed.z += cos(uTime * 0.9 + aPhase * 1.3) * sway * 0.5;`);
  };
  const swayGeometry = merge(buckets.sway);
  if (swayGeometry) group.add(new THREE.Mesh(swayGeometry, swaying));

  const animated = new THREE.MeshLambertMaterial({ vertexColors: true, side: THREE.DoubleSide });
  animated.onBeforeCompile = (shader) => {
    shader.uniforms.uTime = time;
    shader.vertexShader = shader.vertexShader
      .replace('#include <common>', '#include <common>\nattribute vec3 aPivot; attribute vec3 aAxis; attribute vec4 aA; attribute vec4 aB; uniform float uTime;')
      .replace('#include <begin_vertex>', `#include <begin_vertex>
        float kind = aA.x, amp = aA.y;
        float loop = uTime / 6.0;
        float t = 6.2831853 * aA.z * loop + 6.2831853 * aA.w;
        float angle = 0.0;
        vec3 off = vec3(0.0); // offset in Blender axes
        if (kind < 1.5) { angle = t; }
        else if (kind < 2.5) {
          angle = amp * sin(t);
          float dt = 6.2831853 * aB.x * loop + 6.2831853 * aA.w;
          off = vec3(aB.y * sin(dt), aB.z * sin(dt + 1.5707963), aB.w * sin(2.0 * dt));
        } else if (kind < 3.5) { off.z = amp * sin(t); angle = aB.y * sin(t + 1.0); }
        else if (kind < 4.5) { off.z = amp * abs(sin(t * 0.5)); }
        else { angle = t; off = vec3(aB.x * (cos(t) - 1.0), aB.x * sin(t), amp * sin(2.0 * t)); }
        vec3 ax = normalize(aAxis);
        vec3 rel = transformed - aPivot;
        float ca = cos(angle), sa = sin(angle);
        rel = rel * ca + cross(ax, rel) * sa + ax * dot(ax, rel) * (1.0 - ca);
        transformed = rel + aPivot + vec3(off.x, off.z, -off.y);`);
  };
  const animatedGeometry = merge(buckets.anim);
  if (animatedGeometry) {
    const animatedMesh = new THREE.Mesh(animatedGeometry, animated);
    animatedMesh.frustumCulled = false; // creatures leave their rest position
    group.add(animatedMesh);
  }

  const glint = new THREE.MeshBasicMaterial({ vertexColors: true, transparent: true, depthWrite: false });
  glint.onBeforeCompile = (shader) => {
    shader.uniforms.uTime = time;
    shader.vertexShader = shader.vertexShader
      .replace('#include <common>', '#include <common>\nattribute float aPhase; varying float vPhase;')
      .replace('#include <begin_vertex>', '#include <begin_vertex>\nvPhase = aPhase;');
    shader.fragmentShader = shader.fragmentShader
      .replace('#include <common>', '#include <common>\nvarying float vPhase; uniform float uTime;')
      .replace('#include <color_fragment>', '#include <color_fragment>\ndiffuseColor.a *= 0.3 + 0.7 * (0.5 + 0.5 * sin(uTime * 2.2 + vPhase));');
  };
  const glintGeometry = merge(buckets.water);
  if (glintGeometry) group.add(new THREE.Mesh(glintGeometry, glint));

  let ranger = null;
  const rangerGeometry = merge(buckets.ranger);
  if (rangerGeometry) {
    ranger = new THREE.Mesh(rangerGeometry, solid);
    group.add(ranger);
  }

  // Level stations of the module (6 slots), in three.js coordinates.
  const slots = (data.slots ?? []).map((slot) => new THREE.Vector3(...toThree(slot)));

  return {
    group,
    slots,
    update(seconds) {
      if (ranger) ranger.position.y = Math.abs(Math.sin(seconds * 2.4)) * 0.05;
    },
    dispose() {
      group.traverse((node) => node.geometry?.dispose());
      solid.dispose(); swaying.dispose(); animated.dispose(); glint.dispose();
    },
  };
}

// Soft contact shadow under a module so it does not float on the page.
export function makeShadow() {
  const size = 128;
  const canvas = document.createElement('canvas');
  canvas.width = size; canvas.height = size;
  const context = canvas.getContext('2d');
  const gradient = context.createRadialGradient(size / 2, size / 2, 4, size / 2, size / 2, size / 2);
  gradient.addColorStop(0, 'rgba(46,43,37,0.38)');
  gradient.addColorStop(1, 'rgba(46,43,37,0)');
  context.fillStyle = gradient;
  context.fillRect(0, 0, size, size);
  const texture = new THREE.CanvasTexture(canvas);
  const shadow = new THREE.Mesh(
    new THREE.PlaneGeometry(1, 1),
    new THREE.MeshBasicMaterial({ map: texture, transparent: true, depthWrite: false }),
  );
  shadow.rotation.x = -Math.PI / 2;
  shadow.position.y = -1.05;
  shadow.scale.set(17, 15, 1);
  return shadow;
}

export function addLights(scene) {
  scene.add(new THREE.HemisphereLight(0xfff4e0, 0x8f9c72, 1.5));
  const sun = new THREE.DirectionalLight(0xffffff, 2.4);
  sun.position.set(5, 9, 6);
  scene.add(sun);
}

export function webglAvailable() {
  try {
    const canvas = document.createElement('canvas');
    return Boolean(window.WebGLRenderingContext && (canvas.getContext('webgl2') || canvas.getContext('webgl')));
  } catch {
    return false;
  }
}

// True when WebGL runs on the CPU (SwiftShader, llvmpipe, ...). Common on Linux
// browsers without GPU acceleration; continuous 3D animation is unusable there.
export function softwareRenderer() {
  try {
    const gl = document.createElement('canvas').getContext('webgl');
    const info = gl?.getExtension('WEBGL_debug_renderer_info');
    const name = info ? String(gl.getParameter(info.UNMASKED_RENDERER_WEBGL)) : '';
    return /swiftshader|llvmpipe|softpipe|software|basic render/i.test(name);
  } catch {
    return false;
  }
}
