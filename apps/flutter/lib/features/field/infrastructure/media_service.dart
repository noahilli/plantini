import 'dart:typed_data';

import 'package:image/image.dart' as img;
import 'package:image_picker/image_picker.dart';

import '../../../core/errors/app_failure.dart';
import '../../../core/result.dart';

/// Thrown when an uploaded or captured media file exceeds the maximum allowed byte size.
final class FileTooLargeException implements Exception {
  const FileTooLargeException({
    required this.actualBytes,
    required this.maxBytes,
  });

  final int actualBytes;
  final int maxBytes;

  @override
  String toString() =>
      'FileTooLargeException: File size ($actualBytes bytes) exceeds limit ($maxBytes bytes).';
}

/// Thrown when the media format / magic bytes are not supported (only JPEG & PNG allowed).
final class UnsupportedFormatException implements Exception {
  const UnsupportedFormatException({required this.message, this.detectedMime});

  final String message;
  final String? detectedMime;

  @override
  String toString() =>
      'UnsupportedFormatException: $message (detected: $detectedMime)';
}

/// Result of a processed media file ready for upload or local caching.
final class ProcessedMedia {
  const ProcessedMedia({
    required this.bytes,
    required this.filename,
    required this.mimeType,
    required this.width,
    required this.height,
    required this.sizeBytes,
    required this.hadLocationMetadata,
    required this.hasStrippedLocation,
  });

  final Uint8List bytes;
  final String filename;
  final String mimeType;
  final int width;
  final int height;
  final int sizeBytes;
  final bool hadLocationMetadata;
  final bool hasStrippedLocation;
}

/// Service providing safe image capture from camera/gallery,
/// magic-byte validation, resizing, compression, and EXIF/location stripping.
final class MediaService {
  MediaService({
    ImagePicker? picker,
    this.defaultMaxBytes = 10 * 1024 * 1024, // 10 MB
    this.defaultMaxDimension = 2048, // 2048 px max width/height
    this.defaultJpegQuality = 85,
  }) : _picker = picker ?? ImagePicker();

  final ImagePicker _picker;
  final int defaultMaxBytes;
  final int defaultMaxDimension;
  final int defaultJpegQuality;

  static const List<int> jpegMagic = [0xFF, 0xD8, 0xFF];
  static const List<int> pngMagic = [
    0x89,
    0x50,
    0x4E,
    0x47,
    0x0D,
    0x0A,
    0x1A,
    0x0A,
  ];

  /// Captures an image from the camera and processes it safely.
  Future<Result<ProcessedMedia>> captureFromCamera({
    bool keepLocation = false,
    int? maxBytes,
    int? maxDimension,
  }) async {
    try {
      final file = await _picker.pickImage(
        source: ImageSource.camera,
        imageQuality: 100, // We perform our own deterministic compression
      );
      if (file == null) {
        return const Result.failure(
          ValidationFailure(message: 'Fotoaufnahme abgebrochen.'),
        );
      }
      final rawBytes = await file.readAsBytes();
      return await processImageBytes(
        rawBytes,
        originalFilename: file.name,
        keepLocation: keepLocation,
        maxBytes: maxBytes,
        maxDimension: maxDimension,
      );
    } catch (error) {
      return Result.failure(
        ValidationFailure(
          message: 'Kamera-Aufnahme fehlgeschlagen: $error',
          cause: error,
        ),
      );
    }
  }

  /// Picks an image from the device gallery and processes it safely.
  Future<Result<ProcessedMedia>> pickFromGallery({
    bool keepLocation = false,
    int? maxBytes,
    int? maxDimension,
  }) async {
    try {
      final file = await _picker.pickImage(
        source: ImageSource.gallery,
        imageQuality: 100,
      );
      if (file == null) {
        return const Result.failure(
          ValidationFailure(message: 'Bildauswahl abgebrochen.'),
        );
      }
      final rawBytes = await file.readAsBytes();
      return await processImageBytes(
        rawBytes,
        originalFilename: file.name,
        keepLocation: keepLocation,
        maxBytes: maxBytes,
        maxDimension: maxDimension,
      );
    } catch (error) {
      return Result.failure(
        ValidationFailure(
          message: 'Galerie-Auswahl fehlgeschlagen: $error',
          cause: error,
        ),
      );
    }
  }

