/// Synchronization state of a herbarium entry with the backend platform.
enum SyncStatus { synced, pending, conflict, deleted }

/// A stored observation entry in the user's digital herbarium.
final class HerbariumEntry {
  const HerbariumEntry({
    required this.id,
    this.clientObservationId,
    required this.observedAt,
    this.note = '',
    this.confirmedPlantId,
    this.identificationJobId,
    required this.version,
    required this.syncStatus,
    this.mediaUrl,
    this.plantName,
    this.scientificName,
    this.identificationResult,
    this.latitude,
    this.longitude,
    this.accuracyMeters,
    this.syncError,
  });

  final String id;
  final String? clientObservationId;
  final DateTime observedAt;
  final String note;
  final String? confirmedPlantId;
  final String? identificationJobId;
  final String version;
  final SyncStatus syncStatus;
  final String? mediaUrl;
  final String? plantName;
  final String? scientificName;
  final String? identificationResult;
  final double? latitude;
  final double? longitude;
  final double? accuracyMeters;
  final String? syncError;

  /// Display title for list and detail views.
  String get displayTitle {
    if (plantName != null && plantName!.trim().isNotEmpty) {
      return plantName!;
    }
    if (scientificName != null && scientificName!.trim().isNotEmpty) {
      return scientificName!;
    }
    return 'Unbestimmter Fund';
  }

  /// Creates a copy of this entry with modified fields.
  HerbariumEntry copyWith({
    String? id,
    String? clientObservationId,
    DateTime? observedAt,
    String? note,
    String? confirmedPlantId,
    String? identificationJobId,
    String? version,
    SyncStatus? syncStatus,
    String? mediaUrl,
    String? plantName,
    String? scientificName,
    String? identificationResult,
    double? latitude,
    double? longitude,
    double? accuracyMeters,
    String? syncError,
    bool clearSyncError = false,
  }) {
    return HerbariumEntry(
      id: id ?? this.id,
      clientObservationId: clientObservationId ?? this.clientObservationId,
      observedAt: observedAt ?? this.observedAt,
      note: note ?? this.note,
      confirmedPlantId: confirmedPlantId ?? this.confirmedPlantId,
      identificationJobId: identificationJobId ?? this.identificationJobId,
      version: version ?? this.version,
      syncStatus: syncStatus ?? this.syncStatus,
      mediaUrl: mediaUrl ?? this.mediaUrl,
      plantName: plantName ?? this.plantName,
      scientificName: scientificName ?? this.scientificName,
      identificationResult: identificationResult ?? this.identificationResult,
      latitude: latitude ?? this.latitude,
      longitude: longitude ?? this.longitude,
      accuracyMeters: accuracyMeters ?? this.accuracyMeters,
      syncError: clearSyncError ? null : syncError ?? this.syncError,
    );
  }
}
