//
// AUTO-GENERATED FILE, DO NOT MODIFY!
//

// ignore_for_file: unused_element
import 'package:built_value/json_object.dart';
import 'package:built_value/built_value.dart';
import 'package:built_value/serializer.dart';

part 'learning_event.g.dart';

/// LearningEvent
///
/// Properties:
/// * [clientEventId]
/// * [type]
/// * [occurredAt]
/// * [payloadVersion]
/// * [payload]
@BuiltValue()
abstract class LearningEvent
    implements Built<LearningEvent, LearningEventBuilder> {
  @BuiltValueField(wireName: r'clientEventId')
  String get clientEventId;

  @BuiltValueField(wireName: r'type')
  String get type;

  @BuiltValueField(wireName: r'occurredAt')
  DateTime get occurredAt;

  @BuiltValueField(wireName: r'payloadVersion')
  int get payloadVersion;

  @BuiltValueField(wireName: r'payload')
  JsonObject? get payload;

  LearningEvent._();

  factory LearningEvent([void updates(LearningEventBuilder b)]) =
      _$LearningEvent;

  @BuiltValueHook(initializeBuilder: true)
  static void _defaults(LearningEventBuilder b) => b;

  @BuiltValueSerializer(custom: true)
  static Serializer<LearningEvent> get serializer =>
      _$LearningEventSerializer();
}

class _$LearningEventSerializer implements PrimitiveSerializer<LearningEvent> {
  @override
  final Iterable<Type> types = const [LearningEvent, _$LearningEvent];

  @override
  final String wireName = r'LearningEvent';

  Iterable<Object?> _serializeProperties(
    Serializers serializers,
    LearningEvent object, {
    FullType specifiedType = FullType.unspecified,
  }) sync* {
    yield r'clientEventId';
    yield serializers.serialize(
      object.clientEventId,
      specifiedType: const FullType(String),
    );
    yield r'type';
    yield serializers.serialize(
      object.type,
      specifiedType: const FullType(String),
    );
    yield r'occurredAt';
    yield serializers.serialize(
      object.occurredAt,
      specifiedType: const FullType(DateTime),
    );
    yield r'payloadVersion';
    yield serializers.serialize(
      object.payloadVersion,
      specifiedType: const FullType(int),
    );
    if (object.payload != null) {
      yield r'payload';
      yield serializers.serialize(
        object.payload,
        specifiedType: const FullType(JsonObject),
      );
    }
  }

  @override
  Object serialize(
    Serializers serializers,
    LearningEvent object, {
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
    required LearningEventBuilder result,
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
        case r'type':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType(String),
          ) as String;
          result.type = valueDes;
          break;
        case r'occurredAt':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType(DateTime),
          ) as DateTime;
          result.occurredAt = valueDes;
          break;
        case r'payloadVersion':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType(int),
          ) as int;
          result.payloadVersion = valueDes;
          break;
        case r'payload':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType.nullable(JsonObject),
          ) as JsonObject?;
          if (valueDes == null) continue;
          result.payload = valueDes;
          break;
        default:
          unhandled.add(key);
          unhandled.add(value);
          break;
      }
    }
  }

  @override
  LearningEvent deserialize(
    Serializers serializers,
    Object serialized, {
    FullType specifiedType = FullType.unspecified,
  }) {
    final result = LearningEventBuilder();
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
