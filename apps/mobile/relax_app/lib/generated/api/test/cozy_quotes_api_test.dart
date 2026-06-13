import 'package:test/test.dart';
import 'package:relax_api_client/relax_api_client.dart';


/// tests for CozyQuotesApi
void main() {
  final instance = RelaxApiClient().getCozyQuotesApi();

  group(CozyQuotesApi, () {
    // Create a cozy quote
    //
    //Future<CozyQuoteResponseDto> cozyQuotesControllerCreate(CreateCozyQuoteDto createCozyQuoteDto) async
    test('test cozyQuotesControllerCreate', () async {
      // TODO
    });

    // List cozy quotes
    //
    //Future<CozyQuotePageDto> cozyQuotesControllerFindAll({ String q, String category, bool isActive, num skip, num limit }) async
    test('test cozyQuotesControllerFindAll', () async {
      // TODO
    });

    // List cozy quotes by mood
    //
    //Future<BuiltList<CozyQuoteResponseDto>> cozyQuotesControllerFindByMood(String mood) async
    test('test cozyQuotesControllerFindByMood', () async {
      // TODO
    });

    // Get a random active cozy quote
    //
    //Future<CozyQuoteResponseDto> cozyQuotesControllerFindRandom({ String lang }) async
    test('test cozyQuotesControllerFindRandom', () async {
      // TODO
    });

    // Delete a cozy quote
    //
    //Future<CozyQuoteResponseDto> cozyQuotesControllerRemove(String id) async
    test('test cozyQuotesControllerRemove', () async {
      // TODO
    });

    // Update a cozy quote
    //
    //Future<CozyQuoteResponseDto> cozyQuotesControllerUpdate(String id, UpdateCozyQuoteDto updateCozyQuoteDto) async
    test('test cozyQuotesControllerUpdate', () async {
      // TODO
    });

  });
}
