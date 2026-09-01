import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:openid_client/openid_client.dart';
import 'package:plantini_app/adapters/http/platform_api_client.dart';
import 'package:plantini_app/app/app_config.dart';
import 'package:plantini_app/app/app_dependencies.dart';
import 'package:plantini_app/app/plantini_app.dart';
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
import 'package:plantini_app/features/herbarium/application/herbarium_use_cases.dart';
import 'package:plantini_app/features/herbarium/domain/herbarium_models.dart';
import 'package:plantini_app/features/herbarium/infrastructure/local_herbarium_repository.dart';
import 'package:plantini_app/features/learning/application/learning_session_service.dart';
import 'package:plantini_app/features/learning/domain/learning_models.dart';
import 'package:plantini_app/features/learning/domain/learning_repository.dart';
import 'package:plantini_app/features/catalog/application/content_sync_service.dart';

// ---------------------------------------------------------------------------
// Deterministic widget-flow fakes. This test deliberately has no network,
// Keycloak, camera, or persistence boundary and must not be used as E2E proof.
// ---------------------------------------------------------------------------

final class WidgetFlowAuthPlatformHelper implements AuthPlatformHelper {
  @override
  Future<void> completeRedirect() async {}

  @override
  Future<void> logout(Credential credential) async {}

  Credential? fakeCredential;

  Credential _createFakeCredential(String issuerUrl, String clientId) {
    final issuer = Issuer(
      OpenIdProviderMetadata.fromJson({
        'issuer': issuerUrl,
        'authorization_endpoint': '$issuerUrl/auth',
        'token_endpoint': '$issuerUrl/token',
        'userinfo_endpoint': '$issuerUrl/userinfo',
        'response_types_supported': ['token', 'code', 'code token'],
        'token_endpoint_auth_methods_supported': ['client_secret_post'],
        'scopes_supported': ['openid', 'profile', 'email'],
      }),
    );
    final client = Client(issuer, clientId);
    return client.createCredential(
      accessToken: 'widget-flow-access-token',
      tokenType: 'Bearer',
    );
  }

  @override
  Future<Credential?> login(
    String issuerUrl,
    String clientId,
    List<String> scopes,
  ) async {
    fakeCredential = _createFakeCredential(issuerUrl, clientId);
    return fakeCredential;
  }

  @override
  Future<Credential?> processRedirect(
    String issuerUrl,
    String clientId,
    List<String> scopes,
  ) async {
    return null;
  }
}

final class WidgetFlowCredentialStore implements CredentialStore {
  Credential? _stored;

  @override
  Future<void> clear() async => _stored = null;

  @override
  Future<Credential?> read() async => _stored;

  @override
  Future<void> write(Credential credential) async => _stored = credential;
}

final class WidgetFlowCatalogRepository implements CatalogRepository {
  final List<Ecosystem> ecosystems = [
    const Ecosystem(
      id: 'eco-wald',
      slug: 'wald',
      title: 'Wald',
      releaseVersion: '1.0.0',
      levelIds: ['level-wald-1', 'level-wald-2'],
      description: 'Bäume und Waldpflanzen der gemäßigten Zonen',
    ),
    const Ecosystem(
      id: 'eco-wiese',
      slug: 'wiese',
      title: 'Wiese',
      releaseVersion: '1.0.0',
      levelIds: [],
      description: 'Wiesenblumen und Gräser',
    ),
  ];

  final Map<String, List<Level>> levelsByEcosystem = {
    'eco-wald': [
      const Level(
        id: 'level-wald-1',
        ecosystemId: 'eco-wald',
        sequence: 1,
        title: 'Heimische Laubbäume',
        learningGoal: 'Lerne Eiche, Buche und Ahorn sicher zu bestimmen.',
        status: LevelStatus.available,
        minimumScore: 0.75,
        requiredQuizIds: ['quiz-item-1', 'quiz-item-2'],
        plantIds: ['plant-eiche', 'plant-buche'],
      ),
      const Level(
        id: 'level-wald-2',
        ecosystemId: 'eco-wald',
        sequence: 2,
        title: 'Nadelbäume & Sträucher',
        learningGoal: 'Lerne Fichte, Tanne und Kiefer kennen.',
        status: LevelStatus.locked,
        minimumScore: 0.75,
        requiredQuizIds: [],
        plantIds: [],
      ),
    ],
  };

