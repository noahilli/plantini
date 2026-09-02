// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'content_package.dart';

// **************************************************************************
// BuiltValueGenerator
// **************************************************************************

class _$ContentPackage extends ContentPackage {
  @override
  final String id;
  @override
  final String url;
  @override
  final String sha256;
  @override
  final int bytes;

  factory _$ContentPackage([void Function(ContentPackageBuilder)? updates]) =>
      (ContentPackageBuilder()..update(updates))._build();

  _$ContentPackage._(
      {required this.id,
      required this.url,
      required this.sha256,
      required this.bytes})
      : super._();
  @override
  ContentPackage rebuild(void Function(ContentPackageBuilder) updates) =>
      (toBuilder()..update(updates)).build();

  @override
  ContentPackageBuilder toBuilder() => ContentPackageBuilder()..replace(this);

  @override
  bool operator ==(Object other) {
    if (identical(other, this)) return true;
    return other is ContentPackage &&
        id == other.id &&
        url == other.url &&
        sha256 == other.sha256 &&
        bytes == other.bytes;
  }

  @override
  int get hashCode {
    var _$hash = 0;
    _$hash = $jc(_$hash, id.hashCode);
    _$hash = $jc(_$hash, url.hashCode);
    _$hash = $jc(_$hash, sha256.hashCode);
    _$hash = $jc(_$hash, bytes.hashCode);
    _$hash = $jf(_$hash);
    return _$hash;
  }

  @override
  String toString() {
    return (newBuiltValueToStringHelper(r'ContentPackage')
          ..add('id', id)
          ..add('url', url)
          ..add('sha256', sha256)
          ..add('bytes', bytes))
        .toString();
  }
}

class ContentPackageBuilder
    implements Builder<ContentPackage, ContentPackageBuilder> {
  _$ContentPackage? _$v;

  String? _id;
  String? get id => _$this._id;
  set id(String? id) => _$this._id = id;

  String? _url;
  String? get url => _$this._url;
  set url(String? url) => _$this._url = url;

  String? _sha256;
  String? get sha256 => _$this._sha256;
  set sha256(String? sha256) => _$this._sha256 = sha256;

  int? _bytes;
  int? get bytes => _$this._bytes;
  set bytes(int? bytes) => _$this._bytes = bytes;

  ContentPackageBuilder() {
    ContentPackage._defaults(this);
  }

  ContentPackageBuilder get _$this {
    final $v = _$v;
    if ($v != null) {
      _id = $v.id;
      _url = $v.url;
      _sha256 = $v.sha256;
      _bytes = $v.bytes;
      _$v = null;
    }
    return this;
  }

  @override
  void replace(ContentPackage other) {
    _$v = other as _$ContentPackage;
  }

  @override
  void update(void Function(ContentPackageBuilder)? updates) {
    if (updates != null) updates(this);
  }

  @override
  ContentPackage build() => _build();

  _$ContentPackage _build() {
    final _$result = _$v ??
        _$ContentPackage._(
          id: BuiltValueNullFieldError.checkNotNull(
              id, r'ContentPackage', 'id'),
          url: BuiltValueNullFieldError.checkNotNull(
              url, r'ContentPackage', 'url'),
          sha256: BuiltValueNullFieldError.checkNotNull(
              sha256, r'ContentPackage', 'sha256'),
          bytes: BuiltValueNullFieldError.checkNotNull(
              bytes, r'ContentPackage', 'bytes'),
        );
    replace(_$result);
    return _$result;
  }
}

// ignore_for_file: deprecated_member_use_from_same_package,type=lint
