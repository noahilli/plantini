// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'progress_snapshot.dart';

// **************************************************************************
// BuiltValueGenerator
// **************************************************************************

class _$ProgressSnapshot extends ProgressSnapshot {
  @override
  final DateTime updatedAt;
  @override
  final BuiltList<LevelProgress> levels;

  factory _$ProgressSnapshot(
          [void Function(ProgressSnapshotBuilder)? updates]) =>
      (ProgressSnapshotBuilder()..update(updates))._build();

  _$ProgressSnapshot._({required this.updatedAt, required this.levels})
      : super._();
  @override
  ProgressSnapshot rebuild(void Function(ProgressSnapshotBuilder) updates) =>
      (toBuilder()..update(updates)).build();

  @override
  ProgressSnapshotBuilder toBuilder() =>
      ProgressSnapshotBuilder()..replace(this);

  @override
  bool operator ==(Object other) {
    if (identical(other, this)) return true;
    return other is ProgressSnapshot &&
        updatedAt == other.updatedAt &&
        levels == other.levels;
  }

  @override
  int get hashCode {
    var _$hash = 0;
    _$hash = $jc(_$hash, updatedAt.hashCode);
    _$hash = $jc(_$hash, levels.hashCode);
    _$hash = $jf(_$hash);
    return _$hash;
  }

  @override
  String toString() {
    return (newBuiltValueToStringHelper(r'ProgressSnapshot')
          ..add('updatedAt', updatedAt)
          ..add('levels', levels))
        .toString();
  }
}

class ProgressSnapshotBuilder
    implements Builder<ProgressSnapshot, ProgressSnapshotBuilder> {
  _$ProgressSnapshot? _$v;

  DateTime? _updatedAt;
  DateTime? get updatedAt => _$this._updatedAt;
  set updatedAt(DateTime? updatedAt) => _$this._updatedAt = updatedAt;

  ListBuilder<LevelProgress>? _levels;
  ListBuilder<LevelProgress> get levels =>
      _$this._levels ??= ListBuilder<LevelProgress>();
  set levels(ListBuilder<LevelProgress>? levels) => _$this._levels = levels;

  ProgressSnapshotBuilder() {
    ProgressSnapshot._defaults(this);
  }

  ProgressSnapshotBuilder get _$this {
    final $v = _$v;
    if ($v != null) {
      _updatedAt = $v.updatedAt;
      _levels = $v.levels.toBuilder();
      _$v = null;
    }
    return this;
  }

  @override
  void replace(ProgressSnapshot other) {
    _$v = other as _$ProgressSnapshot;
  }

  @override
  void update(void Function(ProgressSnapshotBuilder)? updates) {
    if (updates != null) updates(this);
  }

  @override
  ProgressSnapshot build() => _build();

  _$ProgressSnapshot _build() {
    _$ProgressSnapshot _$result;
    try {
      _$result = _$v ??
          _$ProgressSnapshot._(
            updatedAt: BuiltValueNullFieldError.checkNotNull(
                updatedAt, r'ProgressSnapshot', 'updatedAt'),
            levels: levels.build(),
          );
    } catch (_) {
      late String _$failedField;
      try {
        _$failedField = 'levels';
        levels.build();
      } catch (e) {
        throw BuiltValueNestedFieldError(
            r'ProgressSnapshot', _$failedField, e.toString());
      }
      rethrow;
    }
    replace(_$result);
    return _$result;
  }
}

// ignore_for_file: deprecated_member_use_from_same_package,type=lint
