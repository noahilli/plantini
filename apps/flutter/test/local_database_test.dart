import 'package:flutter_test/flutter_test.dart';
import 'package:plantini_app/core/storage/local_database.dart';
import 'package:plantini_app/features/catalog/infrastructure/models/isar_ecosystem.dart';
import 'package:plantini_app/features/catalog/infrastructure/models/isar_level.dart';
import 'package:plantini_app/features/catalog/infrastructure/models/isar_plant.dart';

void main() {
  group('LocalDatabase Schema & Models', () {
    test('schemas contains all required collection schemas', () {
      expect(LocalDatabase.schemas, contains(IsarEcosystemSchema));
      expect(LocalDatabase.schemas, contains(IsarLevelSchema));
      expect(LocalDatabase.schemas, contains(IsarPlantSchema));
      expect(LocalDatabase.schemas.length, 3);
    });

    test('IsarEcosystem properties instantiate correctly', () {
      final ecosystem = IsarEcosystem()
        ..publicId = 'eco-1'
        ..slug = 'wald'
        ..title = 'Mitteleuropäischer Mischwald'
        ..releaseVersion = 'v1.0.0'
        ..levelIds = ['level-1', 'level-2']
        ..description = 'Ein vielfältiges Ökosystem.';

      expect(ecosystem.publicId, 'eco-1');
      expect(ecosystem.slug, 'wald');
      expect(ecosystem.title, 'Mitteleuropäischer Mischwald');
      expect(ecosystem.releaseVersion, 'v1.0.0');
      expect(ecosystem.levelIds, ['level-1', 'level-2']);
      expect(ecosystem.description, 'Ein vielfältiges Ökosystem.');
    });

    test('IsarLevel properties instantiate correctly', () {
      final level = IsarLevel()
        ..publicId = 'level-1'
        ..ecosystemId = 'eco-1'
        ..title = 'Laubbäume'
        ..sequence = 1
        ..status = IsarLevelStatus.available
        ..minimumScore = 0.8
        ..requiredQuizIds = ['q1', 'q2']
        ..plantIds = ['p1', 'p2']
        ..learningGoal = 'Erkenne heimische Laubbäume'
        ..progress = 0.5
        ..contentVersion = 'v1.0.0';

      expect(level.publicId, 'level-1');
      expect(level.ecosystemId, 'eco-1');
      expect(level.title, 'Laubbäume');
      expect(level.sequence, 1);
      expect(level.status, IsarLevelStatus.available);
      expect(level.minimumScore, 0.8);
      expect(level.requiredQuizIds, ['q1', 'q2']);
      expect(level.plantIds, ['p1', 'p2']);
      expect(level.contentVersion, 'v1.0.0');
    });

    test('IsarPlant and IsarPlantMedia instantiate correctly', () {
      final media = IsarPlantMedia()
        ..publicId = 'media-1'
        ..slug = 'quercus-leaf'
        ..url = 'https://example.com/leaf.jpg'
        ..altText = 'Eichenblatt'
        ..license = 'CC-BY-SA'
        ..author = 'Botaniker';

      final plant = IsarPlant()
        ..publicId = 'plant-1'
        ..slug = 'quercus-robur'
        ..scientificName = 'Quercus robur'
        ..commonName = 'Stieleiche'
        ..family = 'Fagaceae'
        ..description = 'Häufiger Laubbaum in Europa.'
        ..warning = null
        ..sources = ['Flora Germanica']
        ..releaseVersion = 'v1.0.0'
        ..media = [media];

      expect(plant.publicId, 'plant-1');
      expect(plant.slug, 'quercus-robur');
      expect(plant.scientificName, 'Quercus robur');
      expect(plant.commonName, 'Stieleiche');
      expect(plant.family, 'Fagaceae');
      expect(plant.sources, contains('Flora Germanica'));
      expect(plant.media.first.publicId, 'media-1');
      expect(plant.media.first.altText, 'Eichenblatt');
      expect(plant.media.first.author, 'Botaniker');
    });
  });
}
