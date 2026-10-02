// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'editor_item.dart';

// **************************************************************************
// BuiltValueGenerator
// **************************************************************************

const EditorItemTypeEnum _$editorItemTypeEnum_ecosystem =
    const EditorItemTypeEnum._('ecosystem');
const EditorItemTypeEnum _$editorItemTypeEnum_level =
    const EditorItemTypeEnum._('level');
const EditorItemTypeEnum _$editorItemTypeEnum_plant =
    const EditorItemTypeEnum._('plant');
const EditorItemTypeEnum _$editorItemTypeEnum_quiz =
    const EditorItemTypeEnum._('quiz');

EditorItemTypeEnum _$editorItemTypeEnumValueOf(String name) {
  switch (name) {
    case 'ecosystem':
      return _$editorItemTypeEnum_ecosystem;
    case 'level':
      return _$editorItemTypeEnum_level;
    case 'plant':
      return _$editorItemTypeEnum_plant;
    case 'quiz':
      return _$editorItemTypeEnum_quiz;
    default:
      throw ArgumentError(name);
  }
}

final BuiltSet<EditorItemTypeEnum> _$editorItemTypeEnumValues =
    BuiltSet<EditorItemTypeEnum>(const <EditorItemTypeEnum>[
  _$editorItemTypeEnum_ecosystem,
  _$editorItemTypeEnum_level,
  _$editorItemTypeEnum_plant,
  _$editorItemTypeEnum_quiz,
]);

Serializer<EditorItemTypeEnum> _$editorItemTypeEnumSerializer =
    _$EditorItemTypeEnumSerializer();

class _$EditorItemTypeEnumSerializer
    implements PrimitiveSerializer<EditorItemTypeEnum> {
  static const Map<String, Object> _toWire = const <String, Object>{
    'ecosystem': 'ecosystem',
    'level': 'level',
    'plant': 'plant',
    'quiz': 'quiz',
  };
  static const Map<Object, String> _fromWire = const <Object, String>{
    'ecosystem': 'ecosystem',
    'level': 'level',
    'plant': 'plant',
    'quiz': 'quiz',
  };

  @override
  final Iterable<Type> types = const <Type>[EditorItemTypeEnum];
  @override
  final String wireName = 'EditorItemTypeEnum';

  @override
  Object serialize(Serializers serializers, EditorItemTypeEnum object,
          {FullType specifiedType = FullType.unspecified}) =>
      _toWire[object.name] ?? object.name;

  @override
  EditorItemTypeEnum deserialize(Serializers serializers, Object serialized,
          {FullType specifiedType = FullType.unspecified}) =>
      EditorItemTypeEnum.valueOf(
          _fromWire[serialized] ?? (serialized is String ? serialized : ''));
}

class _$EditorItem extends EditorItem {
  @override
  final EditorItemTypeEnum type;
  @override
  final String id;
  @override
  final DateTime updatedAt;
  @override
  final bool published;
  @override
  final JsonObject data;

  factory _$EditorItem([void Function(EditorItemBuilder)? updates]) =>
      (EditorItemBuilder()..update(updates))._build();

  _$EditorItem._(
      {required this.type,
      required this.id,
      required this.updatedAt,
      required this.published,
      required this.data})
      : super._();
  @override
  EditorItem rebuild(void Function(EditorItemBuilder) updates) =>
      (toBuilder()..update(updates)).build();

  @override
  EditorItemBuilder toBuilder() => EditorItemBuilder()..replace(this);

  @override
  bool operator ==(Object other) {
    if (identical(other, this)) return true;
    return other is EditorItem &&
        type == other.type &&
        id == other.id &&
        updatedAt == other.updatedAt &&
        published == other.published &&
        data == other.data;
  }

  @override
  int get hashCode {
    var _$hash = 0;
    _$hash = $jc(_$hash, type.hashCode);
    _$hash = $jc(_$hash, id.hashCode);
    _$hash = $jc(_$hash, updatedAt.hashCode);
    _$hash = $jc(_$hash, published.hashCode);
    _$hash = $jc(_$hash, data.hashCode);
    _$hash = $jf(_$hash);
    return _$hash;
  }

  @override
  String toString() {
    return (newBuiltValueToStringHelper(r'EditorItem')
          ..add('type', type)
          ..add('id', id)
          ..add('updatedAt', updatedAt)
          ..add('published', published)
          ..add('data', data))
        .toString();
  }
}

class EditorItemBuilder implements Builder<EditorItem, EditorItemBuilder> {
  _$EditorItem? _$v;

  EditorItemTypeEnum? _type;
  EditorItemTypeEnum? get type => _$this._type;
  set type(EditorItemTypeEnum? type) => _$this._type = type;

  String? _id;
  String? get id => _$this._id;
  set id(String? id) => _$this._id = id;

  DateTime? _updatedAt;
  DateTime? get updatedAt => _$this._updatedAt;
  set updatedAt(DateTime? updatedAt) => _$this._updatedAt = updatedAt;

  bool? _published;
  bool? get published => _$this._published;
  set published(bool? published) => _$this._published = published;

  JsonObject? _data;
  JsonObject? get data => _$this._data;
  set data(JsonObject? data) => _$this._data = data;

  EditorItemBuilder() {
    EditorItem._defaults(this);
  }

  EditorItemBuilder get _$this {
    final $v = _$v;
    if ($v != null) {
      _type = $v.type;
      _id = $v.id;
      _updatedAt = $v.updatedAt;
      _published = $v.published;
      _data = $v.data;
      _$v = null;
    }
    return this;
  }

  @override
  void replace(EditorItem other) {
    _$v = other as _$EditorItem;
  }

  @override
  void update(void Function(EditorItemBuilder)? updates) {
    if (updates != null) updates(this);
  }

  @override
  EditorItem build() => _build();

  _$EditorItem _build() {
    final _$result = _$v ??
        _$EditorItem._(
          type: BuiltValueNullFieldError.checkNotNull(
              type, r'EditorItem', 'type'),
          id: BuiltValueNullFieldError.checkNotNull(id, r'EditorItem', 'id'),
          updatedAt: BuiltValueNullFieldError.checkNotNull(
              updatedAt, r'EditorItem', 'updatedAt'),
          published: BuiltValueNullFieldError.checkNotNull(
              published, r'EditorItem', 'published'),
          data: BuiltValueNullFieldError.checkNotNull(
              data, r'EditorItem', 'data'),
        );
    replace(_$result);
    return _$result;
  }
}

// ignore_for_file: deprecated_member_use_from_same_package,type=lint
