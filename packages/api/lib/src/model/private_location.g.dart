// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'private_location.dart';

// **************************************************************************
// BuiltValueGenerator
// **************************************************************************

class _$PrivateLocation extends PrivateLocation {
  @override
  final num latitude;
  @override
  final num longitude;
  @override
  final num accuracyMeters;

  factory _$PrivateLocation([void Function(PrivateLocationBuilder)? updates]) =>
      (PrivateLocationBuilder()..update(updates))._build();

  _$PrivateLocation._(
      {required this.latitude,
      required this.longitude,
      required this.accuracyMeters})
      : super._();
  @override
  PrivateLocation rebuild(void Function(PrivateLocationBuilder) updates) =>
      (toBuilder()..update(updates)).build();

  @override
  PrivateLocationBuilder toBuilder() => PrivateLocationBuilder()..replace(this);

  @override
  bool operator ==(Object other) {
    if (identical(other, this)) return true;
    return other is PrivateLocation &&
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
    return (newBuiltValueToStringHelper(r'PrivateLocation')
          ..add('latitude', latitude)
          ..add('longitude', longitude)
          ..add('accuracyMeters', accuracyMeters))
        .toString();
  }
}

class PrivateLocationBuilder
    implements Builder<PrivateLocation, PrivateLocationBuilder> {
  _$PrivateLocation? _$v;

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

  PrivateLocationBuilder() {
    PrivateLocation._defaults(this);
  }

  PrivateLocationBuilder get _$this {
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
  void replace(PrivateLocation other) {
    _$v = other as _$PrivateLocation;
  }

  @override
  void update(void Function(PrivateLocationBuilder)? updates) {
    if (updates != null) updates(this);
  }

  @override
  PrivateLocation build() => _build();

  _$PrivateLocation _build() {
    final _$result = _$v ??
        _$PrivateLocation._(
          latitude: BuiltValueNullFieldError.checkNotNull(
              latitude, r'PrivateLocation', 'latitude'),
          longitude: BuiltValueNullFieldError.checkNotNull(
              longitude, r'PrivateLocation', 'longitude'),
          accuracyMeters: BuiltValueNullFieldError.checkNotNull(
              accuracyMeters, r'PrivateLocation', 'accuracyMeters'),
        );
    replace(_$result);
    return _$result;
  }
}

// ignore_for_file: deprecated_member_use_from_same_package,type=lint
