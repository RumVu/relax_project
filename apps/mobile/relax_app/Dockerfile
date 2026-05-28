# syntax=docker/dockerfile:1
#
# Flutter Web build for the relax_app mobile workspace. Mobile native targets
# (Android/iOS) are not built inside Docker — those need their respective
# native toolchains. This image only produces the static Flutter web bundle,
# which is convenient for previews and PR-deploys.

FROM ghcr.io/cirruslabs/flutter:3.27.0 AS builder
WORKDIR /app

# Manifest first so the dependency layer caches independently of source code.
COPY pubspec.yaml pubspec.lock ./
RUN flutter pub get

COPY . .

RUN flutter pub get \
  && flutter build web --release

# ----- runtime ----------------------------------------------------------------
FROM nginx:1.27-alpine AS runtime

# Default nginx config serves /usr/share/nginx/html on :80 — fine for the
# static Flutter bundle.
COPY --from=builder /app/build/web /usr/share/nginx/html

EXPOSE 80

HEALTHCHECK --interval=30s --timeout=5s --start-period=10s --retries=3 \
  CMD wget --quiet --spider http://127.0.0.1/ || exit 1
