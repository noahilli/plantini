import 'package:shared_preferences/shared_preferences.dart';

import '../../../adapters/http/platform_api_client.dart';
import '../application/content_sync_service.dart';

Future<ContentSyncService> createContentSyncService({
  required PlatformApiClient apiClient,
  required SharedPreferences preferences,
}) async {
  return ContentSyncService(
    apiClient: apiClient,
    localDatabase: null,
    preferences: preferences,
  );
}
