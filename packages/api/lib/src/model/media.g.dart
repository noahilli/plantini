// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'media.dart';

// **************************************************************************
// BuiltValueGenerator
// **************************************************************************

class _$Media extends Media {
  @override
  final String id;
  @override
  final String title;
  @override
  final String? caption;
  @override
  final String? license;
  @override
  final String? author;
  @override
  final String url;

  factory _$Media([void Function(MediaBuilder)? updates]) =>
      (MediaBuilder()..update(updates))._build();

  _$Media._(
      {required this.id,
      required this.title,
      this.caption,
      this.license,
      this.author,
      required this.url})
      : super._();
  @override
  Media rebuild(void Function(MediaBuilder) updates) =>
      (toBuilder()..update(updates)).build();

  @override
  MediaBuilder toBuilder() => MediaBuilder()..replace(this);

  @override
  bool operator ==(Object other) {
    if (identical(other, this)) return true;
    return other is Media &&
        id == other.id &&
        title == other.title &&
        caption == other.caption &&
        license == other.license &&
        author == other.author &&
        url == other.url;
  }

  @override
  int get hashCode {
    var _$hash = 0;
    _$hash = $jc(_$hash, id.hashCode);
    _$hash = $jc(_$hash, title.hashCode);
    _$hash = $jc(_$hash, caption.hashCode);
    _$hash = $jc(_$hash, license.hashCode);
    _$hash = $jc(_$hash, author.hashCode);
    _$hash = $jc(_$hash, url.hashCode);
    _$hash = $jf(_$hash);
    return _$hash;
  }

  @override
  String toString() {
    return (newBuiltValueToStringHelper(r'Media')
          ..add('id', id)
          ..add('title', title)
          ..add('caption', caption)
          ..add('license', license)
          ..add('author', author)
          ..add('url', url))
        .toString();
  }
}

class MediaBuilder implements Builder<Media, MediaBuilder> {
  _$Media? _$v;

  String? _id;
  String? get id => _$this._id;
  set id(String? id) => _$this._id = id;

  String? _title;
  String? get title => _$this._title;
  set title(String? title) => _$this._title = title;

  String? _caption;
  String? get caption => _$this._caption;
  set caption(String? caption) => _$this._caption = caption;

  String? _license;
  String? get license => _$this._license;
  set license(String? license) => _$this._license = license;

  String? _author;
  String? get author => _$this._author;
  set author(String? author) => _$this._author = author;

  String? _url;
  String? get url => _$this._url;
  set url(String? url) => _$this._url = url;

  MediaBuilder() {
    Media._defaults(this);
  }

  MediaBuilder get _$this {
    final $v = _$v;
    if ($v != null) {
      _id = $v.id;
      _title = $v.title;
      _caption = $v.caption;
      _license = $v.license;
      _author = $v.author;
      _url = $v.url;
      _$v = null;
    }
    return this;
  }

  @override
  void replace(Media other) {
    _$v = other as _$Media;
  }

  @override
  void update(void Function(MediaBuilder)? updates) {
    if (updates != null) updates(this);
  }

  @override
  Media build() => _build();

  _$Media _build() {
    final _$result = _$v ??
        _$Media._(
          id: BuiltValueNullFieldError.checkNotNull(id, r'Media', 'id'),
          title:
              BuiltValueNullFieldError.checkNotNull(title, r'Media', 'title'),
          caption: caption,
          license: license,
          author: author,
          url: BuiltValueNullFieldError.checkNotNull(url, r'Media', 'url'),
        );
    replace(_$result);
    return _$result;
  }
}

// ignore_for_file: deprecated_member_use_from_same_package,type=lint
