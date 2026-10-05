// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'teaching_update_student_response.dart';

// **************************************************************************
// BuiltValueGenerator
// **************************************************************************

class _$TeachingUpdateStudentResponse extends TeachingUpdateStudentResponse {
  @override
  final TeachingStudent student;

  factory _$TeachingUpdateStudentResponse(
          [void Function(TeachingUpdateStudentResponseBuilder)? updates]) =>
      (TeachingUpdateStudentResponseBuilder()..update(updates))._build();

  _$TeachingUpdateStudentResponse._({required this.student}) : super._();
  @override
  TeachingUpdateStudentResponse rebuild(
          void Function(TeachingUpdateStudentResponseBuilder) updates) =>
      (toBuilder()..update(updates)).build();

  @override
  TeachingUpdateStudentResponseBuilder toBuilder() =>
      TeachingUpdateStudentResponseBuilder()..replace(this);

  @override
  bool operator ==(Object other) {
    if (identical(other, this)) return true;
    return other is TeachingUpdateStudentResponse && student == other.student;
  }

  @override
  int get hashCode {
    var _$hash = 0;
    _$hash = $jc(_$hash, student.hashCode);
    _$hash = $jf(_$hash);
    return _$hash;
  }

  @override
  String toString() {
    return (newBuiltValueToStringHelper(r'TeachingUpdateStudentResponse')
          ..add('student', student))
        .toString();
  }
}

class TeachingUpdateStudentResponseBuilder
    implements
        Builder<TeachingUpdateStudentResponse,
            TeachingUpdateStudentResponseBuilder> {
  _$TeachingUpdateStudentResponse? _$v;

  TeachingStudentBuilder? _student;
  TeachingStudentBuilder get student =>
      _$this._student ??= TeachingStudentBuilder();
  set student(TeachingStudentBuilder? student) => _$this._student = student;

  TeachingUpdateStudentResponseBuilder() {
    TeachingUpdateStudentResponse._defaults(this);
  }

  TeachingUpdateStudentResponseBuilder get _$this {
    final $v = _$v;
    if ($v != null) {
      _student = $v.student.toBuilder();
      _$v = null;
    }
    return this;
  }

  @override
  void replace(TeachingUpdateStudentResponse other) {
    _$v = other as _$TeachingUpdateStudentResponse;
  }

  @override
  void update(void Function(TeachingUpdateStudentResponseBuilder)? updates) {
    if (updates != null) updates(this);
  }

  @override
  TeachingUpdateStudentResponse build() => _build();

  _$TeachingUpdateStudentResponse _build() {
    _$TeachingUpdateStudentResponse _$result;
    try {
      _$result = _$v ??
          _$TeachingUpdateStudentResponse._(
            student: student.build(),
          );
    } catch (_) {
      late String _$failedField;
      try {
        _$failedField = 'student';
        student.build();
      } catch (e) {
        throw BuiltValueNestedFieldError(
            r'TeachingUpdateStudentResponse', _$failedField, e.toString());
      }
      rethrow;
    }
    replace(_$result);
    return _$result;
  }
}

// ignore_for_file: deprecated_member_use_from_same_package,type=lint
