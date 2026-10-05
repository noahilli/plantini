//
// AUTO-GENERATED FILE, DO NOT MODIFY!
//

// ignore_for_file: unused_element
import 'package:built_value/built_value.dart';
import 'package:built_value/serializer.dart';

part 'teaching_update_student_request.g.dart';

/// TeachingUpdateStudentRequest
///
/// Properties:
/// * [enabled]
@BuiltValue()
abstract class TeachingUpdateStudentRequest
    implements
        Built<TeachingUpdateStudentRequest,
            TeachingUpdateStudentRequestBuilder> {
  @BuiltValueField(wireName: r'enabled')
  bool get enabled;

  TeachingUpdateStudentRequest._();

  factory TeachingUpdateStudentRequest(
          [void updates(TeachingUpdateStudentRequestBuilder b)]) =
      _$TeachingUpdateStudentRequest;

  @BuiltValueHook(initializeBuilder: true)
  static void _defaults(TeachingUpdateStudentRequestBuilder b) => b;

  @BuiltValueSerializer(custom: true)
  static Serializer<TeachingUpdateStudentRequest> get serializer =>
      _$TeachingUpdateStudentRequestSerializer();
}

class _$TeachingUpdateStudentRequestSerializer
    implements PrimitiveSerializer<TeachingUpdateStudentRequest> {
  @override
  final Iterable<Type> types = const [
    TeachingUpdateStudentRequest,
    _$TeachingUpdateStudentRequest
  ];

  @override
  final String wireName = r'TeachingUpdateStudentRequest';

  Iterable<Object?> _serializeProperties(
    Serializers serializers,
    TeachingUpdateStudentRequest object, {
    FullType specifiedType = FullType.unspecified,
  }) sync* {
    yield r'enabled';
    yield serializers.serialize(
      object.enabled,
      specifiedType: const FullType(bool),
    );
  }

  @override
  Object serialize(
    Serializers serializers,
    TeachingUpdateStudentRequest object, {
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
    required TeachingUpdateStudentRequestBuilder result,
    required List<Object?> unhandled,
  }) {
    for (var i = 0; i < serializedList.length; i += 2) {
      final key = serializedList[i] as String;
      final value = serializedList[i + 1];
      switch (key) {
        case r'enabled':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType(bool),
          ) as bool;
          result.enabled = valueDes;
          break;
        default:
          unhandled.add(key);
          unhandled.add(value);
          break;
      }
    }
  }

  @override
  TeachingUpdateStudentRequest deserialize(
    Serializers serializers,
    Object serialized, {
    FullType specifiedType = FullType.unspecified,
  }) {
    final result = TeachingUpdateStudentRequestBuilder();
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
