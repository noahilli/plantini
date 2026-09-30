// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'collection_stats.dart';

// **************************************************************************
// BuiltValueGenerator
// **************************************************************************

class _$CollectionStats extends CollectionStats {
  @override
  final bool available;
  @override
  final String? reason;
  @override
  final DateTime generatedAt;
  @override
  final BuiltMap<String, CollectionShare> plants;
  @override
  final BuiltMap<String, CollectionShare> species;

  factory _$CollectionStats([void Function(CollectionStatsBuilder)? updates]) =>
      (CollectionStatsBuilder()..update(updates))._build();

  _$CollectionStats._(
      {required this.available,
      this.reason,
      required this.generatedAt,
      required this.plants,
      required this.species})
      : super._();
  @override
  CollectionStats rebuild(void Function(CollectionStatsBuilder) updates) =>
      (toBuilder()..update(updates)).build();

  @override
  CollectionStatsBuilder toBuilder() => CollectionStatsBuilder()..replace(this);

  @override
  bool operator ==(Object other) {
    if (identical(other, this)) return true;
    return other is CollectionStats &&
        available == other.available &&
        reason == other.reason &&
        generatedAt == other.generatedAt &&
        plants == other.plants &&
        species == other.species;
  }

  @override
  int get hashCode {
    var _$hash = 0;
    _$hash = $jc(_$hash, available.hashCode);
    _$hash = $jc(_$hash, reason.hashCode);
    _$hash = $jc(_$hash, generatedAt.hashCode);
    _$hash = $jc(_$hash, plants.hashCode);
    _$hash = $jc(_$hash, species.hashCode);
    _$hash = $jf(_$hash);
    return _$hash;
  }

  @override
  String toString() {
    return (newBuiltValueToStringHelper(r'CollectionStats')
          ..add('available', available)
          ..add('reason', reason)
          ..add('generatedAt', generatedAt)
          ..add('plants', plants)
          ..add('species', species))
        .toString();
  }
}

class CollectionStatsBuilder
    implements Builder<CollectionStats, CollectionStatsBuilder> {
  _$CollectionStats? _$v;

  bool? _available;
  bool? get available => _$this._available;
  set available(bool? available) => _$this._available = available;

  String? _reason;
  String? get reason => _$this._reason;
  set reason(String? reason) => _$this._reason = reason;

  DateTime? _generatedAt;
  DateTime? get generatedAt => _$this._generatedAt;
  set generatedAt(DateTime? generatedAt) => _$this._generatedAt = generatedAt;

  MapBuilder<String, CollectionShare>? _plants;
  MapBuilder<String, CollectionShare> get plants =>
      _$this._plants ??= MapBuilder<String, CollectionShare>();
  set plants(MapBuilder<String, CollectionShare>? plants) =>
      _$this._plants = plants;

  MapBuilder<String, CollectionShare>? _species;
  MapBuilder<String, CollectionShare> get species =>
      _$this._species ??= MapBuilder<String, CollectionShare>();
  set species(MapBuilder<String, CollectionShare>? species) =>
      _$this._species = species;

  CollectionStatsBuilder() {
    CollectionStats._defaults(this);
  }

  CollectionStatsBuilder get _$this {
    final $v = _$v;
    if ($v != null) {
      _available = $v.available;
      _reason = $v.reason;
      _generatedAt = $v.generatedAt;
      _plants = $v.plants.toBuilder();
      _species = $v.species.toBuilder();
      _$v = null;
    }
    return this;
  }

  @override
  void replace(CollectionStats other) {
    _$v = other as _$CollectionStats;
  }

  @override
  void update(void Function(CollectionStatsBuilder)? updates) {
    if (updates != null) updates(this);
  }

  @override
  CollectionStats build() => _build();

  _$CollectionStats _build() {
    _$CollectionStats _$result;
    try {
      _$result = _$v ??
          _$CollectionStats._(
            available: BuiltValueNullFieldError.checkNotNull(
                available, r'CollectionStats', 'available'),
            reason: reason,
            generatedAt: BuiltValueNullFieldError.checkNotNull(
                generatedAt, r'CollectionStats', 'generatedAt'),
            plants: plants.build(),
            species: species.build(),
          );
    } catch (_) {
      late String _$failedField;
      try {
        _$failedField = 'plants';
        plants.build();
        _$failedField = 'species';
        species.build();
      } catch (e) {
        throw BuiltValueNestedFieldError(
            r'CollectionStats', _$failedField, e.toString());
      }
      rethrow;
    }
    replace(_$result);
    return _$result;
  }
}

// ignore_for_file: deprecated_member_use_from_same_package,type=lint
