//
// AUTO-GENERATED FILE, DO NOT MODIFY!
//

// ignore_for_file: unused_element
import 'package:built_value/built_value.dart';
import 'package:built_value/serializer.dart';

part 'plant_profile_cards_inner.g.dart';

/// PlantProfileCardsInner
///
/// Properties:
/// * [heading]
/// * [text]
@BuiltValue()
abstract class PlantProfileCardsInner
    implements Built<PlantProfileCardsInner, PlantProfileCardsInnerBuilder> {
  @BuiltValueField(wireName: r'heading')
  String get heading;

  @BuiltValueField(wireName: r'text')
  String get text;

  PlantProfileCardsInner._();

  factory PlantProfileCardsInner(
          [void updates(PlantProfileCardsInnerBuilder b)]) =
      _$PlantProfileCardsInner;

  @BuiltValueHook(initializeBuilder: true)
  static void _defaults(PlantProfileCardsInnerBuilder b) => b;

  @BuiltValueSerializer(custom: true)
  static Serializer<PlantProfileCardsInner> get serializer =>
      _$PlantProfileCardsInnerSerializer();
}

class _$PlantProfileCardsInnerSerializer
    implements PrimitiveSerializer<PlantProfileCardsInner> {
  @override
  final Iterable<Type> types = const [
    PlantProfileCardsInner,
    _$PlantProfileCardsInner
  ];

  @override
  final String wireName = r'PlantProfileCardsInner';

  Iterable<Object?> _serializeProperties(
    Serializers serializers,
    PlantProfileCardsInner object, {
    FullType specifiedType = FullType.unspecified,
  }) sync* {
    yield r'heading';
    yield serializers.serialize(
      object.heading,
      specifiedType: const FullType(String),
    );
    yield r'text';
    yield serializers.serialize(
      object.text,
      specifiedType: const FullType(String),
    );
  }

  @override
  Object serialize(
    Serializers serializers,
    PlantProfileCardsInner object, {
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
    required PlantProfileCardsInnerBuilder result,
    required List<Object?> unhandled,
  }) {
    for (var i = 0; i < serializedList.length; i += 2) {
      final key = serializedList[i] as String;
      final value = serializedList[i + 1];
      switch (key) {
        case r'heading':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType(String),
          ) as String;
          result.heading = valueDes;
          break;
        case r'text':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType(String),
          ) as String;
          result.text = valueDes;
          break;
        default:
          unhandled.add(key);
          unhandled.add(value);
          break;
      }
    }
  }

  @override
  PlantProfileCardsInner deserialize(
    Serializers serializers,
    Object serialized, {
    FullType specifiedType = FullType.unspecified,
  }) {
    final result = PlantProfileCardsInnerBuilder();
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
