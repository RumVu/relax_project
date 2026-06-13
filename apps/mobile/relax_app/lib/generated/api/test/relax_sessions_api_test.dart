import 'package:test/test.dart';
import 'package:relax_api_client/relax_api_client.dart';


/// tests for RelaxSessionsApi
void main() {
  final instance = RelaxApiClient().getRelaxSessionsApi();

  group(RelaxSessionsApi, () {
    // Finish current user relax session
    //
    //Future<JsonObject> relaxSessionsControllerFinish(String id, FinishRelaxSessionDto finishRelaxSessionDto) async
    test('test relaxSessionsControllerFinish', () async {
      // TODO
    });

    // List current user relax sessions
    //
    //Future<RelaxSessionPageDto> relaxSessionsControllerList({ JsonObject activityType, String period, DateTime from, DateTime to, num skip, num limit, num timezoneOffsetMinutes, String timezone }) async
    test('test relaxSessionsControllerList', () async {
      // TODO
    });

    // Start current user relax session
    //
    //Future<RelaxSessionResponseDto> relaxSessionsControllerStart(StartRelaxSessionDto startRelaxSessionDto) async
    test('test relaxSessionsControllerStart', () async {
      // TODO
    });

    // Get current user relax session stats
    //
    //Future<JsonObject> relaxSessionsControllerStats({ JsonObject activityType, String period, DateTime from, DateTime to, num skip, num limit, num timezoneOffsetMinutes, String timezone }) async
    test('test relaxSessionsControllerStats', () async {
      // TODO
    });

  });
}
