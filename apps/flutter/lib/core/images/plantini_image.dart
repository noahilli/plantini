import 'dart:typed_data';

import 'package:flutter/material.dart';

import '../errors/app_failure.dart';
import '../result.dart';
import 'image_service.dart';

/// A network picture served through the app-wide [ImageService] cache.
///
/// [authenticated] is for the caller's own private media; those bytes are
/// downloaded with the bearer token, which a plain `Image.network` cannot send.
class PlantiniImage extends StatefulWidget {
  const PlantiniImage(
    this.url, {
    super.key,
    this.authenticated = false,
    this.fit = BoxFit.cover,
    this.decodeWidth,
    this.semanticLabel,
    this.placeholder,
    this.errorBuilder,
  });

  final String url;
  final bool authenticated;
  final BoxFit fit;

  /// Logical width the picture is shown at; limits the decoded size.
  final int? decodeWidth;
  final String? semanticLabel;
  final WidgetBuilder? placeholder;
  final Widget Function(BuildContext context, AppFailure? failure)?
  errorBuilder;

  @override
  State<PlantiniImage> createState() => _PlantiniImageState();
}

class _PlantiniImageState extends State<PlantiniImage> {
  Future<Result<Uint8List>>? _load;

  @override
  void initState() {
    super.initState();
    _start();
  }

  @override
  void didUpdateWidget(PlantiniImage old) {
    super.didUpdateWidget(old);
    if (old.url != widget.url || old.authenticated != widget.authenticated) {
      _start();
    }
  }

  void _start() {
    final service = ImageService.shared;
    _load = service?.load(widget.url, authenticated: widget.authenticated);
  }

  @override
  Widget build(BuildContext context) {
    final service = ImageService.shared;
    if (service == null) {
      return Image.network(
        widget.url,
        fit: widget.fit,
        semanticLabel: widget.semanticLabel,
        errorBuilder: (context, _, _) =>
            widget.errorBuilder?.call(context, null) ?? const SizedBox.shrink(),
      );
    }
    final ready = service.peek(widget.url);
    if (ready != null) return _image(ready);
    return FutureBuilder<Result<Uint8List>>(
      future: _load,
      builder: (context, snapshot) {
        final result = snapshot.data;
        if (result == null) {
          return widget.placeholder?.call(context) ??
              const Center(
                child: SizedBox(
                  width: 20,
                  height: 20,
                  child: CircularProgressIndicator(strokeWidth: 2),
                ),
              );
        }
        return switch (result) {
          Success<Uint8List>(:final value) => _image(value),
          Failure<Uint8List>(:final failure) =>
            widget.errorBuilder?.call(context, failure) ??
                const SizedBox.shrink(),
        };
      },
    );
  }

  Widget _image(Uint8List bytes) {
    final width = widget.decodeWidth;
    final pixelWidth = width == null
        ? null
        : (width * MediaQuery.devicePixelRatioOf(context)).round();
    return Image.memory(
      bytes,
      fit: widget.fit,
      cacheWidth: pixelWidth,
      gaplessPlayback: true,
      semanticLabel: widget.semanticLabel,
      errorBuilder: (context, _, _) =>
          widget.errorBuilder?.call(context, null) ?? const SizedBox.shrink(),
    );
  }
}
