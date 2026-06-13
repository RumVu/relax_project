import 'package:test/test.dart';
import 'package:relax_api_client/relax_api_client.dart';


/// tests for SessionsApi
void main() {
  final instance = RelaxApiClient().getSessionsApi();

  group(SessionsApi, () {
    // List all sessions (admin)
    //
    //Future<BuiltList<SessionResponseDto>> sessionsControllerFindAll() async
    test('test sessionsControllerFindAll', () async {
      // TODO
    });

    // List sessions for one user (admin)
    //
    //Future<BuiltList<SessionResponseDto>> sessionsControllerFindByUserId(String userId) async
    test('test sessionsControllerFindByUserId', () async {
      // TODO
    });

    // List sessions for the current user
    //
    //Future<BuiltList<SessionResponseDto>> sessionsControllerFindMine() async
    test('test sessionsControllerFindMine', () async {
      // TODO
    });

    // Revoke one session (admin)
    //
    //Future<SessionResponseDto> sessionsControllerRevoke(String id) async
    test('test sessionsControllerRevoke', () async {
      // TODO
    });

    // Revoke all sessions for one user (admin)
    //
    //Future<JsonObject> sessionsControllerRevokeUserSessions(String userId) async
    test('test sessionsControllerRevokeUserSessions', () async {
      // TODO
    });

  });
}
