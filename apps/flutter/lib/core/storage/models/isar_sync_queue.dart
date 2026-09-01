import 'package:isar/isar.dart';

part 'isar_sync_queue.g.dart';

/// Processing lifecycle states for queued synchronization jobs.
enum SyncJobStatus { pending, running, failed, completed }

/// Persistent synchronization job stored in Isar for offline field observations and sync.
@collection
class IsarSyncJob {
  Id id = Isar.autoIncrement;

  @Index(unique: true, replace: true)
  late String clientId;

  late String payload;

  @Enumerated(EnumType.name)
  @Index()
  late SyncJobStatus status;

  int attemptCount = 0;

  @Index()
  DateTime? nextRetryAt;

  String? errorReason;

  late DateTime createdAt;

  DateTime? updatedAt;
}
