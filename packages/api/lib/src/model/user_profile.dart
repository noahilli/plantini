//
// AUTO-GENERATED FILE, DO NOT MODIFY!
//

// ignore_for_file: unused_element
import 'package:built_collection/built_collection.dart';
import 'package:built_value/built_value.dart';
import 'package:built_value/serializer.dart';

part 'user_profile.g.dart';

/// UserProfile
///
/// Properties:
/// * [id]
/// * [displayName]
/// * [locale]
/// * [roles]
/// * [organisationId]
@BuiltValue()
abstract class UserProfile implements Built<UserProfile, UserProfileBuilder> {
  @BuiltValueField(wireName: r'id')
  String get id;

  @BuiltValueField(wireName: r'displayName')
  String get displayName;

  @BuiltValueField(wireName: r'locale')
  String get locale;

  @BuiltValueField(wireName: r'roles')
  BuiltList<UserProfileRolesEnum> get roles;
  // enum rolesEnum {  lernende,  lehrende,  inhaltsredaktion,  botanisches_review,  organisationsadministration,  systemadministration,  };

  @BuiltValueField(wireName: r'organisationId')
  String? get organisationId;

  UserProfile._();

  factory UserProfile([void updates(UserProfileBuilder b)]) = _$UserProfile;

  @BuiltValueHook(initializeBuilder: true)
  static void _defaults(UserProfileBuilder b) => b;

  @BuiltValueSerializer(custom: true)
  static Serializer<UserProfile> get serializer => _$UserProfileSerializer();
}

class _$UserProfileSerializer implements PrimitiveSerializer<UserProfile> {
  @override
  final Iterable<Type> types = const [UserProfile, _$UserProfile];

  @override
  final String wireName = r'UserProfile';

  Iterable<Object?> _serializeProperties(
    Serializers serializers,
    UserProfile object, {
    FullType specifiedType = FullType.unspecified,
  }) sync* {
    yield r'id';
    yield serializers.serialize(
      object.id,
      specifiedType: const FullType(String),
    );
    yield r'displayName';
    yield serializers.serialize(
      object.displayName,
      specifiedType: const FullType(String),
    );
    yield r'locale';
    yield serializers.serialize(
      object.locale,
      specifiedType: const FullType(String),
    );
    yield r'roles';
    yield serializers.serialize(
      object.roles,
      specifiedType:
          const FullType(BuiltList, [FullType(UserProfileRolesEnum)]),
    );
    if (object.organisationId != null) {
      yield r'organisationId';
      yield serializers.serialize(
        object.organisationId,
        specifiedType: const FullType(String),
      );
    }
  }

  @override
  Object serialize(
    Serializers serializers,
    UserProfile object, {
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
    required UserProfileBuilder result,
    required List<Object?> unhandled,
  }) {
    for (var i = 0; i < serializedList.length; i += 2) {
      final key = serializedList[i] as String;
      final value = serializedList[i + 1];
      switch (key) {
        case r'id':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType(String),
          ) as String;
          result.id = valueDes;
          break;
        case r'displayName':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType(String),
          ) as String;
          result.displayName = valueDes;
          break;
        case r'locale':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType(String),
          ) as String;
          result.locale = valueDes;
          break;
        case r'roles':
          final valueDes = serializers.deserialize(
            value,
            specifiedType:
                const FullType(BuiltList, [FullType(UserProfileRolesEnum)]),
          ) as BuiltList<UserProfileRolesEnum>;
          result.roles.replace(valueDes);
          break;
        case r'organisationId':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType.nullable(String),
          ) as String?;
          if (valueDes == null) continue;
          result.organisationId = valueDes;
          break;
        default:
          unhandled.add(key);
          unhandled.add(value);
          break;
      }
    }
  }

  @override
  UserProfile deserialize(
    Serializers serializers,
    Object serialized, {
    FullType specifiedType = FullType.unspecified,
  }) {
    final result = UserProfileBuilder();
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

class UserProfileRolesEnum extends EnumClass {
  @BuiltValueEnumConst(wireName: r'lernende')
  static const UserProfileRolesEnum lernende = _$userProfileRolesEnum_lernende;
  @BuiltValueEnumConst(wireName: r'lehrende')
  static const UserProfileRolesEnum lehrende = _$userProfileRolesEnum_lehrende;
  @BuiltValueEnumConst(wireName: r'inhaltsredaktion')
  static const UserProfileRolesEnum inhaltsredaktion =
      _$userProfileRolesEnum_inhaltsredaktion;
  @BuiltValueEnumConst(wireName: r'botanisches_review')
  static const UserProfileRolesEnum botanischesReview =
      _$userProfileRolesEnum_botanischesReview;
  @BuiltValueEnumConst(wireName: r'organisationsadministration')
  static const UserProfileRolesEnum organisationsadministration =
      _$userProfileRolesEnum_organisationsadministration;
  @BuiltValueEnumConst(wireName: r'systemadministration')
  static const UserProfileRolesEnum systemadministration =
      _$userProfileRolesEnum_systemadministration;

  static Serializer<UserProfileRolesEnum> get serializer =>
      _$userProfileRolesEnumSerializer;

  const UserProfileRolesEnum._(String name) : super(name);

  static BuiltSet<UserProfileRolesEnum> get values =>
      _$userProfileRolesEnumValues;
  static UserProfileRolesEnum valueOf(String name) =>
      _$userProfileRolesEnumValueOf(name);
}