  @override
  Future<Result<List<Ecosystem>>> listPublishedEcosystems() async {
    return Result.success(ecosystems);
  }

  @override
  Future<Result<List<Level>>> listPublishedLevels(String ecosystemId) async {
    final list = levelsByEcosystem[ecosystemId] ?? const [];
    return Result.success(list);
  }

  @override
  Future<Result<LevelContent>> getPublishedLevel(String levelId) async {
    if (levelId == 'level-wald-1') {
      return Result.success(
        const LevelContent(
          level: Level(
            id: 'level-wald-1',
            ecosystemId: 'eco-wald',
            sequence: 1,
            title: 'Heimische Laubbäume',
            learningGoal: 'Lerne Eiche, Buche und Ahorn sicher zu bestimmen.',
            status: LevelStatus.available,
            minimumScore: 0.75,
            requiredQuizIds: ['quiz-item-1', 'quiz-item-2'],
            plantIds: ['plant-eiche', 'plant-buche'],
          ),
          contentVersion: '1.0.0',
        ),
      );
    }
    return const Result.failure(
      ContractFailure(message: 'Level nicht gefunden', missingFields: []),
    );
  }
}

final class WidgetFlowLearningRepository implements LearningRepository {
  final List<QuizItem> quizItems = [
    const QuizItem(
      id: 'quiz-item-1',
      levelId: 'level-wald-1',
      contentVersion: '1.0.0',
      type: QuizItemType.multipleChoice,
      prompt: 'Welcher Baum hat gelappte Blätter und bildet Eicheln aus?',
      choices: [
        QuizChoice(id: 'c1-1', label: 'Stieleiche'),
        QuizChoice(id: 'c1-2', label: 'Rotbuche'),
        QuizChoice(id: 'c1-3', label: 'Berg-Ahorn'),
      ],
    ),
    const QuizItem(
      id: 'quiz-item-2',
      levelId: 'level-wald-1',
      contentVersion: '1.0.0',
      type: QuizItemType.multipleChoice,
      prompt: 'Welche Baumart hat eine glatte, silbergraue Rinde?',
      choices: [
        QuizChoice(id: 'c2-1', label: 'Rotbuche'),
        QuizChoice(id: 'c2-2', label: 'Waldkiefer'),
        QuizChoice(id: 'c2-3', label: 'Gemeine Fichte'),
      ],
    ),
  ];

  @override
  Future<Result<List<QuizItem>>> listQuizItems({
    required String levelId,
    required String contentVersion,
  }) async {
    return Result.success(quizItems);
  }

  @override
  Future<Result<LevelAttempt>> startLevelAttempt({
    required String levelId,
    required String clientAttemptId,
    required String contentVersion,
    required String idempotencyKey,
  }) async {
    return Result.success(
      LevelAttempt(
        id: 'attempt-widget-flow-001',
        levelId: levelId,
        contentVersion: contentVersion,
        status: LevelAttemptStatus.active,
        startedAt: DateTime.now(),
      ),
    );
  }

  @override
  Future<Result<EventBatchAcknowledgement>> submitEvents({
    required List<LearningEvent> events,
    required String idempotencyKey,
  }) async {
    return Result.success(
      EventBatchAcknowledgement(
        acceptedClientEventIds: events.map((e) => e.clientEventId).toList(),
        rejectedCodes: const {},
      ),
    );
  }

  @override
  Future<Result<LevelCompletion>> completeLevelAttempt({
    required String attemptId,
    required String clientEventId,
    required List<QuizAnswer> answers,
    required String idempotencyKey,
  }) async {
    return Result.success(
      LevelCompletion(
        attemptId: attemptId,
        passed: true,
        score: 1.0,
        status: CompletionStatus.completed,
        progress: ProgressSnapshot(updatedAt: DateTime.now(), levels: const []),
      ),
    );
  }

  @override
  Future<Result<ProgressSnapshot>> getProgress({DateTime? since}) async {
    return Result.success(
      ProgressSnapshot(updatedAt: DateTime.now(), levels: const []),
    );
  }
}

final class WidgetFlowInMemoryLearningStore implements LearningSessionStore {
  final Map<String, LearningSession> _store = {};

