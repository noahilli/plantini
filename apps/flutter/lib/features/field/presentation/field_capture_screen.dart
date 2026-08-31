import 'dart:async';

import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../../app/app_dependencies.dart';
import '../../../core/ids/client_id_generator.dart';
import '../../../core/result.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_typography.dart';
import '../../herbarium/domain/herbarium_repository.dart';
import '../domain/field_models.dart';
import '../domain/field_repository.dart';
import '../infrastructure/location_service.dart';
import '../infrastructure/media_service.dart';

/// The online first-cut field workflow: select a privacy-sanitized image,
/// upload it through a reservation, wait for an identification, then explicitly
/// confirm a candidate before creating a private observation.
class FieldCaptureScreen extends StatefulWidget {
  const FieldCaptureScreen({
    super.key,
    this.dependencies,
    this.fieldRepository,
    this.herbariumRepository,
    this.mediaService,
    this.locationService,
    this.ids,
  });

  final AppDependencies? dependencies;
  final FieldRepository? fieldRepository;
  final HerbariumRepository? herbariumRepository;
  final MediaService? mediaService;
  final LocationService? locationService;
  final ClientIdGenerator? ids;

  @override
  State<FieldCaptureScreen> createState() => _FieldCaptureScreenState();
}

class _FieldCaptureScreenState extends State<FieldCaptureScreen> {
  FieldRepository? _fieldRepository;
  HerbariumRepository? _herbariumRepository;
  late final MediaService _mediaService;
  late final LocationService _locationService;
  late final ClientIdGenerator _ids;

  ProcessedMedia? _media;
  IdentificationJob? _job;
  String? _selectedCandidateId;
  String? _workflowError;
  LocationState _locationState = LocationState.unknown;
  bool _includeLocation = false;
  bool _isWorking = false;
  Timer? _identificationPollTimer;
  String? _observationClientId;
  String? _observationIdempotencyKey;

  @override
  void initState() {
    super.initState();
    _fieldRepository =
        widget.fieldRepository ?? widget.dependencies?.fieldRepository;
    _herbariumRepository =
        widget.herbariumRepository ?? widget.dependencies?.herbariumRepository;
    _mediaService = widget.mediaService ?? MediaService();
    _locationService = widget.locationService ?? LocationService();
    _ids = widget.ids ?? SecureClientIdGenerator();
  }

  @override
  void dispose() {
    _identificationPollTimer?.cancel();
    super.dispose();
  }

  bool get _isConfigured =>
      _fieldRepository != null && _herbariumRepository != null;

  Future<void> _pickImage({required bool camera}) async {
    if (_isWorking) return;
    setState(() {
      _isWorking = true;
      _workflowError = null;
    });
    final result = camera
        ? await _mediaService.captureFromCamera(keepLocation: false)
        : await _mediaService.pickFromGallery(keepLocation: false);
    if (!mounted) return;
    switch (result) {
      case Success<ProcessedMedia>(:final value):
        setState(() {
          _media = value;
          _job = null;
          _selectedCandidateId = null;
          _workflowError = null;
          _isWorking = false;
          _observationClientId = null;
          _observationIdempotencyKey = null;
        });
      case Failure<ProcessedMedia>(:final failure):
        _setFailure(failure.message);
    }
  }

  Future<void> _startIdentification() async {
    final media = _media;
    final repository = _fieldRepository;
    if (media == null || repository == null || _isWorking) return;
    setState(() {
      _isWorking = true;
      _workflowError = null;
    });

    final mediaClientId = _ids.next();
    final reservation = await repository.reserveMediaUpload(
      clientMediaId: mediaClientId,
      contentType: media.mimeType,
      bytes: media.sizeBytes,
      idempotencyKey: mediaClientId,
    );
    if (reservation case Failure<MediaUpload>(:final failure)) {
      _setFailure(failure.message);
      return;
    }
    final upload = await repository.uploadMediaContent(
      mediaId: (reservation as Success<MediaUpload>).value.id,
      bytes: media.bytes,
      contentType: media.mimeType,
      filename: media.filename,
    );
    if (upload case Failure<MediaUpload>(:final failure)) {
      _setFailure(failure.message);
      return;
    }
    final jobClientId = _ids.next();
    final job = await repository.submitObservation(
      clientJobId: jobClientId,
      mediaId: (upload as Success<MediaUpload>).value.id,
      idempotencyKey: jobClientId,
    );
    if (!mounted) return;
    switch (job) {
      case Success<IdentificationJob>(:final value):
        setState(() {
          _job = value;
          _selectedCandidateId = _selectionFrom(value);
          _isWorking = false;
        });
        _scheduleIdentificationPoll(value);
      case Failure<IdentificationJob>(:final failure):
        _setFailure(failure.message);
    }
  }

