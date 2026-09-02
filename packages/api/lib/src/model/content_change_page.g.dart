// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'content_change_page.dart';

// **************************************************************************
// BuiltValueGenerator
// **************************************************************************

class _$ContentChangePage extends ContentChangePage {
  @override
  final String cursor;
  @override
  final BuiltList<ContentChange> changes;

  factory _$ContentChangePage(
          [void Function(ContentChangePageBuilder)? updates]) =>
      (ContentChangePageBuilder()..update(updates))._build();

  _$ContentChangePage._({required this.cursor, required this.changes})
      : super._();
  @override
  ContentChangePage rebuild(void Function(ContentChangePageBuilder) updates) =>
      (toBuilder()..update(updates)).build();

  @override
  ContentChangePageBuilder toBuilder() =>
      ContentChangePageBuilder()..replace(this);

  @override
  bool operator ==(Object other) {
    if (identical(other, this)) return true;
    return other is ContentChangePage &&
        cursor == other.cursor &&
        changes == other.changes;
  }

  @override
  int get hashCode {
    var _$hash = 0;
    _$hash = $jc(_$hash, cursor.hashCode);
    _$hash = $jc(_$hash, changes.hashCode);
    _$hash = $jf(_$hash);
    return _$hash;
  }

  @override
  String toString() {
    return (newBuiltValueToStringHelper(r'ContentChangePage')
          ..add('cursor', cursor)
          ..add('changes', changes))
        .toString();
  }
}

class ContentChangePageBuilder
    implements Builder<ContentChangePage, ContentChangePageBuilder> {
  _$ContentChangePage? _$v;

  String? _cursor;
  String? get cursor => _$this._cursor;
  set cursor(String? cursor) => _$this._cursor = cursor;

  ListBuilder<ContentChange>? _changes;
  ListBuilder<ContentChange> get changes =>
      _$this._changes ??= ListBuilder<ContentChange>();
  set changes(ListBuilder<ContentChange>? changes) => _$this._changes = changes;

  ContentChangePageBuilder() {
    ContentChangePage._defaults(this);
  }

  ContentChangePageBuilder get _$this {
    final $v = _$v;
    if ($v != null) {
      _cursor = $v.cursor;
      _changes = $v.changes.toBuilder();
      _$v = null;
    }
    return this;
  }

  @override
  void replace(ContentChangePage other) {
    _$v = other as _$ContentChangePage;
  }

  @override
  void update(void Function(ContentChangePageBuilder)? updates) {
    if (updates != null) updates(this);
  }

  @override
  ContentChangePage build() => _build();

  _$ContentChangePage _build() {
    _$ContentChangePage _$result;
    try {
      _$result = _$v ??
          _$ContentChangePage._(
            cursor: BuiltValueNullFieldError.checkNotNull(
                cursor, r'ContentChangePage', 'cursor'),
            changes: changes.build(),
          );
    } catch (_) {
      late String _$failedField;
      try {
        _$failedField = 'changes';
        changes.build();
      } catch (e) {
        throw BuiltValueNestedFieldError(
            r'ContentChangePage', _$failedField, e.toString());
      }
      rethrow;
    }
    replace(_$result);
    return _$result;
  }
}

// ignore_for_file: deprecated_member_use_from_same_package,type=lint
