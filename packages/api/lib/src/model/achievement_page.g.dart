// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'achievement_page.dart';

// **************************************************************************
// BuiltValueGenerator
// **************************************************************************

class _$AchievementPage extends AchievementPage {
  @override
  final BuiltList<Achievement> items;

  factory _$AchievementPage([void Function(AchievementPageBuilder)? updates]) =>
      (AchievementPageBuilder()..update(updates))._build();

  _$AchievementPage._({required this.items}) : super._();
  @override
  AchievementPage rebuild(void Function(AchievementPageBuilder) updates) =>
      (toBuilder()..update(updates)).build();

  @override
  AchievementPageBuilder toBuilder() => AchievementPageBuilder()..replace(this);

  @override
  bool operator ==(Object other) {
    if (identical(other, this)) return true;
    return other is AchievementPage && items == other.items;
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
    return (newBuiltValueToStringHelper(r'AchievementPage')
          ..add('items', items))
        .toString();
  }
}

class AchievementPageBuilder
    implements Builder<AchievementPage, AchievementPageBuilder> {
  _$AchievementPage? _$v;

  ListBuilder<Achievement>? _items;
  ListBuilder<Achievement> get items =>
      _$this._items ??= ListBuilder<Achievement>();
  set items(ListBuilder<Achievement>? items) => _$this._items = items;

  AchievementPageBuilder() {
    AchievementPage._defaults(this);
  }

  AchievementPageBuilder get _$this {
    final $v = _$v;
    if ($v != null) {
      _items = $v.items.toBuilder();
      _$v = null;
    }
    return this;
  }

  @override
  void replace(AchievementPage other) {
    _$v = other as _$AchievementPage;
  }

  @override
  void update(void Function(AchievementPageBuilder)? updates) {
    if (updates != null) updates(this);
  }

  @override
  AchievementPage build() => _build();

  _$AchievementPage _build() {
    _$AchievementPage _$result;
    try {
      _$result = _$v ??
          _$AchievementPage._(
            items: items.build(),
          );
    } catch (_) {
      late String _$failedField;
      try {
        _$failedField = 'items';
        items.build();
      } catch (e) {
        throw BuiltValueNestedFieldError(
            r'AchievementPage', _$failedField, e.toString());
      }
      rethrow;
    }
    replace(_$result);
    return _$result;
  }
}

// ignore_for_file: deprecated_member_use_from_same_package,type=lint
