//
// AUTO-GENERATED FILE, DO NOT MODIFY!
//

// ignore_for_file: unused_element
import 'package:openapi/src/model/teaching_ecosystem_progress.dart';
import 'package:built_collection/built_collection.dart';
import 'package:built_value/built_value.dart';
import 'package:built_value/serializer.dart';

part 'teaching_student_progress.g.dart';

/// TeachingStudentProgress
///
/// Properties:
/// * [id]
/// * [username]
/// * [displayName]
/// * [email]
/// * [enabled]
/// * [completedLevels]
/// * [totalLevels]
/// * [progress]
/// * [lastActivityAt]
/// * [ecosystems]
@BuiltValue()
abstract class TeachingStudentProgress
    implements Built<TeachingStudentProgress, TeachingStudentProgressBuilder> {
  @BuiltValueField(wireName: r'id')
  String get id;

  @BuiltValueField(wireName: r'username')
  String get username;

  @BuiltValueField(wireName: r'displayName')
  String get displayName;

  @BuiltValueField(wireName: r'email')
  String? get email;

  @BuiltValueField(wireName: r'enabled')
  bool get enabled;

  @BuiltValueField(wireName: r'completedLevels')
  int get completedLevels;

  @BuiltValueField(wireName: r'totalLevels')
  int get totalLevels;

  @BuiltValueField(wireName: r'progress')
  num get progress;

  @BuiltValueField(wireName: r'lastActivityAt')
  DateTime? get lastActivityAt;

  @BuiltValueField(wireName: r'ecosystems')
  BuiltList<TeachingEcosystemProgress> get ecosystems;

  TeachingStudentProgress._();

  factory TeachingStudentProgress(
          [void updates(TeachingStudentProgressBuilder b)]) =
      _$TeachingStudentProgress;

  @BuiltValueHook(initializeBuilder: true)
  static void _defaults(TeachingStudentProgressBuilder b) => b;

  @BuiltValueSerializer(custom: true)
  static Serializer<TeachingStudentProgress> get serializer =>
      _$TeachingStudentProgressSerializer();
}

class _$TeachingStudentProgressSerializer
    implements PrimitiveSerializer<TeachingStudentProgress> {
  @override
  final Iterable<Type> types = const [
    TeachingStudentProgress,
    _$TeachingStudentProgress
  ];

  @override
  final String wireName = r'TeachingStudentProgress';

  Iterable<Object?> _serializeProperties(
    Serializers serializers,
    TeachingStudentProgress object, {
    FullType specifiedType = FullType.unspecified,
  }) sync* {
    yield r'id';
    yield serializers.serialize(
      object.id,
      specifiedType: const FullType(String),
    );
    yield r'username';
    yield serializers.serialize(
      object.username,
      specifiedType: const FullType(String),
    );
    yield r'displayName';
    yield serializers.serialize(
      object.displayName,
      specifiedType: const FullType(String),
    );
    if (object.email != null) {
      yield r'email';
      yield serializers.serialize(
        object.email,
        specifiedType: const FullType(String),
      );
    }
    yield r'enabled';
    yield serializers.serialize(
      object.enabled,
      specifiedType: const FullType(bool),
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
    yield r'progress';
    yield serializers.serialize(
      object.progress,
      specifiedType: const FullType(num),
    );
    yield r'lastActivityAt';
    yield object.lastActivityAt == null
        ? null
        : serializers.serialize(
            object.lastActivityAt,
            specifiedType: const FullType.nullable(DateTime),
          );
    yield r'ecosystems';
    yield serializers.serialize(
      object.ecosystems,
      specifiedType:
          const FullType(BuiltList, [FullType(TeachingEcosystemProgress)]),
    );
  }

  @override
  Object serialize(
    Serializers serializers,
    TeachingStudentProgress object, {
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
    required TeachingStudentProgressBuilder result,
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
        case r'username':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType(String),
          ) as String;
          result.username = valueDes;
          break;
        case r'displayName':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType(String),
          ) as String;
          result.displayName = valueDes;
          break;
        case r'email':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType.nullable(String),
          ) as String?;
          if (valueDes == null) continue;
          result.email = valueDes;
          break;
        case r'enabled':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType(bool),
          ) as bool;
          result.enabled = valueDes;
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
        case r'progress':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType(num),
          ) as num;
          result.progress = valueDes;
          break;
        case r'lastActivityAt':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType.nullable(DateTime),
          ) as DateTime?;
          if (valueDes == null) continue;
          result.lastActivityAt = valueDes;
          break;
        case r'ecosystems':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType(
                BuiltList, [FullType(TeachingEcosystemProgress)]),
          ) as BuiltList<TeachingEcosystemProgress>;
          result.ecosystems.replace(valueDes);
          break;
        default:
          unhandled.add(key);
          unhandled.add(value);
          break;
      }
    }
  }

  @override
  TeachingStudentProgress deserialize(
    Serializers serializers,
    Object serialized, {
    FullType specifiedType = FullType.unspecified,
  }) {
    final result = TeachingStudentProgressBuilder();
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
