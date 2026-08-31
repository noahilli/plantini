import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:plantini_app/features/field/presentation/widgets/expected_plant_mismatch_consent.dart';

void main() {
  testWidgets('FIELD-06 requires an explicit mismatch decision', (
    tester,
  ) async {
    bool? accepted;
    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: ExpectedPlantMismatchConsent(
            expectedPlantName: 'Stieleiche',
            value: false,
            onChanged: (value) => accepted = value,
          ),
        ),
      ),
    );

    expect(find.textContaining('Gesucht war Stieleiche'), findsOneWidget);
    expect(find.byKey(const ValueKey('field-accept-mismatch')), findsOneWidget);
    await tester.tap(find.byType(Checkbox));
    expect(accepted, isTrue);
  });
}
