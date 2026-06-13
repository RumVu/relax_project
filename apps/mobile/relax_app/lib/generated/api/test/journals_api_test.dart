import 'package:test/test.dart';
import 'package:relax_api_client/relax_api_client.dart';


/// tests for JournalsApi
void main() {
  final instance = RelaxApiClient().getJournalsApi();

  group(JournalsApi, () {
    // Create current user journal
    //
    //Future<JournalResponseDto> journalsControllerCreateMine(CreateJournalDto createJournalDto) async
    test('test journalsControllerCreateMine', () async {
      // TODO
    });

    // List journals by user id (admin)
    //
    //Future<JournalPageDto> journalsControllerFindByUserId(String userId, { String q, JsonObject mood, String tag, bool isFavorite, DateTime from, DateTime to, num skip, num limit }) async
    test('test journalsControllerFindByUserId', () async {
      // TODO
    });

    // List current user journals
    //
    //Future<JournalPageDto> journalsControllerFindMine({ String q, JsonObject mood, String tag, bool isFavorite, DateTime from, DateTime to, num skip, num limit }) async
    test('test journalsControllerFindMine', () async {
      // TODO
    });

    // Get one journal by id
    //
    //Future<JournalResponseDto> journalsControllerFindOne(String id) async
    test('test journalsControllerFindOne', () async {
      // TODO
    });

    // Get current user journal stats
    //
    //Future<JsonObject> journalsControllerGetMineStats({ String q, JsonObject mood, String tag, bool isFavorite, DateTime from, DateTime to, num skip, num limit }) async
    test('test journalsControllerGetMineStats', () async {
      // TODO
    });

    // Delete one journal by id
    //
    //Future<JournalResponseDto> journalsControllerRemove(String id) async
    test('test journalsControllerRemove', () async {
      // TODO
    });

    // Update one journal by id
    //
    //Future<JournalResponseDto> journalsControllerUpdate(String id, UpdateJournalDto updateJournalDto) async
    test('test journalsControllerUpdate', () async {
      // TODO
    });

  });
}
