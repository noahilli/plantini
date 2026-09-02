// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'content_change.dart';

// **************************************************************************
// BuiltValueGenerator
// **************************************************************************

const ContentChangeEntityEnum _$contentChangeEntityEnum_ecosystem =
    const ContentChangeEntityEnum._('ecosystem');
const ContentChangeEntityEnum _$contentChangeEntityEnum_level =
    const ContentChangeEntityEnum._('level');
const ContentChangeEntityEnum _$contentChangeEntityEnum_plant =
    const ContentChangeEntityEnum._('plant');
const ContentChangeEntityEnum _$contentChangeEntityEnum_quizItem =
    const ContentChangeEntityEnum._('quizItem');
const ContentChangeEntityEnum _$contentChangeEntityEnum_media =
    const ContentChangeEntityEnum._('media');

ContentChangeEntityEnum _$contentChangeEntityEnumValueOf(String name) {
  switch (name) {
    case 'ecosystem':
      return _$contentChangeEntityEnum_ecosystem;
    case 'level':
      return _$contentChangeEntityEnum_level;
    case 'plant':
      return _$contentChangeEntityEnum_plant;
    case 'quizItem':
      return _$contentChangeEntityEnum_quizItem;
    case 'media':
      return _$contentChangeEntityEnum_media;
    default:
      throw ArgumentError(name);
  }
}

final BuiltSet<ContentChangeEntityEnum> _$contentChangeEntityEnumValues =
    BuiltSet<ContentChangeEntityEnum>(const <ContentChangeEntityEnum>[
  _$contentChangeEntityEnum_ecosystem,
  _$contentChangeEntityEnum_level,
  _$contentChangeEntityEnum_plant,
  _$contentChangeEntityEnum_quizItem,
  _$contentChangeEntityEnum_media,
]);

const ContentChangeOperationEnum _$contentChangeOperationEnum_upsert =
    const ContentChangeOperationEnum._('upsert');
const ContentChangeOperationEnum _$contentChangeOperationEnum_delete =
    const ContentChangeOperationEnum._('delete');

ContentChangeOperationEnum _$contentChangeOperationEnumValueOf(String name) {
  switch (name) {
    case 'upsert':
      return _$contentChangeOperationEnum_upsert;
    case 'delete':
      return _$contentChangeOperationEnum_delete;
    default:
      throw ArgumentError(name);
  }
}

final BuiltSet<ContentChangeOperationEnum> _$contentChangeOperationEnumValues =
    BuiltSet<ContentChangeOperationEnum>(const <ContentChangeOperationEnum>[
  _$contentChangeOperationEnum_upsert,
  _$contentChangeOperationEnum_delete,
]);

Serializer<ContentChangeEntityEnum> _$contentChangeEntityEnumSerializer =
    _$ContentChangeEntityEnumSerializer();
Serializer<ContentChangeOperationEnum> _$contentChangeOperationEnumSerializer =
    _$ContentChangeOperationEnumSerializer();

class _$ContentChangeEntityEnumSerializer
    implements PrimitiveSerializer<ContentChangeEntityEnum> {
  static const Map<String, Object> _toWire = const <String, Object>{
    'ecosystem': 'ecosystem',
    'level': 'level',
    'plant': 'plant',
    'quizItem': 'quiz_item',
    'media': 'media',
  };
  static const Map<Object, String> _fromWire = const <Object, String>{
    'ecosystem': 'ecosystem',
    'level': 'level',
    'plant': 'plant',
    'quiz_item': 'quizItem',
    'media': 'media',
  };

  @override
  final Iterable<Type> types = const <Type>[ContentChangeEntityEnum];
  @override
  final String wireName = 'ContentChangeEntityEnum';

  @override
  Object serialize(Serializers serializers, ContentChangeEntityEnum object,
          {FullType specifiedType = FullType.unspecified}) =>
      _toWire[object.name] ?? object.name;

  @override
  ContentChangeEntityEnum deserialize(
          Serializers serializers, Object serialized,
          {FullType specifiedType = FullType.unspecified}) =>
      ContentChangeEntityEnum.valueOf(
          _fromWire[serialized] ?? (serialized is String ? serialized : ''));
}

