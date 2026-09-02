//
// AUTO-GENERATED FILE, DO NOT MODIFY!
//

// ignore_for_file: unused_element
import 'package:built_collection/built_collection.dart';
import 'package:built_value/built_value.dart';
import 'package:built_value/serializer.dart';

part 'content_change.g.dart';

/// ContentChange
///
/// Properties:
/// * [entity]
/// * [id]
/// * [operation]
/// * [version]
@BuiltValue()
abstract class ContentChange
    implements Built<ContentChange, ContentChangeBuilder> {
  @BuiltValueField(wireName: r'entity')
  ContentChangeEntityEnum get entity;
  // enum entityEnum {  ecosystem,  level,  plant,  quiz_item,  media,  };

  @BuiltValueField(wireName: r'id')
  String get id;

  @BuiltValueField(wireName: r'operation')
  ContentChangeOperationEnum get operation;
  // enum operationEnum {  upsert,  delete,  };

  @BuiltValueField(wireName: r'version')
  String get version;

  ContentChange._();

  factory ContentChange([void updates(ContentChangeBuilder b)]) =
      _$ContentChange;

  @BuiltValueHook(initializeBuilder: true)
  static void _defaults(ContentChangeBuilder b) => b;

  @BuiltValueSerializer(custom: true)
  static Serializer<ContentChange> get serializer =>
      _$ContentChangeSerializer();
}

class _$ContentChangeSerializer implements PrimitiveSerializer<ContentChange> {
  @override
  final Iterable<Type> types = const [ContentChange, _$ContentChange];

  @override
  final String wireName = r'ContentChange';

  Iterable<Object?> _serializeProperties(
    Serializers serializers,
    ContentChange object, {
    FullType specifiedType = FullType.unspecified,
  }) sync* {
    yield r'entity';
    yield serializers.serialize(
      object.entity,
      specifiedType: const FullType(ContentChangeEntityEnum),
    );
    yield r'id';
    yield serializers.serialize(
      object.id,
      specifiedType: const FullType(String),
    );
    yield r'operation';
    yield serializers.serialize(
      object.operation,
      specifiedType: const FullType(ContentChangeOperationEnum),
    );
    yield r'version';
    yield serializers.serialize(
      object.version,
      specifiedType: const FullType(String),
    );
  }

  @override
  Object serialize(
    Serializers serializers,
    ContentChange object, {
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
    required ContentChangeBuilder result,
    required List<Object?> unhandled,
  }) {
    for (var i = 0; i < serializedList.length; i += 2) {
      final key = serializedList[i] as String;
      final value = serializedList[i + 1];
      switch (key) {
        case r'entity':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType(ContentChangeEntityEnum),
          ) as ContentChangeEntityEnum;
          result.entity = valueDes;
          break;
        case r'id':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType(String),
          ) as String;
          result.id = valueDes;
          break;
        case r'operation':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType(ContentChangeOperationEnum),
          ) as ContentChangeOperationEnum;
          result.operation = valueDes;
          break;
        case r'version':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType(String),
          ) as String;
          result.version = valueDes;
          break;
        default:
          unhandled.add(key);
          unhandled.add(value);
          break;
      }
    }
  }

  @override
  ContentChange deserialize(
    Serializers serializers,
    Object serialized, {
    FullType specifiedType = FullType.unspecified,
  }) {
    final result = ContentChangeBuilder();
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

class ContentChangeEntityEnum extends EnumClass {
  @BuiltValueEnumConst(wireName: r'ecosystem')
  static const ContentChangeEntityEnum ecosystem =
      _$contentChangeEntityEnum_ecosystem;
  @BuiltValueEnumConst(wireName: r'level')
  static const ContentChangeEntityEnum level = _$contentChangeEntityEnum_level;
  @BuiltValueEnumConst(wireName: r'plant')
  static const ContentChangeEntityEnum plant = _$contentChangeEntityEnum_plant;
  @BuiltValueEnumConst(wireName: r'quiz_item')
  static const ContentChangeEntityEnum quizItem =
      _$contentChangeEntityEnum_quizItem;
  @BuiltValueEnumConst(wireName: r'media')
  static const ContentChangeEntityEnum media = _$contentChangeEntityEnum_media;

  static Serializer<ContentChangeEntityEnum> get serializer =>
      _$contentChangeEntityEnumSerializer;

  const ContentChangeEntityEnum._(String name) : super(name);

  static BuiltSet<ContentChangeEntityEnum> get values =>
      _$contentChangeEntityEnumValues;
  static ContentChangeEntityEnum valueOf(String name) =>
      _$contentChangeEntityEnumValueOf(name);
}

class ContentChangeOperationEnum extends EnumClass {
  @BuiltValueEnumConst(wireName: r'upsert')
  static const ContentChangeOperationEnum upsert =
      _$contentChangeOperationEnum_upsert;
  @BuiltValueEnumConst(wireName: r'delete')
  static const ContentChangeOperationEnum delete =
      _$contentChangeOperationEnum_delete;

  static Serializer<ContentChangeOperationEnum> get serializer =>
      _$contentChangeOperationEnumSerializer;

  const ContentChangeOperationEnum._(String name) : super(name);

  static BuiltSet<ContentChangeOperationEnum> get values =>
      _$contentChangeOperationEnumValues;
  static ContentChangeOperationEnum valueOf(String name) =>
      _$contentChangeOperationEnumValueOf(name);
}
