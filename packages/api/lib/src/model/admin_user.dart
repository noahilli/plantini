//
// AUTO-GENERATED FILE, DO NOT MODIFY!
//

// ignore_for_file: unused_element
import 'package:built_collection/built_collection.dart';
import 'package:built_value/built_value.dart';
import 'package:built_value/serializer.dart';

part 'admin_user.g.dart';

/// AdminUser
///
/// Properties:
/// * [id]
/// * [status]
/// * [roles]
/// * [organisationId]
@BuiltValue()
abstract class AdminUser implements Built<AdminUser, AdminUserBuilder> {
  @BuiltValueField(wireName: r'id')
  String get id;

  @BuiltValueField(wireName: r'status')
  AdminUserStatusEnum get status;
  // enum statusEnum {  active,  suspended,  };

  @BuiltValueField(wireName: r'roles')
  BuiltList<String> get roles;

  @BuiltValueField(wireName: r'organisationId')
  String? get organisationId;

  AdminUser._();

  factory AdminUser([void updates(AdminUserBuilder b)]) = _$AdminUser;

  @BuiltValueHook(initializeBuilder: true)
  static void _defaults(AdminUserBuilder b) => b;

  @BuiltValueSerializer(custom: true)
  static Serializer<AdminUser> get serializer => _$AdminUserSerializer();
}

class _$AdminUserSerializer implements PrimitiveSerializer<AdminUser> {
  @override
  final Iterable<Type> types = const [AdminUser, _$AdminUser];

  @override
  final String wireName = r'AdminUser';

  Iterable<Object?> _serializeProperties(
    Serializers serializers,
    AdminUser object, {
    FullType specifiedType = FullType.unspecified,
  }) sync* {
    yield r'id';
    yield serializers.serialize(
      object.id,
      specifiedType: const FullType(String),
    );
    yield r'status';
    yield serializers.serialize(
      object.status,
      specifiedType: const FullType(AdminUserStatusEnum),
    );
    yield r'roles';
    yield serializers.serialize(
      object.roles,
      specifiedType: const FullType(BuiltList, [FullType(String)]),
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
    AdminUser object, {
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
    required AdminUserBuilder result,
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
        case r'status':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType(AdminUserStatusEnum),
          ) as AdminUserStatusEnum;
          result.status = valueDes;
          break;
        case r'roles':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType(BuiltList, [FullType(String)]),
          ) as BuiltList<String>;
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
  AdminUser deserialize(
    Serializers serializers,
    Object serialized, {
    FullType specifiedType = FullType.unspecified,
  }) {
    final result = AdminUserBuilder();
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

class AdminUserStatusEnum extends EnumClass {
  @BuiltValueEnumConst(wireName: r'active')
  static const AdminUserStatusEnum active = _$adminUserStatusEnum_active;
  @BuiltValueEnumConst(wireName: r'suspended')
  static const AdminUserStatusEnum suspended = _$adminUserStatusEnum_suspended;

  static Serializer<AdminUserStatusEnum> get serializer =>
      _$adminUserStatusEnumSerializer;

  const AdminUserStatusEnum._(String name) : super(name);

  static BuiltSet<AdminUserStatusEnum> get values =>
      _$adminUserStatusEnumValues;
  static AdminUserStatusEnum valueOf(String name) =>
      _$adminUserStatusEnumValueOf(name);
}
