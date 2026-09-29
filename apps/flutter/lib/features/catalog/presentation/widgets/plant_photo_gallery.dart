import 'dart:ui' as ui;

import 'package:flutter/material.dart';

import '../../../../core/theme/app_colors.dart';
import '../../domain/plant_model.dart';

/// Uncropped botanical photos, with an adaptive matte and intact attribution.
final class PlantPhotoGallery extends StatefulWidget {
  const PlantPhotoGallery({
    super.key,
    required this.plant,
    this.background = const Color(0xFFE6E9DB),
    this.onPalette,
  });
  final Plant plant;
  final Color background;
  final ValueChanged<Color>? onPalette;
  @override
  State<PlantPhotoGallery> createState() => _PlantPhotoGalleryState();
}

final class _PlantPhotoGalleryState extends State<PlantPhotoGallery> {
  static final _paletteCache = <String, Color>{};
  int _selected = 0;
  int _generation = 0;
  ImageStream? _stream;
  ImageStreamListener? _listener;
  String? _sampledUrl;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    _sample();
  }

  @override
  void didUpdateWidget(covariant PlantPhotoGallery oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.plant != widget.plant) {
      _selected = 0;
      _sample();
    }
  }

  void _detach() {
    if (_listener != null) _stream?.removeListener(_listener!);
    _stream = null;
    _listener = null;
  }

  void _sample() {
    final media = widget.plant.media;
    final url = media.isEmpty ? null : media[_selected].url;
    if (_sampledUrl == url) return;
    _sampledUrl = url;
    final generation = ++_generation;
    _detach();
    if (url == null || widget.onPalette == null) return;
    void publish(Color color) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (mounted && generation == _generation) widget.onPalette?.call(color);
      });
    }

    final cached = _paletteCache[url];
    if (cached != null) {
      publish(cached);
      return;
    }
    _stream = ResizeImage(
      NetworkImage(url),
      width: 32,
      height: 32,
    ).resolve(createLocalImageConfiguration(context));
    _listener = ImageStreamListener((info, _) async {
      // Own a clone across the async read; never dispose the image cache's copy.
      final image = info.image.clone();
      info.dispose();
      try {
        final bytes = await image.toByteData(
          format: ui.ImageByteFormat.rawRgba,
        );
        if (bytes == null || !mounted || generation != _generation) return;
        double r = 0, g = 0, b = 0, weight = 0;
        for (var i = 0; i < bytes.lengthInBytes; i += 4) {
          if (bytes.getUint8(i + 3) < 128) continue;
          final red = bytes.getUint8(i),
              green = bytes.getUint8(i + 1),
              blue = bytes.getUint8(i + 2);
          final hsv = HSVColor.fromColor(Color.fromARGB(255, red, green, blue));
          if (hsv.value < .12 || hsv.value > .94 && hsv.saturation < .12) {
            continue;
          }
          final w = .1 + hsv.saturation;
          r += red * w;
          g += green * w;
          b += blue * w;
          weight += w;
        }
        if (weight == 0) return;
        final color = Color.fromARGB(
          255,
          (r / weight).round(),
          (g / weight).round(),
          (b / weight).round(),
        );
        if (_paletteCache.length >= 64) {
          _paletteCache.remove(_paletteCache.keys.first);
        }
        _paletteCache[url] = color;
        publish(color);
      } catch (_) {
        // Decorative colour sampling may fail (offline/CORS); never hide content.
      } finally {
        image.dispose();
      }
    }, onError: (Object _, StackTrace? _) {});
    _stream!.addListener(_listener!);
  }

  @override
  void dispose() {
    _generation++;
    _detach();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final media = widget.plant.media;
    if (media.isEmpty) return _unavailable('Noch kein Pflanzenfoto vorhanden');
    final photo = media[_selected];
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Container(
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: [
                Color.lerp(widget.background, Colors.white, .45)!,
                widget.background,
              ],
            ),
            borderRadius: BorderRadius.circular(24),
            border: Border.all(
              color: Colors.white.withValues(alpha: .85),
              width: 2,
            ),
          ),
          child: Column(
            children: [
              ClipRRect(
                borderRadius: BorderRadius.circular(17),
                child: AspectRatio(
                  aspectRatio: 1.15,
                  child: Stack(
                    fit: StackFit.expand,
                    children: [
                      // Fit.contain intentionally preserves leaves, stems and margins.
                      Center(
                        child: ClipRRect(
                          borderRadius: BorderRadius.circular(14),
                          child: Image.network(
                            photo.url,
                            fit: BoxFit.contain,
                            semanticLabel: photo.altText,
                            loadingBuilder: (context, child, progress) =>
                                progress == null
                                ? child
                                : const Center(
                                    child: CircularProgressIndicator(
                                      strokeWidth: 2,
                                    ),
                                  ),
                            errorBuilder: (_, _, _) => _unavailable(
                              'Foto momentan nicht verfügbar',
                              compact: true,
                            ),
                          ),
                        ),
                      ),
                      Positioned(
                        right: 6,
                        bottom: 6,
                        child: IconButton.filledTonal(
                          tooltip: 'Foto vergrößern',
                          onPressed: () => _enlarge(photo),
                          icon: const Icon(
                            Icons.open_in_full_rounded,
                            size: 18,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 12),
              Row(
                children: [
                  const Icon(
                    Icons.filter_vintage_outlined,
                    size: 16,
                    color: AppColors.sage800,
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      'BOTANISCHE ANSICHT',
                      style: const TextStyle(
                        fontSize: 10,
                        fontWeight: FontWeight.w800,
                        letterSpacing: 1.2,
                        color: AppColors.sage800,
                      ),
                    ),
                  ),
                  Text(
                    '${_selected + 1} / ${media.length}',
                    style: const TextStyle(color: AppColors.sage800),
                  ),
                ],
              ),
            ],
          ),
        ),
        if (media.length > 1) ...[
          const SizedBox(height: 12),
          SizedBox(
            height: 64,
            child: ListView.separated(
              scrollDirection: Axis.horizontal,
              itemCount: media.length,
              separatorBuilder: (_, _) => const SizedBox(width: 8),
              itemBuilder: (context, i) => Semantics(
                selected: i == _selected,
                child: Tooltip(
                  message: media[i].altText,
                  child: OutlinedButton(
                    onPressed: () {
                      setState(() => _selected = i);
                      _sample();
                    },
                    style: OutlinedButton.styleFrom(
                      padding: const EdgeInsets.all(4),
                      minimumSize: const Size(64, 64),
                      side: BorderSide(
                        color: i == _selected
                            ? AppColors.sage800
                            : AppColors.sage300,
                        width: i == _selected ? 2 : 1,
                      ),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                    child: ClipRRect(
                      borderRadius: BorderRadius.circular(8),
                      child: Image.network(
                        media[i].url,
                        width: 52,
                        height: 52,
                        fit: BoxFit.cover,
                        semanticLabel: 'Bild ${i + 1}: ${media[i].altText}',
                        errorBuilder: (_, _, _) =>
                            const Icon(Icons.image_not_supported_outlined),
                      ),
                    ),
                  ),
                ),
              ),
            ),
          ),
        ],
        const SizedBox(height: 12),
        Text(
          photo.altText,
          style: const TextStyle(
            fontSize: 12,
            height: 1.5,
            color: AppColors.sage800,
          ),
        ),
        if (photo.automatic) ...[
          const SizedBox(height: 8),
          const Text(
            'Automatisch zugeordnet · botanisch nicht redaktionell geprüft',
            style: TextStyle(
              fontSize: 11,
              color: Color(0xFF795126),
              height: 1.5,
            ),
          ),
        ],
        const SizedBox(height: 6),
        SelectableText(
          [
            if (photo.author?.isNotEmpty == true) photo.author!,
            photo.license,
          ].join(' · '),
          style: const TextStyle(
            fontSize: 11,
            height: 1.5,
            color: AppColors.sage700,
          ),
        ),
        Theme(
          data: Theme.of(context).copyWith(dividerColor: Colors.transparent),
          child: ExpansionTile(
            tilePadding: EdgeInsets.zero,
            dense: true,
            title: const Text(
              'Bildquelle & Lizenz',
              style: TextStyle(fontSize: 12),
            ),
            children: [
              for (final link in [photo.source, photo.licenseUrl])
                if (link?.isNotEmpty == true)
                  Align(
                    alignment: Alignment.centerLeft,
                    child: Padding(
                      padding: const EdgeInsets.only(bottom: 8),
                      child: SelectableText(
                        link!,
                        style: const TextStyle(fontSize: 11),
                      ),
                    ),
                  ),
            ],
          ),
        ),
      ],
    );
  }

  void _enlarge(PlantMedia photo) => showDialog<void>(
    context: context,
    builder: (context) => Dialog(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Row(
            children: [
              const SizedBox(width: 16),
              const Expanded(child: Text('Pflanzenfoto')),
              IconButton(
                tooltip: 'Schließen',
                onPressed: () => Navigator.pop(context),
                icon: const Icon(Icons.close),
              ),
            ],
          ),
          Flexible(
            child: InteractiveViewer(
              minScale: .8,
              maxScale: 5,
              child: Image.network(
                photo.url,
                fit: BoxFit.contain,
                semanticLabel: photo.altText,
                errorBuilder: (_, _, _) =>
                    _unavailable('Foto momentan nicht verfügbar'),
              ),
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(16),
            child: Text(photo.altText),
          ),
        ],
      ),
    ),
  );

  Widget _unavailable(String message, {bool compact = false}) => Container(
    padding: EdgeInsets.all(compact ? 12 : 24),
    decoration: BoxDecoration(
      color: widget.background,
      borderRadius: BorderRadius.circular(22),
    ),
    child: Column(
      mainAxisSize: MainAxisSize.min,
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Icon(
          Icons.local_florist_outlined,
          size: compact ? 32 : 64,
          color: AppColors.sage700,
        ),
        const SizedBox(height: 12),
        Text(message, textAlign: TextAlign.center),
        if (!compact) ...[
          const SizedBox(height: 8),
          const Text(
            'Deine Merkmalsnotizen sind trotzdem verfügbar.',
            textAlign: TextAlign.center,
            style: TextStyle(fontSize: 12),
          ),
        ],
      ],
    ),
  );
}
