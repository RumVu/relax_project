import 'package:test/test.dart';
import 'package:relax_api_client/relax_api_client.dart';


/// tests for FeedApi
void main() {
  final instance = RelaxApiClient().getFeedApi();

  group(FeedApi, () {
    //Future<BuiltList<JsonObject>> feedControllerGetMyFeed() async
    test('test feedControllerGetMyFeed', () async {
      // TODO
    });

  });
}
