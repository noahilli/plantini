// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'ecosystem.dart';

// **************************************************************************
// BuiltValueGenerator
// **************************************************************************

class _$Ecosystem extends Ecosystem {
  @override
  final String id;
  @override
  final String slug;
  @override
  final String name;
  @override
  final String? description;
  @override
  final String releaseVersion;
  @override
  final BuiltList<String>? levelIds;

  factory _$Ecosystem([void Function(EcosystemBuilder)? updates]) =>
      (EcosystemBuilder()..update(updates))._build();

  _$Ecosystem._(
      {required this.id,
      required this.slug,
      required this.name,
      this.description,
      required this.releaseVersion,
      this.levelIds})
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
        slug == other.slug &&
        name == other.name &&
        description == other.description &&
        releaseVersion == other.releaseVersion &&
        levelIds == other.levelIds;
  }

  @override
  int get hashCode {
    var _$hash = 0;
    _$hash = $jc(_$hash, id.hashCode);
    _$hash = $jc(_$hash, slug.hashCode);
    _$hash = $jc(_$hash, name.hashCode);
    _$hash = $jc(_$hash, description.hashCode);
    _$hash = $jc(_$hash, releaseVersion.hashCode);
    _$hash = $jc(_$hash, levelIds.hashCode);
    _$hash = $jf(_$hash);
    return _$hash;
  }

  @override
  String toString() {
    return (newBuiltValueToStringHelper(r'Ecosystem')
          ..add('id', id)
          ..add('slug', slug)
          ..add('name', name)
          ..add('description', description)
          ..add('releaseVersion', releaseVersion)
          ..add('levelIds', levelIds))
        .toString();
  }
}

class EcosystemBuilder implements Builder<Ecosystem, EcosystemBuilder> {
  _$Ecosystem? _$v;

  String? _id;
  String? get id => _$this._id;
  set id(String? id) => _$this._id = id;

  String? _slug;
  String? get slug => _$this._slug;
  set slug(String? slug) => _$this._slug = slug;

  String? _name;
  String? get name => _$this._name;
  set name(String? name) => _$this._name = name;

  String? _description;
  String? get description => _$this._description;
  set description(String? description) => _$this._description = description;

  String? _releaseVersion;
  String? get releaseVersion => _$this._releaseVersion;
  set releaseVersion(String? releaseVersion) =>
      _$this._releaseVersion = releaseVersion;

  ListBuilder<String>? _levelIds;
  ListBuilder<String> get levelIds =>
      _$this._levelIds ??= ListBuilder<String>();
  set levelIds(ListBuilder<String>? levelIds) => _$this._levelIds = levelIds;

  EcosystemBuilder() {
    Ecosystem._defaults(this);
  }

  EcosystemBuilder get _$this {
    final $v = _$v;
    if ($v != null) {
      _id = $v.id;
      _slug = $v.slug;
      _name = $v.name;
      _description = $v.description;
      _releaseVersion = $v.releaseVersion;
      _levelIds = $v.levelIds?.toBuilder();
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
    _$Ecosystem _$result;
    try {
      _$result = _$v ??
          _$Ecosystem._(
            id: BuiltValueNullFieldError.checkNotNull(id, r'Ecosystem', 'id'),
            slug: BuiltValueNullFieldError.checkNotNull(
                slug, r'Ecosystem', 'slug'),
            name: BuiltValueNullFieldError.checkNotNull(
                name, r'Ecosystem', 'name'),
            description: description,
            releaseVersion: BuiltValueNullFieldError.checkNotNull(
                releaseVersion, r'Ecosystem', 'releaseVersion'),
            levelIds: _levelIds?.build(),
          );
    } catch (_) {
      late String _$failedField;
      try {
        _$failedField = 'levelIds';
        _levelIds?.build();
      } catch (e) {
        throw BuiltValueNestedFieldError(
            r'Ecosystem', _$failedField, e.toString());
      }
      rethrow;
    }
    replace(_$result);
    return _$result;
  }
}

// ignore_for_file: deprecated_member_use_from_same_package,type=lint
