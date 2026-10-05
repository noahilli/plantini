// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'teaching_create_class_request.dart';

// **************************************************************************
// BuiltValueGenerator
// **************************************************************************

class _$TeachingCreateClassRequest extends TeachingCreateClassRequest {
  @override
  final String name;
  @override
  final String? description;

  factory _$TeachingCreateClassRequest(
          [void Function(TeachingCreateClassRequestBuilder)? updates]) =>
      (TeachingCreateClassRequestBuilder()..update(updates))._build();

  _$TeachingCreateClassRequest._({required this.name, this.description})
      : super._();
  @override
  TeachingCreateClassRequest rebuild(
          void Function(TeachingCreateClassRequestBuilder) updates) =>
      (toBuilder()..update(updates)).build();

  @override
  TeachingCreateClassRequestBuilder toBuilder() =>
      TeachingCreateClassRequestBuilder()..replace(this);

  @override
  bool operator ==(Object other) {
    if (identical(other, this)) return true;
    return other is TeachingCreateClassRequest &&
        name == other.name &&
        description == other.description;
  }

  @override
  int get hashCode {
    var _$hash = 0;
    _$hash = $jc(_$hash, name.hashCode);
    _$hash = $jc(_$hash, description.hashCode);
    _$hash = $jf(_$hash);
    return _$hash;
  }

  @override
  String toString() {
    return (newBuiltValueToStringHelper(r'TeachingCreateClassRequest')
          ..add('name', name)
          ..add('description', description))
        .toString();
  }
}

class TeachingCreateClassRequestBuilder
    implements
        Builder<TeachingCreateClassRequest, TeachingCreateClassRequestBuilder> {
  _$TeachingCreateClassRequest? _$v;

  String? _name;
  String? get name => _$this._name;
  set name(String? name) => _$this._name = name;

  String? _description;
  String? get description => _$this._description;
  set description(String? description) => _$this._description = description;

  TeachingCreateClassRequestBuilder() {
    TeachingCreateClassRequest._defaults(this);
  }

  TeachingCreateClassRequestBuilder get _$this {
    final $v = _$v;
    if ($v != null) {
      _name = $v.name;
      _description = $v.description;
      _$v = null;
    }
    return this;
  }

  @override
  void replace(TeachingCreateClassRequest other) {
    _$v = other as _$TeachingCreateClassRequest;
  }

  @override
  void update(void Function(TeachingCreateClassRequestBuilder)? updates) {
    if (updates != null) updates(this);
  }

  @override
  TeachingCreateClassRequest build() => _build();

  _$TeachingCreateClassRequest _build() {
    final _$result = _$v ??
        _$TeachingCreateClassRequest._(
          name: BuiltValueNullFieldError.checkNotNull(
              name, r'TeachingCreateClassRequest', 'name'),
          description: description,
        );
    replace(_$result);
    return _$result;
  }
}

// ignore_for_file: deprecated_member_use_from_same_package,type=lint
