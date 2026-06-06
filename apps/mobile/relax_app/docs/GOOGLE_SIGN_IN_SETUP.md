# Google Sign-In Setup — Web + iOS + Android

App này hỗ trợ Google Sign-In trên cả 3 platform. Mỗi platform có
OAuth Client ID riêng từ cùng 1 Google Cloud project.

Backend (`/v1/auth/google`) accept ID token từ bất kỳ Client ID nào
trong env `GOOGLE_CLIENT_ID` (comma-separated list).

---

## ✅ iOS — Đã setup xong

| Item | Value |
|---|---|
| Bundle ID | `com.example.relaxApp` |
| Client ID | `884741112800-d02cdshsm4bh34qgrlcmp70r1h2o5lp5.apps.googleusercontent.com` |
| Info.plist | Đã patched bằng `scripts/setup_google_signin.sh` |

Build & test:

```bash
flutter run \
  --dart-define=GOOGLE_CLIENT_ID=884741112800-d02cdshsm4bh34qgrlcmp70r1h2o5lp5.apps.googleusercontent.com
```

---

## ✅ Android — Đã setup xong

| Item | Value |
|---|---|
| Package name | `com.example.relax_app` |
| Client ID | `884741112800-vkq8svs2c4012n457uta7uva4n4mteii.apps.googleusercontent.com` |
| SHA-1 | Đã đăng ký ở Google Cloud Console |

Build & test:

```bash
flutter run -d <android-device-id> \
  --dart-define=GOOGLE_CLIENT_ID=884741112800-vkq8svs2c4012n457uta7uva4n4mteii.apps.googleusercontent.com
```

> ⚠️ Android **không** cần patch `AndroidManifest.xml` hay code app side.
> Google verify qua package name + SHA-1 cert đã đăng ký ở Cloud Console.

---

<details>
<summary>📚 Hướng dẫn chi tiết (cho lần setup keystore release sau)</summary>

### Setup từ đầu cho Android — 4 bước

### **Bước 1: Lấy SHA-1 fingerprint của debug keystore**

Google cần biết SHA-1 cert để confirm app build từ máy anh là legit.

**Cách dùng helper script:**

```bash
cd apps/mobile/relax_app
bash scripts/android_sha1.sh
```

Script tự thử `keytool` (nhanh nhất). Nếu không có Java, fallback dùng
`gradlew signingReport`.

**Cách thủ công (cần Java JDK):**

```bash
keytool -list -v \
  -keystore ~/.android/debug.keystore \
  -alias androiddebugkey \
  -storepass android \
  -keypass android
```

Tìm dòng:
```
SHA1: AB:CD:EF:01:23:45:67:89:AB:CD:EF:01:23:45:67:89:AB:CD:EF:01
```

→ **Copy giá trị SHA1 này.**

> 💡 Nếu chưa có Java: `brew install --cask temurin`
> 💡 Nếu chưa có debug.keystore: chạy `flutter run` 1 lần trên Android emulator.

---

### **Bước 2: Tạo Android OAuth Client trên Google Cloud Console**

1. Mở https://console.cloud.google.com/auth/clients
2. Chọn đúng project (cùng project với iOS Client đã tạo)
3. Bấm **`+ Create client`**
4. **Application type**: `Android`
5. Điền:
   | Field | Value |
   |---|---|
   | **Name** | `relax-app-android` |
   | **Package name** | `com.example.relax_app` |
   | **SHA-1 certificate fingerprint** | (paste SHA-1 từ Bước 1) |
6. Bấm **Create**

> ⚠️ **Lưu ý**: package name Android là `com.example.relax_app` (underscore),
> khác với iOS Bundle ID `com.example.relaxApp` (camelCase). Đây là quy ước
> mặc định của Flutter — không cần sửa.

Google sẽ trả về Android CLIENT_ID, ví dụ:
```
884741112800-yyyyy.apps.googleusercontent.com
```

→ **Copy CLIENT_ID này.**

---

### **Bước 3: Cập nhật backend env**

Trong `apps/backend/.env`:

