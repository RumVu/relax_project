# Thi Ai — Mobile App (Flutter)

Wellness & relaxation mobile app built with Flutter/Dart. Connects to the NestJS backend API for mood tracking, journaling, meditation, breathing exercises, and more.

## Prerequisites

- Flutter SDK (3.x+)
- Dart SDK
- Android Studio or Xcode (for emulator/simulator)
- Backend API running (see root `docker-compose.yml`)

## Getting Started

```bash
cd apps/mobile/relax_app
flutter pub get
flutter run
```

## API Base Configuration

The API base URL is configured via environment variable or directly in:

```
lib/core/api_client.dart
```

## Demo Account

On the login screen, tap the **"Dung thu Demo"** button to access a pre-seeded demo account with 14 days of sample data.

## Main Screens

| # | Screen | Description |
|---|--------|-------------|
| 1 | Home | Dashboard with mood summary, quick actions |
| 2 | Mood Check-in | Log mood with intensity, notes, tags, triggers |
| 3 | Analytics | Mood trends, charts, streak tracking |
| 4 | Journal | Private entries with favorites, tags, auto-prompts |
| 5 | Breathing | Guided breathing exercises with timer |
| 6 | Meditation | Meditation sessions with guided audio |
| 7 | Sounds / Soundscape | Ambient sound player with mixer |
| 8 | Companion Chat | AI companion with mood-based messages and chat history |
| 9 | Weather | Weather integration for mood correlation |
| 10 | Settings | App preferences, notifications, account |
| 11 | Billing | Subscription tier management |
| 12 | Weekly Report | Auto-generated wellness summary |
| 13 | Wellness Plan | Personal goals and activity plan |
| 14 | Achievements | Gamification badges and milestones |
| 15 | Trigger Map | Stress cause tracking and visualization |
| 16 | Focus Break | Short break activities and reminders |
| 17 | Buddies | Trusted buddy check-in, SOS messaging |
| 18 | Recommendations | Smart suggestions based on mood, history, time |
| 19 | Crisis Help | Safety layer with hotlines and safe responses |
| 20 | Privacy Vault | PIN lock, hide preview, private AI mode, data export |

## Offline Behavior

The app uses **Hive** for local caching and a sync queue to persist data when offline. Changes are automatically synced to the backend when connectivity is restored.

## Push Notifications

Configured with `flutter_local_notifications`. Supports smart reminders for mood check-ins, wellness activities, and buddy check-in alerts.

## Build APK

```bash
cd apps/mobile/relax_app
flutter build apk --release
```

The release APK will be at `build/app/outputs/flutter-apk/app-release.apk`.

## Tests

```bash
cd apps/mobile/relax_app
flutter test
```
