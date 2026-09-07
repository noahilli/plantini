import 'dart:async';
import 'dart:ui' as ui;

import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:plantini_app/core/errors/app_failure.dart';
import 'package:plantini_app/core/result.dart';
import 'package:plantini_app/design_system/plant_specimen_bottle.dart';
import 'package:plantini_app/features/catalog/application/catalog_use_cases.dart';
import 'package:plantini_app/features/catalog/domain/catalog_models.dart';
import 'package:plantini_app/features/catalog/domain/catalog_repository.dart';
import 'package:plantini_app/features/herbarium/domain/herbarium_models.dart';
import 'package:plantini_app/features/herbarium/infrastructure/local_herbarium_repository.dart';
import 'package:plantini_app/features/herbarium/presentation/herbarium_screen.dart';

class _Catalog implements CatalogRepository {
  bool fail = false;
  String? failPlant;
  Completer<void>? gate;
  final calls = <String>[];

  @override
  Future<Result<List<Ecosystem>>> listPublishedEcosystems() async {
    await gate?.future;
    return fail
        ? const Result.failure(NetworkFailure(message: 'Offline'))
        : const Result.success([
            Ecosystem(
              id: 'forest',
              slug: 'forest',
              title: 'Wald',
              releaseVersion: '1',
              levelIds: ['one', 'two'],
            ),
            Ecosystem(
              id: 'meadow',
              slug: 'meadow',
              title: 'Wiese',
              releaseVersion: '1',
              levelIds: ['three'],
            ),
          ]);
  }

  @override
  Future<Result<List<Level>>> listPublishedLevels(String ecosystemId) async =>
      Result.success([
        Level(
          id: ecosystemId,
          ecosystemId: ecosystemId,
          title: 'Level',
          sequence: 1,
          status: LevelStatus.available,
          minimumScore: .8,
          requiredQuizIds: [],
          plantIds: ecosystemId == 'forest' ? ['oak', 'oak'] : ['oak', 'daisy'],
          requiredPlantIds: ecosystemId == 'forest' ? ['fern'] : [],
        ),
      ]);

  @override
  Future<Result<Plant>> getPublishedPlant(String plantId) async {
    calls.add(plantId);
    if (failPlant == plantId)
      return const Result.failure(
        NetworkFailure(message: 'Steckbrief offline'),
      );
    final (name, scientific) = switch (plantId) {
      'oak' => ('Stieleiche', 'Quercus robur'),
      'fern' => ('Wurmfarn', 'Dryopteris filix-mas'),
      _ => ('Gänseblümchen', 'Bellis perennis'),
    };
    return Result.success(
      Plant(
        id: plantId,
        slug: plantId,
        scientificName: scientific,
        commonName: name,
        family: '',
        description: '',
        releaseVersion: '1',
      ),
    );
  }

  @override
  Future<Result<LevelContent>> getPublishedLevel(String levelId) =>
      throw UnimplementedError();
}

HerbariumEntry _entry(
  String id, {
  String? plantId,
  SyncStatus status = SyncStatus.synced,
}) => HerbariumEntry(
  id: id,
  confirmedPlantId: plantId,
  plantName: 'Stieleiche',
  scientificName: 'Quercus robur',
  note: 'Fund am Bach',
  observedAt: DateTime(2026, 9, 7),
  version: '1',
  syncStatus: status,
);

Future<void> _mount(
  WidgetTester tester,
  _Catalog catalog, {
  List<HerbariumEntry> entries = const [],
  VoidCallback? onStartField,
  double scale = 1,
}) async {
  await tester.pumpWidget(
    MaterialApp(
      builder: (context, child) => MediaQuery(
        data: MediaQuery.of(context)
            .copyWith(textScaler: TextScaler.linear(scale)),
        child: child!,
      ),
      home: HerbariumScreen(
        repository: LocalHerbariumRepository(initialEntries: entries),
        loadEcosystems: LoadPublishedEcosystems(catalog),
        loadLevels: LoadPublishedLevels(catalog),
        loadPlant: LoadPublishedPlant(catalog),
        onStartField: onStartField,
      ),
    ),
  );
  await tester.pump();
}

