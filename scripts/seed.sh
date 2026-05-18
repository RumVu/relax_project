#!/usr/bin/env bash
set -euo pipefail

npm --workspace apps/backend run prisma:seed
