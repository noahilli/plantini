// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'content_manifest.dart';

// **************************************************************************
// BuiltValueGenerator
// **************************************************************************

class _$ContentManifest extends ContentManifest {
  @override
  final String version;
  @override
  final DateTime releasedAt;
  @override
  final String schemaVersion;
  @override
  final String minimumAppVersion;
  @override
  final String? signature;
  @override
  final BuiltList<ContentPackage> packages;

  factory _$ContentManifest([void Function(ContentManifestBuilder)? updates]) =>
      (ContentManifestBuilder()..update(updates))._build();

  _$ContentManifest._(
      {required this.version,
      required this.releasedAt,
      required this.schemaVersion,
      required this.minimumAppVersion,
      this.signature,
      required this.packages})
      : super._();
  @override
  ContentManifest rebuild(void Function(ContentManifestBuilder) updates) =>
      (toBuilder()..update(updates)).build();

  @override
  ContentManifestBuilder toBuilder() => ContentManifestBuilder()..replace(this);

  @override
  bool operator ==(Object other) {
    if (identical(other, this)) return true;
    return other is ContentManifest &&
        version == other.version &&
        releasedAt == other.releasedAt &&
        schemaVersion == other.schemaVersion &&
        minimumAppVersion == other.minimumAppVersion &&
        signature == other.signature &&
        packages == other.packages;
  }

  @override
  int get hashCode {
    var _$hash = 0;
    _$hash = $jc(_$hash, version.hashCode);
    _$hash = $jc(_$hash, releasedAt.hashCode);
    _$hash = $jc(_$hash, schemaVersion.hashCode);
    _$hash = $jc(_$hash, minimumAppVersion.hashCode);
    _$hash = $jc(_$hash, signature.hashCode);
    _$hash = $jc(_$hash, packages.hashCode);
    _$hash = $jf(_$hash);
    return _$hash;
  }

  @override
  String toString() {
    return (newBuiltValueToStringHelper(r'ContentManifest')
          ..add('version', version)
          ..add('releasedAt', releasedAt)
          ..add('schemaVersion', schemaVersion)
          ..add('minimumAppVersion', minimumAppVersion)
          ..add('signature', signature)
          ..add('packages', packages))
        .toString();
  }
}

class ContentManifestBuilder
    implements Builder<ContentManifest, ContentManifestBuilder> {
  _$ContentManifest? _$v;

  String? _version;
  String? get version => _$this._version;
  set version(String? version) => _$this._version = version;

  DateTime? _releasedAt;
  DateTime? get releasedAt => _$this._releasedAt;
  set releasedAt(DateTime? releasedAt) => _$this._releasedAt = releasedAt;

  String? _schemaVersion;
  String? get schemaVersion => _$this._schemaVersion;
  set schemaVersion(String? schemaVersion) =>
      _$this._schemaVersion = schemaVersion;

  String? _minimumAppVersion;
  String? get minimumAppVersion => _$this._minimumAppVersion;
  set minimumAppVersion(String? minimumAppVersion) =>
      _$this._minimumAppVersion = minimumAppVersion;

  String? _signature;
  String? get signature => _$this._signature;
  set signature(String? signature) => _$this._signature = signature;

  ListBuilder<ContentPackage>? _packages;
  ListBuilder<ContentPackage> get packages =>
      _$this._packages ??= ListBuilder<ContentPackage>();
  set packages(ListBuilder<ContentPackage>? packages) =>
      _$this._packages = packages;

  ContentManifestBuilder() {
    ContentManifest._defaults(this);
  }

  ContentManifestBuilder get _$this {
    final $v = _$v;
    if ($v != null) {
      _version = $v.version;
      _releasedAt = $v.releasedAt;
      _schemaVersion = $v.schemaVersion;
      _minimumAppVersion = $v.minimumAppVersion;
      _signature = $v.signature;
      _packages = $v.packages.toBuilder();
      _$v = null;
    }
    return this;
  }

  @override
  void replace(ContentManifest other) {
    _$v = other as _$ContentManifest;
  }

  @override
  void update(void Function(ContentManifestBuilder)? updates) {
    if (updates != null) updates(this);
  }

  @override
  ContentManifest build() => _build();

  _$ContentManifest _build() {
    _$ContentManifest _$result;
    try {
      _$result = _$v ??
          _$ContentManifest._(
            version: BuiltValueNullFieldError.checkNotNull(
                version, r'ContentManifest', 'version'),
            releasedAt: BuiltValueNullFieldError.checkNotNull(
                releasedAt, r'ContentManifest', 'releasedAt'),
            schemaVersion: BuiltValueNullFieldError.checkNotNull(
                schemaVersion, r'ContentManifest', 'schemaVersion'),
            minimumAppVersion: BuiltValueNullFieldError.checkNotNull(
                minimumAppVersion, r'ContentManifest', 'minimumAppVersion'),
            signature: signature,
            packages: packages.build(),
          );
    } catch (_) {
      late String _$failedField;
      try {
        _$failedField = 'packages';
        packages.build();
      } catch (e) {
        throw BuiltValueNestedFieldError(
            r'ContentManifest', _$failedField, e.toString());
      }
      rethrow;
    }
    replace(_$result);
    return _$result;
  }
}

// ignore_for_file: deprecated_member_use_from_same_package,type=lint
