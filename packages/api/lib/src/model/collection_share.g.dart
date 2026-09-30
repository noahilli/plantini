// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'collection_share.dart';

// **************************************************************************
// BuiltValueGenerator
// **************************************************************************

class _$CollectionShare extends CollectionShare {
  @override
  final num share;
  @override
  final String label;

  factory _$CollectionShare([void Function(CollectionShareBuilder)? updates]) =>
      (CollectionShareBuilder()..update(updates))._build();

  _$CollectionShare._({required this.share, required this.label}) : super._();
  @override
  CollectionShare rebuild(void Function(CollectionShareBuilder) updates) =>
      (toBuilder()..update(updates)).build();

  @override
  CollectionShareBuilder toBuilder() => CollectionShareBuilder()..replace(this);

  @override
  bool operator ==(Object other) {
    if (identical(other, this)) return true;
    return other is CollectionShare &&
        share == other.share &&
        label == other.label;
  }

  @override
  int get hashCode {
    var _$hash = 0;
    _$hash = $jc(_$hash, share.hashCode);
    _$hash = $jc(_$hash, label.hashCode);
    _$hash = $jf(_$hash);
    return _$hash;
  }

  @override
  String toString() {
    return (newBuiltValueToStringHelper(r'CollectionShare')
          ..add('share', share)
          ..add('label', label))
        .toString();
  }
}

class CollectionShareBuilder
    implements Builder<CollectionShare, CollectionShareBuilder> {
  _$CollectionShare? _$v;

  num? _share;
  num? get share => _$this._share;
  set share(num? share) => _$this._share = share;

  String? _label;
  String? get label => _$this._label;
  set label(String? label) => _$this._label = label;

  CollectionShareBuilder() {
    CollectionShare._defaults(this);
  }

  CollectionShareBuilder get _$this {
    final $v = _$v;
    if ($v != null) {
      _share = $v.share;
      _label = $v.label;
      _$v = null;
    }
    return this;
  }

  @override
  void replace(CollectionShare other) {
    _$v = other as _$CollectionShare;
  }

  @override
  void update(void Function(CollectionShareBuilder)? updates) {
    if (updates != null) updates(this);
  }

  @override
  CollectionShare build() => _build();

  _$CollectionShare _build() {
    final _$result = _$v ??
        _$CollectionShare._(
          share: BuiltValueNullFieldError.checkNotNull(
              share, r'CollectionShare', 'share'),
          label: BuiltValueNullFieldError.checkNotNull(
              label, r'CollectionShare', 'label'),
        );
    replace(_$result);
    return _$result;
  }
}

// ignore_for_file: deprecated_member_use_from_same_package,type=lint
