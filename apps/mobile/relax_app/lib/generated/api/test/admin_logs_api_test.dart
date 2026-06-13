import 'package:test/test.dart';
import 'package:relax_api_client/relax_api_client.dart';


/// tests for AdminLogsApi
void main() {
  final instance = RelaxApiClient().getAdminLogsApi();

  group(AdminLogsApi, () {
    // List admin audit logs
    //
    //Future<AdminLogPageDto> adminLogsControllerFindAll({ String adminId, String action, String targetType, String targetId, DateTime from, DateTime to, num skip, num limit }) async
    test('test adminLogsControllerFindAll', () async {
      // TODO
    });

  });
}
