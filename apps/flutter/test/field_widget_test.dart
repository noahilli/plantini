import 'package:plantini_app/design_system/async_state_view.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:plantini_app/core/widgets/state_widgets.dart';

void main() {
  group('Field Feature States', () {
    testWidgets('loading state renders correctly', (tester) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(body: SingleChildScrollView(child: LoadingState())),
        ),
      );
      expect(find.byType(CircularProgressIndicator), findsOneWidget);
    });

    testWidgets('empty state renders correctly', (tester) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(
            body: SingleChildScrollView(
              child: EmptyState(title: 'Kein Foto aufgenommen'),
            ),
          ),
        ),
      );
      expect(find.text('Kein Foto aufgenommen'), findsOneWidget);
    });

    testWidgets('offline state renders correctly', (tester) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(body: SingleChildScrollView(child: OfflineState())),
        ),
      );
      expect(find.text('Keine Internetverbindung'), findsOneWidget);
    });

    testWidgets('error state renders correctly', (tester) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(
            body: SingleChildScrollView(
              child: ErrorState(message: 'Bestimmung fehlgeschlagen'),
            ),
          ),
        ),
      );
      expect(find.text('Bestimmung fehlgeschlagen'), findsOneWidget);
    });

    testWidgets('permission denied state renders correctly', (tester) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(
            body: SingleChildScrollView(
              child: PermissionDeniedState(reason: 'Kamerazugriff verweigert'),
            ),
          ),
        ),
      );
      expect(find.text('Kamerazugriff verweigert'), findsOneWidget);
    });

    testWidgets('Dark Mode Error State', (tester) async {
      await tester.pumpWidget(
        MaterialApp(
          themeMode: ThemeMode.dark,
          darkTheme: ThemeData.dark(),
          home: const Scaffold(
            body: SingleChildScrollView(
              child: ErrorState(message: 'Dark Error'),
            ),
          ),
        ),
      );
      expect(find.text('Dark Error'), findsOneWidget);
    });

    testWidgets('Large Font Offline State', (tester) async {
      await tester.pumpWidget(
        MaterialApp(
          builder: (context, child) => MediaQuery(
            data: MediaQuery.of(context)
                .copyWith(textScaler: const TextScaler.linear(3.0)),
            child: child!,
          ),
          home: const Scaffold(
            body: SingleChildScrollView(child: OfflineState()),
          ),
        ),
      );
      expect(find.text('Keine Internetverbindung'), findsOneWidget);
    });

    testWidgets('stale state renders correctly via AsyncStateView', (
      tester,
    ) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(
            body: SingleChildScrollView(
              child: AsyncStateView(kind: AsyncViewKind.stale),
            ),
          ),
        ),
      );
      expect(find.text('Lokaler Stand'), findsOneWidget);
    });
  });
}
