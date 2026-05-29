/**
 * Frees the Next.js dev port before `next dev` boots.
 *
 * Mirrors apps/backend/scripts/free-dev-port.cjs so `npm run dev` in
 * apps/web is just-works even when an old dev server is still holding
 * the port. The previous behaviour bombed with
 *     EADDRINUSE :::3233
 * and forced the developer to find & kill the stray PID by hand.
 */
const { execSync } = require('node:child_process');
const path = require('node:path');

const port = process.env.WEB_PORT || process.env.PORT || '3233';
const webDir = path.resolve(__dirname, '..');
const ancestorPids = new Set();

// Walk up our own process tree so we don't accidentally kill the shell
// that invoked `npm run dev`.
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
    console.log(`Freed web dev process ${pid} (${reason})`);
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

// 1. Whoever is bound to the port gets killed first.
for (const line of list(`lsof -ti tcp:${port} 2>/dev/null || true`)) {
  killPid(Number(line), `port ${port}`);
}

// 2. Sweep any stale `next dev` / `next-server` from THIS workspace
//    that survived a `pkill -f` or whatever happened previously.
for (const line of list(`ps -ax -o pid=,command= 2>/dev/null || true`)) {
  const match = line.match(/^(\d+)\s+(.+)$/);
  if (!match) {
    continue;
  }

  const pid = Number(match[1]);
  const command = match[2];
  const isOurWorkspace = command.includes(webDir);
  const isDevRunner =
    /next(?:-server)? dev/.test(command) ||
    command.includes('next/dist/server/lib/start-server.js');

  if (isOurWorkspace && isDevRunner) {
    killPid(pid, 'old next-dev watcher');
  }
}
