import '../../../core/result.dart';
import '../domain/herbarium_models.dart';
import '../domain/herbarium_repository.dart';

/// Lists herbarium entries.
final class ListHerbarium {
  const ListHerbarium(this._repository);

  final HerbariumRepository _repository;

  Future<Result<List<HerbariumEntry>>> call({
    int page = 1,
    int pageSize = 20,
  }) => _repository.listEntries(page: page, pageSize: pageSize);

  /// A specimen shelf needs every known species, not just the latest page.
  /// Offline adapters may return their cumulative cache instead of one page.
  Future<Result<List<HerbariumEntry>>> all() async {
    final entries = <String, HerbariumEntry>{};
    const pageSize = 100;
    for (var page = 1; ; page++) {
      final result = await _repository.listEntries(
        page: page,
        pageSize: pageSize,
      );
      if (result case Failure<List<HerbariumEntry>>(:final failure)) {
        return Result.failure(failure);
      }
      final items = (result as Success<List<HerbariumEntry>>).value;
      final before = entries.length;
      for (final entry in items) {
        entries[entry.id] = entry;
      }
      if (items.length < pageSize || entries.length == before) break;
    }
    return Result.success(
      entries.values
          .where((entry) => entry.syncStatus != SyncStatus.deleted)
          .toList()
        ..sort((a, b) => b.observedAt.compareTo(a.observedAt)),
    );
  }
}

/// Deletes a herbarium entry with optimistic concurrency check.
final class DeleteEntry {
  const DeleteEntry(this._repository);

  final HerbariumRepository _repository;

  Future<Result<void>> call({
    required String id,
    required String ifMatchVersion,
  }) => _repository.deleteEntry(id: id, ifMatchVersion: ifMatchVersion);
}

/// Synchronizes local and remote herbarium entries.
final class SyncEntries {
  const SyncEntries(this._repository);

  final HerbariumRepository _repository;

  Future<Result<List<HerbariumEntry>>> call() => _repository.syncEntries();
}
