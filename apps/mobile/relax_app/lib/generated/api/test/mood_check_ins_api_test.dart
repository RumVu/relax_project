import 'package:test/test.dart';
import 'package:relax_api_client/relax_api_client.dart';


/// tests for MoodCheckInsApi
void main() {
  final instance = RelaxApiClient().getMoodCheckInsApi();

  group(MoodCheckInsApi, () {
    // Create current user mood check-in
    //
    //Future<MoodCheckinResponseDto> moodCheckinsControllerCreateMine(CreateMoodCheckinDto createMoodCheckinDto) async
    test('test moodCheckinsControllerCreateMine', () async {
      // TODO
    });

    // List all mood check-ins (admin)
    //
    //Future<MoodCheckinPageDto> moodCheckinsControllerFindAll({ JsonObject mood, DateTime from, DateTime to, num skip, num limit }) async
    test('test moodCheckinsControllerFindAll', () async {
      // TODO
    });

    // List mood check-ins by user id (admin)
    //
    //Future<MoodCheckinPageDto> moodCheckinsControllerFindByUserId(String userId, { JsonObject mood, DateTime from, DateTime to, num skip, num limit }) async
    test('test moodCheckinsControllerFindByUserId', () async {
      // TODO
    });

    // List current user mood check-ins
    //
    //Future<MoodCheckinPageDto> moodCheckinsControllerFindMine({ JsonObject mood, DateTime from, DateTime to, num skip, num limit }) async
    test('test moodCheckinsControllerFindMine', () async {
      // TODO
    });

    // Get current user latest mood check-in
    //
    //Future<MoodCheckinResponseDto> moodCheckinsControllerFindMineLatest() async
    test('test moodCheckinsControllerFindMineLatest', () async {
      // TODO
    });

    // Get one mood check-in by id
    //
    //Future<MoodCheckinResponseDto> moodCheckinsControllerFindOne(String id) async
    test('test moodCheckinsControllerFindOne', () async {
      // TODO
    });

    // Get mood analytics by user id (admin)
    //
    //Future<JsonObject> moodCheckinsControllerGetAnalyticsByUserId(String userId, { String period, DateTime from, DateTime to, bool compare, num timezoneOffsetMinutes, String timezone }) async
    test('test moodCheckinsControllerGetAnalyticsByUserId', () async {
      // TODO
    });

    // Get current user mood analytics timeline
    //
    //Future<JsonObject> moodCheckinsControllerGetMineAnalytics({ String period, DateTime from, DateTime to, bool compare, num timezoneOffsetMinutes, String timezone }) async
    test('test moodCheckinsControllerGetMineAnalytics', () async {
      // TODO
    });

    // Get current user mood dashboard
    //
    //Future<JsonObject> moodCheckinsControllerGetMineDashboard({ JsonObject mood, DateTime from, DateTime to, num skip, num limit }) async
    test('test moodCheckinsControllerGetMineDashboard', () async {
      // TODO
    });

    // Get recommended relax actions for a mood
    //
    //Future<BuiltList<String>> moodCheckinsControllerGetMineRecommendations({ String mood }) async
    test('test moodCheckinsControllerGetMineRecommendations', () async {
      // TODO
    });

    // Get current user mood statistics
    //
    //Future<JsonObject> moodCheckinsControllerGetMineStats({ JsonObject mood, DateTime from, DateTime to, num skip, num limit }) async
    test('test moodCheckinsControllerGetMineStats', () async {
      // TODO
    });

    // Get current user materialized weekly mood stats
    //
    //Future<BuiltList<WeeklyMoodStatResponseDto>> moodCheckinsControllerGetMineWeeklyStats({ JsonObject mood, DateTime from, DateTime to, num skip, num limit }) async
    test('test moodCheckinsControllerGetMineWeeklyStats', () async {
      // TODO
    });

    // List mood options for the mood onboarding screen
    //
    //Future<BuiltList<String>> moodCheckinsControllerGetOptions() async
    test('test moodCheckinsControllerGetOptions', () async {
      // TODO
    });

    // Get mood statistics by user id (admin)
    //
    //Future<JsonObject> moodCheckinsControllerGetStatsByUserId(String userId, { JsonObject mood, DateTime from, DateTime to, num skip, num limit }) async
    test('test moodCheckinsControllerGetStatsByUserId', () async {
      // TODO
    });

    // Get materialized weekly mood stats by user id (admin)
    //
    //Future<BuiltList<WeeklyMoodStatResponseDto>> moodCheckinsControllerGetWeeklyStatsByUserId(String userId, { JsonObject mood, DateTime from, DateTime to, num skip, num limit }) async
    test('test moodCheckinsControllerGetWeeklyStatsByUserId', () async {
      // TODO
    });

    // Recalculate current user materialized weekly mood stats
    //
    //Future<JsonObject> moodCheckinsControllerRecalculateMineWeeklyStats(RecalculateWeeklyMoodStatsDto recalculateWeeklyMoodStatsDto) async
    test('test moodCheckinsControllerRecalculateMineWeeklyStats', () async {
      // TODO
    });

    // Recalculate weekly mood stats by user id (admin)
    //
    //Future<JsonObject> moodCheckinsControllerRecalculateWeeklyStatsByUserId(String userId, RecalculateWeeklyMoodStatsDto recalculateWeeklyMoodStatsDto) async
    test('test moodCheckinsControllerRecalculateWeeklyStatsByUserId', () async {
      // TODO
    });

    // Delete one mood check-in by id
    //
    //Future<MoodCheckinResponseDto> moodCheckinsControllerRemove(String id) async
    test('test moodCheckinsControllerRemove', () async {
      // TODO
    });

    // Update one mood check-in by id
    //
    //Future<MoodCheckinResponseDto> moodCheckinsControllerUpdate(String id, UpdateMoodCheckinDto updateMoodCheckinDto) async
    test('test moodCheckinsControllerUpdate', () async {
      // TODO
    });

  });
}
