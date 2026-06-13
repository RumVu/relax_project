import 'package:test/test.dart';
import 'package:relax_api_client/relax_api_client.dart';


/// tests for UserProfilesApi
void main() {
  final instance = RelaxApiClient().getUserProfilesApi();

  group(UserProfilesApi, () {
    // Get a user profile by user id (admin)
    //
    //Future<UserProfileResponseDto> userProfilesControllerFindByUserId(String userId) async
    test('test userProfilesControllerFindByUserId', () async {
      // TODO
    });

    // Get the current user profile
    //
    //Future<UserProfileResponseDto> userProfilesControllerFindMine() async
    test('test userProfilesControllerFindMine', () async {
      // TODO
    });

    // Upsert a user profile by user id (admin)
    //
    //Future<UserProfileResponseDto> userProfilesControllerUpsert(String userId, UpsertUserProfileDto upsertUserProfileDto) async
    test('test userProfilesControllerUpsert', () async {
      // TODO
    });

    // Upsert the current user profile
    //
    //Future<UserProfileResponseDto> userProfilesControllerUpsertMine(UpsertUserProfileDto upsertUserProfileDto) async
    test('test userProfilesControllerUpsertMine', () async {
      // TODO
    });

  });
}
