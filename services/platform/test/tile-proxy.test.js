'use strict';

const assert = require('node:assert/strict');
const { mkdtemp } = require('node:fs/promises');
const os = require('node:os');
const path = require('node:path');
const test = require('node:test');

const { TileProxy } = require('../src/api/platform/services/core/content/tile-proxy');

const png = Buffer.concat([Buffer.from([137, 80, 78, 71, 13, 10, 26, 10]), Buffer.from('tile')]);

test('tile coordinates are validated against the zoom level', () => {
  assert.deepEqual(TileProxy.parse({ z: '3', x: '7', y: '0' }), { z: 3, x: 7, y: 0 });
  for (const bad of [{ z: '19', x: '0', y: '0' }, { z: '3', x: '8', y: '0' }, { z: '3', x: '-1', y: '0' }, { z: 'a', x: '0', y: '0' }, { z: '3', x: '1.5', y: '0' }]) {
    assert.equal(TileProxy.parse(bad), undefined, JSON.stringify(bad));
  }
});

test('a tile is fetched once, then served from the cache; an old copy survives provider failure', async () => {
  const root = await mkdtemp(path.join(os.tmpdir(), 'tiles-'));
  let calls = 0;
  let failing = false;
  let now = Date.now();
  const proxy = new TileProxy({
    root,
    clock: () => now,
    fetchTile: async () => { calls += 1; if (failing) throw new Error('down'); return png; },
  });
  const tile = { z: 2, x: 1, y: 1 };
  assert.deepEqual(await proxy.get(tile), png);
  assert.deepEqual(await proxy.get(tile), png);
  assert.equal(calls, 1);
  now += 15 * 86400000;
  failing = true;
  assert.deepEqual(await proxy.get(tile), png);
  assert.equal(calls, 2);
  await assert.rejects(() => proxy.get({ z: 2, x: 2, y: 2 }));
});

test('a provider answer that is not a PNG is rejected', async () => {
  const root = await mkdtemp(path.join(os.tmpdir(), 'tiles-'));
  const proxy = new TileProxy({ root, fetchTile: async () => Buffer.from('<html>') });
  await assert.rejects(() => proxy.get({ z: 1, x: 0, y: 0 }), /not a PNG/);
});
