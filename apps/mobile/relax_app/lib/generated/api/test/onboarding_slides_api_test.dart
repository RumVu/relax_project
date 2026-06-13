import 'package:test/test.dart';
import 'package:relax_api_client/relax_api_client.dart';


/// tests for OnboardingSlidesApi
void main() {
  final instance = RelaxApiClient().getOnboardingSlidesApi();

  group(OnboardingSlidesApi, () {
    // Create an onboarding slide
    //
    //Future<OnboardingSlideResponseDto> onboardingSlidesControllerCreate(CreateOnboardingSlideDto createOnboardingSlideDto) async
    test('test onboardingSlidesControllerCreate', () async {
      // TODO
    });

    // List onboarding slides
    //
    //Future<OnboardingSlidePageDto> onboardingSlidesControllerFindAll({ String q, String category, bool isActive, num skip, num limit }) async
    test('test onboardingSlidesControllerFindAll', () async {
      // TODO
    });

    // Delete an onboarding slide
    //
    //Future<OnboardingSlideResponseDto> onboardingSlidesControllerRemove(String id) async
    test('test onboardingSlidesControllerRemove', () async {
      // TODO
    });

    // Update an onboarding slide
    //
    //Future<OnboardingSlideResponseDto> onboardingSlidesControllerUpdate(String id, UpdateOnboardingSlideDto updateOnboardingSlideDto) async
    test('test onboardingSlidesControllerUpdate', () async {
      // TODO
    });

  });
}
