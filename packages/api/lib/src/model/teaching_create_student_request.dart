//
// AUTO-GENERATED FILE, DO NOT MODIFY!
//

// ignore_for_file: unused_element
import 'package:built_value/built_value.dart';
import 'package:built_value/serializer.dart';

part 'teaching_create_student_request.g.dart';

/// TeachingCreateStudentRequest
///
/// Properties:
/// * [username] - Normalized to lowercase by the server.
/// * [displayName]
/// * [email] - Optional email; null or an empty string is treated as omitted. Nonempty values must be valid email addresses and are normalized to lowercase.
@BuiltValue()
abstract class TeachingCreateStudentRequest
    implements
        Built<TeachingCreateStudentRequest,
            TeachingCreateStudentRequestBuilder> {
  /// Normalized to lowercase by the server.
  @BuiltValueField(wireName: r'username')
  String get username;

  @BuiltValueField(wireName: r'displayName')
  String get displayName;

  /// Optional email; null or an empty string is treated as omitted. Nonempty values must be valid email addresses and are normalized to lowercase.
  @BuiltValueField(wireName: r'email')
  String? get email;

  TeachingCreateStudentRequest._();

  factory TeachingCreateStudentRequest(
          [void updates(TeachingCreateStudentRequestBuilder b)]) =
      _$TeachingCreateStudentRequest;

  @BuiltValueHook(initializeBuilder: true)
  static void _defaults(TeachingCreateStudentRequestBuilder b) => b;

  @BuiltValueSerializer(custom: true)
  static Serializer<TeachingCreateStudentRequest> get serializer =>
      _$TeachingCreateStudentRequestSerializer();
}

class _$TeachingCreateStudentRequestSerializer
    implements PrimitiveSerializer<TeachingCreateStudentRequest> {
  @override
  final Iterable<Type> types = const [
    TeachingCreateStudentRequest,
    _$TeachingCreateStudentRequest
  ];

  @override
  final String wireName = r'TeachingCreateStudentRequest';

  Iterable<Object?> _serializeProperties(
    Serializers serializers,
    TeachingCreateStudentRequest object, {
    FullType specifiedType = FullType.unspecified,
  }) sync* {
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
        specifiedType: const FullType.nullable(String),
      );
    }
  }

  @override
  Object serialize(
    Serializers serializers,
    TeachingCreateStudentRequest object, {
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
    required TeachingCreateStudentRequestBuilder result,
    required List<Object?> unhandled,
  }) {
    for (var i = 0; i < serializedList.length; i += 2) {
      final key = serializedList[i] as String;
      final value = serializedList[i + 1];
      switch (key) {
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
        default:
          unhandled.add(key);
          unhandled.add(value);
          break;
      }
    }
  }

  @override
  TeachingCreateStudentRequest deserialize(
    Serializers serializers,
    Object serialized, {
    FullType specifiedType = FullType.unspecified,
  }) {
    final result = TeachingCreateStudentRequestBuilder();
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
