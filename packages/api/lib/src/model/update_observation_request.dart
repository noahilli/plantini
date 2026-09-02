//
// AUTO-GENERATED FILE, DO NOT MODIFY!
//

// ignore_for_file: unused_element
import 'package:built_value/built_value.dart';
import 'package:built_value/serializer.dart';

part 'update_observation_request.g.dart';

/// UpdateObservationRequest
///
/// Properties:
/// * [note]
/// * [confirmedPlantId]
@BuiltValue()
abstract class UpdateObservationRequest
    implements
        Built<UpdateObservationRequest, UpdateObservationRequestBuilder> {
  @BuiltValueField(wireName: r'note')
  String? get note;

  @BuiltValueField(wireName: r'confirmedPlantId')
  String? get confirmedPlantId;

  UpdateObservationRequest._();

  factory UpdateObservationRequest(
          [void updates(UpdateObservationRequestBuilder b)]) =
      _$UpdateObservationRequest;

  @BuiltValueHook(initializeBuilder: true)
  static void _defaults(UpdateObservationRequestBuilder b) => b;

  @BuiltValueSerializer(custom: true)
  static Serializer<UpdateObservationRequest> get serializer =>
      _$UpdateObservationRequestSerializer();
}

class _$UpdateObservationRequestSerializer
    implements PrimitiveSerializer<UpdateObservationRequest> {
  @override
  final Iterable<Type> types = const [
    UpdateObservationRequest,
    _$UpdateObservationRequest
  ];

  @override
  final String wireName = r'UpdateObservationRequest';

  Iterable<Object?> _serializeProperties(
    Serializers serializers,
    UpdateObservationRequest object, {
    FullType specifiedType = FullType.unspecified,
  }) sync* {
    if (object.note != null) {
      yield r'note';
      yield serializers.serialize(
        object.note,
        specifiedType: const FullType(String),
      );
    }
    if (object.confirmedPlantId != null) {
      yield r'confirmedPlantId';
      yield serializers.serialize(
        object.confirmedPlantId,
        specifiedType: const FullType(String),
      );
    }
  }

  @override
  Object serialize(
    Serializers serializers,
    UpdateObservationRequest object, {
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
    required UpdateObservationRequestBuilder result,
    required List<Object?> unhandled,
  }) {
    for (var i = 0; i < serializedList.length; i += 2) {
      final key = serializedList[i] as String;
      final value = serializedList[i + 1];
      switch (key) {
        case r'note':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType.nullable(String),
          ) as String?;
          if (valueDes == null) continue;
          result.note = valueDes;
          break;
        case r'confirmedPlantId':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType.nullable(String),
          ) as String?;
          if (valueDes == null) continue;
          result.confirmedPlantId = valueDes;
          break;
        default:
          unhandled.add(key);
          unhandled.add(value);
          break;
      }
    }
  }

  @override
  UpdateObservationRequest deserialize(
    Serializers serializers,
    Object serialized, {
    FullType specifiedType = FullType.unspecified,
  }) {
    final result = UpdateObservationRequestBuilder();
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
