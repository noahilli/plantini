// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'page_meta.dart';

// **************************************************************************
// BuiltValueGenerator
// **************************************************************************

class _$PageMeta extends PageMeta {
  @override
  final int page;
  @override
  final int pageSize;
  @override
  final int total;

  factory _$PageMeta([void Function(PageMetaBuilder)? updates]) =>
      (PageMetaBuilder()..update(updates))._build();

  _$PageMeta._(
      {required this.page, required this.pageSize, required this.total})
      : super._();
  @override
  PageMeta rebuild(void Function(PageMetaBuilder) updates) =>
      (toBuilder()..update(updates)).build();

  @override
  PageMetaBuilder toBuilder() => PageMetaBuilder()..replace(this);

  @override
  bool operator ==(Object other) {
    if (identical(other, this)) return true;
    return other is PageMeta &&
        page == other.page &&
        pageSize == other.pageSize &&
        total == other.total;
  }

  @override
  int get hashCode {
    var _$hash = 0;
    _$hash = $jc(_$hash, page.hashCode);
    _$hash = $jc(_$hash, pageSize.hashCode);
    _$hash = $jc(_$hash, total.hashCode);
    _$hash = $jf(_$hash);
    return _$hash;
  }

  @override
  String toString() {
    return (newBuiltValueToStringHelper(r'PageMeta')
          ..add('page', page)
          ..add('pageSize', pageSize)
          ..add('total', total))
        .toString();
  }
}

class PageMetaBuilder implements Builder<PageMeta, PageMetaBuilder> {
  _$PageMeta? _$v;

  int? _page;
  int? get page => _$this._page;
  set page(int? page) => _$this._page = page;

  int? _pageSize;
  int? get pageSize => _$this._pageSize;
  set pageSize(int? pageSize) => _$this._pageSize = pageSize;

  int? _total;
  int? get total => _$this._total;
  set total(int? total) => _$this._total = total;

  PageMetaBuilder() {
    PageMeta._defaults(this);
  }

  PageMetaBuilder get _$this {
    final $v = _$v;
    if ($v != null) {
      _page = $v.page;
      _pageSize = $v.pageSize;
      _total = $v.total;
      _$v = null;
    }
    return this;
  }

  @override
  void replace(PageMeta other) {
    _$v = other as _$PageMeta;
  }

  @override
  void update(void Function(PageMetaBuilder)? updates) {
    if (updates != null) updates(this);
  }

  @override
  PageMeta build() => _build();

  _$PageMeta _build() {
    final _$result = _$v ??
        _$PageMeta._(
          page:
              BuiltValueNullFieldError.checkNotNull(page, r'PageMeta', 'page'),
          pageSize: BuiltValueNullFieldError.checkNotNull(
              pageSize, r'PageMeta', 'pageSize'),
          total: BuiltValueNullFieldError.checkNotNull(
              total, r'PageMeta', 'total'),
        );
    replace(_$result);
    return _$result;
  }
}

// ignore_for_file: deprecated_member_use_from_same_package,type=lint
