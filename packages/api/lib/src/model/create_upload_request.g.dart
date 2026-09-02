// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'create_upload_request.dart';

// **************************************************************************
// BuiltValueGenerator
// **************************************************************************

const CreateUploadRequestContentTypeEnum
    _$createUploadRequestContentTypeEnum_imageSlashJpeg =
    const CreateUploadRequestContentTypeEnum._('imageSlashJpeg');
const CreateUploadRequestContentTypeEnum
    _$createUploadRequestContentTypeEnum_imageSlashPng =
    const CreateUploadRequestContentTypeEnum._('imageSlashPng');

CreateUploadRequestContentTypeEnum _$createUploadRequestContentTypeEnumValueOf(
    String name) {
  switch (name) {
    case 'imageSlashJpeg':
      return _$createUploadRequestContentTypeEnum_imageSlashJpeg;
    case 'imageSlashPng':
      return _$createUploadRequestContentTypeEnum_imageSlashPng;
    default:
      throw ArgumentError(name);
  }
}

final BuiltSet<CreateUploadRequestContentTypeEnum>
    _$createUploadRequestContentTypeEnumValues = BuiltSet<
        CreateUploadRequestContentTypeEnum>(const <CreateUploadRequestContentTypeEnum>[
  _$createUploadRequestContentTypeEnum_imageSlashJpeg,
  _$createUploadRequestContentTypeEnum_imageSlashPng,
]);

Serializer<CreateUploadRequestContentTypeEnum>
    _$createUploadRequestContentTypeEnumSerializer =
    _$CreateUploadRequestContentTypeEnumSerializer();

class _$CreateUploadRequestContentTypeEnumSerializer
    implements PrimitiveSerializer<CreateUploadRequestContentTypeEnum> {
  static const Map<String, Object> _toWire = const <String, Object>{
    'imageSlashJpeg': 'image/jpeg',
    'imageSlashPng': 'image/png',
  };
  static const Map<Object, String> _fromWire = const <Object, String>{
    'image/jpeg': 'imageSlashJpeg',
    'image/png': 'imageSlashPng',
  };

  @override
  final Iterable<Type> types = const <Type>[CreateUploadRequestContentTypeEnum];
  @override
  final String wireName = 'CreateUploadRequestContentTypeEnum';

  @override
  Object serialize(
          Serializers serializers, CreateUploadRequestContentTypeEnum object,
          {FullType specifiedType = FullType.unspecified}) =>
      _toWire[object.name] ?? object.name;

  @override
  CreateUploadRequestContentTypeEnum deserialize(
          Serializers serializers, Object serialized,
          {FullType specifiedType = FullType.unspecified}) =>
      CreateUploadRequestContentTypeEnum.valueOf(
          _fromWire[serialized] ?? (serialized is String ? serialized : ''));
}

class _$CreateUploadRequest extends CreateUploadRequest {
  @override
  final String clientMediaId;
  @override
  final CreateUploadRequestContentTypeEnum contentType;
  @override
  final int bytes;

  factory _$CreateUploadRequest(
          [void Function(CreateUploadRequestBuilder)? updates]) =>
      (CreateUploadRequestBuilder()..update(updates))._build();

  _$CreateUploadRequest._(
      {required this.clientMediaId,
      required this.contentType,
      required this.bytes})
      : super._();
  @override
  CreateUploadRequest rebuild(
          void Function(CreateUploadRequestBuilder) updates) =>
      (toBuilder()..update(updates)).build();

  @override
  CreateUploadRequestBuilder toBuilder() =>
      CreateUploadRequestBuilder()..replace(this);

  @override
  bool operator ==(Object other) {
    if (identical(other, this)) return true;
    return other is CreateUploadRequest &&
        clientMediaId == other.clientMediaId &&
        contentType == other.contentType &&
        bytes == other.bytes;
  }

  @override
  int get hashCode {
    var _$hash = 0;
    _$hash = $jc(_$hash, clientMediaId.hashCode);
    _$hash = $jc(_$hash, contentType.hashCode);
    _$hash = $jc(_$hash, bytes.hashCode);
    _$hash = $jf(_$hash);
    return _$hash;
  }

  @override
  String toString() {
    return (newBuiltValueToStringHelper(r'CreateUploadRequest')
          ..add('clientMediaId', clientMediaId)
          ..add('contentType', contentType)
          ..add('bytes', bytes))
        .toString();
  }
}

class CreateUploadRequestBuilder
    implements Builder<CreateUploadRequest, CreateUploadRequestBuilder> {
  _$CreateUploadRequest? _$v;

  String? _clientMediaId;
  String? get clientMediaId => _$this._clientMediaId;
  set clientMediaId(String? clientMediaId) =>
      _$this._clientMediaId = clientMediaId;

  CreateUploadRequestContentTypeEnum? _contentType;
  CreateUploadRequestContentTypeEnum? get contentType => _$this._contentType;
  set contentType(CreateUploadRequestContentTypeEnum? contentType) =>
      _$this._contentType = contentType;

  int? _bytes;
  int? get bytes => _$this._bytes;
  set bytes(int? bytes) => _$this._bytes = bytes;

  CreateUploadRequestBuilder() {
    CreateUploadRequest._defaults(this);
  }

  CreateUploadRequestBuilder get _$this {
    final $v = _$v;
    if ($v != null) {
      _clientMediaId = $v.clientMediaId;
      _contentType = $v.contentType;
      _bytes = $v.bytes;
      _$v = null;
    }
    return this;
  }

  @override
  void replace(CreateUploadRequest other) {
    _$v = other as _$CreateUploadRequest;
  }

  @override
  void update(void Function(CreateUploadRequestBuilder)? updates) {
    if (updates != null) updates(this);
  }

  @override
  CreateUploadRequest build() => _build();

  _$CreateUploadRequest _build() {
    final _$result = _$v ??
        _$CreateUploadRequest._(
          clientMediaId: BuiltValueNullFieldError.checkNotNull(
              clientMediaId, r'CreateUploadRequest', 'clientMediaId'),
          contentType: BuiltValueNullFieldError.checkNotNull(
              contentType, r'CreateUploadRequest', 'contentType'),
          bytes: BuiltValueNullFieldError.checkNotNull(
              bytes, r'CreateUploadRequest', 'bytes'),
        );
    replace(_$result);
    return _$result;
  }
}

// ignore_for_file: deprecated_member_use_from_same_package,type=lint
