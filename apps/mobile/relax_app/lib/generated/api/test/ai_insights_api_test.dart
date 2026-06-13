import 'package:test/test.dart';
import 'package:relax_api_client/relax_api_client.dart';


/// tests for AiInsightsApi
void main() {
  final instance = RelaxApiClient().getAiInsightsApi();

  group(AiInsightsApi, () {
    // Get my recent AI insights and recommendations (auto-regenerates if stale).
    //
    //Future aiInsightsControllerGetMine({ num limit }) async
    test('test aiInsightsControllerGetMine', () async {
      // TODO
    });

    // Force regeneration of insights using the configured AI provider.
    //
    //Future aiInsightsControllerRefresh({ num limit }) async
    test('test aiInsightsControllerRefresh', () async {
      // TODO
    });

    // Mark an insight as useful / not useful.
    //
    //Future aiInsightsControllerSetFeedback(String id, FeedbackInsightDto feedbackInsightDto) async
    test('test aiInsightsControllerSetFeedback', () async {
      // TODO
    });

  });
}
