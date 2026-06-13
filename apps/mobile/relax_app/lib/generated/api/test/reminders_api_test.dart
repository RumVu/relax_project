import 'package:test/test.dart';
import 'package:relax_api_client/relax_api_client.dart';


/// tests for RemindersApi
void main() {
  final instance = RelaxApiClient().getRemindersApi();

  group(RemindersApi, () {
    // Create current user reminder
    //
    //Future<ReminderResponseDto> remindersControllerCreateMine(CreateReminderDto createReminderDto) async
    test('test remindersControllerCreateMine', () async {
      // TODO
    });

    // Get one reminder by id
    //
    //Future<ReminderResponseDto> remindersControllerFindOne(String id) async
    test('test remindersControllerFindOne', () async {
      // TODO
    });

    // Get current user reminder stats
    //
    //Future<JsonObject> remindersControllerGetMineStats() async
    test('test remindersControllerGetMineStats', () async {
      // TODO
    });

    // List all reminders (admin)
    //
    //Future<ReminderPageDto> remindersControllerListAll({ JsonObject type, bool isActive, DateTime from, DateTime to, num skip, num limit }) async
    test('test remindersControllerListAll', () async {
      // TODO
    });

    // List reminders by user id (admin)
    //
    //Future<ReminderPageDto> remindersControllerListByUserId(String userId, { JsonObject type, bool isActive, DateTime from, DateTime to, num skip, num limit }) async
    test('test remindersControllerListByUserId', () async {
      // TODO
    });

    // List current user reminders
    //
    //Future<ReminderPageDto> remindersControllerListMine({ JsonObject type, bool isActive, DateTime from, DateTime to, num skip, num limit }) async
    test('test remindersControllerListMine', () async {
      // TODO
    });

    // Delete one reminder by id
    //
    //Future<JsonObject> remindersControllerRemove(String id) async
    test('test remindersControllerRemove', () async {
      // TODO
    });

    // Update one reminder by id
    //
    //Future<ReminderResponseDto> remindersControllerUpdate(String id, UpdateReminderDto updateReminderDto) async
    test('test remindersControllerUpdate', () async {
      // TODO
    });

  });
}
