// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'teaching_dashboard.dart';

// **************************************************************************
// BuiltValueGenerator
// **************************************************************************

class _$TeachingDashboard extends TeachingDashboard {
  @override
  final int classes;
  @override
  final int students;
  @override
  final int activeStudents;
  @override
  final int completedLevels;
  @override
  final int totalLevels;
  @override
  final num averageProgress;
  @override
  final BuiltList<TeachingEcosystemProgress> ecosystems;
  @override
  final BuiltList<TeachingRecentActivity> recentActivity;

  factory _$TeachingDashboard(
          [void Function(TeachingDashboardBuilder)? updates]) =>
      (TeachingDashboardBuilder()..update(updates))._build();

  _$TeachingDashboard._(
      {required this.classes,
      required this.students,
      required this.activeStudents,
      required this.completedLevels,
      required this.totalLevels,
      required this.averageProgress,
      required this.ecosystems,
      required this.recentActivity})
      : super._();
  @override
  TeachingDashboard rebuild(void Function(TeachingDashboardBuilder) updates) =>
      (toBuilder()..update(updates)).build();

  @override
  TeachingDashboardBuilder toBuilder() =>
      TeachingDashboardBuilder()..replace(this);

  @override
  bool operator ==(Object other) {
    if (identical(other, this)) return true;
    return other is TeachingDashboard &&
        classes == other.classes &&
        students == other.students &&
        activeStudents == other.activeStudents &&
        completedLevels == other.completedLevels &&
        totalLevels == other.totalLevels &&
        averageProgress == other.averageProgress &&
        ecosystems == other.ecosystems &&
        recentActivity == other.recentActivity;
  }

  @override
  int get hashCode {
    var _$hash = 0;
    _$hash = $jc(_$hash, classes.hashCode);
    _$hash = $jc(_$hash, students.hashCode);
    _$hash = $jc(_$hash, activeStudents.hashCode);
    _$hash = $jc(_$hash, completedLevels.hashCode);
    _$hash = $jc(_$hash, totalLevels.hashCode);
    _$hash = $jc(_$hash, averageProgress.hashCode);
    _$hash = $jc(_$hash, ecosystems.hashCode);
    _$hash = $jc(_$hash, recentActivity.hashCode);
    _$hash = $jf(_$hash);
    return _$hash;
  }

  @override
  String toString() {
    return (newBuiltValueToStringHelper(r'TeachingDashboard')
          ..add('classes', classes)
          ..add('students', students)
          ..add('activeStudents', activeStudents)
          ..add('completedLevels', completedLevels)
          ..add('totalLevels', totalLevels)
          ..add('averageProgress', averageProgress)
          ..add('ecosystems', ecosystems)
          ..add('recentActivity', recentActivity))
        .toString();
  }
}

class TeachingDashboardBuilder
    implements Builder<TeachingDashboard, TeachingDashboardBuilder> {
  _$TeachingDashboard? _$v;

  int? _classes;
  int? get classes => _$this._classes;
  set classes(int? classes) => _$this._classes = classes;

  int? _students;
  int? get students => _$this._students;
  set students(int? students) => _$this._students = students;

  int? _activeStudents;
  int? get activeStudents => _$this._activeStudents;
  set activeStudents(int? activeStudents) =>
      _$this._activeStudents = activeStudents;

  int? _completedLevels;
  int? get completedLevels => _$this._completedLevels;
  set completedLevels(int? completedLevels) =>
      _$this._completedLevels = completedLevels;

  int? _totalLevels;
  int? get totalLevels => _$this._totalLevels;
  set totalLevels(int? totalLevels) => _$this._totalLevels = totalLevels;

  num? _averageProgress;
  num? get averageProgress => _$this._averageProgress;
  set averageProgress(num? averageProgress) =>
      _$this._averageProgress = averageProgress;

  ListBuilder<TeachingEcosystemProgress>? _ecosystems;
  ListBuilder<TeachingEcosystemProgress> get ecosystems =>
      _$this._ecosystems ??= ListBuilder<TeachingEcosystemProgress>();
  set ecosystems(ListBuilder<TeachingEcosystemProgress>? ecosystems) =>
      _$this._ecosystems = ecosystems;

  ListBuilder<TeachingRecentActivity>? _recentActivity;
  ListBuilder<TeachingRecentActivity> get recentActivity =>
      _$this._recentActivity ??= ListBuilder<TeachingRecentActivity>();
  set recentActivity(ListBuilder<TeachingRecentActivity>? recentActivity) =>
      _$this._recentActivity = recentActivity;

  TeachingDashboardBuilder() {
    TeachingDashboard._defaults(this);
  }

  TeachingDashboardBuilder get _$this {
    final $v = _$v;
    if ($v != null) {
      _classes = $v.classes;
      _students = $v.students;
      _activeStudents = $v.activeStudents;
      _completedLevels = $v.completedLevels;
      _totalLevels = $v.totalLevels;
      _averageProgress = $v.averageProgress;
      _ecosystems = $v.ecosystems.toBuilder();
      _recentActivity = $v.recentActivity.toBuilder();
      _$v = null;
    }
    return this;
  }

  @override
  void replace(TeachingDashboard other) {
    _$v = other as _$TeachingDashboard;
  }

  @override
  void update(void Function(TeachingDashboardBuilder)? updates) {
    if (updates != null) updates(this);
  }

  @override
  TeachingDashboard build() => _build();

  _$TeachingDashboard _build() {
    _$TeachingDashboard _$result;
    try {
      _$result = _$v ??
          _$TeachingDashboard._(
            classes: BuiltValueNullFieldError.checkNotNull(
                classes, r'TeachingDashboard', 'classes'),
            students: BuiltValueNullFieldError.checkNotNull(
                students, r'TeachingDashboard', 'students'),
            activeStudents: BuiltValueNullFieldError.checkNotNull(
                activeStudents, r'TeachingDashboard', 'activeStudents'),
            completedLevels: BuiltValueNullFieldError.checkNotNull(
                completedLevels, r'TeachingDashboard', 'completedLevels'),
            totalLevels: BuiltValueNullFieldError.checkNotNull(
                totalLevels, r'TeachingDashboard', 'totalLevels'),
            averageProgress: BuiltValueNullFieldError.checkNotNull(
                averageProgress, r'TeachingDashboard', 'averageProgress'),
            ecosystems: ecosystems.build(),
            recentActivity: recentActivity.build(),
          );
    } catch (_) {
      late String _$failedField;
      try {
        _$failedField = 'ecosystems';
        ecosystems.build();
        _$failedField = 'recentActivity';
        recentActivity.build();
      } catch (e) {
        throw BuiltValueNestedFieldError(
            r'TeachingDashboard', _$failedField, e.toString());
      }
      rethrow;
    }
    replace(_$result);
    return _$result;
  }
}

// ignore_for_file: deprecated_member_use_from_same_package,type=lint
