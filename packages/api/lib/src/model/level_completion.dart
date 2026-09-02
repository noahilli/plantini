//
// AUTO-GENERATED FILE, DO NOT MODIFY!
//

// ignore_for_file: unused_element
import 'package:built_collection/built_collection.dart';
import 'package:openapi/src/model/progress_snapshot.dart';
import 'package:built_value/built_value.dart';
import 'package:built_value/serializer.dart';

part 'level_completion.g.dart';

/// LevelCompletion
///
/// Properties:
/// * [attemptId]
/// * [passed]
/// * [score]
/// * [status]
/// * [progress]
@BuiltValue()
abstract class LevelCompletion
    implements Built<LevelCompletion, LevelCompletionBuilder> {
  @BuiltValueField(wireName: r'attemptId')
  String get attemptId;

  @BuiltValueField(wireName: r'passed')
  bool get passed;

  @BuiltValueField(wireName: r'score')
  num get score;

  @BuiltValueField(wireName: r'status')
  LevelCompletionStatusEnum get status;
  // enum statusEnum {  completed,  failed,  };

  @BuiltValueField(wireName: r'progress')
  ProgressSnapshot? get progress;

  LevelCompletion._();

  factory LevelCompletion([void updates(LevelCompletionBuilder b)]) =
      _$LevelCompletion;

  @BuiltValueHook(initializeBuilder: true)
  static void _defaults(LevelCompletionBuilder b) => b;

  @BuiltValueSerializer(custom: true)
  static Serializer<LevelCompletion> get serializer =>
      _$LevelCompletionSerializer();
}

class _$LevelCompletionSerializer
    implements PrimitiveSerializer<LevelCompletion> {
  @override
  final Iterable<Type> types = const [LevelCompletion, _$LevelCompletion];

  @override
  final String wireName = r'LevelCompletion';

  Iterable<Object?> _serializeProperties(
    Serializers serializers,
    LevelCompletion object, {
    FullType specifiedType = FullType.unspecified,
  }) sync* {
    yield r'attemptId';
    yield serializers.serialize(
      object.attemptId,
      specifiedType: const FullType(String),
    );
    yield r'passed';
    yield serializers.serialize(
      object.passed,
      specifiedType: const FullType(bool),
    );
    yield r'score';
    yield serializers.serialize(
      object.score,
      specifiedType: const FullType(num),
    );
    yield r'status';
    yield serializers.serialize(
      object.status,
      specifiedType: const FullType(LevelCompletionStatusEnum),
    );
    if (object.progress != null) {
      yield r'progress';
      yield serializers.serialize(
        object.progress,
        specifiedType: const FullType(ProgressSnapshot),
      );
    }
  }

  @override
  Object serialize(
    Serializers serializers,
    LevelCompletion object, {
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
    required LevelCompletionBuilder result,
    required List<Object?> unhandled,
  }) {
    for (var i = 0; i < serializedList.length; i += 2) {
      final key = serializedList[i] as String;
      final value = serializedList[i + 1];
      switch (key) {
        case r'attemptId':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType(String),
          ) as String;
          result.attemptId = valueDes;
          break;
        case r'passed':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType(bool),
          ) as bool;
          result.passed = valueDes;
          break;
        case r'score':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType(num),
          ) as num;
          result.score = valueDes;
          break;
        case r'status':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType(LevelCompletionStatusEnum),
          ) as LevelCompletionStatusEnum;
          result.status = valueDes;
          break;
        case r'progress':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType.nullable(ProgressSnapshot),
          ) as ProgressSnapshot?;
          if (valueDes == null) continue;
          result.progress.replace(valueDes);
          break;
        default:
          unhandled.add(key);
          unhandled.add(value);
          break;
      }
    }
  }

  @override
  LevelCompletion deserialize(
    Serializers serializers,
    Object serialized, {
    FullType specifiedType = FullType.unspecified,
  }) {
    final result = LevelCompletionBuilder();
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

class LevelCompletionStatusEnum extends EnumClass {
  @BuiltValueEnumConst(wireName: r'completed')
  static const LevelCompletionStatusEnum completed =
      _$levelCompletionStatusEnum_completed;
  @BuiltValueEnumConst(wireName: r'failed')
  static const LevelCompletionStatusEnum failed =
      _$levelCompletionStatusEnum_failed;

  static Serializer<LevelCompletionStatusEnum> get serializer =>
      _$levelCompletionStatusEnumSerializer;

  const LevelCompletionStatusEnum._(String name) : super(name);

  static BuiltSet<LevelCompletionStatusEnum> get values =>
      _$levelCompletionStatusEnumValues;
  static LevelCompletionStatusEnum valueOf(String name) =>
      _$levelCompletionStatusEnumValueOf(name);
}
