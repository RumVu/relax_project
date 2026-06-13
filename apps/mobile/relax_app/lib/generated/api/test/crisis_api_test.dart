import 'package:test/test.dart';
import 'package:relax_api_client/relax_api_client.dart';


/// tests for CrisisApi
void main() {
  final instance = RelaxApiClient().getCrisisApi();

  group(CrisisApi, () {
    // Check text content for crisis indicators
    //
    //Future crisisControllerCheckContent(CheckContentDto checkContentDto) async
    test('test crisisControllerCheckContent', () async {
      // TODO
    });

    // Get safety disclaimer
    //
    //Future crisisControllerGetDisclaimer() async
    test('test crisisControllerGetDisclaimer', () async {
      // TODO
    });

    // Get crisis hotlines
    //
    //Future crisisControllerGetHotlines({ String country }) async
    test('test crisisControllerGetHotlines', () async {
      // TODO
    });

  });
}
