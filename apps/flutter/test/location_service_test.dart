import 'package:flutter_test/flutter_test.dart';
import 'package:geolocator/geolocator.dart';
import 'package:plantini_app/features/field/infrastructure/location_service.dart';

final class MockLocationPlatformAdapter implements LocationPlatformAdapter {
  bool serviceEnabled = true;
  LocationPermission permission = LocationPermission.whileInUse;
  Position? positionToReturn;
  bool shouldThrow = false;

  @override
  Future<bool> isLocationServiceEnabled() async {
    if (shouldThrow) throw Exception('Hardware error');
    return serviceEnabled;
  }

  @override
  Future<LocationPermission> checkPermission() async {
    if (shouldThrow) throw Exception('Permission check error');
    return permission;
  }

  @override
  Future<LocationPermission> requestPermission() async {
    if (shouldThrow) throw Exception('Permission request error');
    return permission;
  }

  @override
  Future<Position?> getCurrentPosition() async {
    if (shouldThrow) throw Exception('GPS read error');
    return positionToReturn;
  }
}

Position _createPosition({
  required double latitude,
  required double longitude,
  double accuracy = 5.0,
  double altitude = 45.0,
}) => Position(
  latitude: latitude,
  longitude: longitude,
  timestamp: DateTime.parse('2026-08-26T14:30:00Z'),
  accuracy: accuracy,
  altitude: altitude,
  altitudeAccuracy: 1.0,
  heading: 0.0,
  headingAccuracy: 0.0,
  speed: 0.0,
  speedAccuracy: 0.0,
);

void main() {
  group('LocationService & LocationState', () {
    late MockLocationPlatformAdapter adapter;
    late LocationService service;

    setUp(() {
      adapter = MockLocationPlatformAdapter();
      service = LocationService(adapter: adapter);
    });

    test('initial state is unknown', () {
      expect(service.state, LocationState.unknown);
    });

    test('checkStatus returns disabled when location services are turned off', () async {
      adapter.serviceEnabled = false;

      final state = await service.checkStatus();
      expect(state, LocationState.disabled);
      expect(service.state, LocationState.disabled);
    });

    test('checkStatus returns denied when permission is denied', () async {
      adapter.serviceEnabled = true;
      adapter.permission = LocationPermission.denied;

      final state = await service.checkStatus();
      expect(state, LocationState.denied);
      expect(service.state, LocationState.denied);
    });

    test('checkStatus returns granted when permission is whileInUse or always', () async {
      adapter.serviceEnabled = true;
      adapter.permission = LocationPermission.whileInUse;

      final state = await service.checkStatus();
      expect(state, LocationState.granted);
      expect(service.state, LocationState.granted);
    });

    test('requestLocation transitions through requested to granted', () async {
      adapter.serviceEnabled = true;
      adapter.permission = LocationPermission.always;

      final state = await service.requestLocation();
      expect(state, LocationState.granted);
      expect(service.state, LocationState.granted);
    });

    test('requestLocation handles exceptions gracefully without crashing', () async {
      adapter.shouldThrow = true;

      final state = await service.requestLocation();
      expect(state, LocationState.denied);
      expect(service.state, LocationState.denied);
    });

    test('getCurrentLocation returns coordinates when permission is granted', () async {
      adapter.serviceEnabled = true;
      adapter.permission = LocationPermission.whileInUse;
      adapter.positionToReturn = _createPosition(
        latitude: 52.520008,
        longitude: 13.404954,
        accuracy: 4.2,
      );

      final result = await service.getCurrentLocation();
      expect(result.isSuccess, isTrue);
      final coords = result.valueOrNull;
      expect(coords, isNotNull);
      expect(coords!.latitude, 52.520008);
      expect(coords.longitude, 13.404954);
      expect(coords.accuracy, 4.2);
    });

    test('getCurrentLocation returns null fallback when permission is denied or GPS disabled', () async {
      adapter.serviceEnabled = false;

      final result = await service.getCurrentLocation();
      expect(result.isSuccess, isTrue);
      expect(result.valueOrNull, isNull);
    });

    test('getCurrentLocation handles unexpected adapter error with null fallback', () async {
      adapter.serviceEnabled = true;
      adapter.permission = LocationPermission.whileInUse;
      adapter.shouldThrow = true;

      final result = await service.getCurrentLocation();
      expect(result.isSuccess, isTrue);
      expect(result.valueOrNull, isNull);
    });

    test('getBlurredLocation intentionally coarsens coordinates for privacy', () async {
      adapter.serviceEnabled = true;
      adapter.permission = LocationPermission.whileInUse;
      adapter.positionToReturn = _createPosition(
        latitude: 52.523456,
        longitude: 13.409876,
      );

      // Default: 2 decimal places (~1.1 km)
      final result = await service.getBlurredLocation();
      expect(result.isSuccess, isTrue);
      final blurred = result.valueOrNull;
      expect(blurred, isNotNull);
      expect(blurred!.latitude, 52.52);
      expect(blurred.longitude, 13.41);

      // Custom precision: 1 decimal place
      final coarseResult = await service.getBlurredLocation(precisionDigits: 1);
      final coarse = coarseResult.valueOrNull;
      expect(coarse!.latitude, 52.5);
      expect(coarse.longitude, 13.4);
    });

    test('LocationCoordinates serialization and equality', () {
      final now = DateTime.parse('2026-08-26T14:30:00Z');
      final c1 = LocationCoordinates(
        latitude: 52.52,
        longitude: 13.40,
        accuracy: 5.0,
        timestamp: now,
      );
      final c2 = LocationCoordinates(
        latitude: 52.52,
        longitude: 13.40,
        accuracy: 10.0, // Different accuracy, same coordinates
      );

      expect(c1, equals(c2));
      expect(c1.hashCode, equals(c2.hashCode));

      final json = c1.toJson();
      expect(json['latitude'], 52.52);
      expect(json['longitude'], 13.40);
      expect(json['accuracy'], 5.0);
      expect(json['timestamp'], '2026-08-26T14:30:00.000Z');
    });
  });
}
