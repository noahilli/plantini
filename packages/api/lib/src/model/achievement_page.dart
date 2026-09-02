//
// AUTO-GENERATED FILE, DO NOT MODIFY!
//

// ignore_for_file: unused_element
import 'package:openapi/src/model/achievement.dart';
import 'package:built_collection/built_collection.dart';
import 'package:built_value/built_value.dart';
import 'package:built_value/serializer.dart';

part 'achievement_page.g.dart';

/// AchievementPage
///
/// Properties:
/// * [items]
@BuiltValue()
abstract class AchievementPage
    implements Built<AchievementPage, AchievementPageBuilder> {
  @BuiltValueField(wireName: r'items')
  BuiltList<Achievement> get items;

  AchievementPage._();

  factory AchievementPage([void updates(AchievementPageBuilder b)]) =
      _$AchievementPage;

  @BuiltValueHook(initializeBuilder: true)
  static void _defaults(AchievementPageBuilder b) => b;

  @BuiltValueSerializer(custom: true)
  static Serializer<AchievementPage> get serializer =>
      _$AchievementPageSerializer();
}

class _$AchievementPageSerializer
    implements PrimitiveSerializer<AchievementPage> {
  @override
  final Iterable<Type> types = const [AchievementPage, _$AchievementPage];

  @override
  final String wireName = r'AchievementPage';

  Iterable<Object?> _serializeProperties(
    Serializers serializers,
    AchievementPage object, {
    FullType specifiedType = FullType.unspecified,
  }) sync* {
    yield r'items';
    yield serializers.serialize(
      object.items,
      specifiedType: const FullType(BuiltList, [FullType(Achievement)]),
    );
  }

  @override
  Object serialize(
    Serializers serializers,
    AchievementPage object, {
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
    required AchievementPageBuilder result,
    required List<Object?> unhandled,
  }) {
    for (var i = 0; i < serializedList.length; i += 2) {
      final key = serializedList[i] as String;
      final value = serializedList[i + 1];
      switch (key) {
        case r'items':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType(BuiltList, [FullType(Achievement)]),
          ) as BuiltList<Achievement>;
          result.items.replace(valueDes);
          break;
        default:
          unhandled.add(key);
          unhandled.add(value);
          break;
      }
    }
  }

  @override
  AchievementPage deserialize(
    Serializers serializers,
    Object serialized, {
    FullType specifiedType = FullType.unspecified,
  }) {
    final result = AchievementPageBuilder();
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
