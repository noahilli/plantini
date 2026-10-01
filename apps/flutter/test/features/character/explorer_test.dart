import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:go_router/go_router.dart';
import 'package:plantini_app/core/errors/app_failure.dart';
import 'package:plantini_app/core/result.dart';
import 'package:plantini_app/features/character/application/character_store.dart';
import 'package:plantini_app/features/character/domain/character_repository.dart';
import 'package:plantini_app/features/character/domain/explorer.dart';
import 'package:plantini_app/features/character/presentation/character_selector_screen.dart';
import 'package:plantini_app/features/character/presentation/widgets/explorer_roster.dart';
import 'package:shared_preferences/shared_preferences.dart';

final class _Repo implements CharacterRepository {
  String? stored;
  bool offline = false;
  bool throws = false;

  @override
  Future<Result<String?>> load() async {
    if (throws) throw StateError('boom');
    return offline
        ? Result.failure(const NetworkFailure(message: 'offline'))
        : Result.success(stored);
  }

  @override
  Future<Result<String>> save(String id) async {
    if (offline) {
      return Result.failure(const NetworkFailure(message: 'offline'));
    }
    stored = id;
    return Result.success(id);
  }
}

Future<CharacterStore> _store(
  _Repo repo, [
  Map<String, Object> prefs = const {},
]) async {
  SharedPreferences.setMockInitialValues(prefs);
  return CharacterStore(
    repository: repo,
    preferences: await SharedPreferences.getInstance(),
  );
}

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();
  late ExplorerRoster roster;
  setUpAll(() async => roster = await ExplorerRoster.load());
  setUp(() => PlayerLook.id.value = null);

  test(
    'three women, three men, three non-binary explorers, each with a model',
    () {
      expect(roster.explorers, hasLength(9));
      for (final group in ExplorerGroup.values) {
        expect(roster.inGroup(group), hasLength(3), reason: group.name);
      }
      for (final e in roster.explorers) {
        expect(e.meshes, isNotEmpty);
        expect(e.meshes.every((m) => m.motion == 'ranger'), isTrue);
        final faces = e.meshes.fold<int>(0, (n, m) => n + m.faceCount);
        expect(faces, lessThan(2000), reason: '${e.id} stays cheap to draw');
      }
      expect(roster.explorers.map((e) => e.id).toSet(), hasLength(9));
    },
  );

  test('the first login has none and needs the selector', () async {
    final repo = _Repo();
    final store = await _store(repo);
    await store.sync();
    expect(store.needsSelection, isTrue);
    expect((await store.choose('nia')).isSuccess, isTrue);
    expect(store.needsSelection, isFalse);
    expect(PlayerLook.explorer?.name, 'Nia');
    expect(repo.stored, 'nia');
  });

  test('a saved choice is loaded; an unknown id counts as none', () async {
    final repo = _Repo()..stored = 'arjun';
    final store = await _store(repo);
    await store.sync();
    expect(PlayerLook.id.value, 'arjun');

    PlayerLook.id.value = null;
    final other = await _store(_Repo()..stored = 'old-designer-thing');
    await other.sync();
    expect(other.needsSelection, isTrue);
  });

  test(
    'offline without cache shows a default and does not force the selector',
    () async {
      final repo = _Repo()..offline = true;
      final store = await _store(repo);
      await store.sync();
      expect(store.needsSelection, isFalse);
      expect(PlayerLook.id.value, CharacterStore.fallbackId);
      repo
        ..offline = false
        ..stored = null;
      await store.sync();
      expect(store.needsSelection, isTrue);
    },
  );

  test('a choice made offline is sent at the next sync', () async {
    final repo = _Repo()..offline = true;
    final store = await _store(repo);
    await store.sync();
    expect((await store.choose('mei')).isSuccess, isFalse);
    expect(PlayerLook.id.value, 'mei');
    repo.offline = false;
    PlayerLook.id.value = null;
    final again = await _store(repo, {
      'explorer_v2': '{"id":"mei","dirty":true}',
    });
    await again.sync();
    expect(repo.stored, 'mei');
  });

  test(
    'a failing load still ends ready (never hangs on the boot screen)',
    () async {
      final store = await _store(_Repo()..throws = true);
      await store.sync();
      expect(store.status, CharacterStatus.ready);
      expect(store.needsSelection, isFalse);
    },
  );

  testWidgets('the selector shows all nine and saves the pick', (tester) async {
    final repo = _Repo();
    final store = await _store(repo);
    await tester.runAsync(store.sync);
    final router = GoRouter(
      initialLocation: '/character',
      routes: [
        GoRoute(
          path: '/character',
          builder: (_, _) => CharacterSelectorScreen(store: store),
        ),
        GoRoute(path: '/home', builder: (_, _) => const Text('Home')),
      ],
    );
    tester.view.physicalSize = const Size(800, 3200);
    tester.view.devicePixelRatio = 2;
    addTearDown(tester.view.reset);
    await tester.pumpWidget(MaterialApp.router(routerConfig: router));
    await tester.pump(const Duration(milliseconds: 300));
    for (final e in roster.explorers) {
      expect(
        find.byKey(ValueKey('explorer-${e.id}')),
        findsOneWidget,
        reason: e.id,
      );
    }
    await tester.tap(find.byKey(const ValueKey('explorer-samira')));
    await tester.pump();
    expect(find.text('Ich bin Samira'), findsOneWidget);
    await tester.tap(find.byKey(const ValueKey('character-done')));
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 300));
    expect(repo.stored, 'samira');
    expect(find.text('Home'), findsOneWidget);
  });
}
