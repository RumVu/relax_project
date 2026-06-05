# Mobile Flutter Structure

`main.dart` is only the app entrypoint and library wiring.

- `app/`: root app widget and global state wiring.
- `core/`: theme, locale/copy, and shared context extensions.
- `models/`: UI DTO/value objects used by screens and widgets.
- `screens/`: full-page mobile surfaces.
- `widgets/`: reusable UI components grouped by domain.
- `painters/`: custom pixel-art painters and drawing logic.
- `sheets/`: modal/bottom-sheet interaction flows.

New UI should start in a screen or widget file, not in `main.dart`.
