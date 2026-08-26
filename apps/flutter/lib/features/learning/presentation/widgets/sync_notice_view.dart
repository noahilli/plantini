import 'package:flutter/material.dart';

import '../../../../core/errors/app_failure.dart';

/// Card showing pending offline synchronization status or retry notices.
final class SyncNoticeView extends StatelessWidget {
  const SyncNoticeView({super.key, required this.failure});

  final AppFailure failure;

  @override
  Widget build(BuildContext context) => Semantics(
    label: 'Synchronisierung ausstehend',
    liveRegion: true,
    child: Card(
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: Text(
          failure.isRetryable
              ? 'Deine Antwort ist lokal gesichert und wird bei der nächsten Verbindung synchronisiert.'
              : failure.message,
        ),
      ),
    ),
  );
}
