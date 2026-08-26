import 'dart:math';

import 'package:flutter/foundation.dart';
import 'package:geolocator/geolocator.dart';

import '../../../core/result.dart';

/// States representing the user's location permission and device capability status.
enum LocationState {
  /// Initial state before any permission check or request.
  unknown,

  /// Permission request is actively in progress.
  requested,

  /// Location permission granted and service is active.
  granted,

  /// Location permission was denied by the user.
  denied,

  /// Location permission is restricted (e.g. parental controls or system policy).
  restricted,

  /// Location services (GPS / hardware) are disabled on the device.
  disabled,
}

/// Geographic coordinates data transfer object with privacy helper methods.
final class LocationCoordinates {
  const LocationCoordinates({
    required this.latitude,
    required this.longitude,
    this.accuracy,
    this.altitude,
    this.timestamp,
  });

  final double latitude;
  final double longitude;
  final double? accuracy;
  final double? altitude;
  final DateTime? timestamp;

  /// Returns blurred coordinates rounded to [precisionDigits] decimal places (~1.1 km for 2 digits).
  LocationCoordinates blurred([int precisionDigits = 2]) {
    final factor = pow(10, precisionDigits);
    final blurredLat = (latitude * factor).round() / factor;
    final blurredLng = (longitude * factor).round() / factor;
    return LocationCoordinates(
      latitude: blurredLat,
      longitude: blurredLng,
      accuracy:
          accuracy != null ? (accuracy! * factor).round() / factor : null,
      altitude:
          altitude != null ? (altitude! * factor).round() / factor : null,
      timestamp: timestamp,
    );
  }

  Map<String, dynamic> toJson() => {
    'latitude': latitude,
    'longitude': longitude,
    if (accuracy != null) 'accuracy': accuracy,
    if (altitude != null) 'altitude': altitude,
    if (timestamp != null) 'timestamp': timestamp!.toIso8601String(),
  };

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is LocationCoordinates &&
          runtimeType == other.runtimeType &&
          latitude == other.latitude &&
          longitude == other.longitude;

  @override
  int get hashCode => latitude.hashCode ^ longitude.hashCode;

  @override
  String toString() =>
      'LocationCoordinates(lat: $latitude, lng: $longitude)';
}

/// Platform abstraction for geolocator calls to allow comprehensive testability.
abstract interface class LocationPlatformAdapter {
  Future<bool> isLocationServiceEnabled();
  Future<LocationPermission> checkPermission();
  Future<LocationPermission> requestPermission();
  Future<Position?> getCurrentPosition();
}

/// Default implementation using the real [Geolocator] plugin.
final class GeolocatorPlatformAdapter implements LocationPlatformAdapter {
  const GeolocatorPlatformAdapter();

  @override
  Future<bool> isLocationServiceEnabled() =>
      Geolocator.isLocationServiceEnabled();

  @override
  Future<LocationPermission> checkPermission() =>
      Geolocator.checkPermission();

  @override
  Future<LocationPermission> requestPermission() =>
      Geolocator.requestPermission();

  @override
  Future<Position?> getCurrentPosition() async {
    try {
      return await Geolocator.getCurrentPosition(
        locationSettings: const LocationSettings(
          accuracy: LocationAccuracy.medium,
          timeLimit: Duration(seconds: 10),
        ),
      );
    } catch (error) {
      debugPrint(
        'GeolocatorPlatformAdapter: Failed to acquire position: $error',
      );
      return null;
    }
  }
}

/// Resilient service managing location permissions, coordinate acquisition,
/// privacy blurring, and graceful offline fallbacks.
final class LocationService {
  LocationService({
    LocationPlatformAdapter? adapter,
  }) : _adapter = adapter ?? const GeolocatorPlatformAdapter();

  final LocationPlatformAdapter _adapter;
  LocationState _state = LocationState.unknown;

  /// Current state of the location permission and service.
  LocationState get state => _state;

  /// Determines the current location state by checking permissions and device capabilities.
  Future<LocationState> checkStatus() async {
    try {
      final serviceEnabled = await _adapter.isLocationServiceEnabled();
      if (!serviceEnabled) {
        _state = LocationState.disabled;
        return _state;
      }

      final permission = await _adapter.checkPermission();
      _state = _mapPermissionToState(permission);
      return _state;
    } catch (error) {
      debugPrint('LocationService: Error checking status: $error');
      _state = LocationState.denied;
      return _state;
    }
  }

  /// Explicitly requests location permission from the user.
  Future<LocationState> requestLocation() async {
    _state = LocationState.requested;
    try {
      final serviceEnabled = await _adapter.isLocationServiceEnabled();
      if (!serviceEnabled) {
        _state = LocationState.disabled;
        return _state;
      }

      final permission = await _adapter.requestPermission();
      _state = _mapPermissionToState(permission);
      return _state;
    } catch (error) {
      debugPrint('LocationService: Error requesting location: $error');
      _state = LocationState.denied;
      return _state;
    }
  }

  /// Retrieves the current exact location coordinates.
  /// If location is disabled or permission is not granted, returns `Result.success(null)`.
  Future<Result<LocationCoordinates?>> getCurrentLocation() async {
    try {
      final status = await checkStatus();
      if (status != LocationState.granted) {
        return const Result.success(null);
      }

      final position = await _adapter.getCurrentPosition();
      if (position == null) {
        return const Result.success(null);
      }

      return Result.success(
        LocationCoordinates(
          latitude: position.latitude,
          longitude: position.longitude,
          accuracy: position.accuracy,
          altitude: position.altitude,
          timestamp: position.timestamp,
        ),
      );
    } catch (error) {
      debugPrint('LocationService: Error retrieving position: $error');
      return const Result.success(null);
    }
  }

  /// Retrieves coordinates blurred to [precisionDigits] decimal places for privacy opt-in.
  /// If permission is denied or GPS is disabled, returns `Result.success(null)`.
  Future<Result<LocationCoordinates?>> getBlurredLocation({
    int precisionDigits = 2,
  }) async {
    final result = await getCurrentLocation();
    if (result.isSuccess) {
      final exact = result.valueOrNull;
      if (exact != null) {
        return Result.success(exact.blurred(precisionDigits));
      }
      return const Result.success(null);
    }
    return const Result.success(null);
  }

  LocationState _mapPermissionToState(LocationPermission permission) =>
      switch (permission) {
        LocationPermission.always ||
        LocationPermission.whileInUse =>
          LocationState.granted,
        LocationPermission.denied ||
        LocationPermission.deniedForever =>
          LocationState.denied,
        LocationPermission.unableToDetermine => LocationState.unknown,
      };
}
