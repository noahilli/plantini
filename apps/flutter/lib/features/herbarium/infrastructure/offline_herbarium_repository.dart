import 'dart:async';
import 'dart:convert';

import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../../../core/errors/app_failure.dart';
import '../../../core/result.dart';
import '../../field/application/sync_queue_service.dart';
import '../../field/domain/field_models.dart';
import '../../field/domain/location_privacy.dart';
import '../domain/herbarium_models.dart';
import '../domain/herbarium_repository.dart';

final class LocalObservationRecord {
  const LocalObservationRecord({
    required this.clientId,
    required this.entry,
    this.remoteId,
    this.remoteVersion,
    this.syncError,
  });

  final String clientId;
  final HerbariumEntry entry;
  final String? remoteId;
  final String? remoteVersion;
  final String? syncError;

  LocalObservationRecord copyWith({
    HerbariumEntry? entry,
    String? remoteId,
    String? remoteVersion,
    String? syncError,
    bool clearSyncError = false,
  }) => LocalObservationRecord(
    clientId: clientId,
    entry: entry ?? this.entry,
    remoteId: remoteId ?? this.remoteId,
    remoteVersion: remoteVersion ?? this.remoteVersion,
    syncError: clearSyncError ? null : syncError ?? this.syncError,
  );
}

abstract interface class HerbariumLocalStore {
  Future<List<LocalObservationRecord>> readAll();
  Future<LocalObservationRecord?> read(String clientId);
  Future<void> write(LocalObservationRecord record);
  Future<void> remove(String clientId);
}

final class SharedPreferencesHerbariumStore implements HerbariumLocalStore {
  const SharedPreferencesHerbariumStore(this._preferences);

  static const _key = 'herbarium.cache.v1';
  final SharedPreferences _preferences;

  @override
  Future<List<LocalObservationRecord>> readAll() async {
    final raw = _preferences.getString(_key);
    if (raw == null || raw.isEmpty) return const [];
    final decoded = jsonDecode(raw);
    if (decoded is! List) {
      throw const FormatException('Invalid herbarium cache');
    }
    return decoded
        .whereType<Map<String, dynamic>>()
        .map(_recordFromJson)
        .toList();
  }

  @override
  Future<LocalObservationRecord?> read(String clientId) async {
    for (final record in await readAll()) {
      if (record.clientId == clientId) return record;
    }
    return null;
  }

  @override
  Future<void> write(LocalObservationRecord record) async {
    final records = List<LocalObservationRecord>.of(await readAll());
    records.removeWhere((item) => item.clientId == record.clientId);
    records.add(record);
    await _preferences.setString(
      _key,
      jsonEncode(records.map(_recordToJson).toList()),
    );
  }

  @override
  Future<void> remove(String clientId) async {
    final records = List<LocalObservationRecord>.of(await readAll());
    records.removeWhere((item) => item.clientId == clientId);
    await _preferences.setString(
      _key,
      jsonEncode(records.map(_recordToJson).toList()),
    );
  }
}

final class InMemoryHerbariumLocalStore implements HerbariumLocalStore {
  final Map<String, LocalObservationRecord> records = {};

  @override
  Future<List<LocalObservationRecord>> readAll() async =>
      records.values.toList();

  @override
  Future<LocalObservationRecord?> read(String clientId) async =>
      records[clientId];

  @override
  Future<void> write(LocalObservationRecord record) async {
    records[record.clientId] = record;
  }

  @override
  Future<void> remove(String clientId) async {
    records.remove(clientId);
  }
}

/// Offline-first repository. Local state is committed before a durable queue
/// item is processed, so app termination never turns a failed request into a
/// lost field observation.
final class OfflineHerbariumRepository implements HerbariumRepository {
  OfflineHerbariumRepository({
    required this.remote,
    required this.local,
    required this.queue,
    this.connectivity,
  });

  final HerbariumRepository remote;
  final HerbariumLocalStore local;
  final SyncQueueService queue;
  final Connectivity? connectivity;
  StreamSubscription<List<ConnectivityResult>>? _connectivitySubscription;

  void startConnectivityMonitoring() {
    _connectivitySubscription ??= connectivity?.onConnectivityChanged.listen((
      results,
    ) {
      if (results.any((result) => result != ConnectivityResult.none)) {
        unawaited(queue.onNetworkRestored(processor: _processQueuePayload));
      }
    });
  }

