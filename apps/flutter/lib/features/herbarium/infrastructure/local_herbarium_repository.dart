import '../../../core/errors/app_failure.dart';
import '../../../core/result.dart';
import '../domain/herbarium_models.dart';
import '../domain/herbarium_repository.dart';

/// Explicit in-memory adapter for deterministic widget tests.
///
/// It is intentionally not used by application bootstrap. It never seeds
/// fabricated observations and cannot report a remote synchronization result.
final class LocalHerbariumRepository implements HerbariumRepository {
  LocalHerbariumRepository({List<HerbariumEntry> initialEntries = const []})
    : _entries = List.of(initialEntries);

  final List<HerbariumEntry> _entries;

  @override
  Future<Result<List<HerbariumEntry>>> listEntries({
    int page = 1,
    int pageSize = 20,
  }) async {
    if (page < 1 || pageSize < 1) {
      return const Result.failure(
        ValidationFailure(
          message: 'Seite und Seitengröße müssen positiv sein.',
        ),
      );
    }
    final entries = List.of(_entries)
      ..sort((left, right) => right.observedAt.compareTo(left.observedAt));
    final start = (page - 1) * pageSize;
    if (start >= entries.length) return const Result.success([]);
    final end = (start + pageSize).clamp(0, entries.length);
    return Result.success(List.unmodifiable(entries.sublist(start, end)));
  }

  @override
  Future<Result<HerbariumEntry>> getEntry(String id) async {
    for (final entry in _entries) {
      if (entry.id == id) return Result.success(entry);
    }
    return const Result.failure(
      NotFoundFailure(message: 'Herbarium-Eintrag wurde nicht gefunden.'),
    );
  }

  @override
  Future<Result<HerbariumEntry>> createEntry({
    required String clientObservationId,
    required DateTime observedAt,
    String? note,
    String? mediaId,
    String? mediaUrl,
    String? plantName,
    String? scientificName,
    String? identificationResult,
    String? identificationJobId,
    double? latitude,
    double? longitude,
    double? accuracyMeters,
    required String idempotencyKey,
  }) async {
    final entry = HerbariumEntry(
      id: clientObservationId,
      observedAt: observedAt,
      note: note ?? '',
      plantName: plantName,
      scientificName: scientificName,
      identificationJobId: identificationJobId,
      identificationResult: identificationResult,
      mediaUrl: mediaUrl,
      version: 'local-$clientObservationId',
      syncStatus: SyncStatus.pending,
      latitude: latitude,
      longitude: longitude,
    );
    _entries.removeWhere((item) => item.id == clientObservationId);
    _entries.add(entry);
    return Result.success(entry);
  }

  @override
  Future<Result<void>> deleteEntry({
    required String id,
    required String ifMatchVersion,
  }) async {
    final result = await getEntry(id);
    if (result case Failure<HerbariumEntry>(:final failure)) {
      return Result.failure(failure);
    }
    final entry = (result as Success<HerbariumEntry>).value;
    if (entry.version != ifMatchVersion) {
      return const Result.failure(
        ConflictFailure(message: 'Der Fund wurde inzwischen geändert.'),
      );
    }
    _entries.removeWhere((item) => item.id == id);
    return const Result.success(null);
  }

  @override
  Future<Result<HerbariumEntry>> updateEntry({
    required String id,
    required String note,
    required String ifMatchVersion,
  }) async {
    final index = _entries.indexWhere((item) => item.id == id);
    if (index < 0) {
      return const Result.failure(
        NotFoundFailure(message: 'Herbarium-Eintrag wurde nicht gefunden.'),
      );
    }
    final current = _entries[index];
    if (current.version != ifMatchVersion) {
      return const Result.failure(
        ConflictFailure(message: 'Der Fund wurde inzwischen geändert.'),
      );
    }
    final updated = current.copyWith(
      note: note,
      version: 'local-${DateTime.now().microsecondsSinceEpoch}',
      syncStatus: SyncStatus.pending,
    );
    _entries[index] = updated;
    return Result.success(updated);
  }

  @override
  Future<Result<List<HerbariumEntry>>> syncEntries() async =>
      const Result.failure(
        NetworkFailure(
          message: 'Der lokale Testadapter kann keine Funde synchronisieren. Verwende die API-Implementierung.',
        ),
      );
}
