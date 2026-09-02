//
// AUTO-GENERATED FILE, DO NOT MODIFY!
//

// ignore_for_file: unused_element
import 'package:built_collection/built_collection.dart';
import 'package:openapi/src/model/level_progress.dart';
import 'package:built_value/built_value.dart';
import 'package:built_value/serializer.dart';

part 'progress_snapshot.g.dart';

/// ProgressSnapshot
///
/// Properties:
/// * [updatedAt]
/// * [levels]
@BuiltValue()
abstract class ProgressSnapshot
    implements Built<ProgressSnapshot, ProgressSnapshotBuilder> {
  @BuiltValueField(wireName: r'updatedAt')
  DateTime get updatedAt;

  @BuiltValueField(wireName: r'levels')
  BuiltList<LevelProgress> get levels;

  ProgressSnapshot._();

  factory ProgressSnapshot([void updates(ProgressSnapshotBuilder b)]) =
      _$ProgressSnapshot;

  @BuiltValueHook(initializeBuilder: true)
  static void _defaults(ProgressSnapshotBuilder b) => b;

  @BuiltValueSerializer(custom: true)
  static Serializer<ProgressSnapshot> get serializer =>
      _$ProgressSnapshotSerializer();
}

class _$ProgressSnapshotSerializer
    implements PrimitiveSerializer<ProgressSnapshot> {
  @override
  final Iterable<Type> types = const [ProgressSnapshot, _$ProgressSnapshot];

  @override
  final String wireName = r'ProgressSnapshot';

  Iterable<Object?> _serializeProperties(
    Serializers serializers,
    ProgressSnapshot object, {
    FullType specifiedType = FullType.unspecified,
  }) sync* {
    yield r'updatedAt';
    yield serializers.serialize(
      object.updatedAt,
      specifiedType: const FullType(DateTime),
    );
    yield r'levels';
    yield serializers.serialize(
      object.levels,
      specifiedType: const FullType(BuiltList, [FullType(LevelProgress)]),
    );
  }

  @override
  Object serialize(
    Serializers serializers,
    ProgressSnapshot object, {
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
    required ProgressSnapshotBuilder result,
    required List<Object?> unhandled,
  }) {
    for (var i = 0; i < serializedList.length; i += 2) {
      final key = serializedList[i] as String;
      final value = serializedList[i + 1];
      switch (key) {
        case r'updatedAt':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType(DateTime),
          ) as DateTime;
          result.updatedAt = valueDes;
          break;
        case r'levels':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType(BuiltList, [FullType(LevelProgress)]),
          ) as BuiltList<LevelProgress>;
          result.levels.replace(valueDes);
          break;
        default:
          unhandled.add(key);
          unhandled.add(value);
          break;
      }
    }
  }

  @override
  ProgressSnapshot deserialize(
    Serializers serializers,
    Object serialized, {
    FullType specifiedType = FullType.unspecified,
  }) {
    final result = ProgressSnapshotBuilder();
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
