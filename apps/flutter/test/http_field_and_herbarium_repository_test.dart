import 'package:dio/dio.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:plantini_app/adapters/http/platform_api_client.dart';
import 'package:plantini_app/app/app_config.dart';
import 'package:plantini_app/core/result.dart';
import 'package:plantini_app/features/field/infrastructure/http_field_repository.dart';
import 'package:plantini_app/features/herbarium/domain/herbarium_models.dart';
import 'package:plantini_app/features/herbarium/infrastructure/http_herbarium_repository.dart';

final class _QueuedApiInterceptor extends Interceptor {
  _QueuedApiInterceptor(this._responses);

  final List<_ApiResponse> _responses;
  final List<RequestOptions> requests = [];

  @override
  void onRequest(RequestOptions options, RequestInterceptorHandler handler) {
    requests.add(options);
    final response = _responses.removeAt(0);
    handler.resolve(
      Response<Object?>(
        requestOptions: options,
        data: response.body,
        statusCode: response.statusCode,
      ),
    );
  }
}

final class _ApiResponse {
  const _ApiResponse(this.statusCode, this.body);

  final int statusCode;
  final Object? body;
}

PlatformApiClient _client(_QueuedApiInterceptor interceptor) {
  final dio = Dio();
  dio.interceptors.add(interceptor);
  return PlatformApiClient(
    config: AppConfig.fromValues(
      environment: PlantiniEnvironment.development,
      apiBaseUrl: 'http://127.0.0.1:1338/api/v1',
      oidcIssuerUrl: 'http://127.0.0.1:8082/realms/plantini',
      oidcClientId: 'plantini-mobile-dev',
    ),
    dio: dio,
    accessTokenProvider: () async => 'test-access-token',
  );
}

