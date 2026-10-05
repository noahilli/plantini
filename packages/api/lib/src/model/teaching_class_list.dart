//
// AUTO-GENERATED FILE, DO NOT MODIFY!
//

// ignore_for_file: unused_element
import 'package:built_collection/built_collection.dart';
import 'package:openapi/src/model/teaching_class.dart';
import 'package:built_value/built_value.dart';
import 'package:built_value/serializer.dart';

part 'teaching_class_list.g.dart';

/// TeachingClassList
///
/// Properties:
/// * [classes]
@BuiltValue()
abstract class TeachingClassList
    implements Built<TeachingClassList, TeachingClassListBuilder> {
  @BuiltValueField(wireName: r'classes')
  BuiltList<TeachingClass> get classes;

  TeachingClassList._();

  factory TeachingClassList([void updates(TeachingClassListBuilder b)]) =
      _$TeachingClassList;

  @BuiltValueHook(initializeBuilder: true)
  static void _defaults(TeachingClassListBuilder b) => b;

  @BuiltValueSerializer(custom: true)
  static Serializer<TeachingClassList> get serializer =>
      _$TeachingClassListSerializer();
}

class _$TeachingClassListSerializer
    implements PrimitiveSerializer<TeachingClassList> {
  @override
  final Iterable<Type> types = const [TeachingClassList, _$TeachingClassList];

  @override
  final String wireName = r'TeachingClassList';

  Iterable<Object?> _serializeProperties(
    Serializers serializers,
    TeachingClassList object, {
    FullType specifiedType = FullType.unspecified,
  }) sync* {
    yield r'classes';
    yield serializers.serialize(
      object.classes,
      specifiedType: const FullType(BuiltList, [FullType(TeachingClass)]),
    );
  }

  @override
  Object serialize(
    Serializers serializers,
    TeachingClassList object, {
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
    required TeachingClassListBuilder result,
    required List<Object?> unhandled,
  }) {
    for (var i = 0; i < serializedList.length; i += 2) {
      final key = serializedList[i] as String;
      final value = serializedList[i + 1];
      switch (key) {
        case r'classes':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType(BuiltList, [FullType(TeachingClass)]),
          ) as BuiltList<TeachingClass>;
          result.classes.replace(valueDes);
          break;
        default:
          unhandled.add(key);
          unhandled.add(value);
          break;
      }
    }
  }

  @override
  TeachingClassList deserialize(
    Serializers serializers,
    Object serialized, {
    FullType specifiedType = FullType.unspecified,
  }) {
    final result = TeachingClassListBuilder();
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
