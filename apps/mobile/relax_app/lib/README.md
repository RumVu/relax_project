# Mobile Flutter Structure

`main.dart` is only the app entrypoint and library wiring.

- `app/`: root app widget and global state wiring.
- `core/`: backend API client, theme, locale/copy, and shared context extensions.
- `models/`: backend/UI DTO/value objects used by screens and widgets.
- `services/`: feature repositories that load deployed backend data.
- `screens/`: full-page mobile surfaces.
- `widgets/`: reusable UI components grouped by domain.
- `painters/`: custom pixel-art painters and drawing logic.
- `sheets/`: modal/bottom-sheet interaction flows.

New UI should start in a screen or widget file, not in `main.dart`.

## Backend deploy

The mobile app reads relax catalog data from:

```bash
https://relax-backend.tail3e0c74.ts.net/v1
```

Override it when running another deploy:

```bash
flutter run --dart-define=RELAX_API_URL=https://your-backend.example.com/v1
```

The relax tab loads `GET /relax-activities`, then maps backend resources into
the activity cards and audio player sheet.
