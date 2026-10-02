//
// AUTO-GENERATED FILE, DO NOT MODIFY!
//

// ignore_for_file: unused_element
import 'package:built_collection/built_collection.dart';
import 'package:openapi/src/model/editor_item_summary.dart';
import 'package:built_value/built_value.dart';
import 'package:built_value/serializer.dart';

part 'editor_catalog.g.dart';

/// EditorCatalog
///
/// Properties:
/// * [ecosystems]
/// * [levels]
/// * [plants]
/// * [quizzes]
@BuiltValue()
abstract class EditorCatalog
    implements Built<EditorCatalog, EditorCatalogBuilder> {
  @BuiltValueField(wireName: r'ecosystems')
  BuiltList<EditorItemSummary> get ecosystems;

  @BuiltValueField(wireName: r'levels')
  BuiltList<EditorItemSummary> get levels;

  @BuiltValueField(wireName: r'plants')
  BuiltList<EditorItemSummary> get plants;

  @BuiltValueField(wireName: r'quizzes')
  BuiltList<EditorItemSummary> get quizzes;

  EditorCatalog._();

  factory EditorCatalog([void updates(EditorCatalogBuilder b)]) =
      _$EditorCatalog;

  @BuiltValueHook(initializeBuilder: true)
  static void _defaults(EditorCatalogBuilder b) => b;

  @BuiltValueSerializer(custom: true)
  static Serializer<EditorCatalog> get serializer =>
      _$EditorCatalogSerializer();
}

class _$EditorCatalogSerializer implements PrimitiveSerializer<EditorCatalog> {
  @override
  final Iterable<Type> types = const [EditorCatalog, _$EditorCatalog];

  @override
  final String wireName = r'EditorCatalog';

  Iterable<Object?> _serializeProperties(
    Serializers serializers,
    EditorCatalog object, {
    FullType specifiedType = FullType.unspecified,
  }) sync* {
    yield r'ecosystems';
    yield serializers.serialize(
      object.ecosystems,
      specifiedType: const FullType(BuiltList, [FullType(EditorItemSummary)]),
    );
    yield r'levels';
    yield serializers.serialize(
      object.levels,
      specifiedType: const FullType(BuiltList, [FullType(EditorItemSummary)]),
    );
    yield r'plants';
    yield serializers.serialize(
      object.plants,
      specifiedType: const FullType(BuiltList, [FullType(EditorItemSummary)]),
    );
    yield r'quizzes';
    yield serializers.serialize(
      object.quizzes,
      specifiedType: const FullType(BuiltList, [FullType(EditorItemSummary)]),
    );
  }

  @override
  Object serialize(
    Serializers serializers,
    EditorCatalog object, {
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
    required EditorCatalogBuilder result,
    required List<Object?> unhandled,
  }) {
    for (var i = 0; i < serializedList.length; i += 2) {
      final key = serializedList[i] as String;
      final value = serializedList[i + 1];
      switch (key) {
        case r'ecosystems':
          final valueDes = serializers.deserialize(
            value,
            specifiedType:
                const FullType(BuiltList, [FullType(EditorItemSummary)]),
          ) as BuiltList<EditorItemSummary>;
          result.ecosystems.replace(valueDes);
          break;
        case r'levels':
          final valueDes = serializers.deserialize(
            value,
            specifiedType:
                const FullType(BuiltList, [FullType(EditorItemSummary)]),
          ) as BuiltList<EditorItemSummary>;
          result.levels.replace(valueDes);
          break;
        case r'plants':
          final valueDes = serializers.deserialize(
            value,
            specifiedType:
                const FullType(BuiltList, [FullType(EditorItemSummary)]),
          ) as BuiltList<EditorItemSummary>;
          result.plants.replace(valueDes);
          break;
        case r'quizzes':
          final valueDes = serializers.deserialize(
            value,
            specifiedType:
                const FullType(BuiltList, [FullType(EditorItemSummary)]),
          ) as BuiltList<EditorItemSummary>;
          result.quizzes.replace(valueDes);
          break;
        default:
          unhandled.add(key);
          unhandled.add(value);
          break;
      }
    }
  }

  @override
  EditorCatalog deserialize(
    Serializers serializers,
    Object serialized, {
    FullType specifiedType = FullType.unspecified,
  }) {
    final result = EditorCatalogBuilder();
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
