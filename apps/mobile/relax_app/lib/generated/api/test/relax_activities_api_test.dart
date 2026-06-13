import 'package:test/test.dart';
import 'package:relax_api_client/relax_api_client.dart';


/// tests for RelaxActivitiesApi
void main() {
  final instance = RelaxApiClient().getRelaxActivitiesApi();

  group(RelaxActivitiesApi, () {
    // Finish current user relax activity session
    //
    //Future<JsonObject> relaxActivitiesControllerFinishSession(String id, FinishRelaxSessionDto finishRelaxSessionDto) async
    test('test relaxActivitiesControllerFinishSession', () async {
      // TODO
    });

    // List relax activity options
    //
    //Future<JsonObject> relaxActivitiesControllerGetActivities() async
    test('test relaxActivitiesControllerGetActivities', () async {
      // TODO
    });

    // Get current user relax statistics
    //
    //Future<JsonObject> relaxActivitiesControllerGetStats({ JsonObject activityType, String period, DateTime from, DateTime to, num skip, num limit, num timezoneOffsetMinutes, String timezone }) async
    test('test relaxActivitiesControllerGetStats', () async {
      // TODO
    });

    // List current user finished relax sessions
    //
    //Future<RelaxSessionPageDto> relaxActivitiesControllerListSessions({ JsonObject activityType, String period, DateTime from, DateTime to, num skip, num limit, num timezoneOffsetMinutes, String timezone }) async
    test('test relaxActivitiesControllerListSessions', () async {
      // TODO
    });

    // Start current user relax activity session
    //
    //Future<RelaxSessionResponseDto> relaxActivitiesControllerStartSession(StartRelaxSessionDto startRelaxSessionDto) async
    test('test relaxActivitiesControllerStartSession', () async {
      // TODO
    });

  });
}
