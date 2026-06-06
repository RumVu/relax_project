#!/bin/bash
# Patch ios/Runner/Info.plist với Google iOS OAuth Client ID.
#
# Usage:
#   bash scripts/setup_google_signin.sh <IOS_CLIENT_ID>
#
# Ví dụ:
#   bash scripts/setup_google_signin.sh 123456789012-xxxxx
#
# (Chỉ truyền prefix trước `.apps.googleusercontent.com`)

set -euo pipefail

if [ $# -lt 1 ]; then
  echo "❌ Thiếu CLIENT_ID."
  echo "Usage: bash scripts/setup_google_signin.sh <IOS_CLIENT_ID>"
  echo "       (prefix trước .apps.googleusercontent.com, lấy từ Google Cloud Console)"
  exit 1
fi

CLIENT_ID="$1"
PLIST="ios/Runner/Info.plist"

if [ ! -f "$PLIST" ]; then
  echo "❌ Không tìm thấy $PLIST"
  echo "Hãy chạy script này từ thư mục apps/mobile/relax_app/"
  exit 1
fi

# Backup trước khi sửa.
cp "$PLIST" "$PLIST.bak"
echo "✓ Backup: $PLIST.bak"

# Thay placeholder GIDClientID + REVERSED scheme.
sed -i.tmp "s|YOUR_GOOGLE_IOS_CLIENT_ID.apps.googleusercontent.com|${CLIENT_ID}.apps.googleusercontent.com|g" "$PLIST"
sed -i.tmp "s|com.googleusercontent.apps.YOUR_GOOGLE_IOS_CLIENT_ID|com.googleusercontent.apps.${CLIENT_ID}|g" "$PLIST"
rm -f "$PLIST.tmp"

echo "✓ Đã patch $PLIST với CLIENT_ID: $CLIENT_ID"
echo ""
echo "Bước tiếp theo (Bước 3):"
echo "  flutter run --dart-define=GOOGLE_CLIENT_ID=${CLIENT_ID}.apps.googleusercontent.com"
