//
// AUTO-GENERATED FILE, DO NOT MODIFY!
//

// ignore_for_file: unused_element
import 'package:built_value/built_value.dart';
import 'package:built_value/serializer.dart';

part 'character_part.g.dart';

/// CharacterPart
///
/// Properties:
/// * [style]
/// * [color] - Required unless style is none.
@BuiltValue()
abstract class CharacterPart
    implements Built<CharacterPart, CharacterPartBuilder> {
  @BuiltValueField(wireName: r'style')
  String get style;

  /// Required unless style is none.
  @BuiltValueField(wireName: r'color')
  String? get color;

  CharacterPart._();

  factory CharacterPart([void updates(CharacterPartBuilder b)]) =
      _$CharacterPart;

  @BuiltValueHook(initializeBuilder: true)
  static void _defaults(CharacterPartBuilder b) => b;

  @BuiltValueSerializer(custom: true)
  static Serializer<CharacterPart> get serializer =>
      _$CharacterPartSerializer();
}

class _$CharacterPartSerializer implements PrimitiveSerializer<CharacterPart> {
  @override
  final Iterable<Type> types = const [CharacterPart, _$CharacterPart];

  @override
  final String wireName = r'CharacterPart';

  Iterable<Object?> _serializeProperties(
    Serializers serializers,
    CharacterPart object, {
    FullType specifiedType = FullType.unspecified,
  }) sync* {
    yield r'style';
    yield serializers.serialize(
      object.style,
      specifiedType: const FullType(String),
    );
    if (object.color != null) {
      yield r'color';
      yield serializers.serialize(
        object.color,
        specifiedType: const FullType(String),
      );
    }
  }

  @override
  Object serialize(
    Serializers serializers,
    CharacterPart object, {
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
    required CharacterPartBuilder result,
    required List<Object?> unhandled,
  }) {
    for (var i = 0; i < serializedList.length; i += 2) {
      final key = serializedList[i] as String;
      final value = serializedList[i + 1];
      switch (key) {
        case r'style':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType(String),
          ) as String;
          result.style = valueDes;
          break;
        case r'color':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType.nullable(String),
          ) as String?;
          if (valueDes == null) continue;
          result.color = valueDes;
          break;
        default:
          unhandled.add(key);
          unhandled.add(value);
          break;
      }
    }
  }

  @override
  CharacterPart deserialize(
    Serializers serializers,
    Object serialized, {
    FullType specifiedType = FullType.unspecified,
  }) {
    final result = CharacterPartBuilder();
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
