import 'package:test/test.dart';
import 'package:relax_api_client/relax_api_client.dart';


/// tests for UserPreferencesApi
void main() {
  final instance = RelaxApiClient().getUserPreferencesApi();

  group(UserPreferencesApi, () {
    // Get user preferences by user id (admin)
    //
    //Future<UserPreferenceResponseDto> userPreferencesControllerFindByUserId(String userId) async
    test('test userPreferencesControllerFindByUserId', () async {
      // TODO
    });

    // Get the current user preferences
    //
    //Future<UserPreferenceResponseDto> userPreferencesControllerFindMine() async
    test('test userPreferencesControllerFindMine', () async {
      // TODO
    });

    // Upsert user preferences by user id (admin)
    //
    //Future<UserPreferenceResponseDto> userPreferencesControllerUpsert(String userId, UpsertUserPreferenceDto upsertUserPreferenceDto) async
    test('test userPreferencesControllerUpsert', () async {
      // TODO
    });

    // Upsert the current user preferences
    //
    //Future<UserPreferenceResponseDto> userPreferencesControllerUpsertMine(UpsertUserPreferenceDto upsertUserPreferenceDto) async
    test('test userPreferencesControllerUpsertMine', () async {
      // TODO
    });

  });
}
