#!/bin/bash
# Lấy SHA-1 fingerprint của Android debug keystore và (nếu có) release keystore.
# Cần SHA-1 này để tạo Android OAuth Client trên Google Cloud Console.
#
# Usage:
#   bash scripts/android_sha1.sh
#
# Output: in ra SHA-1 (và SHA-256) của debug keystore mặc định của Android SDK.

set -euo pipefail

# ─── 1) Try Java keytool first (fastest) ─────────────────────────────────────
if command -v keytool >/dev/null 2>&1; then
  echo "📱 Sử dụng keytool (Java)..."
  echo ""
  echo "═══ DEBUG keystore (~/.android/debug.keystore) ═══"
  if [ -f "$HOME/.android/debug.keystore" ]; then
    keytool -list -v \
      -keystore "$HOME/.android/debug.keystore" \
      -alias androiddebugkey \
      -storepass android \
      -keypass android 2>&1 | grep -E "SHA1|SHA-1|SHA256|SHA-256" || true
  else
    echo "⚠️  Chưa có debug.keystore. Hãy chạy 'flutter run' 1 lần trên Android device/emulator để generate."
  fi
  echo ""
  echo "Copy dòng 'SHA1:' (không bao gồm 'SHA-256:') paste vào Google Cloud Console."
  exit 0
fi

# ─── 2) Fallback: Gradle signing report ──────────────────────────────────────
echo "⚠️  Không tìm thấy 'keytool' (Java chưa cài)."
echo "📱 Đang thử 'gradlew signingReport'..."
echo ""

if [ ! -d "android" ]; then
  echo "❌ Không thấy thư mục android/. Chạy từ apps/mobile/relax_app/"
  exit 1
fi

cd android
if [ ! -f "gradlew" ]; then
  echo "❌ Không có gradlew. Hãy chạy 'flutter build apk --debug' 1 lần."
  exit 1
fi

./gradlew :app:signingReport 2>&1 | grep -E "Variant:|SHA1:|SHA-1:" || true

echo ""
echo "═══ Cách dùng ═══"
echo "1. Tìm dòng 'Variant: debug' → SHA1 ngay dưới."
echo "2. Copy SHA1 (vd: AB:CD:EF:01:23:...) vào Google Cloud Console khi tạo Android OAuth Client."
echo ""
echo "💡 Nếu chưa cài Java/JDK, cài qua: 'brew install --cask temurin'"
