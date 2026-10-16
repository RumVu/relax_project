const { execFileSync } = require('node:child_process');
const path = require('node:path');

const port = process.env.PORT || '6823';
// The port is interpolated into shell commands below — accept digits only.
if (!/^\d{1,5}$/.test(port)) {
  console.error(`Invalid port "${port}"; expected a number.`);
  process.exit(1);
}
const backendDir = path.resolve(__dirname, '..');
const ancestorPids = new Set();

let currentPid = process.pid;
while (currentPid && !ancestorPids.has(currentPid)) {
  ancestorPids.add(currentPid);
  const ppid = Number(
    run('ps', ['-o', 'ppid=', '-p', String(currentPid)]).trim(),
  );
  currentPid = Number.isFinite(ppid) ? ppid : 0;
}

function killPid(pid, reason) {
  if (!pid || ancestorPids.has(pid)) {
    return;
  }

  const command = commandForPid(pid);
  if (isDockerProcess(command)) {
    console.error(
      `Port ${port} is owned by Docker Desktop; not killing PID ${pid}. ` +
        'Stop the compose backend first (`docker compose stop backend`) or use a different PORT.',
    );
    process.exitCode = 1;
    return;
  }

  try {
    process.kill(pid, 'SIGKILL');
    console.log(`Freed backend dev process ${pid} (${reason})`);
  } catch {
    // The process may already have exited.
  }
}

// execFileSync (no shell) — arguments are never parsed by sh, so env-derived
// values like the port can't inject commands. Non-zero exits (e.g. lsof with
// no matches) just yield empty output.
function run(file, args) {
  try {
    return execFileSync(file, args, {
      encoding: 'utf8',
      stdio: ['ignore', 'pipe', 'ignore'],
    });
  } catch (err) {
    return typeof err.stdout === 'string' ? err.stdout : '';
  }
}

function list(file, args) {
  return run(file, args)
    .split('\n')
    .map((line) => line.trim())
    .filter(Boolean);
}

function commandForPid(pid) {
  try {
    return run('ps', ['-o', 'command=', '-p', String(pid)]).trim();
  } catch {
    return '';
  }
}

function isDockerProcess(command) {
  return command.includes('/Docker.app/') || command.includes('com.docker.');
}

for (const line of list('lsof', ['-ti', `tcp:${port}`])) {
  killPid(Number(line), `port ${port}`);
}

if (process.exitCode) {
  process.exit(process.exitCode);
}

for (const line of list('ps', ['-ax', '-o', 'pid=,command='])) {
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
