import '../../../core/ids/client_id_generator.dart';
import '../../../core/result.dart';
import '../../../core/time/clock.dart';
import '../domain/learning_models.dart';
import '../domain/learning_repository.dart';

/// Storage abstraction for caching progress snapshots locally.
abstract interface class ProgressStore {
  Future<Result<ProgressSnapshot?>> read();
  Future<Result<void>> save(ProgressSnapshot snapshot);
}

/// In-memory implementation of [ProgressStore] for caching and unit tests.
final class InMemoryProgressStore implements ProgressStore {
  InMemoryProgressStore([this._snapshot]);

  ProgressSnapshot? _snapshot;

  @override
  Future<Result<ProgressSnapshot?>> read() async => Result.success(_snapshot);

  @override
  Future<Result<void>> save(ProgressSnapshot snapshot) async {
    _snapshot = snapshot;
    return const Result.success(null);
  }
}

/// Service managing learning progress synchronization and merging.
final class ProgressSyncService {
  ProgressSyncService({
    required this.repository,
    ProgressStore? store,
    this.ids,
    Clock? clock,
  }) : _store = store ?? InMemoryProgressStore(),
       _clock = clock ?? const SystemClock();

  final LearningRepository repository;
  final ProgressStore _store;
  final ClientIdGenerator? ids;
  final Clock _clock;

  /// Synchronizes local progress and pending events with the remote backend.
  /// Submits pending events, queries server progress, merges results,
  /// saves the merged snapshot locally and returns it.
  Future<Result<ProgressSnapshot>> synchronize({
    List<LearningEvent>? pendingEvents,
    String? idempotencyKey,
    DateTime? since,
  }) async {
    if (pendingEvents != null && pendingEvents.isNotEmpty) {
      final key = idempotencyKey ??
          ids?.next() ??
          'sync-${_clock.now().millisecondsSinceEpoch}';
      final ack = await repository.submitEvents(
        events: pendingEvents,
        idempotencyKey: key,
      );
      if (ack case Failure<EventBatchAcknowledgement>(:final failure)) {
        return Result.failure(failure);
      }
    }

    final serverResult = await repository.getProgress(since: since);
    if (serverResult case Failure<ProgressSnapshot>(:final failure)) {
      return Result.failure(failure);
    }
    final serverSnapshot = (serverResult as Success<ProgressSnapshot>).value;

    final localResult = await getLocalProgress();
    final localSnapshot = localResult.valueOrNull;

    final merged = mergeProgress(
      server: serverSnapshot,
      local: localSnapshot,
    );
    await _store.save(merged);
    return Result.success(merged);
  }

  /// Reads the locally cached progress snapshot.
  Future<Result<ProgressSnapshot?>> getLocalProgress() => _store.read();

  /// Merges server and local progress snapshots.
  /// Server state always wins when conflicts occur on the same level.
  ProgressSnapshot mergeProgress({
    required ProgressSnapshot server,
    ProgressSnapshot? local,
  }) {
    if (local == null) return server;

    final serverLevelsMap = {
      for (final item in server.levels) item.levelId: item,
    };
    final mergedLevels = <LevelProgressSnapshot>[...server.levels];

    // Retain local levels that are not part of the server response
    for (final localLevel in local.levels) {
      if (!serverLevelsMap.containsKey(localLevel.levelId)) {
        mergedLevels.add(localLevel);
      }
    }

    final latestUpdatedAt = server.updatedAt.isAfter(local.updatedAt)
        ? server.updatedAt
        : local.updatedAt;

    return ProgressSnapshot(
      updatedAt: latestUpdatedAt,
      levels: mergedLevels,
    );
  }
}