```bash
# Comma-separated: web,ios,android
GOOGLE_CLIENT_ID=627379199532-4o73eb98p9s6l70dav8s4l8qujja1ljr.apps.googleusercontent.com,884741112800-d02cdshsm4bh34qgrlcmp70r1h2o5lp5.apps.googleusercontent.com,884741112800-<ANDROID_PREFIX>.apps.googleusercontent.com
```

Restart backend. Giờ backend trust ID token từ Web Dashboard + iOS App + Android App.

---

### **Bước 4: Build mobile cho Android**

**Khác iOS:** Android không cần patch Info.plist (Android dùng package name + SHA-1 fingerprint từ Google Cloud Console để auth, không cần ID trong code).

Chỉ cần truyền CLIENT_ID lúc build:

```bash
flutter run -d <android-device-id> \
  --dart-define=GOOGLE_CLIENT_ID=884741112800-<ANDROID_PREFIX>.apps.googleusercontent.com
```

</details>

---

## 🚨 Khi đóng gói production

### iOS App Store

Bundle ID phải khớp với client đã tạo. Nếu đổi (`com.yourcompany.relax`), tạo
iOS Client mới trên Google Cloud Console với Bundle ID mới.

### Android Play Store

**Quan trọng:** SHA-1 debug keystore khác SHA-1 release keystore (Play App
Signing tự gen 1 cái khác nữa).

1. Tạo release keystore: `keytool -genkey -v -keystore release.jks ...`
2. Lấy SHA-1 của release keystore
3. Vào lại Android Client trên Google Cloud Console → thêm SHA-1 thứ 2
4. Nếu deploy qua Play App Signing: lấy SHA-1 từ Play Console → thêm vào
   Google Cloud Console (SHA-1 thứ 3)

1 Android Client có thể có nhiều SHA-1 cùng lúc (debug + release + Play).

---

## 🐛 Troubleshooting

### iOS

| Error | Nguyên nhân | Fix |
|---|---|---|
| `No active configuration. Make sure GIDClientID is set in Info.plist` | Quên patch Info.plist | Chạy `bash scripts/setup_google_signin.sh <CLIENT_ID>` |
| `channel-error, Unable to establish connection on channel: dev.flutter.pigeon.google_sign_in_ios.GoogleSignInApi.configure` | Plugin chưa init | Đảm bảo `GOOGLE_CLIENT_ID` env truyền khi `flutter run` |
| Login screen không hiện nút Google | Env `GOOGLE_CLIENT_ID` rỗng | Build với `--dart-define=GOOGLE_CLIENT_ID=...` |

### Android

| Error | Nguyên nhân | Fix |
|---|---|---|
| `Sign in failed. Error code: 10` (DEVELOPER_ERROR) | Package name hoặc SHA-1 không khớp | Verify package name trong `android/app/build.gradle.kts` và SHA-1 trên Google Cloud Console |
| `Sign in failed. Error code: 12500` | Google Play Services lỗi | Cài/update Google Play Services trên device/emulator |
| `Sign in cancelled` | User huỷ — không phải lỗi | Bỏ qua |

### Backend

| Error | Nguyên nhân | Fix |
|---|---|---|
| `Google ID token is invalid or expired` | Token cũ / `aud` không khớp | Check `GOOGLE_CLIENT_ID` env có chứa CLIENT_ID của platform đang test không |
| `Google sign-in is not configured` | Backend env rỗng | Set `GOOGLE_CLIENT_ID` trong `apps/backend/.env` |

---

## 🔑 Tổng kết Client IDs

| Platform | Identifier | Client ID |
|---|---|---|
| **Web** | `relax-project-web-dashboard.vercel.app` | `884741112800-aq6rsskn13eiv1r3f3e5qbttlj82skcs.apps.googleusercontent.com` |
| **iOS** | Bundle: `com.example.relaxApp` | `884741112800-d02cdshsm4bh34qgrlcmp70r1h2o5lp5.apps.googleusercontent.com` |
| **Android** | Package: `com.example.relax_app` | `884741112800-vkq8svs2c4012n457uta7uva4n4mteii.apps.googleusercontent.com` |

Backend env (`GOOGLE_CLIENT_ID`) = list 3 cái trên, ngăn cách dấu phẩy.
