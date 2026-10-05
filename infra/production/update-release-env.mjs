#!/usr/bin/env node
// Run on the host inside the existing Node image; never display env contents.
// Usage: update-release-env.mjs /workspace/production.env <commit-tag>
import { readFile, writeFile, copyFile, chmod } from 'node:fs/promises';
const [file, release, scope = 'all'] = process.argv.slice(2);
if (!file || !/^[0-9a-f]{7,40}$/.test(release || '')) throw new Error('An environment path and exact commit tag are required.');
if (!['all', 'teacher'].includes(scope)) throw new Error('Release scope must be all or teacher.');
let source = await readFile(file, 'utf8');
await copyFile(file, `${file}.bak-${Date.now()}`);
const changes = scope === 'teacher' ? { TEACHER_IMAGE: `plantini/teacher:${release}` } : { PLATFORM_IMAGE: `plantini/platform:${release}`, TEACHER_IMAGE: `plantini/teacher:${release}`, EDITOR_IMAGE: `plantini/editor:${release}`, TEACHER_PUBLIC_URL: 'https://portal.plantini.eu', TEACHER_LOOPBACK_PORT: '8085' };
for (const [name, value] of Object.entries(changes)) {
  const pattern = new RegExp(`^${name}=.*$`, 'm');
  source = pattern.test(source) ? source.replace(pattern, `${name}=${value}`) : `${source.replace(/\s*$/, '')}\n${name}=${value}\n`;
}
await writeFile(file, source, { mode: 0o600 }); await chmod(file, 0o600);
console.log(`Production image references updated to ${release}; previous environment preserved.`);
