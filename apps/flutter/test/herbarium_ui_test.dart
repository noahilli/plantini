import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:plantini_app/core/result.dart';
import 'package:plantini_app/features/herbarium/domain/herbarium_models.dart';
import 'package:plantini_app/features/herbarium/infrastructure/local_herbarium_repository.dart';
import 'package:plantini_app/features/herbarium/presentation/herbarium_detail_screen.dart';
import 'package:plantini_app/features/herbarium/presentation/herbarium_screen.dart';
import 'package:plantini_app/features/herbarium/presentation/widgets/herbarium_list_view.dart';
import 'package:plantini_app/features/herbarium/presentation/widgets/herbarium_search_filter_bar.dart';

void main() {
  final sampleEntries = [
    HerbariumEntry(
      id: 'entry-1',
      observedAt: DateTime.parse('2026-08-26T10:00:00.000Z'),
      plantName: 'Stieleiche',
      scientificName: 'Quercus robur',
      note: 'Schöne Eiche im Wald',
      identificationResult: 'PlantNet: Quercus robur (98%)',
      version: 'v1',
      syncStatus: SyncStatus.synced,
    ),
    HerbariumEntry(
      id: 'entry-2',
      observedAt: DateTime.parse('2026-08-26T11:00:00.000Z'),
      plantName: 'Gänseblümchen',
      scientificName: 'Bellis perennis',
      note: 'Auf der Wiese',
      identificationResult: 'PlantNet: Bellis perennis (95%)',
      version: 'v1',
      syncStatus: SyncStatus.pending,
    ),
    HerbariumEntry(
      id: 'entry-3',
      observedAt: DateTime.parse('2026-08-26T12:00:00.000Z'),
      plantName: 'Brennnessel',
      scientificName: 'Urtica dioica',
      note: 'Konflikteintrag',
      identificationResult: 'PlantNet: Urtica dioica (90%)',
      version: 'v1',
      syncStatus: SyncStatus.conflict,
    ),
  ];

  group('HerbariumListView Widget Tests', () {
    testWidgets(
      'renders entries with thumbnail, title, scientific name and sync status',
      (tester) async {
        HerbariumEntry? tappedEntry;

        await tester.pumpWidget(
          MaterialApp(
            home: Scaffold(
              body: HerbariumListView(
                entries: sampleEntries,
                onEntryTap: (entry) => tappedEntry = entry,
              ),
            ),
          ),
        );

        expect(find.text("Stieleiche"), findsOneWidget);
        expect(find.text('Gänseblümchen'), findsOneWidget);
        expect(find.text('Brennnessel'), findsOneWidget);

        // Verify sync status icons / tooltips
        expect(find.byTooltip('Ausstehend (Lokal)'), findsOneWidget);
        expect(find.byTooltip('Synchronisationskonflikt'), findsOneWidget);

        // Tap on first entry
        await tester.tap(find.text('Stieleiche'));
        expect(tappedEntry?.id, 'entry-1');
      },
    );

    testWidgets('renders empty view when entries list is empty', (
      tester,
    ) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: HerbariumListView(
              entries: const [],
              onEntryTap: (_) {},
              emptyMessage: 'Keine Funde gefunden.',
            ),
          ),
        ),
      );

      expect(find.text('Keine Pflanzenfunde'), findsOneWidget);
      expect(find.text('Keine Funde gefunden.'), findsOneWidget);
    });
  });

  group('HerbariumDetailScreen Widget Tests', () {
    testWidgets(
      'renders full detail with PlantNet AI result, sync status, and notes',
      (tester) async {
        final entry = sampleEntries.first;
        bool deleteCalled = false;

        await tester.pumpWidget(
          MaterialApp(
            home: HerbariumDetailScreen(
              entry: entry,
              onDelete: (item) async {
                deleteCalled = true;
              },
            ),
          ),
        );

        expect(find.text('Stieleiche'), findsWidgets);
        expect(find.text('Quercus robur'), findsOneWidget);
        expect(find.text('Synchronisiert'), findsWidgets);
        expect(find.text('PlantNet KI-Bestimmung'), findsOneWidget);
        expect(find.text('PlantNet: Quercus robur (98%)'), findsOneWidget);
        expect(find.text('Schöne Eiche im Wald'), findsOneWidget);

        // Test delete button and confirmation dialog
        expect(
          find.byKey(const ValueKey('herbarium-delete-button')),
          findsOneWidget,
        );
        await tester.tap(find.byKey(const ValueKey('herbarium-delete-button')));
        await tester.pumpAndSettle();

        expect(find.text('Fund löschen?'), findsOneWidget);
        expect(find.text('Löschen'), findsOneWidget);

        await tester.tap(find.text('Löschen'));
        await tester.pumpAndSettle();

        expect(deleteCalled, isTrue);
      },
    );
  });

  group('HerbariumSearchFilterBar Widget Tests', () {
    testWidgets(
      'triggers onSearchChanged and onStatusFilterChanged callbacks',
      (tester) async {
        String currentSearch = '';
        SyncStatus? currentStatus;
        final controller = TextEditingController();

        await tester.pumpWidget(
          MaterialApp(
            home: Scaffold(
              body: StatefulBuilder(
                builder: (context, setState) {
                  return HerbariumSearchFilterBar(
                    searchQuery: currentSearch,
                    selectedStatus: currentStatus,
                    searchController: controller,
                    onSearchChanged: (query) {
                      setState(() => currentSearch = query);
                    },
                    onStatusFilterChanged: (status) {
                      setState(() => currentStatus = status);
                    },
                  );
                },
              ),
            ),
          ),
        );

        // Type in search field
        await tester.enterText(
          find.byKey(const ValueKey('herbarium-search-field')),
          'Eiche',
        );
        await tester.pump();
        expect(currentSearch, 'Eiche');

        // Clear search via suffix icon
        expect(
          find.byKey(const ValueKey('herbarium-search-clear')),
          findsOneWidget,
        );
        await tester.tap(find.byKey(const ValueKey('herbarium-search-clear')));
        await tester.pump();
        expect(currentSearch, '');

        // Select filter chip
        await tester.tap(find.byKey(const ValueKey('filter-pending')));
        await tester.pump();
        expect(currentStatus, SyncStatus.pending);

        // Toggle off filter chip
        await tester.tap(find.byKey(const ValueKey('filter-pending')));
        await tester.pump();
        expect(currentStatus, isNull);
      },
    );
  });

  group('HerbariumScreen Integrated Reactive Tests', () {
    testWidgets('filters entries in-memory by text and sync status', (
      tester,
    ) async {
      final repo = LocalHerbariumRepository(
        initialEntries: List.of(sampleEntries),
      );

      await tester.pumpWidget(
        MaterialApp(home: HerbariumScreen(repository: repo)),
      );
      await tester.pumpAndSettle();

      // All 3 items rendered
      expect(find.text('Stieleiche', skipOffstage: false), findsOneWidget);
      expect(find.text('Gänseblümchen', skipOffstage: false), findsOneWidget);
      expect(find.text('Brennnessel', skipOffstage: false), findsOneWidget);

      // Search for "Gänse"
      await tester.enterText(
        find.byKey(const ValueKey('herbarium-search-field')),
        'Gänse',
      );
      await tester.pumpAndSettle();

      expect(find.text('Gänseblümchen', skipOffstage: false), findsOneWidget);
      expect(find.text('Stieleiche', skipOffstage: false), findsNothing);
      expect(find.text('Brennnessel', skipOffstage: false), findsNothing);

      // Clear search
      await tester.tap(find.byKey(const ValueKey('herbarium-search-clear')));
      await tester.pumpAndSettle();

      // Filter by "Konflikte"
      await tester.tap(find.byKey(const ValueKey('filter-conflict')));
      await tester.pumpAndSettle();

      expect(find.text('Brennnessel', skipOffstage: false), findsOneWidget);
      expect(find.text('Stieleiche', skipOffstage: false), findsNothing);
      expect(find.text('Gänseblümchen', skipOffstage: false), findsNothing);
    });

    testWidgets(
      'sync button reports that the local test adapter cannot synchronize',
      (tester) async {
        final repo = LocalHerbariumRepository(
          initialEntries: List.of(sampleEntries),
        );

        await tester.pumpWidget(
          MaterialApp(home: HerbariumScreen(repository: repo)),
        );
        await tester.pumpAndSettle();

        expect(find.byTooltip('Ausstehend (Lokal)'), findsOneWidget);

        // Tap sync button
        await tester.tap(find.byKey(const ValueKey('herbarium-sync-button')));
        await tester.pumpAndSettle();

        // The test adapter never pretends that an unsent item reached the server.
        expect(find.byTooltip('Ausstehend (Lokal)'), findsOneWidget);
        expect(
          find.text(
            'Der lokale Testadapter kann keine Funde synchronisieren. Verwende die API-Implementierung.',
          ),
          findsOneWidget,
        );
      },
    );

    testWidgets(
      'add action launches the field flow instead of creating fake local data',
      (tester) async {
        final repo = LocalHerbariumRepository(
          initialEntries: List.of(sampleEntries),
        );
        var startFieldCalls = 0;

        await tester.pumpWidget(
          MaterialApp(
            home: HerbariumScreen(
              repository: repo,
              onStartField: () => startFieldCalls += 1,
            ),
          ),
        );
        await tester.pumpAndSettle();

        await tester.tap(
          find.byKey(const ValueKey('herbarium-add-observation')),
        );
        await tester.pumpAndSettle();
        expect(startFieldCalls, 1);
        expect(find.text('Waldmeister'), findsNothing);
      },
    );
  });

  group('LocalHerbariumRepository Unit Tests', () {
    test('CRUD operations stay pending and never fake a remote sync', () async {
      final repo = LocalHerbariumRepository(initialEntries: []);

      // Create entry
      final createRes = await repo.createEntry(
        clientObservationId: 'c-1',
        observedAt: DateTime.parse('2026-08-26T12:00:00Z'),
        plantName: 'Sonnentau',
        scientificName: 'Drosera rotundifolia',
        note: 'Im Moor gefunden',
        identificationResult: 'PlantNet: Drosera rotundifolia (99%)',
        idempotencyKey: 'k-1',
      );
      expect(createRes.isSuccess, isTrue);

      // List entries
      final listRes = await repo.listEntries();
      expect(listRes.isSuccess, isTrue);
      final entries = (listRes as Success<List<HerbariumEntry>>).value;
      expect(entries.length, 1);
      expect(entries.first.plantName, 'Sonnentau');
      expect(entries.first.syncStatus, SyncStatus.pending);

      // Get entry
      final getRes = await repo.getEntry('c-1');
      expect(getRes.isSuccess, isTrue);
      expect((getRes as Success<HerbariumEntry>).value.id, 'c-1');

      // Sync entries
      final syncRes = await repo.syncEntries();
      expect(syncRes.isSuccess, isFalse);

      // Delete entry
      final delRes = await repo.deleteEntry(
        id: 'c-1',
        ifMatchVersion: 'local-c-1',
      );
      expect(delRes.isSuccess, isTrue);

      final listAfterDel = await repo.listEntries();
      expect((listAfterDel as Success<List<HerbariumEntry>>).value, isEmpty);
    });
  });
}
