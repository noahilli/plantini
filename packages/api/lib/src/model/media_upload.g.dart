// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'media_upload.dart';

// **************************************************************************
// BuiltValueGenerator
// **************************************************************************

const MediaUploadStatusEnum _$mediaUploadStatusEnum_reserved =
    const MediaUploadStatusEnum._('reserved');
const MediaUploadStatusEnum _$mediaUploadStatusEnum_uploaded =
    const MediaUploadStatusEnum._('uploaded');

MediaUploadStatusEnum _$mediaUploadStatusEnumValueOf(String name) {
  switch (name) {
    case 'reserved':
      return _$mediaUploadStatusEnum_reserved;
    case 'uploaded':
      return _$mediaUploadStatusEnum_uploaded;
    default:
      throw ArgumentError(name);
  }
}

final BuiltSet<MediaUploadStatusEnum> _$mediaUploadStatusEnumValues =
    BuiltSet<MediaUploadStatusEnum>(const <MediaUploadStatusEnum>[
  _$mediaUploadStatusEnum_reserved,
  _$mediaUploadStatusEnum_uploaded,
]);

Serializer<MediaUploadStatusEnum> _$mediaUploadStatusEnumSerializer =
    _$MediaUploadStatusEnumSerializer();

class _$MediaUploadStatusEnumSerializer
    implements PrimitiveSerializer<MediaUploadStatusEnum> {
  static const Map<String, Object> _toWire = const <String, Object>{
    'reserved': 'reserved',
    'uploaded': 'uploaded',
  };
  static const Map<Object, String> _fromWire = const <Object, String>{
    'reserved': 'reserved',
    'uploaded': 'uploaded',
  };

  @override
  final Iterable<Type> types = const <Type>[MediaUploadStatusEnum];
  @override
  final String wireName = 'MediaUploadStatusEnum';

  @override
  Object serialize(Serializers serializers, MediaUploadStatusEnum object,
          {FullType specifiedType = FullType.unspecified}) =>
      _toWire[object.name] ?? object.name;

  @override
  MediaUploadStatusEnum deserialize(Serializers serializers, Object serialized,
          {FullType specifiedType = FullType.unspecified}) =>
      MediaUploadStatusEnum.valueOf(
          _fromWire[serialized] ?? (serialized is String ? serialized : ''));
}

class _$MediaUpload extends MediaUpload {
  @override
  final String id;
  @override
  final String? uploadUrl;
  @override
  final DateTime expiresAt;
  @override
  final MediaUploadStatusEnum status;

  factory _$MediaUpload([void Function(MediaUploadBuilder)? updates]) =>
      (MediaUploadBuilder()..update(updates))._build();

  _$MediaUpload._(
      {required this.id,
      this.uploadUrl,
      required this.expiresAt,
      required this.status})
      : super._();
  @override
  MediaUpload rebuild(void Function(MediaUploadBuilder) updates) =>
      (toBuilder()..update(updates)).build();

  @override
  MediaUploadBuilder toBuilder() => MediaUploadBuilder()..replace(this);

  @override
  bool operator ==(Object other) {
    if (identical(other, this)) return true;
    return other is MediaUpload &&
        id == other.id &&
        uploadUrl == other.uploadUrl &&
        expiresAt == other.expiresAt &&
        status == other.status;
  }

  @override
  int get hashCode {
    var _$hash = 0;
    _$hash = $jc(_$hash, id.hashCode);
    _$hash = $jc(_$hash, uploadUrl.hashCode);
    _$hash = $jc(_$hash, expiresAt.hashCode);
    _$hash = $jc(_$hash, status.hashCode);
    _$hash = $jf(_$hash);
    return _$hash;
  }

  @override
  String toString() {
    return (newBuiltValueToStringHelper(r'MediaUpload')
          ..add('id', id)
          ..add('uploadUrl', uploadUrl)
          ..add('expiresAt', expiresAt)
          ..add('status', status))
        .toString();
  }
}

class MediaUploadBuilder implements Builder<MediaUpload, MediaUploadBuilder> {
  _$MediaUpload? _$v;

  String? _id;
  String? get id => _$this._id;
  set id(String? id) => _$this._id = id;

  String? _uploadUrl;
  String? get uploadUrl => _$this._uploadUrl;
  set uploadUrl(String? uploadUrl) => _$this._uploadUrl = uploadUrl;

  DateTime? _expiresAt;
  DateTime? get expiresAt => _$this._expiresAt;
  set expiresAt(DateTime? expiresAt) => _$this._expiresAt = expiresAt;

  MediaUploadStatusEnum? _status;
  MediaUploadStatusEnum? get status => _$this._status;
  set status(MediaUploadStatusEnum? status) => _$this._status = status;

  MediaUploadBuilder() {
    MediaUpload._defaults(this);
  }

  MediaUploadBuilder get _$this {
    final $v = _$v;
    if ($v != null) {
      _id = $v.id;
      _uploadUrl = $v.uploadUrl;
      _expiresAt = $v.expiresAt;
      _status = $v.status;
      _$v = null;
    }
    return this;
  }

  @override
  void replace(MediaUpload other) {
    _$v = other as _$MediaUpload;
  }

  @override
  void update(void Function(MediaUploadBuilder)? updates) {
    if (updates != null) updates(this);
  }

  @override
  MediaUpload build() => _build();

  _$MediaUpload _build() {
    final _$result = _$v ??
        _$MediaUpload._(
          id: BuiltValueNullFieldError.checkNotNull(id, r'MediaUpload', 'id'),
          uploadUrl: uploadUrl,
          expiresAt: BuiltValueNullFieldError.checkNotNull(
              expiresAt, r'MediaUpload', 'expiresAt'),
          status: BuiltValueNullFieldError.checkNotNull(
              status, r'MediaUpload', 'status'),
        );
    replace(_$result);
    return _$result;
  }
}

// ignore_for_file: deprecated_member_use_from_same_package,type=lint
