//
// AUTO-GENERATED FILE, DO NOT MODIFY!
//

// ignore_for_file: unused_element
import 'package:built_collection/built_collection.dart';
import 'package:built_value/json_object.dart';
import 'package:built_value/built_value.dart';
import 'package:built_value/serializer.dart';

part 'quiz.g.dart';

/// Quiz
///
/// Properties:
/// * [id] 
/// * [title] 
/// * [quizType] 
/// * [data] 
@BuiltValue()
abstract class Quiz implements Built<Quiz, QuizBuilder> {
  @BuiltValueField(wireName: r'id')
  String get id;

  @BuiltValueField(wireName: r'title')
  String get title;

  @BuiltValueField(wireName: r'quizType')
  QuizQuizTypeEnum get quizType;
  // enum quizTypeEnum {  multiple-choice,  flashcard,  identification,  };

  @BuiltValueField(wireName: r'data')
  JsonObject? get data;

  Quiz._();

  factory Quiz([void updates(QuizBuilder b)]) = _$Quiz;

  @BuiltValueHook(initializeBuilder: true)
  static void _defaults(QuizBuilder b) => b;

  @BuiltValueSerializer(custom: true)
  static Serializer<Quiz> get serializer => _$QuizSerializer();
}

class _$QuizSerializer implements PrimitiveSerializer<Quiz> {
  @override
  final Iterable<Type> types = const [Quiz, _$Quiz];

  @override
  final String wireName = r'Quiz';

  Iterable<Object?> _serializeProperties(
    Serializers serializers,
    Quiz object, {
    FullType specifiedType = FullType.unspecified,
  }) sync* {
    yield r'id';
    yield serializers.serialize(
      object.id,
      specifiedType: const FullType(String),
    );
    yield r'title';
    yield serializers.serialize(
      object.title,
      specifiedType: const FullType(String),
    );
    yield r'quizType';
    yield serializers.serialize(
      object.quizType,
      specifiedType: const FullType(QuizQuizTypeEnum),
    );
    if (object.data != null) {
      yield r'data';
      yield serializers.serialize(
        object.data,
        specifiedType: const FullType(JsonObject),
      );
    }
  }

  @override
  Object serialize(
    Serializers serializers,
    Quiz object, {
    FullType specifiedType = FullType.unspecified,
  }) {
    return _serializeProperties(serializers, object, specifiedType: specifiedType).toList();
  }

  void _deserializeProperties(
    Serializers serializers,
    Object serialized, {
    FullType specifiedType = FullType.unspecified,
    required List<Object?> serializedList,
    required QuizBuilder result,
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
        case r'title':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType(String),
          ) as String;
          result.title = valueDes;
          break;
        case r'quizType':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType(QuizQuizTypeEnum),
          ) as QuizQuizTypeEnum;
          result.quizType = valueDes;
          break;
        case r'data':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType.nullable(JsonObject),
          ) as JsonObject?;
          if (valueDes == null) continue;
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
  Quiz deserialize(
    Serializers serializers,
    Object serialized, {
    FullType specifiedType = FullType.unspecified,
  }) {
    final result = QuizBuilder();
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


class QuizQuizTypeEnum extends EnumClass {

  @BuiltValueEnumConst(wireName: r'multiple-choice')
  static const QuizQuizTypeEnum multipleChoice = _$quizQuizTypeEnum_multipleChoice;
  @BuiltValueEnumConst(wireName: r'flashcard')
  static const QuizQuizTypeEnum flashcard = _$quizQuizTypeEnum_flashcard;
  @BuiltValueEnumConst(wireName: r'identification')
  static const QuizQuizTypeEnum identification = _$quizQuizTypeEnum_identification;

  static Serializer<QuizQuizTypeEnum> get serializer => _$quizQuizTypeEnumSerializer;

  const QuizQuizTypeEnum._(String name): super(name);

  static BuiltSet<QuizQuizTypeEnum> get values => _$quizQuizTypeEnumValues;
  static QuizQuizTypeEnum valueOf(String name) => _$quizQuizTypeEnumValueOf(name);
}

