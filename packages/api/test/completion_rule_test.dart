import 'package:test/test.dart';
import 'package:openapi/openapi.dart';

// tests for CompletionRule
void main() {
  final instance = CompletionRuleBuilder();
  // TODO add properties to the builder and call build()

  group(CompletionRule, () {
    // num minimumScore
    test('to test the property `minimumScore`', () async {
      // TODO
    });

    // BuiltList<String> requiredQuizIds
    test('to test the property `requiredQuizIds`', () async {
      // TODO
    });

    // BuiltList<String> requiredLevelIds
    test('to test the property `requiredLevelIds`', () async {
      // TODO
    });

    // Explicit collection targets. Ecosystem-scoped ordinary levels return []; only the final level lists the three public UUIDs. Clients must not infer targets from plantIds.
    // BuiltSet<String> requiredPlantIds
    test('to test the property `requiredPlantIds`', () async {
      // TODO
    });

    // Legacy rules default to level and retain their per-level collection gate. Ecosystem rules never block quiz completion; GET ecosystem progress evaluates the final collection gate.
    // String collectionScope (default value: 'level')
    test('to test the property `collectionScope`', () async {
      // TODO
    });
  });
}