  /// Validates magic bytes, checks file size, resizes if needed, and strips EXIF location.
  Future<Result<ProcessedMedia>> processImageBytes(
    Uint8List rawBytes, {
    String? originalFilename,
    bool keepLocation = false,
    int? maxBytes,
    int? maxDimension,
  }) async {
    final effectiveMaxBytes = maxBytes ?? defaultMaxBytes;
    final effectiveMaxDimension = maxDimension ?? defaultMaxDimension;

    // 1. Initial size check
    if (rawBytes.length > effectiveMaxBytes * 2) {
      final ex = FileTooLargeException(
        actualBytes: rawBytes.length,
        maxBytes: effectiveMaxBytes,
      );
      return Result.failure(
        ValidationFailure(
          message:
              'Die Bilddatei ist mit ${(rawBytes.length / (1024 * 1024)).toStringAsFixed(1)} MB zu groß (Max: ${(effectiveMaxBytes / (1024 * 1024)).toStringAsFixed(1)} MB).',
          cause: ex,
        ),
      );
    }

    // 2. Format & Magic Byte Validation
    final mimeType = detectMimeType(rawBytes);
    if (mimeType == null) {
      const ex = UnsupportedFormatException(
        message: 'Nur JPEG- und PNG-Bilder werden unterstützt.',
      );
      return const Result.failure(
        ValidationFailure(
          message:
              'Ungültiges Dateiformat. Bitte wähle ein JPEG- oder PNG-Foto.',
          cause: ex,
        ),
      );
    }

    // 3. Decode image
    final decoded = img.decodeImage(rawBytes);
    if (decoded == null) {
      return const Result.failure(
        ValidationFailure(message: 'Das Bild konnte nicht dekodiert werden.'),
      );
    }

    final hadLocationMetadata =
        mimeType == 'image/jpeg' &&
        decoded.exif.imageIfd.sub.containsKey('gps');
    if (!keepLocation && hadLocationMetadata) {
      decoded.exif.imageIfd.sub.directories.remove('gps');
    }

    // 4. Resize if dimensions exceed maxDimension
    img.Image workingImage = decoded;
    if (workingImage.width > effectiveMaxDimension ||
        workingImage.height > effectiveMaxDimension) {
      if (workingImage.width >= workingImage.height) {
        workingImage = img.copyResize(
          workingImage,
          width: effectiveMaxDimension,
          interpolation: img.Interpolation.linear,
        );
      } else {
        workingImage = img.copyResize(
          workingImage,
          height: effectiveMaxDimension,
          interpolation: img.Interpolation.linear,
        );
      }
    }

    // 5. Re-encode image (stripping EXIF / location by default)
    Uint8List processedBytes;
    String targetExtension;
    String targetMime;

    if (mimeType == 'image/png') {
      processedBytes = Uint8List.fromList(img.encodePng(workingImage));
      targetExtension = 'png';
      targetMime = 'image/png';
    } else {
      processedBytes = Uint8List.fromList(
        img.encodeJpg(workingImage, quality: defaultJpegQuality),
      );
      targetExtension = 'jpg';
      targetMime = 'image/jpeg';
    }

    // 6. Post-compression size verification
    if (processedBytes.length > effectiveMaxBytes) {
      final ex = FileTooLargeException(
        actualBytes: processedBytes.length,
        maxBytes: effectiveMaxBytes,
      );
      return Result.failure(
        ValidationFailure(
          message:
              'Das Bild überschreitet nach der Kompression die Maximalgröße.',
          cause: ex,
        ),
      );
    }

    final sanitizedFilename =
        originalFilename != null && originalFilename.isNotEmpty
        ? '${originalFilename.split('.').first}.$targetExtension'
        : 'observation_${DateTime.now().millisecondsSinceEpoch}.$targetExtension';

    return Result.success(
      ProcessedMedia(
        bytes: processedBytes,
        filename: sanitizedFilename,
        mimeType: targetMime,
        width: workingImage.width,
        height: workingImage.height,
        sizeBytes: processedBytes.length,
        hadLocationMetadata: hadLocationMetadata,
        hasStrippedLocation: hadLocationMetadata && !keepLocation,
      ),
    );
  }

  /// Detects MIME type by checking the magic byte header.
  static String? detectMimeType(Uint8List bytes) {
    if (bytes.length >= 3 &&
        bytes[0] == jpegMagic[0] &&
        bytes[1] == jpegMagic[1] &&
        bytes[2] == jpegMagic[2]) {
      return 'image/jpeg';
    }

    if (bytes.length >= 8 &&
        bytes[0] == pngMagic[0] &&
        bytes[1] == pngMagic[1] &&
        bytes[2] == pngMagic[2] &&
        bytes[3] == pngMagic[3] &&
        bytes[4] == pngMagic[4] &&
        bytes[5] == pngMagic[5] &&
        bytes[6] == pngMagic[6] &&
        bytes[7] == pngMagic[7]) {
      return 'image/png';
    }

    return null;
  }
}
