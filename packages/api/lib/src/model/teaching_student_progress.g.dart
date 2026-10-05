// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'teaching_student_progress.dart';

// **************************************************************************
// BuiltValueGenerator
// **************************************************************************

class _$TeachingStudentProgress extends TeachingStudentProgress {
  @override
  final String id;
  @override
  final String username;
  @override
  final String displayName;
  @override
  final String? email;
  @override
  final bool enabled;
  @override
  final int completedLevels;
  @override
  final int totalLevels;
  @override
  final num progress;
  @override
  final DateTime? lastActivityAt;
  @override
  final BuiltList<TeachingEcosystemProgress> ecosystems;

  factory _$TeachingStudentProgress(
          [void Function(TeachingStudentProgressBuilder)? updates]) =>
      (TeachingStudentProgressBuilder()..update(updates))._build();

  _$TeachingStudentProgress._(
      {required this.id,
      required this.username,
      required this.displayName,
      this.email,
      required this.enabled,
      required this.completedLevels,
      required this.totalLevels,
      required this.progress,
      this.lastActivityAt,
      required this.ecosystems})
      : super._();
  @override
  TeachingStudentProgress rebuild(
          void Function(TeachingStudentProgressBuilder) updates) =>
      (toBuilder()..update(updates)).build();

  @override
  TeachingStudentProgressBuilder toBuilder() =>
      TeachingStudentProgressBuilder()..replace(this);

  @override
  bool operator ==(Object other) {
    if (identical(other, this)) return true;
    return other is TeachingStudentProgress &&
        id == other.id &&
        username == other.username &&
        displayName == other.displayName &&
        email == other.email &&
        enabled == other.enabled &&
        completedLevels == other.completedLevels &&
        totalLevels == other.totalLevels &&
        progress == other.progress &&
        lastActivityAt == other.lastActivityAt &&
        ecosystems == other.ecosystems;
  }

  @override
  int get hashCode {
    var _$hash = 0;
    _$hash = $jc(_$hash, id.hashCode);
    _$hash = $jc(_$hash, username.hashCode);
    _$hash = $jc(_$hash, displayName.hashCode);
    _$hash = $jc(_$hash, email.hashCode);
    _$hash = $jc(_$hash, enabled.hashCode);
    _$hash = $jc(_$hash, completedLevels.hashCode);
    _$hash = $jc(_$hash, totalLevels.hashCode);
    _$hash = $jc(_$hash, progress.hashCode);
    _$hash = $jc(_$hash, lastActivityAt.hashCode);
    _$hash = $jc(_$hash, ecosystems.hashCode);
    _$hash = $jf(_$hash);
    return _$hash;
  }

  @override
  String toString() {
    return (newBuiltValueToStringHelper(r'TeachingStudentProgress')
          ..add('id', id)
          ..add('username', username)
          ..add('displayName', displayName)
          ..add('email', email)
          ..add('enabled', enabled)
          ..add('completedLevels', completedLevels)
          ..add('totalLevels', totalLevels)
          ..add('progress', progress)
          ..add('lastActivityAt', lastActivityAt)
          ..add('ecosystems', ecosystems))
        .toString();
  }
}

class TeachingStudentProgressBuilder
    implements
        Builder<TeachingStudentProgress, TeachingStudentProgressBuilder> {
  _$TeachingStudentProgress? _$v;

  String? _id;
  String? get id => _$this._id;
  set id(String? id) => _$this._id = id;

  String? _username;
  String? get username => _$this._username;
  set username(String? username) => _$this._username = username;

  String? _displayName;
  String? get displayName => _$this._displayName;
  set displayName(String? displayName) => _$this._displayName = displayName;

  String? _email;
  String? get email => _$this._email;
  set email(String? email) => _$this._email = email;

  bool? _enabled;
  bool? get enabled => _$this._enabled;
  set enabled(bool? enabled) => _$this._enabled = enabled;

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

  DateTime? _lastActivityAt;
  DateTime? get lastActivityAt => _$this._lastActivityAt;
  set lastActivityAt(DateTime? lastActivityAt) =>
      _$this._lastActivityAt = lastActivityAt;

  ListBuilder<TeachingEcosystemProgress>? _ecosystems;
  ListBuilder<TeachingEcosystemProgress> get ecosystems =>
      _$this._ecosystems ??= ListBuilder<TeachingEcosystemProgress>();
  set ecosystems(ListBuilder<TeachingEcosystemProgress>? ecosystems) =>
      _$this._ecosystems = ecosystems;

  TeachingStudentProgressBuilder() {
    TeachingStudentProgress._defaults(this);
  }

  TeachingStudentProgressBuilder get _$this {
    final $v = _$v;
    if ($v != null) {
      _id = $v.id;
      _username = $v.username;
      _displayName = $v.displayName;
      _email = $v.email;
      _enabled = $v.enabled;
      _completedLevels = $v.completedLevels;
      _totalLevels = $v.totalLevels;
      _progress = $v.progress;
      _lastActivityAt = $v.lastActivityAt;
      _ecosystems = $v.ecosystems.toBuilder();
      _$v = null;
    }
    return this;
  }

  @override
  void replace(TeachingStudentProgress other) {
    _$v = other as _$TeachingStudentProgress;
  }

  @override
  void update(void Function(TeachingStudentProgressBuilder)? updates) {
    if (updates != null) updates(this);
  }

  @override
  TeachingStudentProgress build() => _build();

  _$TeachingStudentProgress _build() {
    _$TeachingStudentProgress _$result;
    try {
      _$result = _$v ??
          _$TeachingStudentProgress._(
            id: BuiltValueNullFieldError.checkNotNull(
                id, r'TeachingStudentProgress', 'id'),
            username: BuiltValueNullFieldError.checkNotNull(
                username, r'TeachingStudentProgress', 'username'),
            displayName: BuiltValueNullFieldError.checkNotNull(
                displayName, r'TeachingStudentProgress', 'displayName'),
            email: email,
            enabled: BuiltValueNullFieldError.checkNotNull(
                enabled, r'TeachingStudentProgress', 'enabled'),
            completedLevels: BuiltValueNullFieldError.checkNotNull(
                completedLevels, r'TeachingStudentProgress', 'completedLevels'),
            totalLevels: BuiltValueNullFieldError.checkNotNull(
                totalLevels, r'TeachingStudentProgress', 'totalLevels'),
            progress: BuiltValueNullFieldError.checkNotNull(
                progress, r'TeachingStudentProgress', 'progress'),
            lastActivityAt: lastActivityAt,
            ecosystems: ecosystems.build(),
          );
    } catch (_) {
      late String _$failedField;
      try {
        _$failedField = 'ecosystems';
        ecosystems.build();
      } catch (e) {
        throw BuiltValueNestedFieldError(
            r'TeachingStudentProgress', _$failedField, e.toString());
      }
      rethrow;
    }
    replace(_$result);
    return _$result;
  }
}

// ignore_for_file: deprecated_member_use_from_same_package,type=lint