  Future<void> dispose() async => _connectivitySubscription?.cancel();

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
      clientObservationId: clientObservationId,
      observedAt: observedAt,
      note: note ?? '',
      mediaUrl: mediaUrl,
      plantName: plantName,
      scientificName: scientificName,
      identificationResult: identificationResult,
      identificationJobId: identificationJobId,
      version: 'local-$clientObservationId',
      syncStatus: SyncStatus.pending,
      latitude: latitude,
      longitude: longitude,
      accuracyMeters: accuracyMeters,
    );
    await local.write(
      LocalObservationRecord(clientId: clientObservationId, entry: entry),
    );
    await _enqueue(clientObservationId);
    await queue.processQueue(processor: _processQueuePayload);
    return Result.success((await local.read(clientObservationId))!.entry);
  }

  @override
  Future<Result<List<HerbariumEntry>>> listEntries({
    int page = 1,
    int pageSize = 20,
  }) async {
    await queue.processQueue(processor: _processQueuePayload);
    final pulled = await remote.listEntries(page: page, pageSize: pageSize);
    if (pulled case Success<List<HerbariumEntry>>(:final value)) {
      for (final entry in value) {
        final clientId = entry.clientObservationId ?? entry.id;
        final current = await local.read(clientId);
        if (current != null && current.entry.syncStatus != SyncStatus.synced) {
          continue;
        }
        await local.write(
          LocalObservationRecord(
            clientId: clientId,
            entry: entry,
            remoteId: entry.id,
            remoteVersion: entry.version,
          ),
        );
      }
    }
    final records = await local.readAll();
    final entries =
        records
            .map((record) => record.entry)
            .where((entry) => entry.syncStatus != SyncStatus.deleted)
            .toList()
          ..sort((a, b) => b.observedAt.compareTo(a.observedAt));
    return Result.success(entries);
  }

  @override
  Future<Result<HerbariumEntry>> getEntry(String id) async {
    for (final record in await local.readAll()) {
      if (record.clientId == id ||
          record.entry.id == id ||
          record.remoteId == id) {
        return Result.success(record.entry);
      }
    }
    final result = await remote.getEntry(id);
    if (result case Success<HerbariumEntry>(:final value)) {
      final clientId = value.clientObservationId ?? value.id;
      await local.write(
        LocalObservationRecord(
          clientId: clientId,
          entry: value,
          remoteId: value.id,
          remoteVersion: value.version,
        ),
      );
    }
    return result;
  }

  @override
  Future<Result<HerbariumEntry>> updateEntry({
    required String id,
    required String note,
    required String ifMatchVersion,
  }) async {
    final record = await _findRecord(id);
    if (record == null) {
      return remote.updateEntry(
        id: id,
        note: note,
        ifMatchVersion: ifMatchVersion,
      );
    }
    final pending = record.copyWith(
      entry: record.entry.copyWith(note: note, syncStatus: SyncStatus.pending),
      clearSyncError: true,
    );
    await local.write(pending);
    await _enqueue(record.clientId);
    await queue.processQueue(processor: _processQueuePayload);
    return Result.success((await local.read(record.clientId))!.entry);
  }

  @override
  Future<Result<void>> deleteEntry({
    required String id,
    required String ifMatchVersion,
  }) async {
    final record = await _findRecord(id);
    if (record == null) {
      return remote.deleteEntry(id: id, ifMatchVersion: ifMatchVersion);
    }
    await local.write(
      record.copyWith(
        entry: record.entry.copyWith(syncStatus: SyncStatus.deleted),
        clearSyncError: true,
      ),
    );
    await _enqueue(record.clientId);
    await queue.processQueue(processor: _processQueuePayload);
    return const Result.success(null);
  }

  @override
  Future<Result<List<HerbariumEntry>>> syncEntries() async {
    await queue.retryFailedJobs();
    return listEntries(pageSize: 100);
  }

  Future<void> _enqueue(String clientId) async {
    await queue.enqueueJob(
      clientId: 'observation:$clientId',
      payload: jsonEncode({'clientObservationId': clientId}),
    );
  }

  Future<Result<void>> _processQueuePayload(String payload) async {
    final decoded = jsonDecode(payload);
    if (decoded is! Map<String, dynamic>) {
      return const Result.failure(
        ValidationFailure(message: 'Ungültiger Herbarium-Syncauftrag.'),
      );
    }
    final clientId = decoded['clientObservationId'];
    if (clientId is! String) {
      return const Result.failure(
        ValidationFailure(message: 'Client-ID im Syncauftrag fehlt.'),
      );
    }
    final record = await local.read(clientId);
    if (record == null) return const Result.success(null);
    Result<dynamic> result;
    if (record.entry.syncStatus == SyncStatus.deleted) {
      if (record.remoteId == null || record.remoteVersion == null) {
        await local.remove(clientId);
        return const Result.success(null);
      }
      result = await remote.deleteEntry(
        id: record.remoteId!,
        ifMatchVersion: record.remoteVersion!,
      );
      if (result.isSuccess) await local.remove(clientId);
    } else if (record.remoteId == null) {
      final location =
          record.entry.latitude != null && record.entry.longitude != null
          ? LocationPrivacy.coarsen(
              ObservationLocation(
                latitude: record.entry.latitude!,
                longitude: record.entry.longitude!,
                accuracyMeters: record.entry.accuracyMeters,
              ),
            )
          : null;

      result = await remote.createEntry(
        clientObservationId: clientId,
        observedAt: record.entry.observedAt,
        note: record.entry.note,
        identificationJobId: record.entry.identificationJobId,
        latitude: location?.latitude,
        longitude: location?.longitude,
        accuracyMeters: location?.accuracyMeters,
        idempotencyKey: clientId,
      );
      if (result case Success<HerbariumEntry>(:final value)) {
        final merged = value.copyWith(
          mediaUrl: record.entry.mediaUrl,
          plantName: record.entry.plantName,
          scientificName: record.entry.scientificName,
          identificationResult: record.entry.identificationResult,
          latitude: record.entry.latitude,
          longitude: record.entry.longitude,
          accuracyMeters: record.entry.accuracyMeters,
        );
        await local.write(
          LocalObservationRecord(
            clientId: clientId,
            entry: merged,
            remoteId: value.id,
            remoteVersion: value.version,
          ),
        );
      }
    } else {
      result = await remote.updateEntry(
        id: record.remoteId!,
        note: record.entry.note,
        ifMatchVersion: record.remoteVersion!,
      );
      if (result case Success<HerbariumEntry>(:final value)) {
        final merged = value.copyWith(
          mediaUrl: record.entry.mediaUrl,
          plantName: record.entry.plantName,
          scientificName: record.entry.scientificName,
          identificationResult: record.entry.identificationResult,
          latitude: record.entry.latitude,
          longitude: record.entry.longitude,
          accuracyMeters: record.entry.accuracyMeters,
        );
        await local.write(
          LocalObservationRecord(
            clientId: clientId,
            entry: merged,
            remoteId: value.id,
            remoteVersion: value.version,
          ),
        );
      }
    }
    if (result.isFailure) {
      final failure = result.failureOrNull!;
      await local.write(
        record.copyWith(
          entry: record.entry.copyWith(
            syncStatus: failure is ConflictFailure
                ? SyncStatus.conflict
                : SyncStatus.pending,
            syncError: failure.message,
          ),
          syncError: failure.message,
        ),
      );
      return Result.failure(failure);
    }
    return const Result.success(null);
  }

  Future<LocalObservationRecord?> _findRecord(String id) async {
    for (final record in await local.readAll()) {
      if (record.clientId == id ||
          record.entry.id == id ||
          record.remoteId == id) {
        return record;
      }
    }
    return null;
  }
}

