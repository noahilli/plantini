// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'teaching_student.dart';

// **************************************************************************
// BuiltValueGenerator
// **************************************************************************

class _$TeachingStudent extends TeachingStudent {
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

  factory _$TeachingStudent([void Function(TeachingStudentBuilder)? updates]) =>
      (TeachingStudentBuilder()..update(updates))._build();

  _$TeachingStudent._(
      {required this.id,
      required this.username,
      required this.displayName,
      this.email,
      required this.enabled})
      : super._();
  @override
  TeachingStudent rebuild(void Function(TeachingStudentBuilder) updates) =>
      (toBuilder()..update(updates)).build();

  @override
  TeachingStudentBuilder toBuilder() => TeachingStudentBuilder()..replace(this);

  @override
  bool operator ==(Object other) {
    if (identical(other, this)) return true;
    return other is TeachingStudent &&
        id == other.id &&
        username == other.username &&
        displayName == other.displayName &&
        email == other.email &&
        enabled == other.enabled;
  }

  @override
  int get hashCode {
    var _$hash = 0;
    _$hash = $jc(_$hash, id.hashCode);
    _$hash = $jc(_$hash, username.hashCode);
    _$hash = $jc(_$hash, displayName.hashCode);
    _$hash = $jc(_$hash, email.hashCode);
    _$hash = $jc(_$hash, enabled.hashCode);
    _$hash = $jf(_$hash);
    return _$hash;
  }

  @override
  String toString() {
    return (newBuiltValueToStringHelper(r'TeachingStudent')
          ..add('id', id)
          ..add('username', username)
          ..add('displayName', displayName)
          ..add('email', email)
          ..add('enabled', enabled))
        .toString();
  }
}

class TeachingStudentBuilder
    implements Builder<TeachingStudent, TeachingStudentBuilder> {
  _$TeachingStudent? _$v;

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

  TeachingStudentBuilder() {
    TeachingStudent._defaults(this);
  }

  TeachingStudentBuilder get _$this {
    final $v = _$v;
    if ($v != null) {
      _id = $v.id;
      _username = $v.username;
      _displayName = $v.displayName;
      _email = $v.email;
      _enabled = $v.enabled;
      _$v = null;
    }
    return this;
  }

  @override
  void replace(TeachingStudent other) {
    _$v = other as _$TeachingStudent;
  }

  @override
  void update(void Function(TeachingStudentBuilder)? updates) {
    if (updates != null) updates(this);
  }

  @override
  TeachingStudent build() => _build();

  _$TeachingStudent _build() {
    final _$result = _$v ??
        _$TeachingStudent._(
          id: BuiltValueNullFieldError.checkNotNull(
              id, r'TeachingStudent', 'id'),
          username: BuiltValueNullFieldError.checkNotNull(
              username, r'TeachingStudent', 'username'),
          displayName: BuiltValueNullFieldError.checkNotNull(
              displayName, r'TeachingStudent', 'displayName'),
          email: email,
          enabled: BuiltValueNullFieldError.checkNotNull(
              enabled, r'TeachingStudent', 'enabled'),
        );
    replace(_$result);
    return _$result;
  }
}

// ignore_for_file: deprecated_member_use_from_same_package,type=lint
