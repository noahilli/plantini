//
// AUTO-GENERATED FILE, DO NOT MODIFY!
//

// ignore_for_file: unused_element
import 'package:built_value/built_value.dart';
import 'package:built_value/serializer.dart';

part 'quiz_answer.g.dart';

/// QuizAnswer
///
/// Properties:
/// * [quizItemId]
/// * [choiceId]
@BuiltValue()
abstract class QuizAnswer implements Built<QuizAnswer, QuizAnswerBuilder> {
  @BuiltValueField(wireName: r'quizItemId')
  String get quizItemId;

  @BuiltValueField(wireName: r'choiceId')
  String get choiceId;

  QuizAnswer._();

  factory QuizAnswer([void updates(QuizAnswerBuilder b)]) = _$QuizAnswer;

  @BuiltValueHook(initializeBuilder: true)
  static void _defaults(QuizAnswerBuilder b) => b;

  @BuiltValueSerializer(custom: true)
  static Serializer<QuizAnswer> get serializer => _$QuizAnswerSerializer();
}

class _$QuizAnswerSerializer implements PrimitiveSerializer<QuizAnswer> {
  @override
  final Iterable<Type> types = const [QuizAnswer, _$QuizAnswer];

  @override
  final String wireName = r'QuizAnswer';

  Iterable<Object?> _serializeProperties(
    Serializers serializers,
    QuizAnswer object, {
    FullType specifiedType = FullType.unspecified,
  }) sync* {
    yield r'quizItemId';
    yield serializers.serialize(
      object.quizItemId,
      specifiedType: const FullType(String),
    );
    yield r'choiceId';
    yield serializers.serialize(
      object.choiceId,
      specifiedType: const FullType(String),
    );
  }

  @override
  Object serialize(
    Serializers serializers,
    QuizAnswer object, {
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
    required QuizAnswerBuilder result,
    required List<Object?> unhandled,
  }) {
    for (var i = 0; i < serializedList.length; i += 2) {
      final key = serializedList[i] as String;
      final value = serializedList[i + 1];
      switch (key) {
        case r'quizItemId':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType(String),
          ) as String;
          result.quizItemId = valueDes;
          break;
        case r'choiceId':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType(String),
          ) as String;
          result.choiceId = valueDes;
          break;
        default:
          unhandled.add(key);
          unhandled.add(value);
          break;
      }
    }
  }

  @override
  QuizAnswer deserialize(
    Serializers serializers,
    Object serialized, {
    FullType specifiedType = FullType.unspecified,
  }) {
    final result = QuizAnswerBuilder();
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
