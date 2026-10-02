//
// AUTO-GENERATED FILE, DO NOT MODIFY!
//

// ignore_for_file: unused_element
import 'package:built_collection/built_collection.dart';
import 'package:built_value/json_object.dart';
import 'package:built_value/built_value.dart';
import 'package:built_value/serializer.dart';

part 'editor_change.g.dart';

/// EditorChange
///
/// Properties:
/// * [id]
/// * [type]
/// * [targetId]
/// * [data]
/// * [status]
/// * [author]
/// * [reviewer]
/// * [note]
/// * [updatedAt]
/// * [reviewedAt]
/// * [appliedAt]
/// * [reviewEvents]
/// * [payloadHash]
@BuiltValue()
abstract class EditorChange
    implements Built<EditorChange, EditorChangeBuilder> {
  @BuiltValueField(wireName: r'id')
  String get id;

  @BuiltValueField(wireName: r'type')
  EditorChangeTypeEnum get type;
  // enum typeEnum {  ecosystem,  level,  plant,  quiz,  };

  @BuiltValueField(wireName: r'targetId')
  String get targetId;

  @BuiltValueField(wireName: r'data')
  JsonObject get data;

  @BuiltValueField(wireName: r'status')
  EditorChangeStatusEnum get status;
  // enum statusEnum {  draft,  pending_review,  rejected,  approved,  };

  @BuiltValueField(wireName: r'author')
  String get author;

  @BuiltValueField(wireName: r'reviewer')
  String? get reviewer;

  @BuiltValueField(wireName: r'note')
  String? get note;

  @BuiltValueField(wireName: r'updatedAt')
  DateTime get updatedAt;

  @BuiltValueField(wireName: r'reviewedAt')
  DateTime? get reviewedAt;

  @BuiltValueField(wireName: r'appliedAt')
  DateTime? get appliedAt;

  @BuiltValueField(wireName: r'reviewEvents')
  BuiltList<JsonObject> get reviewEvents;

  @BuiltValueField(wireName: r'payloadHash')
  String? get payloadHash;

  EditorChange._();

  factory EditorChange([void updates(EditorChangeBuilder b)]) = _$EditorChange;

  @BuiltValueHook(initializeBuilder: true)
  static void _defaults(EditorChangeBuilder b) => b;

  @BuiltValueSerializer(custom: true)
  static Serializer<EditorChange> get serializer => _$EditorChangeSerializer();
}

class _$EditorChangeSerializer implements PrimitiveSerializer<EditorChange> {
  @override
  final Iterable<Type> types = const [EditorChange, _$EditorChange];

  @override
  final String wireName = r'EditorChange';

  Iterable<Object?> _serializeProperties(
    Serializers serializers,
    EditorChange object, {
    FullType specifiedType = FullType.unspecified,
  }) sync* {
    yield r'id';
    yield serializers.serialize(
      object.id,
      specifiedType: const FullType(String),
    );
    yield r'type';
    yield serializers.serialize(
      object.type,
      specifiedType: const FullType(EditorChangeTypeEnum),
    );
    yield r'targetId';
    yield serializers.serialize(
      object.targetId,
      specifiedType: const FullType(String),
    );
    yield r'data';
    yield serializers.serialize(
      object.data,
      specifiedType: const FullType(JsonObject),
    );
    yield r'status';
    yield serializers.serialize(
      object.status,
      specifiedType: const FullType(EditorChangeStatusEnum),
    );
    yield r'author';
    yield serializers.serialize(
      object.author,
      specifiedType: const FullType(String),
    );
    if (object.reviewer != null) {
      yield r'reviewer';
      yield serializers.serialize(
        object.reviewer,
        specifiedType: const FullType.nullable(String),
      );
    }
    if (object.note != null) {
      yield r'note';
      yield serializers.serialize(
        object.note,
        specifiedType: const FullType(String),
      );
    }
    yield r'updatedAt';
    yield serializers.serialize(
      object.updatedAt,
      specifiedType: const FullType(DateTime),
    );
    if (object.reviewedAt != null) {
      yield r'reviewedAt';
      yield serializers.serialize(
        object.reviewedAt,
        specifiedType: const FullType.nullable(DateTime),
      );
    }
    if (object.appliedAt != null) {
      yield r'appliedAt';
      yield serializers.serialize(
        object.appliedAt,
        specifiedType: const FullType.nullable(DateTime),
      );
    }
    yield r'reviewEvents';
    yield serializers.serialize(
      object.reviewEvents,
      specifiedType: const FullType(BuiltList, [FullType(JsonObject)]),
    );
    if (object.payloadHash != null) {
      yield r'payloadHash';
      yield serializers.serialize(
        object.payloadHash,
        specifiedType: const FullType.nullable(String),
      );
    }
  }

