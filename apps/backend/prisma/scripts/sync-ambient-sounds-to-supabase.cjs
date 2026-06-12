#!/usr/bin/env node
// Uploads catalog audio files to Supabase Storage, then points AmbientSound
// records at the real public object URLs. This fixes the common seed-only
// problem where the DB has Supabase-looking URLs but the bucket has no files.

const path = require('node:path');
const fs = require('node:fs');
const os = require('node:os');
const process = require('node:process');
const { spawnSync } = require('node:child_process');
const { config: loadEnv } = require('dotenv');
const { PrismaClient } = require('@prisma/client');
const { createClient } = require('@supabase/supabase-js');
const {
  AMBIENT_SOUND_CATALOG,
} = require('../ambient-sounds.catalog.cjs');

const repoRoot = path.resolve(__dirname, '../../../..');
loadEnv({ path: path.join(repoRoot, '.env'), quiet: true });
loadEnv({ path: path.join(repoRoot, 'apps/backend/.env'), quiet: true });
loadEnv({ path: path.join(repoRoot, 'apps/backend/.env.local'), quiet: true });

const args = parseArgs(process.argv.slice(2));
const bucket = process.env.SUPABASE_BUCKET || 'public-assets';
const objectPrefix = trimSlashes(args.prefix || 'ambient-sounds');
const categoryFilter = args.category
  ? new Set(String(args.category).split(',').map((value) => value.trim().toUpperCase()))
  : undefined;
const limit = args.limit ? Number(args.limit) : undefined;
const dryRun = Boolean(args['dry-run']);
const force = Boolean(args.force);
const verifyOnly = Boolean(args['verify-only']);

main().catch(async (error) => {
  console.error(`\n[ambient-sync] failed: ${error.message}`);
  process.exitCode = 1;
});

async function main() {
  validateEnv();

  const prisma = new PrismaClient();
  const supabase = createClient(
    process.env.SUPABASE_URL,
    process.env.SUPABASE_SECRET_KEY,
    { auth: { persistSession: false } },
  );

  try {
    await ensureBucket(supabase);
    const existingPaths = await listExistingPaths(supabase);
    const catalog = AMBIENT_SOUND_CATALOG
      .filter((sound) => !categoryFilter || categoryFilter.has(sound.category))
      .slice(0, limit || undefined);

    const summary = {
      checked: catalog.length,
      uploaded: 0,
      skipped: 0,
      dbUpdated: 0,
      missing: 0,
      failed: 0,
    };

    for (const sound of catalog) {
      const objectPath = `${objectPrefix}/${sound.key}.mp3`;
      const publicUrl = getPublicUrl(supabase, objectPath);
      const objectExists = existingPaths.has(objectPath);

      if (verifyOnly) {
        const dbRecord = await prisma.ambientSound.findFirst({
          where: { title: sound.title },
          select: { id: true, soundUrl: true },
        });
        const ok = objectExists && dbRecord?.soundUrl === publicUrl;
        console.log(
          `${ok ? 'OK ' : 'MISS'} ${sound.category.padEnd(7)} ${sound.title} -> ${objectPath}`,
        );
        if (!ok) summary.missing += 1;
        continue;
      }

      if (!objectExists || force) {
        if (dryRun) {
          console.log(`[dry-run] upload ${sound.sourceUrl} -> ${objectPath}`);
        } else {
          await uploadSound(supabase, sound, objectPath);
        }
        summary.uploaded += 1;
      } else {
        summary.skipped += 1;
      }

      if (dryRun) {
        console.log(`[dry-run] update AmbientSound "${sound.title}" -> ${publicUrl}`);
      } else {
        await upsertAmbientSound(prisma, sound, publicUrl);
        await registerStorageFile(prisma, sound, objectPath, publicUrl);
      }
      summary.dbUpdated += 1;
    }

    console.log('\n[ambient-sync] summary');
    console.table(summary);
    console.log(`[ambient-sync] bucket: ${bucket}`);
    console.log(`[ambient-sync] prefix: ${objectPrefix}`);
  } finally {
    await prisma.$disconnect();
  }
}

