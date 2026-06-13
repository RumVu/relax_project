import 'package:test/test.dart';
import 'package:relax_api_client/relax_api_client.dart';


/// tests for NotificationsApi
void main() {
  final instance = RelaxApiClient().getNotificationsApi();

  group(NotificationsApi, () {
    // Create a notification for any user (admin)
    //
    //Future<JsonObject> notificationsControllerCreateForUser(String userId, CreateNotificationDto createNotificationDto) async
    test('test notificationsControllerCreateForUser', () async {
      // TODO
    });

    // Create a test notification for current user
    //
    //Future<JsonObject> notificationsControllerCreateTest(CreateNotificationDto createNotificationDto) async
    test('test notificationsControllerCreateTest', () async {
      // TODO
    });

    // Get push/email provider configuration status
    //
    //Future<ProviderStatusResponseDto> notificationsControllerGetProviderStatus() async
    test('test notificationsControllerGetProviderStatus', () async {
      // TODO
    });

    // Get unread notification count
    //
    //Future<UnreadCountResponseDto> notificationsControllerGetUnreadCount() async
    test('test notificationsControllerGetUnreadCount', () async {
      // TODO
    });

    // List current user push devices
    //
    //Future<BuiltList<PushDeviceResponseDto>> notificationsControllerListDevices() async
    test('test notificationsControllerListDevices', () async {
      // TODO
    });

    // List current user notifications
    //
    //Future<NotificationPageDto> notificationsControllerListMine({ JsonObject type, bool isRead, num skip, num limit }) async
    test('test notificationsControllerListMine', () async {
      // TODO
    });

    // Mark all current user notifications as read
    //
    //Future<JsonObject> notificationsControllerMarkAllRead() async
    test('test notificationsControllerMarkAllRead', () async {
      // TODO
    });

    // Mark one notification as read
    //
    //Future<NotificationResponseDto> notificationsControllerMarkRead(String id) async
    test('test notificationsControllerMarkRead', () async {
      // TODO
    });

    // Register or update current user push device
    //
    //Future<PushDeviceResponseDto> notificationsControllerRegisterDevice(RegisterPushDeviceDto registerPushDeviceDto) async
    test('test notificationsControllerRegisterDevice', () async {
      // TODO
    });

    // Remove a current user push device
    //
    //Future<JsonObject> notificationsControllerRemoveDevice(String id) async
    test('test notificationsControllerRemoveDevice', () async {
      // TODO
    });

  });
}
