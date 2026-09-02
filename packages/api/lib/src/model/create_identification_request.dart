//
// AUTO-GENERATED FILE, DO NOT MODIFY!
//

// ignore_for_file: unused_element
import 'package:built_value/built_value.dart';
import 'package:built_value/serializer.dart';

part 'create_identification_request.g.dart';

/// CreateIdentificationRequest
///
/// Properties:
/// * [clientJobId]
/// * [mediaId]
/// * [expectedPlantId]
@BuiltValue()
abstract class CreateIdentificationRequest
    implements
        Built<CreateIdentificationRequest, CreateIdentificationRequestBuilder> {
  @BuiltValueField(wireName: r'clientJobId')
  String get clientJobId;

  @BuiltValueField(wireName: r'mediaId')
  String get mediaId;

  @BuiltValueField(wireName: r'expectedPlantId')
  String? get expectedPlantId;

  CreateIdentificationRequest._();

  factory CreateIdentificationRequest(
          [void updates(CreateIdentificationRequestBuilder b)]) =
      _$CreateIdentificationRequest;

  @BuiltValueHook(initializeBuilder: true)
  static void _defaults(CreateIdentificationRequestBuilder b) => b;

  @BuiltValueSerializer(custom: true)
  static Serializer<CreateIdentificationRequest> get serializer =>
      _$CreateIdentificationRequestSerializer();
}

class _$CreateIdentificationRequestSerializer
    implements PrimitiveSerializer<CreateIdentificationRequest> {
  @override
  final Iterable<Type> types = const [
    CreateIdentificationRequest,
    _$CreateIdentificationRequest
  ];

  @override
  final String wireName = r'CreateIdentificationRequest';

  Iterable<Object?> _serializeProperties(
    Serializers serializers,
    CreateIdentificationRequest object, {
    FullType specifiedType = FullType.unspecified,
  }) sync* {
    yield r'clientJobId';
    yield serializers.serialize(
      object.clientJobId,
      specifiedType: const FullType(String),
    );
    yield r'mediaId';
    yield serializers.serialize(
      object.mediaId,
      specifiedType: const FullType(String),
    );
    if (object.expectedPlantId != null) {
      yield r'expectedPlantId';
      yield serializers.serialize(
        object.expectedPlantId,
        specifiedType: const FullType(String),
      );
    }
  }

  @override
  Object serialize(
    Serializers serializers,
    CreateIdentificationRequest object, {
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
    required CreateIdentificationRequestBuilder result,
    required List<Object?> unhandled,
  }) {
    for (var i = 0; i < serializedList.length; i += 2) {
      final key = serializedList[i] as String;
      final value = serializedList[i + 1];
      switch (key) {
        case r'clientJobId':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType(String),
          ) as String;
          result.clientJobId = valueDes;
          break;
        case r'mediaId':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType(String),
          ) as String;
          result.mediaId = valueDes;
          break;
        case r'expectedPlantId':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType.nullable(String),
          ) as String?;
          if (valueDes == null) continue;
          result.expectedPlantId = valueDes;
          break;
        default:
          unhandled.add(key);
          unhandled.add(value);
          break;
      }
    }
  }

  @override
  CreateIdentificationRequest deserialize(
    Serializers serializers,
    Object serialized, {
    FullType specifiedType = FullType.unspecified,
  }) {
    final result = CreateIdentificationRequestBuilder();
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
