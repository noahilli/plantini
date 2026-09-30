import 'package:flutter/material.dart';

import '../../../core/errors/app_failure.dart';
import '../../../core/theme/app_colors.dart';
import '../domain/field_models.dart';

/// Where in the photo → result → save flow something went wrong.
enum FieldStep { reserve, upload, submit, poll, confirm, save }

/// A failure worded for a pupil: what happened, and what to do next.
final class FieldProblem {
  const FieldProblem({
    required this.title,
    required this.message,
    this.hint,
    this.icon = Icons.error_outline_rounded,
    this.retryable = false,
    this.needsLogin = false,
  });

  final String title;
  final String message;
  final String? hint;
  final IconData icon;

  /// Trying the same step again can succeed (network, timeout, busy service).
  final bool retryable;
  final bool needsLogin;

  String get plainText => hint == null ? message : '$message $hint';

  factory FieldProblem.fromFailure(AppFailure failure, FieldStep step) {
    final action = switch (step) {
      FieldStep.reserve || FieldStep.upload || FieldStep.submit =>
        'Dein Foto konnte nicht zur Bestimmung geschickt werden.',
      FieldStep.poll => 'Das Ergebnis konnte nicht abgeholt werden.',
      FieldStep.confirm ||
      FieldStep.save => 'Dein Fund konnte nicht gespeichert werden.',
    };
    return switch (failure) {
      NetworkFailure() => FieldProblem(
        title: 'Keine Verbindung',
        message: action,
        hint: 'Prüfe dein WLAN oder deine mobilen Daten und versuche es gleich noch einmal.',
        icon: Icons.wifi_off_rounded,
        retryable: true,
      ),
      TimeoutFailure() => FieldProblem(
        title: 'Das dauert zu lange',
        message: '$action Die Verbindung ist sehr langsam.',
        hint: 'Versuche es mit besserem Empfang noch einmal.',
        icon: Icons.hourglass_bottom_rounded,
        retryable: true,
      ),
      RateLimitedFailure(:final retryAfter) => FieldProblem(
        title: 'Gerade zu viel los',
        message: 'Du hast in kurzer Zeit viele Bilder geschickt.',
        hint: retryAfter == null
            ? 'Warte einen Moment und versuche es dann erneut.'
            : 'Versuche es in etwa ${_wait(retryAfter)} erneut.',
        icon: Icons.timer_outlined,
        retryable: true,
      ),
      UnauthorizedFailure() => const FieldProblem(
        title: 'Bitte neu anmelden',
        message: 'Deine Sitzung ist abgelaufen.',
        hint: 'Melde dich erneut an. Dein Foto geht dabei nicht verloren.',
        icon: Icons.lock_outline_rounded,
        needsLogin: true,
      ),
      PermissionFailure() => FieldProblem(
        title: 'Nicht erlaubt',
        message: action,
        hint: 'Dein Konto darf diese Aktion nicht ausführen.',
        icon: Icons.block_rounded,
      ),
      ValidationFailure(:final message) => FieldProblem(
        title: 'Das Foto passt nicht',
        message: message,
        hint: 'Mach ein neues Foto: scharf, gut beleuchtet, Pflanze im Bild.',
        icon: Icons.image_not_supported_outlined,
      ),
      ConflictFailure() => FieldProblem(
        title: 'Schon erledigt',
        message: 'Dieser Vorgang wurde bereits abgeschickt.',
        hint: 'Öffne dein Herbarium, dort findest du den Fund.',
        icon: Icons.check_circle_outline_rounded,
      ),
      ServerFailure(:final traceId) => FieldProblem(
        title: 'Unser Server hakt',
        message: action,
        hint: traceId == null
            ? 'Das liegt nicht an dir. Versuche es später noch einmal.'
            : 'Das liegt nicht an dir. Versuche es später noch einmal. Fehlernummer: $traceId',
        icon: Icons.cloud_off_rounded,
        retryable: true,
      ),
      _ => FieldProblem(
        title: 'Etwas ist schiefgegangen',
        message: failure.message,
        icon: Icons.error_outline_rounded,
        retryable: failure.isRetryable,
      ),
    };
  }

