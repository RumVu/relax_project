#!/usr/bin/env bash
# =============================================================================
# db-restore.sh — Restore a PostgreSQL backup created by db-backup.sh
#
# Usage:
#   ./scripts/db-restore.sh                           # pick from list
#   ./scripts/db-restore.sh backups/backup_xxx.sql.gz # restore specific file
#
# WARNING: This DROPS and recreates all tables. Data in the current database
#          will be lost. A safety backup is created automatically before restore.
# =============================================================================
set -euo pipefail

# ---- Config -----------------------------------------------------------------
CONTAINER="${POSTGRES_CONTAINER:-digital-cigarette-postgres}"
DB_USER="${POSTGRES_USER:-postgres}"
DB_NAME="${POSTGRES_DB:-digital_cigarette_break}"
BACKUP_DIR="${BACKUP_DIR:-$(cd "$(dirname "$0")/.." && pwd)/backups}"

# ---- Helpers ----------------------------------------------------------------
RED='\033[0;31m'; GREEN='\033[0;32m'; YELLOW='\033[1;33m'; CYAN='\033[0;36m'; NC='\033[0m'
info()  { echo -e "${GREEN}[restore]${NC} $*"; }
warn()  { echo -e "${YELLOW}[restore]${NC} $*"; }
fail()  { echo -e "${RED}[restore]${NC} $*" >&2; exit 1; }

# ---- Pre-flight -------------------------------------------------------------
if ! docker ps --format '{{.Names}}' | grep -q "^${CONTAINER}$"; then
  fail "Postgres container '${CONTAINER}' is not running. Start it first: make infra-up"
fi

# ---- Select backup file -----------------------------------------------------
BACKUP_FILE="${1:-}"

if [ -z "${BACKUP_FILE}" ]; then
  echo ""
  echo -e "${CYAN}Available backups:${NC}"
  echo ""

  BACKUPS=()
  while IFS= read -r f; do
    BACKUPS+=("$f")
  done < <(ls -1t "${BACKUP_DIR}"/backup_*.sql.gz 2>/dev/null)

  if [ ${#BACKUPS[@]} -eq 0 ]; then
    fail "No backups found in ${BACKUP_DIR}. Run 'make db-backup' first."
  fi

  for i in "${!BACKUPS[@]}"; do
    FILE="$(basename "${BACKUPS[$i]}")"
    SIZE="$(du -h "${BACKUPS[$i]}" | cut -f1)"
    META="${BACKUPS[$i]%.sql.gz}.meta.json"
    MIGRATION=""
    if [ -f "${META}" ]; then
      MIGRATION=" (migration: $(python3 -c "import json; print(json.load(open('${META}'))['migration_version'])" 2>/dev/null || echo '?'))"
    fi
    echo -e "  ${CYAN}[$((i+1))]${NC} ${FILE}  ${SIZE}${MIGRATION}"
  done

  echo ""
  read -rp "Select backup to restore [1-${#BACKUPS[@]}]: " CHOICE

  if ! [[ "${CHOICE}" =~ ^[0-9]+$ ]] || [ "${CHOICE}" -lt 1 ] || [ "${CHOICE}" -gt "${#BACKUPS[@]}" ]; then
    fail "Invalid selection."
  fi

  BACKUP_FILE="${BACKUPS[$((CHOICE-1))]}"
fi

if [ ! -f "${BACKUP_FILE}" ]; then
  fail "Backup file not found: ${BACKUP_FILE}"
fi

# ---- Confirmation -----------------------------------------------------------
echo ""
warn "THIS WILL DROP AND REPLACE ALL DATA in database '${DB_NAME}'."
warn "File: $(basename "${BACKUP_FILE}")"
echo ""
read -rp "Type 'yes' to confirm: " CONFIRM
if [ "${CONFIRM}" != "yes" ]; then
  info "Aborted."
  exit 0
fi

# ---- Safety backup before restore ------------------------------------------
info "Creating safety backup before restore..."
SAFETY_FILE="${BACKUP_DIR}/pre-restore_$(date +%Y%m%d_%H%M%S).sql.gz"
docker exec "${CONTAINER}" \
  pg_dump -U "${DB_USER}" -d "${DB_NAME}" \
    --no-owner --no-privileges --clean --if-exists --format=plain \
  | gzip > "${SAFETY_FILE}"
info "Safety backup saved: ${SAFETY_FILE}"

# ---- Restore ----------------------------------------------------------------
info "Restoring from: $(basename "${BACKUP_FILE}")..."

# Terminate other connections
docker exec "${CONTAINER}" psql -U "${DB_USER}" -d postgres -c \
  "SELECT pg_terminate_backend(pid) FROM pg_stat_activity WHERE datname = '${DB_NAME}' AND pid <> pg_backend_pid();" \
  > /dev/null 2>&1 || true

# Restore — capture psql exit code through the pipe
RESTORE_LOG=$(mktemp)
gunzip -c "${BACKUP_FILE}" | docker exec -i "${CONTAINER}" \
  psql -U "${DB_USER}" -d "${DB_NAME}" --single-transaction -q 2>&1 \
  | grep -v "^NOTICE:" | grep -v "^SET$" | grep -v "^DROP " | grep -v "^ALTER " | grep -v "^CREATE " \
  > "${RESTORE_LOG}" 2>&1
RESTORE_EXIT=${PIPESTATUS[1]}

if [ "${RESTORE_EXIT}" -ne 0 ]; then
  warn "psql restore failed (exit code ${RESTORE_EXIT}):"
  cat "${RESTORE_LOG}" >&2
  rm -f "${RESTORE_LOG}"
  exit 1
fi
rm -f "${RESTORE_LOG}"

info "Database restored successfully!"

# ---- Post-restore: verify migration state -----------------------------------
info "Verifying migration state..."
APPLIED_MIGRATIONS=$(docker exec "${CONTAINER}" psql -U "${DB_USER}" -d "${DB_NAME}" -t -c \
  "SELECT COUNT(*) FROM _prisma_migrations WHERE finished_at IS NOT NULL;" 2>/dev/null | tr -d ' ')
LATEST_MIGRATION=$(docker exec "${CONTAINER}" psql -U "${DB_USER}" -d "${DB_NAME}" -t -c \
  "SELECT migration_name FROM _prisma_migrations ORDER BY finished_at DESC LIMIT 1;" 2>/dev/null | tr -d ' ')

echo ""
echo "========================================"
echo "  Restore complete"
echo "  Source:     $(basename "${BACKUP_FILE}")"
echo "  Safety:     $(basename "${SAFETY_FILE}")"
echo "  Migrations: ${APPLIED_MIGRATIONS} applied"
echo "  Latest:     ${LATEST_MIGRATION}"
echo "========================================"
echo ""
info "Tip: If the schema version doesn't match your code, run:"
info "  make prisma-migrate"
