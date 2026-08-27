import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../core/theme/app_theme.dart';
import 'app_dependencies.dart';
import 'router.dart';

final class PlantiniApp extends StatefulWidget {
  const PlantiniApp({super.key, required this.dependencies});

  final AppDependencies dependencies;

  @override
  State<PlantiniApp> createState() => _PlantiniAppState();
}

final class _PlantiniAppState extends State<PlantiniApp> {
  late final GoRouter _router = createAppRouter(widget.dependencies);

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
    themeMode: ThemeMode.light,
    routerConfig: _router,
  );
}
