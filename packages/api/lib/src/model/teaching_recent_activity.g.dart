// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'teaching_recent_activity.dart';

// **************************************************************************
// BuiltValueGenerator
// **************************************************************************

class _$TeachingRecentActivity extends TeachingRecentActivity {
  @override
  final String studentId;
  @override
  final String displayName;
  @override
  final String className;
  @override
  final DateTime completedAt;
  @override
  final String levelTitle;

  factory _$TeachingRecentActivity(
          [void Function(TeachingRecentActivityBuilder)? updates]) =>
      (TeachingRecentActivityBuilder()..update(updates))._build();

  _$TeachingRecentActivity._(
      {required this.studentId,
      required this.displayName,
      required this.className,
      required this.completedAt,
      required this.levelTitle})
      : super._();
  @override
  TeachingRecentActivity rebuild(
          void Function(TeachingRecentActivityBuilder) updates) =>
      (toBuilder()..update(updates)).build();

  @override
  TeachingRecentActivityBuilder toBuilder() =>
      TeachingRecentActivityBuilder()..replace(this);

  @override
  bool operator ==(Object other) {
    if (identical(other, this)) return true;
    return other is TeachingRecentActivity &&
        studentId == other.studentId &&
        displayName == other.displayName &&
        className == other.className &&
        completedAt == other.completedAt &&
        levelTitle == other.levelTitle;
  }

  @override
  int get hashCode {
    var _$hash = 0;
    _$hash = $jc(_$hash, studentId.hashCode);
    _$hash = $jc(_$hash, displayName.hashCode);
    _$hash = $jc(_$hash, className.hashCode);
    _$hash = $jc(_$hash, completedAt.hashCode);
    _$hash = $jc(_$hash, levelTitle.hashCode);
    _$hash = $jf(_$hash);
    return _$hash;
  }

  @override
  String toString() {
    return (newBuiltValueToStringHelper(r'TeachingRecentActivity')
          ..add('studentId', studentId)
          ..add('displayName', displayName)
          ..add('className', className)
          ..add('completedAt', completedAt)
          ..add('levelTitle', levelTitle))
        .toString();
  }
}

class TeachingRecentActivityBuilder
    implements Builder<TeachingRecentActivity, TeachingRecentActivityBuilder> {
  _$TeachingRecentActivity? _$v;

  String? _studentId;
  String? get studentId => _$this._studentId;
  set studentId(String? studentId) => _$this._studentId = studentId;

  String? _displayName;
  String? get displayName => _$this._displayName;
  set displayName(String? displayName) => _$this._displayName = displayName;

  String? _className;
  String? get className => _$this._className;
  set className(String? className) => _$this._className = className;

  DateTime? _completedAt;
  DateTime? get completedAt => _$this._completedAt;
  set completedAt(DateTime? completedAt) => _$this._completedAt = completedAt;

  String? _levelTitle;
  String? get levelTitle => _$this._levelTitle;
  set levelTitle(String? levelTitle) => _$this._levelTitle = levelTitle;

  TeachingRecentActivityBuilder() {
    TeachingRecentActivity._defaults(this);
  }

  TeachingRecentActivityBuilder get _$this {
    final $v = _$v;
    if ($v != null) {
      _studentId = $v.studentId;
      _displayName = $v.displayName;
      _className = $v.className;
      _completedAt = $v.completedAt;
      _levelTitle = $v.levelTitle;
      _$v = null;
    }
    return this;
  }

  @override
  void replace(TeachingRecentActivity other) {
    _$v = other as _$TeachingRecentActivity;
  }

  @override
  void update(void Function(TeachingRecentActivityBuilder)? updates) {
    if (updates != null) updates(this);
  }

  @override
  TeachingRecentActivity build() => _build();

  _$TeachingRecentActivity _build() {
    final _$result = _$v ??
        _$TeachingRecentActivity._(
          studentId: BuiltValueNullFieldError.checkNotNull(
              studentId, r'TeachingRecentActivity', 'studentId'),
          displayName: BuiltValueNullFieldError.checkNotNull(
              displayName, r'TeachingRecentActivity', 'displayName'),
          className: BuiltValueNullFieldError.checkNotNull(
              className, r'TeachingRecentActivity', 'className'),
          completedAt: BuiltValueNullFieldError.checkNotNull(
              completedAt, r'TeachingRecentActivity', 'completedAt'),
          levelTitle: BuiltValueNullFieldError.checkNotNull(
              levelTitle, r'TeachingRecentActivity', 'levelTitle'),
        );
    replace(_$result);
    return _$result;
  }
}

// ignore_for_file: deprecated_member_use_from_same_package,type=lint
