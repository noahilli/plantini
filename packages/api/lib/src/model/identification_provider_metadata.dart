//
// AUTO-GENERATED FILE, DO NOT MODIFY!
//

// ignore_for_file: unused_element
import 'package:built_value/built_value.dart';
import 'package:built_value/serializer.dart';

part 'identification_provider_metadata.g.dart';

/// IdentificationProviderMetadata
///
/// Properties:
/// * [provider]
/// * [modelVersion]
/// * [floraVersion]
@BuiltValue()
abstract class IdentificationProviderMetadata
    implements
        Built<IdentificationProviderMetadata,
            IdentificationProviderMetadataBuilder> {
  @BuiltValueField(wireName: r'provider')
  String get provider;

  @BuiltValueField(wireName: r'modelVersion')
  String get modelVersion;

  @BuiltValueField(wireName: r'floraVersion')
  String get floraVersion;

  IdentificationProviderMetadata._();

  factory IdentificationProviderMetadata(
          [void updates(IdentificationProviderMetadataBuilder b)]) =
      _$IdentificationProviderMetadata;

  @BuiltValueHook(initializeBuilder: true)
  static void _defaults(IdentificationProviderMetadataBuilder b) => b;

  @BuiltValueSerializer(custom: true)
  static Serializer<IdentificationProviderMetadata> get serializer =>
      _$IdentificationProviderMetadataSerializer();
}

class _$IdentificationProviderMetadataSerializer
    implements PrimitiveSerializer<IdentificationProviderMetadata> {
  @override
  final Iterable<Type> types = const [
    IdentificationProviderMetadata,
    _$IdentificationProviderMetadata
  ];

  @override
  final String wireName = r'IdentificationProviderMetadata';

  Iterable<Object?> _serializeProperties(
    Serializers serializers,
    IdentificationProviderMetadata object, {
    FullType specifiedType = FullType.unspecified,
  }) sync* {
    yield r'provider';
    yield serializers.serialize(
      object.provider,
      specifiedType: const FullType(String),
    );
    yield r'modelVersion';
    yield serializers.serialize(
      object.modelVersion,
      specifiedType: const FullType(String),
    );
    yield r'floraVersion';
    yield serializers.serialize(
      object.floraVersion,
      specifiedType: const FullType(String),
    );
  }

  @override
  Object serialize(
    Serializers serializers,
    IdentificationProviderMetadata object, {
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
    required IdentificationProviderMetadataBuilder result,
    required List<Object?> unhandled,
  }) {
    for (var i = 0; i < serializedList.length; i += 2) {
      final key = serializedList[i] as String;
      final value = serializedList[i + 1];
      switch (key) {
        case r'provider':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType(String),
          ) as String;
          result.provider = valueDes;
          break;
        case r'modelVersion':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType(String),
          ) as String;
          result.modelVersion = valueDes;
          break;
        case r'floraVersion':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType(String),
          ) as String;
          result.floraVersion = valueDes;
          break;
        default:
          unhandled.add(key);
          unhandled.add(value);
          break;
      }
    }
  }

  @override
  IdentificationProviderMetadata deserialize(
    Serializers serializers,
    Object serialized, {
    FullType specifiedType = FullType.unspecified,
  }) {
    final result = IdentificationProviderMetadataBuilder();
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
