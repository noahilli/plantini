//
// AUTO-GENERATED FILE, DO NOT MODIFY!
//

// ignore_for_file: unused_element
import 'package:built_value/built_value.dart';
import 'package:built_value/serializer.dart';

part 'teaching_capabilities.g.dart';

/// Whether identity administration credentials are configured; does not guarantee provider availability.
///
/// Properties:
/// * [manageStudents]
@BuiltValue()
abstract class TeachingCapabilities
    implements Built<TeachingCapabilities, TeachingCapabilitiesBuilder> {
  @BuiltValueField(wireName: r'manageStudents')
  bool get manageStudents;

  TeachingCapabilities._();

  factory TeachingCapabilities([void updates(TeachingCapabilitiesBuilder b)]) =
      _$TeachingCapabilities;

  @BuiltValueHook(initializeBuilder: true)
  static void _defaults(TeachingCapabilitiesBuilder b) => b;

  @BuiltValueSerializer(custom: true)
  static Serializer<TeachingCapabilities> get serializer =>
      _$TeachingCapabilitiesSerializer();
}

class _$TeachingCapabilitiesSerializer
    implements PrimitiveSerializer<TeachingCapabilities> {
  @override
  final Iterable<Type> types = const [
    TeachingCapabilities,
    _$TeachingCapabilities
  ];

  @override
  final String wireName = r'TeachingCapabilities';

  Iterable<Object?> _serializeProperties(
    Serializers serializers,
    TeachingCapabilities object, {
    FullType specifiedType = FullType.unspecified,
  }) sync* {
    yield r'manageStudents';
    yield serializers.serialize(
      object.manageStudents,
      specifiedType: const FullType(bool),
    );
  }

  @override
  Object serialize(
    Serializers serializers,
    TeachingCapabilities object, {
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
    required TeachingCapabilitiesBuilder result,
    required List<Object?> unhandled,
  }) {
    for (var i = 0; i < serializedList.length; i += 2) {
      final key = serializedList[i] as String;
      final value = serializedList[i + 1];
      switch (key) {
        case r'manageStudents':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType(bool),
          ) as bool;
          result.manageStudents = valueDes;
          break;
        default:
          unhandled.add(key);
          unhandled.add(value);
          break;
      }
    }
  }

  @override
  TeachingCapabilities deserialize(
    Serializers serializers,
    Object serialized, {
    FullType specifiedType = FullType.unspecified,
  }) {
    final result = TeachingCapabilitiesBuilder();
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