  /// The provider's failure code of a finished job, translated.
  factory FieldProblem.fromJob(IdentificationJob job) {
    switch (job.failureCode) {
      case 'PROVIDER_RATE_LIMITED' || 'PROVIDER_QUOTA_RESERVED':
        return const FieldProblem(
          title: 'Die Bestimmung ist ausgelastet',
          message: 'Heute wurden sehr viele Pflanzen bestimmt.',
          hint: 'Versuche es später noch einmal. Dein Foto bleibt gespeichert.',
          icon: Icons.timer_outlined,
          retryable: true,
        );
      case 'PROVIDER_TIMEOUT' ||
          'PROVIDER_UNAVAILABLE' ||
          'PROVIDER_CIRCUIT_OPEN' ||
          'PROVIDER_RETRY_EXHAUSTED':
        return const FieldProblem(
          title: 'Bestimmung nicht erreichbar',
          message: 'Der Dienst, der Pflanzen erkennt, antwortet gerade nicht.',
          hint:
              'Das liegt nicht an deinem Foto. Versuche es später noch einmal.',
          icon: Icons.cloud_off_rounded,
          retryable: true,
        );
      case 'PROVIDER_REJECTED':
        return const FieldProblem(
          title: 'Foto nicht erkannt',
          message: 'Auf dem Foto konnte keine Pflanze erkannt werden.',
          hint: 'Fotografiere Blüte oder Blatt aus der Nähe, scharf und bei gutem Licht.',
          icon: Icons.image_search_rounded,
        );
      case 'PROVIDER_CREDENTIALS_INVALID':
        return const FieldProblem(
          title: 'Bestimmung ist gerade abgeschaltet',
          message: 'Bei uns stimmt etwas mit der Einrichtung nicht.',
          hint: 'Das liegt nicht an dir. Wir kümmern uns darum.',
          icon: Icons.build_circle_outlined,
        );
      case 'MEDIA_UPLOAD_EXPIRED' ||
          'MEDIA_UNAVAILABLE' ||
          'MEDIA_UPLOAD_NOT_FOUND':
        return const FieldProblem(
          title: 'Foto nicht mehr da',
          message: 'Das hochgeladene Foto ist nicht mehr verfügbar.',
          hint: 'Mach das Foto bitte noch einmal.',
          icon: Icons.image_not_supported_outlined,
        );
      case 'PROVIDER_INVALID_RESPONSE':
        return const FieldProblem(
          title: 'Unklare Antwort',
          message: 'Die Bestimmung hat keine brauchbare Antwort geliefert.',
          hint: 'Versuche es noch einmal.',
          retryable: true,
        );
    }
    return const FieldProblem(
      title: 'Bestimmung fehlgeschlagen',
      message: 'Dein Foto konnte nicht bestimmt werden.',
      hint: 'Versuche es noch einmal.',
      retryable: true,
    );
  }

  static String _wait(Duration duration) {
    if (duration.inSeconds < 90) {
      return '${duration.inSeconds.clamp(5, 90)} Sekunden';
    }
    return '${(duration.inSeconds / 60).ceil()} Minuten';
  }
}

/// The pop-up shown for every failed step. Returns true if the user chose to
/// try again.
Future<bool> showFieldProblemDialog(
  BuildContext context,
  FieldProblem problem, {
  bool offerRetry = true,
}) async {
  final retry = await showDialog<bool>(
    context: context,
    builder: (context) => AlertDialog(
      key: const ValueKey('field-problem-dialog'),
      backgroundColor: AppColors.neutral100,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(28)),
      icon: Container(
        width: 56,
        height: 56,
        decoration: const BoxDecoration(
          color: AppColors.accent200,
          shape: BoxShape.circle,
        ),
        child: Icon(problem.icon, color: AppColors.accent700, size: 30),
      ),
      title: Text(problem.title, textAlign: TextAlign.center),
      content: SingleChildScrollView(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(problem.message, textAlign: TextAlign.center),
            if (problem.hint != null) ...[
              const SizedBox(height: 10),
              Text(
                problem.hint!,
                textAlign: TextAlign.center,
                style: const TextStyle(color: AppColors.neutral700),
              ),
            ],
          ],
        ),
      ),
      actionsAlignment: MainAxisAlignment.center,
      actionsOverflowAlignment: OverflowBarAlignment.center,
      actions: [
        TextButton(
          onPressed: () => Navigator.of(context).pop(false),
          child: const Text('Schließen'),
        ),
        if (offerRetry && problem.retryable)
          FilledButton.icon(
            onPressed: () => Navigator.of(context).pop(true),
            icon: const Icon(Icons.replay_rounded),
            label: const Text('Erneut versuchen'),
          ),
      ],
    ),
  );
  return retry ?? false;
}
