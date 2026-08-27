import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../../../app/app_dependencies.dart';
import '../../../../core/theme/app_colors.dart';

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
      leading: context.canPop()
          ? Padding(
              padding: const EdgeInsets.all(8),
              child: IconButton.filled(
                style: IconButton.styleFrom(
                  backgroundColor: AppColors.bg,
                  foregroundColor: AppColors.ink,
                ),
                onPressed: context.pop,
                icon: const Icon(Icons.arrow_back, size: 18),
              ),
            )
          : null,
      title: Text(title),
    ),
    body: body,
  );
}