function validateEnv() {
  const missing = ['DATABASE_URL', 'SUPABASE_URL', 'SUPABASE_SECRET_KEY'].filter(
    (key) => !process.env[key],
  );

  if (missing.length) {
    throw new Error(`Missing required env: ${missing.join(', ')}`);
  }
}

async function ensureBucket(supabase) {
  const { data, error } = await supabase.storage.getBucket(bucket);
  if (!error && data) return;

  const { error: createError } = await supabase.storage.createBucket(bucket, {
    public: true,
  });
  if (createError) {
    throw new Error(
      `Supabase bucket "${bucket}" is not ready: ${createError.message}`,
    );
  }
}

async function listExistingPaths(supabase) {
  const existingPaths = new Set();
  let offset = 0;
  const limit = 1000;

  while (true) {
    const { data, error } = await supabase.storage.from(bucket).list(objectPrefix, {
      limit,
      offset,
      sortBy: { column: 'name', order: 'asc' },
    });
    if (error) {
      throw new Error(`Cannot list ${bucket}/${objectPrefix}: ${error.message}`);
    }

    for (const item of data || []) {
      existingPaths.add(`${objectPrefix}/${item.name}`);
    }

    if (!data || data.length < limit) break;
    offset += limit;
  }

  return existingPaths;
}

async function uploadSound(supabase, sound, objectPath) {
  process.stdout.write(`upload ${sound.category.padEnd(7)} ${sound.title} ... `);
  const { body, contentType } = sound.sourceUrl.startsWith('generated:')
    ? generateAudio(sound)
    : await downloadAudio(sound);

  if (body.length < 1024) {
    throw new Error(`Downloaded file is too small for "${sound.title}"`);
  }

  const { error } = await supabase.storage.from(bucket).upload(objectPath, body, {
    contentType,
    upsert: true,
    cacheControl: '31536000',
  });
  if (error) {
    throw new Error(`Cannot upload ${objectPath}: ${error.message}`);
  }

  console.log(`${formatBytes(body.length)}`);
}

async function downloadAudio(sound) {
  const response = await fetch(sound.sourceUrl);
  if (!response.ok) {
    throw new Error(`Cannot download ${sound.sourceUrl}: HTTP ${response.status}`);
  }

  const contentType = response.headers.get('content-type') || 'audio/mpeg';
  if (!contentType.startsWith('audio/')) {
    throw new Error(
      `Source is not audio for "${sound.title}": ${contentType}`,
    );
  }

  return {
    body: Buffer.from(await response.arrayBuffer()),
    contentType,
  };
}

