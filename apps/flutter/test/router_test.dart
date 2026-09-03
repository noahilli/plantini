import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:go_router/go_router.dart';
import 'package:openid_client/openid_client.dart';
import 'package:plantini_app/adapters/http/platform_api_client.dart';
import 'package:plantini_app/app/app_config.dart';
import 'package:plantini_app/app/app_dependencies.dart';
import 'package:plantini_app/app/router.dart';
import 'package:plantini_app/auth/auth_platform_interface.dart';
import 'package:plantini_app/auth/auth_service.dart';
import 'package:plantini_app/auth/credential_store.dart';
import 'package:plantini_app/core/errors/app_failure.dart';
import 'package:plantini_app/core/ids/client_id_generator.dart';
import 'package:plantini_app/core/result.dart';
import 'package:plantini_app/core/time/clock.dart';
import 'package:plantini_app/features/catalog/application/catalog_use_cases.dart';
import 'package:plantini_app/features/catalog/domain/catalog_models.dart';
import 'package:plantini_app/features/catalog/domain/catalog_repository.dart';
import 'package:plantini_app/features/catalog/presentation/plant_detail_screen.dart';
import 'package:plantini_app/features/herbarium/presentation/herbarium_screen.dart';
import 'package:plantini_app/features/learning/application/learning_session_service.dart';
import 'package:plantini_app/features/learning/domain/learning_models.dart';
import 'package:plantini_app/features/learning/domain/learning_repository.dart';
import 'package:plantini_app/features/catalog/application/content_sync_service.dart';

final class MockAuthPlatformHelper implements AuthPlatformHelper {
  @override
  Future<void> completeRedirect() async {}

  @override
  Future<void> logout(Credential credential) async {}

  @override
  Future<Credential?> login(
    String issuerUrl,
    String clientId,
    List<String> scopes,
  ) async => null;

  @override
  Future<Credential?> processRedirect(
    String issuerUrl,
    String clientId,
    List<String> scopes,
  ) async => null;
}

final class MockCredentialStore implements CredentialStore {
  @override
  Future<void> clear() async {}

  @override
  Future<Credential?> read() async => null;

  @override
  Future<void> write(Credential credential) async {}
}

final class MockCatalogRepository implements CatalogRepository {
  @override
  Future<Result<Plant>> getPublishedPlant(String plantId) async =>
      Result.failure(
        const ContractFailure(message: 'not found', missingFields: []),
      );

  @override
  Future<Result<List<Ecosystem>>> listPublishedEcosystems() async =>
      const Result.success([]);

  @override
  Future<Result<LevelContent>> getPublishedLevel(String levelId) async =>
      Result.failure(
        const ContractFailure(message: 'not found', missingFields: []),
      );

  @override
  Future<Result<List<Level>>> listPublishedLevels(String ecosystemId) async =>
      const Result.success([]);
}

final class MockLearningRepository implements LearningRepository {
  @override
  Future<Result<LevelCompletion>> completeLevelAttempt({
    required String attemptId,
    required String clientEventId,
    required List<QuizAnswer> answers,
    required String idempotencyKey,
  }) async =>
      Result.failure(const ContractFailure(message: 'mock', missingFields: []));

  @override
  Future<Result<ProgressSnapshot>> getProgress({DateTime? since}) async =>
      Result.failure(const ContractFailure(message: 'mock', missingFields: []));

  @override
  Future<Result<List<QuizItem>>> listQuizItems({
    required String levelId,
    required String contentVersion,
  }) async => const Result.success([]);

  @override
  Future<Result<LevelAttempt>> startLevelAttempt({
    required String levelId,
    required String clientAttemptId,
    required String contentVersion,
    required String idempotencyKey,
  }) async =>
      Result.failure(const ContractFailure(message: 'mock', missingFields: []));

  @override
  Future<Result<EventBatchAcknowledgement>> submitEvents({
    required List<LearningEvent> events,
    required String idempotencyKey,
  }) async =>
      Result.failure(const ContractFailure(message: 'mock', missingFields: []));
}