  Future<void> _refreshIdentification() async {
    final repository = _fieldRepository;
    final job = _job;
    if (repository == null || job == null || _isWorking) return;
    setState(() {
      _isWorking = true;
      _workflowError = null;
    });
    final result = await repository.getIdentification(job.id);
    if (!mounted) return;
    switch (result) {
      case Success<IdentificationJob>(:final value):
        setState(() {
          _job = value;
          _selectedCandidateId = _selectionFrom(value);
          _isWorking = false;
        });
        _scheduleIdentificationPoll(value);
      case Failure<IdentificationJob>(:final failure):
        _setFailure(failure.message);
    }
  }

  void _scheduleIdentificationPoll(IdentificationJob job) {
    _identificationPollTimer?.cancel();
    if (!mounted || (job.status != 'pending' && job.status != 'processing')) {
      return;
    }
    final now = DateTime.now();
    final retryAfter = job.retryAfter;
    final delay = retryAfter != null && retryAfter.isAfter(now)
        ? retryAfter.difference(now)
        : const Duration(seconds: 1);
    _identificationPollTimer = Timer(
      delay > const Duration(seconds: 10) ? const Duration(seconds: 10) : delay,
      _refreshIdentification,
    );
  }

  Future<void> _saveObservation() async {
    final fieldRepository = _fieldRepository;
    final herbariumRepository = _herbariumRepository;
    final job = _job;
    final candidateId = _selectedCandidateId;
    if (fieldRepository == null ||
        herbariumRepository == null ||
        job == null ||
        candidateId == null ||
        _isWorking) {
      return;
    }
    setState(() {
      _isWorking = true;
      _workflowError = null;
    });

    final confirmed = await fieldRepository.confirmIdentification(
      jobId: job.id,
      candidateId: candidateId,
    );
    if (confirmed case Failure<IdentificationJob>(:final failure)) {
      _setFailure(failure.message);
      return;
    }

    final location = await _locationForSubmission();
    if (!mounted) return;
    final clientId = _observationClientId ??= _ids.next();
    final idempotencyKey = _observationIdempotencyKey ??= _ids.next();
    final created = await herbariumRepository.createEntry(
      clientObservationId: clientId,
      observedAt: DateTime.now(),
      identificationJobId: job.id,
      latitude: location?.latitude,
      longitude: location?.longitude,
      accuracyMeters: location?.accuracy,
      idempotencyKey: idempotencyKey,
    );
    if (!mounted) return;
    if (created.isSuccess) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Fund wurde im privaten Herbarium gespeichert.'),
        ),
      );
      context.go('/herbarium');
      return;
    }
    _setFailure(created.failureOrNull!.message);
  }

  Future<LocationCoordinates?> _locationForSubmission() async {
    if (!_includeLocation) return null;
    final state = await _locationService.requestLocation();
    if (!mounted) return null;
    setState(() => _locationState = state);
    if (state != LocationState.granted) return null;
    final result = await _locationService.getCurrentLocation();
    return result.valueOrNull;
  }

  void _setFailure(String message) {
    if (!mounted) return;
    setState(() {
      _isWorking = false;
      _workflowError = message;
    });
  }

  @override
  Widget build(BuildContext context) {
    if (!_isConfigured) {
      return const Scaffold(
        body: Center(
          child: Padding(
            padding: EdgeInsets.all(24),
            child: Text(
              'Der Feldablauf ist nicht konfiguriert. Bitte starte Plantini mit einer gültigen API-Konfiguration.',
              textAlign: TextAlign.center,
            ),
          ),
        ),
      );
    }

    final media = _media;
    final job = _job;
    final canStartIdentification = media != null && job == null && !_isWorking;
    final canSave =
        job?.status == 'identified' &&
        _selectedCandidateId != null &&
        !_isWorking;

    // State 1n: Identification in progress
    if ((_isWorking && job == null && media != null) ||
        job?.status == 'processing' ||
        job?.status == 'pending') {
      return Scaffold(
        backgroundColor: AppColors.neutral100,
        body: SafeArea(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Padding(
                padding: const EdgeInsets.fromLTRB(22, 10, 22, 14),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Container(
                      width: 32,
                      height: 32,
                      decoration: const BoxDecoration(
                        color: AppColors.bg,
                        shape: BoxShape.circle,
                      ),
                      child: const Icon(Icons.arrow_back, size: 15),
                    ),
                    Text(
                      'Nachweis',
                      style: AppTypography.textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.w400,
                      ),
                    ),
                    const SizedBox(width: 32),
                  ],
                ),
              ),
              Expanded(
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 22),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Container(
                        width: 150,
                        height: 150,
                        decoration: const BoxDecoration(
                          color: AppColors.sage200,
                          shape: BoxShape.circle,
                        ),
                        child: Center(
                          child: Container(
                            width: 106,
                            height: 106,
                            decoration: const BoxDecoration(
                              color: AppColors.sage300,
                              shape: BoxShape.circle,
                            ),
                            child: Center(
                              child: Container(
                                width: 62,
                                height: 62,
                                decoration: const BoxDecoration(
                                  color: AppColors.sage600,
                                  shape: BoxShape.circle,
                                ),
                              ),
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(height: 24),
                      Text(
                        'Abgleich läuft',
                        style: AppTypography.textTheme.headlineMedium?.copyWith(
                          fontSize: 25,
                        ),
                      ),
                      const SizedBox(height: 6),
                      Text(
                        'Dein Bild wird mit PlantNet verglichen. Bitte bleib auf dieser Seite, bis das Ergebnis vorliegt.',
                        textAlign: TextAlign.center,
                        style: AppTypography.textTheme.bodyMedium?.copyWith(
                          color: AppColors.neutral700,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      );
    }

    // State 1o: Identification complete
    if (job?.status == 'identified' || job?.status == 'failed') {
      return Scaffold(
        backgroundColor: AppColors.neutral100,
        body: SafeArea(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Padding(
                padding: const EdgeInsets.fromLTRB(22, 10, 22, 12),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    InkWell(
                      onTap: () => Navigator.of(context).pop(),
                      borderRadius: BorderRadius.circular(999),
                      child: Container(
                        width: 32,
                        height: 32,
                        decoration: const BoxDecoration(
                          color: AppColors.bg,
                          shape: BoxShape.circle,
                        ),
                        child: const Icon(Icons.arrow_back, size: 15),
                      ),
                    ),
                    Text(
                      'Ergebnis',
                      style: AppTypography.textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.w400,
                      ),
                    ),
                    const SizedBox(width: 32),
                  ],
                ),
              ),
              Expanded(
                child: ListView(
                  padding: const EdgeInsets.fromLTRB(22, 0, 22, 22),
                  children: [
                    if (_workflowError != null)
                      _ErrorCard(message: _workflowError!),
                    _IdentificationCard(
                      job: job!,
                      selectedCandidateId: _selectedCandidateId,
                      onCandidateSelected: _isWorking
                          ? null
                          : (candidateId) => setState(
                              () => _selectedCandidateId = candidateId,
                            ),
                      onRefresh: _isWorking ? null : _refreshIdentification,
                    ),
                    const SizedBox(height: 16),
                    SwitchListTile.adaptive(
                      key: const ValueKey('field-location-consent'),
                      value: _includeLocation,
                      onChanged: _isWorking
                          ? null
                          : (value) => setState(() => _includeLocation = value),
                      title: Text(
                        'Fundort privat speichern',
                        style: AppTypography.textTheme.titleMedium?.copyWith(
                          fontSize: 12.5,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      subtitle: Text(
                        _locationDescription(),
                        style: AppTypography.textTheme.bodySmall?.copyWith(
                          fontSize: 10.5,
                          color: AppColors.neutral700,
                        ),
                      ),
                      contentPadding: const EdgeInsets.symmetric(
                        horizontal: 16,
                        vertical: 8,
                      ),
                      tileColor: AppColors.bg,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(24),
                      ),
                    ),
                    const SizedBox(height: 24),
                    FilledButton(
                      key: const ValueKey('field-save-observation'),
                      onPressed: canSave ? _saveObservation : null,
                      style: FilledButton.styleFrom(
                        backgroundColor: AppColors.terracotta,
                        foregroundColor: AppColors.white,
                        padding: const EdgeInsets.symmetric(vertical: 14),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(999),
                        ),
                      ),
                      child: _isWorking
                          ? const SizedBox(
                              width: 20,
                              height: 20,
                              child: CircularProgressIndicator(
                                color: AppColors.white,
                                strokeWidth: 2,
                              ),
                            )
                          : const Text(
                              'Ergebnis speichern',
                              style: TextStyle(fontSize: 15),
                            ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      );
    }

    // State 1l: Initial Entry (or media selected but not started)
    return Scaffold(
      backgroundColor: AppColors.neutral100,
      body: SafeArea(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Padding(
              padding: const EdgeInsets.fromLTRB(22, 10, 22, 13),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    'NEUE BESTIMMUNG',
                    style: AppTypography.textTheme.labelSmall?.copyWith(
                      color: AppColors.sage700,
                      fontWeight: FontWeight.bold,
                      letterSpacing: 1.3,
                    ),
                  ),
                ],
              ),
            ),
            Expanded(
              child: ListView(
                padding: const EdgeInsets.symmetric(horizontal: 22),
                children: [
                  Text(
                    'Finde und bestimme\neine Pflanze',
                    style: AppTypography.textTheme.headlineMedium?.copyWith(
                      fontSize: 29,
                    ),
                  ),
                  const SizedBox(height: 16),

                  if (_workflowError != null) ...[
                    _ErrorCard(message: _workflowError!),
                    const SizedBox(height: 16),
                  ],

                  _PhotoCard(media: media),

                  if (media != null) ...[
                    const SizedBox(height: 12),
                    Text(
                      '${media.filename} · ${(media.sizeBytes / 1024).ceil()} KB',
                      key: const ValueKey('field-selected-media'),
                      style: AppTypography.textTheme.bodySmall?.copyWith(
                        color: AppColors.neutral700,
                      ),
                      textAlign: TextAlign.center,
                    ),
                  ],
                  const SizedBox(height: 20),

                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 15,
                      vertical: 13,
                    ),
                    decoration: BoxDecoration(
                      border: Border.all(
                        color: AppColors.neutral400,
                        style: BorderStyle.solid,
                      ),
                      borderRadius: BorderRadius.circular(24),
                    ),
                    child: Row(
                      children: [
                        Container(
                          width: 8,
                          height: 8,
                          decoration: const BoxDecoration(
                            color: AppColors.terracotta,
                            shape: BoxShape.circle,
                          ),
                        ),
                        const SizedBox(width: 10),
                        Expanded(
                          child: Text(
                            'Kein Netz? Fotos werden lokal gespeichert und beim nächsten WLAN abgeglichen.',
                            style: AppTypography.textTheme.bodySmall?.copyWith(
                              fontSize: 11.5,
                              color: AppColors.neutral700,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 24),
                ],
              ),
            ),
            Padding(
              padding: const EdgeInsets.fromLTRB(22, 0, 22, 22),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  if (media == null) ...[
                    FilledButton.icon(
                      key: const ValueKey('field-capture-camera'),
                      onPressed: _isWorking
                          ? null
                          : () => _pickImage(camera: true),
                      icon: const Icon(Icons.camera_alt_outlined),
                      label: const Text(
                        'Kamera öffnen',
                        style: TextStyle(fontSize: 15),
                      ),
                      style: FilledButton.styleFrom(
                        backgroundColor: AppColors.terracotta,
                        foregroundColor: AppColors.bg,
                        padding: const EdgeInsets.symmetric(vertical: 14),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(999),
                        ),
                      ),
                    ),
                    const SizedBox(height: 10),
                    OutlinedButton.icon(
                      key: const ValueKey('field-capture-gallery'),
                      onPressed: _isWorking
                          ? null
                          : () => _pickImage(camera: false),
                      icon: const Icon(Icons.photo_library_outlined),
                      label: const Text(
                        'Aus Galerie wählen',
                        style: TextStyle(fontSize: 15),
                      ),
                      style: OutlinedButton.styleFrom(
                        foregroundColor: AppColors.ink,
                        padding: const EdgeInsets.symmetric(vertical: 14),
                        side: const BorderSide(color: AppColors.neutral400),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(999),
                        ),
                      ),
                    ),
                  ] else ...[
                    FilledButton.icon(
                      key: const ValueKey('field-start-identification'),
                      onPressed: canStartIdentification
                          ? _startIdentification
                          : null,
                      icon: const Icon(Icons.auto_awesome),
                      label: const Text(
                        'Pflanze bestimmen',
                        style: TextStyle(fontSize: 15),
                      ),
                      style: FilledButton.styleFrom(
                        backgroundColor: AppColors.terracotta,
                        foregroundColor: AppColors.bg,
                        padding: const EdgeInsets.symmetric(vertical: 14),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(999),
                        ),
                      ),
                    ),
                    const SizedBox(height: 10),
                    OutlinedButton(
                      onPressed: _isWorking
                          ? null
                          : () {
                              setState(() {
                                _media = null;
                              });
                            },
                      style: OutlinedButton.styleFrom(
                        foregroundColor: AppColors.ink,
                        padding: const EdgeInsets.symmetric(vertical: 14),
                        side: const BorderSide(color: AppColors.neutral400),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(999),
                        ),
                      ),
                      child: const Text(
                        'Anderes Foto wählen',
                        style: TextStyle(fontSize: 15),
                      ),
                    ),
                  ],
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  String _locationDescription() {
    if (!_includeLocation) {
      return 'nur grobe Position · nie öffentlich · jederzeit löschbar';
    }
    return switch (_locationState) {
      LocationState.denied =>
        'Berechtigung verweigert. Wird ohne Standort gespeichert.',
      LocationState.disabled =>
        'Standortdienste deaktiviert. Wird ohne Standort gespeichert.',
      LocationState.restricted => 'Standort eingeschränkt.',
      _ => 'Wird mit Standort gespeichert. Sichtbarkeit bleibt privat.',
    };
  }

  String? _selectionFrom(IdentificationJob job) {
    if (job.confirmedCandidateId != null) return job.confirmedCandidateId;
    final confirmedPlantId = job.confirmedPlantId;
    if (confirmedPlantId == null) return null;
    for (final candidate in job.candidates) {
      if (candidate.plantId == confirmedPlantId) return candidate.candidateId;
    }
    return null;
  }
}

class _PhotoCard extends StatelessWidget {
  const _PhotoCard({required this.media});

  final ProcessedMedia? media;

  @override
  Widget build(BuildContext context) => Container(
    height: 220,
    alignment: Alignment.center,
    decoration: BoxDecoration(
      color: AppColors.sage200,
      borderRadius: BorderRadius.circular(26),
    ),
    child: media == null
        ? const Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(
                Icons.add_a_photo_outlined,
                size: 44,
                color: AppColors.sage600,
              ),
              SizedBox(height: 12),
              Text(
                'Wähle ein Foto für die Bestimmung',
                style: TextStyle(
                  color: AppColors.sage800,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ],
          )
        : ClipRRect(
            borderRadius: BorderRadius.circular(26),
            child: Image.memory(
              media!.bytes,
              fit: BoxFit.cover,
              width: double.infinity,
              height: double.infinity,
            ),
          ),
  );
}

class _IdentificationCard extends StatelessWidget {
  const _IdentificationCard({
    required this.job,
    required this.selectedCandidateId,
    required this.onCandidateSelected,
    required this.onRefresh,
  });

  final IdentificationJob job;
  final String? selectedCandidateId;
  final ValueChanged<String>? onCandidateSelected;
  final VoidCallback? onRefresh;

  @override
  Widget build(BuildContext context) {
    final isIdentified = job.status == 'identified';
    return Container(
      decoration: BoxDecoration(
        color: AppColors.sage800,
        borderRadius: BorderRadius.circular(28),
      ),
      padding: const EdgeInsets.all(18),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                width: 78,
                height: 78,
                decoration: BoxDecoration(
                  color: AppColors.sage600,
                  borderRadius: BorderRadius.circular(24),
                ),
                child: const Center(
                  child: Icon(Icons.eco, color: AppColors.sage300, size: 32),
                ),
              ),
              const SizedBox(width: 15),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      selectedCandidateId == null
                          ? 'BESTIMMUNGSVORSCHLÄGE'
                          : 'VORSCHLAG AUSGEWÄHLT',
                      style: AppTypography.textTheme.bodySmall?.copyWith(
                        fontWeight: FontWeight.bold,
                        letterSpacing: 1.1,
                        color: AppColors.sage300,
                      ),
                    ),
                    const SizedBox(height: 3),
                    Text(
                      isIdentified
                          ? 'Ergebnis verfügbar'
                          : 'Wird verarbeitet...',
                      style: AppTypography.textTheme.headlineSmall?.copyWith(
                        color: AppColors.neutral100,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          if (!isIdentified)
            Text(
              job.failureCode == null
                  ? 'Der Auftrag läuft im Hintergrund. Aktualisiere den Status.'
                  : 'Fehler: ${job.failureCode}',
              style: TextStyle(color: AppColors.neutral200),
            ),
          if (!isIdentified) ...[
            const SizedBox(height: 12),
            OutlinedButton.icon(
              key: const ValueKey('field-refresh-identification'),
              onPressed: onRefresh,
              icon: const Icon(Icons.refresh),
              label: const Text('Status aktualisieren'),
              style: OutlinedButton.styleFrom(
                foregroundColor: AppColors.neutral100,
                side: const BorderSide(color: AppColors.sage400),
              ),
            ),
          ],
          if (isIdentified && job.candidates.isEmpty)
            const Padding(
              padding: EdgeInsets.only(top: 8),
              child: Text(
                'Keine Übereinstimmung gefunden.',
                style: TextStyle(color: AppColors.neutral200),
              ),
            ),
          if (isIdentified && job.candidates.isNotEmpty)
            Padding(
              padding: const EdgeInsets.only(top: 8, bottom: 8),
              child: Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: AppColors.sage900.withOpacity(0.5),
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: AppColors.sage700),
                ),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Icon(
                      Icons.info_outline,
                      color: AppColors.sage300,
                      size: 18,
                    ),
                    const SizedBox(width: 10),
                    Expanded(
                      child: Text(
                        'KI-Vorschläge sind keine garantierte Bestimmung. Die Erkennung kann fehlerhaft sein. Verlasse dich nicht blind auf das Ergebnis, sondern überprüfe die Merkmale der Pflanze selbst.',
                        style: TextStyle(
                          color: AppColors.sage100,
                          fontSize: 12,
                          height: 1.4,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          if (isIdentified)
            ...job.candidates.map((candidate) {
              final candidateId = candidate.candidateId;
              final isSelected = selectedCandidateId == candidateId;
              return GestureDetector(
                onTap: onCandidateSelected != null
                    ? () => onCandidateSelected!(candidateId)
                    : null,
                child: Container(
                  margin: const EdgeInsets.only(top: 8),
                  padding: const EdgeInsets.symmetric(
                    horizontal: 16,
                    vertical: 12,
                  ),
                  decoration: BoxDecoration(
                    color: isSelected ? AppColors.sage700 : Colors.transparent,
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(
                      color: isSelected ? AppColors.sage400 : AppColors.sage600,
                    ),
                  ),
                  child: Row(
                    children: [
                      Icon(
                        isSelected
                            ? Icons.radio_button_checked
                            : Icons.radio_button_unchecked,
                        color: isSelected
                            ? AppColors.accent300
                            : AppColors.sage400,
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              candidate.commonName ?? candidate.scientificName,
                              style: TextStyle(
                                color: AppColors.neutral100,
                                fontWeight: FontWeight.bold,
                                fontSize: 16,
                              ),
                            ),
                            Text(
                              '${candidate.scientificName} · ${(candidate.score * 100).toStringAsFixed(0)} %',
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
              );
            }),
        ],
      ),
    );
  }
}

class _ErrorCard extends StatelessWidget {
  const _ErrorCard({required this.message});

  final String message;

  @override
  Widget build(BuildContext context) => Container(
    padding: const EdgeInsets.all(12),
    decoration: BoxDecoration(
      color: AppColors.warningBg,
      borderRadius: BorderRadius.circular(12),
    ),
    child: Text(message),
  );
}
