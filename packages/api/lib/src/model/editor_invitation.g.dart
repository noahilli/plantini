// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'editor_invitation.dart';

// **************************************************************************
// BuiltValueGenerator
// **************************************************************************

const EditorInvitationRoleEnum _$editorInvitationRoleEnum_inhaltsredaktion =
    const EditorInvitationRoleEnum._('inhaltsredaktion');
const EditorInvitationRoleEnum _$editorInvitationRoleEnum_botanischesReview =
    const EditorInvitationRoleEnum._('botanischesReview');
const EditorInvitationRoleEnum _$editorInvitationRoleEnum_lehrende =
    const EditorInvitationRoleEnum._('lehrende');

EditorInvitationRoleEnum _$editorInvitationRoleEnumValueOf(String name) {
  switch (name) {
    case 'inhaltsredaktion':
      return _$editorInvitationRoleEnum_inhaltsredaktion;
    case 'botanischesReview':
      return _$editorInvitationRoleEnum_botanischesReview;
    case 'lehrende':
      return _$editorInvitationRoleEnum_lehrende;
    default:
      throw ArgumentError(name);
  }
}

final BuiltSet<EditorInvitationRoleEnum> _$editorInvitationRoleEnumValues =
    BuiltSet<EditorInvitationRoleEnum>(const <EditorInvitationRoleEnum>[
  _$editorInvitationRoleEnum_inhaltsredaktion,
  _$editorInvitationRoleEnum_botanischesReview,
  _$editorInvitationRoleEnum_lehrende,
]);

const EditorInvitationStatusEnum _$editorInvitationStatusEnum_invited =
    const EditorInvitationStatusEnum._('invited');

EditorInvitationStatusEnum _$editorInvitationStatusEnumValueOf(String name) {
  switch (name) {
    case 'invited':
      return _$editorInvitationStatusEnum_invited;
    default:
      throw ArgumentError(name);
  }
}

final BuiltSet<EditorInvitationStatusEnum> _$editorInvitationStatusEnumValues =
    BuiltSet<EditorInvitationStatusEnum>(const <EditorInvitationStatusEnum>[
  _$editorInvitationStatusEnum_invited,
]);

Serializer<EditorInvitationRoleEnum> _$editorInvitationRoleEnumSerializer =
    _$EditorInvitationRoleEnumSerializer();
Serializer<EditorInvitationStatusEnum> _$editorInvitationStatusEnumSerializer =
    _$EditorInvitationStatusEnumSerializer();

class _$EditorInvitationRoleEnumSerializer
    implements PrimitiveSerializer<EditorInvitationRoleEnum> {
  static const Map<String, Object> _toWire = const <String, Object>{
    'inhaltsredaktion': 'inhaltsredaktion',
    'botanischesReview': 'botanisches_review',
    'lehrende': 'lehrende',
  };
  static const Map<Object, String> _fromWire = const <Object, String>{
    'inhaltsredaktion': 'inhaltsredaktion',
    'botanisches_review': 'botanischesReview',
    'lehrende': 'lehrende',
  };

  @override
  final Iterable<Type> types = const <Type>[EditorInvitationRoleEnum];
  @override
  final String wireName = 'EditorInvitationRoleEnum';

  @override
  Object serialize(Serializers serializers, EditorInvitationRoleEnum object,
          {FullType specifiedType = FullType.unspecified}) =>
      _toWire[object.name] ?? object.name;

  @override
  EditorInvitationRoleEnum deserialize(
          Serializers serializers, Object serialized,
          {FullType specifiedType = FullType.unspecified}) =>
      EditorInvitationRoleEnum.valueOf(
          _fromWire[serialized] ?? (serialized is String ? serialized : ''));
}

