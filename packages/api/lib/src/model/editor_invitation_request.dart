//
// AUTO-GENERATED FILE, DO NOT MODIFY!
//

// ignore_for_file: unused_element
import 'package:built_collection/built_collection.dart';
import 'package:built_value/built_value.dart';
import 'package:built_value/serializer.dart';

part 'editor_invitation_request.g.dart';

/// EditorInvitationRequest
///
/// Properties:
/// * [email]
/// * [role] - Only systemadministration may invite botanisches_review or lehrende. Teacher invitations redirect to the configured teacher portal.
@BuiltValue()
abstract class EditorInvitationRequest
    implements Built<EditorInvitationRequest, EditorInvitationRequestBuilder> {
  @BuiltValueField(wireName: r'email')
  String get email;

  /// Only systemadministration may invite botanisches_review or lehrende. Teacher invitations redirect to the configured teacher portal.
  @BuiltValueField(wireName: r'role')
  EditorInvitationRequestRoleEnum? get role;
  // enum roleEnum {  inhaltsredaktion,  botanisches_review,  lehrende,  };

  EditorInvitationRequest._();

  factory EditorInvitationRequest(
          [void updates(EditorInvitationRequestBuilder b)]) =
      _$EditorInvitationRequest;

  @BuiltValueHook(initializeBuilder: true)
  static void _defaults(EditorInvitationRequestBuilder b) =>
      b..role = EditorInvitationRequestRoleEnum.valueOf('inhaltsredaktion');

  @BuiltValueSerializer(custom: true)
  static Serializer<EditorInvitationRequest> get serializer =>
      _$EditorInvitationRequestSerializer();
}

class _$EditorInvitationRequestSerializer
    implements PrimitiveSerializer<EditorInvitationRequest> {
  @override
  final Iterable<Type> types = const [
    EditorInvitationRequest,
    _$EditorInvitationRequest
  ];

  @override
  final String wireName = r'EditorInvitationRequest';

  Iterable<Object?> _serializeProperties(
    Serializers serializers,
    EditorInvitationRequest object, {
    FullType specifiedType = FullType.unspecified,
  }) sync* {
    yield r'email';
    yield serializers.serialize(
      object.email,
      specifiedType: const FullType(String),
    );
    if (object.role != null) {
      yield r'role';
      yield serializers.serialize(
        object.role,
        specifiedType: const FullType(EditorInvitationRequestRoleEnum),
      );
    }
  }

  @override
  Object serialize(
    Serializers serializers,
    EditorInvitationRequest object, {
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
    required EditorInvitationRequestBuilder result,
    required List<Object?> unhandled,
  }) {
    for (var i = 0; i < serializedList.length; i += 2) {
      final key = serializedList[i] as String;
      final value = serializedList[i + 1];
      switch (key) {
        case r'email':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType(String),
          ) as String;
          result.email = valueDes;
          break;
        case r'role':
          final valueDes = serializers.deserialize(
            value,
            specifiedType:
                const FullType.nullable(EditorInvitationRequestRoleEnum),
          ) as EditorInvitationRequestRoleEnum?;
          if (valueDes == null) continue;
          result.role = valueDes;
          break;
        default:
          unhandled.add(key);
          unhandled.add(value);
          break;
      }
    }
  }

  @override
  EditorInvitationRequest deserialize(
    Serializers serializers,
    Object serialized, {
    FullType specifiedType = FullType.unspecified,
  }) {
    final result = EditorInvitationRequestBuilder();
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

/// Only systemadministration may invite botanisches_review or lehrende. Teacher invitations redirect to the configured teacher portal.
class EditorInvitationRequestRoleEnum extends EnumClass {
  @BuiltValueEnumConst(wireName: r'inhaltsredaktion')
  static const EditorInvitationRequestRoleEnum inhaltsredaktion =
      _$editorInvitationRequestRoleEnum_inhaltsredaktion;
  @BuiltValueEnumConst(wireName: r'botanisches_review')
  static const EditorInvitationRequestRoleEnum botanischesReview =
      _$editorInvitationRequestRoleEnum_botanischesReview;
  @BuiltValueEnumConst(wireName: r'lehrende')
  static const EditorInvitationRequestRoleEnum lehrende =
      _$editorInvitationRequestRoleEnum_lehrende;

  static Serializer<EditorInvitationRequestRoleEnum> get serializer =>
      _$editorInvitationRequestRoleEnumSerializer;

  const EditorInvitationRequestRoleEnum._(String name) : super(name);

  static BuiltSet<EditorInvitationRequestRoleEnum> get values =>
      _$editorInvitationRequestRoleEnumValues;
  static EditorInvitationRequestRoleEnum valueOf(String name) =>
      _$editorInvitationRequestRoleEnumValueOf(name);
}
