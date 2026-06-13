import 'package:test/test.dart';
import 'package:relax_api_client/relax_api_client.dart';


/// tests for SleepApi
void main() {
  final instance = RelaxApiClient().getSleepApi();

  group(SleepApi, () {
    // Log a sleep session
    //
    //Future sleepControllerCreateSession(CreateSleepSessionDto createSleepSessionDto) async
    test('test sleepControllerCreateSession', () async {
      // TODO
    });

    // Get current user sleep history
    //
    //Future sleepControllerFindSessions() async
    test('test sleepControllerFindSessions', () async {
      // TODO
    });

  });
}
