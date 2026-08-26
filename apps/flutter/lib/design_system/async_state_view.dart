import 'package:flutter/material.dart';

import '../core/errors/app_failure.dart';

enum AsyncViewKind {
  loading,
  empty,
  offline,
  stale,
  permissionDenied,
  recoverableError,
  fatalError,
}

/// Consistent and semantic state UI for every feature.
class AsyncStateView extends StatelessWidget {
  const AsyncStateView({
    super.key,
    required this.kind,
    this.title,
    this.message,
    this.failure,
    this.onRetry,
  });

  final AsyncViewKind kind;
  final String? title;
  final String? message;
  final AppFailure? failure;
  final VoidCallback? onRetry;

  @override
  Widget build(BuildContext context) {
    if (kind == AsyncViewKind.loading) {
      return Center(
        child: Semantics(
          label: 'Inhalt wird geladen',
          liveRegion: true,
          child: CircularProgressIndicator(),
        ),
      );
    }

    final spec = _specFor(kind);
    final colorScheme = Theme.of(context).colorScheme;
    return Center(
      child: ConstrainedBox(
        constraints: const BoxConstraints(maxWidth: 440),
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Semantics(
            container: true,
            liveRegion: true,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(spec.icon, size: 40, color: colorScheme.primary),
                const SizedBox(height: 16),
                Text(
                  title ?? spec.title,
                  textAlign: TextAlign.center,
                  style: Theme.of(context).textTheme.titleLarge,
                ),
                const SizedBox(height: 8),
                Text(
                  message ?? failure?.message ?? spec.message,
                  textAlign: TextAlign.center,
                  style: Theme.of(context).textTheme.bodyMedium,
                ),
                if (onRetry != null) ...[
                  const SizedBox(height: 20),
                  FilledButton.icon(
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

  _StateSpec _specFor(AsyncViewKind value) => switch (value) {
    AsyncViewKind.loading => throw StateError('Loading has a dedicated UI.'),
    AsyncViewKind.empty => const _StateSpec(
      Icons.eco_outlined,
      'Noch keine Inhalte',
      'Für diesen Bereich wurden noch keine veröffentlichten Inhalte gefunden.',
    ),
    AsyncViewKind.offline => const _StateSpec(
      Icons.cloud_off_outlined,
      'Offline',
      'Für diese Ansicht liegt noch keine lokale Version vor.',
    ),
    AsyncViewKind.stale => const _StateSpec(
      Icons.history_outlined,
      'Lokaler Stand',
      'Die angezeigten Daten stammen aus einer älteren lokalen Version.',
    ),
    AsyncViewKind.permissionDenied => const _StateSpec(
      Icons.lock_outline,
      'Berechtigung erforderlich',
      'Du kannst fortfahren, ohne diese Berechtigung zu erteilen.',
    ),
    AsyncViewKind.recoverableError => const _StateSpec(
      Icons.error_outline,
      'Das hat nicht geklappt',
      'Bitte überprüfe die Verbindung und versuche es erneut.',
    ),
    AsyncViewKind.fatalError => const _StateSpec(
      Icons.warning_amber_outlined,
      'Plantini konnte nicht gestartet werden',
      'Die Konfiguration oder lokale Speicherung muss geprüft werden.',
    ),
  };
}

class _StateSpec {
  const _StateSpec(this.icon, this.title, this.message);

  final IconData icon;
  final String title;
  final String message;
}
