import 'dart:convert';
import 'dart:io';

import 'package:crypto/crypto.dart';
import 'package:flutter/foundation.dart';
import 'package:path_provider/path_provider.dart';

import 'image_disk_store_base.dart';

export 'image_disk_store_base.dart';

ImageDiskStore createImageDiskStore() => _FileImageDiskStore();

/// One file per image under the application support directory, so images
/// survive restarts and are not purged like the temporary cache.
final class _FileImageDiskStore implements ImageDiskStore {
  Future<Directory>? _directory;

  Future<Directory> _dir() => _directory ??= () async {
    final base = await getApplicationSupportDirectory();
    final dir = Directory('${base.path}/images');
    await dir.create(recursive: true);
    return dir;
  }();

  Future<File> _file(String key) async {
    final name = sha256.convert(utf8.encode(key)).toString();
    return File('${(await _dir()).path}/$name.img');
  }

  @override
  Future<StoredImage?> read(String key) async {
    try {
      final file = await _file(key);
      if (!await file.exists()) return null;
      return StoredImage(await file.readAsBytes(), await file.lastModified());
    } catch (error) {
      debugPrint('ImageDiskStore.read failed: $error');
      return null;
    }
  }

  @override
  Future<void> write(String key, Uint8List bytes) async {
    try {
      final file = await _file(key);
      final temp = File('${file.path}.tmp');
      await temp.writeAsBytes(bytes, flush: true);
      await temp.rename(file.path);
    } catch (error) {
      debugPrint('ImageDiskStore.write failed: $error');
    }
  }
}
