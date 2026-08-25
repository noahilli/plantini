// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'plant.dart';

// **************************************************************************
// BuiltValueGenerator
// **************************************************************************

class _$Plant extends Plant {
  @override
  final String id;
  @override
  final String scientificName;
  @override
  final String? commonName;
  @override
  final String? family;
  @override
  final String? description;

  factory _$Plant([void Function(PlantBuilder)? updates]) =>
      (PlantBuilder()..update(updates))._build();

  _$Plant._(
      {required this.id,
      required this.scientificName,
      this.commonName,
      this.family,
      this.description})
      : super._();
  @override
  Plant rebuild(void Function(PlantBuilder) updates) =>
      (toBuilder()..update(updates)).build();

  @override
  PlantBuilder toBuilder() => PlantBuilder()..replace(this);

  @override
  bool operator ==(Object other) {
    if (identical(other, this)) return true;
    return other is Plant &&
        id == other.id &&
        scientificName == other.scientificName &&
        commonName == other.commonName &&
        family == other.family &&
        description == other.description;
  }

  @override
  int get hashCode {
    var _$hash = 0;
    _$hash = $jc(_$hash, id.hashCode);
    _$hash = $jc(_$hash, scientificName.hashCode);
    _$hash = $jc(_$hash, commonName.hashCode);
    _$hash = $jc(_$hash, family.hashCode);
    _$hash = $jc(_$hash, description.hashCode);
    _$hash = $jf(_$hash);
    return _$hash;
  }

  @override
  String toString() {
    return (newBuiltValueToStringHelper(r'Plant')
          ..add('id', id)
          ..add('scientificName', scientificName)
          ..add('commonName', commonName)
          ..add('family', family)
          ..add('description', description))
        .toString();
  }
}

class PlantBuilder implements Builder<Plant, PlantBuilder> {
  _$Plant? _$v;

  String? _id;
  String? get id => _$this._id;
  set id(String? id) => _$this._id = id;

  String? _scientificName;
  String? get scientificName => _$this._scientificName;
  set scientificName(String? scientificName) =>
      _$this._scientificName = scientificName;

  String? _commonName;
  String? get commonName => _$this._commonName;
  set commonName(String? commonName) => _$this._commonName = commonName;

  String? _family;
  String? get family => _$this._family;
  set family(String? family) => _$this._family = family;

  String? _description;
  String? get description => _$this._description;
  set description(String? description) => _$this._description = description;

  PlantBuilder() {
    Plant._defaults(this);
  }

  PlantBuilder get _$this {
    final $v = _$v;
    if ($v != null) {
      _id = $v.id;
      _scientificName = $v.scientificName;
      _commonName = $v.commonName;
      _family = $v.family;
      _description = $v.description;
      _$v = null;
    }
    return this;
  }

  @override
  void replace(Plant other) {
    _$v = other as _$Plant;
  }

  @override
  void update(void Function(PlantBuilder)? updates) {
    if (updates != null) updates(this);
  }

  @override
  Plant build() => _build();

  _$Plant _build() {
    final _$result = _$v ??
        _$Plant._(
          id: BuiltValueNullFieldError.checkNotNull(id, r'Plant', 'id'),
          scientificName: BuiltValueNullFieldError.checkNotNull(
              scientificName, r'Plant', 'scientificName'),
          commonName: commonName,
          family: family,
          description: description,
        );
    replace(_$result);
    return _$result;
  }
}

// ignore_for_file: deprecated_member_use_from_same_package,type=lint