  @override
  Future<Result<void>> delete(String levelId) async {
    _store.remove(levelId);
    return const Result.success(null);
  }

  @override
  Future<Result<LearningSession?>> read(String levelId) async {
    return Result.success(_store[levelId]);
  }

  @override
  Future<Result<void>> save(LearningSession session) async {
    _store[session.levelId] = session;
    return const Result.success(null);
  }
}

final class WidgetFlowClientIdGenerator implements ClientIdGenerator {
  int _counter = 0;
  @override
  String next() =>
      '00000000-0000-4000-8000-${(++_counter).toString().padLeft(12, '0')}';
}

final class WidgetFlowSystemClock implements Clock {
  const WidgetFlowSystemClock();
  @override
  DateTime now() => DateTime.parse('2026-08-26T12:00:00.000Z');
}

// ---------------------------------------------------------------------------
// Widget-flow dependencies factory
// ---------------------------------------------------------------------------

AppDependencies createWidgetFlowDependencies() {
  final config = AppConfig(
    apiBaseUri: Uri.parse('http://127.0.0.1:1338/api/v1'),
    oidcIssuerUri: Uri.parse('http://127.0.0.1:8082/realms/plantini'),
    oidcClientId: 'plantini-mobile-dev',
    environment: PlantiniEnvironment.development,
  );

  final authHelper = WidgetFlowAuthPlatformHelper();
  final credentialStore = WidgetFlowCredentialStore();
  final auth = AuthService(
    config: config,
    helper: authHelper,
    credentialStore: credentialStore,
  );

  final catalogRepo = WidgetFlowCatalogRepository();
  final learningRepo = WidgetFlowLearningRepository();

  final initialHerbariumEntries = [
    HerbariumEntry(
      id: 'herbarium-widget-flow-1',
      observedAt: DateTime.parse('2026-08-26T09:30:00.000Z'),
      plantName: 'Stieleiche',
      scientificName: 'Quercus robur',
      note: 'Alter Baum im Mischwald',
      identificationResult: 'PlantNet: Quercus robur (99%)',
      version: 'v1',
      syncStatus: SyncStatus.synced,
    ),
    HerbariumEntry(
      id: 'herbarium-widget-flow-2',
      observedAt: DateTime.parse('2026-08-26T10:15:00.000Z'),
      plantName: 'Rotbuche',
      scientificName: 'Fagus sylvatica',
      note: 'Am Waldrand entdeckt',
      identificationResult: 'PlantNet: Fagus sylvatica (96%)',
      version: 'v1',
      syncStatus: SyncStatus.pending,
    ),
  ];

  final herbariumRepo = LocalHerbariumRepository(
    initialEntries: initialHerbariumEntries,
  );

  return AppDependencies(
    auth: auth,
    apiClient: PlatformApiClient(
      config: config,
      accessTokenProvider: auth.getAccessToken,
    ),
    loadEcosystems: LoadPublishedEcosystems(catalogRepo),
    loadLevels: LoadPublishedLevels(catalogRepo),
    loadLevel: LoadPublishedLevel(catalogRepo),
    learningSessions: LearningSessionService(
      repository: learningRepo,
      store: WidgetFlowInMemoryLearningStore(),
      ids: WidgetFlowClientIdGenerator(),
      clock: const WidgetFlowSystemClock(),
    ),
    learningRepository: learningRepo,
    contentSync: ContentSyncService(
      apiClient: PlatformApiClient(
        config: config,
        accessTokenProvider: auth.getAccessToken,
      ),
    ),
    herbariumRepository: herbariumRepo,
    listHerbarium: ListHerbarium(herbariumRepo),
    deleteHerbariumEntry: DeleteEntry(herbariumRepo),
    syncHerbariumEntries: SyncEntries(herbariumRepo),
  );
}

// ---------------------------------------------------------------------------
// Widget Main Walkthrough Test
// ---------------------------------------------------------------------------

