// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'manifest.dart';

// **************************************************************************
// BuiltValueGenerator
// **************************************************************************

class _$Manifest extends Manifest {
  @override
  final String version;
  @override
  final DateTime releasedAt;
  @override
  final BuiltMap<String, String>? checksums;

  factory _$Manifest([void Function(ManifestBuilder)? updates]) =>
      (ManifestBuilder()..update(updates))._build();

  _$Manifest._(
      {required this.version, required this.releasedAt, this.checksums})
      : super._();
  @override
  Manifest rebuild(void Function(ManifestBuilder) updates) =>
      (toBuilder()..update(updates)).build();

  @override
  ManifestBuilder toBuilder() => ManifestBuilder()..replace(this);

  @override
  bool operator ==(Object other) {
    if (identical(other, this)) return true;
    return other is Manifest &&
        version == other.version &&
        releasedAt == other.releasedAt &&
        checksums == other.checksums;
  }

  @override
  int get hashCode {
    var _$hash = 0;
    _$hash = $jc(_$hash, version.hashCode);
    _$hash = $jc(_$hash, releasedAt.hashCode);
    _$hash = $jc(_$hash, checksums.hashCode);
    _$hash = $jf(_$hash);
    return _$hash;
  }

  @override
  String toString() {
    return (newBuiltValueToStringHelper(r'Manifest')
          ..add('version', version)
          ..add('releasedAt', releasedAt)
          ..add('checksums', checksums))
        .toString();
  }
}

class ManifestBuilder implements Builder<Manifest, ManifestBuilder> {
  _$Manifest? _$v;

  String? _version;
  String? get version => _$this._version;
  set version(String? version) => _$this._version = version;

  DateTime? _releasedAt;
  DateTime? get releasedAt => _$this._releasedAt;
  set releasedAt(DateTime? releasedAt) => _$this._releasedAt = releasedAt;

  MapBuilder<String, String>? _checksums;
  MapBuilder<String, String> get checksums =>
      _$this._checksums ??= MapBuilder<String, String>();
  set checksums(MapBuilder<String, String>? checksums) =>
      _$this._checksums = checksums;

  ManifestBuilder() {
    Manifest._defaults(this);
  }

  ManifestBuilder get _$this {
    final $v = _$v;
    if ($v != null) {
      _version = $v.version;
      _releasedAt = $v.releasedAt;
      _checksums = $v.checksums?.toBuilder();
      _$v = null;
    }
    return this;
  }

  @override
  void replace(Manifest other) {
    _$v = other as _$Manifest;
  }

  @override
  void update(void Function(ManifestBuilder)? updates) {
    if (updates != null) updates(this);
  }

  @override
  Manifest build() => _build();

  _$Manifest _build() {
    _$Manifest _$result;
    try {
      _$result = _$v ??
          _$Manifest._(
            version: BuiltValueNullFieldError.checkNotNull(
                version, r'Manifest', 'version'),
            releasedAt: BuiltValueNullFieldError.checkNotNull(
                releasedAt, r'Manifest', 'releasedAt'),
            checksums: _checksums?.build(),
          );
    } catch (_) {
      late String _$failedField;
      try {
        _$failedField = 'checksums';
        _checksums?.build();
      } catch (e) {
        throw BuiltValueNestedFieldError(
            r'Manifest', _$failedField, e.toString());
      }
      rethrow;
    }
    replace(_$result);
    return _$result;
  }
}

// ignore_for_file: deprecated_member_use_from_same_package,type=lint
