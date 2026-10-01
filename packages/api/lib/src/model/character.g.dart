// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'character.dart';

// **************************************************************************
// BuiltValueGenerator
// **************************************************************************

const CharacterVEnum _$characterVEnum_number2 =
    const CharacterVEnum._('number2');

CharacterVEnum _$characterVEnumValueOf(String name) {
  switch (name) {
    case 'number2':
      return _$characterVEnum_number2;
    default:
      throw ArgumentError(name);
  }
}

final BuiltSet<CharacterVEnum> _$characterVEnumValues =
    BuiltSet<CharacterVEnum>(const <CharacterVEnum>[
  _$characterVEnum_number2,
]);

const CharacterIdEnum _$characterIdEnum_amara =
    const CharacterIdEnum._('amara');
const CharacterIdEnum _$characterIdEnum_mei = const CharacterIdEnum._('mei');
const CharacterIdEnum _$characterIdEnum_samira =
    const CharacterIdEnum._('samira');
const CharacterIdEnum _$characterIdEnum_heinrich =
    const CharacterIdEnum._('heinrich');
const CharacterIdEnum _$characterIdEnum_mateo =
    const CharacterIdEnum._('mateo');
const CharacterIdEnum _$characterIdEnum_arjun =
    const CharacterIdEnum._('arjun');
const CharacterIdEnum _$characterIdEnum_robin =
    const CharacterIdEnum._('robin');
const CharacterIdEnum _$characterIdEnum_nia = const CharacterIdEnum._('nia');
const CharacterIdEnum _$characterIdEnum_kai = const CharacterIdEnum._('kai');

CharacterIdEnum _$characterIdEnumValueOf(String name) {
  switch (name) {
    case 'amara':
      return _$characterIdEnum_amara;
    case 'mei':
      return _$characterIdEnum_mei;
    case 'samira':
      return _$characterIdEnum_samira;
    case 'heinrich':
      return _$characterIdEnum_heinrich;
    case 'mateo':
      return _$characterIdEnum_mateo;
    case 'arjun':
      return _$characterIdEnum_arjun;
    case 'robin':
      return _$characterIdEnum_robin;
    case 'nia':
      return _$characterIdEnum_nia;
    case 'kai':
      return _$characterIdEnum_kai;
    default:
      throw ArgumentError(name);
  }
}

final BuiltSet<CharacterIdEnum> _$characterIdEnumValues =
    BuiltSet<CharacterIdEnum>(const <CharacterIdEnum>[
  _$characterIdEnum_amara,
  _$characterIdEnum_mei,
  _$characterIdEnum_samira,
  _$characterIdEnum_heinrich,
  _$characterIdEnum_mateo,
  _$characterIdEnum_arjun,
  _$characterIdEnum_robin,
  _$characterIdEnum_nia,
  _$characterIdEnum_kai,
]);

Serializer<CharacterVEnum> _$characterVEnumSerializer =
    _$CharacterVEnumSerializer();
Serializer<CharacterIdEnum> _$characterIdEnumSerializer =
    _$CharacterIdEnumSerializer();

class _$CharacterVEnumSerializer
    implements PrimitiveSerializer<CharacterVEnum> {
  static const Map<String, Object> _toWire = const <String, Object>{
    'number2': 2,
  };
  static const Map<Object, String> _fromWire = const <Object, String>{
    2: 'number2',
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

class _$CharacterIdEnumSerializer
    implements PrimitiveSerializer<CharacterIdEnum> {
  static const Map<String, Object> _toWire = const <String, Object>{
    'amara': 'amara',
    'mei': 'mei',
    'samira': 'samira',
    'heinrich': 'heinrich',
    'mateo': 'mateo',
    'arjun': 'arjun',
    'robin': 'robin',
    'nia': 'nia',
    'kai': 'kai',
  };
  static const Map<Object, String> _fromWire = const <Object, String>{
    'amara': 'amara',
    'mei': 'mei',
    'samira': 'samira',
    'heinrich': 'heinrich',
    'mateo': 'mateo',
    'arjun': 'arjun',
    'robin': 'robin',
    'nia': 'nia',
    'kai': 'kai',
  };

  @override
  final Iterable<Type> types = const <Type>[CharacterIdEnum];
  @override
  final String wireName = 'CharacterIdEnum';

  @override
  Object serialize(Serializers serializers, CharacterIdEnum object,
          {FullType specifiedType = FullType.unspecified}) =>
      _toWire[object.name] ?? object.name;

  @override
  CharacterIdEnum deserialize(Serializers serializers, Object serialized,
          {FullType specifiedType = FullType.unspecified}) =>
      CharacterIdEnum.valueOf(
          _fromWire[serialized] ?? (serialized is String ? serialized : ''));
}

class _$Character extends Character {
  @override
  final CharacterVEnum v;
  @override
  final CharacterIdEnum id;

  factory _$Character([void Function(CharacterBuilder)? updates]) =>
      (CharacterBuilder()..update(updates))._build();

  _$Character._({required this.v, required this.id}) : super._();
  @override
  Character rebuild(void Function(CharacterBuilder) updates) =>
      (toBuilder()..update(updates)).build();

  @override
  CharacterBuilder toBuilder() => CharacterBuilder()..replace(this);

  @override
  bool operator ==(Object other) {
    if (identical(other, this)) return true;
    return other is Character && v == other.v && id == other.id;
  }

  @override
  int get hashCode {
    var _$hash = 0;
    _$hash = $jc(_$hash, v.hashCode);
    _$hash = $jc(_$hash, id.hashCode);
    _$hash = $jf(_$hash);
    return _$hash;
  }

  @override
  String toString() {
    return (newBuiltValueToStringHelper(r'Character')
          ..add('v', v)
          ..add('id', id))
        .toString();
  }
}

class CharacterBuilder implements Builder<Character, CharacterBuilder> {
  _$Character? _$v;

  CharacterVEnum? _v;
  CharacterVEnum? get v => _$this._v;
  set v(CharacterVEnum? v) => _$this._v = v;

  CharacterIdEnum? _id;
  CharacterIdEnum? get id => _$this._id;
  set id(CharacterIdEnum? id) => _$this._id = id;

  CharacterBuilder() {
    Character._defaults(this);
  }

  CharacterBuilder get _$this {
    final $v = _$v;
    if ($v != null) {
      _v = $v.v;
      _id = $v.id;
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
    final _$result = _$v ??
        _$Character._(
          v: BuiltValueNullFieldError.checkNotNull(v, r'Character', 'v'),
          id: BuiltValueNullFieldError.checkNotNull(id, r'Character', 'id'),
        );
    replace(_$result);
    return _$result;
  }
}

// ignore_for_file: deprecated_member_use_from_same_package,type=lint
