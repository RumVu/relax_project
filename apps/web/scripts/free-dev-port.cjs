/**
 * Frees the Next.js dev port before `next dev` boots.
 *
 * Mirrors apps/backend/scripts/free-dev-port.cjs so `npm run dev` in
 * apps/web is just-works even when an old dev server is still holding
 * the port. The previous behaviour bombed with
 *     EADDRINUSE :::3233
 * and forced the developer to find & kill the stray PID by hand.
 */
const { execFileSync } = require("node:child_process");
const path = require("node:path");

const port = process.env.WEB_PORT || process.env.PORT || "3233";
// The port is interpolated into shell commands below — accept digits only.
if (!/^\d{1,5}$/.test(port)) {
  console.error(`Invalid port "${port}"; expected a number.`);
  process.exit(1);
}
const webDir = path.resolve(__dirname, "..");
const ancestorPids = new Set();

// Walk up our own process tree so we don't accidentally kill the shell
// that invoked `npm run dev`.
let currentPid = process.pid;
while (currentPid && !ancestorPids.has(currentPid)) {
  ancestorPids.add(currentPid);
  const ppid = Number(
    run("ps", ["-o", "ppid=", "-p", String(currentPid)]).trim(),
  );
  currentPid = Number.isFinite(ppid) ? ppid : 0;
}

function killPid(pid, reason) {
  if (!pid || ancestorPids.has(pid)) {
    return;
  }

  try {
    process.kill(pid, "SIGKILL");
    console.log(`Freed web dev process ${pid} (${reason})`);
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
      encoding: "utf8",
      stdio: ["ignore", "pipe", "ignore"],
    });
  } catch (err) {
    return typeof err.stdout === "string" ? err.stdout : "";
  }
}

function list(file, args) {
  return run(file, args)
    .split("\n")
    .map((line) => line.trim())
    .filter(Boolean);
}

// 1. Whoever is bound to the port gets killed first.
for (const line of list("lsof", ["-ti", `tcp:${port}`])) {
  killPid(Number(line), `port ${port}`);
}

// 2. Sweep any stale `next dev` / `next-server` from THIS workspace
//    that survived a `pkill -f` or whatever happened previously.
for (const line of list("ps", ["-ax", "-o", "pid=,command="])) {
  const match = line.match(/^(\d+)\s+(.+)$/);
  if (!match) {
    continue;
  }

  const pid = Number(match[1]);
  const command = match[2];
  const isOurWorkspace = command.includes(webDir);
  const isDevRunner =
    /next(?:-server)? dev/.test(command) ||
    command.includes("next/dist/server/lib/start-server.js");

  if (isOurWorkspace && isDevRunner) {
    killPid(pid, "old next-dev watcher");
  }
}
