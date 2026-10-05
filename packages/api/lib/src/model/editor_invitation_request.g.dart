// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'editor_invitation_request.dart';

// **************************************************************************
// BuiltValueGenerator
// **************************************************************************

const EditorInvitationRequestRoleEnum
    _$editorInvitationRequestRoleEnum_inhaltsredaktion =
    const EditorInvitationRequestRoleEnum._('inhaltsredaktion');
const EditorInvitationRequestRoleEnum
    _$editorInvitationRequestRoleEnum_botanischesReview =
    const EditorInvitationRequestRoleEnum._('botanischesReview');
const EditorInvitationRequestRoleEnum
    _$editorInvitationRequestRoleEnum_lehrende =
    const EditorInvitationRequestRoleEnum._('lehrende');

EditorInvitationRequestRoleEnum _$editorInvitationRequestRoleEnumValueOf(
    String name) {
  switch (name) {
    case 'inhaltsredaktion':
      return _$editorInvitationRequestRoleEnum_inhaltsredaktion;
    case 'botanischesReview':
      return _$editorInvitationRequestRoleEnum_botanischesReview;
    case 'lehrende':
      return _$editorInvitationRequestRoleEnum_lehrende;
    default:
      throw ArgumentError(name);
  }
}

final BuiltSet<EditorInvitationRequestRoleEnum>
    _$editorInvitationRequestRoleEnumValues = BuiltSet<
        EditorInvitationRequestRoleEnum>(const <EditorInvitationRequestRoleEnum>[
  _$editorInvitationRequestRoleEnum_inhaltsredaktion,
  _$editorInvitationRequestRoleEnum_botanischesReview,
  _$editorInvitationRequestRoleEnum_lehrende,
]);

Serializer<EditorInvitationRequestRoleEnum>
    _$editorInvitationRequestRoleEnumSerializer =
    _$EditorInvitationRequestRoleEnumSerializer();

class _$EditorInvitationRequestRoleEnumSerializer
    implements PrimitiveSerializer<EditorInvitationRequestRoleEnum> {
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
  final Iterable<Type> types = const <Type>[EditorInvitationRequestRoleEnum];
  @override
  final String wireName = 'EditorInvitationRequestRoleEnum';

  @override
  Object serialize(
          Serializers serializers, EditorInvitationRequestRoleEnum object,
          {FullType specifiedType = FullType.unspecified}) =>
      _toWire[object.name] ?? object.name;

  @override
  EditorInvitationRequestRoleEnum deserialize(
          Serializers serializers, Object serialized,
          {FullType specifiedType = FullType.unspecified}) =>
      EditorInvitationRequestRoleEnum.valueOf(
          _fromWire[serialized] ?? (serialized is String ? serialized : ''));
}

class _$EditorInvitationRequest extends EditorInvitationRequest {
  @override
  final String email;
  @override
  final EditorInvitationRequestRoleEnum? role;

  factory _$EditorInvitationRequest(
          [void Function(EditorInvitationRequestBuilder)? updates]) =>
      (EditorInvitationRequestBuilder()..update(updates))._build();

  _$EditorInvitationRequest._({required this.email, this.role}) : super._();
  @override
  EditorInvitationRequest rebuild(
          void Function(EditorInvitationRequestBuilder) updates) =>
      (toBuilder()..update(updates)).build();

  @override
  EditorInvitationRequestBuilder toBuilder() =>
      EditorInvitationRequestBuilder()..replace(this);

  @override
  bool operator ==(Object other) {
    if (identical(other, this)) return true;
    return other is EditorInvitationRequest &&
        email == other.email &&
        role == other.role;
  }

  @override
  int get hashCode {
    var _$hash = 0;
    _$hash = $jc(_$hash, email.hashCode);
    _$hash = $jc(_$hash, role.hashCode);
    _$hash = $jf(_$hash);
    return _$hash;
  }

  @override
  String toString() {
    return (newBuiltValueToStringHelper(r'EditorInvitationRequest')
          ..add('email', email)
          ..add('role', role))
        .toString();
  }
}

class EditorInvitationRequestBuilder
    implements
        Builder<EditorInvitationRequest, EditorInvitationRequestBuilder> {
  _$EditorInvitationRequest? _$v;

  String? _email;
  String? get email => _$this._email;
  set email(String? email) => _$this._email = email;

  EditorInvitationRequestRoleEnum? _role;
  EditorInvitationRequestRoleEnum? get role => _$this._role;
  set role(EditorInvitationRequestRoleEnum? role) => _$this._role = role;

  EditorInvitationRequestBuilder() {
    EditorInvitationRequest._defaults(this);
  }

  EditorInvitationRequestBuilder get _$this {
    final $v = _$v;
    if ($v != null) {
      _email = $v.email;
      _role = $v.role;
      _$v = null;
    }
    return this;
  }

  @override
  void replace(EditorInvitationRequest other) {
    _$v = other as _$EditorInvitationRequest;
  }

  @override
  void update(void Function(EditorInvitationRequestBuilder)? updates) {
    if (updates != null) updates(this);
  }

  @override
  EditorInvitationRequest build() => _build();

  _$EditorInvitationRequest _build() {
    final _$result = _$v ??
        _$EditorInvitationRequest._(
          email: BuiltValueNullFieldError.checkNotNull(
              email, r'EditorInvitationRequest', 'email'),
          role: role,
        );
    replace(_$result);
    return _$result;
  }
}

// ignore_for_file: deprecated_member_use_from_same_package,type=lint
