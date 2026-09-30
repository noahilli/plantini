import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../auth/auth_service.dart';
import '../core/theme/app_colors.dart';
import '../design_system/world_art.dart';
import '../features/catalog/domain/plant_model.dart';
import '../features/catalog/presentation/catalog_screens.dart';
import '../features/catalog/presentation/plant_detail_screen.dart';
import '../features/catalog/presentation/widgets/ecosystem_vitrine.dart';
import '../features/catalog/presentation/widgets/world_lighting.dart';
import '../features/catalog/presentation/widgets/modular_forest_view.dart'
    show EcosystemWorld;
import '../features/field/presentation/field_capture_screen.dart';
import '../features/herbarium/presentation/herbarium_screen.dart';
import '../features/home/presentation/home_screen.dart';
import '../features/learning/presentation/learning_screen.dart';
import '../features/learning/presentation/practice_screen.dart';
import 'app_dependencies.dart';

/// Creates the declarative [GoRouter] for Plantini.
GoRouter createAppRouter(AppDependencies dependencies) => GoRouter(
  initialLocation: '/home',
  refreshListenable: dependencies.auth,
  redirect: (context, state) {
    final path = state.matchedLocation;
    if (dependencies.auth.state == AuthState.initializing) {
      return path == '/boot' ? null : '/boot';
    }
    if (!dependencies.auth.isAuthenticated) {
      return path == '/login' ? null : '/login';
    }
    if (path == '/boot' || path == '/login') return '/home';
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
          path: '/home',
          builder: (context, state) => HomeScreen(dependencies: dependencies),
        ),
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
          path: '/ecosystems/:ecosystemId/practice',
          builder: (context, state) => PracticeScreen(
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
            return PlantDetailScreen(
              plant: plant,
              insights: dependencies.insights,
            );
          },
        ),
        GoRoute(
          path: '/field',
          builder: (context, state) => FieldCaptureScreen(
            dependencies: dependencies,
            expectedPlantId: state.uri.queryParameters['expectedPlantId'],
            expectedPlantName: state.uri.queryParameters['expectedPlantName'],
          ),
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
    if (location.startsWith('/home')) return 0;
    if (location.startsWith('/field')) {
      return 2;
    }
    if (location.startsWith('/herbarium')) return 3;
    if (location.startsWith('/profile')) {
      return 4;
    }
    return 1;
  }

  void _onItemTapped(BuildContext context, int index) {
    switch (index) {
      case 0:
        context.go('/home');
        break;
      case 1:
        context.go('/ecosystems');
        break;
      case 2:
        context.go('/field');
        break;
      case 3:
        context.go('/herbarium');
        break;
      case 4:
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
            icon: Icon(Icons.terrain_outlined),
            selectedIcon: Icon(Icons.terrain),
            label: 'Home',
          ),
          NavigationDestination(
            icon: Icon(Icons.route_outlined),
            selectedIcon: Icon(Icons.route),
            label: 'Lernen',
          ),
          NavigationDestination(
            icon: Icon(Icons.explore_outlined),
            selectedIcon: Icon(Icons.explore),
            label: 'Expedition',
          ),
          NavigationDestination(
            icon: Icon(Icons.local_florist_outlined),
            selectedIcon: Icon(Icons.local_florist),
            label: 'Herbarium',
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
      body: SafeArea(
        child: Column(
          children: [
            Expanded(
              child: ListView(
                padding: const EdgeInsets.fromLTRB(22, 22, 22, 16),
                children: [
                  const Text(
                    'Route: /profile',
                    style: TextStyle(color: Colors.transparent, fontSize: 1),
                  ),
                  Text(
                    'DEIN BEREICH',
                    style: Theme.of(context).textTheme.labelSmall
                        ?.copyWith(color: AppColors.sage700),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    'Profil & Datenschutz',
                    style: Theme.of(context).textTheme.headlineLarge,
                  ),
                  const SizedBox(height: 22),
                  Container(
                    padding: const EdgeInsets.all(18),
                    decoration: BoxDecoration(
                      color: AppColors.sage800,
                      borderRadius: BorderRadius.circular(28),
                    ),
                    child: Row(
                      children: [
                        Image.asset(
                          WorldArt.explorer,
                          width: 80,
                          height: 96,
                          excludeFromSemantics: true,
                        ),
                        const SizedBox(width: 14),
                        const Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                'Plantini-Forscher:in',
                                style: TextStyle(
                                  color: AppColors.neutral100,
                                  fontSize: 17,
                                  fontWeight: FontWeight.w700,
                                ),
                              ),
                              SizedBox(height: 3),
                              Text(
                                'Deine Funde bleiben privat.',
                                style: TextStyle(
                                  color: AppColors.sage300,
                                  fontSize: 12,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 18),
                  const _DayTimeCard(),
                  const SizedBox(height: 18),
                  Card(
                    child: Column(
                      children: [
                        _ProfileTile(
                          icon: Icons.language,
                          title: 'Sprache',
                          value: 'Deutsch',
                        ),
                        _ProfileTile(
                          icon: Icons.lock_outline,
                          title: 'Datenschutz',
                          value: 'Privat standardmäßig',
                        ),
                        _ProfileTile(
                          icon: Icons.download_outlined,
                          title: 'Daten exportieren',
                          value: 'Deine Daten verwalten',
                        ),
                        _ProfileTile(
                          icon: Icons.help_outline,
                          title: 'Hilfe & Feedback',
                          value: 'Grenzen und Sicherheit',
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
            Padding(
              padding: const EdgeInsets.fromLTRB(22, 8, 22, 18),
              child: OutlinedButton.icon(
                key: const ValueKey('auth-logout'),
                onPressed: auth.logout,
                icon: const Icon(Icons.logout),
                label: const Text('Auf allen Geräten abmelden'),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

/// Lets the pupil look at the ecosystems at another time of day.
final class _DayTimeCard extends StatefulWidget {
  const _DayTimeCard();

  @override
  State<_DayTimeCard> createState() => _DayTimeCardState();
}

final class _DayTimeCardState extends State<_DayTimeCard> {
  static const prefsKey = 'daytime_pin';

  Future<void> _choose(DayPhase? phase) async {
    DayClock.pin(phase);
    setState(() {});
    try {
      final prefs = await SharedPreferences.getInstance();
      if (phase == null) {
        await prefs.remove(prefsKey);
      } else {
        await prefs.setString(prefsKey, phase.name);
      }
    } catch (_) {
      // Only the remembered choice is lost; the view already changed.
    }
  }

  @override
  Widget build(BuildContext context) => Card(
    child: Padding(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const CircleAvatar(
                backgroundColor: AppColors.sage200,
                child: Icon(
                  Icons.wb_twilight_rounded,
                  color: AppColors.sage800,
                  size: 19,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'Tageszeit der Ökosysteme',
                      style: TextStyle(fontWeight: FontWeight.w700),
                    ),
                    Text(
                      DayClock.pinned == null
                          ? 'Folgt der Uhr: jetzt ${DayClock.phase.value.label}'
                          : 'Fest eingestellt: ${DayClock.pinned!.label}',
                      style: Theme.of(context).textTheme.bodySmall,
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: [
              ChoiceChip(
                key: const ValueKey('daytime-auto'),
                label: const Text('Automatisch'),
                selected: DayClock.pinned == null,
                onSelected: (_) => _choose(null),
              ),
              for (final phase in DayPhase.values)
                ChoiceChip(
                  key: ValueKey('daytime-${phase.name}'),
                  label: Text(phase.label),
                  selected: DayClock.pinned == phase,
                  onSelected: (_) => _choose(phase),
                ),
            ],
          ),
        ],
      ),
    ),
  );
}

final class _ProfileTile extends StatelessWidget {
  const _ProfileTile({
    required this.icon,
    required this.title,
    required this.value,
  });

  final IconData icon;
  final String title;
  final String value;

  @override
  Widget build(BuildContext context) => ListTile(
    leading: CircleAvatar(
      backgroundColor: AppColors.sage200,
      child: Icon(icon, color: AppColors.sage800, size: 19),
    ),
    title: Text(title, style: const TextStyle(fontWeight: FontWeight.w700)),
    subtitle: Text(value),
    trailing: const Icon(Icons.chevron_right),
  );
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
    backgroundColor: AppColors.bg,
    body: SafeArea(
      // Scrollable so short phones and landscape never overflow.
      child: Center(
        child: SingleChildScrollView(
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 390),
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 28, vertical: 16),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  Align(
                    child: ConstrainedBox(
                      constraints: const BoxConstraints(maxWidth: 260),
                      child: const EcosystemVitrine(
                        world: EcosystemWorld.forest,
                        title: 'Plantini',
                        aspectRatio: 1.25,
                        animate: true,
                      ),
                    ),
                  ),
                  const SizedBox(height: 24),
                  Text(
                    'Plantini',
                    textAlign: TextAlign.center,
                    style: Theme.of(context).textTheme.displayMedium,
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'Deine spielbare Forschungsreise durch die Pflanzenwelt.',
                    textAlign: TextAlign.center,
                    style: Theme.of(context).textTheme.bodyLarge
                        ?.copyWith(color: AppColors.neutral700),
                  ),
                  if (auth.failure != null) ...[
                    const SizedBox(height: 20),
                    Text(auth.failure!.message, textAlign: TextAlign.center),
                  ],
                  const SizedBox(height: 34),
                  FilledButton.icon(
                    key: const ValueKey('auth-login'),
                    onPressed: auth.login,
                    icon: const Icon(Icons.login),
                    label: const Text('Anmelden'),
                  ),
                  const SizedBox(height: 14),
                  const Text(
                    'Deine Fotos und Fundorte sind nur für dich sichtbar.',
                    textAlign: TextAlign.center,
                    style: TextStyle(color: AppColors.neutral700, fontSize: 11),
                  ),
                ],
              ),
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
