/// Geographic location coordinates for a field observation.
final class ObservationLocation {
  const ObservationLocation({
    required this.latitude,
    required this.longitude,
    this.accuracyMeters,
  });

  final double latitude;
  final double longitude;
  final double? accuracyMeters;
}

/// Field observation record.
final class Observation {
  const Observation({
    required this.id,
    required this.observedAt,
    this.note = '',
    this.confirmedPlantId,
    this.mediaId,
    this.identificationJobId,
    this.location,
  });

  final String id;
  final DateTime observedAt;
  final String note;
  final String? confirmedPlantId;
  final String? mediaId;
  final String? identificationJobId;
  final ObservationLocation? location;
}

/// A short-lived private-media reservation created before uploading image bytes.
final class MediaUpload {
  const MediaUpload({
    required this.id,
    required this.expiresAt,
    required this.status,
  });

  final String id;
  final DateTime expiresAt;
  final String status;
}

/// A candidate plant returned by the automated identification provider.
final class IdentificationCandidate {
  const IdentificationCandidate({
    required this.candidateId,
    required this.scientificName,
    this.commonName,
    this.plantId,
    required this.score,
    this.provider = 'plantnet',
    this.modelVersion = 'unknown',
  });

  /// Provider-stable reference. Unlike [plantId], this is available for
  /// candidates that have not yet been curated in Plantini's own catalogue.
  final String candidateId;
  final String scientificName;
  final String? commonName;
  final String? plantId;
  final double score;
  final String provider;
  final String modelVersion;
}

/// Status of an asynchronous plant identification job.
enum IdentificationStatus { pending, processing, identified, failed }

/// Identification job representation.
final class IdentificationJob {
  const IdentificationJob({
    required this.id,
    required this.status,
    required this.createdAt,
    this.retryAfter,
    this.candidates = const [],
    this.failureCode,
    this.confirmedPlantId,
    this.confirmedCandidateId,
  });

  final String id;
  final String status;
  final DateTime createdAt;
  final DateTime? retryAfter;
  final List<IdentificationCandidate> candidates;
  final String? failureCode;
  final String? confirmedPlantId;
  final String? confirmedCandidateId;
}
