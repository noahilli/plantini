//
// AUTO-GENERATED FILE, DO NOT MODIFY!
//

// ignore_for_file: unused_element
import 'package:built_collection/built_collection.dart';
import 'package:openapi/src/model/content_change.dart';
import 'package:built_value/built_value.dart';
import 'package:built_value/serializer.dart';

part 'content_change_page.g.dart';

/// ContentChangePage
///
/// Properties:
/// * [cursor]
/// * [changes]
@BuiltValue()
abstract class ContentChangePage
    implements Built<ContentChangePage, ContentChangePageBuilder> {
  @BuiltValueField(wireName: r'cursor')
  String get cursor;

  @BuiltValueField(wireName: r'changes')
  BuiltList<ContentChange> get changes;

  ContentChangePage._();

  factory ContentChangePage([void updates(ContentChangePageBuilder b)]) =
      _$ContentChangePage;

  @BuiltValueHook(initializeBuilder: true)
  static void _defaults(ContentChangePageBuilder b) => b;

  @BuiltValueSerializer(custom: true)
  static Serializer<ContentChangePage> get serializer =>
      _$ContentChangePageSerializer();
}

class _$ContentChangePageSerializer
    implements PrimitiveSerializer<ContentChangePage> {
  @override
  final Iterable<Type> types = const [ContentChangePage, _$ContentChangePage];

  @override
  final String wireName = r'ContentChangePage';

  Iterable<Object?> _serializeProperties(
    Serializers serializers,
    ContentChangePage object, {
    FullType specifiedType = FullType.unspecified,
  }) sync* {
    yield r'cursor';
    yield serializers.serialize(
      object.cursor,
      specifiedType: const FullType(String),
    );
    yield r'changes';
    yield serializers.serialize(
      object.changes,
      specifiedType: const FullType(BuiltList, [FullType(ContentChange)]),
    );
  }

  @override
  Object serialize(
    Serializers serializers,
    ContentChangePage object, {
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
    required ContentChangePageBuilder result,
    required List<Object?> unhandled,
  }) {
    for (var i = 0; i < serializedList.length; i += 2) {
      final key = serializedList[i] as String;
      final value = serializedList[i + 1];
      switch (key) {
        case r'cursor':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType(String),
          ) as String;
          result.cursor = valueDes;
          break;
        case r'changes':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType(BuiltList, [FullType(ContentChange)]),
          ) as BuiltList<ContentChange>;
          result.changes.replace(valueDes);
          break;
        default:
          unhandled.add(key);
          unhandled.add(value);
          break;
      }
    }
  }

  @override
  ContentChangePage deserialize(
    Serializers serializers,
    Object serialized, {
    FullType specifiedType = FullType.unspecified,
  }) {
    final result = ContentChangePageBuilder();
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
