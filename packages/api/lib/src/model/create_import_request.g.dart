// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'create_import_request.dart';

// **************************************************************************
// BuiltValueGenerator
// **************************************************************************

const CreateImportRequestKindEnum _$createImportRequestKindEnum_plants =
    const CreateImportRequestKindEnum._('plants');
const CreateImportRequestKindEnum _$createImportRequestKindEnum_quizItems =
    const CreateImportRequestKindEnum._('quizItems');
const CreateImportRequestKindEnum _$createImportRequestKindEnum_translations =
    const CreateImportRequestKindEnum._('translations');

CreateImportRequestKindEnum _$createImportRequestKindEnumValueOf(String name) {
  switch (name) {
    case 'plants':
      return _$createImportRequestKindEnum_plants;
    case 'quizItems':
      return _$createImportRequestKindEnum_quizItems;
    case 'translations':
      return _$createImportRequestKindEnum_translations;
    default:
      throw ArgumentError(name);
  }
}

final BuiltSet<CreateImportRequestKindEnum>
    _$createImportRequestKindEnumValues =
    BuiltSet<CreateImportRequestKindEnum>(const <CreateImportRequestKindEnum>[
  _$createImportRequestKindEnum_plants,
  _$createImportRequestKindEnum_quizItems,
  _$createImportRequestKindEnum_translations,
]);

Serializer<CreateImportRequestKindEnum>
    _$createImportRequestKindEnumSerializer =
    _$CreateImportRequestKindEnumSerializer();

class _$CreateImportRequestKindEnumSerializer
    implements PrimitiveSerializer<CreateImportRequestKindEnum> {
  static const Map<String, Object> _toWire = const <String, Object>{
    'plants': 'plants',
    'quizItems': 'quiz_items',
    'translations': 'translations',
  };
  static const Map<Object, String> _fromWire = const <Object, String>{
    'plants': 'plants',
    'quiz_items': 'quizItems',
    'translations': 'translations',
  };

  @override
  final Iterable<Type> types = const <Type>[CreateImportRequestKindEnum];
  @override
  final String wireName = 'CreateImportRequestKindEnum';

  @override
  Object serialize(Serializers serializers, CreateImportRequestKindEnum object,
          {FullType specifiedType = FullType.unspecified}) =>
      _toWire[object.name] ?? object.name;

  @override
  CreateImportRequestKindEnum deserialize(
          Serializers serializers, Object serialized,
          {FullType specifiedType = FullType.unspecified}) =>
      CreateImportRequestKindEnum.valueOf(
          _fromWire[serialized] ?? (serialized is String ? serialized : ''));
}

class _$CreateImportRequest extends CreateImportRequest {
  @override
  final CreateImportRequestKindEnum kind;
  @override
  final String sourceVersion;
  @override
  final bool? dryRun;

  factory _$CreateImportRequest(
          [void Function(CreateImportRequestBuilder)? updates]) =>
      (CreateImportRequestBuilder()..update(updates))._build();

  _$CreateImportRequest._(
      {required this.kind, required this.sourceVersion, this.dryRun})
      : super._();
  @override
  CreateImportRequest rebuild(
          void Function(CreateImportRequestBuilder) updates) =>
      (toBuilder()..update(updates)).build();

  @override
  CreateImportRequestBuilder toBuilder() =>
      CreateImportRequestBuilder()..replace(this);

  @override
  bool operator ==(Object other) {
    if (identical(other, this)) return true;
    return other is CreateImportRequest &&
        kind == other.kind &&
        sourceVersion == other.sourceVersion &&
        dryRun == other.dryRun;
  }

  @override
  int get hashCode {
    var _$hash = 0;
    _$hash = $jc(_$hash, kind.hashCode);
    _$hash = $jc(_$hash, sourceVersion.hashCode);
    _$hash = $jc(_$hash, dryRun.hashCode);
    _$hash = $jf(_$hash);
    return _$hash;
  }

  @override
  String toString() {
    return (newBuiltValueToStringHelper(r'CreateImportRequest')
          ..add('kind', kind)
          ..add('sourceVersion', sourceVersion)
          ..add('dryRun', dryRun))
        .toString();
  }
}

class CreateImportRequestBuilder
    implements Builder<CreateImportRequest, CreateImportRequestBuilder> {
  _$CreateImportRequest? _$v;

  CreateImportRequestKindEnum? _kind;
  CreateImportRequestKindEnum? get kind => _$this._kind;
  set kind(CreateImportRequestKindEnum? kind) => _$this._kind = kind;

  String? _sourceVersion;
  String? get sourceVersion => _$this._sourceVersion;
  set sourceVersion(String? sourceVersion) =>
      _$this._sourceVersion = sourceVersion;

  bool? _dryRun;
  bool? get dryRun => _$this._dryRun;
  set dryRun(bool? dryRun) => _$this._dryRun = dryRun;

  CreateImportRequestBuilder() {
    CreateImportRequest._defaults(this);
  }

  CreateImportRequestBuilder get _$this {
    final $v = _$v;
    if ($v != null) {
      _kind = $v.kind;
      _sourceVersion = $v.sourceVersion;
      _dryRun = $v.dryRun;
      _$v = null;
    }
    return this;
  }

  @override
  void replace(CreateImportRequest other) {
    _$v = other as _$CreateImportRequest;
  }

  @override
  void update(void Function(CreateImportRequestBuilder)? updates) {
    if (updates != null) updates(this);
  }

  @override
  CreateImportRequest build() => _build();

  _$CreateImportRequest _build() {
    final _$result = _$v ??
        _$CreateImportRequest._(
          kind: BuiltValueNullFieldError.checkNotNull(
              kind, r'CreateImportRequest', 'kind'),
          sourceVersion: BuiltValueNullFieldError.checkNotNull(
              sourceVersion, r'CreateImportRequest', 'sourceVersion'),
          dryRun: dryRun,
        );
    replace(_$result);
    return _$result;
  }
}

// ignore_for_file: deprecated_member_use_from_same_package,type=lint
