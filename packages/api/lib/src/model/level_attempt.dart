//
// AUTO-GENERATED FILE, DO NOT MODIFY!
//

// ignore_for_file: unused_element
import 'package:built_collection/built_collection.dart';
import 'package:built_value/built_value.dart';
import 'package:built_value/serializer.dart';

part 'level_attempt.g.dart';

/// LevelAttempt
///
/// Properties:
/// * [id]
/// * [levelId]
/// * [status]
/// * [contentVersion]
/// * [startedAt]
@BuiltValue()
abstract class LevelAttempt
    implements Built<LevelAttempt, LevelAttemptBuilder> {
  @BuiltValueField(wireName: r'id')
  String get id;

  @BuiltValueField(wireName: r'levelId')
  String get levelId;

  @BuiltValueField(wireName: r'status')
  LevelAttemptStatusEnum get status;
  // enum statusEnum {  active,  completed,  expired,  };

  @BuiltValueField(wireName: r'contentVersion')
  String get contentVersion;

  @BuiltValueField(wireName: r'startedAt')
  DateTime? get startedAt;

  LevelAttempt._();

  factory LevelAttempt([void updates(LevelAttemptBuilder b)]) = _$LevelAttempt;

  @BuiltValueHook(initializeBuilder: true)
  static void _defaults(LevelAttemptBuilder b) => b;

  @BuiltValueSerializer(custom: true)
  static Serializer<LevelAttempt> get serializer => _$LevelAttemptSerializer();
}

class _$LevelAttemptSerializer implements PrimitiveSerializer<LevelAttempt> {
  @override
  final Iterable<Type> types = const [LevelAttempt, _$LevelAttempt];

  @override
  final String wireName = r'LevelAttempt';

  Iterable<Object?> _serializeProperties(
    Serializers serializers,
    LevelAttempt object, {
    FullType specifiedType = FullType.unspecified,
  }) sync* {
    yield r'id';
    yield serializers.serialize(
      object.id,
      specifiedType: const FullType(String),
    );
    yield r'levelId';
    yield serializers.serialize(
      object.levelId,
      specifiedType: const FullType(String),
    );
    yield r'status';
    yield serializers.serialize(
      object.status,
      specifiedType: const FullType(LevelAttemptStatusEnum),
    );
    yield r'contentVersion';
    yield serializers.serialize(
      object.contentVersion,
      specifiedType: const FullType(String),
    );
    if (object.startedAt != null) {
      yield r'startedAt';
      yield serializers.serialize(
        object.startedAt,
        specifiedType: const FullType(DateTime),
      );
    }
  }

  @override
  Object serialize(
    Serializers serializers,
    LevelAttempt object, {
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
    required LevelAttemptBuilder result,
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
            specifiedType: const FullType(LevelAttemptStatusEnum),
          ) as LevelAttemptStatusEnum;
          result.status = valueDes;
          break;
        case r'contentVersion':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType(String),
          ) as String;
          result.contentVersion = valueDes;
          break;
        case r'startedAt':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType.nullable(DateTime),
          ) as DateTime?;
          if (valueDes == null) continue;
          result.startedAt = valueDes;
          break;
        default:
          unhandled.add(key);
          unhandled.add(value);
          break;
      }
    }
  }

  @override
  LevelAttempt deserialize(
    Serializers serializers,
    Object serialized, {
    FullType specifiedType = FullType.unspecified,
  }) {
    final result = LevelAttemptBuilder();
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

class LevelAttemptStatusEnum extends EnumClass {
  @BuiltValueEnumConst(wireName: r'active')
  static const LevelAttemptStatusEnum active = _$levelAttemptStatusEnum_active;
  @BuiltValueEnumConst(wireName: r'completed')
  static const LevelAttemptStatusEnum completed =
      _$levelAttemptStatusEnum_completed;
  @BuiltValueEnumConst(wireName: r'expired')
  static const LevelAttemptStatusEnum expired =
      _$levelAttemptStatusEnum_expired;

  static Serializer<LevelAttemptStatusEnum> get serializer =>
      _$levelAttemptStatusEnumSerializer;

  const LevelAttemptStatusEnum._(String name) : super(name);

  static BuiltSet<LevelAttemptStatusEnum> get values =>
      _$levelAttemptStatusEnumValues;
  static LevelAttemptStatusEnum valueOf(String name) =>
      _$levelAttemptStatusEnumValueOf(name);
}
