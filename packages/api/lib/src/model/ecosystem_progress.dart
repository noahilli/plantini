//
// AUTO-GENERATED FILE, DO NOT MODIFY!
//

// ignore_for_file: unused_element
import 'package:built_collection/built_collection.dart';
import 'package:built_value/built_value.dart';
import 'package:built_value/serializer.dart';

part 'ecosystem_progress.g.dart';

/// EcosystemProgress
///
/// Properties:
/// * [ecosystemId]
/// * [status]
/// * [completed] - True only when every published level has a server-passed attempt and every target species is collected.
/// * [totalLevels]
/// * [completedLevelCount]
/// * [completedLevelIds] - Passed level IDs in sequence order.
/// * [requiredPlantIds]
/// * [collectedPlantIds] - Distinct collected required species only.
/// * [missingPlantIds]
@BuiltValue()
abstract class EcosystemProgress
    implements Built<EcosystemProgress, EcosystemProgressBuilder> {
  @BuiltValueField(wireName: r'ecosystemId')
  String get ecosystemId;

  @BuiltValueField(wireName: r'status')
  EcosystemProgressStatusEnum get status;
  // enum statusEnum {  in_progress,  collection_pending,  completed,  };

  /// True only when every published level has a server-passed attempt and every target species is collected.
  @BuiltValueField(wireName: r'completed')
  bool get completed;

  @BuiltValueField(wireName: r'totalLevels')
  int get totalLevels;

  @BuiltValueField(wireName: r'completedLevelCount')
  int get completedLevelCount;

  /// Passed level IDs in sequence order.
  @BuiltValueField(wireName: r'completedLevelIds')
  BuiltSet<String> get completedLevelIds;

  @BuiltValueField(wireName: r'requiredPlantIds')
  BuiltSet<String> get requiredPlantIds;

  /// Distinct collected required species only.
  @BuiltValueField(wireName: r'collectedPlantIds')
  BuiltSet<String> get collectedPlantIds;

  @BuiltValueField(wireName: r'missingPlantIds')
  BuiltSet<String> get missingPlantIds;

  EcosystemProgress._();

  factory EcosystemProgress([void updates(EcosystemProgressBuilder b)]) =
      _$EcosystemProgress;

  @BuiltValueHook(initializeBuilder: true)
  static void _defaults(EcosystemProgressBuilder b) => b;

  @BuiltValueSerializer(custom: true)
  static Serializer<EcosystemProgress> get serializer =>
      _$EcosystemProgressSerializer();
}

class _$EcosystemProgressSerializer
    implements PrimitiveSerializer<EcosystemProgress> {
  @override
  final Iterable<Type> types = const [EcosystemProgress, _$EcosystemProgress];

  @override
  final String wireName = r'EcosystemProgress';

  Iterable<Object?> _serializeProperties(
    Serializers serializers,
    EcosystemProgress object, {
    FullType specifiedType = FullType.unspecified,
  }) sync* {
    yield r'ecosystemId';
    yield serializers.serialize(
      object.ecosystemId,
      specifiedType: const FullType(String),
    );
    yield r'status';
    yield serializers.serialize(
      object.status,
      specifiedType: const FullType(EcosystemProgressStatusEnum),
    );
    yield r'completed';
    yield serializers.serialize(
      object.completed,
      specifiedType: const FullType(bool),
    );
    yield r'totalLevels';
    yield serializers.serialize(
      object.totalLevels,
      specifiedType: const FullType(int),
    );
    yield r'completedLevelCount';
    yield serializers.serialize(
      object.completedLevelCount,
      specifiedType: const FullType(int),
    );
    yield r'completedLevelIds';
    yield serializers.serialize(
      object.completedLevelIds,
      specifiedType: const FullType(BuiltSet, [FullType(String)]),
    );
    yield r'requiredPlantIds';
    yield serializers.serialize(
      object.requiredPlantIds,
      specifiedType: const FullType(BuiltSet, [FullType(String)]),
    );
    yield r'collectedPlantIds';
    yield serializers.serialize(
      object.collectedPlantIds,
      specifiedType: const FullType(BuiltSet, [FullType(String)]),
    );
    yield r'missingPlantIds';
    yield serializers.serialize(
      object.missingPlantIds,
      specifiedType: const FullType(BuiltSet, [FullType(String)]),
    );
  }

  @override
  Object serialize(
    Serializers serializers,
    EcosystemProgress object, {
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
    required EcosystemProgressBuilder result,
    required List<Object?> unhandled,
  }) {
    for (var i = 0; i < serializedList.length; i += 2) {
      final key = serializedList[i] as String;
      final value = serializedList[i + 1];
      switch (key) {
        case r'ecosystemId':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType(String),
          ) as String;
          result.ecosystemId = valueDes;
          break;
        case r'status':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType(EcosystemProgressStatusEnum),
          ) as EcosystemProgressStatusEnum;
          result.status = valueDes;
          break;
        case r'completed':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType(bool),
          ) as bool;
          result.completed = valueDes;
          break;
        case r'totalLevels':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType(int),
          ) as int;
          result.totalLevels = valueDes;
          break;
        case r'completedLevelCount':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType(int),
          ) as int;
          result.completedLevelCount = valueDes;
          break;
        case r'completedLevelIds':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType(BuiltSet, [FullType(String)]),
          ) as BuiltSet<String>;
          result.completedLevelIds.replace(valueDes);
          break;
        case r'requiredPlantIds':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType(BuiltSet, [FullType(String)]),
          ) as BuiltSet<String>;
          result.requiredPlantIds.replace(valueDes);
          break;
        case r'collectedPlantIds':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType(BuiltSet, [FullType(String)]),
          ) as BuiltSet<String>;
          result.collectedPlantIds.replace(valueDes);
          break;
        case r'missingPlantIds':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType(BuiltSet, [FullType(String)]),
          ) as BuiltSet<String>;
          result.missingPlantIds.replace(valueDes);
          break;
        default:
          unhandled.add(key);
          unhandled.add(value);
          break;
      }
    }
  }

  @override
  EcosystemProgress deserialize(
    Serializers serializers,
    Object serialized, {
    FullType specifiedType = FullType.unspecified,
  }) {
    final result = EcosystemProgressBuilder();
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

class EcosystemProgressStatusEnum extends EnumClass {
  @BuiltValueEnumConst(wireName: r'in_progress')
  static const EcosystemProgressStatusEnum inProgress =
      _$ecosystemProgressStatusEnum_inProgress;
  @BuiltValueEnumConst(wireName: r'collection_pending')
  static const EcosystemProgressStatusEnum collectionPending =
      _$ecosystemProgressStatusEnum_collectionPending;
  @BuiltValueEnumConst(wireName: r'completed')
  static const EcosystemProgressStatusEnum completed =
      _$ecosystemProgressStatusEnum_completed;

  static Serializer<EcosystemProgressStatusEnum> get serializer =>
      _$ecosystemProgressStatusEnumSerializer;

  const EcosystemProgressStatusEnum._(String name) : super(name);

  static BuiltSet<EcosystemProgressStatusEnum> get values =>
      _$ecosystemProgressStatusEnumValues;
  static EcosystemProgressStatusEnum valueOf(String name) =>
      _$ecosystemProgressStatusEnumValueOf(name);
}
