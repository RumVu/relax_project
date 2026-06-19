#!/usr/bin/env bash
# Generate a Dart API client from the backend OpenAPI spec.
#
# Prerequisites:
#   - Backend running at $API_URL (default: http://localhost:6823)
#   - Java installed (for openapi-generator-cli) OR npx available
#
# Usage:
#   ./scripts/generate-api-client.sh
#   API_URL=https://api.thiai.app ./scripts/generate-api-client.sh

set -euo pipefail

API_URL="${API_URL:-http://localhost:6823}"
SPEC_URL="${API_URL}/docs-json"
OUTPUT_DIR="apps/mobile/relax_app/lib/generated/api"
SPEC_FILE="tmp/openapi-spec.json"

echo "=== Relax Time API Client Generator ==="
echo "Fetching OpenAPI spec from: ${SPEC_URL}"

mkdir -p tmp
curl -sf "${SPEC_URL}" -o "${SPEC_FILE}" || {
  echo "ERROR: Could not fetch spec from ${SPEC_URL}"
  echo "Make sure the backend is running and Swagger is enabled."
  exit 1
}

echo "Spec downloaded: $(wc -c < "${SPEC_FILE}") bytes"

# Check for openapi-generator
if command -v openapi-generator-cli &>/dev/null; then
  GENERATOR="openapi-generator-cli"
elif npx --yes @openapitools/openapi-generator-cli version &>/dev/null 2>&1; then
  GENERATOR="npx --yes @openapitools/openapi-generator-cli"
else
  echo ""
  echo "openapi-generator not found. Install one of:"
  echo "  brew install openapi-generator"
  echo "  npm install -g @openapitools/openapi-generator-cli"
  echo ""
  echo "Alternatively, use the spec file directly: ${SPEC_FILE}"
  echo "You can import it into Postman, Insomnia, or any API tool."
  exit 1
fi

echo "Generating Dart client to: ${OUTPUT_DIR}"
rm -rf "${OUTPUT_DIR}"

${GENERATOR} generate \
  -i "${SPEC_FILE}" \
  -g dart-dio \
  -o "${OUTPUT_DIR}" \
  --additional-properties=pubName=relax_api_client,pubAuthor="Thi-Ai-Team" \
  --skip-validate-spec

echo ""
echo "=== Done! ==="
echo "Generated Dart API client at: ${OUTPUT_DIR}"
echo ""
echo "To use it, add to pubspec.yaml:"
echo "  dependencies:"
echo "    relax_api_client:"
echo "      path: lib/generated/api"
echo ""
echo "Then run: cd apps/mobile/relax_app && dart pub get"
