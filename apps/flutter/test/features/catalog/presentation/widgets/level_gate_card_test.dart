import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:plantini_app/features/catalog/domain/catalog_models.dart';
import 'package:plantini_app/features/catalog/presentation/widgets/level_gate_card.dart';

void main() {
  Widget buildTestableWidget(Widget widget) {
    return MaterialApp(home: Scaffold(body: widget));
  }

  testWidgets('shows available level correctly', (WidgetTester tester) async {
    const level = Level(
      id: 'l1',
      ecosystemId: 'e1',
      title: 'Waldrand',
      sequence: 1,
      status: LevelStatus.available,
      minimumScore: 0.8,
      requiredQuizIds: [],
      plantIds: ['p1', 'p2', 'p3'],
      learningGoal: 'Die Pflanzen am Waldrand kennenlernen',
      progress: 0.0,
    );

    await tester.pumpWidget(buildTestableWidget(LevelGateCard(level: level)));

    expect(find.text('Waldrand'), findsOneWidget);
    expect(find.text('Die Pflanzen am Waldrand kennenlernen'), findsOneWidget);
    expect(find.text('3 Arten in diesem Level'), findsOneWidget);
    expect(find.byType(LinearProgressIndicator), findsOneWidget);
  });

  testWidgets('shows completed level correctly', (WidgetTester tester) async {
    const level = Level(
      id: 'l2',
      ecosystemId: 'e1',
      title: 'Tief im Wald',
      sequence: 2,
      status: LevelStatus.completed,
      minimumScore: 0.8,
      requiredQuizIds: [],
      plantIds: ['p4', 'p5'],
      learningGoal: 'Tiefer Wald',
      progress: 1.0,
    );

    await tester.pumpWidget(buildTestableWidget(LevelGateCard(level: level)));

    expect(find.text('Tief im Wald'), findsOneWidget);
    expect(find.text('2 Arten in diesem Level'), findsOneWidget);
  });

  testWidgets('shows locked level with blockedReason', (
    WidgetTester tester,
  ) async {
    const level = Level(
      id: 'l3',
      ecosystemId: 'e1',
      title: 'Baumkronen',
      sequence: 3,
      status: LevelStatus.locked,
      minimumScore: 0.8,
      requiredQuizIds: [],
      plantIds: ['p6'],
      blockedReason: 'Schließe zuerst "Tief im Wald" ab',
    );

    await tester.pumpWidget(buildTestableWidget(LevelGateCard(level: level)));

    expect(find.text('Baumkronen'), findsOneWidget);
    expect(find.text('Schließe zuerst "Tief im Wald" ab'), findsOneWidget);
    expect(find.text('1 Arten in diesem Level'), findsNothing);
  });

  testWidgets('shows empty progress state when progress is null', (
    WidgetTester tester,
  ) async {
    const level = Level(
      id: 'l4',
      ecosystemId: 'e1',
      title: 'Sumpf',
      sequence: 4,
      status: LevelStatus.available,
      minimumScore: 0.8,
      requiredQuizIds: [],
      plantIds: ['p7'],
      progress: null,
    );

    await tester.pumpWidget(buildTestableWidget(LevelGateCard(level: level)));

    expect(find.text('Noch nicht begonnen'), findsOneWidget);
    expect(find.byType(LinearProgressIndicator), findsNothing);
  });
}
