//
// AUTO-GENERATED FILE, DO NOT MODIFY!
//

// ignore_for_file: unused_element
import 'package:built_collection/built_collection.dart';
import 'package:built_value/json_object.dart';
import 'package:built_value/built_value.dart';
import 'package:built_value/serializer.dart';

part 'editor_item.g.dart';

/// EditorItem
///
/// Properties:
/// * [type]
/// * [id]
/// * [updatedAt]
/// * [published]
/// * [data]
@BuiltValue()
abstract class EditorItem implements Built<EditorItem, EditorItemBuilder> {
  @BuiltValueField(wireName: r'type')
  EditorItemTypeEnum get type;
  // enum typeEnum {  ecosystem,  level,  plant,  quiz,  };

  @BuiltValueField(wireName: r'id')
  String get id;

  @BuiltValueField(wireName: r'updatedAt')
  DateTime get updatedAt;

  @BuiltValueField(wireName: r'published')
  bool get published;

  @BuiltValueField(wireName: r'data')
  JsonObject get data;

  EditorItem._();

  factory EditorItem([void updates(EditorItemBuilder b)]) = _$EditorItem;

  @BuiltValueHook(initializeBuilder: true)
  static void _defaults(EditorItemBuilder b) => b;

  @BuiltValueSerializer(custom: true)
  static Serializer<EditorItem> get serializer => _$EditorItemSerializer();
}

class _$EditorItemSerializer implements PrimitiveSerializer<EditorItem> {
  @override
  final Iterable<Type> types = const [EditorItem, _$EditorItem];

  @override
  final String wireName = r'EditorItem';

  Iterable<Object?> _serializeProperties(
    Serializers serializers,
    EditorItem object, {
    FullType specifiedType = FullType.unspecified,
  }) sync* {
    yield r'type';
    yield serializers.serialize(
      object.type,
      specifiedType: const FullType(EditorItemTypeEnum),
    );
    yield r'id';
    yield serializers.serialize(
      object.id,
      specifiedType: const FullType(String),
    );
    yield r'updatedAt';
    yield serializers.serialize(
      object.updatedAt,
      specifiedType: const FullType(DateTime),
    );
    yield r'published';
    yield serializers.serialize(
      object.published,
      specifiedType: const FullType(bool),
    );
    yield r'data';
    yield serializers.serialize(
      object.data,
      specifiedType: const FullType(JsonObject),
    );
  }

  @override
  Object serialize(
    Serializers serializers,
    EditorItem object, {
    FullType specifiedType = FullType.unspecified,
  }) {
    return _serializeProperties(serializers, object,
            specifiedType: specifiedType)
        .toList();
  }

  void _deserializeProperties(
    Serializers serializers,
    Object serialized, {
    FullType specifiedType = FullType.unspecified,
    required List<Object?> serializedList,
    required EditorItemBuilder result,
    required List<Object?> unhandled,
  }) {
    for (var i = 0; i < serializedList.length; i += 2) {
      final key = serializedList[i] as String;
      final value = serializedList[i + 1];
      switch (key) {
        case r'type':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType(EditorItemTypeEnum),
          ) as EditorItemTypeEnum;
          result.type = valueDes;
          break;
        case r'id':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType(String),
          ) as String;
          result.id = valueDes;
          break;
        case r'updatedAt':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType(DateTime),
          ) as DateTime;
          result.updatedAt = valueDes;
          break;
        case r'published':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType(bool),
          ) as bool;
          result.published = valueDes;
          break;
        case r'data':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType(JsonObject),
          ) as JsonObject;
          result.data = valueDes;
          break;
        default:
          unhandled.add(key);
          unhandled.add(value);
          break;
      }
    }
  }

  @override
  EditorItem deserialize(
    Serializers serializers,
    Object serialized, {
    FullType specifiedType = FullType.unspecified,
  }) {
    final result = EditorItemBuilder();
    final serializedList = (serialized as Iterable<Object?>).toList();
    final unhandled = <Object?>[];
    _deserializeProperties(
      serializers,
      serialized,
      specifiedType: specifiedType,
      serializedList: serializedList,
      unhandled: unhandled,
      result: result,
    );
    return result.build();
  }
}

class EditorItemTypeEnum extends EnumClass {
  @BuiltValueEnumConst(wireName: r'ecosystem')
  static const EditorItemTypeEnum ecosystem = _$editorItemTypeEnum_ecosystem;
  @BuiltValueEnumConst(wireName: r'level')
  static const EditorItemTypeEnum level = _$editorItemTypeEnum_level;
  @BuiltValueEnumConst(wireName: r'plant')
  static const EditorItemTypeEnum plant = _$editorItemTypeEnum_plant;
  @BuiltValueEnumConst(wireName: r'quiz')
  static const EditorItemTypeEnum quiz = _$editorItemTypeEnum_quiz;

  static Serializer<EditorItemTypeEnum> get serializer =>
      _$editorItemTypeEnumSerializer;

  const EditorItemTypeEnum._(String name) : super(name);

  static BuiltSet<EditorItemTypeEnum> get values => _$editorItemTypeEnumValues;
  static EditorItemTypeEnum valueOf(String name) =>
      _$editorItemTypeEnumValueOf(name);
}
