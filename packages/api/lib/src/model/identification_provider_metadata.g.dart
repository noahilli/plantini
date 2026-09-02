// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'identification_provider_metadata.dart';

// **************************************************************************
// BuiltValueGenerator
// **************************************************************************

class _$IdentificationProviderMetadata extends IdentificationProviderMetadata {
  @override
  final String provider;
  @override
  final String modelVersion;
  @override
  final String floraVersion;

  factory _$IdentificationProviderMetadata(
          [void Function(IdentificationProviderMetadataBuilder)? updates]) =>
      (IdentificationProviderMetadataBuilder()..update(updates))._build();

  _$IdentificationProviderMetadata._(
      {required this.provider,
      required this.modelVersion,
      required this.floraVersion})
      : super._();
  @override
  IdentificationProviderMetadata rebuild(
          void Function(IdentificationProviderMetadataBuilder) updates) =>
      (toBuilder()..update(updates)).build();

  @override
  IdentificationProviderMetadataBuilder toBuilder() =>
      IdentificationProviderMetadataBuilder()..replace(this);

  @override
  bool operator ==(Object other) {
    if (identical(other, this)) return true;
    return other is IdentificationProviderMetadata &&
        provider == other.provider &&
        modelVersion == other.modelVersion &&
        floraVersion == other.floraVersion;
  }

  @override
  int get hashCode {
    var _$hash = 0;
    _$hash = $jc(_$hash, provider.hashCode);
    _$hash = $jc(_$hash, modelVersion.hashCode);
    _$hash = $jc(_$hash, floraVersion.hashCode);
    _$hash = $jf(_$hash);
    return _$hash;
  }

  @override
  String toString() {
    return (newBuiltValueToStringHelper(r'IdentificationProviderMetadata')
          ..add('provider', provider)
          ..add('modelVersion', modelVersion)
          ..add('floraVersion', floraVersion))
        .toString();
  }
}

class IdentificationProviderMetadataBuilder
    implements
        Builder<IdentificationProviderMetadata,
            IdentificationProviderMetadataBuilder> {
  _$IdentificationProviderMetadata? _$v;

  String? _provider;
  String? get provider => _$this._provider;
  set provider(String? provider) => _$this._provider = provider;

  String? _modelVersion;
  String? get modelVersion => _$this._modelVersion;
  set modelVersion(String? modelVersion) => _$this._modelVersion = modelVersion;

  String? _floraVersion;
  String? get floraVersion => _$this._floraVersion;
  set floraVersion(String? floraVersion) => _$this._floraVersion = floraVersion;

  IdentificationProviderMetadataBuilder() {
    IdentificationProviderMetadata._defaults(this);
  }

  IdentificationProviderMetadataBuilder get _$this {
    final $v = _$v;
    if ($v != null) {
      _provider = $v.provider;
      _modelVersion = $v.modelVersion;
      _floraVersion = $v.floraVersion;
      _$v = null;
    }
    return this;
  }

  @override
  void replace(IdentificationProviderMetadata other) {
    _$v = other as _$IdentificationProviderMetadata;
  }

  @override
  void update(void Function(IdentificationProviderMetadataBuilder)? updates) {
    if (updates != null) updates(this);
  }

  @override
  IdentificationProviderMetadata build() => _build();

  _$IdentificationProviderMetadata _build() {
    final _$result = _$v ??
        _$IdentificationProviderMetadata._(
          provider: BuiltValueNullFieldError.checkNotNull(
              provider, r'IdentificationProviderMetadata', 'provider'),
          modelVersion: BuiltValueNullFieldError.checkNotNull(
              modelVersion, r'IdentificationProviderMetadata', 'modelVersion'),
          floraVersion: BuiltValueNullFieldError.checkNotNull(
              floraVersion, r'IdentificationProviderMetadata', 'floraVersion'),
        );
    replace(_$result);
    return _$result;
  }
}

// ignore_for_file: deprecated_member_use_from_same_package,type=lint
