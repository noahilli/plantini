import 'package:plantini_app/design_system/async_state_view.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:plantini_app/core/widgets/state_widgets.dart';

void main() {
  group('Catalog Feature States', () {
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
              child: EmptyState(title: 'Keine Ökosysteme'),
            ),
          ),
        ),
      );
      expect(find.text('Keine Ökosysteme'), findsOneWidget);
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
              child: ErrorState(message: 'Laden fehlgeschlagen'),
            ),
          ),
        ),
      );
      expect(find.text('Laden fehlgeschlagen'), findsOneWidget);
    });

    testWidgets('permission denied state renders correctly', (tester) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(
            body: SingleChildScrollView(
              child: PermissionDeniedState(reason: 'Zugriff verweigert'),
            ),
          ),
        ),
      );
      expect(find.text('Zugriff verweigert'), findsOneWidget);
    });

    testWidgets('Dark Mode Empty State', (tester) async {
      await tester.pumpWidget(
        MaterialApp(
          themeMode: ThemeMode.dark,
          darkTheme: ThemeData.dark(),
          home: const Scaffold(
            body: SingleChildScrollView(child: EmptyState(title: 'Dark Empty')),
          ),
        ),
      );
      expect(find.text('Dark Empty'), findsOneWidget);
    });

    testWidgets('Large Font Error State', (tester) async {
      await tester.pumpWidget(
        MaterialApp(
          builder: (context, child) => MediaQuery(
            data: MediaQuery.of(context)
                .copyWith(textScaler: const TextScaler.linear(3.0)),
            child: child!,
          ),
          home: const Scaffold(
            body: SingleChildScrollView(
              child: ErrorState(message: 'Large Error'),
            ),
          ),
        ),
      );
      expect(find.text('Large Error'), findsOneWidget);
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
