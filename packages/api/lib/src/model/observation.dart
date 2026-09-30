//
// AUTO-GENERATED FILE, DO NOT MODIFY!
//

// ignore_for_file: unused_element
import 'package:openapi/src/model/identification_job.dart';
import 'package:built_collection/built_collection.dart';
import 'package:openapi/src/model/observation_location.dart';
import 'package:built_value/built_value.dart';
import 'package:built_value/serializer.dart';

part 'observation.g.dart';

/// Observation
///
/// Properties:
/// * [id]
/// * [clientObservationId]
/// * [observedAt]
/// * [note]
/// * [confirmedPlantId]
/// * [speciesKey] - Set when the confirmed species is not in the catalogue; see /species/{speciesKey}.
/// * [speciesName]
/// * [mediaId]
/// * [mediaUrl] - Path of the photo, see /media/{mediaId}/content.
/// * [location]
/// * [identification]
/// * [version]
/// * [syncStatus]
@BuiltValue()
abstract class Observation implements Built<Observation, ObservationBuilder> {
  @BuiltValueField(wireName: r'id')
  String get id;

  @BuiltValueField(wireName: r'clientObservationId')
  String get clientObservationId;

  @BuiltValueField(wireName: r'observedAt')
  DateTime get observedAt;

  @BuiltValueField(wireName: r'note')
  String? get note;

  @BuiltValueField(wireName: r'confirmedPlantId')
  String? get confirmedPlantId;

  /// Set when the confirmed species is not in the catalogue; see /species/{speciesKey}.
  @BuiltValueField(wireName: r'speciesKey')
  String? get speciesKey;

  @BuiltValueField(wireName: r'speciesName')
  String? get speciesName;

  @BuiltValueField(wireName: r'mediaId')
  String? get mediaId;

  /// Path of the photo, see /media/{mediaId}/content.
  @BuiltValueField(wireName: r'mediaUrl')
  String? get mediaUrl;

  @BuiltValueField(wireName: r'location')
  ObservationLocation? get location;

  @BuiltValueField(wireName: r'identification')
  IdentificationJob? get identification;

  @BuiltValueField(wireName: r'version')
  String get version;

  @BuiltValueField(wireName: r'syncStatus')
  ObservationSyncStatusEnum get syncStatus;
  // enum syncStatusEnum {  synced,  pending,  conflict,  deleted,  };

  Observation._();

  factory Observation([void updates(ObservationBuilder b)]) = _$Observation;

  @BuiltValueHook(initializeBuilder: true)
  static void _defaults(ObservationBuilder b) => b;

  @BuiltValueSerializer(custom: true)
  static Serializer<Observation> get serializer => _$ObservationSerializer();
}

class _$ObservationSerializer implements PrimitiveSerializer<Observation> {
  @override
  final Iterable<Type> types = const [Observation, _$Observation];

  @override
  final String wireName = r'Observation';

  Iterable<Object?> _serializeProperties(
    Serializers serializers,
    Observation object, {
    FullType specifiedType = FullType.unspecified,
  }) sync* {
    yield r'id';
    yield serializers.serialize(
      object.id,
      specifiedType: const FullType(String),
    );
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
    if (object.confirmedPlantId != null) {
      yield r'confirmedPlantId';
      yield serializers.serialize(
        object.confirmedPlantId,
        specifiedType: const FullType(String),
      );
    }
    if (object.speciesKey != null) {
      yield r'speciesKey';
      yield serializers.serialize(
        object.speciesKey,
        specifiedType: const FullType(String),
      );
    }
    if (object.speciesName != null) {
      yield r'speciesName';
      yield serializers.serialize(
        object.speciesName,
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
    if (object.mediaUrl != null) {
      yield r'mediaUrl';
      yield serializers.serialize(
        object.mediaUrl,
        specifiedType: const FullType(String),
      );
    }
    if (object.location != null) {
      yield r'location';
      yield serializers.serialize(
        object.location,
        specifiedType: const FullType(ObservationLocation),
      );
    }
    if (object.identification != null) {
      yield r'identification';
      yield serializers.serialize(
        object.identification,
        specifiedType: const FullType(IdentificationJob),
      );
    }
    yield r'version';
    yield serializers.serialize(
      object.version,
      specifiedType: const FullType(String),
    );
    yield r'syncStatus';
    yield serializers.serialize(
      object.syncStatus,
      specifiedType: const FullType(ObservationSyncStatusEnum),
    );
  }

  @override
  Object serialize(
    Serializers serializers,
    Observation object, {
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
    required ObservationBuilder result,
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
        case r'confirmedPlantId':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType.nullable(String),
          ) as String?;
          if (valueDes == null) continue;
          result.confirmedPlantId = valueDes;
          break;
        case r'speciesKey':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType.nullable(String),
          ) as String?;
          if (valueDes == null) continue;
          result.speciesKey = valueDes;
          break;
        case r'speciesName':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType.nullable(String),
          ) as String?;
          if (valueDes == null) continue;
          result.speciesName = valueDes;
          break;
        case r'mediaId':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType.nullable(String),
          ) as String?;
          if (valueDes == null) continue;
          result.mediaId = valueDes;
          break;
        case r'mediaUrl':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType.nullable(String),
          ) as String?;
          if (valueDes == null) continue;
          result.mediaUrl = valueDes;
          break;
        case r'location':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType.nullable(ObservationLocation),
          ) as ObservationLocation?;
          if (valueDes == null) continue;
          result.location.replace(valueDes);
          break;
        case r'identification':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType.nullable(IdentificationJob),
          ) as IdentificationJob?;
          if (valueDes == null) continue;
          result.identification.replace(valueDes);
          break;
        case r'version':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType(String),
          ) as String;
          result.version = valueDes;
          break;
        case r'syncStatus':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType(ObservationSyncStatusEnum),
          ) as ObservationSyncStatusEnum;
          result.syncStatus = valueDes;
          break;
        default:
          unhandled.add(key);
          unhandled.add(value);
          break;
      }
    }
  }

  @override
  Observation deserialize(
    Serializers serializers,
    Object serialized, {
    FullType specifiedType = FullType.unspecified,
  }) {
    final result = ObservationBuilder();
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

class ObservationSyncStatusEnum extends EnumClass {
  @BuiltValueEnumConst(wireName: r'synced')
  static const ObservationSyncStatusEnum synced =
      _$observationSyncStatusEnum_synced;
  @BuiltValueEnumConst(wireName: r'pending')
  static const ObservationSyncStatusEnum pending =
      _$observationSyncStatusEnum_pending;
  @BuiltValueEnumConst(wireName: r'conflict')
  static const ObservationSyncStatusEnum conflict =
      _$observationSyncStatusEnum_conflict;
  @BuiltValueEnumConst(wireName: r'deleted')
  static const ObservationSyncStatusEnum deleted =
      _$observationSyncStatusEnum_deleted;

  static Serializer<ObservationSyncStatusEnum> get serializer =>
      _$observationSyncStatusEnumSerializer;

  const ObservationSyncStatusEnum._(String name) : super(name);

  static BuiltSet<ObservationSyncStatusEnum> get values =>
      _$observationSyncStatusEnumValues;
  static ObservationSyncStatusEnum valueOf(String name) =>
      _$observationSyncStatusEnumValueOf(name);
}
