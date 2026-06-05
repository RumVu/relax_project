# Thi Ai Chill Mobile

Flutter mobile workspace for the Thi Ai Chill relaxation app.

## Version Policy

- Recommended Flutter SDK: `3.41.7` stable, pinned in `.fvmrc`.
- Minimum Dart SDK accepted by this app: `>=3.11.4 <4.0.0`.
- App version is managed from `pubspec.yaml`:
  - `version: 1.0.1+2`
  - `1.0.1` is the user-facing app version.
  - `2` is the native build number/code.

Do not edit native Android/iOS version fields directly. Flutter maps
`pubspec.yaml` into:

- Android: `versionName` / `versionCode`
- iOS: `CFBundleShortVersionString` / `CFBundleVersion`

## Setup

```bash
cd apps/mobile/relax_app
flutter pub get
flutter analyze
flutter test
```

If using FVM:

```bash
cd apps/mobile/relax_app
fvm install
fvm flutter pub get
```

## Backend

The app uses the deployed backend by default:

```bash
https://relax-backend.tail3e0c74.ts.net/v1
```

Override it when running another environment:

```bash
flutter run --dart-define=RELAX_API_URL=https://your-backend.example.com/v1
```

## Release Bump

For a normal app update, bump both user-facing version and build number:

```yaml
version: 1.0.2+3
```

For an internal rebuild with no visible app changes, bump only the build number:

```yaml
version: 1.0.1+3
```
