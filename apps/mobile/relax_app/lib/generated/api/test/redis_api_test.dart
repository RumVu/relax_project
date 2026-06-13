import 'package:test/test.dart';
import 'package:relax_api_client/relax_api_client.dart';


/// tests for RedisApi
void main() {
  final instance = RelaxApiClient().getRedisApi();

  group(RedisApi, () {
    // Get Redis configuration and optional deep connectivity health
    //
    //Future redisControllerHealth({ String deep }) async
    test('test redisControllerHealth', () async {
      // TODO
    });

  });
}
