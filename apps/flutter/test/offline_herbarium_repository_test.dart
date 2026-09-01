import 'package:flutter_test/flutter_test.dart';
import 'package:plantini_app/core/errors/app_failure.dart';
import 'package:plantini_app/core/result.dart';
import 'package:plantini_app/core/time/clock.dart';
import 'package:plantini_app/features/field/application/sync_queue_service.dart';
import 'package:plantini_app/features/herbarium/domain/herbarium_models.dart';
import 'package:plantini_app/features/herbarium/domain/herbarium_repository.dart';
import 'package:plantini_app/features/herbarium/infrastructure/offline_herbarium_repository.dart';
import 'package:shared_preferences/shared_preferences.dart';

final class _TestClock implements Clock {
  _TestClock(this.value);
  DateTime value;
  @override
  DateTime now() => value;
  void advance(Duration duration) => value = value.add(duration);
}

final class _RemoteHerbarium implements HerbariumRepository {
  bool online = false;
  bool conflictOnUpdate = false;
  int createCalls = 0;
  final Map<String, HerbariumEntry> entries = {};

  NetworkFailure get unavailable => const NetworkFailure(message: 'offline');

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
    createCalls++;
    if (!online) return Result.failure(unavailable);
    final existing = entries[clientObservationId];
    if (existing != null) return Result.success(existing);
    final entry = HerbariumEntry(
      id: 'remote-$clientObservationId',
      clientObservationId: clientObservationId,
      observedAt: observedAt,
      note: note ?? '',
      identificationJobId: identificationJobId,
      version: 'remote-v1',
      syncStatus: SyncStatus.synced,
    );
    entries[clientObservationId] = entry;
    return Result.success(entry);
  }

  @override
  Future<Result<List<HerbariumEntry>>> listEntries({
    int page = 1,
    int pageSize = 20,
  }) async => online
      ? Result.success(entries.values.toList())
      : Result.failure(unavailable);

  @override
  Future<Result<HerbariumEntry>> getEntry(String id) async {
    if (!online) return Result.failure(unavailable);
    return Result.success(entries.values.firstWhere((entry) => entry.id == id));
  }

  @override
  Future<Result<HerbariumEntry>> updateEntry({
    required String id,
    required String note,
    required String ifMatchVersion,
  }) async {
    if (!online) return Result.failure(unavailable);
    if (conflictOnUpdate) {
      return const Result.failure(ConflictFailure(message: 'remote conflict'));
    }
    final current = entries.values.firstWhere((entry) => entry.id == id);
    final updated = current.copyWith(note: note, version: 'remote-v2');
    entries[current.clientObservationId!] = updated;
    return Result.success(updated);
  }

  @override
  Future<Result<void>> deleteEntry({
    required String id,
    required String ifMatchVersion,
  }) async {
    if (!online) return Result.failure(unavailable);
    entries.removeWhere((_, entry) => entry.id == id);
    return const Result.success(null);
  }

  @override
  Future<Result<List<HerbariumEntry>>> syncEntries() => listEntries();
}

void main() {
  test(
    'offline observation survives repository restart and syncs once',
    () async {
      final remote = _RemoteHerbarium();
      SharedPreferences.setMockInitialValues({});
      final preferences = await SharedPreferences.getInstance();
      var local = SharedPreferencesHerbariumStore(preferences);
      final queueStore = InMemorySyncQueueStore();
      final clock = _TestClock(DateTime.parse('2026-09-01T10:00:00Z'));
      final queue = SyncQueueService(store: queueStore, clock: clock);
      var repository = OfflineHerbariumRepository(
        remote: remote,
        local: local,
        queue: queue,
      );

      final created = await repository.createEntry(
        clientObservationId: '11111111-1111-4111-8111-111111111111',
        observedAt: clock.now(),
        note: 'Offline-Fund',
        idempotencyKey: '11111111-1111-4111-8111-111111111111',
      );
      expect(created.valueOrNull?.syncStatus, SyncStatus.pending);

      local = SharedPreferencesHerbariumStore(preferences);
      repository = OfflineHerbariumRepository(
        remote: remote,
        local: local,
        queue: queue,
      );
      final afterRestart = await repository.listEntries();
      expect(afterRestart.valueOrNull?.single.note, 'Offline-Fund');

      remote.online = true;
      clock.advance(const Duration(seconds: 3));
      final synced = await repository.syncEntries();
      expect(synced.valueOrNull?.single.syncStatus, SyncStatus.synced);
      expect(
        synced.valueOrNull?.single.clientObservationId,
        '11111111-1111-4111-8111-111111111111',
      );
      expect(remote.entries.length, 1);
    },
  );

  test('remote version conflict remains visible and retryable', () async {
    final remote = _RemoteHerbarium()..online = true;
    final local = InMemoryHerbariumLocalStore();
    final clock = _TestClock(DateTime.parse('2026-09-01T10:00:00Z'));
    final repository = OfflineHerbariumRepository(
      remote: remote,
      local: local,
      queue: SyncQueueService(store: InMemorySyncQueueStore(), clock: clock),
    );
    final created = await repository.createEntry(
      clientObservationId: '22222222-2222-4222-8222-222222222222',
      observedAt: clock.now(),
      idempotencyKey: '22222222-2222-4222-8222-222222222222',
    );
    remote.conflictOnUpdate = true;

    final updated = await repository.updateEntry(
      id: created.valueOrNull!.id,
      note: 'Konkurrierende Notiz',
      ifMatchVersion: created.valueOrNull!.version,
    );

    expect(updated.valueOrNull?.syncStatus, SyncStatus.conflict);
    final afterPull = await repository.listEntries();
    expect(afterPull.valueOrNull?.single.syncStatus, SyncStatus.conflict);
    expect(local.records.values.single.syncError, 'remote conflict');
  });
}
