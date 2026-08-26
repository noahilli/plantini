import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'adapters/http/platform_api_client.dart';
import 'app/app_config.dart';
import 'app/app_dependencies.dart';
import 'app/plantini_app.dart';
import 'auth/auth_service.dart';
import 'core/errors/app_failure.dart';
import 'core/ids/client_id_generator.dart';
import 'core/theme/app_theme.dart';
import 'core/time/clock.dart';
import 'features/catalog/application/catalog_use_cases.dart';
import 'features/catalog/infrastructure/cached_catalog_repository.dart';
import 'features/catalog/infrastructure/http_catalog_repository.dart';
import 'features/learning/application/learning_session_service.dart';
import 'features/learning/infrastructure/http_learning_repository.dart';
import 'features/learning/infrastructure/shared_preferences_learning_session_store.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized();
  runApp(const AppBootstrap());
}

/// A failed configuration or local-storage initialisation is a visible app
/// state. No partially initialised late dependency can reach a feature screen.
final class AppBootstrap extends StatefulWidget {
  const AppBootstrap({super.key});

  @override
  State<AppBootstrap> createState() => _AppBootstrapState();
}

final class _AppBootstrapState extends State<AppBootstrap> {
  Future<AppDependencies>? _initialization;

  @override
  void initState() {
    super.initState();
    _initialization = _initialize();
  }

  Future<AppDependencies> _initialize() async {
    final config = AppConfig.fromDartDefines();
    final preferences = await SharedPreferences.getInstance();
    final auth = AuthService(config: config);
    await auth.initialize();
    final api = PlatformApiClient(
      config: config,
      accessTokenProvider: auth.getAccessToken,
    );
    final remoteCatalog = HttpCatalogRepository(api);
    final catalog = CachedCatalogRepository(
      remote: remoteCatalog,
      preferences: preferences,
    );
    final learningRepository = HttpLearningRepository(api);
    return AppDependencies(
      auth: auth,
      apiClient: api,
      loadEcosystems: LoadPublishedEcosystems(catalog),
      loadLevels: LoadPublishedLevels(catalog),
      loadLevel: LoadPublishedLevel(catalog),
      learningSessions: LearningSessionService(
        repository: learningRepository,
        store: SharedPreferencesLearningSessionStore(preferences),
        ids: SecureClientIdGenerator(),
        clock: const SystemClock(),
      ),
      learningRepository: learningRepository,
    );
  }

  void _retry() => setState(() => _initialization = _initialize());

  @override
  Widget build(BuildContext context) => FutureBuilder<AppDependencies>(
    future: _initialization,
    builder: (context, snapshot) {
      if (snapshot.connectionState != ConnectionState.done) {
        return MaterialApp(
          theme: AppTheme.lightTheme,
          home: const Scaffold(
            body: Center(child: CircularProgressIndicator()),
          ),
        );
      }
      if (snapshot.hasData) return PlantiniApp(dependencies: snapshot.data!);
      final error = snapshot.error;
      final message = error is AppFailure
          ? error.message
          : 'Plantini konnte nicht sicher gestartet werden. Prüfe die bereitgestellte Konfiguration oder den lokalen Speicher.';
      return MaterialApp(
        theme: AppTheme.lightTheme,
        home: Scaffold(
          body: Center(
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 480),
              child: Padding(
                padding: const EdgeInsets.all(24),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const Icon(Icons.error_outline, size: 48),
                    const SizedBox(height: 16),
                    Text(message, textAlign: TextAlign.center),
                    const SizedBox(height: 20),
                    FilledButton(
                      onPressed: _retry,
                      child: const Text('Erneut versuchen'),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      );
    },
  );
}
