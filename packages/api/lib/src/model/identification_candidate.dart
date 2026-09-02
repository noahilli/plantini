//
// AUTO-GENERATED FILE, DO NOT MODIFY!
//

// ignore_for_file: unused_element
import 'package:built_value/built_value.dart';
import 'package:built_value/serializer.dart';

part 'identification_candidate.g.dart';

/// IdentificationCandidate
///
/// Properties:
/// * [candidateId]
/// * [plantId]
/// * [scientificName]
/// * [commonName]
/// * [score]
/// * [provider]
/// * [modelVersion]
/// * [safetyNotice]
@BuiltValue()
abstract class IdentificationCandidate
    implements Built<IdentificationCandidate, IdentificationCandidateBuilder> {
  @BuiltValueField(wireName: r'candidateId')
  String get candidateId;

  @BuiltValueField(wireName: r'plantId')
  String? get plantId;

  @BuiltValueField(wireName: r'scientificName')
  String get scientificName;

  @BuiltValueField(wireName: r'commonName')
  String? get commonName;

  @BuiltValueField(wireName: r'score')
  num get score;

  @BuiltValueField(wireName: r'provider')
  String? get provider;

  @BuiltValueField(wireName: r'modelVersion')
  String? get modelVersion;

  @BuiltValueField(wireName: r'safetyNotice')
  String? get safetyNotice;

  IdentificationCandidate._();

  factory IdentificationCandidate(
          [void updates(IdentificationCandidateBuilder b)]) =
      _$IdentificationCandidate;

  @BuiltValueHook(initializeBuilder: true)
  static void _defaults(IdentificationCandidateBuilder b) => b;

  @BuiltValueSerializer(custom: true)
  static Serializer<IdentificationCandidate> get serializer =>
      _$IdentificationCandidateSerializer();
}

class _$IdentificationCandidateSerializer
    implements PrimitiveSerializer<IdentificationCandidate> {
  @override
  final Iterable<Type> types = const [
    IdentificationCandidate,
    _$IdentificationCandidate
  ];

  @override
  final String wireName = r'IdentificationCandidate';

  Iterable<Object?> _serializeProperties(
    Serializers serializers,
    IdentificationCandidate object, {
    FullType specifiedType = FullType.unspecified,
  }) sync* {
    yield r'candidateId';
    yield serializers.serialize(
      object.candidateId,
      specifiedType: const FullType(String),
    );
    if (object.plantId != null) {
      yield r'plantId';
      yield serializers.serialize(
        object.plantId,
        specifiedType: const FullType(String),
      );
    }
    yield r'scientificName';
    yield serializers.serialize(
      object.scientificName,
      specifiedType: const FullType(String),
    );
    if (object.commonName != null) {
      yield r'commonName';
      yield serializers.serialize(
        object.commonName,
        specifiedType: const FullType(String),
      );
    }
    yield r'score';
    yield serializers.serialize(
      object.score,
      specifiedType: const FullType(num),
    );
    if (object.provider != null) {
      yield r'provider';
      yield serializers.serialize(
        object.provider,
        specifiedType: const FullType(String),
      );
    }
    if (object.modelVersion != null) {
      yield r'modelVersion';
      yield serializers.serialize(
        object.modelVersion,
        specifiedType: const FullType(String),
      );
    }
    if (object.safetyNotice != null) {
      yield r'safetyNotice';
      yield serializers.serialize(
        object.safetyNotice,
        specifiedType: const FullType(String),
      );
    }
  }

  @override
  Object serialize(
    Serializers serializers,
    IdentificationCandidate object, {
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
    required IdentificationCandidateBuilder result,
    required List<Object?> unhandled,
  }) {
    for (var i = 0; i < serializedList.length; i += 2) {
      final key = serializedList[i] as String;
      final value = serializedList[i + 1];
      switch (key) {
        case r'candidateId':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType(String),
          ) as String;
          result.candidateId = valueDes;
          break;
        case r'plantId':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType.nullable(String),
          ) as String?;
          if (valueDes == null) continue;
          result.plantId = valueDes;
          break;
        case r'scientificName':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType(String),
          ) as String;
          result.scientificName = valueDes;
          break;
        case r'commonName':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType.nullable(String),
          ) as String?;
          if (valueDes == null) continue;
          result.commonName = valueDes;
          break;
        case r'score':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType(num),
          ) as num;
          result.score = valueDes;
          break;
        case r'provider':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType.nullable(String),
          ) as String?;
          if (valueDes == null) continue;
          result.provider = valueDes;
          break;
        case r'modelVersion':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType.nullable(String),
          ) as String?;
          if (valueDes == null) continue;
          result.modelVersion = valueDes;
          break;
        case r'safetyNotice':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType.nullable(String),
          ) as String?;
          if (valueDes == null) continue;
          result.safetyNotice = valueDes;
          break;
        default:
          unhandled.add(key);
          unhandled.add(value);
          break;
      }
    }
  }

  @override
  IdentificationCandidate deserialize(
    Serializers serializers,
    Object serialized, {
    FullType specifiedType = FullType.unspecified,
  }) {
    final result = IdentificationCandidateBuilder();
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
