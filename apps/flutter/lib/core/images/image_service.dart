import 'dart:typed_data';

import '../../adapters/http/platform_api_client.dart';
import '../errors/app_failure.dart';
import '../result.dart';
import 'image_disk_store.dart';

/// Loads every picture at most once per lifetime of the image.
///
/// Order: memory, disk, network. A photo whose URL names its id (`/media/…`,
/// `photoId=…`) never changes and is kept forever; other public URLs are
/// re-fetched after a week, matching the backend's weekly refresh, and the
/// stale copy is served when the network fails.
final class ImageService {
  ImageService({
    required this._api,
    ImageDiskStore? disk,
    DateTime Function()? now,
    this.memoryBudgetBytes = 48 * 1024 * 1024,
  }) : _disk = disk ?? createImageDiskStore(),
       _now = now ?? DateTime.now;

  /// Set once at bootstrap; widgets fall back to plain network images without.
  static ImageService? shared;

  static const refreshAfter = Duration(days: 7);

  final PlatformApiClient _api;
  final ImageDiskStore _disk;
  final DateTime Function() _now;
  final int memoryBudgetBytes;

  final _memory = <String, Uint8List>{};
  final _inFlight = <String, Future<Result<Uint8List>>>{};
  int _memoryBytes = 0;

  static bool isImmutable(String url) {
    final uri = Uri.tryParse(url);
    if (uri == null) return false;
    return uri.path.contains('/media/') ||
        uri.queryParameters.containsKey('photoId');
  }

  Uint8List? peek(String url) => _touch(url);

  Future<Result<Uint8List>> load(String url, {bool authenticated = false}) {
    final hit = _touch(url);
    if (hit != null) return Future.value(Result.success(hit));
    return _inFlight[url] ??= _fetch(url, authenticated).whenComplete(() {
      // A block body: returning the removed future would make it wait for itself.
      _inFlight.remove(url);
    });
  }

  Future<Result<Uint8List>> _fetch(String url, bool authenticated) async {
    final stored = await _disk.read(url);
    final fresh =
        stored != null &&
        (isImmutable(url) || _now().difference(stored.storedAt) < refreshAfter);
    if (fresh) {
      _remember(url, stored.bytes);
      return Result.success(stored.bytes);
    }
    final downloaded = await _api.getBytes(url, authenticated: authenticated);
    switch (downloaded) {
      case Success<Uint8List>(:final value):
        _remember(url, value);
        await _disk.write(url, value);
        return downloaded;
      case Failure<Uint8List>(:final failure):
        if (stored != null && failure is! NotFoundFailure) {
          _remember(url, stored.bytes);
          return Result.success(stored.bytes);
        }
        return downloaded;
    }
  }

  Uint8List? _touch(String url) {
    final bytes = _memory.remove(url);
    if (bytes != null) _memory[url] = bytes;
    return bytes;
  }

  void _remember(String url, Uint8List bytes) {
    final previous = _memory.remove(url);
    if (previous != null) _memoryBytes -= previous.length;
    _memory[url] = bytes;
    _memoryBytes += bytes.length;
    while (_memoryBytes > memoryBudgetBytes && _memory.length > 1) {
      final oldest = _memory.keys.first;
      _memoryBytes -= _memory.remove(oldest)!.length;
    }
  }
}
