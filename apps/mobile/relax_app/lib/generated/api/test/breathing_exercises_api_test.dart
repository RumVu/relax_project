import 'package:test/test.dart';
import 'package:relax_api_client/relax_api_client.dart';


/// tests for BreathingExercisesApi
void main() {
  final instance = RelaxApiClient().getBreathingExercisesApi();

  group(BreathingExercisesApi, () {
    // Create a breathing exercise
    //
    //Future<BreathingExerciseResponseDto> breathingExercisesControllerCreate(CreateBreathingExerciseDto createBreathingExerciseDto) async
    test('test breathingExercisesControllerCreate', () async {
      // TODO
    });

    // List breathing exercises
    //
    //Future<BreathingExercisePageDto> breathingExercisesControllerFindAll({ String q, String category, bool isActive, num skip, num limit }) async
    test('test breathingExercisesControllerFindAll', () async {
      // TODO
    });

    // Delete a breathing exercise
    //
    //Future<BreathingExerciseResponseDto> breathingExercisesControllerRemove(String id) async
    test('test breathingExercisesControllerRemove', () async {
      // TODO
    });

    // Update a breathing exercise
    //
    //Future<BreathingExerciseResponseDto> breathingExercisesControllerUpdate(String id, UpdateBreathingExerciseDto updateBreathingExerciseDto) async
    test('test breathingExercisesControllerUpdate', () async {
      // TODO
    });

  });
}
