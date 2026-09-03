import 'package:shared_preferences/shared_preferences.dart';

import '../../../adapters/http/platform_api_client.dart';
import '../../../core/result.dart';
import '../../../core/storage/local_database.dart';
import '../application/content_sync_service.dart';

Future<ContentSyncService> createContentSyncService({
  required PlatformApiClient apiClient,
  required SharedPreferences preferences,
  LocalDatabase? localDatabase,
}) async {
  final database = localDatabase ?? await _openDatabase();
  return ContentSyncService(
    apiClient: apiClient,
    localDatabase: database,
    preferences: preferences,
  );
}

Future<LocalDatabase> _openDatabase() async {
  final result = await LocalDatabase.open();
  if (result case Failure<LocalDatabase>(:final failure)) throw failure;
  return result.valueOrNull!;
}
