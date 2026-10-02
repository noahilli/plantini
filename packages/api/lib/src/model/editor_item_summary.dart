//
// AUTO-GENERATED FILE, DO NOT MODIFY!
//

// ignore_for_file: unused_element
import 'package:built_collection/built_collection.dart';
import 'package:built_value/built_value.dart';
import 'package:built_value/serializer.dart';

part 'editor_item_summary.g.dart';

/// EditorItemSummary
///
/// Properties:
/// * [id]
/// * [type]
/// * [title]
/// * [slug]
/// * [published]
/// * [reviewStatus]
/// * [ecosystemId]
/// * [plantIds]
/// * [levelId]
/// * [plantId]
/// * [sequence]
@BuiltValue()
abstract class EditorItemSummary
    implements Built<EditorItemSummary, EditorItemSummaryBuilder> {
  @BuiltValueField(wireName: r'id')
  String get id;

  @BuiltValueField(wireName: r'type')
  EditorItemSummaryTypeEnum get type;
  // enum typeEnum {  ecosystem,  level,  plant,  quiz,  };

  @BuiltValueField(wireName: r'title')
  String get title;

  @BuiltValueField(wireName: r'slug')
  String get slug;

  @BuiltValueField(wireName: r'published')
  bool get published;

  @BuiltValueField(wireName: r'reviewStatus')
  String? get reviewStatus;

  @BuiltValueField(wireName: r'ecosystemId')
  String? get ecosystemId;

  @BuiltValueField(wireName: r'plantIds')
  BuiltList<String>? get plantIds;

  @BuiltValueField(wireName: r'levelId')
  String? get levelId;

  @BuiltValueField(wireName: r'plantId')
  String? get plantId;

  @BuiltValueField(wireName: r'sequence')
  int? get sequence;

  EditorItemSummary._();

  factory EditorItemSummary([void updates(EditorItemSummaryBuilder b)]) =
      _$EditorItemSummary;

  @BuiltValueHook(initializeBuilder: true)
  static void _defaults(EditorItemSummaryBuilder b) => b;

  @BuiltValueSerializer(custom: true)
  static Serializer<EditorItemSummary> get serializer =>
      _$EditorItemSummarySerializer();
}

class _$EditorItemSummarySerializer
    implements PrimitiveSerializer<EditorItemSummary> {
  @override
  final Iterable<Type> types = const [EditorItemSummary, _$EditorItemSummary];

  @override
  final String wireName = r'EditorItemSummary';

  Iterable<Object?> _serializeProperties(
    Serializers serializers,
    EditorItemSummary object, {
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
      specifiedType: const FullType(EditorItemSummaryTypeEnum),
    );
    yield r'title';
    yield serializers.serialize(
      object.title,
      specifiedType: const FullType(String),
    );
    yield r'slug';
    yield serializers.serialize(
      object.slug,
      specifiedType: const FullType(String),
    );
    yield r'published';
    yield serializers.serialize(
      object.published,
      specifiedType: const FullType(bool),
    );
    if (object.reviewStatus != null) {
      yield r'reviewStatus';
      yield serializers.serialize(
        object.reviewStatus,
        specifiedType: const FullType.nullable(String),
      );
    }
    if (object.ecosystemId != null) {
      yield r'ecosystemId';
      yield serializers.serialize(
        object.ecosystemId,
        specifiedType: const FullType(String),
      );
    }
    if (object.plantIds != null) {
      yield r'plantIds';
      yield serializers.serialize(
        object.plantIds,
        specifiedType: const FullType(BuiltList, [FullType(String)]),
      );
    }
    if (object.levelId != null) {
      yield r'levelId';
      yield serializers.serialize(
        object.levelId,
        specifiedType: const FullType(String),
      );
    }
    if (object.plantId != null) {
      yield r'plantId';
      yield serializers.serialize(
        object.plantId,
        specifiedType: const FullType(String),
      );
    }
    if (object.sequence != null) {
      yield r'sequence';
      yield serializers.serialize(
        object.sequence,
        specifiedType: const FullType(int),
      );
    }
  }

  @override
  Object serialize(
    Serializers serializers,
    EditorItemSummary object, {
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
    required EditorItemSummaryBuilder result,
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
            specifiedType: const FullType(EditorItemSummaryTypeEnum),
          ) as EditorItemSummaryTypeEnum;
          result.type = valueDes;
          break;
        case r'title':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType(String),
          ) as String;
          result.title = valueDes;
          break;
        case r'slug':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType(String),
          ) as String;
          result.slug = valueDes;
          break;
        case r'published':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType(bool),
          ) as bool;
          result.published = valueDes;
          break;
        case r'reviewStatus':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType.nullable(String),
          ) as String?;
          if (valueDes == null) continue;
          result.reviewStatus = valueDes;
          break;
        case r'ecosystemId':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType.nullable(String),
          ) as String?;
          if (valueDes == null) continue;
          result.ecosystemId = valueDes;
          break;
        case r'plantIds':
          final valueDes = serializers.deserialize(
            value,
            specifiedType:
                const FullType.nullable(BuiltList, [FullType(String)]),
          ) as BuiltList<String>?;
          if (valueDes == null) continue;
          result.plantIds.replace(valueDes);
          break;
        case r'levelId':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType.nullable(String),
          ) as String?;
          if (valueDes == null) continue;
          result.levelId = valueDes;
          break;
        case r'plantId':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType.nullable(String),
          ) as String?;
          if (valueDes == null) continue;
          result.plantId = valueDes;
          break;
        case r'sequence':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType.nullable(int),
          ) as int?;
          if (valueDes == null) continue;
          result.sequence = valueDes;
          break;
        default:
          unhandled.add(key);
          unhandled.add(value);
          break;
      }
    }
  }

  @override
  EditorItemSummary deserialize(
    Serializers serializers,
    Object serialized, {
    FullType specifiedType = FullType.unspecified,
  }) {
    final result = EditorItemSummaryBuilder();
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

class EditorItemSummaryTypeEnum extends EnumClass {
  @BuiltValueEnumConst(wireName: r'ecosystem')
  static const EditorItemSummaryTypeEnum ecosystem =
      _$editorItemSummaryTypeEnum_ecosystem;
  @BuiltValueEnumConst(wireName: r'level')
  static const EditorItemSummaryTypeEnum level =
      _$editorItemSummaryTypeEnum_level;
  @BuiltValueEnumConst(wireName: r'plant')
  static const EditorItemSummaryTypeEnum plant =
      _$editorItemSummaryTypeEnum_plant;
  @BuiltValueEnumConst(wireName: r'quiz')
  static const EditorItemSummaryTypeEnum quiz =
      _$editorItemSummaryTypeEnum_quiz;

  static Serializer<EditorItemSummaryTypeEnum> get serializer =>
      _$editorItemSummaryTypeEnumSerializer;

  const EditorItemSummaryTypeEnum._(String name) : super(name);

  static BuiltSet<EditorItemSummaryTypeEnum> get values =>
      _$editorItemSummaryTypeEnumValues;
  static EditorItemSummaryTypeEnum valueOf(String name) =>
      _$editorItemSummaryTypeEnumValueOf(name);
}
