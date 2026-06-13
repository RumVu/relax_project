import 'package:test/test.dart';
import 'package:relax_api_client/relax_api_client.dart';


/// tests for AuthApi
void main() {
  final instance = RelaxApiClient().getAuthApi();

  group(AuthApi, () {
    // Change the current local user password
    //
    //Future<AuthActionResultDto> authControllerChangeMyPassword(ChangePasswordDto changePasswordDto) async
    test('test authControllerChangeMyPassword', () async {
      // TODO
    });

    // Delete or deactivate the current account
    //
    //Future<AuthActionResultDto> authControllerDeleteMine(DeleteAccountDto deleteAccountDto) async
    test('test authControllerDeleteMine', () async {
      // TODO
    });

    // Login as demo user with pre-populated data
    //
    //Future<AuthResponseDto> authControllerDemo(DemoLoginDto demoLoginDto) async
    test('test authControllerDemo', () async {
      // TODO
    });

    // Export current user personal data
    //
    //Future<JsonObject> authControllerExportMine() async
    test('test authControllerExportMine', () async {
      // TODO
    });

    // Exchange a Google ID token for an app session
    //
    //Future<AuthResponseDto> authControllerGoogle(GoogleLoginDto googleLoginDto) async
    test('test authControllerGoogle', () async {
      // TODO
    });

    // Login with email and password
    //
    //Future<AuthResponseDto> authControllerLogin(LoginDto loginDto) async
    test('test authControllerLogin', () async {
      // TODO
    });

    // Logout by revoking one refresh token
    //
    //Future<AuthActionResultDto> authControllerLogout(RefreshTokenDto refreshTokenDto) async
    test('test authControllerLogout', () async {
      // TODO
    });

    // Get the current authenticated user
    //
    //Future<UserResponseDto> authControllerMe() async
    test('test authControllerMe', () async {
      // TODO
    });

    // Rotate a refresh token
    //
    //Future<AuthResponseDto> authControllerRefresh(RefreshTokenDto refreshTokenDto) async
    test('test authControllerRefresh', () async {
      // TODO
    });

    // Register a local user and create a session
    //
    //Future<AuthResponseDto> authControllerRegister(RegisterDto registerDto) async
    test('test authControllerRegister', () async {
      // TODO
    });

    // Request current user email verification token
    //
    //Future<AuthActionResultDto> authControllerRequestEmailVerification() async
    test('test authControllerRequestEmailVerification', () async {
      // TODO
    });

    // Request a password reset email
    //
    //Future<AuthActionResultDto> authControllerRequestPasswordReset(RequestPasswordResetDto requestPasswordResetDto) async
    test('test authControllerRequestPasswordReset', () async {
      // TODO
    });

    // Reset password with an account token
    //
    //Future<AuthActionResultDto> authControllerResetPassword(ResetPasswordDto resetPasswordDto) async
    test('test authControllerResetPassword', () async {
      // TODO
    });

    // Verify email with an account token
    //
    //Future<AuthActionResultDto> authControllerVerifyEmail(VerifyEmailDto verifyEmailDto) async
    test('test authControllerVerifyEmail', () async {
      // TODO
    });

  });
}