Map<String, Object?> _recordToJson(LocalObservationRecord record) => {
  'clientId': record.clientId,
  'remoteId': record.remoteId,
  'remoteVersion': record.remoteVersion,
  'syncError': record.syncError,
  'entry': _entryToJson(record.entry),
};

LocalObservationRecord _recordFromJson(Map<String, dynamic> value) =>
    LocalObservationRecord(
      clientId: value['clientId'] as String,
      remoteId: value['remoteId'] as String?,
      remoteVersion: value['remoteVersion'] as String?,
      syncError: value['syncError'] as String?,
      entry: _entryFromJson(value['entry'] as Map<String, dynamic>),
    );

Map<String, Object?> _entryToJson(HerbariumEntry entry) => {
  'id': entry.id,
  'clientObservationId': entry.clientObservationId,
  'observedAt': entry.observedAt.toUtc().toIso8601String(),
  'note': entry.note,
  'confirmedPlantId': entry.confirmedPlantId,
  'identificationJobId': entry.identificationJobId,
  'version': entry.version,
  'syncStatus': entry.syncStatus.name,
  'mediaUrl': entry.mediaUrl,
  'mediaId': entry.mediaId,
  'speciesKey': entry.speciesKey,
  'plantName': entry.plantName,
  'scientificName': entry.scientificName,
  'identificationResult': entry.identificationResult,
  'latitude': entry.latitude,
  'longitude': entry.longitude,
  'accuracyMeters': entry.accuracyMeters,
  'syncError': entry.syncError,
};

HerbariumEntry _entryFromJson(Map<String, dynamic> value) => HerbariumEntry(
  id: value['id'] as String,
  clientObservationId: value['clientObservationId'] as String?,
  observedAt: DateTime.parse(value['observedAt'] as String).toLocal(),
  note: value['note'] as String? ?? '',
  confirmedPlantId: value['confirmedPlantId'] as String?,
  identificationJobId: value['identificationJobId'] as String?,
  version: value['version'] as String,
  syncStatus: SyncStatus.values.byName(value['syncStatus'] as String),
  mediaUrl: value['mediaUrl'] as String?,
  mediaId: value['mediaId'] as String?,
  speciesKey: value['speciesKey'] as String?,
  plantName: value['plantName'] as String?,
  scientificName: value['scientificName'] as String?,
  identificationResult: value['identificationResult'] as String?,
  latitude: (value['latitude'] as num?)?.toDouble(),
  longitude: (value['longitude'] as num?)?.toDouble(),
  accuracyMeters: (value['accuracyMeters'] as num?)?.toDouble(),
  syncError: value['syncError'] as String?,
);
