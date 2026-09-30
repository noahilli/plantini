// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'user_profile.dart';

// **************************************************************************
// BuiltValueGenerator
// **************************************************************************

const UserProfileRolesEnum _$userProfileRolesEnum_lernende =
    const UserProfileRolesEnum._('lernende');
const UserProfileRolesEnum _$userProfileRolesEnum_lehrende =
    const UserProfileRolesEnum._('lehrende');
const UserProfileRolesEnum _$userProfileRolesEnum_inhaltsredaktion =
    const UserProfileRolesEnum._('inhaltsredaktion');
const UserProfileRolesEnum _$userProfileRolesEnum_botanischesReview =
    const UserProfileRolesEnum._('botanischesReview');
const UserProfileRolesEnum _$userProfileRolesEnum_organisationsadministration =
    const UserProfileRolesEnum._('organisationsadministration');
const UserProfileRolesEnum _$userProfileRolesEnum_systemadministration =
    const UserProfileRolesEnum._('systemadministration');

UserProfileRolesEnum _$userProfileRolesEnumValueOf(String name) {
  switch (name) {
    case 'lernende':
      return _$userProfileRolesEnum_lernende;
    case 'lehrende':
      return _$userProfileRolesEnum_lehrende;
    case 'inhaltsredaktion':
      return _$userProfileRolesEnum_inhaltsredaktion;
    case 'botanischesReview':
      return _$userProfileRolesEnum_botanischesReview;
    case 'organisationsadministration':
      return _$userProfileRolesEnum_organisationsadministration;
    case 'systemadministration':
      return _$userProfileRolesEnum_systemadministration;
    default:
      throw ArgumentError(name);
  }
}

final BuiltSet<UserProfileRolesEnum> _$userProfileRolesEnumValues =
    BuiltSet<UserProfileRolesEnum>(const <UserProfileRolesEnum>[
  _$userProfileRolesEnum_lernende,
  _$userProfileRolesEnum_lehrende,
  _$userProfileRolesEnum_inhaltsredaktion,
  _$userProfileRolesEnum_botanischesReview,
  _$userProfileRolesEnum_organisationsadministration,
  _$userProfileRolesEnum_systemadministration,
]);

Serializer<UserProfileRolesEnum> _$userProfileRolesEnumSerializer =
    _$UserProfileRolesEnumSerializer();

class _$UserProfileRolesEnumSerializer
    implements PrimitiveSerializer<UserProfileRolesEnum> {
  static const Map<String, Object> _toWire = const <String, Object>{
    'lernende': 'lernende',
    'lehrende': 'lehrende',
    'inhaltsredaktion': 'inhaltsredaktion',
    'botanischesReview': 'botanisches_review',
    'organisationsadministration': 'organisationsadministration',
    'systemadministration': 'systemadministration',
  };
  static const Map<Object, String> _fromWire = const <Object, String>{
    'lernende': 'lernende',
    'lehrende': 'lehrende',
    'inhaltsredaktion': 'inhaltsredaktion',
    'botanisches_review': 'botanischesReview',
    'organisationsadministration': 'organisationsadministration',
    'systemadministration': 'systemadministration',
  };

  @override
  final Iterable<Type> types = const <Type>[UserProfileRolesEnum];
  @override
  final String wireName = 'UserProfileRolesEnum';

  @override
  Object serialize(Serializers serializers, UserProfileRolesEnum object,
          {FullType specifiedType = FullType.unspecified}) =>
      _toWire[object.name] ?? object.name;

  @override
  UserProfileRolesEnum deserialize(Serializers serializers, Object serialized,
          {FullType specifiedType = FullType.unspecified}) =>
      UserProfileRolesEnum.valueOf(
          _fromWire[serialized] ?? (serialized is String ? serialized : ''));
}

class _$UserProfile extends UserProfile {
  @override
  final String id;
  @override
  final String displayName;
  @override
  final String locale;
  @override
  final BuiltList<UserProfileRolesEnum> roles;
  @override
  final String? organisationId;
  @override
  final Character? character;

  factory _$UserProfile([void Function(UserProfileBuilder)? updates]) =>
      (UserProfileBuilder()..update(updates))._build();

