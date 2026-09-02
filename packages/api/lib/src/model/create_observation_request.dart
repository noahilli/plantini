//
// AUTO-GENERATED FILE, DO NOT MODIFY!
//

// ignore_for_file: unused_element
import 'package:openapi/src/model/private_location.dart';
import 'package:built_value/built_value.dart';
import 'package:built_value/serializer.dart';

part 'create_observation_request.g.dart';

/// CreateObservationRequest
///
/// Properties:
/// * [clientObservationId]
/// * [observedAt]
/// * [note]
/// * [mediaId]
/// * [identificationJobId]
/// * [location]
@BuiltValue()
abstract class CreateObservationRequest
    implements
        Built<CreateObservationRequest, CreateObservationRequestBuilder> {
  @BuiltValueField(wireName: r'clientObservationId')
  String get clientObservationId;

  @BuiltValueField(wireName: r'observedAt')
  DateTime get observedAt;

  @BuiltValueField(wireName: r'note')
  String? get note;

  @BuiltValueField(wireName: r'mediaId')
  String? get mediaId;

  @BuiltValueField(wireName: r'identificationJobId')
  String? get identificationJobId;

  @BuiltValueField(wireName: r'location')
  PrivateLocation? get location;

  CreateObservationRequest._();

  factory CreateObservationRequest(
          [void updates(CreateObservationRequestBuilder b)]) =
      _$CreateObservationRequest;

  @BuiltValueHook(initializeBuilder: true)
  static void _defaults(CreateObservationRequestBuilder b) => b;

  @BuiltValueSerializer(custom: true)
  static Serializer<CreateObservationRequest> get serializer =>
      _$CreateObservationRequestSerializer();
}

class _$CreateObservationRequestSerializer
    implements PrimitiveSerializer<CreateObservationRequest> {
  @override
  final Iterable<Type> types = const [
    CreateObservationRequest,
    _$CreateObservationRequest
  ];

  @override
  final String wireName = r'CreateObservationRequest';

  Iterable<Object?> _serializeProperties(
    Serializers serializers,
    CreateObservationRequest object, {
    FullType specifiedType = FullType.unspecified,
  }) sync* {
    yield r'clientObservationId';
    yield serializers.serialize(
      object.clientObservationId,
      specifiedType: const FullType(String),
    );
    yield r'observedAt';
    yield serializers.serialize(
      object.observedAt,
      specifiedType: const FullType(DateTime),
    );
    if (object.note != null) {
      yield r'note';
      yield serializers.serialize(
        object.note,
        specifiedType: const FullType(String),
      );
    }
    if (object.mediaId != null) {
      yield r'mediaId';
      yield serializers.serialize(
        object.mediaId,
        specifiedType: const FullType(String),
      );
    }
    if (object.identificationJobId != null) {
      yield r'identificationJobId';
      yield serializers.serialize(
        object.identificationJobId,
        specifiedType: const FullType(String),
      );
    }
    if (object.location != null) {
      yield r'location';
      yield serializers.serialize(
        object.location,
        specifiedType: const FullType(PrivateLocation),
      );
    }
  }

  @override
  Object serialize(
    Serializers serializers,
    CreateObservationRequest object, {
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
    required CreateObservationRequestBuilder result,
    required List<Object?> unhandled,
  }) {
    for (var i = 0; i < serializedList.length; i += 2) {
      final key = serializedList[i] as String;
      final value = serializedList[i + 1];
      switch (key) {
        case r'clientObservationId':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType(String),
          ) as String;
          result.clientObservationId = valueDes;
          break;
        case r'observedAt':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType(DateTime),
          ) as DateTime;
          result.observedAt = valueDes;
          break;
        case r'note':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType.nullable(String),
          ) as String?;
          if (valueDes == null) continue;
          result.note = valueDes;
          break;
        case r'mediaId':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType.nullable(String),
          ) as String?;
          if (valueDes == null) continue;
          result.mediaId = valueDes;
          break;
        case r'identificationJobId':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType.nullable(String),
          ) as String?;
          if (valueDes == null) continue;
          result.identificationJobId = valueDes;
          break;
        case r'location':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType.nullable(PrivateLocation),
          ) as PrivateLocation?;
          if (valueDes == null) continue;
          result.location.replace(valueDes);
          break;
        default:
          unhandled.add(key);
          unhandled.add(value);
          break;
      }
    }
  }

  @override
  CreateObservationRequest deserialize(
    Serializers serializers,
    Object serialized, {
    FullType specifiedType = FullType.unspecified,
  }) {
    final result = CreateObservationRequestBuilder();
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
