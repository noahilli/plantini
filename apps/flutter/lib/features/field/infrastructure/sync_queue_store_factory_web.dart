import '../../../core/result.dart';
import '../../../core/storage/local_database.dart';
import '../application/sync_queue_service.dart';
import 'isar_sync_queue_store.dart';

Future<SyncQueueStore> createSyncQueueStore({
  LocalDatabase? localDatabase,
}) async {
  if (localDatabase != null) return IsarSyncQueueStore(localDatabase);
  final result = await LocalDatabase.open();
  if (result case Failure<LocalDatabase>(:final failure)) throw failure;
  return IsarSyncQueueStore(result.valueOrNull!);
}
