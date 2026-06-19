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

// 1. Update root package.json
const rootPkgPath = path.join(rootDir, 'package.json');
if (fs.existsSync(rootPkgPath)) {
  const pkg = JSON.parse(fs.readFileSync(rootPkgPath, 'utf8'));
  pkg.version = semVer;
  fs.writeFileSync(rootPkgPath, JSON.stringify(pkg, null, 2) + '\n', 'utf8');
  console.log(`✓ Updated root package.json version to ${semVer}`);
}

// 2. Update apps/backend/package.json
const backendPkgPath = path.join(rootDir, 'apps/backend/package.json');
if (fs.existsSync(backendPkgPath)) {
  const pkg = JSON.parse(fs.readFileSync(backendPkgPath, 'utf8'));
  pkg.version = semVer;
  fs.writeFileSync(backendPkgPath, JSON.stringify(pkg, null, 2) + '\n', 'utf8');
  console.log(`✓ Updated apps/backend/package.json version to ${semVer}`);
}

// 3. Update apps/web/package.json
const webPkgPath = path.join(rootDir, 'apps/web/package.json');
if (fs.existsSync(webPkgPath)) {
  const pkg = JSON.parse(fs.readFileSync(webPkgPath, 'utf8'));
  pkg.version = semVer;
  fs.writeFileSync(webPkgPath, JSON.stringify(pkg, null, 2) + '\n', 'utf8');
  console.log(`✓ Updated apps/web/package.json version to ${semVer}`);
}

// 4. Update apps/mobile/relax_app/pubspec.yaml
const pubspecPath = path.join(rootDir, 'apps/mobile/relax_app/pubspec.yaml');
if (fs.existsSync(pubspecPath)) {
  let pubspec = fs.readFileSync(pubspecPath, 'utf8');
  
  // Find line: version: x.y.z+n or version: x.y.z-rc.a+n
  const versionRegex = /^version:\s*(.+)$/m;
  const match = pubspec.match(versionRegex);
  
  if (match) {
    const newVersionString = `${semVer}+${buildNumber}`;
    pubspec = pubspec.replace(versionRegex, `version: ${newVersionString}`);
    fs.writeFileSync(pubspecPath, pubspec, 'utf8');
    console.log(`✓ Updated apps/mobile/relax_app/pubspec.yaml version to ${newVersionString}`);
  } else {
    console.warn(`✗ Could not find 'version:' line in pubspec.yaml`);
  }
}

console.log('✓ All versions synchronized successfully.');
