// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'character.dart';

// **************************************************************************
// BuiltValueGenerator
// **************************************************************************

const CharacterVEnum _$characterVEnum_number1 =
    const CharacterVEnum._('number1');

CharacterVEnum _$characterVEnumValueOf(String name) {
  switch (name) {
    case 'number1':
      return _$characterVEnum_number1;
    default:
      throw ArgumentError(name);
  }
}

final BuiltSet<CharacterVEnum> _$characterVEnumValues =
    BuiltSet<CharacterVEnum>(const <CharacterVEnum>[
  _$characterVEnum_number1,
]);

const CharacterGenderEnum _$characterGenderEnum_female =
    const CharacterGenderEnum._('female');
const CharacterGenderEnum _$characterGenderEnum_male =
    const CharacterGenderEnum._('male');
const CharacterGenderEnum _$characterGenderEnum_diverse =
    const CharacterGenderEnum._('diverse');

CharacterGenderEnum _$characterGenderEnumValueOf(String name) {
  switch (name) {
    case 'female':
      return _$characterGenderEnum_female;
    case 'male':
      return _$characterGenderEnum_male;
    case 'diverse':
      return _$characterGenderEnum_diverse;
    default:
      throw ArgumentError(name);
  }
}

final BuiltSet<CharacterGenderEnum> _$characterGenderEnumValues =
    BuiltSet<CharacterGenderEnum>(const <CharacterGenderEnum>[
  _$characterGenderEnum_female,
  _$characterGenderEnum_male,
  _$characterGenderEnum_diverse,
]);

Serializer<CharacterVEnum> _$characterVEnumSerializer =
    _$CharacterVEnumSerializer();
Serializer<CharacterGenderEnum> _$characterGenderEnumSerializer =
    _$CharacterGenderEnumSerializer();

class _$CharacterVEnumSerializer
    implements PrimitiveSerializer<CharacterVEnum> {
  static const Map<String, Object> _toWire = const <String, Object>{
    'number1': 1,
  };
  static const Map<Object, String> _fromWire = const <Object, String>{
    1: 'number1',
  };

  @override
  final Iterable<Type> types = const <Type>[CharacterVEnum];
  @override
  final String wireName = 'CharacterVEnum';

  @override
  Object serialize(Serializers serializers, CharacterVEnum object,
          {FullType specifiedType = FullType.unspecified}) =>
      _toWire[object.name] ?? object.name;

  @override
  CharacterVEnum deserialize(Serializers serializers, Object serialized,
          {FullType specifiedType = FullType.unspecified}) =>
      CharacterVEnum.valueOf(
          _fromWire[serialized] ?? (serialized is String ? serialized : ''));
}

class _$CharacterGenderEnumSerializer
    implements PrimitiveSerializer<CharacterGenderEnum> {
  static const Map<String, Object> _toWire = const <String, Object>{
    'female': 'female',
    'male': 'male',
    'diverse': 'diverse',
  };
  static const Map<Object, String> _fromWire = const <Object, String>{
    'female': 'female',
    'male': 'male',
    'diverse': 'diverse',
  };

  @override
  final Iterable<Type> types = const <Type>[CharacterGenderEnum];
  @override
  final String wireName = 'CharacterGenderEnum';

  @override
  Object serialize(Serializers serializers, CharacterGenderEnum object,
          {FullType specifiedType = FullType.unspecified}) =>
      _toWire[object.name] ?? object.name;

  @override
  CharacterGenderEnum deserialize(Serializers serializers, Object serialized,
          {FullType specifiedType = FullType.unspecified}) =>
      CharacterGenderEnum.valueOf(
          _fromWire[serialized] ?? (serialized is String ? serialized : ''));
}

class _$Character extends Character {
  @override
  final CharacterVEnum v;
  @override
  final CharacterGenderEnum gender;
  @override
  final String skin;
  @override
  final CharacterPart? hair;
  @override
  final CharacterPart? hat;
  @override
  final CharacterPart? glasses;
  @override
  final CharacterPart top;
  @override
  final CharacterPart bottom;
  @override
  final CharacterPart shoes;
  @override
  final CharacterPart? backpack;

  factory _$Character([void Function(CharacterBuilder)? updates]) =>
      (CharacterBuilder()..update(updates))._build();

  _$Character._(
      {required this.v,
      required this.gender,
      required this.skin,
      this.hair,
      this.hat,
      this.glasses,
      required this.top,
      required this.bottom,
      required this.shoes,
      this.backpack})
      : super._();
  @override
  Character rebuild(void Function(CharacterBuilder) updates) =>
      (toBuilder()..update(updates)).build();

  @override
  CharacterBuilder toBuilder() => CharacterBuilder()..replace(this);

  @override
  bool operator ==(Object other) {
    if (identical(other, this)) return true;
    return other is Character &&
        v == other.v &&
        gender == other.gender &&
        skin == other.skin &&
        hair == other.hair &&
        hat == other.hat &&
        glasses == other.glasses &&
        top == other.top &&
        bottom == other.bottom &&
        shoes == other.shoes &&
        backpack == other.backpack;
  }

