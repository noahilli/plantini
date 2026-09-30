//
// AUTO-GENERATED FILE, DO NOT MODIFY!
//

// ignore_for_file: unused_element
import 'package:built_collection/built_collection.dart';
import 'package:openapi/src/model/collection_share.dart';
import 'package:built_value/built_value.dart';
import 'package:built_value/serializer.dart';

part 'collection_stats.g.dart';

/// CollectionStats
///
/// Properties:
/// * [available]
/// * [reason]
/// * [generatedAt]
/// * [plants]
/// * [species]
@BuiltValue()
abstract class CollectionStats
    implements Built<CollectionStats, CollectionStatsBuilder> {
  @BuiltValueField(wireName: r'available')
  bool get available;

  @BuiltValueField(wireName: r'reason')
  String? get reason;

  @BuiltValueField(wireName: r'generatedAt')
  DateTime get generatedAt;

  @BuiltValueField(wireName: r'plants')
  BuiltMap<String, CollectionShare> get plants;

  @BuiltValueField(wireName: r'species')
  BuiltMap<String, CollectionShare> get species;

  CollectionStats._();

  factory CollectionStats([void updates(CollectionStatsBuilder b)]) =
      _$CollectionStats;

  @BuiltValueHook(initializeBuilder: true)
  static void _defaults(CollectionStatsBuilder b) => b;

  @BuiltValueSerializer(custom: true)
  static Serializer<CollectionStats> get serializer =>
      _$CollectionStatsSerializer();
}

class _$CollectionStatsSerializer
    implements PrimitiveSerializer<CollectionStats> {
  @override
  final Iterable<Type> types = const [CollectionStats, _$CollectionStats];

  @override
  final String wireName = r'CollectionStats';

  Iterable<Object?> _serializeProperties(
    Serializers serializers,
    CollectionStats object, {
    FullType specifiedType = FullType.unspecified,
  }) sync* {
    yield r'available';
    yield serializers.serialize(
      object.available,
      specifiedType: const FullType(bool),
    );
    if (object.reason != null) {
      yield r'reason';
      yield serializers.serialize(
        object.reason,
        specifiedType: const FullType(String),
      );
    }
    yield r'generatedAt';
    yield serializers.serialize(
      object.generatedAt,
      specifiedType: const FullType(DateTime),
    );
    yield r'plants';
    yield serializers.serialize(
      object.plants,
      specifiedType: const FullType(
          BuiltMap, [FullType(String), FullType(CollectionShare)]),
    );
    yield r'species';
    yield serializers.serialize(
      object.species,
      specifiedType: const FullType(
          BuiltMap, [FullType(String), FullType(CollectionShare)]),
    );
  }

  @override
  Object serialize(
    Serializers serializers,
    CollectionStats object, {
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
    required CollectionStatsBuilder result,
    required List<Object?> unhandled,
  }) {
    for (var i = 0; i < serializedList.length; i += 2) {
      final key = serializedList[i] as String;
      final value = serializedList[i + 1];
      switch (key) {
        case r'available':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType(bool),
          ) as bool;
          result.available = valueDes;
          break;
        case r'reason':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType.nullable(String),
          ) as String?;
          if (valueDes == null) continue;
          result.reason = valueDes;
          break;
        case r'generatedAt':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType(DateTime),
          ) as DateTime;
          result.generatedAt = valueDes;
          break;
        case r'plants':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType(
                BuiltMap, [FullType(String), FullType(CollectionShare)]),
          ) as BuiltMap<String, CollectionShare>;
          result.plants.replace(valueDes);
          break;
        case r'species':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType(
                BuiltMap, [FullType(String), FullType(CollectionShare)]),
          ) as BuiltMap<String, CollectionShare>;
          result.species.replace(valueDes);
          break;
        default:
          unhandled.add(key);
          unhandled.add(value);
          break;
      }
    }
  }

  @override
  CollectionStats deserialize(
    Serializers serializers,
    Object serialized, {
    FullType specifiedType = FullType.unspecified,
  }) {
    final result = CollectionStatsBuilder();
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
