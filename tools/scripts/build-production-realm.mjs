#!/usr/bin/env node
// Derives the production realm from the versioned, secret-free realm export.
// Usage: node tools/scripts/build-production-realm.mjs <public-origin> <smtp-host> <smtp-port> <smtp-user> <out.json>
// The SMTP password is NOT part of the file: set it with
// infra/production/configure-smtp.sh after the first start.
import { readFile, writeFile } from 'node:fs/promises';
import { resolve } from 'node:path';

const [origin, smtpHost, smtpPort, smtpUser, out] = process.argv.slice(2);
if (!origin?.startsWith('https://') || !smtpHost || !smtpPort || !smtpUser || !out) {
  console.error('Usage: build-production-realm.mjs https://<domain> <smtp-host> <smtp-port> <smtp-user> <out.json>');
  process.exit(64);
}
const source = new URL('../../services/identity/realm/plantini-realm.json', import.meta.url);
const realm = JSON.parse(await readFile(source, 'utf8'));

realm.sslRequired = 'all';
// Self-registration stays open; the validator requires it together with
// e-mail verification and password reset.
realm.registrationAllowed = true;
realm.verifyEmail = true;
realm.resetPasswordAllowed = true;
realm.smtpServer = {
  host: smtpHost,
  port: smtpPort,
  from: smtpUser,
  fromDisplayName: 'Plantini',
  ssl: 'true',
  starttls: 'false',
  auth: 'true',
  user: smtpUser,
};

const web = realm.clients.find((client) => client.clientId === 'plantini-web-production');
if (!web) throw new Error('plantini-web-production is missing in the versioned realm');
web.enabled = true;
web.name = 'Plantini Web (production)';
web.redirectUris = [`${origin}/`, `${origin}/auth/callback`, `${origin}/auth/logout-callback`];
web.webOrigins = [origin];
web.attributes = { ...web.attributes, 'post.logout.redirect.uris': `${origin}/auth/logout-callback` };

await writeFile(resolve(out), `${JSON.stringify(realm, null, 2)}\n`);
console.log(`Production realm written to ${out}`);
