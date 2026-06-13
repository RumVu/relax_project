import 'package:test/test.dart';
import 'package:relax_api_client/relax_api_client.dart';


/// tests for UsersApi
void main() {
  final instance = RelaxApiClient().getUsersApi();

  group(UsersApi, () {
    // Create a user (admin)
    //
    //Future<UserResponseDto> usersControllerCreate(CreateUserDto createUserDto) async
    test('test usersControllerCreate', () async {
      // TODO
    });

    // List all users (admin)
    //
    //Future<UserPageDto> usersControllerFindAll({ String search, JsonObject role, JsonObject status, bool emailVerified, bool includeDeleted, num skip, num limit }) async
    test('test usersControllerFindAll', () async {
      // TODO
    });

    // Get one user by id (admin)
    //
    //Future<UserResponseDto> usersControllerFindOne(String id) async
    test('test usersControllerFindOne', () async {
      // TODO
    });

    // Delete a user (admin)
    //
    //Future<UserResponseDto> usersControllerRemove(String id) async
    test('test usersControllerRemove', () async {
      // TODO
    });

    // Update a user (admin)
    //
    //Future<UserResponseDto> usersControllerUpdate(String id, UpdateUserDto updateUserDto) async
    test('test usersControllerUpdate', () async {
      // TODO
    });

  });
}
