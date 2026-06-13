import 'package:test/test.dart';
import 'package:relax_api_client/relax_api_client.dart';


/// tests for ExperimentsApi
void main() {
  final instance = RelaxApiClient().getExperimentsApi();

  group(ExperimentsApi, () {
    // Create an experiment (admin)
    //
    //Future experimentsControllerCreate(CreateExperimentDto createExperimentDto) async
    test('test experimentsControllerCreate', () async {
      // TODO
    });

    // Delete an experiment (admin)
    //
    //Future experimentsControllerDelete(String key) async
    test('test experimentsControllerDelete', () async {
      // TODO
    });

    // List all experiments (admin)
    //
    //Future experimentsControllerFindAll() async
    test('test experimentsControllerFindAll', () async {
      // TODO
    });

    // Get my assignment for a specific experiment
    //
    //Future experimentsControllerGetAssignment(String key) async
    test('test experimentsControllerGetAssignment', () async {
      // TODO
    });

    // Get all my experiment assignments
    //
    //Future experimentsControllerGetMyAssignments() async
    test('test experimentsControllerGetMyAssignments', () async {
      // TODO
    });

    // Log an experiment event
    //
    //Future experimentsControllerLogEvent(LogExperimentEventDto logExperimentEventDto) async
    test('test experimentsControllerLogEvent', () async {
      // TODO
    });

    // Update an experiment (admin)
    //
    //Future experimentsControllerUpdate(String key, UpdateExperimentDto updateExperimentDto) async
    test('test experimentsControllerUpdate', () async {
      // TODO
    });

  });
}