void main() {
  late AppDependencies dependencies;
  late AuthService auth;

  setUp(() {
    final config = AppConfig(
      apiBaseUri: Uri.parse('http://localhost:1337'),
      oidcIssuerUri: Uri.parse('http://localhost:8080/realms/plantini'),
      oidcClientId: 'plantini-app',
      environment: PlantiniEnvironment.development,
    );
    auth = AuthService(
      config: config,
      helper: MockAuthPlatformHelper(),
      credentialStore: MockCredentialStore(),
    );
    final catalogRepo = MockCatalogRepository();
    final learningRepo = MockLearningRepository();
    dependencies = AppDependencies(
      auth: auth,
      apiClient: PlatformApiClient(
        config: config,
        accessTokenProvider: () async => null,
      ),
      loadEcosystems: LoadPublishedEcosystems(catalogRepo),
      loadLevels: LoadPublishedLevels(catalogRepo),
      loadLevel: LoadPublishedLevel(catalogRepo),
      loadPlant: LoadPublishedPlant(catalogRepo),
      learningSessions: LearningSessionService(
        repository: learningRepo,
        store: _DummyStore(),
        ids: _DummyIds(),
        clock: _DummyClock(),
      ),
      learningRepository: learningRepo,
      contentSync: ContentSyncService(
        apiClient: PlatformApiClient(
          config: config,
          accessTokenProvider: () async => null,
        ),
      ),
    );
  });

  group('GoRouter & Navigation', () {
    testWidgets('redirects to /login when unauthenticated', (tester) async {
      await auth.initialize();
      final router = createAppRouter(dependencies);

      await tester.pumpWidget(MaterialApp.router(routerConfig: router));
      await tester.pumpAndSettle();

      expect(find.byType(LoginScreen), findsOneWidget);
      expect(find.text('Anmelden'), findsOneWidget);
    });

    testWidgets('renders AppShell with NavigationBar destinations', (
      tester,
    ) async {
      await tester.pumpWidget(
        MaterialApp(
          home: AppShell(
            location: '/ecosystems',
            child: const Text('Lerninhalt'),
          ),
        ),
      );

      expect(find.text('Home'), findsOneWidget);
      expect(find.text('Lernen'), findsOneWidget);
      expect(find.text('Expedition'), findsOneWidget);
      expect(find.text('Herbarium'), findsOneWidget);
      expect(find.text('Profil'), findsOneWidget);
      expect(find.text('Lerninhalt'), findsOneWidget);
    });

    testWidgets('renders HerbariumScreen', (tester) async {
      await tester.pumpWidget(
        MaterialApp(home: HerbariumScreen(dependencies: dependencies)),
      );
      await tester.pumpAndSettle();

      expect(find.text('MEIN HERBARIUM'), findsOneWidget);
      expect(
        find.byKey(const ValueKey('herbarium-search-field')),
        findsOneWidget,
      );
    });

    testWidgets('renders ProfileScreen placeholder', (tester) async {
      await tester.pumpWidget(MaterialApp(home: ProfileScreen(auth: auth)));

      expect(find.text('Profil & Datenschutz'), findsOneWidget);
      expect(find.text('Route: /profile'), findsOneWidget);
    });

    testWidgets('renders PlantDetailScreen via router fallback', (
      tester,
    ) async {
      const plant = Plant(
        id: 'p-1',
        slug: 'slug-1',
        scientificName: 'Rosa canina',
        commonName: 'Hundsrose',
        family: 'Rosaceae',
        description: 'Häufige Wildrose.',
        releaseVersion: '1.0.0',
      );

      final router = GoRouter(
        initialLocation: '/plants/p-1',
        routes: [
          GoRoute(
            path: '/plants/:plantId',
            builder: (context, state) =>
                PlantDetailScreen(plant: (state.extra as Plant?) ?? plant),
          ),
        ],
      );

      await tester.pumpWidget(MaterialApp.router(routerConfig: router));
      await tester.pumpAndSettle();

      expect(find.text('Rosa canina'), findsWidgets);
      expect(find.text('Hundsrose'), findsWidgets);
    });
  });
}

final class _DummyStore implements LearningSessionStore {
  @override
  Future<Result<void>> delete(String levelId) async =>
      const Result.success(null);
  @override
  Future<Result<LearningSession?>> read(String levelId) async =>
      const Result.success(null);
  @override
  Future<Result<void>> save(LearningSession session) async =>
      const Result.success(null);
}

final class _DummyIds implements ClientIdGenerator {
  @override
  String next() => '00000000-0000-4000-8000-000000000001';
}

final class _DummyClock implements Clock {
  @override
  DateTime now() => DateTime.parse('2026-08-26T12:00:00Z');
}