class _$ContentChangeOperationEnumSerializer
    implements PrimitiveSerializer<ContentChangeOperationEnum> {
  static const Map<String, Object> _toWire = const <String, Object>{
    'upsert': 'upsert',
    'delete': 'delete',
  };
  static const Map<Object, String> _fromWire = const <Object, String>{
    'upsert': 'upsert',
    'delete': 'delete',
  };

  @override
  final Iterable<Type> types = const <Type>[ContentChangeOperationEnum];
  @override
  final String wireName = 'ContentChangeOperationEnum';

  @override
  Object serialize(Serializers serializers, ContentChangeOperationEnum object,
          {FullType specifiedType = FullType.unspecified}) =>
      _toWire[object.name] ?? object.name;

  @override
  ContentChangeOperationEnum deserialize(
          Serializers serializers, Object serialized,
          {FullType specifiedType = FullType.unspecified}) =>
      ContentChangeOperationEnum.valueOf(
          _fromWire[serialized] ?? (serialized is String ? serialized : ''));
}

class _$ContentChange extends ContentChange {
  @override
  final ContentChangeEntityEnum entity;
  @override
  final String id;
  @override
  final ContentChangeOperationEnum operation;
  @override
  final String version;

  factory _$ContentChange([void Function(ContentChangeBuilder)? updates]) =>
      (ContentChangeBuilder()..update(updates))._build();

  _$ContentChange._(
      {required this.entity,
      required this.id,
      required this.operation,
      required this.version})
      : super._();
  @override
  ContentChange rebuild(void Function(ContentChangeBuilder) updates) =>
      (toBuilder()..update(updates)).build();

  @override
  ContentChangeBuilder toBuilder() => ContentChangeBuilder()..replace(this);

  @override
  bool operator ==(Object other) {
    if (identical(other, this)) return true;
    return other is ContentChange &&
        entity == other.entity &&
        id == other.id &&
        operation == other.operation &&
        version == other.version;
  }

  @override
  int get hashCode {
    var _$hash = 0;
    _$hash = $jc(_$hash, entity.hashCode);
    _$hash = $jc(_$hash, id.hashCode);
    _$hash = $jc(_$hash, operation.hashCode);
    _$hash = $jc(_$hash, version.hashCode);
    _$hash = $jf(_$hash);
    return _$hash;
  }

  @override
  String toString() {
    return (newBuiltValueToStringHelper(r'ContentChange')
          ..add('entity', entity)
          ..add('id', id)
          ..add('operation', operation)
          ..add('version', version))
        .toString();
  }
}

class ContentChangeBuilder
    implements Builder<ContentChange, ContentChangeBuilder> {
  _$ContentChange? _$v;

  ContentChangeEntityEnum? _entity;
  ContentChangeEntityEnum? get entity => _$this._entity;
  set entity(ContentChangeEntityEnum? entity) => _$this._entity = entity;

  String? _id;
  String? get id => _$this._id;
  set id(String? id) => _$this._id = id;

  ContentChangeOperationEnum? _operation;
  ContentChangeOperationEnum? get operation => _$this._operation;
  set operation(ContentChangeOperationEnum? operation) =>
      _$this._operation = operation;

  String? _version;
  String? get version => _$this._version;
  set version(String? version) => _$this._version = version;

  ContentChangeBuilder() {
    ContentChange._defaults(this);
  }

  ContentChangeBuilder get _$this {
    final $v = _$v;
    if ($v != null) {
      _entity = $v.entity;
      _id = $v.id;
      _operation = $v.operation;
      _version = $v.version;
      _$v = null;
    }
    return this;
  }

  @override
  void replace(ContentChange other) {
    _$v = other as _$ContentChange;
  }

  @override
  void update(void Function(ContentChangeBuilder)? updates) {
    if (updates != null) updates(this);
  }

  @override
  ContentChange build() => _build();

  _$ContentChange _build() {
    final _$result = _$v ??
        _$ContentChange._(
          entity: BuiltValueNullFieldError.checkNotNull(
              entity, r'ContentChange', 'entity'),
          id: BuiltValueNullFieldError.checkNotNull(id, r'ContentChange', 'id'),
          operation: BuiltValueNullFieldError.checkNotNull(
              operation, r'ContentChange', 'operation'),
          version: BuiltValueNullFieldError.checkNotNull(
              version, r'ContentChange', 'version'),
        );
    replace(_$result);
    return _$result;
  }
}

// ignore_for_file: deprecated_member_use_from_same_package,type=lint
