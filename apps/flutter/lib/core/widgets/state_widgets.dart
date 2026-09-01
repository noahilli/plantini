import 'package:flutter/material.dart';

import '../theme/app_colors.dart';
import '../theme/app_typography.dart';

/// Loading state widget displaying a centered progress indicator and optional message.
class LoadingState extends StatelessWidget {
  const LoadingState({super.key, this.message});

  final String? message;

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24.0),
        child: Semantics(
          label: message ?? 'Inhalt wird geladen',
          liveRegion: true,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const CircularProgressIndicator(
                valueColor: AlwaysStoppedAnimation<Color>(AppColors.forest),
              ),
              if (message != null) ...[
                const SizedBox(height: 16),
                Text(
                  message!,
                  textAlign: TextAlign.center,
                  style: AppTypography.textTheme.bodyMedium?.copyWith(
                    color: AppColors.muted,
                  ),
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }
}

/// Empty state widget displaying an icon, title, and optional subtitle.
class EmptyState extends StatelessWidget {
  const EmptyState({super.key, required this.title, this.subtitle, this.icon});

  final String title;
  final String? subtitle;
  final IconData? icon;

  @override
  Widget build(BuildContext context) {
    return Center(
      child: ConstrainedBox(
        constraints: const BoxConstraints(maxWidth: 440),
        child: Padding(
          padding: const EdgeInsets.all(24.0),
          child: Semantics(
            container: true,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(
                  icon ?? Icons.eco_outlined,
                  size: 48,
                  color: AppColors.sage,
                ),
                const SizedBox(height: 16),
                Text(
                  title,
                  textAlign: TextAlign.center,
                  style: AppTypography.textTheme.titleLarge?.copyWith(
                    color: AppColors.forest,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                if (subtitle != null) ...[
                  const SizedBox(height: 8),
                  Text(
                    subtitle!,
                    textAlign: TextAlign.center,
                    style: AppTypography.textTheme.bodyMedium?.copyWith(
                      color: AppColors.muted,
                    ),
                  ),
                ],
              ],
            ),
          ),
        ),
      ),
    );
  }
}

/// Offline state widget displaying an offline icon, notice, and optional retry action.
class OfflineState extends StatelessWidget {
  const OfflineState({super.key, this.onRetry});

  final VoidCallback? onRetry;

  @override
  Widget build(BuildContext context) {
    return Center(
      child: ConstrainedBox(
        constraints: const BoxConstraints(maxWidth: 440),
        child: Padding(
          padding: const EdgeInsets.all(24.0),
          child: Semantics(
            container: true,
            liveRegion: true,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                const Icon(
                  Icons.cloud_off_outlined,
                  size: 48,
                  color: AppColors.muted,
                ),
                const SizedBox(height: 16),
                Text(
                  'Keine Internetverbindung',
                  textAlign: TextAlign.center,
                  style: AppTypography.textTheme.titleLarge?.copyWith(
                    color: AppColors.ink,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  'Bitte überprüfe deine Netzwerkverbindung oder greife auf bereits heruntergeladene Offline-Inhalte zu.',
                  textAlign: TextAlign.center,
                  style: AppTypography.textTheme.bodyMedium?.copyWith(
                    color: AppColors.muted,
                  ),
                ),
                if (onRetry != null) ...[
                  const SizedBox(height: 20),
                  ElevatedButton.icon(
                    onPressed: onRetry,
                    icon: const Icon(Icons.refresh),
                    label: const Text('Erneut versuchen'),
                  ),
                ],
              ],
            ),
          ),
        ),
      ),
    );
  }
}

/// Error state widget displaying an error message, optional retry, and fatal indicator.
class ErrorState extends StatelessWidget {
  const ErrorState({
    super.key,
    required this.message,
    this.onRetry,
    this.isFatal = false,
  });

  final String message;
  final VoidCallback? onRetry;
  final bool isFatal;

  @override
  Widget build(BuildContext context) {
    return Center(
      child: ConstrainedBox(
        constraints: const BoxConstraints(maxWidth: 440),
        child: Padding(
          padding: const EdgeInsets.all(24.0),
          child: Semantics(
            container: true,
            liveRegion: true,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(
                  isFatal
                      ? Icons.warning_amber_rounded
                      : Icons.error_outline_rounded,
                  size: 48,
                  color: isFatal ? AppColors.danger : AppColors.bark,
                ),
                const SizedBox(height: 16),
                Text(
                  isFatal
                      ? 'Schwerwiegender Fehler'
                      : 'Ein Fehler ist aufgetreten',
                  textAlign: TextAlign.center,
                  style: AppTypography.textTheme.titleLarge?.copyWith(
                    color: isFatal ? AppColors.danger : AppColors.ink,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  message,
                  textAlign: TextAlign.center,
                  style: AppTypography.textTheme.bodyMedium?.copyWith(
                    color: AppColors.muted,
                  ),
                ),
                if (onRetry != null) ...[
                  const SizedBox(height: 20),
                  ElevatedButton.icon(
                    onPressed: onRetry,
                    icon: const Icon(Icons.refresh),
                    label: const Text('Erneut versuchen'),
                  ),
                ],
              ],
            ),
          ),
        ),
      ),
    );
  }
}

/// Permission denied state widget explaining the missing permission.
class PermissionDeniedState extends StatelessWidget {
  const PermissionDeniedState({super.key, required this.reason});

  final String reason;

  @override
  Widget build(BuildContext context) {
    return Center(
      child: ConstrainedBox(
        constraints: const BoxConstraints(maxWidth: 440),
        child: Padding(
          padding: const EdgeInsets.all(24.0),
          child: Semantics(
            container: true,
            liveRegion: true,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                const Icon(
                  Icons.lock_outline_rounded,
                  size: 48,
                  color: AppColors.bark,
                ),
                const SizedBox(height: 16),
                Text(
                  'Berechtigung erforderlich',
                  textAlign: TextAlign.center,
                  style: AppTypography.textTheme.titleLarge?.copyWith(
                    color: AppColors.ink,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  reason,
                  textAlign: TextAlign.center,
                  style: AppTypography.textTheme.bodyMedium?.copyWith(
                    color: AppColors.muted,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
