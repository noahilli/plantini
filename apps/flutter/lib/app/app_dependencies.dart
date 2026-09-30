import '../adapters/http/platform_api_client.dart';
import '../auth/auth_service.dart';
import '../features/catalog/application/catalog_use_cases.dart';
import '../features/character/application/character_store.dart';
import '../features/catalog/application/content_sync_service.dart';
import '../features/catalog/domain/ecosystem_journey.dart';
import '../features/field/domain/field_repository.dart';
import '../features/herbarium/application/herbarium_use_cases.dart';
import '../features/herbarium/domain/herbarium_repository.dart';
import '../features/herbarium/domain/insight_repository.dart';
import '../features/learning/application/learning_session_service.dart';
import '../features/learning/domain/learning_repository.dart';

/// Explicit dependency bundle assembled once at bootstrap. Feature widgets get
/// use cases and ports, never raw Dio, Strapi, or storage objects.
final class AppDependencies {
  const AppDependencies({
    required this.auth,
    required this.apiClient,
    required this.loadEcosystems,
    required this.loadLevels,
    required this.loadLevel,
    required this.loadPlant,
    required this.learningSessions,
    required this.learningRepository,
    required this.contentSync,
    this.herbariumRepository,
    this.fieldRepository,
    this.listHerbarium,
    this.deleteHerbariumEntry,
    this.syncHerbariumEntries,
    this.ecosystemJourneys,
    this.insights,
    this.character,
  });

  final AuthService auth;
  final PlatformApiClient apiClient;
  final LoadPublishedEcosystems loadEcosystems;
  final LoadPublishedLevels loadLevels;
  final LoadPublishedLevel loadLevel;
  final LoadPublishedPlant loadPlant;
  final LearningSessionService learningSessions;
  final LearningRepository learningRepository;
  final ContentSyncService contentSync;
  final EcosystemJourneyRepository? ecosystemJourneys;
  final InsightRepository? insights;
  final CharacterStore? character;
  final HerbariumRepository? herbariumRepository;
  final FieldRepository? fieldRepository;
  final ListHerbarium? listHerbarium;
  final DeleteEntry? deleteHerbariumEntry;
  final SyncEntries? syncHerbariumEntries;
}
