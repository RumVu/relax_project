#!/usr/bin/env bash
# =============================================================================
# db-backup.sh — Create a timestamped PostgreSQL backup (pg_dump)
#
# Usage:
#   ./scripts/db-backup.sh              # backup with auto-generated name
#   ./scripts/db-backup.sh my-tag       # backup with custom tag in filename
#   BACKUP_DIR=~/my-backups ./scripts/db-backup.sh   # custom output dir
#
# The script connects to the Postgres container via docker exec.
# Output: compressed .sql.gz file in backups/ (git-ignored).
# =============================================================================
set -euo pipefail

# ---- Config (overridable via env) -------------------------------------------
CONTAINER="${POSTGRES_CONTAINER:-digital-cigarette-postgres}"
DB_USER="${POSTGRES_USER:-postgres}"
DB_NAME="${POSTGRES_DB:-digital_cigarette_break}"
BACKUP_DIR="${BACKUP_DIR:-$(cd "$(dirname "$0")/.." && pwd)/backups}"
KEEP_LAST="${KEEP_LAST:-10}"  # auto-prune: keep only the N most recent backups

# ---- Helpers ----------------------------------------------------------------
RED='\033[0;31m'; GREEN='\033[0;32m'; YELLOW='\033[1;33m'; NC='\033[0m'
info()  { echo -e "${GREEN}[backup]${NC} $*"; }
warn()  { echo -e "${YELLOW}[backup]${NC} $*"; }
fail()  { echo -e "${RED}[backup]${NC} $*" >&2; exit 1; }

# ---- Pre-flight checks -----------------------------------------------------
if ! docker ps --format '{{.Names}}' | grep -q "^${CONTAINER}$"; then
  fail "Postgres container '${CONTAINER}' is not running. Start it first: make infra-up"
fi

mkdir -p "${BACKUP_DIR}"

# ---- Build filename ---------------------------------------------------------
TAG="${1:-}"
TIMESTAMP="$(date +%Y%m%d_%H%M%S)"
MIGRATION_VERSION="$(ls -1 "$(dirname "$0")/../apps/backend/prisma/migrations" 2>/dev/null \
  | grep -E '^[0-9]+' | sort | tail -1 | cut -d_ -f1 || echo 'unknown')"

if [ -n "${TAG}" ]; then
  FILENAME="backup_${TIMESTAMP}_v${MIGRATION_VERSION}_${TAG}.sql.gz"
else
  FILENAME="backup_${TIMESTAMP}_v${MIGRATION_VERSION}.sql.gz"
fi

FILEPATH="${BACKUP_DIR}/${FILENAME}"

# ---- Dump -------------------------------------------------------------------
info "Dumping database '${DB_NAME}' from container '${CONTAINER}'..."
info "Migration version: ${MIGRATION_VERSION}"

docker exec "${CONTAINER}" \
  pg_dump -U "${DB_USER}" -d "${DB_NAME}" \
    --no-owner --no-privileges --clean --if-exists \
    --format=plain \
  | gzip > "${FILEPATH}"

SIZE="$(du -h "${FILEPATH}" | cut -f1)"
info "Backup saved: ${FILEPATH} (${SIZE})"

# ---- Write metadata ---------------------------------------------------------
META="${FILEPATH%.sql.gz}.meta.json"
cat > "${META}" <<METAJSON
{
  "timestamp": "${TIMESTAMP}",
  "database": "${DB_NAME}",
  "migration_version": "${MIGRATION_VERSION}",
  "container": "${CONTAINER}",
  "file": "${FILENAME}",
  "size": "${SIZE}",
  "hostname": "$(hostname)",
  "created_by": "$(whoami)"
}
METAJSON
info "Metadata: ${META}"

# ---- Auto-prune old backups -------------------------------------------------
BACKUP_COUNT=$(ls -1 "${BACKUP_DIR}"/backup_*.sql.gz 2>/dev/null | wc -l | tr -d ' ')
if [ "${BACKUP_COUNT}" -gt "${KEEP_LAST}" ]; then
  PRUNE_COUNT=$((BACKUP_COUNT - KEEP_LAST))
  info "Pruning ${PRUNE_COUNT} old backup(s) (keeping last ${KEEP_LAST})..."
  ls -1t "${BACKUP_DIR}"/backup_*.sql.gz | tail -n "${PRUNE_COUNT}" | while read -r old; do
    rm -f "${old}" "${old%.sql.gz}.meta.json"
    info "  removed: $(basename "${old}")"
  done
fi

# ---- Summary ----------------------------------------------------------------
echo ""
echo "========================================"
echo "  Backup complete"
echo "  File: ${FILENAME}"
echo "  Size: ${SIZE}"
echo "  Migration: ${MIGRATION_VERSION}"
echo "  Dir:  ${BACKUP_DIR}"
echo "========================================"
