import 'package:isar_plus/isar_plus.dart';

part 'isar_sync_queue.g.dart';

/// Processing lifecycle states for queued synchronization jobs.
enum SyncJobStatus { pending, running, failed, completed }

/// Persistent synchronization job stored in Isar for offline field observations and sync.
@collection
class IsarSyncJob {
  int id = 0;

  @Index(unique: true)
  late String clientId;

  late String payload;

  @Index()
  late SyncJobStatus status;

  int attemptCount = 0;

  @Index()
  DateTime? nextRetryAt;

  String? errorReason;

  late DateTime createdAt;

  DateTime? updatedAt;
}
