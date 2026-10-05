#!/usr/bin/env node
// Preserve the web directory inode mounted by Caddy and replace each public
// file atomically. Previous download files remain in the release directory.
import { readdir, mkdir, copyFile, rename, readFile, stat } from 'node:fs/promises';
import { join, resolve, relative } from 'node:path';
import { createHash } from 'node:crypto';

const [rootArgument, releaseArgument] = process.argv.slice(2);
if (!rootArgument || !releaseArgument) throw new Error('Usage: promote-public-assets.mjs <root> <release-directory>');
const root = resolve(rootArgument), release = resolve(releaseArgument);
if (!relative(join(root, 'releases'), release) || relative(join(root, 'releases'), release).startsWith('..')) throw new Error('Release must be a child of the deployment releases directory.');
const version = JSON.parse(await readFile(join(release, 'web/version.json'), 'utf8'));
const metadata = JSON.parse(await readFile(join(release, 'plantini.json'), 'utf8'));
const apk = await readFile(join(release, 'plantini.apk'));
if (version.version !== metadata.versionName || Number(version.build_number) !== metadata.versionCode || apk.length !== metadata.bytes || createHash('sha256').update(apk).digest('hex') !== metadata.sha256) throw new Error('Web/APK versions or APK checksum differ.');

const previous = join(release, 'previous-downloads'); await mkdir(previous, { recursive: true });
for (const name of ['plantini.apk', 'plantini.json', 'plantini.apk.sha256']) {
  const existing = join(root, 'downloads', name);
  if (await stat(existing).catch(() => null)) await copyFile(existing, join(previous, name));
}

const entryFiles = new Set(['main.dart.js', 'flutter_bootstrap.js', 'flutter_service_worker.js', 'index.html', 'version.json']);
const entries = [];
async function atomicCopy(source, destination) {
  await mkdir(resolve(destination, '..'), { recursive: true });
  const temporary = `${destination}.release-${process.pid}`;
  await copyFile(source, temporary); await rename(temporary, destination);
}
async function walk(source, destination, top = true) {
  for (const file of await readdir(source, { withFileTypes: true })) {
    if (file.isSymbolicLink()) throw new Error('Public release assets must not contain symlinks.');
    const from = join(source, file.name), to = join(destination, file.name);
    if (file.isDirectory()) await walk(from, to, false);
    else if (file.isFile()) {
      if (top && entryFiles.has(file.name)) entries.push([from, to]);
      else await atomicCopy(from, to);
    }
  }
}
await walk(join(release, 'web'), join(root, 'web'));
entries.sort((a, b) => Number(a[0].endsWith('version.json')) - Number(b[0].endsWith('version.json')));
for (const [from, to] of entries) await atomicCopy(from, to);
for (const name of ['plantini.apk', 'plantini.apk.sha256', 'plantini.json']) await atomicCopy(join(release, name), join(root, 'downloads', name));
console.log(`Public Web and signed Android ${version.version} (${version.build_number}) promoted; previous downloads preserved.`);
