import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../auth/auth_service.dart';
import '../core/theme/app_theme.dart';
import '../features/catalog/presentation/widgets/world_lighting.dart';
import 'app_dependencies.dart';
import 'router.dart';

final class PlantiniApp extends StatefulWidget {
  const PlantiniApp({super.key, required this.dependencies});

  final AppDependencies dependencies;

  @override
  State<PlantiniApp> createState() => _PlantiniAppState();
}

final class _PlantiniAppState extends State<PlantiniApp>
    with WidgetsBindingObserver {
  late final GoRouter _router = createAppRouter(widget.dependencies);
  bool _hasSynced = false;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    widget.dependencies.auth.addListener(_checkAuthAndSync);
    _checkAuthAndSync();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    // The ecosystems follow the time of day; pick it up after a pause.
    if (state == AppLifecycleState.resumed) {
      DayClock.refresh();
      if (widget.dependencies.auth.isAuthenticated) {
        widget.dependencies.character?.sync();
      }
    }
  }

  void _checkAuthAndSync() {
    final character = widget.dependencies.character;
    if (widget.dependencies.auth.isAuthenticated) {
      character?.sync();
      if (!_hasSynced) {
        _hasSynced = true;
        widget.dependencies.contentSync.syncRelease();
      }
    } else if (widget.dependencies.auth.state == AuthState.unauthenticated) {
      // Another person may sign in on this device next.
      character?.reset();
      _hasSynced = false;
    }
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    widget.dependencies.auth.removeListener(_checkAuthAndSync);
    _router.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) => MaterialApp.router(
    title: 'Plantini',
    theme: AppTheme.lightTheme,
    darkTheme: AppTheme.darkTheme,
    themeMode: ThemeMode.light,
    routerConfig: _router,
  );
}
