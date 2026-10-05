// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'teaching_actor.dart';

// **************************************************************************
// BuiltValueGenerator
// **************************************************************************

class _$TeachingActor extends TeachingActor {
  @override
  final String id;
  @override
  final String displayName;
  @override
  final BuiltList<String> roles;

  factory _$TeachingActor([void Function(TeachingActorBuilder)? updates]) =>
      (TeachingActorBuilder()..update(updates))._build();

  _$TeachingActor._(
      {required this.id, required this.displayName, required this.roles})
      : super._();
  @override
  TeachingActor rebuild(void Function(TeachingActorBuilder) updates) =>
      (toBuilder()..update(updates)).build();

  @override
  TeachingActorBuilder toBuilder() => TeachingActorBuilder()..replace(this);

  @override
  bool operator ==(Object other) {
    if (identical(other, this)) return true;
    return other is TeachingActor &&
        id == other.id &&
        displayName == other.displayName &&
        roles == other.roles;
  }

  @override
  int get hashCode {
    var _$hash = 0;
    _$hash = $jc(_$hash, id.hashCode);
    _$hash = $jc(_$hash, displayName.hashCode);
    _$hash = $jc(_$hash, roles.hashCode);
    _$hash = $jf(_$hash);
    return _$hash;
  }

  @override
  String toString() {
    return (newBuiltValueToStringHelper(r'TeachingActor')
          ..add('id', id)
          ..add('displayName', displayName)
          ..add('roles', roles))
        .toString();
  }
}

class TeachingActorBuilder
    implements Builder<TeachingActor, TeachingActorBuilder> {
  _$TeachingActor? _$v;

  String? _id;
  String? get id => _$this._id;
  set id(String? id) => _$this._id = id;

  String? _displayName;
  String? get displayName => _$this._displayName;
  set displayName(String? displayName) => _$this._displayName = displayName;

  ListBuilder<String>? _roles;
  ListBuilder<String> get roles => _$this._roles ??= ListBuilder<String>();
  set roles(ListBuilder<String>? roles) => _$this._roles = roles;

  TeachingActorBuilder() {
    TeachingActor._defaults(this);
  }

  TeachingActorBuilder get _$this {
    final $v = _$v;
    if ($v != null) {
      _id = $v.id;
      _displayName = $v.displayName;
      _roles = $v.roles.toBuilder();
      _$v = null;
    }
    return this;
  }

  @override
  void replace(TeachingActor other) {
    _$v = other as _$TeachingActor;
  }

  @override
  void update(void Function(TeachingActorBuilder)? updates) {
    if (updates != null) updates(this);
  }

  @override
  TeachingActor build() => _build();

  _$TeachingActor _build() {
    _$TeachingActor _$result;
    try {
      _$result = _$v ??
          _$TeachingActor._(
            id: BuiltValueNullFieldError.checkNotNull(
                id, r'TeachingActor', 'id'),
            displayName: BuiltValueNullFieldError.checkNotNull(
                displayName, r'TeachingActor', 'displayName'),
            roles: roles.build(),
          );
    } catch (_) {
      late String _$failedField;
      try {
        _$failedField = 'roles';
        roles.build();
      } catch (e) {
        throw BuiltValueNestedFieldError(
            r'TeachingActor', _$failedField, e.toString());
      }
      rethrow;
    }
    replace(_$result);
    return _$result;
  }
}

// ignore_for_file: deprecated_member_use_from_same_package,type=lint
