//
// AUTO-GENERATED FILE, DO NOT MODIFY!
//

// ignore_for_file: unused_element
import 'package:built_collection/built_collection.dart';
import 'package:built_value/built_value.dart';
import 'package:built_value/serializer.dart';

part 'manifest.g.dart';

/// Manifest
///
/// Properties:
/// * [version] 
/// * [releasedAt] 
/// * [checksums] 
@BuiltValue()
abstract class Manifest implements Built<Manifest, ManifestBuilder> {
  @BuiltValueField(wireName: r'version')
  String get version;

  @BuiltValueField(wireName: r'releasedAt')
  DateTime get releasedAt;

  @BuiltValueField(wireName: r'checksums')
  BuiltMap<String, String>? get checksums;

  Manifest._();

  factory Manifest([void updates(ManifestBuilder b)]) = _$Manifest;

  @BuiltValueHook(initializeBuilder: true)
  static void _defaults(ManifestBuilder b) => b;

  @BuiltValueSerializer(custom: true)
  static Serializer<Manifest> get serializer => _$ManifestSerializer();
}

class _$ManifestSerializer implements PrimitiveSerializer<Manifest> {
  @override
  final Iterable<Type> types = const [Manifest, _$Manifest];

  @override
  final String wireName = r'Manifest';

  Iterable<Object?> _serializeProperties(
    Serializers serializers,
    Manifest object, {
    FullType specifiedType = FullType.unspecified,
  }) sync* {
    yield r'version';
    yield serializers.serialize(
      object.version,
      specifiedType: const FullType(String),
    );
    yield r'releasedAt';
    yield serializers.serialize(
      object.releasedAt,
      specifiedType: const FullType(DateTime),
    );
    if (object.checksums != null) {
      yield r'checksums';
      yield serializers.serialize(
        object.checksums,
        specifiedType: const FullType(BuiltMap, [FullType(String), FullType(String)]),
      );
    }
  }

  @override
  Object serialize(
    Serializers serializers,
    Manifest object, {
    FullType specifiedType = FullType.unspecified,
  }) {
    return _serializeProperties(serializers, object, specifiedType: specifiedType).toList();
  }

  void _deserializeProperties(
    Serializers serializers,
    Object serialized, {
    FullType specifiedType = FullType.unspecified,
    required List<Object?> serializedList,
    required ManifestBuilder result,
    required List<Object?> unhandled,
  }) {
    for (var i = 0; i < serializedList.length; i += 2) {
      final key = serializedList[i] as String;
      final value = serializedList[i + 1];
      switch (key) {
        case r'version':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType(String),
          ) as String;
          result.version = valueDes;
          break;
        case r'releasedAt':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType(DateTime),
          ) as DateTime;
          result.releasedAt = valueDes;
          break;
        case r'checksums':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType.nullable(BuiltMap, [FullType(String), FullType(String)]),
          ) as BuiltMap<String, String>?;
          if (valueDes == null) continue;
          result.checksums.replace(valueDes);
          break;
        default:
          unhandled.add(key);
          unhandled.add(value);
          break;
      }
    }
  }

  @override
  Manifest deserialize(
    Serializers serializers,
    Object serialized, {
    FullType specifiedType = FullType.unspecified,
  }) {
    final result = ManifestBuilder();
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


