//
// AUTO-GENERATED FILE, DO NOT MODIFY!
//

// ignore_for_file: unused_element
import 'package:built_collection/built_collection.dart';
import 'package:openapi/src/model/learning_event.dart';
import 'package:built_value/built_value.dart';
import 'package:built_value/serializer.dart';

part 'learning_event_batch.g.dart';

/// LearningEventBatch
///
/// Properties:
/// * [events]
@BuiltValue()
abstract class LearningEventBatch
    implements Built<LearningEventBatch, LearningEventBatchBuilder> {
  @BuiltValueField(wireName: r'events')
  BuiltList<LearningEvent> get events;

  LearningEventBatch._();

  factory LearningEventBatch([void updates(LearningEventBatchBuilder b)]) =
      _$LearningEventBatch;

  @BuiltValueHook(initializeBuilder: true)
  static void _defaults(LearningEventBatchBuilder b) => b;

  @BuiltValueSerializer(custom: true)
  static Serializer<LearningEventBatch> get serializer =>
      _$LearningEventBatchSerializer();
}

class _$LearningEventBatchSerializer
    implements PrimitiveSerializer<LearningEventBatch> {
  @override
  final Iterable<Type> types = const [LearningEventBatch, _$LearningEventBatch];

  @override
  final String wireName = r'LearningEventBatch';

  Iterable<Object?> _serializeProperties(
    Serializers serializers,
    LearningEventBatch object, {
    FullType specifiedType = FullType.unspecified,
  }) sync* {
    yield r'events';
    yield serializers.serialize(
      object.events,
      specifiedType: const FullType(BuiltList, [FullType(LearningEvent)]),
    );
  }

  @override
  Object serialize(
    Serializers serializers,
    LearningEventBatch object, {
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
    required LearningEventBatchBuilder result,
    required List<Object?> unhandled,
  }) {
    for (var i = 0; i < serializedList.length; i += 2) {
      final key = serializedList[i] as String;
      final value = serializedList[i + 1];
      switch (key) {
        case r'events':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType(BuiltList, [FullType(LearningEvent)]),
          ) as BuiltList<LearningEvent>;
          result.events.replace(valueDes);
          break;
        default:
          unhandled.add(key);
          unhandled.add(value);
          break;
      }
    }
  }

  @override
  LearningEventBatch deserialize(
    Serializers serializers,
    Object serialized, {
    FullType specifiedType = FullType.unspecified,
  }) {
    final result = LearningEventBatchBuilder();
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
