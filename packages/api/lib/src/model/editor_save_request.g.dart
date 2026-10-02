// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'editor_save_request.dart';

// **************************************************************************
// BuiltValueGenerator
// **************************************************************************

const EditorSaveRequestTypeEnum _$editorSaveRequestTypeEnum_ecosystem =
    const EditorSaveRequestTypeEnum._('ecosystem');
const EditorSaveRequestTypeEnum _$editorSaveRequestTypeEnum_level =
    const EditorSaveRequestTypeEnum._('level');
const EditorSaveRequestTypeEnum _$editorSaveRequestTypeEnum_plant =
    const EditorSaveRequestTypeEnum._('plant');
const EditorSaveRequestTypeEnum _$editorSaveRequestTypeEnum_quiz =
    const EditorSaveRequestTypeEnum._('quiz');

EditorSaveRequestTypeEnum _$editorSaveRequestTypeEnumValueOf(String name) {
  switch (name) {
    case 'ecosystem':
      return _$editorSaveRequestTypeEnum_ecosystem;
    case 'level':
      return _$editorSaveRequestTypeEnum_level;
    case 'plant':
      return _$editorSaveRequestTypeEnum_plant;
    case 'quiz':
      return _$editorSaveRequestTypeEnum_quiz;
    default:
      throw ArgumentError(name);
  }
}

final BuiltSet<EditorSaveRequestTypeEnum> _$editorSaveRequestTypeEnumValues =
    BuiltSet<EditorSaveRequestTypeEnum>(const <EditorSaveRequestTypeEnum>[
  _$editorSaveRequestTypeEnum_ecosystem,
  _$editorSaveRequestTypeEnum_level,
  _$editorSaveRequestTypeEnum_plant,
  _$editorSaveRequestTypeEnum_quiz,
]);

Serializer<EditorSaveRequestTypeEnum> _$editorSaveRequestTypeEnumSerializer =
    _$EditorSaveRequestTypeEnumSerializer();

class _$EditorSaveRequestTypeEnumSerializer
    implements PrimitiveSerializer<EditorSaveRequestTypeEnum> {
  static const Map<String, Object> _toWire = const <String, Object>{
    'ecosystem': 'ecosystem',
    'level': 'level',
    'plant': 'plant',
    'quiz': 'quiz',
  };
  static const Map<Object, String> _fromWire = const <Object, String>{
    'ecosystem': 'ecosystem',
    'level': 'level',
    'plant': 'plant',
    'quiz': 'quiz',
  };

  @override
  final Iterable<Type> types = const <Type>[EditorSaveRequestTypeEnum];
  @override
  final String wireName = 'EditorSaveRequestTypeEnum';

  @override
  Object serialize(Serializers serializers, EditorSaveRequestTypeEnum object,
          {FullType specifiedType = FullType.unspecified}) =>
      _toWire[object.name] ?? object.name;

  @override
  EditorSaveRequestTypeEnum deserialize(
          Serializers serializers, Object serialized,
          {FullType specifiedType = FullType.unspecified}) =>
      EditorSaveRequestTypeEnum.valueOf(
          _fromWire[serialized] ?? (serialized is String ? serialized : ''));
}

class _$EditorSaveRequest extends EditorSaveRequest {
  @override
  final EditorSaveRequestTypeEnum type;
  @override
  final String? targetId;
  @override
  final JsonObject data;

  factory _$EditorSaveRequest(
          [void Function(EditorSaveRequestBuilder)? updates]) =>
      (EditorSaveRequestBuilder()..update(updates))._build();

  _$EditorSaveRequest._({required this.type, this.targetId, required this.data})
      : super._();
  @override
  EditorSaveRequest rebuild(void Function(EditorSaveRequestBuilder) updates) =>
      (toBuilder()..update(updates)).build();

  @override
  EditorSaveRequestBuilder toBuilder() =>
      EditorSaveRequestBuilder()..replace(this);

  @override
  bool operator ==(Object other) {
    if (identical(other, this)) return true;
    return other is EditorSaveRequest &&
        type == other.type &&
        targetId == other.targetId &&
        data == other.data;
  }

  @override
  int get hashCode {
    var _$hash = 0;
    _$hash = $jc(_$hash, type.hashCode);
    _$hash = $jc(_$hash, targetId.hashCode);
    _$hash = $jc(_$hash, data.hashCode);
    _$hash = $jf(_$hash);
    return _$hash;
  }

  @override
  String toString() {
    return (newBuiltValueToStringHelper(r'EditorSaveRequest')
          ..add('type', type)
          ..add('targetId', targetId)
          ..add('data', data))
        .toString();
  }
}

class EditorSaveRequestBuilder
    implements Builder<EditorSaveRequest, EditorSaveRequestBuilder> {
  _$EditorSaveRequest? _$v;

  EditorSaveRequestTypeEnum? _type;
  EditorSaveRequestTypeEnum? get type => _$this._type;
  set type(EditorSaveRequestTypeEnum? type) => _$this._type = type;

  String? _targetId;
  String? get targetId => _$this._targetId;
  set targetId(String? targetId) => _$this._targetId = targetId;

  JsonObject? _data;
  JsonObject? get data => _$this._data;
  set data(JsonObject? data) => _$this._data = data;

  EditorSaveRequestBuilder() {
    EditorSaveRequest._defaults(this);
  }

  EditorSaveRequestBuilder get _$this {
    final $v = _$v;
    if ($v != null) {
      _type = $v.type;
      _targetId = $v.targetId;
      _data = $v.data;
      _$v = null;
    }
    return this;
  }

  @override
  void replace(EditorSaveRequest other) {
    _$v = other as _$EditorSaveRequest;
  }

  @override
  void update(void Function(EditorSaveRequestBuilder)? updates) {
    if (updates != null) updates(this);
  }

  @override
  EditorSaveRequest build() => _build();

  _$EditorSaveRequest _build() {
    final _$result = _$v ??
        _$EditorSaveRequest._(
          type: BuiltValueNullFieldError.checkNotNull(
              type, r'EditorSaveRequest', 'type'),
          targetId: targetId,
          data: BuiltValueNullFieldError.checkNotNull(
              data, r'EditorSaveRequest', 'data'),
        );
    replace(_$result);
    return _$result;
  }
}

// ignore_for_file: deprecated_member_use_from_same_package,type=lint
