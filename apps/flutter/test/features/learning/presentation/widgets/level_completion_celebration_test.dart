import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:plantini_app/features/catalog/domain/catalog_models.dart';
import 'package:plantini_app/features/learning/domain/learning_models.dart';
import 'package:plantini_app/features/learning/presentation/widgets/level_completion_celebration.dart';

void main() {
  Widget buildTestableWidget(Widget widget) {
    return MaterialApp(
      home: Scaffold(
        body: widget,
      ),
    );
  }

  testWidgets('shows passed celebration with next level unlocked', (WidgetTester tester) async {
    const level = Level(
      id: 'l1',
      ecosystemId: 'e1',
      title: 'Waldrand',
      sequence: 1,
      status: LevelStatus.completed,
      minimumScore: 0.8,
      requiredQuizIds: [],
      plantIds: ['p1', 'p2', 'p3'],
    );

    const nextLevel = Level(
      id: 'l2',
      ecosystemId: 'e1',
      title: 'Tief im Wald',
      sequence: 2,
      status: LevelStatus.available,
      minimumScore: 0.8,
      requiredQuizIds: [],
      plantIds: ['p4', 'p5'],
    );

    const completion = LevelCompletion(
      attemptId: 'a1',
      passed: true,
      score: 0.9,
      status: CompletionStatus.completed,
    );

    await tester.pumpWidget(buildTestableWidget(
      LevelCompletionCelebration(
        completion: completion,
        level: level,
        nextLevel: nextLevel,
      ),
    ));

    expect(find.text('Herzlichen Glückwunsch!'), findsOneWidget);
    expect(find.textContaining('Waldrand'), findsOneWidget);
    expect(find.text('90%'), findsOneWidget);
    expect(find.text('Tief im Wald'), findsOneWidget);
    expect(find.text('Zum nächsten Level'), findsOneWidget);
  });

  testWidgets('shows failed celebration', (WidgetTester tester) async {
    const level = Level(
      id: 'l1',
      ecosystemId: 'e1',
      title: 'Waldrand',
      sequence: 1,
      status: LevelStatus.available,
      minimumScore: 0.8,
      requiredQuizIds: [],
      plantIds: ['p1', 'p2', 'p3'],
    );

    const completion = LevelCompletion(
      attemptId: 'a2',
      passed: false,
      score: 0.6,
      status: CompletionStatus.completed,
    );

    await tester.pumpWidget(buildTestableWidget(
      LevelCompletionCelebration(
        completion: completion,
        level: level,
      ),
    ));

    expect(find.text('Fast geschafft!'), findsOneWidget);
    expect(find.textContaining('Waldrand'), findsOneWidget);
    expect(find.text('60%'), findsOneWidget);
    expect(find.text('Zurück zur Übersicht'), findsOneWidget);
    expect(find.text('Zum nächsten Level'), findsNothing);
  });
}
