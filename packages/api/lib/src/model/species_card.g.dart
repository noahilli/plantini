// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'species_card.dart';

// **************************************************************************
// BuiltValueGenerator
// **************************************************************************

class _$SpeciesCard extends SpeciesCard {
  @override
  final String key;
  @override
  final String scientificName;
  @override
  final String? commonName;
  @override
  final String? summary;
  @override
  final String? summaryLanguage;
  @override
  final String? summarySource;
  @override
  final String? summaryLicense;
  @override
  final PublicMedia? photo;
  @override
  final CollectionShare? collectedShare;

  factory _$SpeciesCard([void Function(SpeciesCardBuilder)? updates]) =>
      (SpeciesCardBuilder()..update(updates))._build();

  _$SpeciesCard._(
      {required this.key,
      required this.scientificName,
      this.commonName,
      this.summary,
      this.summaryLanguage,
      this.summarySource,
      this.summaryLicense,
      this.photo,
      this.collectedShare})
      : super._();
  @override
  SpeciesCard rebuild(void Function(SpeciesCardBuilder) updates) =>
      (toBuilder()..update(updates)).build();

  @override
  SpeciesCardBuilder toBuilder() => SpeciesCardBuilder()..replace(this);

  @override
  bool operator ==(Object other) {
    if (identical(other, this)) return true;
    return other is SpeciesCard &&
        key == other.key &&
        scientificName == other.scientificName &&
        commonName == other.commonName &&
        summary == other.summary &&
        summaryLanguage == other.summaryLanguage &&
        summarySource == other.summarySource &&
        summaryLicense == other.summaryLicense &&
        photo == other.photo &&
        collectedShare == other.collectedShare;
  }

  @override
  int get hashCode {
    var _$hash = 0;
    _$hash = $jc(_$hash, key.hashCode);
    _$hash = $jc(_$hash, scientificName.hashCode);
    _$hash = $jc(_$hash, commonName.hashCode);
    _$hash = $jc(_$hash, summary.hashCode);
    _$hash = $jc(_$hash, summaryLanguage.hashCode);
    _$hash = $jc(_$hash, summarySource.hashCode);
    _$hash = $jc(_$hash, summaryLicense.hashCode);
    _$hash = $jc(_$hash, photo.hashCode);
    _$hash = $jc(_$hash, collectedShare.hashCode);
    _$hash = $jf(_$hash);
    return _$hash;
  }

  @override
  String toString() {
    return (newBuiltValueToStringHelper(r'SpeciesCard')
          ..add('key', key)
          ..add('scientificName', scientificName)
          ..add('commonName', commonName)
          ..add('summary', summary)
          ..add('summaryLanguage', summaryLanguage)
          ..add('summarySource', summarySource)
          ..add('summaryLicense', summaryLicense)
          ..add('photo', photo)
          ..add('collectedShare', collectedShare))
        .toString();
  }
}

class SpeciesCardBuilder implements Builder<SpeciesCard, SpeciesCardBuilder> {
  _$SpeciesCard? _$v;

  String? _key;
  String? get key => _$this._key;
  set key(String? key) => _$this._key = key;

  String? _scientificName;
  String? get scientificName => _$this._scientificName;
  set scientificName(String? scientificName) =>
      _$this._scientificName = scientificName;

  String? _commonName;
  String? get commonName => _$this._commonName;
  set commonName(String? commonName) => _$this._commonName = commonName;

  String? _summary;
  String? get summary => _$this._summary;
  set summary(String? summary) => _$this._summary = summary;

  String? _summaryLanguage;
  String? get summaryLanguage => _$this._summaryLanguage;
  set summaryLanguage(String? summaryLanguage) =>
      _$this._summaryLanguage = summaryLanguage;

  String? _summarySource;
  String? get summarySource => _$this._summarySource;
  set summarySource(String? summarySource) =>
      _$this._summarySource = summarySource;

  String? _summaryLicense;
  String? get summaryLicense => _$this._summaryLicense;
  set summaryLicense(String? summaryLicense) =>
      _$this._summaryLicense = summaryLicense;

  PublicMediaBuilder? _photo;
  PublicMediaBuilder get photo => _$this._photo ??= PublicMediaBuilder();
  set photo(PublicMediaBuilder? photo) => _$this._photo = photo;

  CollectionShareBuilder? _collectedShare;
  CollectionShareBuilder get collectedShare =>
      _$this._collectedShare ??= CollectionShareBuilder();
  set collectedShare(CollectionShareBuilder? collectedShare) =>
      _$this._collectedShare = collectedShare;

  SpeciesCardBuilder() {
    SpeciesCard._defaults(this);
  }

  SpeciesCardBuilder get _$this {
    final $v = _$v;
    if ($v != null) {
      _key = $v.key;
      _scientificName = $v.scientificName;
      _commonName = $v.commonName;
      _summary = $v.summary;
      _summaryLanguage = $v.summaryLanguage;
      _summarySource = $v.summarySource;
      _summaryLicense = $v.summaryLicense;
      _photo = $v.photo?.toBuilder();
      _collectedShare = $v.collectedShare?.toBuilder();
      _$v = null;
    }
    return this;
  }

  @override
  void replace(SpeciesCard other) {
    _$v = other as _$SpeciesCard;
  }

  @override
  void update(void Function(SpeciesCardBuilder)? updates) {
    if (updates != null) updates(this);
  }

  @override
  SpeciesCard build() => _build();

  _$SpeciesCard _build() {
    _$SpeciesCard _$result;
    try {
      _$result = _$v ??
          _$SpeciesCard._(
            key: BuiltValueNullFieldError.checkNotNull(
                key, r'SpeciesCard', 'key'),
            scientificName: BuiltValueNullFieldError.checkNotNull(
                scientificName, r'SpeciesCard', 'scientificName'),
            commonName: commonName,
            summary: summary,
            summaryLanguage: summaryLanguage,
            summarySource: summarySource,
            summaryLicense: summaryLicense,
            photo: _photo?.build(),
            collectedShare: _collectedShare?.build(),
          );
    } catch (_) {
      late String _$failedField;
      try {
        _$failedField = 'photo';
        _photo?.build();
        _$failedField = 'collectedShare';
        _collectedShare?.build();
      } catch (e) {
        throw BuiltValueNestedFieldError(
            r'SpeciesCard', _$failedField, e.toString());
      }
      rethrow;
    }
    replace(_$result);
    return _$result;
  }
}

// ignore_for_file: deprecated_member_use_from_same_package,type=lint
