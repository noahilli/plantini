//
// AUTO-GENERATED FILE, DO NOT MODIFY!
//

// ignore_for_file: unused_element
import 'package:openapi/src/model/teaching_actor.dart';
import 'package:openapi/src/model/teaching_capabilities.dart';
import 'package:built_value/built_value.dart';
import 'package:built_value/serializer.dart';

part 'teaching_session.g.dart';

/// TeachingSession
///
/// Properties:
/// * [actor]
/// * [capabilities]
@BuiltValue()
abstract class TeachingSession
    implements Built<TeachingSession, TeachingSessionBuilder> {
  @BuiltValueField(wireName: r'actor')
  TeachingActor get actor;

  @BuiltValueField(wireName: r'capabilities')
  TeachingCapabilities get capabilities;

  TeachingSession._();

  factory TeachingSession([void updates(TeachingSessionBuilder b)]) =
      _$TeachingSession;

  @BuiltValueHook(initializeBuilder: true)
  static void _defaults(TeachingSessionBuilder b) => b;

  @BuiltValueSerializer(custom: true)
  static Serializer<TeachingSession> get serializer =>
      _$TeachingSessionSerializer();
}

class _$TeachingSessionSerializer
    implements PrimitiveSerializer<TeachingSession> {
  @override
  final Iterable<Type> types = const [TeachingSession, _$TeachingSession];

  @override
  final String wireName = r'TeachingSession';

  Iterable<Object?> _serializeProperties(
    Serializers serializers,
    TeachingSession object, {
    FullType specifiedType = FullType.unspecified,
  }) sync* {
    yield r'actor';
    yield serializers.serialize(
      object.actor,
      specifiedType: const FullType(TeachingActor),
    );
    yield r'capabilities';
    yield serializers.serialize(
      object.capabilities,
      specifiedType: const FullType(TeachingCapabilities),
    );
  }

  @override
  Object serialize(
    Serializers serializers,
    TeachingSession object, {
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
    required TeachingSessionBuilder result,
    required List<Object?> unhandled,
  }) {
    for (var i = 0; i < serializedList.length; i += 2) {
      final key = serializedList[i] as String;
      final value = serializedList[i + 1];
      switch (key) {
        case r'actor':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType(TeachingActor),
          ) as TeachingActor;
          result.actor.replace(valueDes);
          break;
        case r'capabilities':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType(TeachingCapabilities),
          ) as TeachingCapabilities;
          result.capabilities.replace(valueDes);
          break;
        default:
          unhandled.add(key);
          unhandled.add(value);
          break;
      }
    }
  }

  @override
  TeachingSession deserialize(
    Serializers serializers,
    Object serialized, {
    FullType specifiedType = FullType.unspecified,
  }) {
    final result = TeachingSessionBuilder();
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
