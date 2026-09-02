// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'ecosystem_page.dart';

// **************************************************************************
// BuiltValueGenerator
// **************************************************************************

class _$EcosystemPage extends EcosystemPage {
  @override
  final BuiltList<Ecosystem> items;
  @override
  final PageMeta page;

  factory _$EcosystemPage([void Function(EcosystemPageBuilder)? updates]) =>
      (EcosystemPageBuilder()..update(updates))._build();

  _$EcosystemPage._({required this.items, required this.page}) : super._();
  @override
  EcosystemPage rebuild(void Function(EcosystemPageBuilder) updates) =>
      (toBuilder()..update(updates)).build();

  @override
  EcosystemPageBuilder toBuilder() => EcosystemPageBuilder()..replace(this);

  @override
  bool operator ==(Object other) {
    if (identical(other, this)) return true;
    return other is EcosystemPage && items == other.items && page == other.page;
  }

  @override
  int get hashCode {
    var _$hash = 0;
    _$hash = $jc(_$hash, items.hashCode);
    _$hash = $jc(_$hash, page.hashCode);
    _$hash = $jf(_$hash);
    return _$hash;
  }

  @override
  String toString() {
    return (newBuiltValueToStringHelper(r'EcosystemPage')
          ..add('items', items)
          ..add('page', page))
        .toString();
  }
}

class EcosystemPageBuilder
    implements Builder<EcosystemPage, EcosystemPageBuilder> {
  _$EcosystemPage? _$v;

  ListBuilder<Ecosystem>? _items;
  ListBuilder<Ecosystem> get items =>
      _$this._items ??= ListBuilder<Ecosystem>();
  set items(ListBuilder<Ecosystem>? items) => _$this._items = items;

  PageMetaBuilder? _page;
  PageMetaBuilder get page => _$this._page ??= PageMetaBuilder();
  set page(PageMetaBuilder? page) => _$this._page = page;

  EcosystemPageBuilder() {
    EcosystemPage._defaults(this);
  }

  EcosystemPageBuilder get _$this {
    final $v = _$v;
    if ($v != null) {
      _items = $v.items.toBuilder();
      _page = $v.page.toBuilder();
      _$v = null;
    }
    return this;
  }

  @override
  void replace(EcosystemPage other) {
    _$v = other as _$EcosystemPage;
  }

  @override
  void update(void Function(EcosystemPageBuilder)? updates) {
    if (updates != null) updates(this);
  }

  @override
  EcosystemPage build() => _build();

  _$EcosystemPage _build() {
    _$EcosystemPage _$result;
    try {
      _$result = _$v ??
          _$EcosystemPage._(
            items: items.build(),
            page: page.build(),
          );
    } catch (_) {
      late String _$failedField;
      try {
        _$failedField = 'items';
        items.build();
        _$failedField = 'page';
        page.build();
      } catch (e) {
        throw BuiltValueNestedFieldError(
            r'EcosystemPage', _$failedField, e.toString());
      }
      rethrow;
    }
    replace(_$result);
    return _$result;
  }
}

// ignore_for_file: deprecated_member_use_from_same_package,type=lint
