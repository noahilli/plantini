//
// AUTO-GENERATED FILE, DO NOT MODIFY!
//

// ignore_for_file: unused_element
import 'package:built_value/built_value.dart';
import 'package:built_value/serializer.dart';

part 'confirm_identification_request.g.dart';

/// ConfirmIdentificationRequest
///
/// Properties:
/// * [candidateId]
/// * [confirmedPlantId]
/// * [acceptMismatch]
@BuiltValue()
abstract class ConfirmIdentificationRequest
    implements
        Built<ConfirmIdentificationRequest,
            ConfirmIdentificationRequestBuilder> {
  @BuiltValueField(wireName: r'candidateId')
  String? get candidateId;

  @BuiltValueField(wireName: r'confirmedPlantId')
  String? get confirmedPlantId;

  @BuiltValueField(wireName: r'acceptMismatch')
  bool? get acceptMismatch;

  ConfirmIdentificationRequest._();

  factory ConfirmIdentificationRequest(
          [void updates(ConfirmIdentificationRequestBuilder b)]) =
      _$ConfirmIdentificationRequest;

  @BuiltValueHook(initializeBuilder: true)
  static void _defaults(ConfirmIdentificationRequestBuilder b) =>
      b..acceptMismatch = false;

  @BuiltValueSerializer(custom: true)
  static Serializer<ConfirmIdentificationRequest> get serializer =>
      _$ConfirmIdentificationRequestSerializer();
}

class _$ConfirmIdentificationRequestSerializer
    implements PrimitiveSerializer<ConfirmIdentificationRequest> {
  @override
  final Iterable<Type> types = const [
    ConfirmIdentificationRequest,
    _$ConfirmIdentificationRequest
  ];

  @override
  final String wireName = r'ConfirmIdentificationRequest';

  Iterable<Object?> _serializeProperties(
    Serializers serializers,
    ConfirmIdentificationRequest object, {
    FullType specifiedType = FullType.unspecified,
  }) sync* {
    if (object.candidateId != null) {
      yield r'candidateId';
      yield serializers.serialize(
        object.candidateId,
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
    if (object.acceptMismatch != null) {
      yield r'acceptMismatch';
      yield serializers.serialize(
        object.acceptMismatch,
        specifiedType: const FullType(bool),
      );
    }
  }

  @override
  Object serialize(
    Serializers serializers,
    ConfirmIdentificationRequest object, {
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
    required ConfirmIdentificationRequestBuilder result,
    required List<Object?> unhandled,
  }) {
    for (var i = 0; i < serializedList.length; i += 2) {
      final key = serializedList[i] as String;
      final value = serializedList[i + 1];
      switch (key) {
        case r'candidateId':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType.nullable(String),
          ) as String?;
          if (valueDes == null) continue;
          result.candidateId = valueDes;
          break;
        case r'confirmedPlantId':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType.nullable(String),
          ) as String?;
          if (valueDes == null) continue;
          result.confirmedPlantId = valueDes;
          break;
        case r'acceptMismatch':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType.nullable(bool),
          ) as bool?;
          if (valueDes == null) continue;
          result.acceptMismatch = valueDes;
          break;
        default:
          unhandled.add(key);
          unhandled.add(value);
          break;
      }
    }
  }

  @override
  ConfirmIdentificationRequest deserialize(
    Serializers serializers,
    Object serialized, {
    FullType specifiedType = FullType.unspecified,
  }) {
    final result = ConfirmIdentificationRequestBuilder();
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
