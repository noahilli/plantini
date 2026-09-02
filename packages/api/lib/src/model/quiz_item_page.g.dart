// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'quiz_item_page.dart';

// **************************************************************************
// BuiltValueGenerator
// **************************************************************************

class _$QuizItemPage extends QuizItemPage {
  @override
  final BuiltList<QuizItem> items;

  factory _$QuizItemPage([void Function(QuizItemPageBuilder)? updates]) =>
      (QuizItemPageBuilder()..update(updates))._build();

  _$QuizItemPage._({required this.items}) : super._();
  @override
  QuizItemPage rebuild(void Function(QuizItemPageBuilder) updates) =>
      (toBuilder()..update(updates)).build();

  @override
  QuizItemPageBuilder toBuilder() => QuizItemPageBuilder()..replace(this);

  @override
  bool operator ==(Object other) {
    if (identical(other, this)) return true;
    return other is QuizItemPage && items == other.items;
  }

  @override
  int get hashCode {
    var _$hash = 0;
    _$hash = $jc(_$hash, items.hashCode);
    _$hash = $jf(_$hash);
    return _$hash;
  }

  @override
  String toString() {
    return (newBuiltValueToStringHelper(r'QuizItemPage')..add('items', items))
        .toString();
  }
}

class QuizItemPageBuilder
    implements Builder<QuizItemPage, QuizItemPageBuilder> {
  _$QuizItemPage? _$v;

  ListBuilder<QuizItem>? _items;
  ListBuilder<QuizItem> get items => _$this._items ??= ListBuilder<QuizItem>();
  set items(ListBuilder<QuizItem>? items) => _$this._items = items;

  QuizItemPageBuilder() {
    QuizItemPage._defaults(this);
  }

  QuizItemPageBuilder get _$this {
    final $v = _$v;
    if ($v != null) {
      _items = $v.items.toBuilder();
      _$v = null;
    }
    return this;
  }

  @override
  void replace(QuizItemPage other) {
    _$v = other as _$QuizItemPage;
  }

  @override
  void update(void Function(QuizItemPageBuilder)? updates) {
    if (updates != null) updates(this);
  }

  @override
  QuizItemPage build() => _build();

  _$QuizItemPage _build() {
    _$QuizItemPage _$result;
    try {
      _$result = _$v ??
          _$QuizItemPage._(
            items: items.build(),
          );
    } catch (_) {
      late String _$failedField;
      try {
        _$failedField = 'items';
        items.build();
      } catch (e) {
        throw BuiltValueNestedFieldError(
            r'QuizItemPage', _$failedField, e.toString());
      }
      rethrow;
    }
    replace(_$result);
    return _$result;
  }
}

// ignore_for_file: deprecated_member_use_from_same_package,type=lint
