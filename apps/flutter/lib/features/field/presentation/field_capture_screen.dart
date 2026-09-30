import 'dart:async';

import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../../app/app_dependencies.dart';
import '../../../core/ids/client_id_generator.dart';
import '../../../core/result.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_typography.dart';
import '../../herbarium/domain/herbarium_repository.dart';
import '../../../core/errors/app_failure.dart';
import '../domain/field_models.dart';
import 'field_problem.dart';
import 'widgets/analysis_progress.dart';
import '../domain/field_repository.dart';
import '../infrastructure/location_service.dart';
import '../infrastructure/media_service.dart';
import 'widgets/expected_plant_mismatch_consent.dart';

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
    this.expectedPlantId,
    this.expectedPlantName,
  });

  final AppDependencies? dependencies;
  final FieldRepository? fieldRepository;
  final HerbariumRepository? herbariumRepository;
  final MediaService? mediaService;
  final LocationService? locationService;
  final ClientIdGenerator? ids;
  final String? expectedPlantId;
  final String? expectedPlantName;

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
  bool _removePhotoLocation = true;
  bool _isWorking = false;
  bool _acceptMismatch = false;
  Timer? _identificationPollTimer;
  bool _problemDialogOpen = false;
  String? _explainedJob;
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
        ? await _mediaService.captureFromCamera(
            keepLocation: !_removePhotoLocation,
          )
        : await _mediaService.pickFromGallery(
            keepLocation: !_removePhotoLocation,
          );
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
          _acceptMismatch = false;
        });
      case Failure<ProcessedMedia>(:final failure):
        _setPickFailure(failure);
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
      _setFailure(failure, FieldStep.reserve, _startIdentification);
      return;
    }
    final upload = await repository.uploadMediaContent(
      mediaId: (reservation as Success<MediaUpload>).value.id,
      bytes: media.bytes,
      contentType: media.mimeType,
      filename: media.filename,
    );
    if (upload case Failure<MediaUpload>(:final failure)) {
      _setFailure(failure, FieldStep.upload, _startIdentification);
      return;
    }
    final jobClientId = _ids.next();
    final job = await repository.submitObservation(
      clientJobId: jobClientId,
      mediaId: (upload as Success<MediaUpload>).value.id,
      idempotencyKey: jobClientId,
      expectedPlantId: widget.expectedPlantId,
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
        _explainFailedJob(value);
      case Failure<IdentificationJob>(:final failure):
        _setFailure(failure, FieldStep.submit, _startIdentification);
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
        _explainFailedJob(value);
      case Failure<IdentificationJob>(:final failure):
        _setFailure(failure, FieldStep.poll, _refreshIdentification);
    }
  }

  Future<void> _retryIdentification() async {
    final repository = _fieldRepository;
    final job = _job;
    if (repository == null || job == null || _isWorking) return;
    setState(() {
      _isWorking = true;
      _workflowError = null;
    });
    _explainedJob = null;
    final result = await repository.retryIdentification(
      jobId: job.id,
      idempotencyKey: _ids.next(),
    );
    if (!mounted) return;
    switch (result) {
      case Success<IdentificationJob>(:final value):
        setState(() {
          _job = value;
          _isWorking = false;
        });
        _scheduleIdentificationPoll(value);
        _explainFailedJob(value);
      case Failure<IdentificationJob>(:final failure):
        _setFailure(failure, FieldStep.submit, _retryIdentification);
    }
  }

  void _scheduleIdentificationPoll(IdentificationJob job) {
    _identificationPollTimer?.cancel();
    final retryScheduled = job.status == 'failed' && job.retryAfter != null;
    if (!mounted ||
        (job.status != 'pending' &&
            job.status != 'processing' &&
            !retryScheduled)) {
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
      acceptMismatch: _requiresMismatchAcceptance && _acceptMismatch,
    );
    if (confirmed case Failure<IdentificationJob>(:final failure)) {
      _setFailure(failure, FieldStep.confirm, _saveObservation);
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
    _setFailure(created.failureOrNull!, FieldStep.save, _saveObservation);
  }

  Future<LocationCoordinates?> _locationForSubmission() async {
    if (!_includeLocation) return null;
    final state = await _locationService.requestLocation();
    if (!mounted) return null;
    setState(() => _locationState = state);
    if (state != LocationState.granted) return null;
    final result = await _locationService.getCurrentLocation();
    if (mounted && _locationService.state != state) {
      setState(() => _locationState = _locationService.state);
    }
    return result.valueOrNull;
  }

  void _setPickFailure(AppFailure failure) => _report(
    FieldProblem(
      title: 'Foto nicht verfügbar',
      message: failure.message,
      hint: 'Prüfe die Berechtigungen für Kamera und Fotos oder wähle ein anderes Bild.',
      icon: Icons.no_photography_outlined,
    ),
  );

  void _setFailure(
    AppFailure failure,
    FieldStep step, [
    Future<void> Function()? retry,
  ]) => _report(FieldProblem.fromFailure(failure, step), retry);

  /// Shows the problem as inline note and as a pop-up; "Erneut versuchen" runs
  /// [retry] again for exactly the step that failed.
  void _report(FieldProblem problem, [Future<void> Function()? retry]) {
    if (!mounted) return;
    setState(() {
      _isWorking = false;
      _workflowError = problem.plainText;
    });
    if (_problemDialogOpen) return;
    _problemDialogOpen = true;
    WidgetsBinding.instance.addPostFrameCallback((_) async {
      if (!mounted) {
        _problemDialogOpen = false;
        return;
      }
      final again = await showFieldProblemDialog(
        context,
        problem,
        offerRetry: retry != null,
      );
      _problemDialogOpen = false;
      if (again && mounted && retry != null) {
        setState(() => _workflowError = null);
        await retry();
      }
    });
  }

  /// A finished job that failed for good is explained once in a pop-up.
  void _explainFailedJob(IdentificationJob job) {
    final terminal =
        job.status == 'failed' &&
        (job.retryAfter == null || job.deadLetteredAt != null);
    final marker = '${job.id}/${job.attempts}';
    if (!terminal || _explainedJob == marker) return;
    _explainedJob = marker;
    final problem = FieldProblem.fromJob(job);
    _report(problem, problem.retryable ? _retryIdentification : null);
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
        (!_requiresMismatchAcceptance || _acceptMismatch) &&
        !_isWorking;
    final retryScheduled =
        job?.status == 'failed' &&
        job?.retryAfter != null &&
        job?.deadLetteredAt == null;

    // State 1n: Identification in progress
    if ((_isWorking && job == null && media != null) ||
        job?.status == 'processing' ||
        job?.status == 'pending' ||
        retryScheduled) {
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
                      AnalysisProgress(
                        stage: job == null
                            ? AnalysisStage.uploading
                            : job.status == 'processing'
                            ? AnalysisStage.analysing
                            : AnalysisStage.queued,
                        photo: media?.bytes,
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
                          : (candidateId) => setState(() {
                              _selectedCandidateId = candidateId;
                              _acceptMismatch = false;
                            }),
                      onRefresh: _isWorking ? null : _refreshIdentification,
                      onRetry: _isWorking ? null : _retryIdentification,
                    ),
                    const SizedBox(height: 16),
                    if (_requiresMismatchAcceptance) ...[
                      ExpectedPlantMismatchConsent(
                        expectedPlantName:
                            widget.expectedPlantName ?? 'die Levelart',
                        value: _acceptMismatch,
                        onChanged: _isWorking
                            ? null
                            : (value) => setState(
                                () => _acceptMismatch = value == true,
                              ),
                      ),
                      const SizedBox(height: 16),
                    ],
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
                  Container(
                    padding: const EdgeInsets.all(22),
                    decoration: BoxDecoration(
                      gradient: const LinearGradient(
                        colors: [AppColors.sage800, AppColors.sage700],
                      ),
                      borderRadius: BorderRadius.circular(28),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Icon(
                          Icons.explore_rounded,
                          size: 36,
                          color: AppColors.accent300,
                        ),
                        const SizedBox(height: 12),
                        Text(
                          'Finde und bestimme\neine Pflanze',
                          style: AppTypography.textTheme.headlineMedium
                              ?.copyWith(
                                fontSize: 29,
                                color: AppColors.neutral100,
                              ),
                        ),
                        const SizedBox(height: 8),
                        const Text(
                          'Dein nächster Fund wartet draußen.',
                          style: TextStyle(color: AppColors.sage200),
                        ),
                      ],
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
                    SwitchListTile.adaptive(
                      key: const ValueKey('field-remove-photo-location'),
                      contentPadding: EdgeInsets.zero,
                      value: _removePhotoLocation,
                      onChanged: _isWorking
                          ? null
                          : (value) =>
                                setState(() => _removePhotoLocation = value),
                      title: const Text('Foto-Standort entfernen'),
                      subtitle: const Text(
                        'Empfohlen: GPS-Metadaten vor dem Upload löschen.',
                      ),
                    ),
                    const SizedBox(height: 10),
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
      LocationState.restricted =>
        'Genauer Standort eingeschränkt. Wird ohne Standort gespeichert.',
      LocationState.inaccurate =>
        'Standort zu ungenau. Wird ohne Standort gespeichert.',
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

  bool get _requiresMismatchAcceptance {
    final job = _job;
    final selected = _selectedCandidateId;
    if (job == null || job.expectedPlantId == null || selected == null) {
      return false;
    }
    return job.expectedCandidateId == null ||
        selected != job.expectedCandidateId;
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
    required this.onRetry,
  });

  final IdentificationJob job;
  final String? selectedCandidateId;
  final ValueChanged<String>? onCandidateSelected;
  final VoidCallback? onRefresh;
  final VoidCallback? onRetry;

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
                  : FieldProblem.fromJob(job).plainText,
              style: TextStyle(color: AppColors.neutral200),
            ),
          if (!isIdentified) ...[
            const SizedBox(height: 12),
            OutlinedButton.icon(
              key: const ValueKey('field-refresh-identification'),
              onPressed: job.status == 'failed' ? onRetry : onRefresh,
              icon: Icon(job.status == 'failed' ? Icons.replay : Icons.refresh),
              label: Text(
                job.status == 'failed'
                    ? 'Erneut versuchen'
                    : 'Status aktualisieren',
              ),
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
                        'KI-Vorschläge sind keine garantierte Bestimmung und ähnliche Arten können verwechselt werden. Pflanze nicht verzehren, berühren oder sammeln, solange Giftigkeit und Schutzstatus nicht fachlich geprüft sind.',
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
          if (isIdentified && job.provider != null)
            Padding(
              padding: const EdgeInsets.only(bottom: 4),
              child: Text(
                'Provider: ${job.provider} · Modell: ${job.modelVersion ?? 'unbekannt'} · Flora: ${job.floraVersion ?? 'unbekannt'} · Versuch ${job.attempts}',
                key: const ValueKey('field-provider-metadata'),
                style: TextStyle(color: AppColors.sage300, fontSize: 11),
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
                              '${candidate.scientificName} · ${_confidenceLabel(candidate.score)}',
                              style: TextStyle(
                                color: AppColors.sage300,
                                fontSize: 12,
                              ),
                            ),
                            if (candidate.safetyNotice != null) ...[
                              const SizedBox(height: 6),
                              Text(
                                candidate.safetyNotice!,
                                key: ValueKey(
                                  'field-safety-${candidate.candidateId}',
                                ),
                                style: const TextStyle(
                                  color: AppColors.accent200,
                                  fontSize: 12,
                                  height: 1.35,
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
            }),
        ],
      ),
    );
  }

  String _confidenceLabel(double score) {
    final percent = (score * 100).round();
    if (score >= 0.8) return 'hohe Ähnlichkeit ($percent %)';
    if (score >= 0.5) return 'mittlere Ähnlichkeit ($percent %)';
    return 'geringe Ähnlichkeit ($percent %)';
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
