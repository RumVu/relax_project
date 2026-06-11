#!/usr/bin/env bash
# =============================================================================
# db-version.sh — Show current database version, migration status & health
#
# Usage:
#   ./scripts/db-version.sh            # full status
#   ./scripts/db-version.sh --json     # machine-readable output
# =============================================================================
set -euo pipefail

CONTAINER="${POSTGRES_CONTAINER:-digital-cigarette-postgres}"
DB_USER="${POSTGRES_USER:-postgres}"
DB_NAME="${POSTGRES_DB:-digital_cigarette_break}"

RED='\033[0;31m'; GREEN='\033[0;32m'; YELLOW='\033[1;33m'; CYAN='\033[0;36m'; NC='\033[0m'

# ---- Pre-flight -------------------------------------------------------------
if ! docker ps --format '{{.Names}}' | grep -q "^${CONTAINER}$"; then
  echo -e "${RED}[db-version]${NC} Postgres container '${CONTAINER}' is not running." >&2
  exit 1
fi

# ---- Gather info ------------------------------------------------------------
PG_VERSION=$(docker exec "${CONTAINER}" psql -U "${DB_USER}" -d "${DB_NAME}" -t -c \
  "SELECT version();" 2>/dev/null | xargs)

MIGRATION_COUNT=$(docker exec "${CONTAINER}" psql -U "${DB_USER}" -d "${DB_NAME}" -t -c \
  "SELECT COUNT(*) FROM _prisma_migrations;" 2>/dev/null | tr -d ' ')

LATEST_MIGRATION=$(docker exec "${CONTAINER}" psql -U "${DB_USER}" -d "${DB_NAME}" -t -c \
  "SELECT migration_name FROM _prisma_migrations ORDER BY finished_at DESC LIMIT 1;" 2>/dev/null | tr -d ' ')

LATEST_DATE=$(docker exec "${CONTAINER}" psql -U "${DB_USER}" -d "${DB_NAME}" -t -c \
  "SELECT finished_at FROM _prisma_migrations ORDER BY finished_at DESC LIMIT 1;" 2>/dev/null | xargs)

FAILED_COUNT=$(docker exec "${CONTAINER}" psql -U "${DB_USER}" -d "${DB_NAME}" -t -c \
  "SELECT COUNT(*) FROM _prisma_migrations WHERE finished_at IS NULL AND rolled_back_at IS NULL;" 2>/dev/null | tr -d ' ')

TABLE_COUNT=$(docker exec "${CONTAINER}" psql -U "${DB_USER}" -d "${DB_NAME}" -t -c \
  "SELECT COUNT(*) FROM pg_tables WHERE schemaname = 'public';" 2>/dev/null | tr -d ' ')

DB_SIZE=$(docker exec "${CONTAINER}" psql -U "${DB_USER}" -d "${DB_NAME}" -t -c \
  "SELECT pg_size_pretty(pg_database_size('${DB_NAME}'));" 2>/dev/null | xargs)

TOTAL_ROWS=$(docker exec "${CONTAINER}" psql -U "${DB_USER}" -d "${DB_NAME}" -t -c \
  "SELECT SUM(n_live_tup) FROM pg_stat_user_tables;" 2>/dev/null | tr -d ' ')

# Local schema migrations (files on disk)
SCHEMA_DIR="$(cd "$(dirname "$0")/../apps/backend/prisma/migrations" && pwd)"
LOCAL_MIGRATIONS=$(ls -1d "${SCHEMA_DIR}"/[0-9]* 2>/dev/null | wc -l | tr -d ' ')
LOCAL_LATEST=$(ls -1d "${SCHEMA_DIR}"/[0-9]* 2>/dev/null | sort | tail -1 | xargs basename 2>/dev/null || echo "none")

# ---- Output -----------------------------------------------------------------
if [ "${1:-}" = "--json" ]; then
  cat <<ENDJSON
{
  "postgres_version": "${PG_VERSION}",
  "database": "${DB_NAME}",
  "database_size": "${DB_SIZE}",
  "table_count": ${TABLE_COUNT},
  "total_rows": ${TOTAL_ROWS:-0},
  "migrations_applied": ${MIGRATION_COUNT},
  "migrations_on_disk": ${LOCAL_MIGRATIONS},
  "latest_migration_applied": "${LATEST_MIGRATION}",
  "latest_migration_date": "${LATEST_DATE}",
  "latest_migration_on_disk": "${LOCAL_LATEST}",
  "failed_migrations": ${FAILED_COUNT},
  "in_sync": $([ "${MIGRATION_COUNT}" = "${LOCAL_MIGRATIONS}" ] && echo "true" || echo "false")
}
ENDJSON
  exit 0
fi

echo ""
echo -e "${CYAN}========================================${NC}"
echo -e "${CYAN}  Database Version & Status${NC}"
echo -e "${CYAN}========================================${NC}"
echo ""
echo -e "  PostgreSQL:    ${GREEN}${PG_VERSION}${NC}"
echo -e "  Database:      ${DB_NAME}"
echo -e "  Size:          ${DB_SIZE}"
echo -e "  Tables:        ${TABLE_COUNT}"
echo -e "  Total rows:    ${TOTAL_ROWS:-0}"
echo ""
echo -e "${CYAN}  Migrations${NC}"
echo -e "  Applied (DB):  ${MIGRATION_COUNT}"
echo -e "  On disk:       ${LOCAL_MIGRATIONS}"
echo -e "  Latest (DB):   ${LATEST_MIGRATION}"
echo -e "  Latest (disk): ${LOCAL_LATEST}"
echo -e "  Applied at:    ${LATEST_DATE}"

if [ "${FAILED_COUNT}" -gt 0 ]; then
  echo -e "  Failed:        ${RED}${FAILED_COUNT} migration(s) failed!${NC}"
else
  echo -e "  Failed:        ${GREEN}0${NC}"
fi

if [ "${MIGRATION_COUNT}" = "${LOCAL_MIGRATIONS}" ]; then
  echo ""
  echo -e "  Status:        ${GREEN}IN SYNC${NC}"
else
  echo ""
  echo -e "  Status:        ${YELLOW}OUT OF SYNC${NC} (${MIGRATION_COUNT} applied vs ${LOCAL_MIGRATIONS} on disk)"
  echo -e "  Run:           ${CYAN}make prisma-migrate${NC}"
fi

echo ""

# ---- Top tables by row count ------------------------------------------------
echo -e "${CYAN}  Top 10 tables by rows${NC}"
docker exec "${CONTAINER}" psql -U "${DB_USER}" -d "${DB_NAME}" -t -c \
  "SELECT '  ' || rpad(relname, 30) || '  ' || n_live_tup || ' rows'
   FROM pg_stat_user_tables
   WHERE relname NOT LIKE '\_%'
   ORDER BY n_live_tup DESC
   LIMIT 10;" 2>/dev/null || echo "  (could not query row counts)"
echo ""
