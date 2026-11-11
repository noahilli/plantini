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
// Public self-registration is open (user decision 10.11.2026); teachers can
// additionally provision managed learner accounts through the portal.
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

const editor = realm.clients.find((client) => client.clientId === 'plantini-editor-production');
if (!editor) throw new Error('plantini-editor-production is missing in the versioned realm');
const editorOrigin = new URL(origin);
editorOrigin.hostname = `studio.${editorOrigin.hostname.replace(/^app\./, '')}`;
editor.enabled = true;
editor.redirectUris = [`${editorOrigin.origin}/`];
editor.webOrigins = [editorOrigin.origin];
editor.attributes = { ...editor.attributes, 'post.logout.redirect.uris': `${editorOrigin.origin}/` };

const teacher = realm.clients.find((client) => client.clientId === 'plantini-teacher-production');
if (!teacher) throw new Error('plantini-teacher-production is missing in the versioned realm');
const teacherOrigin = new URL(origin);
teacherOrigin.hostname = `portal.${teacherOrigin.hostname.replace(/^app\./, '')}`;
teacher.enabled = true;
teacher.redirectUris = [`${teacherOrigin.origin}/`];
teacher.webOrigins = [teacherOrigin.origin];
teacher.attributes = { ...teacher.attributes, 'post.logout.redirect.uris': `${teacherOrigin.origin}/` };

// Native app: phones return to the app through the verified App Link
// `https://plantini.eu/app/login` (fallback page -> `eu.plantini.app://oauth2redirect`), desktops receive the code on a loopback
// address (RFC 8252, port fixed in apps/flutter/lib/auth/auth_platform_io.dart).
const mobile = realm.clients.find((client) => client.clientId === 'plantini-mobile-production');
if (!mobile) throw new Error('plantini-mobile-production is missing in the versioned realm');
mobile.enabled = true;
mobile.name = 'Plantini Android (production)';
mobile.redirectUris = ['http://127.0.0.1:4000/', 'https://plantini.eu/app/login', 'eu.plantini.app://oauth2redirect'];
mobile.attributes = { ...mobile.attributes, 'post.logout.redirect.uris': 'eu.plantini.app://oauth2redirect' };
mobile.webOrigins = [];

await writeFile(resolve(out), `${JSON.stringify(realm, null, 2)}\n`);
console.log(`Production realm written to ${out}`);
