/// Synchronization state of a herbarium entry with the backend platform.
enum SyncStatus {
  synced,
  pending,
  conflict,
  deleted,
}

/// A stored observation entry in the user's digital herbarium.
final class HerbariumEntry {
  const HerbariumEntry({
    required this.id,
    required this.observedAt,
    this.note = '',
    this.confirmedPlantId,
    this.identificationJobId,
    required this.version,
    required this.syncStatus,
    this.mediaUrl,
  });

  final String id;
  final DateTime observedAt;
  final String note;
  final String? confirmedPlantId;
  final String? identificationJobId;
  final String version;
  final SyncStatus syncStatus;
  final String? mediaUrl;
}
