// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'ecosystem.dart';

// **************************************************************************
// BuiltValueGenerator
// **************************************************************************

class _$Ecosystem extends Ecosystem {
  @override
  final String id;
  @override
  final String name;
  @override
  final String? description;

  factory _$Ecosystem([void Function(EcosystemBuilder)? updates]) =>
      (EcosystemBuilder()..update(updates))._build();

  _$Ecosystem._({required this.id, required this.name, this.description})
      : super._();
  @override
  Ecosystem rebuild(void Function(EcosystemBuilder) updates) =>
      (toBuilder()..update(updates)).build();

  @override
  EcosystemBuilder toBuilder() => EcosystemBuilder()..replace(this);

  @override
  bool operator ==(Object other) {
    if (identical(other, this)) return true;
    return other is Ecosystem &&
        id == other.id &&
        name == other.name &&
        description == other.description;
  }

  @override
  int get hashCode {
    var _$hash = 0;
    _$hash = $jc(_$hash, id.hashCode);
    _$hash = $jc(_$hash, name.hashCode);
    _$hash = $jc(_$hash, description.hashCode);
    _$hash = $jf(_$hash);
    return _$hash;
  }

  @override
  String toString() {
    return (newBuiltValueToStringHelper(r'Ecosystem')
          ..add('id', id)
          ..add('name', name)
          ..add('description', description))
        .toString();
  }
}

class EcosystemBuilder implements Builder<Ecosystem, EcosystemBuilder> {
  _$Ecosystem? _$v;

  String? _id;
  String? get id => _$this._id;
  set id(String? id) => _$this._id = id;

  String? _name;
  String? get name => _$this._name;
  set name(String? name) => _$this._name = name;

  String? _description;
  String? get description => _$this._description;
  set description(String? description) => _$this._description = description;

  EcosystemBuilder() {
    Ecosystem._defaults(this);
  }

  EcosystemBuilder get _$this {
    final $v = _$v;
    if ($v != null) {
      _id = $v.id;
      _name = $v.name;
      _description = $v.description;
      _$v = null;
    }
    return this;
  }

  @override
  void replace(Ecosystem other) {
    _$v = other as _$Ecosystem;
  }

  @override
  void update(void Function(EcosystemBuilder)? updates) {
    if (updates != null) updates(this);
  }

  @override
  Ecosystem build() => _build();

  _$Ecosystem _build() {
    final _$result = _$v ??
        _$Ecosystem._(
          id: BuiltValueNullFieldError.checkNotNull(id, r'Ecosystem', 'id'),
          name:
              BuiltValueNullFieldError.checkNotNull(name, r'Ecosystem', 'name'),
          description: description,
        );
    replace(_$result);
    return _$result;
  }
}

// ignore_for_file: deprecated_member_use_from_same_package,type=lint
