//
// AUTO-GENERATED FILE, DO NOT MODIFY!
//

// ignore_for_file: unused_element
import 'package:built_collection/built_collection.dart';
import 'package:built_value/built_value.dart';
import 'package:built_value/serializer.dart';

part 'achievement.g.dart';

/// Achievement
///
/// Properties:
/// * [id]
/// * [status]
/// * [title]
/// * [description]
/// * [earnedAt]
@BuiltValue()
abstract class Achievement implements Built<Achievement, AchievementBuilder> {
  @BuiltValueField(wireName: r'id')
  String get id;

  @BuiltValueField(wireName: r'status')
  AchievementStatusEnum get status;
  // enum statusEnum {  earned,  next,  locked,  };

  @BuiltValueField(wireName: r'title')
  String get title;

  @BuiltValueField(wireName: r'description')
  String? get description;

  @BuiltValueField(wireName: r'earnedAt')
  DateTime? get earnedAt;

  Achievement._();

  factory Achievement([void updates(AchievementBuilder b)]) = _$Achievement;

  @BuiltValueHook(initializeBuilder: true)
  static void _defaults(AchievementBuilder b) => b;

  @BuiltValueSerializer(custom: true)
  static Serializer<Achievement> get serializer => _$AchievementSerializer();
}

class _$AchievementSerializer implements PrimitiveSerializer<Achievement> {
  @override
  final Iterable<Type> types = const [Achievement, _$Achievement];

  @override
  final String wireName = r'Achievement';

  Iterable<Object?> _serializeProperties(
    Serializers serializers,
    Achievement object, {
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
      specifiedType: const FullType(AchievementStatusEnum),
    );
    yield r'title';
    yield serializers.serialize(
      object.title,
      specifiedType: const FullType(String),
    );
    if (object.description != null) {
      yield r'description';
      yield serializers.serialize(
        object.description,
        specifiedType: const FullType(String),
      );
    }
    if (object.earnedAt != null) {
      yield r'earnedAt';
      yield serializers.serialize(
        object.earnedAt,
        specifiedType: const FullType(DateTime),
      );
    }
  }

  @override
  Object serialize(
    Serializers serializers,
    Achievement object, {
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
    required AchievementBuilder result,
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
            specifiedType: const FullType(AchievementStatusEnum),
          ) as AchievementStatusEnum;
          result.status = valueDes;
          break;
        case r'title':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType(String),
          ) as String;
          result.title = valueDes;
          break;
        case r'description':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType.nullable(String),
          ) as String?;
          if (valueDes == null) continue;
          result.description = valueDes;
          break;
        case r'earnedAt':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType.nullable(DateTime),
          ) as DateTime?;
          if (valueDes == null) continue;
          result.earnedAt = valueDes;
          break;
        default:
          unhandled.add(key);
          unhandled.add(value);
          break;
      }
    }
  }

  @override
  Achievement deserialize(
    Serializers serializers,
    Object serialized, {
    FullType specifiedType = FullType.unspecified,
  }) {
    final result = AchievementBuilder();
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

class AchievementStatusEnum extends EnumClass {
  @BuiltValueEnumConst(wireName: r'earned')
  static const AchievementStatusEnum earned = _$achievementStatusEnum_earned;
  @BuiltValueEnumConst(wireName: r'next')
  static const AchievementStatusEnum next = _$achievementStatusEnum_next;
  @BuiltValueEnumConst(wireName: r'locked')
  static const AchievementStatusEnum locked = _$achievementStatusEnum_locked;

  static Serializer<AchievementStatusEnum> get serializer =>
      _$achievementStatusEnumSerializer;

  const AchievementStatusEnum._(String name) : super(name);

  static BuiltSet<AchievementStatusEnum> get values =>
      _$achievementStatusEnumValues;
  static AchievementStatusEnum valueOf(String name) =>
      _$achievementStatusEnumValueOf(name);
}
