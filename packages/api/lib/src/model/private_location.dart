//
// AUTO-GENERATED FILE, DO NOT MODIFY!
//

// ignore_for_file: unused_element
import 'package:built_value/built_value.dart';
import 'package:built_value/serializer.dart';

part 'private_location.g.dart';

/// PrivateLocation
///
/// Properties:
/// * [latitude]
/// * [longitude]
/// * [accuracyMeters]
@BuiltValue()
abstract class PrivateLocation
    implements Built<PrivateLocation, PrivateLocationBuilder> {
  @BuiltValueField(wireName: r'latitude')
  num get latitude;

  @BuiltValueField(wireName: r'longitude')
  num get longitude;

  @BuiltValueField(wireName: r'accuracyMeters')
  num get accuracyMeters;

  PrivateLocation._();

  factory PrivateLocation([void updates(PrivateLocationBuilder b)]) =
      _$PrivateLocation;

  @BuiltValueHook(initializeBuilder: true)
  static void _defaults(PrivateLocationBuilder b) => b;

  @BuiltValueSerializer(custom: true)
  static Serializer<PrivateLocation> get serializer =>
      _$PrivateLocationSerializer();
}

class _$PrivateLocationSerializer
    implements PrimitiveSerializer<PrivateLocation> {
  @override
  final Iterable<Type> types = const [PrivateLocation, _$PrivateLocation];

  @override
  final String wireName = r'PrivateLocation';

  Iterable<Object?> _serializeProperties(
    Serializers serializers,
    PrivateLocation object, {
    FullType specifiedType = FullType.unspecified,
  }) sync* {
    yield r'latitude';
    yield serializers.serialize(
      object.latitude,
      specifiedType: const FullType(num),
    );
    yield r'longitude';
    yield serializers.serialize(
      object.longitude,
      specifiedType: const FullType(num),
    );
    yield r'accuracyMeters';
    yield serializers.serialize(
      object.accuracyMeters,
      specifiedType: const FullType(num),
    );
  }

  @override
  Object serialize(
    Serializers serializers,
    PrivateLocation object, {
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
    required PrivateLocationBuilder result,
    required List<Object?> unhandled,
  }) {
    for (var i = 0; i < serializedList.length; i += 2) {
      final key = serializedList[i] as String;
      final value = serializedList[i + 1];
      switch (key) {
        case r'latitude':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType(num),
          ) as num;
          result.latitude = valueDes;
          break;
        case r'longitude':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType(num),
          ) as num;
          result.longitude = valueDes;
          break;
        case r'accuracyMeters':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType(num),
          ) as num;
          result.accuracyMeters = valueDes;
          break;
        default:
          unhandled.add(key);
          unhandled.add(value);
          break;
      }
    }
  }

  @override
  PrivateLocation deserialize(
    Serializers serializers,
    Object serialized, {
    FullType specifiedType = FullType.unspecified,
  }) {
    final result = PrivateLocationBuilder();
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
