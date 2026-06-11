import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:provider/provider.dart';

import '../../../core/api_client.dart';
import '../../../core/auth_state.dart';
import '../../../core/env.dart';
import '../../../core/locale_controller.dart';
import '../../../widgets/soft_toast.dart';

/// Perform Google Sign-In flow: SDK → idToken → backend auth → navigate.
///
/// [context] must be mounted throughout the async gaps.
/// [setBusy] toggles the loading state on the parent widget.
Future<void> loginWithGoogle(
  BuildContext context, {
  required ValueChanged<bool> setBusy,
}) async {
  debugPrint('=== [ĐÃ CHỌN ĐĂNG NHẬP: GOOGLE SIGN-IN] ===');
  setBusy(true);
  try {
    final googleSignIn = GoogleSignIn(
      scopes: ['email', 'profile', 'openid'],
      serverClientId: Env.googleServerClientId,
    );
    debugPrint('Đang kích hoạt Google Sign-In SDK...');
    final GoogleSignInAccount? account = await googleSignIn.signIn();
    if (account == null) {
      debugPrint('=== [GOOGLE SIGN-IN BỊ HỦY BỞI NGƯỜI DÙNG] ===');
      if (!context.mounted) return;
      showSoftToast(context,
          message: context.t('Đăng nhập Google bị hủy bởi người dùng'),
          tone: SoftToastTone.info);
      setBusy(false);
      return;
    }

    debugPrint('Google Sign-In thành công cho tài khoản: ${account.email}');
    debugPrint('Đang lấy Google Authentication details...');
    final GoogleSignInAuthentication authDetails =
        await account.authentication;
    final idToken = authDetails.idToken;
    final accessToken = authDetails.accessToken;

    debugPrint('Google ID Token lấy được: $idToken');
    debugPrint('Google Access Token lấy được: $accessToken');

    if (idToken == null) {
      debugPrint(
          '=== [GOOGLE SIGN-IN THẤT BẠI]: Không lấy được ID Token ===');
      if (context.mounted) {
        showSoftToast(context,
            message: context.t('Không lấy được Google ID Token'),
            tone: SoftToastTone.error);
      }
      setBusy(false);
      return;
    }

    if (!context.mounted) return;
    final auth = context.read<AuthState>();
    debugPrint('Đang gửi ID Token lên backend để xác thực...');
    final ok = await auth.loginWithGoogle(
        idToken: idToken, accessToken: accessToken);

    if (context.mounted) {
      setBusy(false);
      if (ok) {
        final token = await RelaxApi.instance.accessToken;
        if (!context.mounted) return;
        debugPrint('=== [ĐĂNG NHẬP GOOGLE THÀNH CÔNG] ===');
        debugPrint('Backend Access Token: $token');
        debugPrint('Tiến hành chuyển hướng vào màn hình Home...');
        context.go('/home');
      } else {
        debugPrint(
            '=== [ĐĂNG NHẬP GOOGLE THẤT BẠI]: ${auth.error} ===');
        showSoftToast(context,
            message:
                context.t(auth.error ?? 'Đăng nhập Google thất bại'),
            tone: SoftToastTone.error);
      }
    }
  } catch (e) {
    debugPrint('=== [GOOGLE SIGN-IN GẶP NGOẠI LỆ]: $e ===');
    if (context.mounted) {
      setBusy(false);
      showSoftToast(context,
          message: '${context.t('Lỗi đăng nhập Google:')} $e',
          tone: SoftToastTone.error);
    }
  }
}

/// DEV bypass: use demo credentials instead of Google Sign-In.
Future<void> simulateGoogleLogin(
  BuildContext context, {
  required ValueChanged<bool> setBusy,
}) async {
  debugPrint('=== [ĐÃ CHỌN ĐĂNG NHẬP: GIẢ LẬP GOOGLE BYPASS] ===');
  setBusy(true);
  final auth = context.read<AuthState>();
  final ok =
      await auth.login('dashboard.demo@relax.local', 'Relax123!@#');
  if (!context.mounted) return;
  setBusy(false);
  if (ok) {
    debugPrint('=== [ĐĂNG NHẬP GIẢ LẬP THÀNH CÔNG] ===');
    debugPrint('Tiến hành chuyển hướng vào màn hình Home...');
    context.go('/home');
  } else {
    debugPrint(
        '=== [ĐĂNG NHẬP GIẢ LẬP THẤT BẠI]: ${auth.error} ===');
    showSoftToast(context,
        message: context.t(auth.error ?? 'Đăng nhập giả lập thất bại'),
        tone: SoftToastTone.error);
  }
}
