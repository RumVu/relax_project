import 'dart:convert';
import 'dart:math' as math;

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:http/http.dart' as http;
import 'package:just_audio/just_audio.dart';

// ── App root + theme + locale copy ──────────────────────────────────────
part 'app/app_root.dart';
part 'app/theme.dart';
part 'app/app_copy.dart';

// ── Cross-cutting infra ─────────────────────────────────────────────────
part 'config/env.dart';
part 'core/api_client.dart';
part 'core/session.dart';

// ── Data layer ──────────────────────────────────────────────────────────
part 'data/models/backend_models.dart';
part 'data/models/app_models.dart';
part 'data/services/auth_service.dart';
part 'data/services/mood_service.dart';
part 'data/services/relax_session_service.dart';
part 'data/services/supabase_storage_service.dart';
part 'data/services/mobile_content_service.dart';
part 'data/services/relax_catalog_service.dart';

// ── Shared UI building blocks ───────────────────────────────────────────
part 'shared/painters/pixel_scene_painter.dart';
part 'shared/widgets/pixel/pixel_panel.dart';
part 'shared/widgets/pixel/pixel_badge.dart';
part 'shared/widgets/pixel/pixel_button.dart';
part 'shared/widgets/pixel/cat_widgets.dart';
part 'shared/widgets/common/section_title.dart';
part 'shared/widgets/common/page_dots.dart';
part 'shared/widgets/common/speech_bubble.dart';
part 'shared/widgets/common/backend_status_banner.dart';
part 'shared/widgets/buttons/small_action_button.dart';
part 'shared/widgets/buttons/pill_controls.dart';
part 'shared/widgets/mood/mood_tile.dart';
part 'shared/widgets/mood/mood_progress.dart';
part 'shared/widgets/mood/method_chip.dart';
part 'shared/widgets/activity/activity_card.dart';
part 'shared/widgets/dashboard/stat_card.dart';
part 'shared/widgets/dashboard/favorite_activity.dart';
part 'shared/widgets/dashboard/mini_moment.dart';
part 'shared/widgets/charts/mood_line_chart.dart';
part 'shared/widgets/layout/app_scroll.dart';
part 'shared/widgets/layout/header_bar.dart';
part 'shared/widgets/navigation/pixel_bottom_nav.dart';
part 'shared/widgets/settings/setting_row.dart';
part 'shared/widgets/settings/setting_action.dart';
part 'shared/widgets/settings/time_chip.dart';

// ── Feature screens + sheets ────────────────────────────────────────────
part 'features/splash/splash_screen.dart';
part 'features/onboarding/onboarding_screen.dart';
part 'features/auth/login_screen.dart';
part 'features/auth/register_screen.dart';
part 'features/shell/app_shell.dart';
part 'features/home/home_screen.dart';
part 'features/relax/relax_screen.dart';
part 'features/relax/sheets/relax_sheets.dart';
part 'features/challenge/challenge_screen.dart';
part 'features/setup/setup_screen.dart';

void main() {
  runApp(const RelaxApp());
}
