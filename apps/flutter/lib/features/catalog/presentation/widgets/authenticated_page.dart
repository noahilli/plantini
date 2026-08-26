import 'package:flutter/material.dart';

import '../../../../app/app_dependencies.dart';

/// Common shell for authenticated catalog and feature pages.
final class AuthenticatedPage extends StatelessWidget {
  const AuthenticatedPage({
    super.key,
    required this.dependencies,
    required this.title,
    required this.body,
  });

  final AppDependencies dependencies;
  final String title;
  final Widget body;

  @override
  Widget build(BuildContext context) => Scaffold(
    appBar: AppBar(
      title: Text(title),
      actions: [
        IconButton(
          key: const ValueKey('auth-logout'),
          tooltip: 'Abmelden',
          onPressed: dependencies.auth.logout,
          icon: const Icon(Icons.logout),
        ),
      ],
    ),
    body: body,
  );
}
