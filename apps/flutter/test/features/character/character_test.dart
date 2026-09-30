import 'dart:convert';
import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:go_router/go_router.dart';
import 'package:plantini_app/core/errors/app_failure.dart';
import 'package:plantini_app/core/result.dart';
import 'package:plantini_app/features/character/application/character_store.dart';
import 'package:plantini_app/features/character/domain/character_repository.dart';
import 'package:plantini_app/features/character/domain/character_spec.dart';
import 'package:plantini_app/features/character/presentation/character_creator_screen.dart';
import 'package:plantini_app/features/character/presentation/widgets/character_kit.dart';
import 'package:shared_preferences/shared_preferences.dart';

final class _FakeRepository implements CharacterRepository {
  CharacterSpec? stored;
  bool offline = false;
  final saved = <CharacterSpec>[];

  @override
  Future<Result<CharacterSpec?>> load() async => offline
      ? Result.failure(const NetworkFailure(message: 'offline'))
      : Result.success(stored);

  @override
  Future<Result<CharacterSpec>> save(CharacterSpec spec) async {
    if (offline) {
      return Result.failure(const NetworkFailure(message: 'offline'));
    }
    stored = spec;
    saved.add(spec);
    return Result.success(spec);
  }
}

Future<CharacterStore> _store(
  _FakeRepository repository, [
  Map<String, Object> prefs = const {},
]) async {
  SharedPreferences.setMockInitialValues(prefs);
  return CharacterStore(
    repository: repository,
    preferences: await SharedPreferences.getInstance(),
  );
}

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  setUp(() => PlayerLook.spec.value = null);

  group('CharacterSpec', () {
    test('survives a JSON round trip and stays valid when random', () {
      final random = math.Random(3);
      for (var i = 0; i < 200; i++) {
        final spec = CharacterSpec.random(random);
        final back = CharacterSpec.fromJson(spec.toJson());
        expect(back, isNotNull, reason: '${spec.toJson()}');
        expect(back, spec);
      }
    });

    test('an unknown style, colour or version is not a character', () {
      final good = CharacterSpec.starter().toJson();
      expect(CharacterSpec.fromJson(good), isNotNull);
      expect(CharacterSpec.fromJson({...good, 'v': 2}), isNull);
      expect(CharacterSpec.fromJson({...good, 'skin': 'red'}), isNull);
      expect(
        CharacterSpec.fromJson({
          ...good,
          'top': {'style': 'cape', 'color': '#ffffff'},
        }),
        isNull,
      );
      expect(CharacterSpec.fromJson({...good}..remove('top')), isNull);
      expect(CharacterSpec.fromJson('x'), isNull);
    });

    test('the record stays small', () {
      expect(CharacterSpec.starter().toJson().toString().length, lessThan(600));
    });
  });

  group('CharacterKit', () {
    late CharacterKit kit;
    setUpAll(() async => kit = await CharacterKit.load());

    test('offers a part for every style the creator and the server know', () {
      for (final part in CharacterOptions.partNames) {
        for (final option in CharacterOptions.styles[part]!) {
          if (option.id == 'none') continue;
          expect(
            kit.has(part, option.id),
            isTrue,
            reason: '$part.${option.id}',
          );
        }
      }
    });

    test('builds ranger-placed meshes in the chosen colours', () {
      final spec = CharacterSpec.starter().copyWith(
        top: const PartChoice('hoodie', Color(0xFFFF0000)),
      );
      final meshes = kit.build(spec);
      expect(meshes.every((m) => m.motion == 'ranger'), isTrue);
      final hoodie = meshes.firstWhere((m) => m.name == 'Character hoodie');
      expect(hoodie.color.r, closeTo(1, .01)); // pure red stays red
      expect(hoodie.color.g, closeTo(0, .01));
      expect(identical(kit.build(spec), meshes), isTrue, reason: 'cached');
    });

    test('a hat hides the fringe and the body width follows the gender', () {
      final bare = CharacterSpec.starter();
      final hatted = bare.copyWith(
        hat: const PartChoice('cap', Color(0xFFE0A030)),
      );
      expect(kit.build(bare).any((m) => m.name == 'Character fringe'), isTrue);
      expect(
        kit.build(hatted).any((m) => m.name == 'Character fringe'),
        isFalse,
      );

      double width(CharacterGender gender) {
        final top = kit
            .build(bare.copyWith(gender: gender))
            .firstWhere((m) => m.name == 'Character tshirt');
        final xs = [for (final v in top.vertices) v[0]];
        return xs.reduce(math.max) - xs.reduce(math.min);
      }

      expect(
        width(CharacterGender.male),
        greaterThan(width(CharacterGender.female)),
      );
    });
  });

  group('CharacterStore', () {
    test('the first login has no character and needs the creator', () async {
      final repository = _FakeRepository();
      final store = await _store(repository);
      await store.sync();
      expect(store.status, CharacterStatus.ready);
      expect(store.needsCreation, isTrue);

      final spec = CharacterSpec.starter();
      expect((await store.save(spec)).isSuccess, isTrue);
      expect(store.needsCreation, isFalse);
      expect(PlayerLook.spec.value, spec);
      expect(repository.stored, spec);
    });

    test('a saved character is loaded on the next login', () async {
      final repository = _FakeRepository()..stored = CharacterSpec.starter();
      final store = await _store(repository);
      await store.sync();
      expect(store.needsCreation, isFalse);
      expect(PlayerLook.spec.value, CharacterSpec.starter());
    });

    test(
      'offline without a cache shows a starter and does not force the creator',
      () async {
        final repository = _FakeRepository()..offline = true;
        final store = await _store(repository);
        await store.sync();
        expect(store.status, CharacterStatus.ready);
        expect(store.needsCreation, isFalse);
        expect(PlayerLook.spec.value, isNotNull);

        repository
          ..offline = false
          ..stored = null;
        await store.sync();
        expect(
          store.needsCreation,
          isTrue,
          reason: 'online again: the server has none',
        );
      },
    );

    test('a change made offline is sent at the next sync', () async {
      final repository = _FakeRepository()
        ..offline = true
        ..stored = CharacterSpec.starter();
      final store = await _store(repository);
      await store.sync();
      final changed = CharacterSpec.starter().copyWith(
        gender: CharacterGender.female,
      );
      expect((await store.save(changed)).isSuccess, isFalse);
      expect(PlayerLook.spec.value, changed, reason: 'shown at once');

      repository.offline = false;
      final again = await _store(repository, {
        'character_v1': '{"spec":${_json(changed)},"dirty":true}',
      });
      await again.sync();
      expect(repository.stored, changed);
    });
  });

  throwingRepositoryTest();

  testWidgets('the creator changes a part and saves it', (tester) async {
    final repository = _FakeRepository();
    final store = await _store(repository);
    await tester.runAsync(store.sync);
    await tester.runAsync(CharacterKit.load);

    final router = GoRouter(
      initialLocation: '/character',
      routes: [
        GoRoute(
          path: '/character',
          builder: (_, _) => CharacterCreatorScreen(store: store),
        ),
        GoRoute(path: '/home', builder: (_, _) => const Text('Home')),
      ],
    );
    await tester.pumpWidget(MaterialApp.router(routerConfig: router));
    await tester.pump(const Duration(milliseconds: 300));

    await tester.tap(find.byKey(const ValueKey('character-category-hat')));
    await tester.pump();
    await tester.tap(find.byKey(const ValueKey('character-style-hat-beanie')));
    await tester.pump();
    await tester.tap(find.byKey(const ValueKey('character-gender-female')));
    await tester.pump();
    await tester.tap(find.byKey(const ValueKey('character-done')));
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 300));

    final saved = repository.stored!;
    expect(saved.hat.style, 'beanie');
    expect(saved.hat.color, isNotNull);
    expect(saved.gender, CharacterGender.female);
    expect(find.text('Home'), findsOneWidget);
  });
}

String _json(CharacterSpec spec) => jsonEncode(spec.toJson());

final class _ThrowingRepository implements CharacterRepository {
  @override
  Future<Result<CharacterSpec?>> load() async => throw StateError('boom');

  @override
  Future<Result<CharacterSpec>> save(CharacterSpec spec) async =>
      throw StateError('boom');
}

void throwingRepositoryTest() {
  test('a failing load still ends ready, so the app never hangs on the boot screen', () async {
    SharedPreferences.setMockInitialValues({});
    final store = CharacterStore(
      repository: _ThrowingRepository(),
      preferences: await SharedPreferences.getInstance(),
    );
    await store.sync();
    expect(store.status, CharacterStatus.ready);
    expect(store.needsCreation, isFalse);
    expect(PlayerLook.spec.value, isNotNull);
  });
}
