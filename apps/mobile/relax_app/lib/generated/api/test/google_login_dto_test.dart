import 'package:test/test.dart';
import 'package:relax_api_client/relax_api_client.dart';

// tests for GoogleLoginDto
void main() {
  final instance = GoogleLoginDtoBuilder();
  // TODO add properties to the builder and call build()

  group(GoogleLoginDto, () {
    // Legacy GIS ID token. Kept for backwards compatibility.
    // String idToken
    test('to test the property `idToken`', () async {
      // TODO
    });

    // Legacy OAuth access token. Kept for backwards compatibility.
    // String accessToken
    test('to test the property `accessToken`', () async {
      // TODO
    });

    // OAuth authorization code returned to /auth/google/callback. Backend exchanges this using GOOGLE_CLIENT_SECRET.
    // String authorizationCode
    test('to test the property `authorizationCode`', () async {
      // TODO
    });

    // String redirectUri
    test('to test the property `redirectUri`', () async {
      // TODO
    });

  });
}
