//
// AUTO-GENERATED FILE, DO NOT MODIFY!
//

// ignore_for_file: unused_element
import 'package:openapi/src/model/collection_share.dart';
import 'package:openapi/src/model/public_media.dart';
import 'package:built_value/built_value.dart';
import 'package:built_value/serializer.dart';

part 'species_card.g.dart';

/// SpeciesCard
///
/// Properties:
/// * [key]
/// * [scientificName]
/// * [commonName]
/// * [summary]
/// * [summaryLanguage]
/// * [summarySource] - Article the summary was taken from (Wikipedia).
/// * [summaryLicense]
/// * [photo]
/// * [collectedShare]
@BuiltValue()
abstract class SpeciesCard implements Built<SpeciesCard, SpeciesCardBuilder> {
  @BuiltValueField(wireName: r'key')
  String get key;

  @BuiltValueField(wireName: r'scientificName')
  String get scientificName;

  @BuiltValueField(wireName: r'commonName')
  String? get commonName;

  @BuiltValueField(wireName: r'summary')
  String? get summary;

  @BuiltValueField(wireName: r'summaryLanguage')
  String? get summaryLanguage;

  /// Article the summary was taken from (Wikipedia).
  @BuiltValueField(wireName: r'summarySource')
  String? get summarySource;

  @BuiltValueField(wireName: r'summaryLicense')
  String? get summaryLicense;

  @BuiltValueField(wireName: r'photo')
  PublicMedia? get photo;

  @BuiltValueField(wireName: r'collectedShare')
  CollectionShare? get collectedShare;

  SpeciesCard._();

  factory SpeciesCard([void updates(SpeciesCardBuilder b)]) = _$SpeciesCard;

  @BuiltValueHook(initializeBuilder: true)
  static void _defaults(SpeciesCardBuilder b) => b;

  @BuiltValueSerializer(custom: true)
  static Serializer<SpeciesCard> get serializer => _$SpeciesCardSerializer();
}

class _$SpeciesCardSerializer implements PrimitiveSerializer<SpeciesCard> {
  @override
  final Iterable<Type> types = const [SpeciesCard, _$SpeciesCard];

  @override
  final String wireName = r'SpeciesCard';

  Iterable<Object?> _serializeProperties(
    Serializers serializers,
    SpeciesCard object, {
    FullType specifiedType = FullType.unspecified,
  }) sync* {
    yield r'key';
    yield serializers.serialize(
      object.key,
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
    if (object.summary != null) {
      yield r'summary';
      yield serializers.serialize(
        object.summary,
        specifiedType: const FullType(String),
      );
    }
    if (object.summaryLanguage != null) {
      yield r'summaryLanguage';
      yield serializers.serialize(
        object.summaryLanguage,
        specifiedType: const FullType(String),
      );
    }
    if (object.summarySource != null) {
      yield r'summarySource';
      yield serializers.serialize(
        object.summarySource,
        specifiedType: const FullType(String),
      );
    }
    if (object.summaryLicense != null) {
      yield r'summaryLicense';
      yield serializers.serialize(
        object.summaryLicense,
        specifiedType: const FullType(String),
      );
    }
    if (object.photo != null) {
      yield r'photo';
      yield serializers.serialize(
        object.photo,
        specifiedType: const FullType(PublicMedia),
      );
    }
    if (object.collectedShare != null) {
      yield r'collectedShare';
      yield serializers.serialize(
        object.collectedShare,
        specifiedType: const FullType(CollectionShare),
      );
    }
  }

  @override
  Object serialize(
    Serializers serializers,
    SpeciesCard object, {
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
    required SpeciesCardBuilder result,
    required List<Object?> unhandled,
  }) {
    for (var i = 0; i < serializedList.length; i += 2) {
      final key = serializedList[i] as String;
      final value = serializedList[i + 1];
      switch (key) {
        case r'key':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType(String),
          ) as String;
          result.key = valueDes;
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
        case r'summary':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType.nullable(String),
          ) as String?;
          if (valueDes == null) continue;
          result.summary = valueDes;
          break;
        case r'summaryLanguage':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType.nullable(String),
          ) as String?;
          if (valueDes == null) continue;
          result.summaryLanguage = valueDes;
          break;
        case r'summarySource':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType.nullable(String),
          ) as String?;
          if (valueDes == null) continue;
          result.summarySource = valueDes;
          break;
        case r'summaryLicense':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType.nullable(String),
          ) as String?;
          if (valueDes == null) continue;
          result.summaryLicense = valueDes;
          break;
        case r'photo':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType.nullable(PublicMedia),
          ) as PublicMedia?;
          if (valueDes == null) continue;
          result.photo.replace(valueDes);
          break;
        case r'collectedShare':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType.nullable(CollectionShare),
          ) as CollectionShare?;
          if (valueDes == null) continue;
          result.collectedShare.replace(valueDes);
          break;
        default:
          unhandled.add(key);
          unhandled.add(value);
          break;
      }
    }
  }

  @override
  SpeciesCard deserialize(
    Serializers serializers,
    Object serialized, {
    FullType specifiedType = FullType.unspecified,
  }) {
    final result = SpeciesCardBuilder();
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
