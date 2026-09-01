import 'package:flutter_test/flutter_test.dart';
import 'package:plantini_app/features/catalog/domain/catalog_models.dart';
import 'package:plantini_app/features/catalog/domain/level_collection_progress.dart';
import 'package:plantini_app/features/field/domain/location_privacy.dart';
import 'package:plantini_app/features/field/domain/field_models.dart';

void main() {
  group('Level Rules', () {
    test('collection gate requires every curated target plant', () {
      const level = Level(
        id: 'l0',
        ecosystemId: 'e1',
        title: 'Sammelmission',
        sequence: 1,
        status: LevelStatus.inProgress,
        minimumScore: 0.8,
        requiredQuizIds: [],
        plantIds: ['p1', 'p2', 'p3', 'p4'],
        requiredPlantIds: ['p1', 'p3'],
      );

      final partial = LevelCollectionProgress.forLevel(level, ['p1', 'p4']);
      expect(partial.collectedCount, 1);
      expect(partial.missingPlantIds, ['p3']);
      expect(partial.isComplete, isFalse);

      final complete = LevelCollectionProgress.forLevel(level, ['p1', 'p3']);
      expect(complete.fraction, 1);
      expect(complete.isComplete, isTrue);
    });

    test(
      'legacy levels use their first three plants as collection targets',
      () {
        const level = Level(
          id: 'legacy',
          ecosystemId: 'e1',
          title: 'Legacy',
          sequence: 1,
          status: LevelStatus.available,
          minimumScore: 0.8,
          requiredQuizIds: [],
          plantIds: ['p1', 'p2', 'p3', 'p4'],
        );

        expect(level.collectionTargets, ['p1', 'p2', 'p3']);
      },
    );

    test(
      'isUnlocked returns true for available, inProgress, and completed',
      () {
        final lockedLevel = Level(
          id: 'l1',
          ecosystemId: 'e1',
          title: 'Level 1',
          sequence: 1,
          status: LevelStatus.locked,
          minimumScore: 0.8,
          requiredQuizIds: [],
          plantIds: [],
        );
        expect(lockedLevel.isUnlocked, isFalse);

        final availableLevel = Level(
          id: 'l2',
          ecosystemId: 'e1',
          title: 'Level 2',
          sequence: 2,
          status: LevelStatus.available,
          minimumScore: 0.8,
          requiredQuizIds: [],
          plantIds: [],
        );
        expect(availableLevel.isUnlocked, isTrue);

        final inProgressLevel = Level(
          id: 'l3',
          ecosystemId: 'e1',
          title: 'Level 3',
          sequence: 3,
          status: LevelStatus.inProgress,
          minimumScore: 0.8,
          requiredQuizIds: [],
          plantIds: [],
        );
        expect(inProgressLevel.isUnlocked, isTrue);

        final completedLevel = Level(
          id: 'l4',
          ecosystemId: 'e1',
          title: 'Level 4',
          sequence: 4,
          status: LevelStatus.completed,
          minimumScore: 0.8,
          requiredQuizIds: [],
          plantIds: [],
        );
        expect(completedLevel.isUnlocked, isTrue);
      },
    );
  });

  group('LocationPrivacy', () {
    test('coarsen rounds latitude and longitude to 2 decimal places and clears accuracy', () {
      final loc1 = ObservationLocation(
        latitude: 52.520008,
        longitude: 13.404954,
        accuracyMeters: 10.5,
      );
      final coarsened1 = LocationPrivacy.coarsen(loc1);
      expect(coarsened1.latitude, closeTo(52.52, 0.001));
      expect(coarsened1.longitude, closeTo(13.40, 0.001));
      expect(coarsened1.accuracyMeters, 1000.0);

      final loc2 = ObservationLocation(
        latitude: -33.8688,
        longitude: 151.2093,
        accuracyMeters: 5.0,
      );
      final coarsened2 = LocationPrivacy.coarsen(loc2);
      expect(coarsened2.latitude, closeTo(-33.87, 0.001));
      expect(coarsened2.longitude, closeTo(151.21, 0.001));
      expect(coarsened2.accuracyMeters, 1000.0);
    });

    test('omit returns null', () {
      expect(LocationPrivacy.omit(), isNull);
    });
  });
}
