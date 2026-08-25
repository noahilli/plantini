//
// AUTO-GENERATED FILE, DO NOT MODIFY!
//

// ignore_for_file: unused_element
import 'package:built_value/built_value.dart';
import 'package:built_value/serializer.dart';

part 'plant.g.dart';

/// Plant
///
/// Properties:
/// * [id] 
/// * [scientificName] 
/// * [commonName] 
/// * [family] 
/// * [description] 
@BuiltValue()
abstract class Plant implements Built<Plant, PlantBuilder> {
  @BuiltValueField(wireName: r'id')
  String get id;

  @BuiltValueField(wireName: r'scientificName')
  String get scientificName;

  @BuiltValueField(wireName: r'commonName')
  String? get commonName;

  @BuiltValueField(wireName: r'family')
  String? get family;

  @BuiltValueField(wireName: r'description')
  String? get description;

  Plant._();

  factory Plant([void updates(PlantBuilder b)]) = _$Plant;

  @BuiltValueHook(initializeBuilder: true)
  static void _defaults(PlantBuilder b) => b;

  @BuiltValueSerializer(custom: true)
  static Serializer<Plant> get serializer => _$PlantSerializer();
}

class _$PlantSerializer implements PrimitiveSerializer<Plant> {
  @override
  final Iterable<Type> types = const [Plant, _$Plant];

  @override
  final String wireName = r'Plant';

  Iterable<Object?> _serializeProperties(
    Serializers serializers,
    Plant object, {
    FullType specifiedType = FullType.unspecified,
  }) sync* {
    yield r'id';
    yield serializers.serialize(
      object.id,
      specifiedType: const FullType(String),
    );
    yield r'scientificName';
    yield serializers.serialize(
      object.scientificName,
      specifiedType: const FullType(String),
    );
    if (object.commonName != null) {
      yield r'commonName';
      yield serializers.serialize(
        object.commonName,
        specifiedType: const FullType(String),
      );
    }
    if (object.family != null) {
      yield r'family';
      yield serializers.serialize(
        object.family,
        specifiedType: const FullType(String),
      );
    }
    if (object.description != null) {
      yield r'description';
      yield serializers.serialize(
        object.description,
        specifiedType: const FullType(String),
      );
    }
  }

  @override
  Object serialize(
    Serializers serializers,
    Plant object, {
    FullType specifiedType = FullType.unspecified,
  }) {
    return _serializeProperties(serializers, object, specifiedType: specifiedType).toList();
  }

  void _deserializeProperties(
    Serializers serializers,
    Object serialized, {
    FullType specifiedType = FullType.unspecified,
    required List<Object?> serializedList,
    required PlantBuilder result,
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
        case r'scientificName':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType(String),
          ) as String;
          result.scientificName = valueDes;
          break;
        case r'commonName':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType.nullable(String),
          ) as String?;
          if (valueDes == null) continue;
          result.commonName = valueDes;
          break;
        case r'family':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType.nullable(String),
          ) as String?;
          if (valueDes == null) continue;
          result.family = valueDes;
          break;
        case r'description':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType.nullable(String),
          ) as String?;
          if (valueDes == null) continue;
          result.description = valueDes;
          break;
        default:
          unhandled.add(key);
          unhandled.add(value);
          break;
      }
    }
  }

  @override
  Plant deserialize(
    Serializers serializers,
    Object serialized, {
    FullType specifiedType = FullType.unspecified,
  }) {
    final result = PlantBuilder();
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


