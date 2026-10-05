// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'teaching_ecosystem_progress.dart';

// **************************************************************************
// BuiltValueGenerator
// **************************************************************************

class _$TeachingEcosystemProgress extends TeachingEcosystemProgress {
  @override
  final String id;
  @override
  final String name;
  @override
  final int completedLevels;
  @override
  final int totalLevels;
  @override
  final num progress;

  factory _$TeachingEcosystemProgress(
          [void Function(TeachingEcosystemProgressBuilder)? updates]) =>
      (TeachingEcosystemProgressBuilder()..update(updates))._build();

  _$TeachingEcosystemProgress._(
      {required this.id,
      required this.name,
      required this.completedLevels,
      required this.totalLevels,
      required this.progress})
      : super._();
  @override
  TeachingEcosystemProgress rebuild(
          void Function(TeachingEcosystemProgressBuilder) updates) =>
      (toBuilder()..update(updates)).build();

  @override
  TeachingEcosystemProgressBuilder toBuilder() =>
      TeachingEcosystemProgressBuilder()..replace(this);

  @override
  bool operator ==(Object other) {
    if (identical(other, this)) return true;
    return other is TeachingEcosystemProgress &&
        id == other.id &&
        name == other.name &&
        completedLevels == other.completedLevels &&
        totalLevels == other.totalLevels &&
        progress == other.progress;
  }

  @override
  int get hashCode {
    var _$hash = 0;
    _$hash = $jc(_$hash, id.hashCode);
    _$hash = $jc(_$hash, name.hashCode);
    _$hash = $jc(_$hash, completedLevels.hashCode);
    _$hash = $jc(_$hash, totalLevels.hashCode);
    _$hash = $jc(_$hash, progress.hashCode);
    _$hash = $jf(_$hash);
    return _$hash;
  }

  @override
  String toString() {
    return (newBuiltValueToStringHelper(r'TeachingEcosystemProgress')
          ..add('id', id)
          ..add('name', name)
          ..add('completedLevels', completedLevels)
          ..add('totalLevels', totalLevels)
          ..add('progress', progress))
        .toString();
  }
}

class TeachingEcosystemProgressBuilder
    implements
        Builder<TeachingEcosystemProgress, TeachingEcosystemProgressBuilder> {
  _$TeachingEcosystemProgress? _$v;

  String? _id;
  String? get id => _$this._id;
  set id(String? id) => _$this._id = id;

  String? _name;
  String? get name => _$this._name;
  set name(String? name) => _$this._name = name;

  int? _completedLevels;
  int? get completedLevels => _$this._completedLevels;
  set completedLevels(int? completedLevels) =>
      _$this._completedLevels = completedLevels;

  int? _totalLevels;
  int? get totalLevels => _$this._totalLevels;
  set totalLevels(int? totalLevels) => _$this._totalLevels = totalLevels;

  num? _progress;
  num? get progress => _$this._progress;
  set progress(num? progress) => _$this._progress = progress;

  TeachingEcosystemProgressBuilder() {
    TeachingEcosystemProgress._defaults(this);
  }

  TeachingEcosystemProgressBuilder get _$this {
    final $v = _$v;
    if ($v != null) {
      _id = $v.id;
      _name = $v.name;
      _completedLevels = $v.completedLevels;
      _totalLevels = $v.totalLevels;
      _progress = $v.progress;
      _$v = null;
    }
    return this;
  }

  @override
  void replace(TeachingEcosystemProgress other) {
    _$v = other as _$TeachingEcosystemProgress;
  }

  @override
  void update(void Function(TeachingEcosystemProgressBuilder)? updates) {
    if (updates != null) updates(this);
  }

  @override
  TeachingEcosystemProgress build() => _build();

  _$TeachingEcosystemProgress _build() {
    final _$result = _$v ??
        _$TeachingEcosystemProgress._(
          id: BuiltValueNullFieldError.checkNotNull(
              id, r'TeachingEcosystemProgress', 'id'),
          name: BuiltValueNullFieldError.checkNotNull(
              name, r'TeachingEcosystemProgress', 'name'),
          completedLevels: BuiltValueNullFieldError.checkNotNull(
              completedLevels, r'TeachingEcosystemProgress', 'completedLevels'),
          totalLevels: BuiltValueNullFieldError.checkNotNull(
              totalLevels, r'TeachingEcosystemProgress', 'totalLevels'),
          progress: BuiltValueNullFieldError.checkNotNull(
              progress, r'TeachingEcosystemProgress', 'progress'),
        );
    replace(_$result);
    return _$result;
  }
}

// ignore_for_file: deprecated_member_use_from_same_package,type=lint
