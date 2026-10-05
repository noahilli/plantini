// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'teaching_create_student_response.dart';

// **************************************************************************
// BuiltValueGenerator
// **************************************************************************

class _$TeachingCreateStudentResponse extends TeachingCreateStudentResponse {
  @override
  final TeachingStudent student;
  @override
  final String temporaryPassword;

  factory _$TeachingCreateStudentResponse(
          [void Function(TeachingCreateStudentResponseBuilder)? updates]) =>
      (TeachingCreateStudentResponseBuilder()..update(updates))._build();

  _$TeachingCreateStudentResponse._(
      {required this.student, required this.temporaryPassword})
      : super._();
  @override
  TeachingCreateStudentResponse rebuild(
          void Function(TeachingCreateStudentResponseBuilder) updates) =>
      (toBuilder()..update(updates)).build();

  @override
  TeachingCreateStudentResponseBuilder toBuilder() =>
      TeachingCreateStudentResponseBuilder()..replace(this);

  @override
  bool operator ==(Object other) {
    if (identical(other, this)) return true;
    return other is TeachingCreateStudentResponse &&
        student == other.student &&
        temporaryPassword == other.temporaryPassword;
  }

  @override
  int get hashCode {
    var _$hash = 0;
    _$hash = $jc(_$hash, student.hashCode);
    _$hash = $jc(_$hash, temporaryPassword.hashCode);
    _$hash = $jf(_$hash);
    return _$hash;
  }

  @override
  String toString() {
    return (newBuiltValueToStringHelper(r'TeachingCreateStudentResponse')
          ..add('student', student)
          ..add('temporaryPassword', temporaryPassword))
        .toString();
  }
}

class TeachingCreateStudentResponseBuilder
    implements
        Builder<TeachingCreateStudentResponse,
            TeachingCreateStudentResponseBuilder> {
  _$TeachingCreateStudentResponse? _$v;

  TeachingStudentBuilder? _student;
  TeachingStudentBuilder get student =>
      _$this._student ??= TeachingStudentBuilder();
  set student(TeachingStudentBuilder? student) => _$this._student = student;

  String? _temporaryPassword;
  String? get temporaryPassword => _$this._temporaryPassword;
  set temporaryPassword(String? temporaryPassword) =>
      _$this._temporaryPassword = temporaryPassword;

  TeachingCreateStudentResponseBuilder() {
    TeachingCreateStudentResponse._defaults(this);
  }

  TeachingCreateStudentResponseBuilder get _$this {
    final $v = _$v;
    if ($v != null) {
      _student = $v.student.toBuilder();
      _temporaryPassword = $v.temporaryPassword;
      _$v = null;
    }
    return this;
  }

  @override
  void replace(TeachingCreateStudentResponse other) {
    _$v = other as _$TeachingCreateStudentResponse;
  }

  @override
  void update(void Function(TeachingCreateStudentResponseBuilder)? updates) {
    if (updates != null) updates(this);
  }

  @override
  TeachingCreateStudentResponse build() => _build();

  _$TeachingCreateStudentResponse _build() {
    _$TeachingCreateStudentResponse _$result;
    try {
      _$result = _$v ??
          _$TeachingCreateStudentResponse._(
            student: student.build(),
            temporaryPassword: BuiltValueNullFieldError.checkNotNull(
                temporaryPassword,
                r'TeachingCreateStudentResponse',
                'temporaryPassword'),
          );
    } catch (_) {
      late String _$failedField;
      try {
        _$failedField = 'student';
        student.build();
      } catch (e) {
        throw BuiltValueNestedFieldError(
            r'TeachingCreateStudentResponse', _$failedField, e.toString());
      }
      rethrow;
    }
    replace(_$result);
    return _$result;
  }
}

// ignore_for_file: deprecated_member_use_from_same_package,type=lint
