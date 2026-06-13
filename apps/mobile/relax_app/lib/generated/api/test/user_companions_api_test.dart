import 'package:test/test.dart';
import 'package:relax_api_client/relax_api_client.dart';


/// tests for UserCompanionsApi
void main() {
  final instance = RelaxApiClient().getUserCompanionsApi();

  group(UserCompanionsApi, () {
    // Chat with user companion using AI
    //
    //Future<JsonObject> userCompanionsControllerChat(CompanionChatDto companionChatDto) async
    test('test userCompanionsControllerChat', () async {
      // TODO
    });

    // Get companion chat history
    //
    //Future<JsonObject> userCompanionsControllerGetChatHistory() async
    test('test userCompanionsControllerGetChatHistory', () async {
      // TODO
    });

    // Get current user companion
    //
    //Future<UserCompanionResponseDto> userCompanionsControllerGetMine() async
    test('test userCompanionsControllerGetMine', () async {
      // TODO
    });

    // Get companion personalization options
    //
    //Future<JsonObject> userCompanionsControllerGetPersonalizationOptions() async
    test('test userCompanionsControllerGetPersonalizationOptions', () async {
      // TODO
    });

    // Get current user companion stats
    //
    //Future<JsonObject> userCompanionsControllerGetStats() async
    test('test userCompanionsControllerGetStats', () async {
      // TODO
    });

    // Create companion interaction
    //
    //Future<JsonObject> userCompanionsControllerInteract(CreateCompanionInteractionDto createCompanionInteractionDto) async
    test('test userCompanionsControllerInteract', () async {
      // TODO
    });

    // Switch companion personalization mode while preserving or resetting progress
    //
    //Future<JsonObject> userCompanionsControllerSwitchPersonalization(SwitchCompanionPersonalizationDto switchCompanionPersonalizationDto) async
    test('test userCompanionsControllerSwitchPersonalization', () async {
      // TODO
    });

    // Upsert current user companion
    //
    //Future<UserCompanionResponseDto> userCompanionsControllerUpsertMine(UpsertUserCompanionDto upsertUserCompanionDto) async
    test('test userCompanionsControllerUpsertMine', () async {
      // TODO
    });

  });
}
