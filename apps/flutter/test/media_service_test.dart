import 'dart:typed_data';

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:image/image.dart' as img;
import 'package:plantini_app/core/errors/app_failure.dart';
import 'package:plantini_app/core/result.dart';
import 'package:plantini_app/features/field/domain/field_repository.dart';
import 'package:plantini_app/features/field/infrastructure/media_service.dart';
import 'package:plantini_app/features/field/presentation/field_capture_screen.dart';
import 'package:plantini_app/features/herbarium/domain/herbarium_repository.dart';

final class _UnusedFieldRepository implements FieldRepository {
  @override
  dynamic noSuchMethod(Invocation invocation) => super.noSuchMethod(invocation);
}

final class _UnusedHerbariumRepository implements HerbariumRepository {
  @override
  dynamic noSuchMethod(Invocation invocation) => super.noSuchMethod(invocation);
}

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  late MediaService mediaService;

  setUp(() {
    mediaService = MediaService(
      defaultMaxBytes: 1024 * 1024, // 1 MB limit for tests
      defaultMaxDimension: 800,
    );
  });

  Uint8List createSampleJpg({int width = 100, int height = 100}) {
    final image = img.Image(width: width, height: height);
    img.fill(image, color: img.ColorRgb8(50, 150, 50));
    return Uint8List.fromList(img.encodeJpg(image));
  }

  Uint8List createSampleJpgWithLocation() {
    final image = img.Image(width: 100, height: 100);
    img.fill(image, color: img.ColorRgb8(50, 150, 50));
    image.exif.gpsIfd.setGpsLocation(latitude: 52.52, longitude: 13.405);
    return Uint8List.fromList(img.encodeJpg(image));
  }

  Uint8List createSamplePng({int width = 100, int height = 100}) {
    final image = img.Image(width: width, height: height);
    img.fill(image, color: img.ColorRgb8(100, 200, 100));
    return Uint8List.fromList(img.encodePng(image));
  }

  group('MediaService Magic Byte & Format Validation', () {
    test('detects JPEG format correctly from magic bytes', () {
      final jpgBytes = createSampleJpg();
      expect(MediaService.detectMimeType(jpgBytes), 'image/jpeg');
    });

    test('detects PNG format correctly from magic bytes', () {
      final pngBytes = createSamplePng();
      expect(MediaService.detectMimeType(pngBytes), 'image/png');
    });

    test('rejects arbitrary text or unknown formats', () {
      final dummyBytes = Uint8List.fromList([1, 2, 3, 4, 5, 6, 7, 8]);
      expect(MediaService.detectMimeType(dummyBytes), isNull);
    });

    test('rejects unsupported files with ValidationFailure and UnsupportedFormatException', () async {
      final dummyBytes = Uint8List.fromList([
        0x47,
        0x49,
        0x46,
        0x38,
        0x39,
        0x61,
      ]); // GIF header
      final result = await mediaService.processImageBytes(dummyBytes);

      expect(result, isA<Failure<ProcessedMedia>>());
      final failure = (result as Failure<ProcessedMedia>).failure;
      expect(failure, isA<ValidationFailure>());
      expect(failure.cause, isA<UnsupportedFormatException>());
      expect(failure.message, contains('Ungültiges Dateiformat'));
    });
  });

  group('MediaService Image Processing & Compression', () {
    test('processes valid JPEG image and strips location by default', () async {
      final jpgBytes = createSampleJpg(width: 200, height: 150);
      final result = await mediaService.processImageBytes(
        jpgBytes,
        originalFilename: 'leaf.jpeg',
        keepLocation: false,
      );

      expect(result, isA<Success<ProcessedMedia>>());
      final processed = (result as Success<ProcessedMedia>).value;

      expect(processed.mimeType, 'image/jpeg');
      expect(processed.filename, 'leaf.jpg');
      expect(processed.width, 200);
      expect(processed.height, 150);
      expect(processed.hadLocationMetadata, isFalse);
      expect(processed.hasStrippedLocation, isFalse);
      expect(processed.bytes.isNotEmpty, isTrue);
    });

    test('removes GPS EXIF when the user keeps the safe default', () async {
      final result = await mediaService.processImageBytes(
        createSampleJpgWithLocation(),
        keepLocation: false,
      );

      final processed = (result as Success<ProcessedMedia>).value;
      final decoded = img.decodeJpg(processed.bytes)!;
      expect(processed.hadLocationMetadata, isTrue);
      expect(processed.hasStrippedLocation, isTrue);
      expect(decoded.exif.imageIfd.sub.containsKey('gps'), isFalse);
    });

    test('retains GPS EXIF only after the user opts out of removal', () async {
      final result = await mediaService.processImageBytes(
        createSampleJpgWithLocation(),
        keepLocation: true,
      );

      final processed = (result as Success<ProcessedMedia>).value;
      final decoded = img.decodeJpg(processed.bytes)!;
      expect(processed.hadLocationMetadata, isTrue);
      expect(processed.hasStrippedLocation, isFalse);
      expect(decoded.exif.imageIfd.sub.containsKey('gps'), isTrue);
    });

    test('processes valid PNG image', () async {
      final pngBytes = createSamplePng(width: 80, height: 80);
      final result = await mediaService.processImageBytes(
        pngBytes,
        originalFilename: 'flower.png',
      );

      expect(result, isA<Success<ProcessedMedia>>());
      final processed = (result as Success<ProcessedMedia>).value;

      expect(processed.mimeType, 'image/png');
      expect(processed.filename, 'flower.png');
      expect(processed.width, 80);
      expect(processed.height, 80);
    });

    test('resizes oversized dimensions down to maxDimension preserving aspect ratio', () async {
      final largeJpg = createSampleJpg(width: 1600, height: 800);
      final result = await mediaService.processImageBytes(
        largeJpg,
        maxDimension: 800,
      );

      expect(result, isA<Success<ProcessedMedia>>());
      final processed = (result as Success<ProcessedMedia>).value;

      expect(processed.width, 800);
      expect(processed.height, 400);
    });

    test('rejects image that exceeds maximum byte size', () async {
      final jpgBytes = createSampleJpg(width: 100, height: 100);
      // Test with tiny 50 bytes threshold
      final result = await mediaService.processImageBytes(
        jpgBytes,
        maxBytes: 50,
      );

      expect(result, isA<Failure<ProcessedMedia>>());
      final failure = (result as Failure<ProcessedMedia>).failure;
      expect(failure, isA<ValidationFailure>());
      expect(failure.cause, isA<FileTooLargeException>());
    });
  });

  testWidgets('field capture exposes safe photo location choice', (
    tester,
  ) async {
    await tester.pumpWidget(
      MaterialApp(
        home: FieldCaptureScreen(
          fieldRepository: _UnusedFieldRepository(),
          herbariumRepository: _UnusedHerbariumRepository(),
        ),
      ),
    );

    final choice = find.byKey(const ValueKey('field-remove-photo-location'));
    expect(choice, findsOneWidget);
    expect(tester.widget<SwitchListTile>(choice).value, isTrue);

    await tester.tap(choice);
    await tester.pump();
    expect(tester.widget<SwitchListTile>(choice).value, isFalse);
  });
}
