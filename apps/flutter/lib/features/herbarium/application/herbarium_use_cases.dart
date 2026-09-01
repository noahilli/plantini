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
