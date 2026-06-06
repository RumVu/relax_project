import 'package:device_info_plus/device_info_plus.dart';
import 'package:flutter/foundation.dart';
import 'package:package_info_plus/package_info_plus.dart';
import 'package:permission_handler/permission_handler.dart';

class DeviceSnapshot {
  const DeviceSnapshot({
    required this.platform,
    required this.deviceName,
    required this.osVersion,
    required this.appVersion,
    required this.buildNumber,
    required this.notificationStatus,
  });

  final String platform;
  final String deviceName;
  final String osVersion;
  final String appVersion;
  final String buildNumber;
  final PermissionStatus notificationStatus;

  String get appLabel => '$appVersion+$buildNumber';
  bool get notificationsAllowed => notificationStatus.isGranted;

  String get notificationLabel {
    if (notificationsAllowed) return 'Đã cho phép';
    if (notificationStatus.isDenied) return 'Chưa cho phép';
    if (notificationStatus.isPermanentlyDenied) return 'Bị chặn trong cài đặt';
    if (notificationStatus.isLimited) return 'Giới hạn';
    if (notificationStatus.isRestricted) return 'Bị giới hạn';
    return 'Chưa xác định';
  }
}

class DeviceCapabilityService {
  DeviceCapabilityService({DeviceInfoPlugin? deviceInfo})
    : _deviceInfo = deviceInfo ?? DeviceInfoPlugin();

  final DeviceInfoPlugin _deviceInfo;

  Future<DeviceSnapshot> load() async {
    final package = await PackageInfo.fromPlatform();
    final status = await Permission.notification.status;
    final info = await _readDeviceInfo();

    return DeviceSnapshot(
      platform: info.platform,
      deviceName: info.deviceName,
      osVersion: info.osVersion,
      appVersion: package.version,
      buildNumber: package.buildNumber,
      notificationStatus: status,
    );
  }

  Future<DeviceSnapshot> requestNotifications() async {
    await Permission.notification.request();
    return load();
  }

  Future<_DeviceInfoView> _readDeviceInfo() async {
    if (kIsWeb) {
      final info = await _deviceInfo.webBrowserInfo;
      return _DeviceInfoView(
        platform: 'Web',
        deviceName: [info.browserName.name, info.platform]
            .where((part) => part != null && part.toString().isNotEmpty)
            .join(' · '),
        osVersion: info.userAgent ?? 'Không rõ phiên bản',
      );
    }

    switch (defaultTargetPlatform) {
      case TargetPlatform.android:
        final info = await _deviceInfo.androidInfo;
        return _DeviceInfoView(
          platform: 'Android',
          deviceName: '${info.manufacturer} ${info.model}'.trim(),
          osVersion:
              'Android ${info.version.release} (SDK ${info.version.sdkInt})',
        );
      case TargetPlatform.iOS:
        final info = await _deviceInfo.iosInfo;
        return _DeviceInfoView(
          platform: 'iOS',
          deviceName: info.utsname.machine,
          osVersion: '${info.systemName} ${info.systemVersion}',
        );
      case TargetPlatform.macOS:
        final info = await _deviceInfo.macOsInfo;
        return _DeviceInfoView(
          platform: 'macOS',
          deviceName: info.model,
          osVersion: 'macOS ${info.osRelease}',
        );
      case TargetPlatform.windows:
        final info = await _deviceInfo.windowsInfo;
        return _DeviceInfoView(
          platform: 'Windows',
          deviceName: info.computerName,
          osVersion: 'Build ${info.buildNumber}',
        );
      case TargetPlatform.linux:
        final info = await _deviceInfo.linuxInfo;
        return _DeviceInfoView(
          platform: 'Linux',
          deviceName: info.prettyName,
          osVersion: info.version ?? 'Không rõ phiên bản',
        );
      case TargetPlatform.fuchsia:
        return const _DeviceInfoView(
          platform: 'Fuchsia',
          deviceName: 'Thiết bị Fuchsia',
          osVersion: 'Không rõ phiên bản',
        );
    }
  }
}

class _DeviceInfoView {
  const _DeviceInfoView({
    required this.platform,
    required this.deviceName,
    required this.osVersion,
  });

  final String platform;
  final String deviceName;
  final String osVersion;
}
