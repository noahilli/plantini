//
// AUTO-GENERATED FILE, DO NOT MODIFY!
//

// ignore_for_file: unused_element
import 'package:built_collection/built_collection.dart';
import 'package:openapi/src/model/observation.dart';
import 'package:openapi/src/model/page_meta.dart';
import 'package:built_value/built_value.dart';
import 'package:built_value/serializer.dart';

part 'observation_page.g.dart';

/// ObservationPage
///
/// Properties:
/// * [items]
/// * [page]
@BuiltValue()
abstract class ObservationPage
    implements Built<ObservationPage, ObservationPageBuilder> {
  @BuiltValueField(wireName: r'items')
  BuiltList<Observation> get items;

  @BuiltValueField(wireName: r'page')
  PageMeta get page;

  ObservationPage._();

  factory ObservationPage([void updates(ObservationPageBuilder b)]) =
      _$ObservationPage;

  @BuiltValueHook(initializeBuilder: true)
  static void _defaults(ObservationPageBuilder b) => b;

  @BuiltValueSerializer(custom: true)
  static Serializer<ObservationPage> get serializer =>
      _$ObservationPageSerializer();
}

class _$ObservationPageSerializer
    implements PrimitiveSerializer<ObservationPage> {
  @override
  final Iterable<Type> types = const [ObservationPage, _$ObservationPage];

  @override
  final String wireName = r'ObservationPage';

  Iterable<Object?> _serializeProperties(
    Serializers serializers,
    ObservationPage object, {
    FullType specifiedType = FullType.unspecified,
  }) sync* {
    yield r'items';
    yield serializers.serialize(
      object.items,
      specifiedType: const FullType(BuiltList, [FullType(Observation)]),
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
    ObservationPage object, {
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
    required ObservationPageBuilder result,
    required List<Object?> unhandled,
  }) {
    for (var i = 0; i < serializedList.length; i += 2) {
      final key = serializedList[i] as String;
      final value = serializedList[i + 1];
      switch (key) {
        case r'items':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType(BuiltList, [FullType(Observation)]),
          ) as BuiltList<Observation>;
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
  ObservationPage deserialize(
    Serializers serializers,
    Object serialized, {
    FullType specifiedType = FullType.unspecified,
  }) {
    final result = ObservationPageBuilder();
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
