//
// AUTO-GENERATED FILE, DO NOT MODIFY!
//

// ignore_for_file: unused_element
import 'package:built_collection/built_collection.dart';
import 'package:openapi/src/model/completion_rule.dart';
import 'package:built_value/built_value.dart';
import 'package:built_value/serializer.dart';

part 'level.g.dart';

/// Level
///
/// Properties:
/// * [id]
/// * [ecosystemId]
/// * [title]
/// * [sequence]
/// * [learningGoal]
/// * [plantIds]
/// * [completionRule]
/// * [status]
/// * [progress]
@BuiltValue()
abstract class Level implements Built<Level, LevelBuilder> {
  @BuiltValueField(wireName: r'id')
  String get id;

  @BuiltValueField(wireName: r'ecosystemId')
  String get ecosystemId;

  @BuiltValueField(wireName: r'title')
  String get title;

  @BuiltValueField(wireName: r'sequence')
  int get sequence;

  @BuiltValueField(wireName: r'learningGoal')
  String? get learningGoal;

  @BuiltValueField(wireName: r'plantIds')
  BuiltList<String>? get plantIds;

  @BuiltValueField(wireName: r'completionRule')
  CompletionRule get completionRule;

  @BuiltValueField(wireName: r'status')
  LevelStatusEnum get status;
  // enum statusEnum {  locked,  available,  in_progress,  completed,  };

  @BuiltValueField(wireName: r'progress')
  num? get progress;

  Level._();

  factory Level([void updates(LevelBuilder b)]) = _$Level;

  @BuiltValueHook(initializeBuilder: true)
  static void _defaults(LevelBuilder b) => b;

  @BuiltValueSerializer(custom: true)
  static Serializer<Level> get serializer => _$LevelSerializer();
}

class _$LevelSerializer implements PrimitiveSerializer<Level> {
  @override
  final Iterable<Type> types = const [Level, _$Level];

  @override
  final String wireName = r'Level';

  Iterable<Object?> _serializeProperties(
    Serializers serializers,
    Level object, {
    FullType specifiedType = FullType.unspecified,
  }) sync* {
    yield r'id';
    yield serializers.serialize(
      object.id,
      specifiedType: const FullType(String),
    );
    yield r'ecosystemId';
    yield serializers.serialize(
      object.ecosystemId,
      specifiedType: const FullType(String),
    );
    yield r'title';
    yield serializers.serialize(
      object.title,
      specifiedType: const FullType(String),
    );
    yield r'sequence';
    yield serializers.serialize(
      object.sequence,
      specifiedType: const FullType(int),
    );
    if (object.learningGoal != null) {
      yield r'learningGoal';
      yield serializers.serialize(
        object.learningGoal,
        specifiedType: const FullType(String),
      );
    }
    if (object.plantIds != null) {
      yield r'plantIds';
      yield serializers.serialize(
        object.plantIds,
        specifiedType: const FullType(BuiltList, [FullType(String)]),
      );
    }
    yield r'completionRule';
    yield serializers.serialize(
      object.completionRule,
      specifiedType: const FullType(CompletionRule),
    );
    yield r'status';
    yield serializers.serialize(
      object.status,
      specifiedType: const FullType(LevelStatusEnum),
    );
    if (object.progress != null) {
      yield r'progress';
      yield serializers.serialize(
        object.progress,
        specifiedType: const FullType(num),
      );
    }
  }

  @override
  Object serialize(
    Serializers serializers,
    Level object, {
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
    required LevelBuilder result,
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
        case r'ecosystemId':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType(String),
          ) as String;
          result.ecosystemId = valueDes;
          break;
        case r'title':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType(String),
          ) as String;
          result.title = valueDes;
          break;
        case r'sequence':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType(int),
          ) as int;
          result.sequence = valueDes;
          break;
        case r'learningGoal':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType.nullable(String),
          ) as String?;
          if (valueDes == null) continue;
          result.learningGoal = valueDes;
          break;
        case r'plantIds':
          final valueDes = serializers.deserialize(
            value,
            specifiedType:
                const FullType.nullable(BuiltList, [FullType(String)]),
          ) as BuiltList<String>?;
          if (valueDes == null) continue;
          result.plantIds.replace(valueDes);
          break;
        case r'completionRule':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType(CompletionRule),
          ) as CompletionRule;
          result.completionRule.replace(valueDes);
          break;
        case r'status':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType(LevelStatusEnum),
          ) as LevelStatusEnum;
          result.status = valueDes;
          break;
        case r'progress':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType.nullable(num),
          ) as num?;
          if (valueDes == null) continue;
          result.progress = valueDes;
          break;
        default:
          unhandled.add(key);
          unhandled.add(value);
          break;
      }
    }
  }

  @override
  Level deserialize(
    Serializers serializers,
    Object serialized, {
    FullType specifiedType = FullType.unspecified,
  }) {
    final result = LevelBuilder();
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

class LevelStatusEnum extends EnumClass {
  @BuiltValueEnumConst(wireName: r'locked')
  static const LevelStatusEnum locked = _$levelStatusEnum_locked;
  @BuiltValueEnumConst(wireName: r'available')
  static const LevelStatusEnum available = _$levelStatusEnum_available;
  @BuiltValueEnumConst(wireName: r'in_progress')
  static const LevelStatusEnum inProgress = _$levelStatusEnum_inProgress;
  @BuiltValueEnumConst(wireName: r'completed')
  static const LevelStatusEnum completed = _$levelStatusEnum_completed;

  static Serializer<LevelStatusEnum> get serializer =>
      _$levelStatusEnumSerializer;

  const LevelStatusEnum._(String name) : super(name);

  static BuiltSet<LevelStatusEnum> get values => _$levelStatusEnumValues;
  static LevelStatusEnum valueOf(String name) => _$levelStatusEnumValueOf(name);
}
