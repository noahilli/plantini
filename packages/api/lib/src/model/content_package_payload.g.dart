// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'content_package_payload.dart';

// **************************************************************************
// BuiltValueGenerator
// **************************************************************************

class _$ContentPackagePayload extends ContentPackagePayload {
  @override
  final BuiltList<JsonObject> items;

  factory _$ContentPackagePayload(
          [void Function(ContentPackagePayloadBuilder)? updates]) =>
      (ContentPackagePayloadBuilder()..update(updates))._build();

  _$ContentPackagePayload._({required this.items}) : super._();
  @override
  ContentPackagePayload rebuild(
          void Function(ContentPackagePayloadBuilder) updates) =>
      (toBuilder()..update(updates)).build();

  @override
  ContentPackagePayloadBuilder toBuilder() =>
      ContentPackagePayloadBuilder()..replace(this);

  @override
  bool operator ==(Object other) {
    if (identical(other, this)) return true;
    return other is ContentPackagePayload && items == other.items;
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
    return (newBuiltValueToStringHelper(r'ContentPackagePayload')
          ..add('items', items))
        .toString();
  }
}

class ContentPackagePayloadBuilder
    implements Builder<ContentPackagePayload, ContentPackagePayloadBuilder> {
  _$ContentPackagePayload? _$v;

  ListBuilder<JsonObject>? _items;
  ListBuilder<JsonObject> get items =>
      _$this._items ??= ListBuilder<JsonObject>();
  set items(ListBuilder<JsonObject>? items) => _$this._items = items;

  ContentPackagePayloadBuilder() {
    ContentPackagePayload._defaults(this);
  }

  ContentPackagePayloadBuilder get _$this {
    final $v = _$v;
    if ($v != null) {
      _items = $v.items.toBuilder();
      _$v = null;
    }
    return this;
  }

  @override
  void replace(ContentPackagePayload other) {
    _$v = other as _$ContentPackagePayload;
  }

  @override
  void update(void Function(ContentPackagePayloadBuilder)? updates) {
    if (updates != null) updates(this);
  }

  @override
  ContentPackagePayload build() => _build();

  _$ContentPackagePayload _build() {
    _$ContentPackagePayload _$result;
    try {
      _$result = _$v ??
          _$ContentPackagePayload._(
            items: items.build(),
          );
    } catch (_) {
      late String _$failedField;
      try {
        _$failedField = 'items';
        items.build();
      } catch (e) {
        throw BuiltValueNestedFieldError(
            r'ContentPackagePayload', _$failedField, e.toString());
      }
      rethrow;
    }
    replace(_$result);
    return _$result;
  }
}

// ignore_for_file: deprecated_member_use_from_same_package,type=lint
