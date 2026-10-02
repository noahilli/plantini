//
// AUTO-GENERATED FILE, DO NOT MODIFY!
//

// ignore_for_file: unused_element
import 'package:built_collection/built_collection.dart';
import 'package:built_value/json_object.dart';
import 'package:built_value/built_value.dart';
import 'package:built_value/serializer.dart';

part 'editor_save_request.g.dart';

/// EditorSaveRequest
///
/// Properties:
/// * [type]
/// * [targetId]
/// * [data]
@BuiltValue()
abstract class EditorSaveRequest
    implements Built<EditorSaveRequest, EditorSaveRequestBuilder> {
  @BuiltValueField(wireName: r'type')
  EditorSaveRequestTypeEnum get type;
  // enum typeEnum {  ecosystem,  level,  plant,  quiz,  };

  @BuiltValueField(wireName: r'targetId')
  String? get targetId;

  @BuiltValueField(wireName: r'data')
  JsonObject get data;

  EditorSaveRequest._();

  factory EditorSaveRequest([void updates(EditorSaveRequestBuilder b)]) =
      _$EditorSaveRequest;

  @BuiltValueHook(initializeBuilder: true)
  static void _defaults(EditorSaveRequestBuilder b) => b;

  @BuiltValueSerializer(custom: true)
  static Serializer<EditorSaveRequest> get serializer =>
      _$EditorSaveRequestSerializer();
}

class _$EditorSaveRequestSerializer
    implements PrimitiveSerializer<EditorSaveRequest> {
  @override
  final Iterable<Type> types = const [EditorSaveRequest, _$EditorSaveRequest];

  @override
  final String wireName = r'EditorSaveRequest';

  Iterable<Object?> _serializeProperties(
    Serializers serializers,
    EditorSaveRequest object, {
    FullType specifiedType = FullType.unspecified,
  }) sync* {
    yield r'type';
    yield serializers.serialize(
      object.type,
      specifiedType: const FullType(EditorSaveRequestTypeEnum),
    );
    if (object.targetId != null) {
      yield r'targetId';
      yield serializers.serialize(
        object.targetId,
        specifiedType: const FullType(String),
      );
    }
    yield r'data';
    yield serializers.serialize(
      object.data,
      specifiedType: const FullType(JsonObject),
    );
  }

  @override
  Object serialize(
    Serializers serializers,
    EditorSaveRequest object, {
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
    required EditorSaveRequestBuilder result,
    required List<Object?> unhandled,
  }) {
    for (var i = 0; i < serializedList.length; i += 2) {
      final key = serializedList[i] as String;
      final value = serializedList[i + 1];
      switch (key) {
        case r'type':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType(EditorSaveRequestTypeEnum),
          ) as EditorSaveRequestTypeEnum;
          result.type = valueDes;
          break;
        case r'targetId':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType.nullable(String),
          ) as String?;
          if (valueDes == null) continue;
          result.targetId = valueDes;
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
  EditorSaveRequest deserialize(
    Serializers serializers,
    Object serialized, {
    FullType specifiedType = FullType.unspecified,
  }) {
    final result = EditorSaveRequestBuilder();
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

class EditorSaveRequestTypeEnum extends EnumClass {
  @BuiltValueEnumConst(wireName: r'ecosystem')
  static const EditorSaveRequestTypeEnum ecosystem =
      _$editorSaveRequestTypeEnum_ecosystem;
  @BuiltValueEnumConst(wireName: r'level')
  static const EditorSaveRequestTypeEnum level =
      _$editorSaveRequestTypeEnum_level;
  @BuiltValueEnumConst(wireName: r'plant')
  static const EditorSaveRequestTypeEnum plant =
      _$editorSaveRequestTypeEnum_plant;
  @BuiltValueEnumConst(wireName: r'quiz')
  static const EditorSaveRequestTypeEnum quiz =
      _$editorSaveRequestTypeEnum_quiz;

  static Serializer<EditorSaveRequestTypeEnum> get serializer =>
      _$editorSaveRequestTypeEnumSerializer;

  const EditorSaveRequestTypeEnum._(String name) : super(name);

  static BuiltSet<EditorSaveRequestTypeEnum> get values =>
      _$editorSaveRequestTypeEnumValues;
  static EditorSaveRequestTypeEnum valueOf(String name) =>
      _$editorSaveRequestTypeEnumValueOf(name);
}
