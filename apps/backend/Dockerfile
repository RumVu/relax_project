# syntax=docker/dockerfile:1
#
# Production image for the NestJS backend. Multi-stage so the runtime image
# only contains the built dist, runtime deps, and the Prisma schema needed at
# boot. Use bookworm-slim instead of alpine because bcrypt and Prisma play
# nicer with glibc.

# ----- builder ---------------------------------------------------------------
FROM node:22-bookworm-slim AS builder
WORKDIR /app

# Prisma needs OpenSSL at install time (postinstall runs prisma generate via
# the backend workspace).
RUN apt-get update \
  && apt-get install -y --no-install-recommends openssl ca-certificates \
  && rm -rf /var/lib/apt/lists/*

# Manifest files first so npm ci can hit the layer cache when only source
# changes.
COPY package.json package-lock.json ./
COPY tsconfig.json ./
COPY apps/backend/package.json apps/backend/
COPY apps/web/package.json apps/web/
COPY packages ./packages
# Prisma schema parts + sync script are required by the backend's
# `postinstall -> prisma:generate` hook.
COPY apps/backend/prisma ./apps/backend/prisma

RUN npm ci

# Backend source
COPY apps/backend ./apps/backend

WORKDIR /app/apps/backend
RUN npm run build

# ----- runtime ---------------------------------------------------------------
FROM node:22-bookworm-slim AS runtime
WORKDIR /app

ENV NODE_ENV=production
ENV PORT=6823

RUN apt-get update \
  && apt-get install -y --no-install-recommends openssl ca-certificates wget tini \
  && rm -rf /var/lib/apt/lists/*

# Bring only what is required to run the compiled server.
COPY --from=builder /app/node_modules ./node_modules
COPY --from=builder /app/apps/backend/node_modules ./apps/backend/node_modules
COPY --from=builder /app/apps/backend/dist ./apps/backend/dist
COPY --from=builder /app/apps/backend/prisma ./apps/backend/prisma
COPY --from=builder /app/apps/backend/scripts ./apps/backend/scripts
COPY --from=builder /app/packages ./packages
COPY --from=builder /app/apps/backend/package.json ./apps/backend/
COPY --from=builder /app/package.json ./

RUN npm prune --omit=dev --workspace apps/backend 2>/dev/null; \
    find node_modules -name '*.md' -o -name '*.map' -o -name 'CHANGELOG*' | head -500 | xargs rm -f 2>/dev/null; \
    true

EXPOSE 6823

HEALTHCHECK --interval=30s --timeout=5s --start-period=15s --retries=3 \
  CMD wget --quiet --spider http://127.0.0.1:6823/health || exit 1

USER node

# tini handles signals so SIGTERM cleanly stops Nest + Prisma.
ENTRYPOINT ["/usr/bin/tini", "--"]
CMD ["node", "apps/backend/scripts/start-prod.cjs"]
