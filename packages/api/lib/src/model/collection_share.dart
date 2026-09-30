//
// AUTO-GENERATED FILE, DO NOT MODIFY!
//

// ignore_for_file: unused_element
import 'package:built_value/built_value.dart';
import 'package:built_value/serializer.dart';

part 'collection_share.g.dart';

/// CollectionShare
///
/// Properties:
/// * [share]
/// * [label] - Formatted, e.g. \"12 %\" or \"3 ‰\".
@BuiltValue()
abstract class CollectionShare
    implements Built<CollectionShare, CollectionShareBuilder> {
  @BuiltValueField(wireName: r'share')
  num get share;

  /// Formatted, e.g. \"12 %\" or \"3 ‰\".
  @BuiltValueField(wireName: r'label')
  String get label;

  CollectionShare._();

  factory CollectionShare([void updates(CollectionShareBuilder b)]) =
      _$CollectionShare;

  @BuiltValueHook(initializeBuilder: true)
  static void _defaults(CollectionShareBuilder b) => b;

  @BuiltValueSerializer(custom: true)
  static Serializer<CollectionShare> get serializer =>
      _$CollectionShareSerializer();
}

class _$CollectionShareSerializer
    implements PrimitiveSerializer<CollectionShare> {
  @override
  final Iterable<Type> types = const [CollectionShare, _$CollectionShare];

  @override
  final String wireName = r'CollectionShare';

  Iterable<Object?> _serializeProperties(
    Serializers serializers,
    CollectionShare object, {
    FullType specifiedType = FullType.unspecified,
  }) sync* {
    yield r'share';
    yield serializers.serialize(
      object.share,
      specifiedType: const FullType(num),
    );
    yield r'label';
    yield serializers.serialize(
      object.label,
      specifiedType: const FullType(String),
    );
  }

  @override
  Object serialize(
    Serializers serializers,
    CollectionShare object, {
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
    required CollectionShareBuilder result,
    required List<Object?> unhandled,
  }) {
    for (var i = 0; i < serializedList.length; i += 2) {
      final key = serializedList[i] as String;
      final value = serializedList[i + 1];
      switch (key) {
        case r'share':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType(num),
          ) as num;
          result.share = valueDes;
          break;
        case r'label':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType(String),
          ) as String;
          result.label = valueDes;
          break;
        default:
          unhandled.add(key);
          unhandled.add(value);
          break;
      }
    }
  }

  @override
  CollectionShare deserialize(
    Serializers serializers,
    Object serialized, {
    FullType specifiedType = FullType.unspecified,
  }) {
    final result = CollectionShareBuilder();
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
