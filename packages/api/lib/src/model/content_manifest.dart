//
// AUTO-GENERATED FILE, DO NOT MODIFY!
//

// ignore_for_file: unused_element
import 'package:built_collection/built_collection.dart';
import 'package:openapi/src/model/content_package.dart';
import 'package:built_value/built_value.dart';
import 'package:built_value/serializer.dart';

part 'content_manifest.g.dart';

/// ContentManifest
///
/// Properties:
/// * [version]
/// * [releasedAt]
/// * [schemaVersion]
/// * [minimumAppVersion]
/// * [signature]
/// * [packages]
@BuiltValue()
abstract class ContentManifest
    implements Built<ContentManifest, ContentManifestBuilder> {
  @BuiltValueField(wireName: r'version')
  String get version;

  @BuiltValueField(wireName: r'releasedAt')
  DateTime get releasedAt;

  @BuiltValueField(wireName: r'schemaVersion')
  String get schemaVersion;

  @BuiltValueField(wireName: r'minimumAppVersion')
  String get minimumAppVersion;

  @BuiltValueField(wireName: r'signature')
  String? get signature;

  @BuiltValueField(wireName: r'packages')
  BuiltList<ContentPackage> get packages;

  ContentManifest._();

  factory ContentManifest([void updates(ContentManifestBuilder b)]) =
      _$ContentManifest;

  @BuiltValueHook(initializeBuilder: true)
  static void _defaults(ContentManifestBuilder b) => b;

  @BuiltValueSerializer(custom: true)
  static Serializer<ContentManifest> get serializer =>
      _$ContentManifestSerializer();
}

class _$ContentManifestSerializer
    implements PrimitiveSerializer<ContentManifest> {
  @override
  final Iterable<Type> types = const [ContentManifest, _$ContentManifest];

  @override
  final String wireName = r'ContentManifest';

  Iterable<Object?> _serializeProperties(
    Serializers serializers,
    ContentManifest object, {
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
    yield r'schemaVersion';
    yield serializers.serialize(
      object.schemaVersion,
      specifiedType: const FullType(String),
    );
    yield r'minimumAppVersion';
    yield serializers.serialize(
      object.minimumAppVersion,
      specifiedType: const FullType(String),
    );
    if (object.signature != null) {
      yield r'signature';
      yield serializers.serialize(
        object.signature,
        specifiedType: const FullType(String),
      );
    }
    yield r'packages';
    yield serializers.serialize(
      object.packages,
      specifiedType: const FullType(BuiltList, [FullType(ContentPackage)]),
    );
  }

  @override
  Object serialize(
    Serializers serializers,
    ContentManifest object, {
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
    required ContentManifestBuilder result,
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
        case r'schemaVersion':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType(String),
          ) as String;
          result.schemaVersion = valueDes;
          break;
        case r'minimumAppVersion':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType(String),
          ) as String;
          result.minimumAppVersion = valueDes;
          break;
        case r'signature':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType.nullable(String),
          ) as String?;
          if (valueDes == null) continue;
          result.signature = valueDes;
          break;
        case r'packages':
          final valueDes = serializers.deserialize(
            value,
            specifiedType:
                const FullType(BuiltList, [FullType(ContentPackage)]),
          ) as BuiltList<ContentPackage>;
          result.packages.replace(valueDes);
          break;
        default:
          unhandled.add(key);
          unhandled.add(value);
          break;
      }
    }
  }

  @override
  ContentManifest deserialize(
    Serializers serializers,
    Object serialized, {
    FullType specifiedType = FullType.unspecified,
  }) {
    final result = ContentManifestBuilder();
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
