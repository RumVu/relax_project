import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';

import '../app/theme.dart';

/// Cài 1 lần lúc app boot — catch mọi error chưa handle và hiện
/// "Có lỗi nhỏ ✦" screen thân thiện thay vì red screen of death.
///
/// Trong DEBUG: vẫn hiện red screen mặc định để dev thấy stack trace.
/// Trong RELEASE: hiện FriendlyErrorScreen + nút "Tải lại".
class ErrorBoundary {
  static void install({void Function(FlutterErrorDetails)? onError}) {
    // Catch errors trong widget tree
    FlutterError.onError = (details) {
      // Vẫn log để dev thấy
      FlutterError.presentError(details);
      onError?.call(details);
    };

    // Catch errors ngoài widget tree (async / isolate)
    PlatformDispatcher.instance.onError = (error, stack) {
      debugPrint('UNHANDLED ERROR: $error\n$stack');
      onError?.call(
        FlutterErrorDetails(exception: error, stack: stack),
      );
      return true; // mark as handled
    };

    // Custom ErrorWidget builder — chỉ trong RELEASE
    if (kReleaseMode) {
      ErrorWidget.builder = (details) => _FriendlyErrorScreen(
            message: details.exceptionAsString(),
          );
    }
  }
}

class _FriendlyErrorScreen extends StatelessWidget {
  const _FriendlyErrorScreen({required this.message});
  final String message;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Theme.of(context).scaffoldBackgroundColor,
      child: SafeArea(
        child: Center(
          child: Padding(
            padding: const EdgeInsets.all(28),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Container(
                  width: 92,
                  height: 92,
                  decoration: BoxDecoration(
                    color: RelaxTheme.purple.withValues(alpha: .12),
                    shape: BoxShape.circle,
                  ),
                  child: const Icon(
                    Icons.healing_rounded,
                    color: RelaxTheme.purple,
                    size: 44,
                  ),
                ),
                const SizedBox(height: 20),
                Text(
                  'Có lỗi nhỏ ✦',
                  textAlign: TextAlign.center,
                  style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                        fontWeight: FontWeight.w900,
                      ),
                ),
                const SizedBox(height: 10),
                Text(
                  'Mình gặp chút trục trặc khi hiển thị màn này.\nThử tải lại nha ~',
                  textAlign: TextAlign.center,
                  style: Theme.of(context).textTheme.bodyMedium,
                ),
                if (!kReleaseMode) ...[
                  const SizedBox(height: 12),
                  Container(
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: Colors.black12,
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Text(
                      message,
                      style: const TextStyle(
                        fontFamily: 'monospace',
                        fontSize: 11,
                      ),
                    ),
                  ),
                ],
              ],
            ),
          ),
        ),
      ),
    );
  }
}
