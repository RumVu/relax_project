import 'package:flutter_secure_storage/flutter_secure_storage.dart';

/// Hỗ trợ cấu hình dùng chung cho FlutterSecureStorage.
/// useDataProtectionKeyChain: false giúp tránh bị treo/lỗi trên macOS Desktop
/// khi không cấu hình Keychain Sharing Entitlements.
const secureStorage = FlutterSecureStorage(
  mOptions: MacOsOptions(
    useDataProtectionKeyChain: false,
  ),
);
