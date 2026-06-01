#!/usr/bin/env bash
# =============================================================================
# Sync curated ambient sounds to Supabase Storage + Postgres.
#
# Catalog source:
#   apps/backend/prisma/ambient-sounds.catalog.cjs
#
# The files are direct Mixkit music MP3s under the Mixkit Free License:
#   https://mixkit.co/license/
#
# Usage:
#   bash scripts/seed-ambient-sounds.sh
# =============================================================================

set -euo pipefail

ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
cd "$ROOT"

node <<'NODE'
const fs = require('node:fs');
const os = require('node:os');
const path = require('node:path');
const { execFileSync } = require('node:child_process');
const { AMBIENT_SOUND_CATALOG } = require('./apps/backend/prisma/ambient-sounds.catalog.cjs');

function loadEnv(file) {
  if (!fs.existsSync(file)) return;
  for (const rawLine of fs.readFileSync(file, 'utf8').split(/\r?\n/)) {
    const line = rawLine.trim();
    if (!line || line.startsWith('#') || !line.includes('=')) continue;
    const index = line.indexOf('=');
    const key = line.slice(0, index).trim();
    let value = line.slice(index + 1).trim();
    value = value.replace(/^['"]|['"]$/g, '');
    if (!process.env[key]) process.env[key] = value;
  }
}

function quoteSql(value) {
  return `'${String(value ?? '').replaceAll("'", "''")}'`;
}

function publicSoundUrl(sound) {
  const bucket = process.env.SUPABASE_BUCKET || 'public-assets';
  return `${process.env.SUPABASE_URL}/storage/v1/object/public/${bucket}/ambient-sounds/${sound.key}.mp3`;
}

async function download(url, file) {
  const response = await fetch(url);
  if (!response.ok) {
    throw new Error(`Download failed ${response.status} ${url}`);
  }
  fs.writeFileSync(file, Buffer.from(await response.arrayBuffer()));
}

async function upload(sound, workDir) {
  const bucket = process.env.SUPABASE_BUCKET || 'public-assets';
  const file = path.join(workDir, `${sound.key}.mp3`);
  await download(sound.sourceUrl, file);

  const response = await fetch(
    `${process.env.SUPABASE_URL}/storage/v1/object/${bucket}/ambient-sounds/${sound.key}.mp3`,
    {
      method: 'POST',
      headers: {
        apikey: process.env.SUPABASE_SECRET_KEY,
        'Content-Type': 'audio/mpeg',
        'x-upsert': 'true',
      },
      body: fs.readFileSync(file),
    },
  );

  if (!response.ok) {
    const body = await response.text().catch(() => '');
    throw new Error(`Upload failed ${response.status} ${sound.key}: ${body}`);
  }
}

function buildSql() {
  const values = AMBIENT_SOUND_CATALOG.map((sound) => {
    const soundUrl =
      process.env.SUPABASE_URL && process.env.SUPABASE_SECRET_KEY
        ? publicSoundUrl(sound)
        : sound.sourceUrl;

    return [
      quoteSql(`curated-${sound.key}`),
      quoteSql(sound.title),
      quoteSql(sound.description),
      quoteSql(sound.category),
      quoteSql(soundUrl),
      quoteSql(sound.imageUrl),
      Number(sound.duration) || 'NULL',
      sound.isActive ? 'true' : 'false',
      'NOW()',
      'NOW()',
    ].join(', ');
  })
    .map((row) => `(${row})`)
    .join(',\n');

  return `
DELETE FROM sound_sessions WHERE "soundId" IN (SELECT id FROM ambient_sounds);
DELETE FROM ambient_sounds;
DELETE FROM search_indices WHERE "entityType" = 'AMBIENT_SOUND';

INSERT INTO ambient_sounds (id, title, description, category, "soundUrl", "imageUrl", duration, "isActive", "createdAt", "updatedAt")
VALUES
${values};

INSERT INTO search_indices (id, "entityType", "entityId", title, content, tags, "createdAt", "updatedAt")
SELECT
  'search-' || id,
  'AMBIENT_SOUND',
  id,
  title,
  concat_ws(' ', title, description, category, "soundUrl", duration || 's', 'active'),
  ARRAY['sound', 'ambient', lower(category), 'active'],
  NOW(),
  NOW()
FROM ambient_sounds;
`;
}

async function main() {
  loadEnv('apps/backend/.env');
  const workDir = fs.mkdtempSync(path.join(os.tmpdir(), 'ambient-sounds-'));

  try {
    if (process.env.SUPABASE_URL && process.env.SUPABASE_SECRET_KEY) {
      console.log(
        `→ Uploading ${AMBIENT_SOUND_CATALOG.length} curated MP3 files to Supabase Storage`,
      );
      let done = 0;
      for (const sound of AMBIENT_SOUND_CATALOG) {
        await upload(sound, workDir);
        done += 1;
        if (done % 10 === 0 || done === AMBIENT_SOUND_CATALOG.length) {
          console.log(`  ✓ ${done}/${AMBIENT_SOUND_CATALOG.length} files synced`);
        }
      }
    } else {
      console.log('→ Supabase env missing; DB will use Mixkit source URLs directly');
    }

    console.log(
      `→ Replacing ambient_sounds with ${AMBIENT_SOUND_CATALOG.length} curated tracks`,
    );
    execFileSync(
      'docker',
      [
        'exec',
        '-i',
        'digital-cigarette-postgres',
        'psql',
        '-U',
        'postgres',
        '-d',
        'digital_cigarette_break',
        '-v',
        'ON_ERROR_STOP=1',
        '-c',
        buildSql(),
      ],
      { stdio: 'inherit' },
    );
    console.log('✓ Done — Supabase Storage and ambient_sounds are synced.');
  } finally {
    fs.rmSync(workDir, { force: true, recursive: true });
  }
}

main().catch((error) => {
  console.error(error);
  process.exit(1);
});
NODE
