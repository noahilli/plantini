//
// AUTO-GENERATED FILE, DO NOT MODIFY!
//

// ignore_for_file: unused_element
import 'package:built_value/built_value.dart';
import 'package:built_value/serializer.dart';

part 'teaching_ecosystem_progress.g.dart';

/// TeachingEcosystemProgress
///
/// Properties:
/// * [id]
/// * [name]
/// * [completedLevels]
/// * [totalLevels]
/// * [progress]
@BuiltValue()
abstract class TeachingEcosystemProgress
    implements
        Built<TeachingEcosystemProgress, TeachingEcosystemProgressBuilder> {
  @BuiltValueField(wireName: r'id')
  String get id;

  @BuiltValueField(wireName: r'name')
  String get name;

  @BuiltValueField(wireName: r'completedLevels')
  int get completedLevels;

  @BuiltValueField(wireName: r'totalLevels')
  int get totalLevels;

  @BuiltValueField(wireName: r'progress')
  num get progress;

  TeachingEcosystemProgress._();

  factory TeachingEcosystemProgress(
          [void updates(TeachingEcosystemProgressBuilder b)]) =
      _$TeachingEcosystemProgress;

  @BuiltValueHook(initializeBuilder: true)
  static void _defaults(TeachingEcosystemProgressBuilder b) => b;

  @BuiltValueSerializer(custom: true)
  static Serializer<TeachingEcosystemProgress> get serializer =>
      _$TeachingEcosystemProgressSerializer();
}

class _$TeachingEcosystemProgressSerializer
    implements PrimitiveSerializer<TeachingEcosystemProgress> {
  @override
  final Iterable<Type> types = const [
    TeachingEcosystemProgress,
    _$TeachingEcosystemProgress
  ];

  @override
  final String wireName = r'TeachingEcosystemProgress';

  Iterable<Object?> _serializeProperties(
    Serializers serializers,
    TeachingEcosystemProgress object, {
    FullType specifiedType = FullType.unspecified,
  }) sync* {
    yield r'id';
    yield serializers.serialize(
      object.id,
      specifiedType: const FullType(String),
    );
    yield r'name';
    yield serializers.serialize(
      object.name,
      specifiedType: const FullType(String),
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
  }

  @override
  Object serialize(
    Serializers serializers,
    TeachingEcosystemProgress object, {
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
    required TeachingEcosystemProgressBuilder result,
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
        case r'name':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType(String),
          ) as String;
          result.name = valueDes;
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
        default:
          unhandled.add(key);
          unhandled.add(value);
          break;
      }
    }
  }

  @override
  TeachingEcosystemProgress deserialize(
    Serializers serializers,
    Object serialized, {
    FullType specifiedType = FullType.unspecified,
  }) {
    final result = TeachingEcosystemProgressBuilder();
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