void main() {
  group('HttpFieldRepository', () {
    test(
      'reserves, uploads, and maps an identification through v1 endpoints',
      () async {
        final interceptor = _QueuedApiInterceptor([
          const _ApiResponse(201, {
            'id': '11111111-1111-4111-8111-111111111111',
            'expiresAt': '2026-08-27T12:15:00.000Z',
            'status': 'reserved',
          }),
          const _ApiResponse(200, {
            'id': '11111111-1111-4111-8111-111111111111',
            'expiresAt': '2026-08-27T12:15:00.000Z',
            'status': 'uploaded',
          }),
          const _ApiResponse(202, {
            'id': '22222222-2222-4222-8222-222222222222',
            'status': 'identified',
            'createdAt': '2026-08-27T12:00:00.000Z',
            'attempts': 2,
            'providerMetadata': {
              'provider': 'plantnet',
              'modelVersion': '2026-test',
              'floraVersion': 'flora-test',
            },
            'expectedPlantId': '33333333-3333-4333-8333-333333333333',
            'expectedMatch': 'mismatch',
            'candidates': [
              {
                'candidateId': 'plantnet:gbif:2927079',
                'plantId': '33333333-3333-4333-8333-333333333333',
                'scientificName': 'Bellis perennis',
                'commonName': 'Gänseblümchen',
                'score': 0.94,
                'provider': 'plantnet-mock',
                'modelVersion': 'test-v1',
                'safetyNotice': 'Nicht verzehren; Verwechslungsgefahr.',
              },
            ],
          }),
          const _ApiResponse(200, {
            'id': '22222222-2222-4222-8222-222222222222',
            'status': 'identified',
            'createdAt': '2026-08-27T12:00:00.000Z',
            'confirmedCandidateId': 'plantnet:gbif:2927079',
            'candidates': [
              {
                'candidateId': 'plantnet:gbif:2927079',
                'scientificName': 'Bellis perennis',
                'commonName': 'Gänseblümchen',
                'score': 0.94,
                'provider': 'plantnet',
                'modelVersion': 'test-v1',
              },
            ],
          }),
          const _ApiResponse(202, {
            'id': '22222222-2222-4222-8222-222222222222',
            'status': 'pending',
            'createdAt': '2026-08-27T12:00:00.000Z',
            'attempts': 0,
          }),
        ]);
        final repository = HttpFieldRepository(_client(interceptor));

        final reserved = await repository.reserveMediaUpload(
          clientMediaId: 'aaaaaaaa-aaaa-4aaa-8aaa-aaaaaaaaaaaa',
          contentType: 'image/jpeg',
          bytes: 3,
          idempotencyKey: 'aaaaaaaa-aaaa-4aaa-8aaa-aaaaaaaaaaaa',
        );
        expect(reserved.isSuccess, isTrue);
        expect((reserved as Success).value.status, 'reserved');

        final uploaded = await repository.uploadMediaContent(
          mediaId: '11111111-1111-4111-8111-111111111111',
          bytes: const [0xff, 0xd8, 0xff],
          contentType: 'image/jpeg',
          filename: 'fund.jpg',
        );
        expect(uploaded.isSuccess, isTrue);
        expect((uploaded as Success).value.status, 'uploaded');

        final job = await repository.submitObservation(
          clientJobId: 'bbbbbbbb-bbbb-4bbb-8bbb-bbbbbbbbbbbb',
          mediaId: '11111111-1111-4111-8111-111111111111',
          idempotencyKey: 'bbbbbbbb-bbbb-4bbb-8bbb-bbbbbbbbbbbb',
        );
        expect(job.isSuccess, isTrue);
        final value = (job as Success).value;
        expect(value.candidates.single.commonName, 'Gänseblümchen');
        expect(value.candidates.single.candidateId, 'plantnet:gbif:2927079');
        expect(value.candidates.single.score, 0.94);
        expect(
          value.candidates.single.safetyNotice,
          'Nicht verzehren; Verwechslungsgefahr.',
        );
        expect(value.attempts, 2);
        expect(value.provider, 'plantnet');
        expect(value.modelVersion, '2026-test');
        expect(value.floraVersion, 'flora-test');
        expect(value.expectedMatch, 'mismatch');

        final confirmed = await repository.confirmIdentification(
          jobId: value.id,
          candidateId: value.candidates.single.candidateId,
          acceptMismatch: true,
        );
        expect(confirmed.isSuccess, isTrue);
        expect(
          (confirmed as Success).value.confirmedCandidateId,
          'plantnet:gbif:2927079',
        );

        expect(interceptor.requests.map((request) => request.path), [
          'media/uploads',
          'media/uploads/11111111-1111-4111-8111-111111111111/content',
          'identifications',
          'identifications/22222222-2222-4222-8222-222222222222/confirm',
        ]);
        expect(
          interceptor.requests.first.headers['Idempotency-Key'],
          'aaaaaaaa-aaaa-4aaa-8aaa-aaaaaaaaaaaa',
        );
        expect(
          interceptor.requests[1].headers.containsKey('Idempotency-Key'),
          isFalse,
        );
        expect(
          interceptor.requests.last.headers['Authorization'],
          'Bearer test-access-token',
        );
        expect(interceptor.requests.last.data, {
          'candidateId': 'plantnet:gbif:2927079',
          'acceptMismatch': true,
        });

        final retried = await repository.retryIdentification(
          jobId: value.id,
          idempotencyKey: 'cccccccc-cccc-4ccc-8ccc-cccccccccccc',
        );
        expect(retried.isSuccess, isTrue);
        expect((retried as Success).value.status, 'pending');
        expect(
          interceptor.requests.last.path,
          'identifications/${value.id}/retry',
        );
        expect(
          interceptor.requests.last.headers['Idempotency-Key'],
          'cccccccc-cccc-4ccc-8ccc-cccccccccccc',
        );
      },
    );
  });

  group('HttpHerbariumRepository', () {
    test('maps caller-owned observations and preserves optimistic concurrency headers', () async {
      const observation = {
        'id': '44444444-4444-4444-8444-444444444444',
        'observedAt': '2026-08-27T12:00:00.000Z',
        'note': 'An der Wiese',
        'version': '55555555-5555-4555-8555-555555555555',
        'syncStatus': 'synced',
        'identification': {
          'id': '22222222-2222-4222-8222-222222222222',
          'status': 'identified',
          'createdAt': '2026-08-27T12:00:00.000Z',
          'confirmedCandidateId': 'plantnet:gbif:2927079',
          'candidates': [
            {
              'candidateId': 'plantnet:gbif:2927079',
              'scientificName': 'Bellis perennis',
              'commonName': 'Gänseblümchen',
              'score': 0.94,
              'provider': 'plantnet-mock',
              'modelVersion': 'test-v1',
            },
          ],
        },
      };
      final updatedObservation = <String, Object?>{
        ...observation,
        'note': 'Neue Notiz',
        'version': '88888888-8888-4888-8888-888888888888',
      };
      final interceptor = _QueuedApiInterceptor([
        const _ApiResponse(200, {
          'items': [observation],
          'page': {},
        }),
        const _ApiResponse(201, observation),
        _ApiResponse(200, updatedObservation),
        const _ApiResponse(202, null),
      ]);
      final repository = HttpHerbariumRepository(_client(interceptor));

      final entries = await repository.listEntries();
      expect(entries.isSuccess, isTrue);
      final entry = (entries as Success<List>).value.single;
      expect(entry.plantName, 'Gänseblümchen');
      expect(entry.scientificName, 'Bellis perennis');
      expect(entry.confirmedPlantId, isNull);
      expect(entry.syncStatus, SyncStatus.synced);
      expect(entry.latitude, isNull);
      expect(entry.longitude, isNull);

      final created = await repository.createEntry(
        clientObservationId: '66666666-6666-4666-8666-666666666666',
        observedAt: DateTime.parse('2026-08-27T12:30:00.000Z'),
        identificationJobId: '22222222-2222-4222-8222-222222222222',
        latitude: 48.1,
        longitude: 11.5,
        accuracyMeters: 20,
        idempotencyKey: '77777777-7777-4777-8777-777777777777',
      );
      expect(created.isSuccess, isTrue);
      final requestBody = interceptor.requests[1].data as Map<String, Object?>;
      expect(requestBody['location'], {
        'latitude': 48.1,
        'longitude': 11.5,
        'accuracyMeters': 20,
      });
      expect(
        interceptor.requests[1].headers['Idempotency-Key'],
        '77777777-7777-4777-8777-777777777777',
      );

      final updated = await repository.updateEntry(
        id: '44444444-4444-4444-8444-444444444444',
        note: 'Neue Notiz',
        ifMatchVersion: '55555555-5555-4555-8555-555555555555',
      );
      expect(updated.valueOrNull?.note, 'Neue Notiz');
      expect(interceptor.requests[2].method, 'PATCH');
      expect(
        interceptor.requests[2].headers['If-Match'],
        '55555555-5555-4555-8555-555555555555',
      );

      final deleted = await repository.deleteEntry(
        id: '44444444-4444-4444-8444-444444444444',
        ifMatchVersion: '88888888-8888-4888-8888-888888888888',
      );
      expect(deleted.isSuccess, isTrue);
      expect(
        interceptor.requests.last.headers['If-Match'],
        '88888888-8888-4888-8888-888888888888',
      );
    });
  });
}
