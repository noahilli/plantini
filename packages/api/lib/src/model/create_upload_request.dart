//
// AUTO-GENERATED FILE, DO NOT MODIFY!
//

// ignore_for_file: unused_element
import 'package:built_collection/built_collection.dart';
import 'package:built_value/built_value.dart';
import 'package:built_value/serializer.dart';

part 'create_upload_request.g.dart';

/// CreateUploadRequest
///
/// Properties:
/// * [clientMediaId]
/// * [contentType]
/// * [bytes]
@BuiltValue()
abstract class CreateUploadRequest
    implements Built<CreateUploadRequest, CreateUploadRequestBuilder> {
  @BuiltValueField(wireName: r'clientMediaId')
  String get clientMediaId;

  @BuiltValueField(wireName: r'contentType')
  CreateUploadRequestContentTypeEnum get contentType;
  // enum contentTypeEnum {  image/jpeg,  image/png,  };

  @BuiltValueField(wireName: r'bytes')
  int get bytes;

  CreateUploadRequest._();

  factory CreateUploadRequest([void updates(CreateUploadRequestBuilder b)]) =
      _$CreateUploadRequest;

  @BuiltValueHook(initializeBuilder: true)
  static void _defaults(CreateUploadRequestBuilder b) => b;

  @BuiltValueSerializer(custom: true)
  static Serializer<CreateUploadRequest> get serializer =>
      _$CreateUploadRequestSerializer();
}

class _$CreateUploadRequestSerializer
    implements PrimitiveSerializer<CreateUploadRequest> {
  @override
  final Iterable<Type> types = const [
    CreateUploadRequest,
    _$CreateUploadRequest
  ];

  @override
  final String wireName = r'CreateUploadRequest';

  Iterable<Object?> _serializeProperties(
    Serializers serializers,
    CreateUploadRequest object, {
    FullType specifiedType = FullType.unspecified,
  }) sync* {
    yield r'clientMediaId';
    yield serializers.serialize(
      object.clientMediaId,
      specifiedType: const FullType(String),
    );
    yield r'contentType';
    yield serializers.serialize(
      object.contentType,
      specifiedType: const FullType(CreateUploadRequestContentTypeEnum),
    );
    yield r'bytes';
    yield serializers.serialize(
      object.bytes,
      specifiedType: const FullType(int),
    );
  }

  @override
  Object serialize(
    Serializers serializers,
    CreateUploadRequest object, {
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
    required CreateUploadRequestBuilder result,
    required List<Object?> unhandled,
  }) {
    for (var i = 0; i < serializedList.length; i += 2) {
      final key = serializedList[i] as String;
      final value = serializedList[i + 1];
      switch (key) {
        case r'clientMediaId':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType(String),
          ) as String;
          result.clientMediaId = valueDes;
          break;
        case r'contentType':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType(CreateUploadRequestContentTypeEnum),
          ) as CreateUploadRequestContentTypeEnum;
          result.contentType = valueDes;
          break;
        case r'bytes':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType(int),
          ) as int;
          result.bytes = valueDes;
          break;
        default:
          unhandled.add(key);
          unhandled.add(value);
          break;
      }
    }
  }

  @override
  CreateUploadRequest deserialize(
    Serializers serializers,
    Object serialized, {
    FullType specifiedType = FullType.unspecified,
  }) {
    final result = CreateUploadRequestBuilder();
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

class CreateUploadRequestContentTypeEnum extends EnumClass {
  @BuiltValueEnumConst(wireName: r'image/jpeg')
  static const CreateUploadRequestContentTypeEnum imageSlashJpeg =
      _$createUploadRequestContentTypeEnum_imageSlashJpeg;
  @BuiltValueEnumConst(wireName: r'image/png')
  static const CreateUploadRequestContentTypeEnum imageSlashPng =
      _$createUploadRequestContentTypeEnum_imageSlashPng;

  static Serializer<CreateUploadRequestContentTypeEnum> get serializer =>
      _$createUploadRequestContentTypeEnumSerializer;

  const CreateUploadRequestContentTypeEnum._(String name) : super(name);

  static BuiltSet<CreateUploadRequestContentTypeEnum> get values =>
      _$createUploadRequestContentTypeEnumValues;
  static CreateUploadRequestContentTypeEnum valueOf(String name) =>
      _$createUploadRequestContentTypeEnumValueOf(name);
}
