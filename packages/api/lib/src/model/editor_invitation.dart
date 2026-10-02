//
// AUTO-GENERATED FILE, DO NOT MODIFY!
//

// ignore_for_file: unused_element
import 'package:built_collection/built_collection.dart';
import 'package:built_value/built_value.dart';
import 'package:built_value/serializer.dart';

part 'editor_invitation.g.dart';

/// EditorInvitation
///
/// Properties:
/// * [email]
/// * [role]
/// * [status]
@BuiltValue()
abstract class EditorInvitation
    implements Built<EditorInvitation, EditorInvitationBuilder> {
  @BuiltValueField(wireName: r'email')
  String get email;

  @BuiltValueField(wireName: r'role')
  EditorInvitationRoleEnum get role;
  // enum roleEnum {  inhaltsredaktion,  botanisches_review,  };

  @BuiltValueField(wireName: r'status')
  EditorInvitationStatusEnum get status;
  // enum statusEnum {  invited,  };

  EditorInvitation._();

  factory EditorInvitation([void updates(EditorInvitationBuilder b)]) =
      _$EditorInvitation;

  @BuiltValueHook(initializeBuilder: true)
  static void _defaults(EditorInvitationBuilder b) => b;

  @BuiltValueSerializer(custom: true)
  static Serializer<EditorInvitation> get serializer =>
      _$EditorInvitationSerializer();
}

class _$EditorInvitationSerializer
    implements PrimitiveSerializer<EditorInvitation> {
  @override
  final Iterable<Type> types = const [EditorInvitation, _$EditorInvitation];

  @override
  final String wireName = r'EditorInvitation';

  Iterable<Object?> _serializeProperties(
    Serializers serializers,
    EditorInvitation object, {
    FullType specifiedType = FullType.unspecified,
  }) sync* {
    yield r'email';
    yield serializers.serialize(
      object.email,
      specifiedType: const FullType(String),
    );
    yield r'role';
    yield serializers.serialize(
      object.role,
      specifiedType: const FullType(EditorInvitationRoleEnum),
    );
    yield r'status';
    yield serializers.serialize(
      object.status,
      specifiedType: const FullType(EditorInvitationStatusEnum),
    );
  }

  @override
  Object serialize(
    Serializers serializers,
    EditorInvitation object, {
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
    required EditorInvitationBuilder result,
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
            specifiedType: const FullType(EditorInvitationRoleEnum),
          ) as EditorInvitationRoleEnum;
          result.role = valueDes;
          break;
        case r'status':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType(EditorInvitationStatusEnum),
          ) as EditorInvitationStatusEnum;
          result.status = valueDes;
          break;
        default:
          unhandled.add(key);
          unhandled.add(value);
          break;
      }
    }
  }

  @override
  EditorInvitation deserialize(
    Serializers serializers,
    Object serialized, {
    FullType specifiedType = FullType.unspecified,
  }) {
    final result = EditorInvitationBuilder();
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

class EditorInvitationRoleEnum extends EnumClass {
  @BuiltValueEnumConst(wireName: r'inhaltsredaktion')
  static const EditorInvitationRoleEnum inhaltsredaktion =
      _$editorInvitationRoleEnum_inhaltsredaktion;
  @BuiltValueEnumConst(wireName: r'botanisches_review')
  static const EditorInvitationRoleEnum botanischesReview =
      _$editorInvitationRoleEnum_botanischesReview;

  static Serializer<EditorInvitationRoleEnum> get serializer =>
      _$editorInvitationRoleEnumSerializer;

  const EditorInvitationRoleEnum._(String name) : super(name);

  static BuiltSet<EditorInvitationRoleEnum> get values =>
      _$editorInvitationRoleEnumValues;
  static EditorInvitationRoleEnum valueOf(String name) =>
      _$editorInvitationRoleEnumValueOf(name);
}

class EditorInvitationStatusEnum extends EnumClass {
  @BuiltValueEnumConst(wireName: r'invited')
  static const EditorInvitationStatusEnum invited =
      _$editorInvitationStatusEnum_invited;

  static Serializer<EditorInvitationStatusEnum> get serializer =>
      _$editorInvitationStatusEnumSerializer;

  const EditorInvitationStatusEnum._(String name) : super(name);

  static BuiltSet<EditorInvitationStatusEnum> get values =>
      _$editorInvitationStatusEnumValues;
  static EditorInvitationStatusEnum valueOf(String name) =>
      _$editorInvitationStatusEnumValueOf(name);
}
