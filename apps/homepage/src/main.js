document.documentElement.classList.add('js');
import '@fontsource-variable/fraunces';
import '@fontsource-variable/inter';
import * as THREE from 'three';
import { OrbitControls } from 'three/examples/jsm/controls/OrbitControls.js';
import './style.css';
import content from './content.json';
import { STORE_URLS } from './config.js';
import { renderCard, renderMosaic } from './cards.js';
import { addLights, buildWorld, loadWorldData, makeShadow, webglAvailable } from './world.js';

const $ = (selector, root = document) => root.querySelector(selector);
const $$ = (selector, root = document) => [...root.querySelectorAll(selector)];
const reducedMotion = window.matchMedia('(prefers-reduced-motion: reduce)').matches;
const ecosystems = content.ecosystems;
const byKey = new Map(ecosystems.map((ecosystem) => [ecosystem.key, ecosystem]));

// ---- shared selection state -------------------------------------------------
const state = { eco: 'wald', station: 0 };
const listeners = new Set();
function select(eco, station = 0) {
  state.eco = eco;
  state.station = station;
  listeners.forEach((listener) => listener(state));
}

// ---- small page behaviours --------------------------------------------------
function initNav() {
  const nav = $('#nav');
  const toggle = $('.nav-toggle');
  const links = $('#nav-links');
  toggle.addEventListener('click', () => {
    const open = toggle.getAttribute('aria-expanded') !== 'true';
    toggle.setAttribute('aria-expanded', String(open));
    links.classList.toggle('open', open);
  });
  links.addEventListener('click', (event) => {
    if (event.target.closest('a')) {
      toggle.setAttribute('aria-expanded', 'false');
      links.classList.remove('open');
    }
  });
  const onScroll = () => nav.classList.toggle('scrolled', window.scrollY > 8);
  onScroll();
  window.addEventListener('scroll', onScroll, { passive: true });
}

function initReveal() {
  const targets = $$('.reveal');
  if (reducedMotion || !('IntersectionObserver' in window)) {
    targets.forEach((node) => node.classList.add('in'));
    return;
  }
  const observer = new IntersectionObserver((entries) => {
    for (const entry of entries) {
      if (entry.isIntersecting) {
        entry.target.classList.add('in');
        observer.unobserve(entry.target);
      }
    }
  }, { rootMargin: '0px 0px -8% 0px' });
  targets.forEach((node) => observer.observe(node));
}

function initStores() {
  for (const node of $$('.store')) {
    const url = STORE_URLS[node.dataset.store];
    if (!url) continue;
    const link = document.createElement('a');
    link.className = 'store store-live';
    link.href = url;
    link.rel = 'noopener noreferrer';
    link.append(...[...node.childNodes].map((child) => child.cloneNode(true)));
    for (const small of link.querySelectorAll('small')) small.textContent = small.textContent.replace('Bald', 'Jetzt');
    node.replaceWith(link);
  }
}

// ---- three.js helpers -------------------------------------------------------
function createStage(canvas) {
  const renderer = new THREE.WebGLRenderer({ canvas, antialias: true, alpha: true, powerPreference: 'high-performance' });
  renderer.setPixelRatio(Math.min(window.devicePixelRatio || 1, 2));
  renderer.setClearColor(0x000000, 0);
  const scene = new THREE.Scene();
  addLights(scene);
  const camera = new THREE.PerspectiveCamera(35, 1, 0.1, 200);
  return { renderer, scene, camera };
}

// Runs `frame` only while the canvas is on screen and the tab is visible.
function createLoop(host, frame) {
  let visible = false;
  let raf = 0;
  const started = performance.now();
  const tick = () => {
    raf = 0;
    if (!visible || document.hidden) return;
    frame((performance.now() - started) / 1000);
    if (!reducedMotion) raf = requestAnimationFrame(tick);
  };
  const start = () => { if (!raf) raf = requestAnimationFrame(tick); };
  new IntersectionObserver(([entry]) => {
    visible = entry.isIntersecting;
    if (visible) start();
  }, { threshold: 0.05 }).observe(host);
  document.addEventListener('visibilitychange', start);
  return { render: start };
}

function fallback(host) {
  host.classList.add('no-webgl');
  const note = document.createElement('p');
  note.className = 'no-webgl-note';
  note.textContent = 'Die 3D-Ansicht braucht WebGL. Im Browser ist sie hier nicht verfügbar – die App funktioniert trotzdem.';
  host.append(note);
}

const worldUrl = (eco) => `/worlds/${byKey.get(eco).world}.json`;

