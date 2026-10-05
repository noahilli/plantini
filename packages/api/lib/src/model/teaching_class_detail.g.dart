// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'teaching_class_detail.dart';

// **************************************************************************
// BuiltValueGenerator
// **************************************************************************

class _$TeachingClassDetail extends TeachingClassDetail {
  @override
  final TeachingClass class_;
  @override
  final BuiltList<TeachingStudentProgress> students;

  factory _$TeachingClassDetail(
          [void Function(TeachingClassDetailBuilder)? updates]) =>
      (TeachingClassDetailBuilder()..update(updates))._build();

  _$TeachingClassDetail._({required this.class_, required this.students})
      : super._();
  @override
  TeachingClassDetail rebuild(
          void Function(TeachingClassDetailBuilder) updates) =>
      (toBuilder()..update(updates)).build();

  @override
  TeachingClassDetailBuilder toBuilder() =>
      TeachingClassDetailBuilder()..replace(this);

  @override
  bool operator ==(Object other) {
    if (identical(other, this)) return true;
    return other is TeachingClassDetail &&
        class_ == other.class_ &&
        students == other.students;
  }

  @override
  int get hashCode {
    var _$hash = 0;
    _$hash = $jc(_$hash, class_.hashCode);
    _$hash = $jc(_$hash, students.hashCode);
    _$hash = $jf(_$hash);
    return _$hash;
  }

  @override
  String toString() {
    return (newBuiltValueToStringHelper(r'TeachingClassDetail')
          ..add('class_', class_)
          ..add('students', students))
        .toString();
  }
}

class TeachingClassDetailBuilder
    implements Builder<TeachingClassDetail, TeachingClassDetailBuilder> {
  _$TeachingClassDetail? _$v;

  TeachingClassBuilder? _class_;
  TeachingClassBuilder get class_ => _$this._class_ ??= TeachingClassBuilder();
  set class_(TeachingClassBuilder? class_) => _$this._class_ = class_;

  ListBuilder<TeachingStudentProgress>? _students;
  ListBuilder<TeachingStudentProgress> get students =>
      _$this._students ??= ListBuilder<TeachingStudentProgress>();
  set students(ListBuilder<TeachingStudentProgress>? students) =>
      _$this._students = students;

  TeachingClassDetailBuilder() {
    TeachingClassDetail._defaults(this);
  }

  TeachingClassDetailBuilder get _$this {
    final $v = _$v;
    if ($v != null) {
      _class_ = $v.class_.toBuilder();
      _students = $v.students.toBuilder();
      _$v = null;
    }
    return this;
  }

  @override
  void replace(TeachingClassDetail other) {
    _$v = other as _$TeachingClassDetail;
  }

  @override
  void update(void Function(TeachingClassDetailBuilder)? updates) {
    if (updates != null) updates(this);
  }

  @override
  TeachingClassDetail build() => _build();

  _$TeachingClassDetail _build() {
    _$TeachingClassDetail _$result;
    try {
      _$result = _$v ??
          _$TeachingClassDetail._(
            class_: class_.build(),
            students: students.build(),
          );
    } catch (_) {
      late String _$failedField;
      try {
        _$failedField = 'class_';
        class_.build();
        _$failedField = 'students';
        students.build();
      } catch (e) {
        throw BuiltValueNestedFieldError(
            r'TeachingClassDetail', _$failedField, e.toString());
      }
      rethrow;
    }
    replace(_$result);
    return _$result;
  }
}

// ignore_for_file: deprecated_member_use_from_same_package,type=lint