PlantSpecimenBottle _bottle(WidgetTester tester, String id) =>
    tester.widget<PlantSpecimenBottle>(
      find.descendant(
        of: find.byKey(ValueKey('herbarium-species-$id')),
        matching: find.byType(PlantSpecimenBottle),
      ),
    );

void main() {
  testWidgets(
    'empty catalog bottles load unique species across ecosystems and explicit targets',
    (tester) async {
      final catalog = _Catalog();
      await _mount(tester, catalog);
      await tester.pumpAndSettle();
      expect(catalog.calls, ['oak', 'fern', 'daisy']);
      expect(_bottle(tester, 'oak').collected, isFalse);
      expect(_bottle(tester, 'fern').collected, isFalse);
      expect(find.text('0 von 3 Arten gesammelt'), findsOneWidget);
      expect(find.text('Wald'), findsOneWidget);
      await tester.scrollUntilVisible(
        find.byKey(const ValueKey('herbarium-species-daisy')),
        200,
        scrollable: find
            .descendant(
              of: find.byKey(const ValueKey('herbarium-bottle-collection')),
              matching: find.byType(Scrollable),
            )
            .first,
      );
      expect(_bottle(tester, 'daisy').collected, isFalse);
      expect(find.text('Wiese'), findsOneWidget);
    },
  );

  testWidgets(
    'only matching confirmed IDs fill bottles; names, unknown IDs and tombstones do not',
    (tester) async {
      await _mount(
        tester,
        _Catalog(),
        entries: [
          _entry('named-only'),
          _entry('wrong', plantId: 'other'),
          _entry('deleted', plantId: 'fern', status: SyncStatus.deleted),
          _entry('match', plantId: 'oak', status: SyncStatus.pending),
          _entry('duplicate', plantId: 'oak', status: SyncStatus.pending),
        ],
      );
      await tester.pumpAndSettle();
      expect(_bottle(tester, 'oak').collected, isTrue);
      expect(_bottle(tester, 'fern').collected, isFalse);
      expect(find.text('1 von 3 Arten gesammelt'), findsOneWidget);
      expect(find.text('Lokal · noch nicht synchronisiert'), findsOneWidget);
      expect(
        find.textContaining('Der Server bestätigt den Levelabschluss'),
        findsOneWidget,
      );
    },
  );

  testWidgets(
    'catalog loading and error leave observations accessible; retry restores bottles',
    (tester) async {
      final catalog = _Catalog()..gate = Completer<void>();
      await _mount(tester, catalog, entries: [_entry('saved', plantId: 'oak')]);
      expect(find.text('Pflanzenkatalog wird geladen …'), findsOneWidget);
      await tester.tap(
        find.byKey(const ValueKey('herbarium-tab-observations')),
      );
      await tester.pump();
      expect(
        find.byKey(const ValueKey('herbarium-entry-saved')),
        findsOneWidget,
      );
      catalog.fail = true;
      catalog.gate!.complete();
      await tester.pumpAndSettle();
      await tester.tap(find.byKey(const ValueKey('herbarium-tab-collection')));
      await tester.pumpAndSettle();
      expect(find.textContaining('Katalog unvollständig'), findsOneWidget);
      catalog.fail = false;
      await tester.tap(find.byKey(const ValueKey('herbarium-catalog-retry')));
      await tester.pumpAndSettle();
      expect(_bottle(tester, 'oak').collected, isTrue);
    },
  );

  testWidgets(
    'partial plant failure shows available species and retries missing content',
    (tester) async {
      final catalog = _Catalog()..failPlant = 'fern';
      await _mount(tester, catalog);
      await tester.pumpAndSettle();
      expect(
        find.byKey(const ValueKey('herbarium-species-oak')),
        findsOneWidget,
      );
      expect(
        find.byKey(const ValueKey('herbarium-species-fern')),
        findsNothing,
      );
      expect(find.textContaining('Katalog unvollständig'), findsOneWidget);
      expect(find.textContaining('von 2 Arten'), findsNothing);
      catalog.failPlant = null;
      await tester.tap(find.byKey(const ValueKey('herbarium-catalog-retry')));
      await tester.pumpAndSettle();
      expect(
        find.byKey(const ValueKey('herbarium-species-fern')),
        findsOneWidget,
      );
    },
  );

  testWidgets(
    'search, status filters, add, detail, note editing and deletion remain usable',
    (tester) async {
      var addCalls = 0;
      await _mount(
        tester,
        _Catalog(),
        entries: [_entry('saved', plantId: 'oak', status: SyncStatus.pending)],
        onStartField: () => addCalls++,
      );
      await tester.pumpAndSettle();
      await tester.enterText(
        find.byKey(const ValueKey('herbarium-search-field')),
        'Bach',
      );
      await tester.pumpAndSettle();
      expect(
        find.byKey(const ValueKey('herbarium-species-oak')),
        findsOneWidget,
      );
      expect(
        find.byKey(const ValueKey('herbarium-species-fern')),
        findsNothing,
      );
      await tester.tap(find.byKey(const ValueKey('herbarium-search-clear')));
      await tester.tap(find.byKey(const ValueKey('filter-pending')));
      await tester.pumpAndSettle();
      expect(
        find.byKey(const ValueKey('herbarium-species-fern')),
        findsNothing,
      );
      await tester.tap(find.byKey(const ValueKey('herbarium-add-observation')));
      expect(addCalls, 1);
      await tester.ensureVisible(find.text('Fund ansehen'));
      await tester.tap(find.text('Fund ansehen'));
      await tester.pumpAndSettle();
      await tester.ensureVisible(
        find.byKey(const ValueKey('herbarium-edit-note')),
      );
      await tester.tap(find.byKey(const ValueKey('herbarium-edit-note')));
      await tester.pumpAndSettle();
      await tester.enterText(
        find.byKey(const ValueKey('herbarium-note-input')),
        'Neue Notiz',
      );
      await tester.tap(find.byKey(const ValueKey('herbarium-note-save')));
      await tester.pumpAndSettle();
      expect(find.text('Neue Notiz'), findsOneWidget);
      await tester.ensureVisible(
        find.byKey(const ValueKey('herbarium-delete-button')),
      );
      await tester.tap(find.byKey(const ValueKey('herbarium-delete-button')));
      await tester.pumpAndSettle();
      await tester.tap(find.text('Löschen'));
      await tester.pumpAndSettle();
      await tester.tap(find.byKey(const ValueKey('filter-pending')));
      await tester.pumpAndSettle();
      expect(_bottle(tester, 'oak').collected, isFalse);
    },
  );

  testWidgets('320px and 200 percent text reflows with reachable controls', (
    tester,
  ) async {
    await tester.view.reset();
    tester.view.physicalSize = const Size(320, 740);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);
    await _mount(
      tester,
      _Catalog(),
      entries: [_entry('saved', plantId: 'oak')],
      scale: 2,
    );
    await tester.pumpAndSettle();
    expect(tester.takeException(), isNull);
    await tester.tap(find.byKey(const ValueKey('herbarium-tab-observations')));
    await tester.pumpAndSettle();
    expect(tester.takeException(), isNull);
    expect(find.byKey(const ValueKey('herbarium-sync-button')), findsOneWidget);
  });

  testWidgets(
    'vector output is stable, differs by species and contains accessible empty state',
    (tester) async {
      final key = GlobalKey();
      Future<List<int>> render(bool collected, String species) async {
        await tester.pumpWidget(
          MaterialApp(
            home: Center(
              child: RepaintBoundary(
                key: key,
                child: PlantSpecimenBottle(
                  collected: collected,
                  scientificName: species,
                ),
              ),
            ),
          ),
        );
        await tester.pump();
        final boundary =
            key.currentContext!.findRenderObject()! as RenderRepaintBoundary;
        final image = await boundary.toImage();
        final bytes = await image.toByteData(
          format: ui.ImageByteFormat.rawRgba,
        );
        image.dispose();
        return bytes!.buffer.asUint8List();
      }

      final semantics = tester.ensureSemantics();
      addTearDown(semantics.dispose);
      final empty = await render(false, 'Quercus robur');
      expect(
        find.bySemanticsLabel(
          'Quercus robur: Leeres Glas, noch nicht gesammelt',
        ),
        findsOneWidget,
      );
      final oak = await render(true, 'Quercus robur');
      expect(oak, isNot(orderedEquals(empty)));
      expect(await render(true, 'Bellis perennis'), isNot(orderedEquals(oak)));
      expect(await render(true, 'Quercus robur'), orderedEquals(oak));
    },
  );
}
