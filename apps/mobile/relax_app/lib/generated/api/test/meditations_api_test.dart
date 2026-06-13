import 'package:test/test.dart';
import 'package:relax_api_client/relax_api_client.dart';


/// tests for MeditationsApi
void main() {
  final instance = RelaxApiClient().getMeditationsApi();

  group(MeditationsApi, () {
    // Log a meditation session
    //
    //Future<JsonObject> meditationsControllerCreateSession(CreateMeditationSessionDto createMeditationSessionDto) async
    test('test meditationsControllerCreateSession', () async {
      // TODO
    });

    // Get active guided meditations
    //
    //Future meditationsControllerFindGuides({ String difficulty, String focusArea }) async
    test('test meditationsControllerFindGuides', () async {
      // TODO
    });

    // Get current user meditation sessions history
    //
    //Future<BuiltList<JsonObject>> meditationsControllerFindSessions() async
    test('test meditationsControllerFindSessions', () async {
      // TODO
    });

  });
}
