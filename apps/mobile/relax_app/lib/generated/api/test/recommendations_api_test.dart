import 'package:test/test.dart';
import 'package:relax_api_client/relax_api_client.dart';


/// tests for RecommendationsApi
void main() {
  final instance = RelaxApiClient().getRecommendationsApi();

  group(RecommendationsApi, () {
    // Get my content ratings
    //
    //Future recommendationsControllerGetMyRatings() async
    test('test recommendationsControllerGetMyRatings', () async {
      // TODO
    });

    // Get today smart recommendations for current user
    //
    //Future recommendationsControllerGetToday() async
    test('test recommendationsControllerGetToday', () async {
      // TODO
    });

    // Get trigger analytics for current user
    //
    //Future recommendationsControllerGetTriggerAnalytics() async
    test('test recommendationsControllerGetTriggerAnalytics', () async {
      // TODO
    });

    // Rate a content item
    //
    //Future recommendationsControllerRateContent(RateContentDto rateContentDto) async
    test('test recommendationsControllerRateContent', () async {
      // TODO
    });

    // Refresh recommendations for current user
    //
    //Future recommendationsControllerRefresh() async
    test('test recommendationsControllerRefresh', () async {
      // TODO
    });

  });
}
