//
// AUTO-GENERATED FILE, DO NOT MODIFY!
//

// ignore_for_file: unused_element
import 'package:built_collection/built_collection.dart';
import 'package:built_value/built_value.dart';
import 'package:built_value/serializer.dart';

part 'level_progress.g.dart';

/// LevelProgress
///
/// Properties:
/// * [levelId]
/// * [status]
/// * [percentage]
/// * [completedAt]
@BuiltValue()
abstract class LevelProgress
    implements Built<LevelProgress, LevelProgressBuilder> {
  @BuiltValueField(wireName: r'levelId')
  String get levelId;

  @BuiltValueField(wireName: r'status')
  LevelProgressStatusEnum get status;
  // enum statusEnum {  locked,  available,  in_progress,  completed,  };

  @BuiltValueField(wireName: r'percentage')
  num get percentage;

  @BuiltValueField(wireName: r'completedAt')
  DateTime? get completedAt;

  LevelProgress._();

  factory LevelProgress([void updates(LevelProgressBuilder b)]) =
      _$LevelProgress;

  @BuiltValueHook(initializeBuilder: true)
  static void _defaults(LevelProgressBuilder b) => b;

  @BuiltValueSerializer(custom: true)
  static Serializer<LevelProgress> get serializer =>
      _$LevelProgressSerializer();
}

class _$LevelProgressSerializer implements PrimitiveSerializer<LevelProgress> {
  @override
  final Iterable<Type> types = const [LevelProgress, _$LevelProgress];

  @override
  final String wireName = r'LevelProgress';

  Iterable<Object?> _serializeProperties(
    Serializers serializers,
    LevelProgress object, {
    FullType specifiedType = FullType.unspecified,
  }) sync* {
    yield r'levelId';
    yield serializers.serialize(
      object.levelId,
      specifiedType: const FullType(String),
    );
    yield r'status';
    yield serializers.serialize(
      object.status,
      specifiedType: const FullType(LevelProgressStatusEnum),
    );
    yield r'percentage';
    yield serializers.serialize(
      object.percentage,
      specifiedType: const FullType(num),
    );
    if (object.completedAt != null) {
      yield r'completedAt';
      yield serializers.serialize(
        object.completedAt,
        specifiedType: const FullType(DateTime),
      );
    }
  }

  @override
  Object serialize(
    Serializers serializers,
    LevelProgress object, {
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
    required LevelProgressBuilder result,
    required List<Object?> unhandled,
  }) {
    for (var i = 0; i < serializedList.length; i += 2) {
      final key = serializedList[i] as String;
      final value = serializedList[i + 1];
      switch (key) {
        case r'levelId':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType(String),
          ) as String;
          result.levelId = valueDes;
          break;
        case r'status':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType(LevelProgressStatusEnum),
          ) as LevelProgressStatusEnum;
          result.status = valueDes;
          break;
        case r'percentage':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType(num),
          ) as num;
          result.percentage = valueDes;
          break;
        case r'completedAt':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType.nullable(DateTime),
          ) as DateTime?;
          if (valueDes == null) continue;
          result.completedAt = valueDes;
          break;
        default:
          unhandled.add(key);
          unhandled.add(value);
          break;
      }
    }
  }

  @override
  LevelProgress deserialize(
    Serializers serializers,
    Object serialized, {
    FullType specifiedType = FullType.unspecified,
  }) {
    final result = LevelProgressBuilder();
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

class LevelProgressStatusEnum extends EnumClass {
  @BuiltValueEnumConst(wireName: r'locked')
  static const LevelProgressStatusEnum locked =
      _$levelProgressStatusEnum_locked;
  @BuiltValueEnumConst(wireName: r'available')
  static const LevelProgressStatusEnum available =
      _$levelProgressStatusEnum_available;
  @BuiltValueEnumConst(wireName: r'in_progress')
  static const LevelProgressStatusEnum inProgress =
      _$levelProgressStatusEnum_inProgress;
  @BuiltValueEnumConst(wireName: r'completed')
  static const LevelProgressStatusEnum completed =
      _$levelProgressStatusEnum_completed;

  static Serializer<LevelProgressStatusEnum> get serializer =>
      _$levelProgressStatusEnumSerializer;

  const LevelProgressStatusEnum._(String name) : super(name);

  static BuiltSet<LevelProgressStatusEnum> get values =>
      _$levelProgressStatusEnumValues;
  static LevelProgressStatusEnum valueOf(String name) =>
      _$levelProgressStatusEnumValueOf(name);
}