function generateAudio(sound) {
  const [, flavor, rawIndex] = sound.sourceUrl.split(':');
  const index = Number(String(rawIndex).match(/\d+$/)?.[0]) || 1;
  const isNotification = flavor === 'notification';
  const duration = isNotification
    ? Math.max(4, Math.min(Number(sound.duration) || 8, 15))
    : Math.max(45, Math.min(Number(sound.duration) || 90, 150));
  const base = isNotification
    ? 520 + (index % 8) * 45
    : flavor === 'buddha'
      ? 174 + (index % 5) * 13
      : flavor === 'podcast'
        ? 196 + (index % 6) * 11
        : 220 + (index % 7) * 9;
  const frequencies = isNotification
    ? [base, base * 1.5, base * 2, base * 3]
    : flavor === 'buddha'
      ? [base, base * 1.5, base * 2]
      : flavor === 'podcast'
        ? [base, base * 1.25, base * 1.5]
        : [base, base * 1.2, base * 1.5, base * 2];
  const outputPath = path.join(
    os.tmpdir(),
    `relax-${sound.key}-${Date.now()}-${process.pid}.mp3`,
  );
  const inputs = frequencies.flatMap((frequency) => [
    '-f',
    'lavfi',
    '-i',
    `sine=frequency=${Math.round(frequency)}:sample_rate=44100:duration=${duration}`,
  ]);
  const notifVol = isNotification ? '3.0' : '0.045';
  const notifVolSub = isNotification ? '1.8' : '0.028';
  const volumeFilters = frequencies
    .map((_, inputIndex) => `[${inputIndex}:a]volume=${inputIndex === 0 ? notifVol : notifVolSub}[a${inputIndex}]`)
    .join(';');
  const mixInputs = frequencies.map((_, inputIndex) => `[a${inputIndex}]`).join('');
  const echo = isNotification
    ? ',aecho=0.8:0.5:180:0.25'
    : flavor === 'lofi' ? ',aecho=0.6:0.35:420:0.18' : '';
  const fadeIn = isNotification ? 0.3 : 2;
  const fadeOut = isNotification ? 1.5 : 4;
  const filter = `${volumeFilters};${mixInputs}amix=inputs=${frequencies.length}:duration=longest,lowpass=f=${isNotification ? 3200 : 1800}${echo},afade=t=in:st=0:d=${fadeIn},afade=t=out:st=${Math.max(0, duration - fadeOut)}:d=${fadeOut}`;
  const result = spawnSync(
    'ffmpeg',
    [
      '-y',
      '-hide_banner',
      '-loglevel',
      'error',
      ...inputs,
      '-filter_complex',
      filter,
      '-codec:a',
      'libmp3lame',
      '-b:a',
      '128k',
      outputPath,
    ],
    { encoding: 'utf8' },
  );

  if (result.status !== 0) {
    throw new Error(
      `Cannot generate audio for "${sound.title}": ${result.stderr || 'ffmpeg failed'}`,
    );
  }

  try {
    return {
      body: fs.readFileSync(outputPath),
      contentType: 'audio/mpeg',
    };
  } finally {
    fs.rmSync(outputPath, { force: true });
  }
}

async function upsertAmbientSound(prisma, sound, publicUrl) {
  const data = {
    title: sound.title,
    description: sound.description,
    category: sound.category,
    soundUrl: publicUrl,
    imageUrl: sound.imageUrl,
    duration: sound.duration,
    isActive: sound.isActive,
  };
  const existing = await prisma.ambientSound.findFirst({
    where: { title: sound.title },
    select: { id: true },
  });

  if (existing) {
    await prisma.ambientSound.update({ where: { id: existing.id }, data });
    return;
  }

  await prisma.ambientSound.create({ data });
}

async function registerStorageFile(prisma, sound, objectPath, publicUrl) {
  await prisma.storageFile.deleteMany({
    where: {
      provider: 'supabase',
      bucket,
      path: objectPath,
    },
  });

  await prisma.storageFile.create({
    data: {
      filename: `${sound.key}.mp3`,
      mimetype: 'audio/mpeg',
      size: 0,
      provider: 'supabase',
      bucket,
      path: objectPath,
      url: publicUrl,
      publicUrl,
      isPublic: true,
      metadata: {
        domain: 'ambient-sound-sync',
        category: sound.category,
        title: sound.title,
        sourceUrl: sound.sourceUrl,
      },
    },
  });
}

function getPublicUrl(supabase, objectPath) {
  return supabase.storage.from(bucket).getPublicUrl(objectPath).data.publicUrl;
}

function parseArgs(argv) {
  return Object.fromEntries(
    argv.map((arg) => {
      if (!arg.startsWith('--')) return [arg, true];
      const [key, ...rest] = arg.slice(2).split('=');
      return [key, rest.length ? rest.join('=') : true];
    }),
  );
}

function trimSlashes(value) {
  return String(value || '').replace(/^\/+|\/+$/g, '');
}

function formatBytes(bytes) {
  if (bytes < 1024 * 1024) return `${Math.round(bytes / 1024)} KB`;
  return `${(bytes / 1024 / 1024).toFixed(1)} MB`;
}
