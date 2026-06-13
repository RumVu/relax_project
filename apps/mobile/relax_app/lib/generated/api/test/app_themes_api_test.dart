import 'package:test/test.dart';
import 'package:relax_api_client/relax_api_client.dart';


/// tests for AppThemesApi
void main() {
  final instance = RelaxApiClient().getAppThemesApi();

  group(AppThemesApi, () {
    // Create an app theme
    //
    //Future<AppThemeResponseDto> appThemesControllerCreate(CreateAppThemeDto createAppThemeDto) async
    test('test appThemesControllerCreate', () async {
      // TODO
    });

    // List app themes
    //
    //Future<AppThemePageDto> appThemesControllerFindAll({ String q, String category, bool isActive, num skip, num limit }) async
    test('test appThemesControllerFindAll', () async {
      // TODO
    });

    // Get the default app theme
    //
    //Future<AppThemeResponseDto> appThemesControllerFindDefault() async
    test('test appThemesControllerFindDefault', () async {
      // TODO
    });

    // Delete an app theme
    //
    //Future<AppThemeResponseDto> appThemesControllerRemove(String id) async
    test('test appThemesControllerRemove', () async {
      // TODO
    });

    // Update an app theme
    //
    //Future<AppThemeResponseDto> appThemesControllerUpdate(String id, UpdateAppThemeDto updateAppThemeDto) async
    test('test appThemesControllerUpdate', () async {
      // TODO
    });

  });
}
