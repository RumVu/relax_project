# syntax=docker/dockerfile:1
# Production image for Next.js web dashboard.
FROM node:22-alpine AS builder
WORKDIR /app

# Manifest files first so npm ci can hit the layer cache when only source changes.
COPY package.json package-lock.json ./
COPY tsconfig.json ./
COPY apps/web/package.json apps/web/
COPY packages ./packages

RUN npm ci

# Web source
COPY apps/web ./apps/web

WORKDIR /app/apps/web
ARG NEXT_PUBLIC_API_URL=http://localhost:6823
ENV NEXT_PUBLIC_API_URL=$NEXT_PUBLIC_API_URL
ARG NEXT_PUBLIC_GOOGLE_CLIENT_ID=
ENV NEXT_PUBLIC_GOOGLE_CLIENT_ID=$NEXT_PUBLIC_GOOGLE_CLIENT_ID

RUN npm run build

# ----- runner ----------------------------------------------------------------
FROM node:22-alpine AS runner
WORKDIR /app

ENV NODE_ENV=production
ENV HOSTNAME=0.0.0.0
ENV PORT=3233

# Bring only what is required to run the web dashboard.
COPY --from=builder /app/node_modules ./node_modules
COPY --from=builder /app/apps/web/node_modules ./apps/web/node_modules
COPY --from=builder /app/apps/web/.next ./apps/web/.next
COPY --from=builder /app/packages ./packages
COPY --from=builder /app/apps/web/package.json ./apps/web/
COPY --from=builder /app/package.json ./

EXPOSE 3233

WORKDIR /app/apps/web
CMD ["npx", "next", "start", "--hostname", "0.0.0.0", "--port", "3233"]
