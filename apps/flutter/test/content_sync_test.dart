import 'dart:convert';
import 'dart:typed_data';

import 'package:crypto/crypto.dart';
import 'package:dio/dio.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:plantini_app/adapters/http/platform_api_client.dart';
import 'package:plantini_app/app/app_config.dart';
import 'package:plantini_app/core/errors/app_failure.dart';
import 'package:plantini_app/core/result.dart';
import 'package:plantini_app/features/catalog/application/content_sync_service.dart';
import 'package:shared_preferences/shared_preferences.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  late AppConfig testConfig;

  setUp(() {
    testConfig = AppConfig.fromValues(
      environment: PlantiniEnvironment.development,
      apiBaseUrl: 'http://127.0.0.1:1338/api/v1',
      oidcIssuerUrl: 'http://127.0.0.1:8082/realms/plantini',
      oidcClientId: 'plantini-dev',
    );
  });

  String computeSha256(String content) {
    final bytes = utf8.encode(content);
    return sha256.convert(bytes).toString();
  }

  test('syncRelease downloads packages and validates SHA-256 checksums successfully', () async {
    SharedPreferences.setMockInitialValues({});
    final prefs = await SharedPreferences.getInstance();

    final ecosystemsJson = jsonEncode({
      'items': [
        {
          'id': 'eco-1',
          'slug': 'wald',
          'name': 'Laubwald',
          'description': 'Waldökosystem',
          'releaseVersion': '2026.08.25-1',
          'levelIds': ['lvl-1'],
        },
      ],
    });

    final levelsJson = jsonEncode({
      'items': [
        {
          'id': 'lvl-1',
          'ecosystemId': 'eco-1',
          'title': 'Bäume',
          'sequence': 1,
          'status': 'available',
          'completionRule': {
            'minimumScore': 0.8,
            'requiredQuizIds': ['q-1'],
          },
          'plantIds': ['plant-1'],
          'learningGoal': 'Baumarten erkennen',
        },
      ],
    });

    final plantsJson = jsonEncode({
      'items': [
        {
          'id': 'plant-1',
          'slug': 'rotbuche',
          'scientificName': 'Fagus sylvatica',
          'commonName': 'Rotbuche',
          'family': 'Buchengewächse',
          'description': 'Häufiger Laubbaum',
          'sources': ['Flora Helvetica'],
          'media': [
            {
              'id': 'm-1',
              'slug': 'rotbuche-habitus',
              'url': 'https://media.plantini.test/buche.jpg',
              'altText': 'Rotbuche im Sommer',
              'license': 'CC-BY-4.0',
            },
          ],
        },
      ],
    });

    final manifestData = {
      'version': '2026.08.25-1',
      'releasedAt': '2026-08-25T12:00:00Z',
      'schemaVersion': '1.0',
      'minimumAppVersion': '0.1.0',
      'packages': [
        {
          'id': 'ecosystems',
          'url': 'content/packages/ecosystems.json',
          'sha256': computeSha256(ecosystemsJson),
          'bytes': utf8.encode(ecosystemsJson).length,
        },
        {
          'id': 'levels',
          'url': 'content/packages/levels.json',
          'sha256': computeSha256(levelsJson),
          'bytes': utf8.encode(levelsJson).length,
        },
        {
          'id': 'plants',
          'url': 'content/packages/plants.json',
          'sha256': computeSha256(plantsJson),
          'bytes': utf8.encode(plantsJson).length,
        },
      ],
    };

    final dio = Dio();
    dio.interceptors.add(
      InterceptorsWrapper(
        onRequest: (options, handler) {
          if (options.path.contains('content/manifest')) {
            return handler.resolve(
              Response(
                requestOptions: options,
                statusCode: 200,
                data: manifestData,
              ),
            );
          }
          if (options.path.contains('ecosystems.json')) {
            return handler.resolve(
              Response(
                requestOptions: options,
                statusCode: 200,
                data: jsonDecode(ecosystemsJson),
              ),
            );
          }
          if (options.path.contains('levels.json')) {
            return handler.resolve(
              Response(
                requestOptions: options,
                statusCode: 200,
                data: jsonDecode(levelsJson),
              ),
            );
          }
          if (options.path.contains('plants.json')) {
            return handler.resolve(
              Response(
                requestOptions: options,
                statusCode: 200,
                data: jsonDecode(plantsJson),
              ),
            );
          }
          return handler.reject(
            DioException(
              requestOptions: options,
              type: DioExceptionType.badResponse,
              response: Response(requestOptions: options, statusCode: 404),
            ),
          );
        },
      ),
    );

    final apiClient = PlatformApiClient(
      config: testConfig,
      accessTokenProvider: () async => null,
      dio: dio,
    );

    final service = ContentSyncService(
      apiClient: apiClient,
      preferences: prefs,
      packageDownloader: (url) async {
        if (url.contains('ecosystems')) {
          return Result.success(
            Uint8List.fromList(utf8.encode(ecosystemsJson)),
          );
        }
        if (url.contains('levels')) {
          return Result.success(Uint8List.fromList(utf8.encode(levelsJson)));
        }
        if (url.contains('plants')) {
          return Result.success(Uint8List.fromList(utf8.encode(plantsJson)));
        }
        return const Result.failure(NotFoundFailure(message: 'Not found'));
      },
    );

    final result = await service.syncRelease();
    expect(result, isA<Success<ContentSyncResult>>());

    final summary = (result as Success<ContentSyncResult>).value;
    expect(summary.version, '2026.08.25-1');
    expect(summary.ecosystemCount, 1);
    expect(summary.levelCount, 1);
    expect(summary.plantCount, 1);
    expect(service.activeLocalVersion, '2026.08.25-1');
  });

  test('syncRelease aborts atomically when SHA-256 checksum fails', () async {
    SharedPreferences.setMockInitialValues({
      'plantini.content.active_version': '2026.08.20-old',
    });
    final prefs = await SharedPreferences.getInstance();

    final validJson = jsonEncode({'items': []});
    final corruptedJson = jsonEncode({
      'items': [
        {'id': 'tampered'},
      ],
    });

    final manifestData = {
      'version': '2026.08.25-2',
      'releasedAt': '2026-08-25T12:00:00Z',
      'schemaVersion': '1.0',
      'minimumAppVersion': '0.1.0',
      'packages': [
        {
          'id': 'ecosystems',
          'url': 'content/packages/ecosystems.json',
          'sha256': computeSha256(validJson), // Expected hash of validJson
          'bytes': 100,
        },
      ],
    };

    final dio = Dio();
    dio.interceptors.add(
      InterceptorsWrapper(
        onRequest: (options, handler) {
          if (options.path.contains('content/manifest')) {
            return handler.resolve(
              Response(
                requestOptions: options,
                statusCode: 200,
                data: manifestData,
              ),
            );
          }
          return handler.next(options);
        },
      ),
    );

    final apiClient = PlatformApiClient(
      config: testConfig,
      accessTokenProvider: () async => null,
      dio: dio,
    );

    final service = ContentSyncService(
      apiClient: apiClient,
      preferences: prefs,
      packageDownloader: (url) async {
        // Return tampered content whose checksum doesn't match manifest
        return Result.success(Uint8List.fromList(utf8.encode(corruptedJson)));
      },
    );

    final result = await service.syncRelease();
    expect(result, isA<Failure<ContentSyncResult>>());

    final failure = (result as Failure<ContentSyncResult>).failure;
    expect(failure, isA<ValidationFailure>());
    expect(failure.message, contains('Prüfsumme ungültig'));

    // Old active version must remain unchanged
    expect(service.activeLocalVersion, '2026.08.20-old');
  });

  test('syncRelease aborts when network fails', () async {
    SharedPreferences.setMockInitialValues({
      'plantini.content.active_version': '2026.08.20-old',
    });
    final prefs = await SharedPreferences.getInstance();

    final dio = Dio();
    dio.interceptors.add(
      InterceptorsWrapper(
        onRequest: (options, handler) {
          return handler.reject(
            DioException(
              requestOptions: options,
              type: DioExceptionType.connectionError,
              error: 'No internet',
            ),
          );
        },
      ),
    );

    final apiClient = PlatformApiClient(
      config: testConfig,
      accessTokenProvider: () async => null,
      dio: dio,
    );

    final service = ContentSyncService(
      apiClient: apiClient,
      preferences: prefs,
    );

    final result = await service.syncRelease();
    expect(result, isA<Failure<ContentSyncResult>>());
    expect(service.activeLocalVersion, '2026.08.20-old');
  });
}
