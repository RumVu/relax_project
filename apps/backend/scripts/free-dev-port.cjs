const { execSync } = require('node:child_process');
const path = require('node:path');

const port = process.env.PORT || '6823';
const backendDir = path.resolve(__dirname, '..');
const ancestorPids = new Set();

let currentPid = process.pid;
while (currentPid && !ancestorPids.has(currentPid)) {
  ancestorPids.add(currentPid);
  const ppid = Number(
    execSync(`ps -o ppid= -p ${currentPid} 2>/dev/null || true`, {
      encoding: 'utf8',
    }).trim(),
  );
  currentPid = Number.isFinite(ppid) ? ppid : 0;
}

function killPid(pid, reason) {
  if (!pid || ancestorPids.has(pid)) {
    return;
  }

  try {
    process.kill(pid, 'SIGKILL');
    console.log(`Freed backend dev process ${pid} (${reason})`);
  } catch {
    // The process may already have exited.
  }
}

function list(command) {
  try {
    return execSync(command, { encoding: 'utf8' })
      .split('\n')
      .map((line) => line.trim())
      .filter(Boolean);
  } catch {
    return [];
  }
}

for (const line of list(`lsof -ti tcp:${port} 2>/dev/null || true`)) {
  killPid(Number(line), `port ${port}`);
}

for (const line of list(`ps -ax -o pid=,command= 2>/dev/null || true`)) {
  const match = line.match(/^(\d+)\s+(.+)$/);
  if (!match) {
    continue;
  }

  const pid = Number(match[1]);
  const command = match[2];
  const isBackendCommand = command.includes(backendDir);
  const isDevRunner =
    command.includes('nest start --watch') ||
    command.includes('node --enable-source-maps') ||
    command.includes(`${path.sep}dist${path.sep}main`);

  if (isBackendCommand && isDevRunner) {
    killPid(pid, 'old backend watcher');
  }
}
