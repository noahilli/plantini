import { readFile } from 'node:fs/promises';
import { spawn } from 'node:child_process';
import { dirname, resolve } from 'node:path';
import { fileURLToPath } from 'node:url';

const scriptDirectory = dirname(fileURLToPath(import.meta.url));
const environmentPath = resolve(scriptDirectory, '..', '.runtime', 'e2e.env');
const [command, ...args] = process.argv.slice(2);

if (!command) {
  throw new Error('Usage: node run-with-e2e-env.mjs <command> [args...]');
}

const text = await readFile(environmentPath, 'utf8').catch(() => {
  throw new Error('E2E environment is missing. Run npm run stack:up first.');
});
const environment = { ...process.env };
for (const line of text.split(/\r?\n/)) {
  if (!line) continue;
  const separator = line.indexOf('=');
  if (separator < 1) throw new Error(`Invalid E2E environment line: ${line}`);
  environment[line.slice(0, separator)] = line.slice(separator + 1);
}

const child = spawn(command, args, { cwd: resolve(scriptDirectory, '..'), env: environment, stdio: 'inherit' });
child.on('error', (error) => {
  console.error(error.message);
  process.exitCode = 1;
});
child.on('exit', (code, signal) => {
  process.exitCode = code ?? (signal ? 1 : 0);
});