// ---- hero: three floating ecosystem cards -----------------------------------
async function initHero() {
  const host = $('#hero-stage');
  const canvas = $('#hero-canvas');
  if (!webglAvailable()) return fallback(host);
  const time = { value: 0 };
  const { renderer, scene, camera } = createStage(canvas);
  const tiles = [];
  const hits = [];
  const datas = await Promise.all(ecosystems.map((ecosystem) => loadWorldData(worldUrl(ecosystem.key))));
  ecosystems.forEach((ecosystem, index) => {
    const built = buildWorld(datas[index], time);
    const tile = new THREE.Group();
    tile.add(built.group);
    tile.scale.setScalar(0.5);
    const offset = index - 1;
    tile.position.set(offset * 6.6, 0, -Math.abs(offset) * 1.6);
    tile.rotation.y = -offset * 0.42;
    const shadow = makeShadow();
    tile.add(shadow);
    const hit = new THREE.Mesh(new THREE.BoxGeometry(11.5, 4, 10), new THREE.MeshBasicMaterial({ visible: false }));
    hit.position.y = 0.8;
    hit.userData.eco = ecosystem.key;
    tile.add(hit);
    hits.push(hit);
    scene.add(tile);
    tiles.push({ key: ecosystem.key, tile, built, base: tile.position.clone(), baseRot: tile.rotation.y, lift: 0, shadow });
  });
  const raycaster = new THREE.Raycaster();
  const pointer = new THREE.Vector2(9, 9);
  let hovered = null;
  const buttons = $$('.tile-picker button');

  function fit() {
    const width = host.clientWidth;
    const height = host.clientHeight;
    renderer.setSize(width, height, false);
    camera.aspect = width / height;
    const distance = Math.max(13, 19 / (2 * Math.tan(THREE.MathUtils.degToRad(camera.fov / 2)) * camera.aspect));
    camera.position.set(0, distance * 0.62, distance * 0.86);
    camera.lookAt(0, -0.2, 0);
    camera.updateProjectionMatrix();
  }
  new ResizeObserver(() => { fit(); loop.render(); }).observe(host);
  fit();

  const loop = createLoop(host, (seconds) => {
    time.value = seconds;
    raycaster.setFromCamera(pointer, camera);
    const hit = raycaster.intersectObjects(hits, false)[0];
    hovered = hit ? hit.object.userData.eco : hovered && buttons.some((b) => b.matches(':hover, :focus-visible') && b.dataset.eco === hovered) ? hovered : null;
    canvas.classList.toggle('pointing', Boolean(hit));
    for (const item of tiles) {
      item.built.update(seconds);
      const target = item.key === hovered ? 0.9 : 0;
      item.lift += (target - item.lift) * 0.12;
      const bob = reducedMotion ? 0 : Math.sin(seconds * 0.9 + item.base.x) * 0.12;
      item.tile.position.y = item.base.y + item.lift + bob;
      item.tile.rotation.y = item.baseRot + (reducedMotion ? 0 : Math.sin(seconds * 0.35 + item.base.x) * 0.06);
      item.shadow.material.opacity = 1 - item.lift * 0.35;
    }
    renderer.render(scene, camera);
  });

  canvas.addEventListener('pointermove', (event) => {
    const rect = canvas.getBoundingClientRect();
    pointer.set(((event.clientX - rect.left) / rect.width) * 2 - 1, -((event.clientY - rect.top) / rect.height) * 2 + 1);
    loop.render();
  });
  canvas.addEventListener('pointerleave', () => { pointer.set(9, 9); loop.render(); });
  canvas.addEventListener('click', () => { if (hovered) goToEcosystem(hovered); });
  for (const button of buttons) {
    button.addEventListener('pointerenter', () => { hovered = button.dataset.eco; loop.render(); });
    button.addEventListener('focus', () => { hovered = button.dataset.eco; loop.render(); });
    button.addEventListener('pointerleave', () => { hovered = null; loop.render(); });
    button.addEventListener('blur', () => { hovered = null; loop.render(); });
    button.addEventListener('click', () => goToEcosystem(button.dataset.eco));
  }
}

function goToEcosystem(eco) {
  select(eco, 0);
  $('#demo').scrollIntoView({ behavior: reducedMotion ? 'auto' : 'smooth', block: 'start' });
}

