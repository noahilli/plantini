import 'dart:typed_data';

import 'image_disk_store_base.dart';

export 'image_disk_store_base.dart';

/// The browser already keeps the (immutable) responses in its HTTP cache, so
/// the web build needs no second persistent copy.
ImageDiskStore createImageDiskStore() => _NoDiskStore();

final class _NoDiskStore implements ImageDiskStore {
  @override
  Future<StoredImage?> read(String key) async => null;

  @override
  Future<void> write(String key, Uint8List bytes) async {}
}
