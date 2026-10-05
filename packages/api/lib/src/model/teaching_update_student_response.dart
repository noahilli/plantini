//
// AUTO-GENERATED FILE, DO NOT MODIFY!
//

// ignore_for_file: unused_element
import 'package:openapi/src/model/teaching_student.dart';
import 'package:built_value/built_value.dart';
import 'package:built_value/serializer.dart';

part 'teaching_update_student_response.g.dart';

/// TeachingUpdateStudentResponse
///
/// Properties:
/// * [student]
@BuiltValue()
abstract class TeachingUpdateStudentResponse
    implements
        Built<TeachingUpdateStudentResponse,
            TeachingUpdateStudentResponseBuilder> {
  @BuiltValueField(wireName: r'student')
  TeachingStudent get student;

  TeachingUpdateStudentResponse._();

  factory TeachingUpdateStudentResponse(
          [void updates(TeachingUpdateStudentResponseBuilder b)]) =
      _$TeachingUpdateStudentResponse;

  @BuiltValueHook(initializeBuilder: true)
  static void _defaults(TeachingUpdateStudentResponseBuilder b) => b;

  @BuiltValueSerializer(custom: true)
  static Serializer<TeachingUpdateStudentResponse> get serializer =>
      _$TeachingUpdateStudentResponseSerializer();
}

class _$TeachingUpdateStudentResponseSerializer
    implements PrimitiveSerializer<TeachingUpdateStudentResponse> {
  @override
  final Iterable<Type> types = const [
    TeachingUpdateStudentResponse,
    _$TeachingUpdateStudentResponse
  ];

  @override
  final String wireName = r'TeachingUpdateStudentResponse';

  Iterable<Object?> _serializeProperties(
    Serializers serializers,
    TeachingUpdateStudentResponse object, {
    FullType specifiedType = FullType.unspecified,
  }) sync* {
    yield r'student';
    yield serializers.serialize(
      object.student,
      specifiedType: const FullType(TeachingStudent),
    );
  }

  @override
  Object serialize(
    Serializers serializers,
    TeachingUpdateStudentResponse object, {
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
    required TeachingUpdateStudentResponseBuilder result,
    required List<Object?> unhandled,
  }) {
    for (var i = 0; i < serializedList.length; i += 2) {
      final key = serializedList[i] as String;
      final value = serializedList[i + 1];
      switch (key) {
        case r'student':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType(TeachingStudent),
          ) as TeachingStudent;
          result.student.replace(valueDes);
          break;
        default:
          unhandled.add(key);
          unhandled.add(value);
          break;
      }
    }
  }

  @override
  TeachingUpdateStudentResponse deserialize(
    Serializers serializers,
    Object serialized, {
    FullType specifiedType = FullType.unspecified,
  }) {
    final result = TeachingUpdateStudentResponseBuilder();
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
