//
// AUTO-GENERATED FILE, DO NOT MODIFY!
//

// ignore_for_file: unused_element
import 'package:openapi/src/model/character_part.dart';
import 'package:built_collection/built_collection.dart';
import 'package:built_value/built_value.dart';
import 'package:built_value/serializer.dart';

part 'character.g.dart';

/// The player's avatar as part choices and colours; the app assembles it from its character kit. Visible to the owner only.
///
/// Properties:
/// * [v]
/// * [gender]
/// * [skin]
/// * [hair]
/// * [hat]
/// * [glasses]
/// * [top]
/// * [bottom]
/// * [shoes]
/// * [backpack]
@BuiltValue()
abstract class Character implements Built<Character, CharacterBuilder> {
  @BuiltValueField(wireName: r'v')
  CharacterVEnum get v;
  // enum vEnum {  1,  };

  @BuiltValueField(wireName: r'gender')
  CharacterGenderEnum get gender;
  // enum genderEnum {  female,  male,  diverse,  };

  @BuiltValueField(wireName: r'skin')
  String get skin;

  @BuiltValueField(wireName: r'hair')
  CharacterPart? get hair;

  @BuiltValueField(wireName: r'hat')
  CharacterPart? get hat;

  @BuiltValueField(wireName: r'glasses')
  CharacterPart? get glasses;

  @BuiltValueField(wireName: r'top')
  CharacterPart get top;

  @BuiltValueField(wireName: r'bottom')
  CharacterPart get bottom;

  @BuiltValueField(wireName: r'shoes')
  CharacterPart get shoes;

  @BuiltValueField(wireName: r'backpack')
  CharacterPart? get backpack;

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
    yield r'gender';
    yield serializers.serialize(
      object.gender,
      specifiedType: const FullType(CharacterGenderEnum),
    );
    yield r'skin';
    yield serializers.serialize(
      object.skin,
      specifiedType: const FullType(String),
    );
    if (object.hair != null) {
      yield r'hair';
      yield serializers.serialize(
        object.hair,
        specifiedType: const FullType(CharacterPart),
      );
    }
    if (object.hat != null) {
      yield r'hat';
      yield serializers.serialize(
        object.hat,
        specifiedType: const FullType(CharacterPart),
      );
    }
    if (object.glasses != null) {
      yield r'glasses';
      yield serializers.serialize(
        object.glasses,
        specifiedType: const FullType(CharacterPart),
      );
    }
    yield r'top';
    yield serializers.serialize(
      object.top,
      specifiedType: const FullType(CharacterPart),
    );
    yield r'bottom';
    yield serializers.serialize(
      object.bottom,
      specifiedType: const FullType(CharacterPart),
    );
    yield r'shoes';
    yield serializers.serialize(
      object.shoes,
      specifiedType: const FullType(CharacterPart),
    );
    if (object.backpack != null) {
      yield r'backpack';
      yield serializers.serialize(
        object.backpack,
        specifiedType: const FullType(CharacterPart),
      );
    }
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
        case r'gender':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType(CharacterGenderEnum),
          ) as CharacterGenderEnum;
          result.gender = valueDes;
          break;
        case r'skin':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType(String),
          ) as String;
          result.skin = valueDes;
          break;
        case r'hair':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType.nullable(CharacterPart),
          ) as CharacterPart?;
          if (valueDes == null) continue;
          result.hair.replace(valueDes);
          break;
        case r'hat':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType.nullable(CharacterPart),
          ) as CharacterPart?;
          if (valueDes == null) continue;
          result.hat.replace(valueDes);
          break;
        case r'glasses':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType.nullable(CharacterPart),
          ) as CharacterPart?;
          if (valueDes == null) continue;
          result.glasses.replace(valueDes);
          break;
        case r'top':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType(CharacterPart),
          ) as CharacterPart;
          result.top.replace(valueDes);
          break;
        case r'bottom':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType(CharacterPart),
          ) as CharacterPart;
          result.bottom.replace(valueDes);
          break;
        case r'shoes':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType(CharacterPart),
          ) as CharacterPart;
          result.shoes.replace(valueDes);
          break;
        case r'backpack':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType.nullable(CharacterPart),
          ) as CharacterPart?;
          if (valueDes == null) continue;
          result.backpack.replace(valueDes);
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
  @BuiltValueEnumConst(wireNumber: 1)
  static const CharacterVEnum number1 = _$characterVEnum_number1;

  static Serializer<CharacterVEnum> get serializer =>
      _$characterVEnumSerializer;

  const CharacterVEnum._(String name) : super(name);

  static BuiltSet<CharacterVEnum> get values => _$characterVEnumValues;
  static CharacterVEnum valueOf(String name) => _$characterVEnumValueOf(name);
}

class CharacterGenderEnum extends EnumClass {
  @BuiltValueEnumConst(wireName: r'female')
  static const CharacterGenderEnum female = _$characterGenderEnum_female;
  @BuiltValueEnumConst(wireName: r'male')
  static const CharacterGenderEnum male = _$characterGenderEnum_male;
  @BuiltValueEnumConst(wireName: r'diverse')
  static const CharacterGenderEnum diverse = _$characterGenderEnum_diverse;

  static Serializer<CharacterGenderEnum> get serializer =>
      _$characterGenderEnumSerializer;

  const CharacterGenderEnum._(String name) : super(name);

  static BuiltSet<CharacterGenderEnum> get values =>
      _$characterGenderEnumValues;
  static CharacterGenderEnum valueOf(String name) =>
      _$characterGenderEnumValueOf(name);
}
