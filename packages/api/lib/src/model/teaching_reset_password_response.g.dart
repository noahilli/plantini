// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'teaching_reset_password_response.dart';

// **************************************************************************
// BuiltValueGenerator
// **************************************************************************

class _$TeachingResetPasswordResponse extends TeachingResetPasswordResponse {
  @override
  final String temporaryPassword;

  factory _$TeachingResetPasswordResponse(
          [void Function(TeachingResetPasswordResponseBuilder)? updates]) =>
      (TeachingResetPasswordResponseBuilder()..update(updates))._build();

  _$TeachingResetPasswordResponse._({required this.temporaryPassword})
      : super._();
  @override
  TeachingResetPasswordResponse rebuild(
          void Function(TeachingResetPasswordResponseBuilder) updates) =>
      (toBuilder()..update(updates)).build();

  @override
  TeachingResetPasswordResponseBuilder toBuilder() =>
      TeachingResetPasswordResponseBuilder()..replace(this);

  @override
  bool operator ==(Object other) {
    if (identical(other, this)) return true;
    return other is TeachingResetPasswordResponse &&
        temporaryPassword == other.temporaryPassword;
  }

  @override
  int get hashCode {
    var _$hash = 0;
    _$hash = $jc(_$hash, temporaryPassword.hashCode);
    _$hash = $jf(_$hash);
    return _$hash;
  }

  @override
  String toString() {
    return (newBuiltValueToStringHelper(r'TeachingResetPasswordResponse')
          ..add('temporaryPassword', temporaryPassword))
        .toString();
  }
}

class TeachingResetPasswordResponseBuilder
    implements
        Builder<TeachingResetPasswordResponse,
            TeachingResetPasswordResponseBuilder> {
  _$TeachingResetPasswordResponse? _$v;

  String? _temporaryPassword;
  String? get temporaryPassword => _$this._temporaryPassword;
  set temporaryPassword(String? temporaryPassword) =>
      _$this._temporaryPassword = temporaryPassword;

  TeachingResetPasswordResponseBuilder() {
    TeachingResetPasswordResponse._defaults(this);
  }

  TeachingResetPasswordResponseBuilder get _$this {
    final $v = _$v;
    if ($v != null) {
      _temporaryPassword = $v.temporaryPassword;
      _$v = null;
    }
    return this;
  }

  @override
  void replace(TeachingResetPasswordResponse other) {
    _$v = other as _$TeachingResetPasswordResponse;
  }

  @override
  void update(void Function(TeachingResetPasswordResponseBuilder)? updates) {
    if (updates != null) updates(this);
  }

  @override
  TeachingResetPasswordResponse build() => _build();

  _$TeachingResetPasswordResponse _build() {
    final _$result = _$v ??
        _$TeachingResetPasswordResponse._(
          temporaryPassword: BuiltValueNullFieldError.checkNotNull(
              temporaryPassword,
              r'TeachingResetPasswordResponse',
              'temporaryPassword'),
        );
    replace(_$result);
    return _$result;
  }
}

// ignore_for_file: deprecated_member_use_from_same_package,type=lint