void main() {
  group('Plantini widget flow', () {
    testWidgets(
      'uses fakes for the visible Login -> Lernen -> Profil -> Logout journey',
      (tester) async {
        // ---------------------------------------------------------------------
        // 1. App starten (Unauthentifizierter Zustand)
        // ---------------------------------------------------------------------
        final dependencies = createWidgetFlowDependencies();
        await dependencies.auth.initialize();

        await tester.pumpWidget(PlantiniApp(dependencies: dependencies));
        await tester.pumpAndSettle();

        // ---------------------------------------------------------------------
        // 2. LoginScreen: deterministic fake login
        // ---------------------------------------------------------------------
        expect(find.text('Plantini'), findsOneWidget);
        expect(find.text('Anmelden'), findsOneWidget);
        expect(find.byKey(const ValueKey('auth-login')), findsOneWidget);

        // Login-Button drücken
        await tester.tap(find.byKey(const ValueKey('auth-login')));
        await tester.pumpAndSettle();

        // Nach erfolgreichem Login -> Weiterleitung zur Ökosystem-Liste
        expect(find.text('Ökosysteme'), findsOneWidget);
        expect(find.text('Wald'), findsOneWidget);
        expect(find.text('Wiese'), findsOneWidget);

        // ---------------------------------------------------------------------
        // 3. Home/Ecosystems: Das Ökosystem "Wald" anklicken
        // ---------------------------------------------------------------------
        final waldCard = find.byKey(const ValueKey('ecosystem-card-eco-wald'));
        expect(waldCard, findsOneWidget);
        await tester.tap(waldCard);
        await tester.pumpAndSettle();

        // ---------------------------------------------------------------------
        // 4. Level wählen (Lernpfad) & Level-Übersicht aufrufen
        // ---------------------------------------------------------------------
        expect(find.text('Lernpfad'), findsOneWidget);
        expect(find.text('1. Heimische Laubbäume'), findsOneWidget);

        final levelCard = find.byKey(const ValueKey('level-card-level-wald-1'));
        expect(levelCard, findsOneWidget);
        await tester.tap(levelCard);
        await tester.pumpAndSettle();

        // Level-Übersicht ("Lerneinheit") prüfen
        expect(find.text('Lerneinheit'), findsOneWidget);
        expect(find.text('Heimische Laubbäume'), findsOneWidget);
        expect(
          find.byKey(const ValueKey('learning-start-quiz')),
          findsOneWidget,
        );

        // Quiz starten
        await tester.tap(find.byKey(const ValueKey('learning-start-quiz')));
        await tester.pumpAndSettle();

        // ---------------------------------------------------------------------
        // 5. Quiz durchspielen und lösen
        // ---------------------------------------------------------------------
        expect(find.text('Quiz'), findsOneWidget);

        // Frage 1 beantworten
        expect(
          find.text(
            'Welcher Baum hat gelappte Blätter und bildet Eicheln aus?',
          ),
          findsOneWidget,
        );
        final firstChoiceQ1 = find.byKey(const ValueKey('quiz-answer-c1-1'));
        expect(firstChoiceQ1, findsOneWidget);
        await tester.tap(firstChoiceQ1);
        await tester.pumpAndSettle();

        // Frage 2 beantworten
        expect(
          find.text('Welche Baumart hat eine glatte, silbergraue Rinde?'),
          findsOneWidget,
        );
        final firstChoiceQ2 = find.byKey(const ValueKey('quiz-answer-c2-1'));
        expect(firstChoiceQ2, findsOneWidget);
        await tester.tap(firstChoiceQ2);
        await tester.pumpAndSettle();

        // Level abschließen
        final completeButton = find.byKey(
          const ValueKey('learning-level-complete'),
        );
        expect(completeButton, findsOneWidget);
        await tester.tap(completeButton);
        await tester.pumpAndSettle();

        // Erfolgsanzeige prüfen
        expect(
          find.byKey(const ValueKey('learning-level-completed')),
          findsOneWidget,
        );
        expect(find.text('Level abgeschlossen'), findsOneWidget);

        // ---------------------------------------------------------------------
        // 6. Profil & Logout testen
        // ---------------------------------------------------------------------
        expect(find.text('Profil'), findsOneWidget);
        await tester.tap(find.text('Profil'));
        await tester.pumpAndSettle();

        expect(find.text('Route: /profile'), findsOneWidget);
        final logoutBtn = find.byKey(const ValueKey('auth-logout')).first;
        await tester.tap(logoutBtn);
        await tester.pumpAndSettle();

        // Zurück auf dem LoginScreen
        expect(find.text('Anmelden'), findsOneWidget);
        expect(find.byKey(const ValueKey('auth-login')), findsOneWidget);
      },
    );
  });
}
