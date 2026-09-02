//
// AUTO-GENERATED FILE, DO NOT MODIFY!
//

// ignore_for_file: unused_element
import 'package:openapi/src/model/identification_candidate.dart';
import 'package:built_collection/built_collection.dart';
import 'package:openapi/src/model/identification_provider_metadata.dart';
import 'package:built_value/built_value.dart';
import 'package:built_value/serializer.dart';

part 'identification_job.g.dart';

/// IdentificationJob
///
/// Properties:
/// * [id]
/// * [status]
/// * [createdAt]
/// * [attempts]
/// * [retryAfter]
/// * [candidates]
/// * [providerMetadata]
/// * [expectedPlantId]
/// * [expectedMatch]
/// * [expectedCandidateId]
/// * [failureCode]
/// * [deadLetteredAt]
/// * [confirmedPlantId]
/// * [confirmedCandidateId]
@BuiltValue()
abstract class IdentificationJob
    implements Built<IdentificationJob, IdentificationJobBuilder> {
  @BuiltValueField(wireName: r'id')
  String get id;

  @BuiltValueField(wireName: r'status')
  IdentificationJobStatusEnum get status;
  // enum statusEnum {  pending,  processing,  identified,  failed,  cancelled,  };

  @BuiltValueField(wireName: r'createdAt')
  DateTime get createdAt;

  @BuiltValueField(wireName: r'attempts')
  int get attempts;

  @BuiltValueField(wireName: r'retryAfter')
  DateTime? get retryAfter;

  @BuiltValueField(wireName: r'candidates')
  BuiltList<IdentificationCandidate>? get candidates;

  @BuiltValueField(wireName: r'providerMetadata')
  IdentificationProviderMetadata? get providerMetadata;

  @BuiltValueField(wireName: r'expectedPlantId')
  String? get expectedPlantId;

  @BuiltValueField(wireName: r'expectedMatch')
  IdentificationJobExpectedMatchEnum? get expectedMatch;
  // enum expectedMatchEnum {  matched,  mismatch,  };

  @BuiltValueField(wireName: r'expectedCandidateId')
  String? get expectedCandidateId;

  @BuiltValueField(wireName: r'failureCode')
  String? get failureCode;

  @BuiltValueField(wireName: r'deadLetteredAt')
  DateTime? get deadLetteredAt;

  @BuiltValueField(wireName: r'confirmedPlantId')
  String? get confirmedPlantId;

  @BuiltValueField(wireName: r'confirmedCandidateId')
  String? get confirmedCandidateId;

  IdentificationJob._();

  factory IdentificationJob([void updates(IdentificationJobBuilder b)]) =
      _$IdentificationJob;

  @BuiltValueHook(initializeBuilder: true)
  static void _defaults(IdentificationJobBuilder b) => b;

  @BuiltValueSerializer(custom: true)
  static Serializer<IdentificationJob> get serializer =>
      _$IdentificationJobSerializer();
}

