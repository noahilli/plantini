import 'package:test/test.dart';
import 'package:openapi/openapi.dart';

// tests for EcosystemProgress
void main() {
  final instance = EcosystemProgressBuilder();
  // TODO add properties to the builder and call build()

  group(EcosystemProgress, () {
    // String ecosystemId
    test('to test the property `ecosystemId`', () async {
      // TODO
    });

    // String status
    test('to test the property `status`', () async {
      // TODO
    });

    // True only when every published level has a server-passed attempt and every target species is collected.
    // bool completed
    test('to test the property `completed`', () async {
      // TODO
    });

    // int totalLevels
    test('to test the property `totalLevels`', () async {
      // TODO
    });

    // int completedLevelCount
    test('to test the property `completedLevelCount`', () async {
      // TODO
    });

    // Passed level IDs in sequence order.
    // BuiltSet<String> completedLevelIds
    test('to test the property `completedLevelIds`', () async {
      // TODO
    });

    // BuiltSet<String> requiredPlantIds
    test('to test the property `requiredPlantIds`', () async {
      // TODO
    });

    // Distinct collected required species only.
    // BuiltSet<String> collectedPlantIds
    test('to test the property `collectedPlantIds`', () async {
      // TODO
    });

    // BuiltSet<String> missingPlantIds
    test('to test the property `missingPlantIds`', () async {
      // TODO
    });
  });
}
