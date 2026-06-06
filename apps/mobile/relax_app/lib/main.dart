import 'package:flutter/material.dart';
import 'package:just_audio_background/just_audio_background.dart';

import 'app/app_root.dart';
import 'core/error_boundary.dart';

export 'app/app_copy.dart';
export 'app/app_root.dart';
export 'app/theme.dart';
export 'core/api_client.dart';
export 'core/session.dart';
export 'data/models/app_models.dart';
export 'data/models/backend_models.dart';
export 'data/services/mobile_content_service.dart';
export 'data/services/relax_catalog_service.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  ErrorBoundary.install();
  // Background audio: lock-screen + notification controls khi play nhạc/podcast.
  try {
    await JustAudioBackground.init(
      androidNotificationChannelId: 'com.example.relaxApp.audio',
      androidNotificationChannelName: 'Phát nhạc thư giãn',
      androidNotificationOngoing: true,
    );
  } catch (_) {/* swallow — không chặn app boot */}
  runApp(const RelaxApp());
}
