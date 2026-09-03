import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:plantini_app/core/result.dart';
import 'package:plantini_app/features/catalog/domain/catalog_models.dart';
import 'package:plantini_app/features/catalog/infrastructure/catalog_dto.dart';
import 'package:plantini_app/features/catalog/presentation/plant_detail_screen.dart';

void main() {
  group('Plant Domain Model', () {
    test('maps a published API plant for named collection missions', () {
      final result = CatalogDto.plantFromJson({
        'id': '33333333-3333-4333-8333-333333333333',
        'scientificName': 'Quercus robur',
        'commonName': 'Stiel-Eiche',
        'family': 'Fagaceae',
        'description': 'Heimischer Laubbaum',
        'releaseVersion': 'demo-de-v1',
      });

      expect(result, isA<Success<Plant>>());
      final plant = (result as Success<Plant>).value;
      expect(plant.commonName, 'Stiel-Eiche');
      expect(plant.scientificName, 'Quercus robur');
    });

    test('instantiates with all fields correctly', () {
      const media = PlantMedia(
        id: 'media-1',
        slug: 'monstera-leaf',
        url: 'https://example.com/monstera.jpg',
        altText: 'Monstera deliciosa leaf',
        license: 'CC-BY-4.0',
        author: 'Botanist Jane',
      );

      const plant = Plant(
        id: 'plant-1',
        slug: 'monstera-deliciosa',
        scientificName: 'Monstera deliciosa',
        commonName: 'Fensterblatt',
        family: 'Araceae',
        description:
            'Eine beliebte Zimmerpflanze mit charakteristischen Blättern.',
        warning: 'Giftig für Haustiere!',
        sources: ['https://wikipedia.org/wiki/Monstera_deliciosa'],
        releaseVersion: 'v1.0.0',
        media: [media],
      );

      expect(plant.id, 'plant-1');
      expect(plant.slug, 'monstera-deliciosa');
      expect(plant.scientificName, 'Monstera deliciosa');
      expect(plant.commonName, 'Fensterblatt');
      expect(plant.family, 'Araceae');
      expect(
        plant.description,
        'Eine beliebte Zimmerpflanze mit charakteristischen Blättern.',
      );
      expect(plant.warning, 'Giftig für Haustiere!');
      expect(
        plant.sources,
        contains('https://wikipedia.org/wiki/Monstera_deliciosa'),
      );
      expect(plant.releaseVersion, 'v1.0.0');
      expect(plant.media.length, 1);
      expect(plant.media.first.id, 'media-1');
      expect(plant.media.first.author, 'Botanist Jane');
    });
  });

  group('PlantDetailScreen Widget', () {
    testWidgets('renders plant details, warning and sources', (tester) async {
      const media = PlantMedia(
        id: 'media-1',
        slug: 'taraxacum-photo',
        url: 'https://example.com/taraxacum.jpg',
        altText: 'Löwenzahn in voller Blüte',
        license: 'CC0',
        author: 'Naturfreund',
      );

      const plant = Plant(
        id: 'plant-2',
        slug: 'taraxacum-officinale',
        scientificName: 'Taraxacum officinale',
        commonName: 'Gewöhnlicher Löwenzahn',
        family: 'Asteraceae',
        description: 'Sehr anpassungsfähige Wiesenpflanze mit gelben Blüten.',
        warning: 'Kann bei empfindlicher Haut Kontaktallergien auslösen.',
        sources: ['Flora von Deutschland', 'https://floraweb.de'],
        releaseVersion: 'v1.0.0',
        media: [media],
      );

      await tester.pumpWidget(
        const MaterialApp(home: PlantDetailScreen(plant: plant)),
      );

      // Verify text elements
      expect(find.text('Taraxacum officinale'), findsWidgets);
      expect(find.text('Gewöhnlicher Löwenzahn'), findsWidgets);
      expect(find.text('Asteraceae'), findsOneWidget);
      expect(
        find.text('Sehr anpassungsfähige Wiesenpflanze mit gelben Blüten.'),
        findsOneWidget,
      );
      expect(
        find.text('Kann bei empfindlicher Haut Kontaktallergien auslösen.'),
        findsOneWidget,
      );
      expect(find.text('Lizenz: CC0'), findsOneWidget);
      expect(find.text('Autor: Naturfreund'), findsOneWidget);
      expect(find.text('Flora von Deutschland'), findsOneWidget);
      expect(find.text('https://floraweb.de'), findsOneWidget);
    });

    testWidgets('renders cleanly without optional warning or media', (
      tester,
    ) async {
      const plant = Plant(
        id: 'plant-3',
        slug: 'bellis-perennis',
        scientificName: 'Bellis perennis',
        commonName: 'Gänseblümchen',
        family: 'Asteraceae',
        description: 'Bekannte Wiesenblume.',
        releaseVersion: 'v1.0.0',
      );

      await tester.pumpWidget(
        const MaterialApp(home: PlantDetailScreen(plant: plant)),
      );

      expect(find.text('Bellis perennis'), findsWidgets);
      expect(find.text('Gänseblümchen'), findsWidgets);
      expect(find.text('Galerie'), findsNothing);
      expect(find.byIcon(Icons.warning_amber_rounded), findsNothing);
    });
  });
}
