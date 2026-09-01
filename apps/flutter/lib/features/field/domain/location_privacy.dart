import 'field_models.dart';

/// Utility class for location privacy transformations.
abstract final class LocationPrivacy {
  /// Reduces location precision to approximately 1km resolution (~2 decimal places).
  /// This prevents exact location tracking while maintaining useful contextual area data.
  static ObservationLocation coarsen(ObservationLocation location) {
    final lat = (location.latitude * 100).round() / 100;
    final lng = (location.longitude * 100).round() / 100;

    return ObservationLocation(
      latitude: lat,
      longitude: lng,
      accuracyMeters: 1000.0,
    );
  }

  /// Completely strips the location.
  static ObservationLocation? omit() => null;
}
