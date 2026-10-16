#!/usr/bin/env node

import fs from 'fs';
import path from 'path';
import { fileURLToPath } from 'url';

const __filename = fileURLToPath(import.meta.url);
const __dirname = path.dirname(__filename);
const rootDir = path.resolve(__dirname, '..');

const versionArg = process.argv[2];

if (!versionArg) {
  console.error('Usage: node scripts/release-version.mjs <version>');
  console.error('Example: node scripts/release-version.mjs 1.2.0-rc.2');
  process.exit(1);
}

// Clean version representation (without +buildNumber if any)
let semVer = versionArg;
let buildNumber = '1';

if (versionArg.includes('+')) {
  const parts = versionArg.split('+');
  semVer = parts[0];
  buildNumber = parts[1];
}

console.log(`Synchronizing version to: ${semVer} (Build: ${buildNumber})`);

// Read + transform + write in one pass. Reading directly (instead of an
// existsSync() check first) avoids a check-then-use race on the file.
function updateFile(relPath, transform) {
  const filePath = path.join(rootDir, relPath);
  let content;
  try {
    content = fs.readFileSync(filePath, 'utf8');
  } catch (err) {
    if (err.code === 'ENOENT') return;
    throw err;
  }
  const updated = transform(content);
  if (updated !== null) fs.writeFileSync(filePath, updated, 'utf8');
}

function setPackageVersion(content) {
  const pkg = JSON.parse(content);
  pkg.version = semVer;
  return JSON.stringify(pkg, null, 2) + '\n';
}

// 1-3. Update package.json files
for (const relPath of [
  'package.json',
  'apps/backend/package.json',
  'apps/web/package.json',
]) {
  updateFile(relPath, (content) => {
    const updated = setPackageVersion(content);
    console.log(`✓ Updated ${relPath} version to ${semVer}`);
    return updated;
  });
}

// 4. Update apps/mobile/relax_app/pubspec.yaml
updateFile('apps/mobile/relax_app/pubspec.yaml', (pubspec) => {
  // Find line: version: x.y.z+n or version: x.y.z-rc.a+n
  const versionRegex = /^version:\s*(.+)$/m;
  if (!versionRegex.test(pubspec)) {
    console.warn(`✗ Could not find 'version:' line in pubspec.yaml`);
    return null;
  }
  const newVersionString = `${semVer}+${buildNumber}`;
  console.log(
    `✓ Updated apps/mobile/relax_app/pubspec.yaml version to ${newVersionString}`,
  );
  return pubspec.replace(versionRegex, `version: ${newVersionString}`);
});

console.log('✓ All versions synchronized successfully.');
