import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../../app/app_dependencies.dart';
import '../../../core/ids/client_id_generator.dart';
import '../../../core/result.dart';
import '../../../core/theme/app_colors.dart';
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
      case Failure<IdentificationJob>(:final failure):
        _setFailure(failure.message);
    }
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

    return Scaffold(
      appBar: AppBar(title: const Text('Fund bestimmen')),
      body: ListView(
        padding: const EdgeInsets.all(20),
        children: [
          const Text(
            'Dein Foto wird zur Bestimmung an den konfigurierten Erkennungsdienst übertragen, aber nicht öffentlich geteilt. Standortdaten werden nur nach einer separaten Zustimmung übertragen.',
            style: TextStyle(height: 1.4),
          ),
          const SizedBox(height: 20),
          _PhotoCard(media: media),
          const SizedBox(height: 12),
          Wrap(
            spacing: 12,
            runSpacing: 8,
            children: [
              OutlinedButton.icon(
                key: const ValueKey('field-capture-camera'),
                onPressed: _isWorking ? null : () => _pickImage(camera: true),
                icon: const Icon(Icons.camera_alt_outlined),
                label: const Text('Foto aufnehmen'),
              ),
              OutlinedButton.icon(
                key: const ValueKey('field-capture-gallery'),
                onPressed: _isWorking ? null : () => _pickImage(camera: false),
                icon: const Icon(Icons.photo_library_outlined),
                label: const Text('Aus Galerie wählen'),
              ),
            ],
          ),
          if (media != null) ...[
            const SizedBox(height: 12),
            Text(
              '${media.filename} · ${(media.sizeBytes / 1024).ceil()} KB · Metadaten entfernt',
              key: const ValueKey('field-selected-media'),
              style: Theme.of(context).textTheme.bodySmall,
            ),
            const SizedBox(height: 16),
            FilledButton.icon(
              key: const ValueKey('field-start-identification'),
              onPressed: canStartIdentification ? _startIdentification : null,
              icon: const Icon(Icons.auto_awesome),
              label: const Text('Pflanze bestimmen'),
            ),
          ],
          if (_isWorking) ...[
            const SizedBox(height: 20),
            const Center(child: CircularProgressIndicator()),
          ],
          if (_workflowError != null) ...[
            const SizedBox(height: 16),
            _ErrorCard(message: _workflowError!),
          ],
          if (job != null) ...[
            const SizedBox(height: 24),
            _IdentificationCard(
              job: job,
              selectedCandidateId: _selectedCandidateId,
              onCandidateSelected: _isWorking
                  ? null
                  : (candidateId) =>
                        setState(() => _selectedCandidateId = candidateId),
              onRefresh: _isWorking ? null : _refreshIdentification,
            ),
          ],
          if (job?.status == 'identified') ...[
            const SizedBox(height: 16),
            SwitchListTile.adaptive(
              key: const ValueKey('field-location-consent'),
              value: _includeLocation,
              onChanged: _isWorking
                  ? null
                  : (value) => setState(() => _includeLocation = value),
              title: const Text('Standort einmalig mit diesem Fund teilen'),
              subtitle: Text(_locationDescription()),
              contentPadding: EdgeInsets.zero,
            ),
            const SizedBox(height: 12),
            FilledButton.icon(
              key: const ValueKey('field-save-observation'),
              onPressed: canSave ? _saveObservation : null,
              icon: const Icon(Icons.save_outlined),
              label: const Text('Vorschlag bestätigen und speichern'),
            ),
          ],
        ],
      ),
    );
  }

  String _locationDescription() {
    if (!_includeLocation) {
      return 'Aus. Das Foto wird unabhängig vom Standort verarbeitet.';
    }
    return switch (_locationState) {
      LocationState.denied => 'Nicht verfügbar: Berechtigung wurde verweigert. Der Fund wird ohne Standort gespeichert.',
      LocationState.disabled => 'Nicht verfügbar: Standortdienste sind deaktiviert. Der Fund wird ohne Standort gespeichert.',
      LocationState.restricted =>
        'Nicht verfügbar: Der Standort ist auf diesem Gerät eingeschränkt.',
      _ => 'Optional und nur für diesen privaten Fund. Du kannst ohne Standort fortfahren.',
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
    height: 180,
    alignment: Alignment.center,
    decoration: BoxDecoration(
      color: AppColors.cream,
      borderRadius: BorderRadius.circular(16),
      border: Border.all(color: AppColors.line),
    ),
    child: media == null
        ? const Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(Icons.add_a_photo_outlined, size: 44, color: AppColors.sage),
              SizedBox(height: 8),
              Text('Wähle ein Foto für die Bestimmung aus.'),
            ],
          )
        : ClipRRect(
            borderRadius: BorderRadius.circular(15),
            child: Image.memory(
              media!.bytes,
              fit: BoxFit.cover,
              width: double.infinity,
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
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              isIdentified
                  ? 'Bestimmung fertig'
                  : 'Bestimmung wird verarbeitet',
              style: Theme.of(context).textTheme.titleMedium,
            ),
            const SizedBox(height: 6),
            if (!isIdentified)
              Text(
                job.failureCode == null
                    ? 'Der Auftrag läuft im Hintergrund. Aktualisiere den Status, um das Ergebnis zu laden.'
                    : 'Die Bestimmung konnte nicht abgeschlossen werden: ${job.failureCode}',
              ),
            if (!isIdentified) ...[
              const SizedBox(height: 12),
              OutlinedButton.icon(
                key: const ValueKey('field-refresh-identification'),
                onPressed: onRefresh,
                icon: const Icon(Icons.refresh),
                label: const Text('Status aktualisieren'),
              ),
            ],
            if (isIdentified && job.candidates.isEmpty)
              const Padding(
                padding: EdgeInsets.only(top: 12),
                child: Text(
                  'Der Dienst lieferte keine bestätigbare Pflanzenart.',
                ),
              ),
            if (isIdentified && job.candidates.isNotEmpty)
              const Padding(
                padding: EdgeInsets.only(top: 12),
                child: Text(
                  'Die Bestimmung ist ein Vorschlag von PlantNet, keine garantierte Artenbestimmung. Prüfe die Merkmale vor dem Speichern.',
                ),
              ),
            if (isIdentified)
              ...job.candidates.map((candidate) {
                final candidateId = candidate.candidateId;
                return RadioListTile<String>(
                  value: candidateId,
                  groupValue: selectedCandidateId,
                  onChanged: onCandidateSelected != null
                      ? (_) => onCandidateSelected!(candidateId)
                      : null,
                  title: Text(candidate.commonName ?? candidate.scientificName),
                  subtitle: Text(
                    '${candidate.scientificName} · ${(candidate.score * 100).toStringAsFixed(0)} %',
                  ),
                );
              }),
          ],
        ),
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
