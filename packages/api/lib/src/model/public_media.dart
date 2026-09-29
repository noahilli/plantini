//
// AUTO-GENERATED FILE, DO NOT MODIFY!
//

// ignore_for_file: unused_element
import 'package:built_value/built_value.dart';
import 'package:built_value/serializer.dart';

part 'public_media.g.dart';

/// PublicMedia
///
/// Properties:
/// * [id]
/// * [url]
/// * [altText]
/// * [license]
/// * [author]
/// * [source_] - Original image description and attribution page
/// * [licenseUrl]
/// * [automatic] - Supplemental provider image not editorially reviewed or part of the immutable release
@BuiltValue()
abstract class PublicMedia implements Built<PublicMedia, PublicMediaBuilder> {
  @BuiltValueField(wireName: r'id')
  String get id;

  @BuiltValueField(wireName: r'url')
  String get url;

  @BuiltValueField(wireName: r'altText')
  String get altText;

  @BuiltValueField(wireName: r'license')
  String get license;

  @BuiltValueField(wireName: r'author')
  String get author;

  /// Original image description and attribution page
  @BuiltValueField(wireName: r'source')
  String? get source_;

  @BuiltValueField(wireName: r'licenseUrl')
  String? get licenseUrl;

  /// Supplemental provider image not editorially reviewed or part of the immutable release
  @BuiltValueField(wireName: r'automatic')
  bool? get automatic;

  PublicMedia._();

  factory PublicMedia([void updates(PublicMediaBuilder b)]) = _$PublicMedia;

  @BuiltValueHook(initializeBuilder: true)
  static void _defaults(PublicMediaBuilder b) => b..automatic = false;

  @BuiltValueSerializer(custom: true)
  static Serializer<PublicMedia> get serializer => _$PublicMediaSerializer();
}

class _$PublicMediaSerializer implements PrimitiveSerializer<PublicMedia> {
  @override
  final Iterable<Type> types = const [PublicMedia, _$PublicMedia];

  @override
  final String wireName = r'PublicMedia';

  Iterable<Object?> _serializeProperties(
    Serializers serializers,
    PublicMedia object, {
    FullType specifiedType = FullType.unspecified,
  }) sync* {
    yield r'id';
    yield serializers.serialize(
      object.id,
      specifiedType: const FullType(String),
    );
    yield r'url';
    yield serializers.serialize(
      object.url,
      specifiedType: const FullType(String),
    );
    yield r'altText';
    yield serializers.serialize(
      object.altText,
      specifiedType: const FullType(String),
    );
    yield r'license';
    yield serializers.serialize(
      object.license,
      specifiedType: const FullType(String),
    );
    yield r'author';
    yield serializers.serialize(
      object.author,
      specifiedType: const FullType(String),
    );
    if (object.source_ != null) {
      yield r'source';
      yield serializers.serialize(
        object.source_,
        specifiedType: const FullType(String),
      );
    }
    if (object.licenseUrl != null) {
      yield r'licenseUrl';
      yield serializers.serialize(
        object.licenseUrl,
        specifiedType: const FullType(String),
      );
    }
    if (object.automatic != null) {
      yield r'automatic';
      yield serializers.serialize(
        object.automatic,
        specifiedType: const FullType(bool),
      );
    }
  }

  @override
  Object serialize(
    Serializers serializers,
    PublicMedia object, {
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
    required PublicMediaBuilder result,
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
        case r'url':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType(String),
          ) as String;
          result.url = valueDes;
          break;
        case r'altText':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType(String),
          ) as String;
          result.altText = valueDes;
          break;
        case r'license':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType(String),
          ) as String;
          result.license = valueDes;
          break;
        case r'author':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType(String),
          ) as String;
          result.author = valueDes;
          break;
        case r'source':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType.nullable(String),
          ) as String?;
          if (valueDes == null) continue;
          result.source_ = valueDes;
          break;
        case r'licenseUrl':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType.nullable(String),
          ) as String?;
          if (valueDes == null) continue;
          result.licenseUrl = valueDes;
          break;
        case r'automatic':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType.nullable(bool),
          ) as bool?;
          if (valueDes == null) continue;
          result.automatic = valueDes;
          break;
        default:
          unhandled.add(key);
          unhandled.add(value);
          break;
      }
    }
  }

  @override
  PublicMedia deserialize(
    Serializers serializers,
    Object serialized, {
    FullType specifiedType = FullType.unspecified,
  }) {
    final result = PublicMediaBuilder();
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
