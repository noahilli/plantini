//
// AUTO-GENERATED FILE, DO NOT MODIFY!
//

// ignore_for_file: unused_element
import 'package:built_value/built_value.dart';
import 'package:built_value/serializer.dart';

part 'teaching_reset_password_response.g.dart';

/// TeachingResetPasswordResponse
///
/// Properties:
/// * [temporaryPassword] - Sensitive temporary password returned only by this creation or reset response. Display once for secure handoff; never log or persist it. The learner must change it at next login.
@BuiltValue()
abstract class TeachingResetPasswordResponse
    implements
        Built<TeachingResetPasswordResponse,
            TeachingResetPasswordResponseBuilder> {
  /// Sensitive temporary password returned only by this creation or reset response. Display once for secure handoff; never log or persist it. The learner must change it at next login.
  @BuiltValueField(wireName: r'temporaryPassword')
  String get temporaryPassword;

  TeachingResetPasswordResponse._();

  factory TeachingResetPasswordResponse(
          [void updates(TeachingResetPasswordResponseBuilder b)]) =
      _$TeachingResetPasswordResponse;

  @BuiltValueHook(initializeBuilder: true)
  static void _defaults(TeachingResetPasswordResponseBuilder b) => b;

  @BuiltValueSerializer(custom: true)
  static Serializer<TeachingResetPasswordResponse> get serializer =>
      _$TeachingResetPasswordResponseSerializer();
}

class _$TeachingResetPasswordResponseSerializer
    implements PrimitiveSerializer<TeachingResetPasswordResponse> {
  @override
  final Iterable<Type> types = const [
    TeachingResetPasswordResponse,
    _$TeachingResetPasswordResponse
  ];

  @override
  final String wireName = r'TeachingResetPasswordResponse';

  Iterable<Object?> _serializeProperties(
    Serializers serializers,
    TeachingResetPasswordResponse object, {
    FullType specifiedType = FullType.unspecified,
  }) sync* {
    yield r'temporaryPassword';
    yield serializers.serialize(
      object.temporaryPassword,
      specifiedType: const FullType(String),
    );
  }

  @override
  Object serialize(
    Serializers serializers,
    TeachingResetPasswordResponse object, {
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
    required TeachingResetPasswordResponseBuilder result,
    required List<Object?> unhandled,
  }) {
    for (var i = 0; i < serializedList.length; i += 2) {
      final key = serializedList[i] as String;
      final value = serializedList[i + 1];
      switch (key) {
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
  TeachingResetPasswordResponse deserialize(
    Serializers serializers,
    Object serialized, {
    FullType specifiedType = FullType.unspecified,
  }) {
    final result = TeachingResetPasswordResponseBuilder();
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
