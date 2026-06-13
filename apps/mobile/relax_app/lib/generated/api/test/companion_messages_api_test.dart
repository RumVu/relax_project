import 'package:test/test.dart';
import 'package:relax_api_client/relax_api_client.dart';


/// tests for CompanionMessagesApi
void main() {
  final instance = RelaxApiClient().getCompanionMessagesApi();

  group(CompanionMessagesApi, () {
    // Create a companion message
    //
    //Future<CompanionMessageResponseDto> companionMessagesControllerCreate(CreateCompanionMessageDto createCompanionMessageDto) async
    test('test companionMessagesControllerCreate', () async {
      // TODO
    });

    // List companion messages
    //
    //Future<CompanionMessagePageDto> companionMessagesControllerFindAll({ String q, String category, bool isActive, num skip, num limit }) async
    test('test companionMessagesControllerFindAll', () async {
      // TODO
    });

    // Get a random active companion message
    //
    //Future<CompanionMessageResponseDto> companionMessagesControllerFindRandom() async
    test('test companionMessagesControllerFindRandom', () async {
      // TODO
    });

    // Delete a companion message
    //
    //Future<CompanionMessageResponseDto> companionMessagesControllerRemove(String id) async
    test('test companionMessagesControllerRemove', () async {
      // TODO
    });

    // Update a companion message
    //
    //Future<CompanionMessageResponseDto> companionMessagesControllerUpdate(String id, UpdateCompanionMessageDto updateCompanionMessageDto) async
    test('test companionMessagesControllerUpdate', () async {
      // TODO
    });

  });
}
