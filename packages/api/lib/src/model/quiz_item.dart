//
// AUTO-GENERATED FILE, DO NOT MODIFY!
//

// ignore_for_file: unused_element
import 'package:openapi/src/model/quiz_choice.dart';
import 'package:built_collection/built_collection.dart';
import 'package:built_value/built_value.dart';
import 'package:built_value/serializer.dart';

part 'quiz_item.g.dart';

/// QuizItem
///
/// Properties:
/// * [id]
/// * [levelId]
/// * [type]
/// * [contentVersion]
/// * [prompt]
/// * [choices]
@BuiltValue()
abstract class QuizItem implements Built<QuizItem, QuizItemBuilder> {
  @BuiltValueField(wireName: r'id')
  String get id;

  @BuiltValueField(wireName: r'levelId')
  String get levelId;

  @BuiltValueField(wireName: r'type')
  QuizItemTypeEnum get type;
  // enum typeEnum {  multiple_choice,  flashcard,  image_identification,  feature_match,  };

  @BuiltValueField(wireName: r'contentVersion')
  String get contentVersion;

  @BuiltValueField(wireName: r'prompt')
  String get prompt;

  @BuiltValueField(wireName: r'choices')
  BuiltList<QuizChoice>? get choices;

  QuizItem._();

  factory QuizItem([void updates(QuizItemBuilder b)]) = _$QuizItem;

  @BuiltValueHook(initializeBuilder: true)
  static void _defaults(QuizItemBuilder b) => b;

  @BuiltValueSerializer(custom: true)
  static Serializer<QuizItem> get serializer => _$QuizItemSerializer();
}

class _$QuizItemSerializer implements PrimitiveSerializer<QuizItem> {
  @override
  final Iterable<Type> types = const [QuizItem, _$QuizItem];

  @override
  final String wireName = r'QuizItem';

  Iterable<Object?> _serializeProperties(
    Serializers serializers,
    QuizItem object, {
    FullType specifiedType = FullType.unspecified,
  }) sync* {
    yield r'id';
    yield serializers.serialize(
      object.id,
      specifiedType: const FullType(String),
    );
    yield r'levelId';
    yield serializers.serialize(
      object.levelId,
      specifiedType: const FullType(String),
    );
    yield r'type';
    yield serializers.serialize(
      object.type,
      specifiedType: const FullType(QuizItemTypeEnum),
    );
    yield r'contentVersion';
    yield serializers.serialize(
      object.contentVersion,
      specifiedType: const FullType(String),
    );
    yield r'prompt';
    yield serializers.serialize(
      object.prompt,
      specifiedType: const FullType(String),
    );
    if (object.choices != null) {
      yield r'choices';
      yield serializers.serialize(
        object.choices,
        specifiedType: const FullType(BuiltList, [FullType(QuizChoice)]),
      );
    }
  }

  @override
  Object serialize(
    Serializers serializers,
    QuizItem object, {
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
    required QuizItemBuilder result,
    required List<Object?> unhandled,
  }) {
    for (var i = 0; i < serializedList.length; i += 2) {
      final key = serializedList[i] as String;
      final value = serializedList[i + 1];
      switch (key) {
        case r'id':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType(String),
          ) as String;
          result.id = valueDes;
          break;
        case r'levelId':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType(String),
          ) as String;
          result.levelId = valueDes;
          break;
        case r'type':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType(QuizItemTypeEnum),
          ) as QuizItemTypeEnum;
          result.type = valueDes;
          break;
        case r'contentVersion':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType(String),
          ) as String;
          result.contentVersion = valueDes;
          break;
        case r'prompt':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType(String),
          ) as String;
          result.prompt = valueDes;
          break;
        case r'choices':
          final valueDes = serializers.deserialize(
            value,
            specifiedType:
                const FullType.nullable(BuiltList, [FullType(QuizChoice)]),
          ) as BuiltList<QuizChoice>?;
          if (valueDes == null) continue;
          result.choices.replace(valueDes);
          break;
        default:
          unhandled.add(key);
          unhandled.add(value);
          break;
      }
    }
  }

  @override
  QuizItem deserialize(
    Serializers serializers,
    Object serialized, {
    FullType specifiedType = FullType.unspecified,
  }) {
    final result = QuizItemBuilder();
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

class QuizItemTypeEnum extends EnumClass {
  @BuiltValueEnumConst(wireName: r'multiple_choice')
  static const QuizItemTypeEnum multipleChoice =
      _$quizItemTypeEnum_multipleChoice;
  @BuiltValueEnumConst(wireName: r'flashcard')
  static const QuizItemTypeEnum flashcard = _$quizItemTypeEnum_flashcard;
  @BuiltValueEnumConst(wireName: r'image_identification')
  static const QuizItemTypeEnum imageIdentification =
      _$quizItemTypeEnum_imageIdentification;
  @BuiltValueEnumConst(wireName: r'feature_match')
  static const QuizItemTypeEnum featureMatch = _$quizItemTypeEnum_featureMatch;

  static Serializer<QuizItemTypeEnum> get serializer =>
      _$quizItemTypeEnumSerializer;

  const QuizItemTypeEnum._(String name) : super(name);

  static BuiltSet<QuizItemTypeEnum> get values => _$quizItemTypeEnumValues;
  static QuizItemTypeEnum valueOf(String name) =>
      _$quizItemTypeEnumValueOf(name);
}
