// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'teaching_create_student_request.dart';

// **************************************************************************
// BuiltValueGenerator
// **************************************************************************

class _$TeachingCreateStudentRequest extends TeachingCreateStudentRequest {
  @override
  final String username;
  @override
  final String displayName;
  @override
  final String? email;

  factory _$TeachingCreateStudentRequest(
          [void Function(TeachingCreateStudentRequestBuilder)? updates]) =>
      (TeachingCreateStudentRequestBuilder()..update(updates))._build();

  _$TeachingCreateStudentRequest._(
      {required this.username, required this.displayName, this.email})
      : super._();
  @override
  TeachingCreateStudentRequest rebuild(
          void Function(TeachingCreateStudentRequestBuilder) updates) =>
      (toBuilder()..update(updates)).build();

  @override
  TeachingCreateStudentRequestBuilder toBuilder() =>
      TeachingCreateStudentRequestBuilder()..replace(this);

  @override
  bool operator ==(Object other) {
    if (identical(other, this)) return true;
    return other is TeachingCreateStudentRequest &&
        username == other.username &&
        displayName == other.displayName &&
        email == other.email;
  }

  @override
  int get hashCode {
    var _$hash = 0;
    _$hash = $jc(_$hash, username.hashCode);
    _$hash = $jc(_$hash, displayName.hashCode);
    _$hash = $jc(_$hash, email.hashCode);
    _$hash = $jf(_$hash);
    return _$hash;
  }

  @override
  String toString() {
    return (newBuiltValueToStringHelper(r'TeachingCreateStudentRequest')
          ..add('username', username)
          ..add('displayName', displayName)
          ..add('email', email))
        .toString();
  }
}

class TeachingCreateStudentRequestBuilder
    implements
        Builder<TeachingCreateStudentRequest,
            TeachingCreateStudentRequestBuilder> {
  _$TeachingCreateStudentRequest? _$v;

  String? _username;
  String? get username => _$this._username;
  set username(String? username) => _$this._username = username;

  String? _displayName;
  String? get displayName => _$this._displayName;
  set displayName(String? displayName) => _$this._displayName = displayName;

  String? _email;
  String? get email => _$this._email;
  set email(String? email) => _$this._email = email;

  TeachingCreateStudentRequestBuilder() {
    TeachingCreateStudentRequest._defaults(this);
  }

  TeachingCreateStudentRequestBuilder get _$this {
    final $v = _$v;
    if ($v != null) {
      _username = $v.username;
      _displayName = $v.displayName;
      _email = $v.email;
      _$v = null;
    }
    return this;
  }

  @override
  void replace(TeachingCreateStudentRequest other) {
    _$v = other as _$TeachingCreateStudentRequest;
  }

  @override
  void update(void Function(TeachingCreateStudentRequestBuilder)? updates) {
    if (updates != null) updates(this);
  }

  @override
  TeachingCreateStudentRequest build() => _build();

  _$TeachingCreateStudentRequest _build() {
    final _$result = _$v ??
        _$TeachingCreateStudentRequest._(
          username: BuiltValueNullFieldError.checkNotNull(
              username, r'TeachingCreateStudentRequest', 'username'),
          displayName: BuiltValueNullFieldError.checkNotNull(
              displayName, r'TeachingCreateStudentRequest', 'displayName'),
          email: email,
        );
    replace(_$result);
    return _$result;
  }
}

// ignore_for_file: deprecated_member_use_from_same_package,type=lint
