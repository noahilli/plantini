//
// AUTO-GENERATED FILE, DO NOT MODIFY!
//

// ignore_for_file: unused_element
import 'package:built_collection/built_collection.dart';
import 'package:openapi/src/model/ecosystem.dart';
import 'package:openapi/src/model/page_meta.dart';
import 'package:built_value/built_value.dart';
import 'package:built_value/serializer.dart';

part 'ecosystem_page.g.dart';

/// EcosystemPage
///
/// Properties:
/// * [items]
/// * [page]
@BuiltValue()
abstract class EcosystemPage
    implements Built<EcosystemPage, EcosystemPageBuilder> {
  @BuiltValueField(wireName: r'items')
  BuiltList<Ecosystem> get items;

  @BuiltValueField(wireName: r'page')
  PageMeta get page;

  EcosystemPage._();

  factory EcosystemPage([void updates(EcosystemPageBuilder b)]) =
      _$EcosystemPage;

  @BuiltValueHook(initializeBuilder: true)
  static void _defaults(EcosystemPageBuilder b) => b;

  @BuiltValueSerializer(custom: true)
  static Serializer<EcosystemPage> get serializer =>
      _$EcosystemPageSerializer();
}

class _$EcosystemPageSerializer implements PrimitiveSerializer<EcosystemPage> {
  @override
  final Iterable<Type> types = const [EcosystemPage, _$EcosystemPage];

  @override
  final String wireName = r'EcosystemPage';

  Iterable<Object?> _serializeProperties(
    Serializers serializers,
    EcosystemPage object, {
    FullType specifiedType = FullType.unspecified,
  }) sync* {
    yield r'items';
    yield serializers.serialize(
      object.items,
      specifiedType: const FullType(BuiltList, [FullType(Ecosystem)]),
    );
    yield r'page';
    yield serializers.serialize(
      object.page,
      specifiedType: const FullType(PageMeta),
    );
  }

  @override
  Object serialize(
    Serializers serializers,
    EcosystemPage object, {
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
    required EcosystemPageBuilder result,
    required List<Object?> unhandled,
  }) {
    for (var i = 0; i < serializedList.length; i += 2) {
      final key = serializedList[i] as String;
      final value = serializedList[i + 1];
      switch (key) {
        case r'items':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType(BuiltList, [FullType(Ecosystem)]),
          ) as BuiltList<Ecosystem>;
          result.items.replace(valueDes);
          break;
        case r'page':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType(PageMeta),
          ) as PageMeta;
          result.page.replace(valueDes);
          break;
        default:
          unhandled.add(key);
          unhandled.add(value);
          break;
      }
    }
  }

  @override
  EcosystemPage deserialize(
    Serializers serializers,
    Object serialized, {
    FullType specifiedType = FullType.unspecified,
  }) {
    final result = EcosystemPageBuilder();
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
