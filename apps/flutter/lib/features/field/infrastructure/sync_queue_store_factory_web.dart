import '../application/sync_queue_service.dart';

Future<SyncQueueStore> createSyncQueueStore() async => InMemorySyncQueueStore();
