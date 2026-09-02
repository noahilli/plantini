// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'update_profile_request.dart';

// **************************************************************************
// BuiltValueGenerator
// **************************************************************************

class _$UpdateProfileRequest extends UpdateProfileRequest {
  @override
  final String? displayName;
  @override
  final String? locale;

  factory _$UpdateProfileRequest(
          [void Function(UpdateProfileRequestBuilder)? updates]) =>
      (UpdateProfileRequestBuilder()..update(updates))._build();

  _$UpdateProfileRequest._({this.displayName, this.locale}) : super._();
  @override
  UpdateProfileRequest rebuild(
          void Function(UpdateProfileRequestBuilder) updates) =>
      (toBuilder()..update(updates)).build();

  @override
  UpdateProfileRequestBuilder toBuilder() =>
      UpdateProfileRequestBuilder()..replace(this);

  @override
  bool operator ==(Object other) {
    if (identical(other, this)) return true;
    return other is UpdateProfileRequest &&
        displayName == other.displayName &&
        locale == other.locale;
  }

  @override
  int get hashCode {
    var _$hash = 0;
    _$hash = $jc(_$hash, displayName.hashCode);
    _$hash = $jc(_$hash, locale.hashCode);
    _$hash = $jf(_$hash);
    return _$hash;
  }

  @override
  String toString() {
    return (newBuiltValueToStringHelper(r'UpdateProfileRequest')
          ..add('displayName', displayName)
          ..add('locale', locale))
        .toString();
  }
}

class UpdateProfileRequestBuilder
    implements Builder<UpdateProfileRequest, UpdateProfileRequestBuilder> {
  _$UpdateProfileRequest? _$v;

  String? _displayName;
  String? get displayName => _$this._displayName;
  set displayName(String? displayName) => _$this._displayName = displayName;

  String? _locale;
  String? get locale => _$this._locale;
  set locale(String? locale) => _$this._locale = locale;

  UpdateProfileRequestBuilder() {
    UpdateProfileRequest._defaults(this);
  }

  UpdateProfileRequestBuilder get _$this {
    final $v = _$v;
    if ($v != null) {
      _displayName = $v.displayName;
      _locale = $v.locale;
      _$v = null;
    }
    return this;
  }

  @override
  void replace(UpdateProfileRequest other) {
    _$v = other as _$UpdateProfileRequest;
  }

  @override
  void update(void Function(UpdateProfileRequestBuilder)? updates) {
    if (updates != null) updates(this);
  }

  @override
  UpdateProfileRequest build() => _build();

  _$UpdateProfileRequest _build() {
    final _$result = _$v ??
        _$UpdateProfileRequest._(
          displayName: displayName,
          locale: locale,
        );
    replace(_$result);
    return _$result;
  }
}

// ignore_for_file: deprecated_member_use_from_same_package,type=lint
