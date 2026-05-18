#!/usr/bin/env bash
set -euo pipefail

docker compose down -v
docker compose up -d
npm --workspace apps/backend run prisma:migrate:deploy
npm --workspace apps/backend run prisma:seed
