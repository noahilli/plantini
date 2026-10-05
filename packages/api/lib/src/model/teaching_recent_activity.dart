//
// AUTO-GENERATED FILE, DO NOT MODIFY!
//

// ignore_for_file: unused_element
import 'package:built_value/built_value.dart';
import 'package:built_value/serializer.dart';

part 'teaching_recent_activity.g.dart';

/// TeachingRecentActivity
///
/// Properties:
/// * [studentId]
/// * [displayName]
/// * [className]
/// * [completedAt]
/// * [levelTitle]
@BuiltValue()
abstract class TeachingRecentActivity
    implements Built<TeachingRecentActivity, TeachingRecentActivityBuilder> {
  @BuiltValueField(wireName: r'studentId')
  String get studentId;

  @BuiltValueField(wireName: r'displayName')
  String get displayName;

  @BuiltValueField(wireName: r'className')
  String get className;

  @BuiltValueField(wireName: r'completedAt')
  DateTime get completedAt;

  @BuiltValueField(wireName: r'levelTitle')
  String get levelTitle;

  TeachingRecentActivity._();

  factory TeachingRecentActivity(
          [void updates(TeachingRecentActivityBuilder b)]) =
      _$TeachingRecentActivity;

  @BuiltValueHook(initializeBuilder: true)
  static void _defaults(TeachingRecentActivityBuilder b) => b;

  @BuiltValueSerializer(custom: true)
  static Serializer<TeachingRecentActivity> get serializer =>
      _$TeachingRecentActivitySerializer();
}

class _$TeachingRecentActivitySerializer
    implements PrimitiveSerializer<TeachingRecentActivity> {
  @override
  final Iterable<Type> types = const [
    TeachingRecentActivity,
    _$TeachingRecentActivity
  ];

  @override
  final String wireName = r'TeachingRecentActivity';

  Iterable<Object?> _serializeProperties(
    Serializers serializers,
    TeachingRecentActivity object, {
    FullType specifiedType = FullType.unspecified,
  }) sync* {
    yield r'studentId';
    yield serializers.serialize(
      object.studentId,
      specifiedType: const FullType(String),
    );
    yield r'displayName';
    yield serializers.serialize(
      object.displayName,
      specifiedType: const FullType(String),
    );
    yield r'className';
    yield serializers.serialize(
      object.className,
      specifiedType: const FullType(String),
    );
    yield r'completedAt';
    yield serializers.serialize(
      object.completedAt,
      specifiedType: const FullType(DateTime),
    );
    yield r'levelTitle';
    yield serializers.serialize(
      object.levelTitle,
      specifiedType: const FullType(String),
    );
  }

  @override
  Object serialize(
    Serializers serializers,
    TeachingRecentActivity object, {
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
    required TeachingRecentActivityBuilder result,
    required List<Object?> unhandled,
  }) {
    for (var i = 0; i < serializedList.length; i += 2) {
      final key = serializedList[i] as String;
      final value = serializedList[i + 1];
      switch (key) {
        case r'studentId':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType(String),
          ) as String;
          result.studentId = valueDes;
          break;
        case r'displayName':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType(String),
          ) as String;
          result.displayName = valueDes;
          break;
        case r'className':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType(String),
          ) as String;
          result.className = valueDes;
          break;
        case r'completedAt':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType(DateTime),
          ) as DateTime;
          result.completedAt = valueDes;
          break;
        case r'levelTitle':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType(String),
          ) as String;
          result.levelTitle = valueDes;
          break;
        default:
          unhandled.add(key);
          unhandled.add(value);
          break;
      }
    }
  }

  @override
  TeachingRecentActivity deserialize(
    Serializers serializers,
    Object serialized, {
    FullType specifiedType = FullType.unspecified,
  }) {
    final result = TeachingRecentActivityBuilder();
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
