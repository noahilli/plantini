//
// AUTO-GENERATED FILE, DO NOT MODIFY!
//

// ignore_for_file: unused_element
import 'package:built_collection/built_collection.dart';
import 'package:openapi/src/model/quiz_answer.dart';
import 'package:built_value/built_value.dart';
import 'package:built_value/serializer.dart';

part 'complete_level_attempt_request.g.dart';

/// CompleteLevelAttemptRequest
///
/// Properties:
/// * [clientEventId]
/// * [answers]
@BuiltValue()
abstract class CompleteLevelAttemptRequest
    implements
        Built<CompleteLevelAttemptRequest, CompleteLevelAttemptRequestBuilder> {
  @BuiltValueField(wireName: r'clientEventId')
  String get clientEventId;

  @BuiltValueField(wireName: r'answers')
  BuiltList<QuizAnswer> get answers;

  CompleteLevelAttemptRequest._();

  factory CompleteLevelAttemptRequest(
          [void updates(CompleteLevelAttemptRequestBuilder b)]) =
      _$CompleteLevelAttemptRequest;

  @BuiltValueHook(initializeBuilder: true)
  static void _defaults(CompleteLevelAttemptRequestBuilder b) => b;

  @BuiltValueSerializer(custom: true)
  static Serializer<CompleteLevelAttemptRequest> get serializer =>
      _$CompleteLevelAttemptRequestSerializer();
}

class _$CompleteLevelAttemptRequestSerializer
    implements PrimitiveSerializer<CompleteLevelAttemptRequest> {
  @override
  final Iterable<Type> types = const [
    CompleteLevelAttemptRequest,
    _$CompleteLevelAttemptRequest
  ];

  @override
  final String wireName = r'CompleteLevelAttemptRequest';

  Iterable<Object?> _serializeProperties(
    Serializers serializers,
    CompleteLevelAttemptRequest object, {
    FullType specifiedType = FullType.unspecified,
  }) sync* {
    yield r'clientEventId';
    yield serializers.serialize(
      object.clientEventId,
      specifiedType: const FullType(String),
    );
    yield r'answers';
    yield serializers.serialize(
      object.answers,
      specifiedType: const FullType(BuiltList, [FullType(QuizAnswer)]),
    );
  }

  @override
  Object serialize(
    Serializers serializers,
    CompleteLevelAttemptRequest object, {
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
    required CompleteLevelAttemptRequestBuilder result,
    required List<Object?> unhandled,
  }) {
    for (var i = 0; i < serializedList.length; i += 2) {
      final key = serializedList[i] as String;
      final value = serializedList[i + 1];
      switch (key) {
        case r'clientEventId':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType(String),
          ) as String;
          result.clientEventId = valueDes;
          break;
        case r'answers':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType(BuiltList, [FullType(QuizAnswer)]),
          ) as BuiltList<QuizAnswer>;
          result.answers.replace(valueDes);
          break;
        default:
          unhandled.add(key);
          unhandled.add(value);
          break;
      }
    }
  }

  @override
  CompleteLevelAttemptRequest deserialize(
    Serializers serializers,
    Object serialized, {
    FullType specifiedType = FullType.unspecified,
  }) {
    final result = CompleteLevelAttemptRequestBuilder();
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
