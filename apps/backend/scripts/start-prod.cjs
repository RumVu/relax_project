#!/usr/bin/env node
'use strict';

const { spawnSync } = require('node:child_process');
const path = require('node:path');

const backendDir = path.resolve(__dirname, '..');
const rootDir = path.resolve(backendDir, '..', '..');
const shouldRunMigrations =
  String(process.env.RUN_MIGRATIONS_ON_START ?? '').toLowerCase() === 'true';

function run(command, args, options = {}) {
  const result = spawnSync(command, args, {
    cwd: options.cwd ?? backendDir,
    env: process.env,
    stdio: 'inherit',
    shell: process.platform === 'win32',
  });

  if (result.error) {
    console.error(result.error);
    process.exit(1);
  }

  if (result.status !== 0) {
    process.exit(result.status ?? 1);
  }
}

if (shouldRunMigrations) {
  console.log(
    '[startup] RUN_MIGRATIONS_ON_START=true, applying Prisma migrations...',
  );
  run(
    'npx',
    [
      '--no-install',
      'prisma',
      'migrate',
      'deploy',
      '--schema',
      path.join(backendDir, 'prisma', 'schema.prisma'),
    ],
    { cwd: rootDir },
  );
}

console.log('[startup] Starting NestJS backend...');
run(process.execPath, [
  '--enable-source-maps',
  path.join(backendDir, 'dist', 'src', 'main.js'),
]);
