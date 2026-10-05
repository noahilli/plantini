// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'teaching_update_student_request.dart';

// **************************************************************************
// BuiltValueGenerator
// **************************************************************************

class _$TeachingUpdateStudentRequest extends TeachingUpdateStudentRequest {
  @override
  final bool enabled;

  factory _$TeachingUpdateStudentRequest(
          [void Function(TeachingUpdateStudentRequestBuilder)? updates]) =>
      (TeachingUpdateStudentRequestBuilder()..update(updates))._build();

  _$TeachingUpdateStudentRequest._({required this.enabled}) : super._();
  @override
  TeachingUpdateStudentRequest rebuild(
          void Function(TeachingUpdateStudentRequestBuilder) updates) =>
      (toBuilder()..update(updates)).build();

  @override
  TeachingUpdateStudentRequestBuilder toBuilder() =>
      TeachingUpdateStudentRequestBuilder()..replace(this);

  @override
  bool operator ==(Object other) {
    if (identical(other, this)) return true;
    return other is TeachingUpdateStudentRequest && enabled == other.enabled;
  }

  @override
  int get hashCode {
    var _$hash = 0;
    _$hash = $jc(_$hash, enabled.hashCode);
    _$hash = $jf(_$hash);
    return _$hash;
  }

  @override
  String toString() {
    return (newBuiltValueToStringHelper(r'TeachingUpdateStudentRequest')
          ..add('enabled', enabled))
        .toString();
  }
}

class TeachingUpdateStudentRequestBuilder
    implements
        Builder<TeachingUpdateStudentRequest,
            TeachingUpdateStudentRequestBuilder> {
  _$TeachingUpdateStudentRequest? _$v;

  bool? _enabled;
  bool? get enabled => _$this._enabled;
  set enabled(bool? enabled) => _$this._enabled = enabled;

  TeachingUpdateStudentRequestBuilder() {
    TeachingUpdateStudentRequest._defaults(this);
  }

  TeachingUpdateStudentRequestBuilder get _$this {
    final $v = _$v;
    if ($v != null) {
      _enabled = $v.enabled;
      _$v = null;
    }
    return this;
  }

  @override
  void replace(TeachingUpdateStudentRequest other) {
    _$v = other as _$TeachingUpdateStudentRequest;
  }

  @override
  void update(void Function(TeachingUpdateStudentRequestBuilder)? updates) {
    if (updates != null) updates(this);
  }

  @override
  TeachingUpdateStudentRequest build() => _build();

  _$TeachingUpdateStudentRequest _build() {
    final _$result = _$v ??
        _$TeachingUpdateStudentRequest._(
          enabled: BuiltValueNullFieldError.checkNotNull(
              enabled, r'TeachingUpdateStudentRequest', 'enabled'),
        );
    replace(_$result);
    return _$result;
  }
}

// ignore_for_file: deprecated_member_use_from_same_package,type=lint
