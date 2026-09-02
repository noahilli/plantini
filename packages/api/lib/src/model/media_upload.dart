//
// AUTO-GENERATED FILE, DO NOT MODIFY!
//

// ignore_for_file: unused_element
import 'package:built_collection/built_collection.dart';
import 'package:built_value/built_value.dart';
import 'package:built_value/serializer.dart';

part 'media_upload.g.dart';

/// MediaUpload
///
/// Properties:
/// * [id]
/// * [uploadUrl] - Present only while the reservation is writable.
/// * [expiresAt]
/// * [status]
@BuiltValue()
abstract class MediaUpload implements Built<MediaUpload, MediaUploadBuilder> {
  @BuiltValueField(wireName: r'id')
  String get id;

  /// Present only while the reservation is writable.
  @BuiltValueField(wireName: r'uploadUrl')
  String? get uploadUrl;

  @BuiltValueField(wireName: r'expiresAt')
  DateTime get expiresAt;

  @BuiltValueField(wireName: r'status')
  MediaUploadStatusEnum get status;
  // enum statusEnum {  reserved,  uploaded,  };

  MediaUpload._();

  factory MediaUpload([void updates(MediaUploadBuilder b)]) = _$MediaUpload;

  @BuiltValueHook(initializeBuilder: true)
  static void _defaults(MediaUploadBuilder b) => b;

  @BuiltValueSerializer(custom: true)
  static Serializer<MediaUpload> get serializer => _$MediaUploadSerializer();
}

class _$MediaUploadSerializer implements PrimitiveSerializer<MediaUpload> {
  @override
  final Iterable<Type> types = const [MediaUpload, _$MediaUpload];

  @override
  final String wireName = r'MediaUpload';

  Iterable<Object?> _serializeProperties(
    Serializers serializers,
    MediaUpload object, {
    FullType specifiedType = FullType.unspecified,
  }) sync* {
    yield r'id';
    yield serializers.serialize(
      object.id,
      specifiedType: const FullType(String),
    );
    if (object.uploadUrl != null) {
      yield r'uploadUrl';
      yield serializers.serialize(
        object.uploadUrl,
        specifiedType: const FullType(String),
      );
    }
    yield r'expiresAt';
    yield serializers.serialize(
      object.expiresAt,
      specifiedType: const FullType(DateTime),
    );
    yield r'status';
    yield serializers.serialize(
      object.status,
      specifiedType: const FullType(MediaUploadStatusEnum),
    );
  }

  @override
  Object serialize(
    Serializers serializers,
    MediaUpload object, {
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
    required MediaUploadBuilder result,
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
        case r'uploadUrl':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType.nullable(String),
          ) as String?;
          if (valueDes == null) continue;
          result.uploadUrl = valueDes;
          break;
        case r'expiresAt':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType(DateTime),
          ) as DateTime;
          result.expiresAt = valueDes;
          break;
        case r'status':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType(MediaUploadStatusEnum),
          ) as MediaUploadStatusEnum;
          result.status = valueDes;
          break;
        default:
          unhandled.add(key);
          unhandled.add(value);
          break;
      }
    }
  }

  @override
  MediaUpload deserialize(
    Serializers serializers,
    Object serialized, {
    FullType specifiedType = FullType.unspecified,
  }) {
    final result = MediaUploadBuilder();
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

class MediaUploadStatusEnum extends EnumClass {
  @BuiltValueEnumConst(wireName: r'reserved')
  static const MediaUploadStatusEnum reserved =
      _$mediaUploadStatusEnum_reserved;
  @BuiltValueEnumConst(wireName: r'uploaded')
  static const MediaUploadStatusEnum uploaded =
      _$mediaUploadStatusEnum_uploaded;

  static Serializer<MediaUploadStatusEnum> get serializer =>
      _$mediaUploadStatusEnumSerializer;

  const MediaUploadStatusEnum._(String name) : super(name);

  static BuiltSet<MediaUploadStatusEnum> get values =>
      _$mediaUploadStatusEnumValues;
  static MediaUploadStatusEnum valueOf(String name) =>
      _$mediaUploadStatusEnumValueOf(name);
}
