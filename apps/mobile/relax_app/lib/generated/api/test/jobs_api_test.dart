import 'package:test/test.dart';
import 'package:relax_api_client/relax_api_client.dart';


/// tests for JobsApi
void main() {
  final instance = RelaxApiClient().getJobsApi();

  group(JobsApi, () {
    // Enqueue weekly mood stats materialization job (admin)
    //
    //Future<JsonObject> jobsControllerEnqueueWeeklyMoodStats(RunWeeklyMoodStatsJobDto runWeeklyMoodStatsJobDto) async
    test('test jobsControllerEnqueueWeeklyMoodStats', () async {
      // TODO
    });

    // Get backend job status (admin)
    //
    //Future<JsonObject> jobsControllerGetStatus() async
    test('test jobsControllerGetStatus', () async {
      // TODO
    });

    // Run weekly mood stats materialization job (admin)
    //
    //Future<JsonObject> jobsControllerRunWeeklyMoodStats(RunWeeklyMoodStatsJobDto runWeeklyMoodStatsJobDto) async
    test('test jobsControllerRunWeeklyMoodStats', () async {
      // TODO
    });

  });
}
