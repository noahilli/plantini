import 'dart:typed_data';

import 'package:dio/dio.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:plantini_app/adapters/http/platform_api_client.dart';
import 'package:plantini_app/app/app_config.dart';
import 'package:plantini_app/core/images/image_disk_store.dart';
import 'package:plantini_app/core/images/image_service.dart';
import 'package:plantini_app/core/result.dart';

final class _Adapter implements HttpClientAdapter {
  _Adapter(this.respond);

  final ResponseBody Function(RequestOptions options) respond;
  final requests = <RequestOptions>[];

  @override
  Future<ResponseBody> fetch(
    RequestOptions options,
    Stream<Uint8List>? requestStream,
    Future<void>? cancelFuture,
  ) async {
    requests.add(options);
    return respond(options);
  }

  @override
  void close({bool force = false}) {}
}

final class _MemoryDisk implements ImageDiskStore {
  final files = <String, StoredImage>{};

  @override
  Future<StoredImage?> read(String key) async => files[key];

  @override
  Future<void> write(String key, Uint8List bytes) async =>
      files[key] = StoredImage(bytes, DateTime.now());
}

PlatformApiClient _client(_Adapter adapter) {
  final dio = Dio(BaseOptions(baseUrl: 'https://api.example.test/api/v1'))
    ..httpClientAdapter = adapter;
  return PlatformApiClient(
    config: AppConfig(
      environment: PlantiniEnvironment.development,
      apiBaseUri: Uri.parse('https://api.example.test/api/v1'),
      oidcIssuerUri: Uri.parse('https://auth.example.test/realms/x'),
      oidcClientId: 'test',
    ),
    accessTokenProvider: () async => 'token',
    dio: dio,
  );
}

ResponseBody _bytes(List<int> data) => ResponseBody.fromBytes(data, 200);

void main() {
  test('a picture is downloaded once, concurrent requests share it', () async {
    final adapter = _Adapter((_) => _bytes([1, 2, 3]));
    final service = ImageService(api: _client(adapter), disk: _MemoryDisk());
    const url = '/api/v1/media/abc/content?width=320';

    final results = await Future.wait([
      service.load(url, authenticated: true),
      service.load(url, authenticated: true),
    ]);
    expect(results.every((result) => result.isSuccess), isTrue);
    expect(
      await service.load(url, authenticated: true),
      isA<Success<Uint8List>>(),
    );
    expect(adapter.requests, hasLength(1));
    expect(adapter.requests.single.headers['Authorization'], 'Bearer token');
    expect(service.peek(url), [1, 2, 3]);
  });

  test('a second app start reads the disk copy without the network', () async {
    final disk = _MemoryDisk();
    final first = _Adapter((_) => _bytes([9, 9]));
    await ImageService(api: _client(first), disk: disk).load('tiles/1/0/0');
    final second = _Adapter((_) => _bytes([0]));
    final result = await ImageService(
      api: _client(second),
      disk: disk,
    ).load('/api/v1/media/abc/content');
    expect(result.isSuccess, isTrue); // media is immutable: never refetched
    // A non-immutable URL younger than a week is also served from disk.
    final tile = await ImageService(
      api: _client(second),
      disk: disk,
    ).load('tiles/1/0/0');
    expect(tile.valueOrNull, [9, 9]);
    expect(second.requests.length, 1); // only the media that was never stored
  });

  test('a stale copy is served when the network fails', () async {
    final disk = _MemoryDisk()
      ..files['tiles/2/1/1'] = StoredImage(
        Uint8List.fromList([7]),
        DateTime.now().subtract(const Duration(days: 30)),
      );
    final adapter = _Adapter((_) => ResponseBody.fromString('', 503));
    final result = await ImageService(
      api: _client(adapter),
      disk: disk,
    ).load('tiles/2/1/1');
    expect(result.valueOrNull, [7]);
    expect(adapter.requests, hasLength(1));
  });
}
