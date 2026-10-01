//
// AUTO-GENERATED FILE, DO NOT MODIFY!
//

// ignore_for_file: unused_element
import 'package:built_collection/built_collection.dart';
import 'package:built_value/built_value.dart';
import 'package:built_value/serializer.dart';

part 'character.g.dart';

/// The player's chosen explorer, one of nine fixed characters shipped with the app. Visible to the owner only.
///
/// Properties:
/// * [v]
/// * [id]
@BuiltValue()
abstract class Character implements Built<Character, CharacterBuilder> {
  @BuiltValueField(wireName: r'v')
  CharacterVEnum get v;
  // enum vEnum {  2,  };

  @BuiltValueField(wireName: r'id')
  CharacterIdEnum get id;
  // enum idEnum {  amara,  mei,  samira,  heinrich,  mateo,  arjun,  robin,  nia,  kai,  };

  Character._();

  factory Character([void updates(CharacterBuilder b)]) = _$Character;

  @BuiltValueHook(initializeBuilder: true)
  static void _defaults(CharacterBuilder b) => b;

  @BuiltValueSerializer(custom: true)
  static Serializer<Character> get serializer => _$CharacterSerializer();
}

class _$CharacterSerializer implements PrimitiveSerializer<Character> {
  @override
  final Iterable<Type> types = const [Character, _$Character];

  @override
  final String wireName = r'Character';

  Iterable<Object?> _serializeProperties(
    Serializers serializers,
    Character object, {
    FullType specifiedType = FullType.unspecified,
  }) sync* {
    yield r'v';
    yield serializers.serialize(
      object.v,
      specifiedType: const FullType(CharacterVEnum),
    );
    yield r'id';
    yield serializers.serialize(
      object.id,
      specifiedType: const FullType(CharacterIdEnum),
    );
  }

  @override
  Object serialize(
    Serializers serializers,
    Character object, {
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
    required CharacterBuilder result,
    required List<Object?> unhandled,
  }) {
    for (var i = 0; i < serializedList.length; i += 2) {
      final key = serializedList[i] as String;
      final value = serializedList[i + 1];
      switch (key) {
        case r'v':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType(CharacterVEnum),
          ) as CharacterVEnum;
          result.v = valueDes;
          break;
        case r'id':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType(CharacterIdEnum),
          ) as CharacterIdEnum;
          result.id = valueDes;
          break;
        default:
          unhandled.add(key);
          unhandled.add(value);
          break;
      }
    }
  }

  @override
  Character deserialize(
    Serializers serializers,
    Object serialized, {
    FullType specifiedType = FullType.unspecified,
  }) {
    final result = CharacterBuilder();
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

class CharacterVEnum extends EnumClass {
  @BuiltValueEnumConst(wireNumber: 2)
  static const CharacterVEnum number2 = _$characterVEnum_number2;

  static Serializer<CharacterVEnum> get serializer =>
      _$characterVEnumSerializer;

  const CharacterVEnum._(String name) : super(name);

  static BuiltSet<CharacterVEnum> get values => _$characterVEnumValues;
  static CharacterVEnum valueOf(String name) => _$characterVEnumValueOf(name);
}

class CharacterIdEnum extends EnumClass {
  @BuiltValueEnumConst(wireName: r'amara')
  static const CharacterIdEnum amara = _$characterIdEnum_amara;
  @BuiltValueEnumConst(wireName: r'mei')
  static const CharacterIdEnum mei = _$characterIdEnum_mei;
  @BuiltValueEnumConst(wireName: r'samira')
  static const CharacterIdEnum samira = _$characterIdEnum_samira;
  @BuiltValueEnumConst(wireName: r'heinrich')
  static const CharacterIdEnum heinrich = _$characterIdEnum_heinrich;
  @BuiltValueEnumConst(wireName: r'mateo')
  static const CharacterIdEnum mateo = _$characterIdEnum_mateo;
  @BuiltValueEnumConst(wireName: r'arjun')
  static const CharacterIdEnum arjun = _$characterIdEnum_arjun;
  @BuiltValueEnumConst(wireName: r'robin')
  static const CharacterIdEnum robin = _$characterIdEnum_robin;
  @BuiltValueEnumConst(wireName: r'nia')
  static const CharacterIdEnum nia = _$characterIdEnum_nia;
  @BuiltValueEnumConst(wireName: r'kai')
  static const CharacterIdEnum kai = _$characterIdEnum_kai;

  static Serializer<CharacterIdEnum> get serializer =>
      _$characterIdEnumSerializer;

  const CharacterIdEnum._(String name) : super(name);

  static BuiltSet<CharacterIdEnum> get values => _$characterIdEnumValues;
  static CharacterIdEnum valueOf(String name) => _$characterIdEnumValueOf(name);
}
