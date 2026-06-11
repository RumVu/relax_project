#!/usr/bin/env bash
# =============================================================================
# db-snapshot.sh — Quick named snapshot for before/after comparisons
#
# Usage:
#   ./scripts/db-snapshot.sh before-feature-x    # save snapshot
#   ./scripts/db-snapshot.sh after-feature-x     # save another
#   ./scripts/db-snapshot.sh --list              # list all snapshots
#   ./scripts/db-snapshot.sh --diff before after  # compare two snapshots (schema)
#
# Snapshots are lightweight: schema-only by default, with optional data.
# =============================================================================
set -euo pipefail

CONTAINER="${POSTGRES_CONTAINER:-digital-cigarette-postgres}"
DB_USER="${POSTGRES_USER:-postgres}"
DB_NAME="${POSTGRES_DB:-digital_cigarette_break}"
SNAPSHOT_DIR="${SNAPSHOT_DIR:-$(cd "$(dirname "$0")/.." && pwd)/backups/snapshots}"

RED='\033[0;31m'; GREEN='\033[0;32m'; YELLOW='\033[1;33m'; CYAN='\033[0;36m'; NC='\033[0m'
info()  { echo -e "${GREEN}[snapshot]${NC} $*"; }
fail()  { echo -e "${RED}[snapshot]${NC} $*" >&2; exit 1; }

mkdir -p "${SNAPSHOT_DIR}"

# ---- Commands ---------------------------------------------------------------

cmd_list() {
  echo -e "${CYAN}Snapshots:${NC}"
  echo ""
  shopt -s nullglob
  local found=0
  for f in "${SNAPSHOT_DIR}"/*.schema.sql; do
    found=1
    NAME="$(basename "$f" .schema.sql)"
    TABLES=$(grep -c "^CREATE TABLE" "$f" 2>/dev/null || echo "?")
    TIME=$(stat -f "%Sm" -t "%Y-%m-%d %H:%M" "$f" 2>/dev/null || stat -c "%y" "$f" 2>/dev/null | cut -d. -f1)
    DATA=""
    [ -f "${SNAPSHOT_DIR}/${NAME}.data.sql.gz" ] && DATA=" + data"
    echo -e "  ${CYAN}${NAME}${NC}  (${TABLES} tables, ${TIME})${DATA}"
  done
  shopt -u nullglob
  [ "$found" -eq 0 ] && echo "  (no snapshots yet)"
  echo ""
}

cmd_diff() {
  local A="${1:-}" B="${2:-}"
  [ -z "$A" ] || [ -z "$B" ] && fail "Usage: db-snapshot.sh --diff <name-a> <name-b>"
  local FA="${SNAPSHOT_DIR}/${A}.schema.sql"
  local FB="${SNAPSHOT_DIR}/${B}.schema.sql"
  [ -f "$FA" ] || fail "Snapshot '${A}' not found"
  [ -f "$FB" ] || fail "Snapshot '${B}' not found"

  echo -e "${CYAN}Schema diff: ${A} → ${B}${NC}"
  echo ""
  diff --color=auto -u "$FA" "$FB" || true
}

cmd_snapshot() {
  local NAME="${1:-}"
  [ -z "$NAME" ] && fail "Usage: db-snapshot.sh <name> [--with-data]"
  local WITH_DATA="${2:-}"

  if ! docker ps --format '{{.Names}}' | grep -q "^${CONTAINER}$"; then
    fail "Postgres container '${CONTAINER}' is not running."
  fi

  # Schema snapshot
  info "Taking schema snapshot '${NAME}'..."
  docker exec "${CONTAINER}" \
    pg_dump -U "${DB_USER}" -d "${DB_NAME}" --schema-only --no-owner --no-privileges \
    > "${SNAPSHOT_DIR}/${NAME}.schema.sql"

  # Migration version
  MIGRATION_VERSION=$(docker exec "${CONTAINER}" psql -U "${DB_USER}" -d "${DB_NAME}" -t -c \
    "SELECT migration_name FROM _prisma_migrations ORDER BY finished_at DESC LIMIT 1;" 2>/dev/null | tr -d ' ')
  echo "${MIGRATION_VERSION}" > "${SNAPSHOT_DIR}/${NAME}.migration"

  # Table counts
  docker exec "${CONTAINER}" psql -U "${DB_USER}" -d "${DB_NAME}" -t -c \
    "SELECT tablename || ': ' || (SELECT count(*) FROM \"public\".\"\" || tablename || \"\") FROM pg_tables WHERE schemaname = 'public' ORDER BY tablename;" \
    > /dev/null 2>&1 || true

  # Row counts
  docker exec "${CONTAINER}" psql -U "${DB_USER}" -d "${DB_NAME}" -t --csv -c \
    "SELECT schemaname||'.'||relname AS table, n_live_tup AS rows FROM pg_stat_user_tables ORDER BY n_live_tup DESC;" \
    > "${SNAPSHOT_DIR}/${NAME}.rowcounts.csv" 2>/dev/null || true

  # Optional: full data dump
  if [ "${WITH_DATA}" = "--with-data" ]; then
    info "Including data dump..."
    docker exec "${CONTAINER}" \
      pg_dump -U "${DB_USER}" -d "${DB_NAME}" --no-owner --no-privileges --clean --if-exists --format=plain \
      | gzip > "${SNAPSHOT_DIR}/${NAME}.data.sql.gz"
    DATA_SIZE="$(du -h "${SNAPSHOT_DIR}/${NAME}.data.sql.gz" | cut -f1)"
    info "Data: ${DATA_SIZE}"
  fi

  TABLES=$(grep -c "^CREATE TABLE" "${SNAPSHOT_DIR}/${NAME}.schema.sql" 2>/dev/null || echo "?")
  info "Snapshot '${NAME}' saved (${TABLES} tables, migration: ${MIGRATION_VERSION})"
}

# ---- Router -----------------------------------------------------------------
case "${1:-}" in
  --list|-l)   cmd_list ;;
  --diff|-d)   cmd_diff "${2:-}" "${3:-}" ;;
  --help|-h)
    echo "Usage:"
    echo "  db-snapshot.sh <name> [--with-data]   Create snapshot"
    echo "  db-snapshot.sh --list                  List snapshots"
    echo "  db-snapshot.sh --diff <a> <b>          Diff two schema snapshots"
    ;;
  *)           cmd_snapshot "$@" ;;
esac
