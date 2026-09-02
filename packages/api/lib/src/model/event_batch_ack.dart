//
// AUTO-GENERATED FILE, DO NOT MODIFY!
//

// ignore_for_file: unused_element
import 'package:built_collection/built_collection.dart';
import 'package:openapi/src/model/problem.dart';
import 'package:built_value/built_value.dart';
import 'package:built_value/serializer.dart';

part 'event_batch_ack.g.dart';

/// EventBatchAck
///
/// Properties:
/// * [acceptedClientEventIds]
/// * [rejected]
@BuiltValue()
abstract class EventBatchAck
    implements Built<EventBatchAck, EventBatchAckBuilder> {
  @BuiltValueField(wireName: r'acceptedClientEventIds')
  BuiltList<String> get acceptedClientEventIds;

  @BuiltValueField(wireName: r'rejected')
  BuiltList<Problem>? get rejected;

  EventBatchAck._();

  factory EventBatchAck([void updates(EventBatchAckBuilder b)]) =
      _$EventBatchAck;

  @BuiltValueHook(initializeBuilder: true)
  static void _defaults(EventBatchAckBuilder b) => b;

  @BuiltValueSerializer(custom: true)
  static Serializer<EventBatchAck> get serializer =>
      _$EventBatchAckSerializer();
}

class _$EventBatchAckSerializer implements PrimitiveSerializer<EventBatchAck> {
  @override
  final Iterable<Type> types = const [EventBatchAck, _$EventBatchAck];

  @override
  final String wireName = r'EventBatchAck';

  Iterable<Object?> _serializeProperties(
    Serializers serializers,
    EventBatchAck object, {
    FullType specifiedType = FullType.unspecified,
  }) sync* {
    yield r'acceptedClientEventIds';
    yield serializers.serialize(
      object.acceptedClientEventIds,
      specifiedType: const FullType(BuiltList, [FullType(String)]),
    );
    if (object.rejected != null) {
      yield r'rejected';
      yield serializers.serialize(
        object.rejected,
        specifiedType: const FullType(BuiltList, [FullType(Problem)]),
      );
    }
  }

  @override
  Object serialize(
    Serializers serializers,
    EventBatchAck object, {
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
    required EventBatchAckBuilder result,
    required List<Object?> unhandled,
  }) {
    for (var i = 0; i < serializedList.length; i += 2) {
      final key = serializedList[i] as String;
      final value = serializedList[i + 1];
      switch (key) {
        case r'acceptedClientEventIds':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType(BuiltList, [FullType(String)]),
          ) as BuiltList<String>;
          result.acceptedClientEventIds.replace(valueDes);
          break;
        case r'rejected':
          final valueDes = serializers.deserialize(
            value,
            specifiedType:
                const FullType.nullable(BuiltList, [FullType(Problem)]),
          ) as BuiltList<Problem>?;
          if (valueDes == null) continue;
          result.rejected.replace(valueDes);
          break;
        default:
          unhandled.add(key);
          unhandled.add(value);
          break;
      }
    }
  }

  @override
  EventBatchAck deserialize(
    Serializers serializers,
    Object serialized, {
    FullType specifiedType = FullType.unspecified,
  }) {
    final result = EventBatchAckBuilder();
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
