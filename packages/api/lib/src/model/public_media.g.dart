// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'public_media.dart';

// **************************************************************************
// BuiltValueGenerator
// **************************************************************************

class _$PublicMedia extends PublicMedia {
  @override
  final String id;
  @override
  final String url;
  @override
  final String altText;
  @override
  final String license;
  @override
  final String author;

  factory _$PublicMedia([void Function(PublicMediaBuilder)? updates]) =>
      (PublicMediaBuilder()..update(updates))._build();

  _$PublicMedia._(
      {required this.id,
      required this.url,
      required this.altText,
      required this.license,
      required this.author})
      : super._();
  @override
  PublicMedia rebuild(void Function(PublicMediaBuilder) updates) =>
      (toBuilder()..update(updates)).build();

  @override
  PublicMediaBuilder toBuilder() => PublicMediaBuilder()..replace(this);

  @override
  bool operator ==(Object other) {
    if (identical(other, this)) return true;
    return other is PublicMedia &&
        id == other.id &&
        url == other.url &&
        altText == other.altText &&
        license == other.license &&
        author == other.author;
  }

  @override
  int get hashCode {
    var _$hash = 0;
    _$hash = $jc(_$hash, id.hashCode);
    _$hash = $jc(_$hash, url.hashCode);
    _$hash = $jc(_$hash, altText.hashCode);
    _$hash = $jc(_$hash, license.hashCode);
    _$hash = $jc(_$hash, author.hashCode);
    _$hash = $jf(_$hash);
    return _$hash;
  }

  @override
  String toString() {
    return (newBuiltValueToStringHelper(r'PublicMedia')
          ..add('id', id)
          ..add('url', url)
          ..add('altText', altText)
          ..add('license', license)
          ..add('author', author))
        .toString();
  }
}

class PublicMediaBuilder implements Builder<PublicMedia, PublicMediaBuilder> {
  _$PublicMedia? _$v;

  String? _id;
  String? get id => _$this._id;
  set id(String? id) => _$this._id = id;

  String? _url;
  String? get url => _$this._url;
  set url(String? url) => _$this._url = url;

  String? _altText;
  String? get altText => _$this._altText;
  set altText(String? altText) => _$this._altText = altText;

  String? _license;
  String? get license => _$this._license;
  set license(String? license) => _$this._license = license;

  String? _author;
  String? get author => _$this._author;
  set author(String? author) => _$this._author = author;

  PublicMediaBuilder() {
    PublicMedia._defaults(this);
  }

  PublicMediaBuilder get _$this {
    final $v = _$v;
    if ($v != null) {
      _id = $v.id;
      _url = $v.url;
      _altText = $v.altText;
      _license = $v.license;
      _author = $v.author;
      _$v = null;
    }
    return this;
  }

  @override
  void replace(PublicMedia other) {
    _$v = other as _$PublicMedia;
  }

  @override
  void update(void Function(PublicMediaBuilder)? updates) {
    if (updates != null) updates(this);
  }

  @override
  PublicMedia build() => _build();

  _$PublicMedia _build() {
    final _$result = _$v ??
        _$PublicMedia._(
          id: BuiltValueNullFieldError.checkNotNull(id, r'PublicMedia', 'id'),
          url:
              BuiltValueNullFieldError.checkNotNull(url, r'PublicMedia', 'url'),
          altText: BuiltValueNullFieldError.checkNotNull(
              altText, r'PublicMedia', 'altText'),
          license: BuiltValueNullFieldError.checkNotNull(
              license, r'PublicMedia', 'license'),
          author: BuiltValueNullFieldError.checkNotNull(
              author, r'PublicMedia', 'author'),
        );
    replace(_$result);
    return _$result;
  }
}

// ignore_for_file: deprecated_member_use_from_same_package,type=lint