class _$EditorInvitationStatusEnumSerializer
    implements PrimitiveSerializer<EditorInvitationStatusEnum> {
  static const Map<String, Object> _toWire = const <String, Object>{
    'invited': 'invited',
  };
  static const Map<Object, String> _fromWire = const <Object, String>{
    'invited': 'invited',
  };

  @override
  final Iterable<Type> types = const <Type>[EditorInvitationStatusEnum];
  @override
  final String wireName = 'EditorInvitationStatusEnum';

  @override
  Object serialize(Serializers serializers, EditorInvitationStatusEnum object,
          {FullType specifiedType = FullType.unspecified}) =>
      _toWire[object.name] ?? object.name;

  @override
  EditorInvitationStatusEnum deserialize(
          Serializers serializers, Object serialized,
          {FullType specifiedType = FullType.unspecified}) =>
      EditorInvitationStatusEnum.valueOf(
          _fromWire[serialized] ?? (serialized is String ? serialized : ''));
}

class _$EditorInvitation extends EditorInvitation {
  @override
  final String email;
  @override
  final EditorInvitationRoleEnum role;
  @override
  final EditorInvitationStatusEnum status;

  factory _$EditorInvitation(
          [void Function(EditorInvitationBuilder)? updates]) =>
      (EditorInvitationBuilder()..update(updates))._build();

  _$EditorInvitation._(
      {required this.email, required this.role, required this.status})
      : super._();
  @override
  EditorInvitation rebuild(void Function(EditorInvitationBuilder) updates) =>
      (toBuilder()..update(updates)).build();

  @override
  EditorInvitationBuilder toBuilder() =>
      EditorInvitationBuilder()..replace(this);

  @override
  bool operator ==(Object other) {
    if (identical(other, this)) return true;
    return other is EditorInvitation &&
        email == other.email &&
        role == other.role &&
        status == other.status;
  }

  @override
  int get hashCode {
    var _$hash = 0;
    _$hash = $jc(_$hash, email.hashCode);
    _$hash = $jc(_$hash, role.hashCode);
    _$hash = $jc(_$hash, status.hashCode);
    _$hash = $jf(_$hash);
    return _$hash;
  }

  @override
  String toString() {
    return (newBuiltValueToStringHelper(r'EditorInvitation')
          ..add('email', email)
          ..add('role', role)
          ..add('status', status))
        .toString();
  }
}

class EditorInvitationBuilder
    implements Builder<EditorInvitation, EditorInvitationBuilder> {
  _$EditorInvitation? _$v;

  String? _email;
  String? get email => _$this._email;
  set email(String? email) => _$this._email = email;

  EditorInvitationRoleEnum? _role;
  EditorInvitationRoleEnum? get role => _$this._role;
  set role(EditorInvitationRoleEnum? role) => _$this._role = role;

  EditorInvitationStatusEnum? _status;
  EditorInvitationStatusEnum? get status => _$this._status;
  set status(EditorInvitationStatusEnum? status) => _$this._status = status;

  EditorInvitationBuilder() {
    EditorInvitation._defaults(this);
  }

  EditorInvitationBuilder get _$this {
    final $v = _$v;
    if ($v != null) {
      _email = $v.email;
      _role = $v.role;
      _status = $v.status;
      _$v = null;
    }
    return this;
  }

  @override
  void replace(EditorInvitation other) {
    _$v = other as _$EditorInvitation;
  }

  @override
  void update(void Function(EditorInvitationBuilder)? updates) {
    if (updates != null) updates(this);
  }

  @override
  EditorInvitation build() => _build();

  _$EditorInvitation _build() {
    final _$result = _$v ??
        _$EditorInvitation._(
          email: BuiltValueNullFieldError.checkNotNull(
              email, r'EditorInvitation', 'email'),
          role: BuiltValueNullFieldError.checkNotNull(
              role, r'EditorInvitation', 'role'),
          status: BuiltValueNullFieldError.checkNotNull(
              status, r'EditorInvitation', 'status'),
        );
    replace(_$result);
    return _$result;
  }
}

// ignore_for_file: deprecated_member_use_from_same_package,type=lint
