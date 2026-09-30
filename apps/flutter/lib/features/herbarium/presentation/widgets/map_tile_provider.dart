import 'dart:async';
import 'dart:typed_data';
import 'dart:ui' as ui;

import 'package:flutter/foundation.dart' show SynchronousFuture;
import 'package:flutter/painting.dart';
import 'package:flutter_map/flutter_map.dart';

import '../../../../core/images/image_service.dart';
import '../../../../core/result.dart';

/// Loads map tiles from the Plantini API (which caches the OpenStreetMap
/// tiles), through the app-wide [ImageService]: a tile is downloaded once, is
/// kept on disk and is never requested from the tile provider by the device.
final class PlantiniTileProvider extends TileProvider {
  PlantiniTileProvider(this.images);

  final ImageService images;

  @override
  ImageProvider getImage(TileCoordinates coordinates, TileLayer options) =>
      _TileImage(
        images,
        'tiles/${coordinates.z}/${coordinates.x}/${coordinates.y}',
      );
}

final class _TileImage extends ImageProvider<_TileImage> {
  const _TileImage(this.images, this.path);

  final ImageService images;
  final String path;

  @override
  Future<_TileImage> obtainKey(ImageConfiguration configuration) =>
      SynchronousFuture(this);

  @override
  ImageStreamCompleter loadImage(_TileImage key, ImageDecoderCallback decode) =>
      MultiFrameImageStreamCompleter(
        codec: _load(decode),
        scale: 1,
        debugLabel: path,
      );

  Future<ui.Codec> _load(ImageDecoderCallback decode) async {
    final result = await images.load(path, authenticated: true);
    switch (result) {
      case Success<Uint8List>(:final value):
        return decode(await ui.ImmutableBuffer.fromUint8List(value));
      case Failure<Uint8List>(:final failure):
        throw failure;
    }
  }

  @override
  bool operator ==(Object other) =>
      other is _TileImage && other.path == path && other.images == images;

  @override
  int get hashCode => Object.hash(path, images);
}
