import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../auth/auth_service.dart';
import '../core/theme/app_colors.dart';
import '../features/catalog/domain/plant_model.dart';
import '../features/catalog/presentation/catalog_screens.dart';
import '../features/catalog/presentation/plant_detail_screen.dart';
import '../features/field/presentation/field_capture_screen.dart';
import '../features/herbarium/presentation/herbarium_screen.dart';
import '../features/learning/presentation/learning_screen.dart';
import 'app_dependencies.dart';

/// Creates the declarative [GoRouter] for Plantini.
GoRouter createAppRouter(AppDependencies dependencies) => GoRouter(
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
    // Top-level unauthenticated / system routes outside the Shell
    GoRoute(path: '/boot', builder: (context, state) => const BootScreen()),
    GoRoute(
      path: '/login',
      builder: (context, state) => LoginScreen(auth: dependencies.auth),
    ),

    // Main App Shell with Bottom Navigation (Lernen, Feld, Profil)
    ShellRoute(
      builder: (context, state, child) =>
          AppShell(location: state.matchedLocation, child: child),
      routes: [
        GoRoute(
          path: '/',
          builder: (context, state) =>
              EcosystemListScreen(dependencies: dependencies),
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
          path: '/levels/:levelId/quiz',
          builder: (context, state) {
            final version =
                state.uri.queryParameters['contentVersion'] ?? 'latest';
            return LearningScreen(
              dependencies: dependencies,
              levelId: state.pathParameters['levelId']!,
              contentVersion: version,
            );
          },
        ),
        GoRoute(
          path: '/quiz/:levelId',
          builder: (context, state) {
            final version = state.uri.queryParameters['contentVersion'];
            if (version == null || version.isEmpty) {
              return const InvalidRouteScreen();
            }
            return LearningScreen(
              dependencies: dependencies,
              levelId: state.pathParameters['levelId']!,
              contentVersion: version,
            );
          },
        ),
        GoRoute(
          path: '/plants/:plantId',
          builder: (context, state) {
            final plantId = state.pathParameters['plantId'] ?? '';
            final plant = state.extra is Plant
                ? state.extra as Plant
                : Plant(
                    id: plantId,
                    slug: plantId,
                    scientificName: 'Pflanzendetails ($plantId)',
                    commonName: 'Pflanze',
                    family: '',
                    description: 'Pflanzensteckbrief für ID: $plantId',
                    releaseVersion: '1.0.0',
                  );
            return PlantDetailScreen(plant: plant);
          },
        ),
        GoRoute(
          path: '/field',
          builder: (context, state) =>
              FieldCaptureScreen(dependencies: dependencies),
        ),
        GoRoute(
          path: '/herbarium',
          builder: (context, state) =>
              HerbariumScreen(dependencies: dependencies),
        ),
        GoRoute(
          path: '/profile',
          builder: (context, state) => ProfileScreen(auth: dependencies.auth),
        ),
      ],
    ),
  ],
);

/// Shell widget with bottom navigation bar containing 3 tabs: Lernen, Feld, Profil.
final class AppShell extends StatelessWidget {
  const AppShell({super.key, required this.child, required this.location});

  final Widget child;
  final String location;

  int _calculateSelectedIndex() {
    if (location.startsWith('/herbarium') || location.startsWith('/field')) {
      return 1;
    }
    if (location.startsWith('/profile')) {
      return 2;
    }
    return 0; // Lernen (/ecosystems, /levels, /plants, etc.)
  }

  void _onItemTapped(BuildContext context, int index) {
    switch (index) {
      case 0:
        context.go('/ecosystems');
        break;
      case 1:
        context.go('/field');
        break;
      case 2:
        context.go('/profile');
        break;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: child,
      bottomNavigationBar: NavigationBar(
        selectedIndex: _calculateSelectedIndex(),
        onDestinationSelected: (index) => _onItemTapped(context, index),
        destinations: const [
          NavigationDestination(
            icon: Icon(Icons.school_outlined),
            selectedIcon: Icon(Icons.school),
            label: 'Lernen',
          ),
          NavigationDestination(
            icon: Icon(Icons.eco_outlined),
            selectedIcon: Icon(Icons.eco),
            label: 'Feld',
          ),
          NavigationDestination(
            icon: Icon(Icons.person_outline),
            selectedIcon: Icon(Icons.person),
            label: 'Profil',
          ),
        ],
      ),
    );
  }
}

/// Placeholder screen for the user profile (Tab "Profil").
final class ProfileScreen extends StatelessWidget {
  const ProfileScreen({super.key, required this.auth});

  final AuthService auth;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Profil'),
        actions: [
          IconButton(
            key: const ValueKey('auth-logout'),
            tooltip: 'Abmelden',
            onPressed: auth.logout,
            icon: const Icon(Icons.logout),
          ),
        ],
      ),
      body: Center(
        child: Padding(
          padding: const EdgeInsets.all(24.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Icon(
                Icons.person_outline,
                size: 64,
                color: AppColors.forest,
              ),
              const SizedBox(height: 16),
              Text(
                'Profil',
                style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                  color: AppColors.forest,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 8),
              const Text(
                'Route: /profile',
                style: TextStyle(color: AppColors.muted),
              ),
              const SizedBox(height: 24),
              ElevatedButton.icon(
                onPressed: auth.logout,
                icon: const Icon(Icons.logout),
                label: const Text('Abmelden'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

/// Startup boot splash screen.
final class BootScreen extends StatelessWidget {
  const BootScreen({super.key});

  @override
  Widget build(BuildContext context) => Scaffold(
    body: Center(
      child: Semantics(
        label: 'Plantini wird gestartet',
        liveRegion: true,
        child: const CircularProgressIndicator(),
      ),
    ),
  );
}

/// Login screen when user is unauthenticated.
final class LoginScreen extends StatelessWidget {
  const LoginScreen({super.key, required this.auth});

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

/// Screen shown when a link is invalid or lacks required query parameters.
final class InvalidRouteScreen extends StatelessWidget {
  const InvalidRouteScreen({super.key});

  @override
  Widget build(BuildContext context) => Scaffold(
    appBar: AppBar(title: const Text('Ungültiger Link')),
    body: const Center(
      child: Text('Dieser Lernlink enthält keine gültige Inhaltsversion.'),
    ),
  );
}
