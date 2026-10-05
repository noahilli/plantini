//
// AUTO-GENERATED FILE, DO NOT MODIFY!
//

// ignore_for_file: unused_element
import 'package:openapi/src/model/teaching_student_progress.dart';
import 'package:built_collection/built_collection.dart';
import 'package:openapi/src/model/teaching_class.dart';
import 'package:built_value/built_value.dart';
import 'package:built_value/serializer.dart';

part 'teaching_class_detail.g.dart';

/// TeachingClassDetail
///
/// Properties:
/// * [class_]
/// * [students]
@BuiltValue()
abstract class TeachingClassDetail
    implements Built<TeachingClassDetail, TeachingClassDetailBuilder> {
  @BuiltValueField(wireName: r'class')
  TeachingClass get class_;

  @BuiltValueField(wireName: r'students')
  BuiltList<TeachingStudentProgress> get students;

  TeachingClassDetail._();

  factory TeachingClassDetail([void updates(TeachingClassDetailBuilder b)]) =
      _$TeachingClassDetail;

  @BuiltValueHook(initializeBuilder: true)
  static void _defaults(TeachingClassDetailBuilder b) => b;

  @BuiltValueSerializer(custom: true)
  static Serializer<TeachingClassDetail> get serializer =>
      _$TeachingClassDetailSerializer();
}

class _$TeachingClassDetailSerializer
    implements PrimitiveSerializer<TeachingClassDetail> {
  @override
  final Iterable<Type> types = const [
    TeachingClassDetail,
    _$TeachingClassDetail
  ];

  @override
  final String wireName = r'TeachingClassDetail';

  Iterable<Object?> _serializeProperties(
    Serializers serializers,
    TeachingClassDetail object, {
    FullType specifiedType = FullType.unspecified,
  }) sync* {
    yield r'class';
    yield serializers.serialize(
      object.class_,
      specifiedType: const FullType(TeachingClass),
    );
    yield r'students';
    yield serializers.serialize(
      object.students,
      specifiedType:
          const FullType(BuiltList, [FullType(TeachingStudentProgress)]),
    );
  }

  @override
  Object serialize(
    Serializers serializers,
    TeachingClassDetail object, {
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
    required TeachingClassDetailBuilder result,
    required List<Object?> unhandled,
  }) {
    for (var i = 0; i < serializedList.length; i += 2) {
      final key = serializedList[i] as String;
      final value = serializedList[i + 1];
      switch (key) {
        case r'class':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType(TeachingClass),
          ) as TeachingClass;
          result.class_.replace(valueDes);
          break;
        case r'students':
          final valueDes = serializers.deserialize(
            value,
            specifiedType:
                const FullType(BuiltList, [FullType(TeachingStudentProgress)]),
          ) as BuiltList<TeachingStudentProgress>;
          result.students.replace(valueDes);
          break;
        default:
          unhandled.add(key);
          unhandled.add(value);
          break;
      }
    }
  }

  @override
  TeachingClassDetail deserialize(
    Serializers serializers,
    Object serialized, {
    FullType specifiedType = FullType.unspecified,
  }) {
    final result = TeachingClassDetailBuilder();
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
