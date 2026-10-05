#!/usr/bin/env node
// Generate public download metadata from the built APK and versioned pubspec.
import { readFile, writeFile } from 'node:fs/promises';
import { createHash } from 'node:crypto';
import { dirname, join, resolve } from 'node:path';

const apk = resolve(process.argv[2] || 'apps/flutter/build/app/outputs/flutter-apk/app-release.apk');
const pubspec = await readFile(new URL('../../apps/flutter/pubspec.yaml', import.meta.url), 'utf8');
const match = /^version:\s*(\d+\.\d+\.\d+)\+(\d+)\s*$/m.exec(pubspec);
if (!match) throw new Error('A version name and increasing build number are required.');
const bytes = await readFile(apk);
const sha256 = createHash('sha256').update(bytes).digest('hex');
const metadata = { versionName: match[1], versionCode: Number(match[2]), bytes: bytes.length, sha256, minAndroid: 7 };
await writeFile(join(dirname(apk), 'plantini.json'), `${JSON.stringify(metadata, null, 2)}\n`);
await writeFile(join(dirname(apk), 'plantini.apk.sha256'), `${sha256}  plantini.apk\n`);
console.log(`Android ${metadata.versionName} (${metadata.versionCode}): ${metadata.bytes} bytes; public metadata prepared.`);