  _$UserProfile._(
      {required this.id,
      required this.displayName,
      required this.locale,
      required this.roles,
      this.organisationId,
      this.character})
      : super._();
  @override
  UserProfile rebuild(void Function(UserProfileBuilder) updates) =>
      (toBuilder()..update(updates)).build();

  @override
  UserProfileBuilder toBuilder() => UserProfileBuilder()..replace(this);

  @override
  bool operator ==(Object other) {
    if (identical(other, this)) return true;
    return other is UserProfile &&
        id == other.id &&
        displayName == other.displayName &&
        locale == other.locale &&
        roles == other.roles &&
        organisationId == other.organisationId &&
        character == other.character;
  }

  @override
  int get hashCode {
    var _$hash = 0;
    _$hash = $jc(_$hash, id.hashCode);
    _$hash = $jc(_$hash, displayName.hashCode);
    _$hash = $jc(_$hash, locale.hashCode);
    _$hash = $jc(_$hash, roles.hashCode);
    _$hash = $jc(_$hash, organisationId.hashCode);
    _$hash = $jc(_$hash, character.hashCode);
    _$hash = $jf(_$hash);
    return _$hash;
  }

  @override
  String toString() {
    return (newBuiltValueToStringHelper(r'UserProfile')
          ..add('id', id)
          ..add('displayName', displayName)
          ..add('locale', locale)
          ..add('roles', roles)
          ..add('organisationId', organisationId)
          ..add('character', character))
        .toString();
  }
}

class UserProfileBuilder implements Builder<UserProfile, UserProfileBuilder> {
  _$UserProfile? _$v;

  String? _id;
  String? get id => _$this._id;
  set id(String? id) => _$this._id = id;

  String? _displayName;
  String? get displayName => _$this._displayName;
  set displayName(String? displayName) => _$this._displayName = displayName;

  String? _locale;
  String? get locale => _$this._locale;
  set locale(String? locale) => _$this._locale = locale;

  ListBuilder<UserProfileRolesEnum>? _roles;
  ListBuilder<UserProfileRolesEnum> get roles =>
      _$this._roles ??= ListBuilder<UserProfileRolesEnum>();
  set roles(ListBuilder<UserProfileRolesEnum>? roles) => _$this._roles = roles;

  String? _organisationId;
  String? get organisationId => _$this._organisationId;
  set organisationId(String? organisationId) =>
      _$this._organisationId = organisationId;

  CharacterBuilder? _character;
  CharacterBuilder get character => _$this._character ??= CharacterBuilder();
  set character(CharacterBuilder? character) => _$this._character = character;

  UserProfileBuilder() {
    UserProfile._defaults(this);
  }

  UserProfileBuilder get _$this {
    final $v = _$v;
    if ($v != null) {
      _id = $v.id;
      _displayName = $v.displayName;
      _locale = $v.locale;
      _roles = $v.roles.toBuilder();
      _organisationId = $v.organisationId;
      _character = $v.character?.toBuilder();
      _$v = null;
    }
    return this;
  }

  @override
  void replace(UserProfile other) {
    _$v = other as _$UserProfile;
  }

  @override
  void update(void Function(UserProfileBuilder)? updates) {
    if (updates != null) updates(this);
  }

  @override
  UserProfile build() => _build();

  _$UserProfile _build() {
    _$UserProfile _$result;
    try {
      _$result = _$v ??
          _$UserProfile._(
            id: BuiltValueNullFieldError.checkNotNull(id, r'UserProfile', 'id'),
            displayName: BuiltValueNullFieldError.checkNotNull(
                displayName, r'UserProfile', 'displayName'),
            locale: BuiltValueNullFieldError.checkNotNull(
                locale, r'UserProfile', 'locale'),
            roles: roles.build(),
            organisationId: organisationId,
            character: _character?.build(),
          );
    } catch (_) {
      late String _$failedField;
      try {
        _$failedField = 'roles';
        roles.build();

        _$failedField = 'character';
        _character?.build();
      } catch (e) {
        throw BuiltValueNestedFieldError(
            r'UserProfile', _$failedField, e.toString());
      }
      rethrow;
    }
    replace(_$result);
    return _$result;
  }
}

// ignore_for_file: deprecated_member_use_from_same_package,type=lint
