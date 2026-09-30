// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'observation_location.dart';

// **************************************************************************
// BuiltValueGenerator
// **************************************************************************

class _$ObservationLocation extends ObservationLocation {
  @override
  final num latitude;
  @override
  final num longitude;
  @override
  final num? accuracyMeters;

  factory _$ObservationLocation(
          [void Function(ObservationLocationBuilder)? updates]) =>
      (ObservationLocationBuilder()..update(updates))._build();

  _$ObservationLocation._(
      {required this.latitude, required this.longitude, this.accuracyMeters})
      : super._();
  @override
  ObservationLocation rebuild(
          void Function(ObservationLocationBuilder) updates) =>
      (toBuilder()..update(updates)).build();

  @override
  ObservationLocationBuilder toBuilder() =>
      ObservationLocationBuilder()..replace(this);

  @override
  bool operator ==(Object other) {
    if (identical(other, this)) return true;
    return other is ObservationLocation &&
        latitude == other.latitude &&
        longitude == other.longitude &&
        accuracyMeters == other.accuracyMeters;
  }

  @override
  int get hashCode {
    var _$hash = 0;
    _$hash = $jc(_$hash, latitude.hashCode);
    _$hash = $jc(_$hash, longitude.hashCode);
    _$hash = $jc(_$hash, accuracyMeters.hashCode);
    _$hash = $jf(_$hash);
    return _$hash;
  }

  @override
  String toString() {
    return (newBuiltValueToStringHelper(r'ObservationLocation')
          ..add('latitude', latitude)
          ..add('longitude', longitude)
          ..add('accuracyMeters', accuracyMeters))
        .toString();
  }
}

class ObservationLocationBuilder
    implements Builder<ObservationLocation, ObservationLocationBuilder> {
  _$ObservationLocation? _$v;

  num? _latitude;
  num? get latitude => _$this._latitude;
  set latitude(num? latitude) => _$this._latitude = latitude;

  num? _longitude;
  num? get longitude => _$this._longitude;
  set longitude(num? longitude) => _$this._longitude = longitude;

  num? _accuracyMeters;
  num? get accuracyMeters => _$this._accuracyMeters;
  set accuracyMeters(num? accuracyMeters) =>
      _$this._accuracyMeters = accuracyMeters;

  ObservationLocationBuilder() {
    ObservationLocation._defaults(this);
  }

  ObservationLocationBuilder get _$this {
    final $v = _$v;
    if ($v != null) {
      _latitude = $v.latitude;
      _longitude = $v.longitude;
      _accuracyMeters = $v.accuracyMeters;
      _$v = null;
    }
    return this;
  }

  @override
  void replace(ObservationLocation other) {
    _$v = other as _$ObservationLocation;
  }

  @override
  void update(void Function(ObservationLocationBuilder)? updates) {
    if (updates != null) updates(this);
  }

  @override
  ObservationLocation build() => _build();

  _$ObservationLocation _build() {
    final _$result = _$v ??
        _$ObservationLocation._(
          latitude: BuiltValueNullFieldError.checkNotNull(
              latitude, r'ObservationLocation', 'latitude'),
          longitude: BuiltValueNullFieldError.checkNotNull(
              longitude, r'ObservationLocation', 'longitude'),
          accuracyMeters: accuracyMeters,
        );
    replace(_$result);
    return _$result;
  }
}

// ignore_for_file: deprecated_member_use_from_same_package,type=lint
