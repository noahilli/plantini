// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'admin_user.dart';

// **************************************************************************
// BuiltValueGenerator
// **************************************************************************

const AdminUserStatusEnum _$adminUserStatusEnum_active =
    const AdminUserStatusEnum._('active');
const AdminUserStatusEnum _$adminUserStatusEnum_suspended =
    const AdminUserStatusEnum._('suspended');

AdminUserStatusEnum _$adminUserStatusEnumValueOf(String name) {
  switch (name) {
    case 'active':
      return _$adminUserStatusEnum_active;
    case 'suspended':
      return _$adminUserStatusEnum_suspended;
    default:
      throw ArgumentError(name);
  }
}

final BuiltSet<AdminUserStatusEnum> _$adminUserStatusEnumValues =
    BuiltSet<AdminUserStatusEnum>(const <AdminUserStatusEnum>[
  _$adminUserStatusEnum_active,
  _$adminUserStatusEnum_suspended,
]);

Serializer<AdminUserStatusEnum> _$adminUserStatusEnumSerializer =
    _$AdminUserStatusEnumSerializer();

class _$AdminUserStatusEnumSerializer
    implements PrimitiveSerializer<AdminUserStatusEnum> {
  static const Map<String, Object> _toWire = const <String, Object>{
    'active': 'active',
    'suspended': 'suspended',
  };
  static const Map<Object, String> _fromWire = const <Object, String>{
    'active': 'active',
    'suspended': 'suspended',
  };

  @override
  final Iterable<Type> types = const <Type>[AdminUserStatusEnum];
  @override
  final String wireName = 'AdminUserStatusEnum';

  @override
  Object serialize(Serializers serializers, AdminUserStatusEnum object,
          {FullType specifiedType = FullType.unspecified}) =>
      _toWire[object.name] ?? object.name;

  @override
  AdminUserStatusEnum deserialize(Serializers serializers, Object serialized,
          {FullType specifiedType = FullType.unspecified}) =>
      AdminUserStatusEnum.valueOf(
          _fromWire[serialized] ?? (serialized is String ? serialized : ''));
}

class _$AdminUser extends AdminUser {
  @override
  final String id;
  @override
  final AdminUserStatusEnum status;
  @override
  final BuiltList<String> roles;
  @override
  final String? organisationId;

  factory _$AdminUser([void Function(AdminUserBuilder)? updates]) =>
      (AdminUserBuilder()..update(updates))._build();

  _$AdminUser._(
      {required this.id,
      required this.status,
      required this.roles,
      this.organisationId})
      : super._();
  @override
  AdminUser rebuild(void Function(AdminUserBuilder) updates) =>
      (toBuilder()..update(updates)).build();

  @override
  AdminUserBuilder toBuilder() => AdminUserBuilder()..replace(this);

  @override
  bool operator ==(Object other) {
    if (identical(other, this)) return true;
    return other is AdminUser &&
        id == other.id &&
        status == other.status &&
        roles == other.roles &&
        organisationId == other.organisationId;
  }

  @override
  int get hashCode {
    var _$hash = 0;
    _$hash = $jc(_$hash, id.hashCode);
    _$hash = $jc(_$hash, status.hashCode);
    _$hash = $jc(_$hash, roles.hashCode);
    _$hash = $jc(_$hash, organisationId.hashCode);
    _$hash = $jf(_$hash);
    return _$hash;
  }

  @override
  String toString() {
    return (newBuiltValueToStringHelper(r'AdminUser')
          ..add('id', id)
          ..add('status', status)
          ..add('roles', roles)
          ..add('organisationId', organisationId))
        .toString();
  }
}

class AdminUserBuilder implements Builder<AdminUser, AdminUserBuilder> {
  _$AdminUser? _$v;

  String? _id;
  String? get id => _$this._id;
  set id(String? id) => _$this._id = id;

  AdminUserStatusEnum? _status;
  AdminUserStatusEnum? get status => _$this._status;
  set status(AdminUserStatusEnum? status) => _$this._status = status;

  ListBuilder<String>? _roles;
  ListBuilder<String> get roles => _$this._roles ??= ListBuilder<String>();
  set roles(ListBuilder<String>? roles) => _$this._roles = roles;

  String? _organisationId;
  String? get organisationId => _$this._organisationId;
  set organisationId(String? organisationId) =>
      _$this._organisationId = organisationId;

  AdminUserBuilder() {
    AdminUser._defaults(this);
  }

  AdminUserBuilder get _$this {
    final $v = _$v;
    if ($v != null) {
      _id = $v.id;
      _status = $v.status;
      _roles = $v.roles.toBuilder();
      _organisationId = $v.organisationId;
      _$v = null;
    }
    return this;
  }

  @override
  void replace(AdminUser other) {
    _$v = other as _$AdminUser;
  }

  @override
  void update(void Function(AdminUserBuilder)? updates) {
    if (updates != null) updates(this);
  }

  @override
  AdminUser build() => _build();

  _$AdminUser _build() {
    _$AdminUser _$result;
    try {
      _$result = _$v ??
          _$AdminUser._(
            id: BuiltValueNullFieldError.checkNotNull(id, r'AdminUser', 'id'),
            status: BuiltValueNullFieldError.checkNotNull(
                status, r'AdminUser', 'status'),
            roles: roles.build(),
            organisationId: organisationId,
          );
    } catch (_) {
      late String _$failedField;
      try {
        _$failedField = 'roles';
        roles.build();
      } catch (e) {
        throw BuiltValueNestedFieldError(
            r'AdminUser', _$failedField, e.toString());
      }
      rethrow;
    }
    replace(_$result);
    return _$result;
  }
}

// ignore_for_file: deprecated_member_use_from_same_package,type=lint