  @override
  Object serialize(
    Serializers serializers,
    EditorChange object, {
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
    required EditorChangeBuilder result,
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
        case r'type':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType(EditorChangeTypeEnum),
          ) as EditorChangeTypeEnum;
          result.type = valueDes;
          break;
        case r'targetId':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType(String),
          ) as String;
          result.targetId = valueDes;
          break;
        case r'data':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType(JsonObject),
          ) as JsonObject;
          result.data = valueDes;
          break;
        case r'status':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType(EditorChangeStatusEnum),
          ) as EditorChangeStatusEnum;
          result.status = valueDes;
          break;
        case r'author':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType(String),
          ) as String;
          result.author = valueDes;
          break;
        case r'reviewer':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType.nullable(String),
          ) as String?;
          if (valueDes == null) continue;
          result.reviewer = valueDes;
          break;
        case r'note':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType.nullable(String),
          ) as String?;
          if (valueDes == null) continue;
          result.note = valueDes;
          break;
        case r'updatedAt':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType(DateTime),
          ) as DateTime;
          result.updatedAt = valueDes;
          break;
        case r'reviewedAt':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType.nullable(DateTime),
          ) as DateTime?;
          if (valueDes == null) continue;
          result.reviewedAt = valueDes;
          break;
        case r'appliedAt':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType.nullable(DateTime),
          ) as DateTime?;
          if (valueDes == null) continue;
          result.appliedAt = valueDes;
          break;
        case r'reviewEvents':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType(BuiltList, [FullType(JsonObject)]),
          ) as BuiltList<JsonObject>;
          result.reviewEvents.replace(valueDes);
          break;
        case r'payloadHash':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType.nullable(String),
          ) as String?;
          if (valueDes == null) continue;
          result.payloadHash = valueDes;
          break;
        default:
          unhandled.add(key);
          unhandled.add(value);
          break;
      }
    }
  }

  @override
  EditorChange deserialize(
    Serializers serializers,
    Object serialized, {
    FullType specifiedType = FullType.unspecified,
  }) {
    final result = EditorChangeBuilder();
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

class EditorChangeTypeEnum extends EnumClass {
  @BuiltValueEnumConst(wireName: r'ecosystem')
  static const EditorChangeTypeEnum ecosystem =
      _$editorChangeTypeEnum_ecosystem;
  @BuiltValueEnumConst(wireName: r'level')
  static const EditorChangeTypeEnum level = _$editorChangeTypeEnum_level;
  @BuiltValueEnumConst(wireName: r'plant')
  static const EditorChangeTypeEnum plant = _$editorChangeTypeEnum_plant;
  @BuiltValueEnumConst(wireName: r'quiz')
  static const EditorChangeTypeEnum quiz = _$editorChangeTypeEnum_quiz;

  static Serializer<EditorChangeTypeEnum> get serializer =>
      _$editorChangeTypeEnumSerializer;

  const EditorChangeTypeEnum._(String name) : super(name);

  static BuiltSet<EditorChangeTypeEnum> get values =>
      _$editorChangeTypeEnumValues;
  static EditorChangeTypeEnum valueOf(String name) =>
      _$editorChangeTypeEnumValueOf(name);
}

class EditorChangeStatusEnum extends EnumClass {
  @BuiltValueEnumConst(wireName: r'draft')
  static const EditorChangeStatusEnum draft = _$editorChangeStatusEnum_draft;
  @BuiltValueEnumConst(wireName: r'pending_review')
  static const EditorChangeStatusEnum pendingReview =
      _$editorChangeStatusEnum_pendingReview;
  @BuiltValueEnumConst(wireName: r'rejected')
  static const EditorChangeStatusEnum rejected =
      _$editorChangeStatusEnum_rejected;
  @BuiltValueEnumConst(wireName: r'approved')
  static const EditorChangeStatusEnum approved =
      _$editorChangeStatusEnum_approved;

  static Serializer<EditorChangeStatusEnum> get serializer =>
      _$editorChangeStatusEnumSerializer;

  const EditorChangeStatusEnum._(String name) : super(name);

  static BuiltSet<EditorChangeStatusEnum> get values =>
      _$editorChangeStatusEnumValues;
  static EditorChangeStatusEnum valueOf(String name) =>
      _$editorChangeStatusEnumValueOf(name);
}
