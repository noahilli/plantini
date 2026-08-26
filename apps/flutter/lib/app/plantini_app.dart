import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../auth/auth_service.dart';
import '../core/theme/app_theme.dart';
import '../features/catalog/presentation/catalog_screens.dart';
import '../features/learning/presentation/learning_screen.dart';
import 'app_dependencies.dart';

final class PlantiniApp extends StatefulWidget {
  const PlantiniApp({super.key, required this.dependencies});

  final AppDependencies dependencies;

  @override
  State<PlantiniApp> createState() => _PlantiniAppState();
}

final class _PlantiniAppState extends State<PlantiniApp> {
  late final GoRouter _router = _createRouter(widget.dependencies);

  @override
  void dispose() {
    _router.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) => MaterialApp.router(
    title: 'Plantini',
    theme: AppTheme.lightTheme,
    darkTheme: AppTheme.darkTheme,
    themeMode: ThemeMode.system,
    routerConfig: _router,
  );
}

GoRouter _createRouter(AppDependencies dependencies) => GoRouter(
  initialLocation: '/ecosystems',
  refreshListenable: dependencies.auth,
  redirect: (context, state) {
    final path = state.matchedLocation;
    if (dependencies.auth.state == AuthState.initializing) {
      return path == '/boot' ? null : '/boot';
    }
    if (!dependencies.auth.isAuthenticated) {
      return path == '/login' ? null : '/login';
    }
    if (path == '/boot' || path == '/login') return '/ecosystems';
    return null;
  },
  routes: [
    GoRoute(path: '/boot', builder: (context, state) => const _BootScreen()),
    GoRoute(
      path: '/login',
      builder: (context, state) => _LoginScreen(auth: dependencies.auth),
    ),
    GoRoute(
      path: '/ecosystems',
      builder: (context, state) =>
          EcosystemListScreen(dependencies: dependencies),
    ),
    GoRoute(
      path: '/ecosystems/:ecosystemId',
      builder: (context, state) => EcosystemLevelsScreen(
        dependencies: dependencies,
        ecosystemId: state.pathParameters['ecosystemId']!,
      ),
    ),
    GoRoute(
      path: '/levels/:levelId',
      builder: (context, state) => LevelOverviewScreen(
        dependencies: dependencies,
        levelId: state.pathParameters['levelId']!,
      ),
    ),
    GoRoute(
      path: '/quiz/:levelId',
      builder: (context, state) {
        final version = state.uri.queryParameters['contentVersion'];
        if (version == null || version.isEmpty) {
          return const _InvalidRouteScreen();
        }
        return LearningScreen(
          dependencies: dependencies,
          levelId: state.pathParameters['levelId']!,
          contentVersion: version,
        );
      },
    ),
  ],
);

final class _BootScreen extends StatelessWidget {
  const _BootScreen();

  @override
  Widget build(BuildContext context) => Scaffold(
    body: Center(
      child: Semantics(
        label: 'Plantini wird gestartet',
        liveRegion: true,
        child: CircularProgressIndicator(),
      ),
    ),
  );
}

final class _LoginScreen extends StatelessWidget {
  const _LoginScreen({required this.auth});

  final AuthService auth;

  @override
  Widget build(BuildContext context) => Scaffold(
    body: SafeArea(
      child: Center(
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 480),
          child: Padding(
            padding: const EdgeInsets.all(32),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                const Icon(Icons.eco_rounded, size: 72),
                const SizedBox(height: 20),
                Text(
                  'Plantini',
                  textAlign: TextAlign.center,
                  style: Theme.of(context).textTheme.headlineMedium,
                ),
                const SizedBox(height: 12),
                const Text(
                  'Entdecke Pflanzen und sichere deine Lernfortschritte in deinem eigenen Konto.',
                  textAlign: TextAlign.center,
                ),
                if (auth.failure != null) ...[
                  const SizedBox(height: 20),
                  Text(auth.failure!.message, textAlign: TextAlign.center),
                ],
                const SizedBox(height: 32),
                FilledButton.icon(
                  key: const ValueKey('auth-login'),
                  onPressed: auth.login,
                  icon: const Icon(Icons.login),
                  label: const Text('Anmelden'),
                ),
              ],
            ),
          ),
        ),
      ),
    ),
  );
}

final class _InvalidRouteScreen extends StatelessWidget {
  const _InvalidRouteScreen();

  @override
  Widget build(BuildContext context) => Scaffold(
    appBar: AppBar(title: const Text('Ungültiger Link')),
    body: const Center(
      child: Text('Dieser Lernlink enthält keine gültige Inhaltsversion.'),
    ),
  );
}