  @override
  int get hashCode {
    var _$hash = 0;
    _$hash = $jc(_$hash, v.hashCode);
    _$hash = $jc(_$hash, gender.hashCode);
    _$hash = $jc(_$hash, skin.hashCode);
    _$hash = $jc(_$hash, hair.hashCode);
    _$hash = $jc(_$hash, hat.hashCode);
    _$hash = $jc(_$hash, glasses.hashCode);
    _$hash = $jc(_$hash, top.hashCode);
    _$hash = $jc(_$hash, bottom.hashCode);
    _$hash = $jc(_$hash, shoes.hashCode);
    _$hash = $jc(_$hash, backpack.hashCode);
    _$hash = $jf(_$hash);
    return _$hash;
  }

  @override
  String toString() {
    return (newBuiltValueToStringHelper(r'Character')
          ..add('v', v)
          ..add('gender', gender)
          ..add('skin', skin)
          ..add('hair', hair)
          ..add('hat', hat)
          ..add('glasses', glasses)
          ..add('top', top)
          ..add('bottom', bottom)
          ..add('shoes', shoes)
          ..add('backpack', backpack))
        .toString();
  }
}

class CharacterBuilder implements Builder<Character, CharacterBuilder> {
  _$Character? _$v;

  CharacterVEnum? _v;
  CharacterVEnum? get v => _$this._v;
  set v(CharacterVEnum? v) => _$this._v = v;

  CharacterGenderEnum? _gender;
  CharacterGenderEnum? get gender => _$this._gender;
  set gender(CharacterGenderEnum? gender) => _$this._gender = gender;

  String? _skin;
  String? get skin => _$this._skin;
  set skin(String? skin) => _$this._skin = skin;

  CharacterPartBuilder? _hair;
  CharacterPartBuilder get hair => _$this._hair ??= CharacterPartBuilder();
  set hair(CharacterPartBuilder? hair) => _$this._hair = hair;

  CharacterPartBuilder? _hat;
  CharacterPartBuilder get hat => _$this._hat ??= CharacterPartBuilder();
  set hat(CharacterPartBuilder? hat) => _$this._hat = hat;

  CharacterPartBuilder? _glasses;
  CharacterPartBuilder get glasses =>
      _$this._glasses ??= CharacterPartBuilder();
  set glasses(CharacterPartBuilder? glasses) => _$this._glasses = glasses;

  CharacterPartBuilder? _top;
  CharacterPartBuilder get top => _$this._top ??= CharacterPartBuilder();
  set top(CharacterPartBuilder? top) => _$this._top = top;

  CharacterPartBuilder? _bottom;
  CharacterPartBuilder get bottom => _$this._bottom ??= CharacterPartBuilder();
  set bottom(CharacterPartBuilder? bottom) => _$this._bottom = bottom;

  CharacterPartBuilder? _shoes;
  CharacterPartBuilder get shoes => _$this._shoes ??= CharacterPartBuilder();
  set shoes(CharacterPartBuilder? shoes) => _$this._shoes = shoes;

  CharacterPartBuilder? _backpack;
  CharacterPartBuilder get backpack =>
      _$this._backpack ??= CharacterPartBuilder();
  set backpack(CharacterPartBuilder? backpack) => _$this._backpack = backpack;

  CharacterBuilder() {
    Character._defaults(this);
  }

  CharacterBuilder get _$this {
    final $v = _$v;
    if ($v != null) {
      _v = $v.v;
      _gender = $v.gender;
      _skin = $v.skin;
      _hair = $v.hair?.toBuilder();
      _hat = $v.hat?.toBuilder();
      _glasses = $v.glasses?.toBuilder();
      _top = $v.top.toBuilder();
      _bottom = $v.bottom.toBuilder();
      _shoes = $v.shoes.toBuilder();
      _backpack = $v.backpack?.toBuilder();
      _$v = null;
    }
    return this;
  }

  @override
  void replace(Character other) {
    _$v = other as _$Character;
  }

  @override
  void update(void Function(CharacterBuilder)? updates) {
    if (updates != null) updates(this);
  }

  @override
  Character build() => _build();

  _$Character _build() {
    _$Character _$result;
    try {
      _$result = _$v ??
          _$Character._(
            v: BuiltValueNullFieldError.checkNotNull(v, r'Character', 'v'),
            gender: BuiltValueNullFieldError.checkNotNull(
                gender, r'Character', 'gender'),
            skin: BuiltValueNullFieldError.checkNotNull(
                skin, r'Character', 'skin'),
            hair: _hair?.build(),
            hat: _hat?.build(),
            glasses: _glasses?.build(),
            top: top.build(),
            bottom: bottom.build(),
            shoes: shoes.build(),
            backpack: _backpack?.build(),
          );
    } catch (_) {
      late String _$failedField;
      try {
        _$failedField = 'hair';
        _hair?.build();
        _$failedField = 'hat';
        _hat?.build();
        _$failedField = 'glasses';
        _glasses?.build();
        _$failedField = 'top';
        top.build();
        _$failedField = 'bottom';
        bottom.build();
        _$failedField = 'shoes';
        shoes.build();
        _$failedField = 'backpack';
        _backpack?.build();
      } catch (e) {
        throw BuiltValueNestedFieldError(
            r'Character', _$failedField, e.toString());
      }
      rethrow;
    }
    replace(_$result);
    return _$result;
  }
}

// ignore_for_file: deprecated_member_use_from_same_package,type=lint
