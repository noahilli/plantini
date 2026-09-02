// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'observation_page.dart';

// **************************************************************************
// BuiltValueGenerator
// **************************************************************************

class _$ObservationPage extends ObservationPage {
  @override
  final BuiltList<Observation> items;
  @override
  final PageMeta page;

  factory _$ObservationPage([void Function(ObservationPageBuilder)? updates]) =>
      (ObservationPageBuilder()..update(updates))._build();

  _$ObservationPage._({required this.items, required this.page}) : super._();
  @override
  ObservationPage rebuild(void Function(ObservationPageBuilder) updates) =>
      (toBuilder()..update(updates)).build();

  @override
  ObservationPageBuilder toBuilder() => ObservationPageBuilder()..replace(this);

  @override
  bool operator ==(Object other) {
    if (identical(other, this)) return true;
    return other is ObservationPage &&
        items == other.items &&
        page == other.page;
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
    return (newBuiltValueToStringHelper(r'ObservationPage')
          ..add('items', items)
          ..add('page', page))
        .toString();
  }
}

class ObservationPageBuilder
    implements Builder<ObservationPage, ObservationPageBuilder> {
  _$ObservationPage? _$v;

  ListBuilder<Observation>? _items;
  ListBuilder<Observation> get items =>
      _$this._items ??= ListBuilder<Observation>();
  set items(ListBuilder<Observation>? items) => _$this._items = items;

  PageMetaBuilder? _page;
  PageMetaBuilder get page => _$this._page ??= PageMetaBuilder();
  set page(PageMetaBuilder? page) => _$this._page = page;

  ObservationPageBuilder() {
    ObservationPage._defaults(this);
  }

  ObservationPageBuilder get _$this {
    final $v = _$v;
    if ($v != null) {
      _items = $v.items.toBuilder();
      _page = $v.page.toBuilder();
      _$v = null;
    }
    return this;
  }

  @override
  void replace(ObservationPage other) {
    _$v = other as _$ObservationPage;
  }

  @override
  void update(void Function(ObservationPageBuilder)? updates) {
    if (updates != null) updates(this);
  }

  @override
  ObservationPage build() => _build();

  _$ObservationPage _build() {
    _$ObservationPage _$result;
    try {
      _$result = _$v ??
          _$ObservationPage._(
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
            r'ObservationPage', _$failedField, e.toString());
      }
      rethrow;
    }
    replace(_$result);
    return _$result;
  }
}

// ignore_for_file: deprecated_member_use_from_same_package,type=lint
