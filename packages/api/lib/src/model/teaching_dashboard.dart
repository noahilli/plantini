//
// AUTO-GENERATED FILE, DO NOT MODIFY!
//

// ignore_for_file: unused_element
import 'package:openapi/src/model/teaching_ecosystem_progress.dart';
import 'package:built_collection/built_collection.dart';
import 'package:openapi/src/model/teaching_recent_activity.dart';
import 'package:built_value/built_value.dart';
import 'package:built_value/serializer.dart';

part 'teaching_dashboard.g.dart';

/// TeachingDashboard
///
/// Properties:
/// * [classes]
/// * [students]
/// * [activeStudents]
/// * [completedLevels]
/// * [totalLevels]
/// * [averageProgress]
/// * [ecosystems]
/// * [recentActivity]
@BuiltValue()
abstract class TeachingDashboard
    implements Built<TeachingDashboard, TeachingDashboardBuilder> {
  @BuiltValueField(wireName: r'classes')
  int get classes;

  @BuiltValueField(wireName: r'students')
  int get students;

  @BuiltValueField(wireName: r'activeStudents')
  int get activeStudents;

  @BuiltValueField(wireName: r'completedLevels')
  int get completedLevels;

  @BuiltValueField(wireName: r'totalLevels')
  int get totalLevels;

  @BuiltValueField(wireName: r'averageProgress')
  num get averageProgress;

  @BuiltValueField(wireName: r'ecosystems')
  BuiltList<TeachingEcosystemProgress> get ecosystems;

  @BuiltValueField(wireName: r'recentActivity')
  BuiltList<TeachingRecentActivity> get recentActivity;

  TeachingDashboard._();

  factory TeachingDashboard([void updates(TeachingDashboardBuilder b)]) =
      _$TeachingDashboard;

  @BuiltValueHook(initializeBuilder: true)
  static void _defaults(TeachingDashboardBuilder b) => b;

  @BuiltValueSerializer(custom: true)
  static Serializer<TeachingDashboard> get serializer =>
      _$TeachingDashboardSerializer();
}

class _$TeachingDashboardSerializer
    implements PrimitiveSerializer<TeachingDashboard> {
  @override
  final Iterable<Type> types = const [TeachingDashboard, _$TeachingDashboard];

  @override
  final String wireName = r'TeachingDashboard';

  Iterable<Object?> _serializeProperties(
    Serializers serializers,
    TeachingDashboard object, {
    FullType specifiedType = FullType.unspecified,
  }) sync* {
    yield r'classes';
    yield serializers.serialize(
      object.classes,
      specifiedType: const FullType(int),
    );
    yield r'students';
    yield serializers.serialize(
      object.students,
      specifiedType: const FullType(int),
    );
    yield r'activeStudents';
    yield serializers.serialize(
      object.activeStudents,
      specifiedType: const FullType(int),
    );
    yield r'completedLevels';
    yield serializers.serialize(
      object.completedLevels,
      specifiedType: const FullType(int),
    );
    yield r'totalLevels';
    yield serializers.serialize(
      object.totalLevels,
      specifiedType: const FullType(int),
    );
    yield r'averageProgress';
    yield serializers.serialize(
      object.averageProgress,
      specifiedType: const FullType(num),
    );
    yield r'ecosystems';
    yield serializers.serialize(
      object.ecosystems,
      specifiedType:
          const FullType(BuiltList, [FullType(TeachingEcosystemProgress)]),
    );
    yield r'recentActivity';
    yield serializers.serialize(
      object.recentActivity,
      specifiedType:
          const FullType(BuiltList, [FullType(TeachingRecentActivity)]),
    );
  }

  @override
  Object serialize(
    Serializers serializers,
    TeachingDashboard object, {
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
    required TeachingDashboardBuilder result,
    required List<Object?> unhandled,
  }) {
    for (var i = 0; i < serializedList.length; i += 2) {
      final key = serializedList[i] as String;
      final value = serializedList[i + 1];
      switch (key) {
        case r'classes':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType(int),
          ) as int;
          result.classes = valueDes;
          break;
        case r'students':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType(int),
          ) as int;
          result.students = valueDes;
          break;
        case r'activeStudents':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType(int),
          ) as int;
          result.activeStudents = valueDes;
          break;
        case r'completedLevels':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType(int),
          ) as int;
          result.completedLevels = valueDes;
          break;
        case r'totalLevels':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType(int),
          ) as int;
          result.totalLevels = valueDes;
          break;
        case r'averageProgress':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType(num),
          ) as num;
          result.averageProgress = valueDes;
          break;
        case r'ecosystems':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType(
                BuiltList, [FullType(TeachingEcosystemProgress)]),
          ) as BuiltList<TeachingEcosystemProgress>;
          result.ecosystems.replace(valueDes);
          break;
        case r'recentActivity':
          final valueDes = serializers.deserialize(
            value,
            specifiedType:
                const FullType(BuiltList, [FullType(TeachingRecentActivity)]),
          ) as BuiltList<TeachingRecentActivity>;
          result.recentActivity.replace(valueDes);
          break;
        default:
          unhandled.add(key);
          unhandled.add(value);
          break;
      }
    }
  }

  @override
  TeachingDashboard deserialize(
    Serializers serializers,
    Object serialized, {
    FullType specifiedType = FullType.unspecified,
  }) {
    final result = TeachingDashboardBuilder();
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
