//
// AUTO-GENERATED FILE, DO NOT MODIFY!
//

// ignore_for_file: unused_element
import 'package:openapi/src/model/teaching_student.dart';
import 'package:built_value/built_value.dart';
import 'package:built_value/serializer.dart';

part 'teaching_create_student_response.g.dart';

/// TeachingCreateStudentResponse
///
/// Properties:
/// * [student]
/// * [temporaryPassword] - Sensitive temporary password returned only by this creation or reset response. Display once for secure handoff; never log or persist it. The learner must change it at next login.
@BuiltValue()
abstract class TeachingCreateStudentResponse
    implements
        Built<TeachingCreateStudentResponse,
            TeachingCreateStudentResponseBuilder> {
  @BuiltValueField(wireName: r'student')
  TeachingStudent get student;

  /// Sensitive temporary password returned only by this creation or reset response. Display once for secure handoff; never log or persist it. The learner must change it at next login.
  @BuiltValueField(wireName: r'temporaryPassword')
  String get temporaryPassword;

  TeachingCreateStudentResponse._();

  factory TeachingCreateStudentResponse(
          [void updates(TeachingCreateStudentResponseBuilder b)]) =
      _$TeachingCreateStudentResponse;

  @BuiltValueHook(initializeBuilder: true)
  static void _defaults(TeachingCreateStudentResponseBuilder b) => b;

  @BuiltValueSerializer(custom: true)
  static Serializer<TeachingCreateStudentResponse> get serializer =>
      _$TeachingCreateStudentResponseSerializer();
}

class _$TeachingCreateStudentResponseSerializer
    implements PrimitiveSerializer<TeachingCreateStudentResponse> {
  @override
  final Iterable<Type> types = const [
    TeachingCreateStudentResponse,
    _$TeachingCreateStudentResponse
  ];

  @override
  final String wireName = r'TeachingCreateStudentResponse';

  Iterable<Object?> _serializeProperties(
    Serializers serializers,
    TeachingCreateStudentResponse object, {
    FullType specifiedType = FullType.unspecified,
  }) sync* {
    yield r'student';
    yield serializers.serialize(
      object.student,
      specifiedType: const FullType(TeachingStudent),
    );
    yield r'temporaryPassword';
    yield serializers.serialize(
      object.temporaryPassword,
      specifiedType: const FullType(String),
    );
  }

  @override
  Object serialize(
    Serializers serializers,
    TeachingCreateStudentResponse object, {
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
    required TeachingCreateStudentResponseBuilder result,
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
        case r'temporaryPassword':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType(String),
          ) as String;
          result.temporaryPassword = valueDes;
          break;
        default:
          unhandled.add(key);
          unhandled.add(value);
          break;
      }
    }
  }

  @override
  TeachingCreateStudentResponse deserialize(
    Serializers serializers,
    Object serialized, {
    FullType specifiedType = FullType.unspecified,
  }) {
    final result = TeachingCreateStudentResponseBuilder();
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
