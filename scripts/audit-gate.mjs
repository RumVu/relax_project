#!/usr/bin/env node

// CI gate: fail on high/critical npm advisories, except ones listed in
// scripts/audit-allowlist.json. Every allowlist entry carries a reason and an
// expiry date so accepted risks get re-reviewed instead of silently piling up.
//
// Usage: node scripts/audit-gate.mjs [extra npm audit args...]
// Example: node scripts/audit-gate.mjs --omit=dev --workspace apps/backend

import { execFileSync } from 'child_process';
import fs from 'fs';
import path from 'path';
import { fileURLToPath } from 'url';

const __dirname = path.dirname(fileURLToPath(import.meta.url));
const BLOCKING = new Set(['high', 'critical']);

const allowlist = JSON.parse(
  fs.readFileSync(path.join(__dirname, 'audit-allowlist.json'), 'utf8'),
);
const today = new Date().toISOString().slice(0, 10);

let raw;
try {
  raw = execFileSync('npm', ['audit', '--json', ...process.argv.slice(2)], {
    encoding: 'utf8',
    maxBuffer: 64 * 1024 * 1024,
  });
} catch (err) {
  // npm audit exits non-zero when it finds anything; the JSON is still on stdout.
  raw = err.stdout;
}
const report = JSON.parse(raw);

const advisories = new Map();
for (const [pkg, vuln] of Object.entries(report.vulnerabilities ?? {})) {
  for (const via of vuln.via) {
    if (typeof via === 'string' || !BLOCKING.has(via.severity)) continue;
    const id = via.url.split('/').pop();
    advisories.set(id, { id, pkg, severity: via.severity, title: via.title });
  }
}

let failed = false;
for (const adv of advisories.values()) {
  const entry = allowlist.find((a) => a.id === adv.id);
  const label = `${adv.severity} ${adv.pkg} ${adv.id} — ${adv.title}`;
  if (!entry) {
    console.error(`✗ ${label}`);
    failed = true;
  } else if (entry.expires < today) {
    console.error(`✗ ${label} (allowlist entry expired ${entry.expires})`);
    failed = true;
  } else {
    console.log(`~ ${label} (allowlisted until ${entry.expires})`);
  }
}

for (const entry of allowlist) {
  if (!advisories.has(entry.id)) {
    console.log(`i ${entry.id} no longer reported — remove it from the allowlist`);
  }
}

if (failed) process.exit(1);
console.log(`✓ no unaccepted high/critical advisories (${advisories.size} checked)`);