class _$IdentificationJobSerializer
    implements PrimitiveSerializer<IdentificationJob> {
  @override
  final Iterable<Type> types = const [IdentificationJob, _$IdentificationJob];

  @override
  final String wireName = r'IdentificationJob';

  Iterable<Object?> _serializeProperties(
    Serializers serializers,
    IdentificationJob object, {
    FullType specifiedType = FullType.unspecified,
  }) sync* {
    yield r'id';
    yield serializers.serialize(
      object.id,
      specifiedType: const FullType(String),
    );
    yield r'status';
    yield serializers.serialize(
      object.status,
      specifiedType: const FullType(IdentificationJobStatusEnum),
    );
    yield r'createdAt';
    yield serializers.serialize(
      object.createdAt,
      specifiedType: const FullType(DateTime),
    );
    yield r'attempts';
    yield serializers.serialize(
      object.attempts,
      specifiedType: const FullType(int),
    );
    if (object.retryAfter != null) {
      yield r'retryAfter';
      yield serializers.serialize(
        object.retryAfter,
        specifiedType: const FullType(DateTime),
      );
    }
    if (object.candidates != null) {
      yield r'candidates';
      yield serializers.serialize(
        object.candidates,
        specifiedType:
            const FullType(BuiltList, [FullType(IdentificationCandidate)]),
      );
    }
    if (object.providerMetadata != null) {
      yield r'providerMetadata';
      yield serializers.serialize(
        object.providerMetadata,
        specifiedType: const FullType(IdentificationProviderMetadata),
      );
    }
    if (object.expectedPlantId != null) {
      yield r'expectedPlantId';
      yield serializers.serialize(
        object.expectedPlantId,
        specifiedType: const FullType(String),
      );
    }
    if (object.expectedMatch != null) {
      yield r'expectedMatch';
      yield serializers.serialize(
        object.expectedMatch,
        specifiedType: const FullType(IdentificationJobExpectedMatchEnum),
      );
    }
    if (object.expectedCandidateId != null) {
      yield r'expectedCandidateId';
      yield serializers.serialize(
        object.expectedCandidateId,
        specifiedType: const FullType(String),
      );
    }
    if (object.failureCode != null) {
      yield r'failureCode';
      yield serializers.serialize(
        object.failureCode,
        specifiedType: const FullType(String),
      );
    }
    if (object.deadLetteredAt != null) {
      yield r'deadLetteredAt';
      yield serializers.serialize(
        object.deadLetteredAt,
        specifiedType: const FullType(DateTime),
      );
    }
    if (object.confirmedPlantId != null) {
      yield r'confirmedPlantId';
      yield serializers.serialize(
        object.confirmedPlantId,
        specifiedType: const FullType(String),
      );
    }
    if (object.confirmedCandidateId != null) {
      yield r'confirmedCandidateId';
      yield serializers.serialize(
        object.confirmedCandidateId,
        specifiedType: const FullType(String),
      );
    }
  }

  @override
  Object serialize(
    Serializers serializers,
    IdentificationJob object, {
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
    required IdentificationJobBuilder result,
    required List<Object?> unhandled,
  }) {
    for (var i = 0; i < serializedList.length; i += 2) {
      final key = serializedList[i] as String;
      final value = serializedList[i + 1];
      switch (key) {
        case r'id':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType(String),
          ) as String;
          result.id = valueDes;
          break;
        case r'status':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType(IdentificationJobStatusEnum),
          ) as IdentificationJobStatusEnum;
          result.status = valueDes;
          break;
        case r'createdAt':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType(DateTime),
          ) as DateTime;
          result.createdAt = valueDes;
          break;
        case r'attempts':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType(int),
          ) as int;
          result.attempts = valueDes;
          break;
        case r'retryAfter':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType.nullable(DateTime),
          ) as DateTime?;
          if (valueDes == null) continue;
          result.retryAfter = valueDes;
          break;
        case r'candidates':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType.nullable(
                BuiltList, [FullType(IdentificationCandidate)]),
          ) as BuiltList<IdentificationCandidate>?;
          if (valueDes == null) continue;
          result.candidates.replace(valueDes);
          break;
        case r'providerMetadata':
          final valueDes = serializers.deserialize(
            value,
            specifiedType:
                const FullType.nullable(IdentificationProviderMetadata),
          ) as IdentificationProviderMetadata?;
          if (valueDes == null) continue;
          result.providerMetadata.replace(valueDes);
          break;
        case r'expectedPlantId':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType.nullable(String),
          ) as String?;
          if (valueDes == null) continue;
          result.expectedPlantId = valueDes;
          break;
        case r'expectedMatch':
          final valueDes = serializers.deserialize(
            value,
            specifiedType:
                const FullType.nullable(IdentificationJobExpectedMatchEnum),
          ) as IdentificationJobExpectedMatchEnum?;
          if (valueDes == null) continue;
          result.expectedMatch = valueDes;
          break;
        case r'expectedCandidateId':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType.nullable(String),
          ) as String?;
          if (valueDes == null) continue;
          result.expectedCandidateId = valueDes;
          break;
        case r'failureCode':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType.nullable(String),
          ) as String?;
          if (valueDes == null) continue;
          result.failureCode = valueDes;
          break;
        case r'deadLetteredAt':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType.nullable(DateTime),
          ) as DateTime?;
          if (valueDes == null) continue;
          result.deadLetteredAt = valueDes;
          break;
        case r'confirmedPlantId':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType.nullable(String),
          ) as String?;
          if (valueDes == null) continue;
          result.confirmedPlantId = valueDes;
          break;
        case r'confirmedCandidateId':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType.nullable(String),
          ) as String?;
          if (valueDes == null) continue;
          result.confirmedCandidateId = valueDes;
          break;
        default:
          unhandled.add(key);
          unhandled.add(value);
          break;
      }
    }
  }

  @override
  IdentificationJob deserialize(
    Serializers serializers,
    Object serialized, {
    FullType specifiedType = FullType.unspecified,
  }) {
    final result = IdentificationJobBuilder();
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

class IdentificationJobStatusEnum extends EnumClass {
  @BuiltValueEnumConst(wireName: r'pending')
  static const IdentificationJobStatusEnum pending =
      _$identificationJobStatusEnum_pending;
  @BuiltValueEnumConst(wireName: r'processing')
  static const IdentificationJobStatusEnum processing =
      _$identificationJobStatusEnum_processing;
  @BuiltValueEnumConst(wireName: r'identified')
  static const IdentificationJobStatusEnum identified =
      _$identificationJobStatusEnum_identified;
  @BuiltValueEnumConst(wireName: r'failed')
  static const IdentificationJobStatusEnum failed =
      _$identificationJobStatusEnum_failed;
  @BuiltValueEnumConst(wireName: r'cancelled')
  static const IdentificationJobStatusEnum cancelled =
      _$identificationJobStatusEnum_cancelled;

  static Serializer<IdentificationJobStatusEnum> get serializer =>
      _$identificationJobStatusEnumSerializer;

  const IdentificationJobStatusEnum._(String name) : super(name);

  static BuiltSet<IdentificationJobStatusEnum> get values =>
      _$identificationJobStatusEnumValues;
  static IdentificationJobStatusEnum valueOf(String name) =>
      _$identificationJobStatusEnumValueOf(name);
}

class IdentificationJobExpectedMatchEnum extends EnumClass {
  @BuiltValueEnumConst(wireName: r'matched')
  static const IdentificationJobExpectedMatchEnum matched =
      _$identificationJobExpectedMatchEnum_matched;
  @BuiltValueEnumConst(wireName: r'mismatch')
  static const IdentificationJobExpectedMatchEnum mismatch =
      _$identificationJobExpectedMatchEnum_mismatch;

  static Serializer<IdentificationJobExpectedMatchEnum> get serializer =>
      _$identificationJobExpectedMatchEnumSerializer;

  const IdentificationJobExpectedMatchEnum._(String name) : super(name);

  static BuiltSet<IdentificationJobExpectedMatchEnum> get values =>
      _$identificationJobExpectedMatchEnumValues;
  static IdentificationJobExpectedMatchEnum valueOf(String name) =>
      _$identificationJobExpectedMatchEnumValueOf(name);
}
