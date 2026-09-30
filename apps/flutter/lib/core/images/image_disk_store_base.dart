import 'dart:typed_data';

/// Persistent byte store for downloaded images, keyed by an opaque string.
abstract interface class ImageDiskStore {
  /// The stored bytes and when they were written, or null if absent.
  Future<StoredImage?> read(String key);

  Future<void> write(String key, Uint8List bytes);
}

final class StoredImage {
  const StoredImage(this.bytes, this.storedAt);

  final Uint8List bytes;
  final DateTime storedAt;
}
