import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:plantini_app/auth/auth_service.dart';
import 'package:plantini_app/main.dart';

void main() {
  testWidgets('Plantini Login Screen smoke test', (WidgetTester tester) async {
    final authService = AuthService();

    await tester.pumpWidget(
      MaterialApp(
        home: AuthWrapper(
          authService: authService,
        ),
      ),
    );

    expect(find.text('Plantini Login'), findsOneWidget);
    expect(find.text('Login with Keycloak'), findsOneWidget);
  });
}
