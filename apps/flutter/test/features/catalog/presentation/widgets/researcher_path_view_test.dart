import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:plantini_app/features/catalog/domain/catalog_models.dart';
import 'package:plantini_app/features/catalog/domain/level_collection_progress.dart';
import 'package:plantini_app/features/catalog/presentation/widgets/researcher_path_view.dart';
import 'package:plantini_app/features/catalog/presentation/widgets/level_gate_card.dart';

void main() {
  Widget buildTestableWidget(Widget widget) {
    return MaterialApp(home: Scaffold(body: widget));
  }

  testWidgets('ResearcherPathView displays levels sorted by sequence', (
    WidgetTester tester,
  ) async {
    const ecosystem = Ecosystem(
      id: 'e1',
      slug: 'wald',
      title: 'Heimischer Wald',
      releaseVersion: '1',
      levelIds: ['l1', 'l2'],
    );

    const level2 = Level(
      id: 'l2',
      ecosystemId: 'e1',
      title: 'Tief im Wald',
      sequence: 2,
      status: LevelStatus.locked,
      minimumScore: 0.8,
      requiredQuizIds: [],
      plantIds: ['p4', 'p5'],
      blockedReason: 'Gesperrt',
    );

    const level1 = Level(
      id: 'l1',
      ecosystemId: 'e1',
      title: 'Waldrand',
      sequence: 1,
      status: LevelStatus.available,
      minimumScore: 0.8,
      requiredQuizIds: [],
      plantIds: ['p1', 'p2', 'p3'],
    );

    // Pass them in reverse order to ensure the widget sorts them by sequence
    await tester.pumpWidget(
      buildTestableWidget(
        ResearcherPathView(
          ecosystem: ecosystem,
          levels: const [level2, level1],
        ),
      ),
    );

    expect(find.byType(LevelGateCard), findsNWidgets(2));

    // Check if they are rendered in correct order
    final firstCard = tester.widget<LevelGateCard>(
      find.byType(LevelGateCard).first,
    );
    expect(firstCard.level.title, 'Waldrand');

    final lastCard = tester.widget<LevelGateCard>(
      find.byType(LevelGateCard).last,
    );
    expect(lastCard.level.title, 'Tief im Wald');
  });

  testWidgets('active level renders its herbarium collection mission', (
    WidgetTester tester,
  ) async {
    const ecosystem = Ecosystem(
      id: 'e1',
      slug: 'wald',
      title: 'Wald',
      releaseVersion: '1',
      levelIds: ['l1'],
    );
    const level = Level(
      id: 'l1',
      ecosystemId: 'e1',
      title: 'Waldsammler',
      sequence: 1,
      status: LevelStatus.inProgress,
      minimumScore: .8,
      requiredQuizIds: [],
      plantIds: ['p1', 'p2', 'p3'],
    );

    await tester.pumpWidget(
      buildTestableWidget(
        ResearcherPathView(
          ecosystem: ecosystem,
          levels: const [level],
          collectionProgress: const {
            'l1': LevelCollectionProgress(
              requiredPlantIds: ['p1', 'p2', 'p3'],
              collectedPlantIds: {'p1'},
            ),
          },
        ),
      ),
    );

    expect(find.text('1/3 gesammelt'), findsOneWidget);
    expect(find.text('Sammle noch 2 Zielarten'), findsOneWidget);
  });
}