// ---- demo: one explorable ecosystem with numbered stations -------------------
async function initDemo() {
  const host = $('#demo-stage');
  const canvas = $('#demo-canvas');
  const stationsHost = $('#stations');
  if (!webglAvailable()) {
    fallback(host);
    return;
  }
  const time = { value: 0 };
  const { renderer, scene, camera } = createStage(canvas);
  const built = new Map();
  const root = new THREE.Group();
  scene.add(root);
  root.add(makeShadow());

  const controls = new OrbitControls(camera, canvas);
  controls.enablePan = false;
  controls.enableZoom = false;
  controls.enableDamping = true;
  controls.minPolarAngle = 0.55;
  controls.maxPolarAngle = 1.32;
  controls.autoRotate = !reducedMotion;
  controls.autoRotateSpeed = 0.7;
  controls.target.set(0, 0.6, 0);
  // Vertical swipes must still scroll the page on touch devices.
  canvas.style.touchAction = 'pan-y';

  function fit() {
    const width = host.clientWidth;
    const height = host.clientHeight;
    renderer.setSize(width, height, false);
    camera.aspect = width / height;
    const distance = Math.max(17, 16 / (2 * Math.tan(THREE.MathUtils.degToRad(camera.fov / 2)) * camera.aspect));
    const direction = camera.position.clone().sub(controls.target);
    if (direction.lengthSq() < 1e-6) direction.set(0, 0.55, 1);
    camera.position.copy(controls.target).add(direction.normalize().multiplyScalar(distance));
    camera.updateProjectionMatrix();
  }
  camera.position.set(0, 9, 15);
  new ResizeObserver(() => { fit(); loop.render(); }).observe(host);
  fit();

  let current = null;
  let markers = [];
  async function show(eco) {
    if (!built.has(eco)) {
      const world = buildWorld(await loadWorldData(worldUrl(eco)), time);
      root.add(world.group);
      built.set(eco, world);
    }
    for (const [key, world] of built) world.group.visible = key === eco;
    current = built.get(eco);
    stationsHost.replaceChildren();
    markers = current.slots.map((slot, index) => {
      const button = document.createElement('button');
      button.type = 'button';
      button.className = 'station';
      button.textContent = String(index + 1);
      const plant = byKey.get(eco).plants[index];
      button.setAttribute('aria-label', `Station ${index + 1}: ${plant ? plant.commonName : 'Pflanze'}`);
      button.addEventListener('click', () => select(eco, index));
      stationsHost.append(button);
      return { button, position: slot.clone().add(new THREE.Vector3(0, 0.9, 0)) };
    });
    markActive();
    loop.render();
  }
  function markActive() {
    markers.forEach((marker, index) => marker.button.classList.toggle('active', index === state.station));
  }

  const projected = new THREE.Vector3();
  const loop = createLoop(host, (seconds) => {
    time.value = seconds;
    controls.update();
    current?.update(seconds);
    renderer.render(scene, camera);
    const width = host.clientWidth;
    const height = host.clientHeight;
    for (const marker of markers) {
      projected.copy(marker.position).project(camera);
      const x = (projected.x * 0.5 + 0.5) * width;
      const y = (-projected.y * 0.5 + 0.5) * height;
      marker.button.style.transform = `translate(${x.toFixed(1)}px, ${y.toFixed(1)}px) translate(-50%, -50%)`;
    }
  });
  controls.addEventListener('change', () => loop.render());
  controls.addEventListener('start', () => { controls.autoRotate = false; $('#demo-hint').classList.add('gone'); });
  controls.addEventListener('end', () => { controls.autoRotate = !reducedMotion; });

  let shown = null;
  listeners.add((next) => {
    if (next.eco !== shown) { shown = next.eco; show(next.eco); } else markActive();
  });
  shown = state.eco;
  await show(state.eco);
}

// ---- tabs, card preview and card strip --------------------------------------
function initCards() {
  const tabs = $$('.eco-tabs button');
  const demoCard = $('#demo-card');
  const strip = $('#cards-strip');
  const description = $('#eco-desc');
  tabs.forEach((tab) => tab.addEventListener('click', () => select(tab.dataset.eco, 0)));
  let renderedEco = null;
  const update = (next) => {
    const ecosystem = byKey.get(next.eco);
    tabs.forEach((tab) => {
      const on = tab.dataset.eco === next.eco;
      tab.setAttribute('aria-selected', String(on));
      tab.tabIndex = on ? 0 : -1;
    });
    description.textContent = ecosystem.description;
    demoCard.replaceChildren(renderCard(ecosystem.plants[next.station], ecosystem, { compact: true }));
    if (renderedEco !== next.eco) {
      renderedEco = next.eco;
      strip.replaceChildren(...ecosystem.plants.map((plant) => renderCard(plant, ecosystem)));
      strip.scrollLeft = 0;
    }
  };
  listeners.add(update);
  update(state);
  $('.eco-tabs').addEventListener('keydown', (event) => {
    if (!['ArrowLeft', 'ArrowRight'].includes(event.key)) return;
    const index = tabs.findIndex((tab) => tab.dataset.eco === state.eco);
    const next = tabs[(index + (event.key === 'ArrowRight' ? 1 : tabs.length - 1)) % tabs.length];
    select(next.dataset.eco, 0);
    next.focus();
  });
}

initNav();
initReveal();
initStores();
initCards();
renderMosaic($('#mosaic'), ecosystems);
initHero().catch((error) => { console.error(error); fallback($('#hero-stage')); });
initDemo().catch((error) => { console.error(error); fallback($('#demo-stage')); });
