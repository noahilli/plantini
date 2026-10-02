// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'editor_change.dart';

// **************************************************************************
// BuiltValueGenerator
// **************************************************************************

const EditorChangeTypeEnum _$editorChangeTypeEnum_ecosystem =
    const EditorChangeTypeEnum._('ecosystem');
const EditorChangeTypeEnum _$editorChangeTypeEnum_level =
    const EditorChangeTypeEnum._('level');
const EditorChangeTypeEnum _$editorChangeTypeEnum_plant =
    const EditorChangeTypeEnum._('plant');
const EditorChangeTypeEnum _$editorChangeTypeEnum_quiz =
    const EditorChangeTypeEnum._('quiz');

EditorChangeTypeEnum _$editorChangeTypeEnumValueOf(String name) {
  switch (name) {
    case 'ecosystem':
      return _$editorChangeTypeEnum_ecosystem;
    case 'level':
      return _$editorChangeTypeEnum_level;
    case 'plant':
      return _$editorChangeTypeEnum_plant;
    case 'quiz':
      return _$editorChangeTypeEnum_quiz;
    default:
      throw ArgumentError(name);
  }
}

final BuiltSet<EditorChangeTypeEnum> _$editorChangeTypeEnumValues =
    BuiltSet<EditorChangeTypeEnum>(const <EditorChangeTypeEnum>[
  _$editorChangeTypeEnum_ecosystem,
  _$editorChangeTypeEnum_level,
  _$editorChangeTypeEnum_plant,
  _$editorChangeTypeEnum_quiz,
]);

const EditorChangeStatusEnum _$editorChangeStatusEnum_draft =
    const EditorChangeStatusEnum._('draft');
const EditorChangeStatusEnum _$editorChangeStatusEnum_pendingReview =
    const EditorChangeStatusEnum._('pendingReview');
const EditorChangeStatusEnum _$editorChangeStatusEnum_rejected =
    const EditorChangeStatusEnum._('rejected');
const EditorChangeStatusEnum _$editorChangeStatusEnum_approved =
    const EditorChangeStatusEnum._('approved');

EditorChangeStatusEnum _$editorChangeStatusEnumValueOf(String name) {
  switch (name) {
    case 'draft':
      return _$editorChangeStatusEnum_draft;
    case 'pendingReview':
      return _$editorChangeStatusEnum_pendingReview;
    case 'rejected':
      return _$editorChangeStatusEnum_rejected;
    case 'approved':
      return _$editorChangeStatusEnum_approved;
    default:
      throw ArgumentError(name);
  }
}

final BuiltSet<EditorChangeStatusEnum> _$editorChangeStatusEnumValues =
    BuiltSet<EditorChangeStatusEnum>(const <EditorChangeStatusEnum>[
  _$editorChangeStatusEnum_draft,
  _$editorChangeStatusEnum_pendingReview,
  _$editorChangeStatusEnum_rejected,
  _$editorChangeStatusEnum_approved,
]);

Serializer<EditorChangeTypeEnum> _$editorChangeTypeEnumSerializer =
    _$EditorChangeTypeEnumSerializer();
Serializer<EditorChangeStatusEnum> _$editorChangeStatusEnumSerializer =
    _$EditorChangeStatusEnumSerializer();

class _$EditorChangeTypeEnumSerializer
    implements PrimitiveSerializer<EditorChangeTypeEnum> {
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
  final Iterable<Type> types = const <Type>[EditorChangeTypeEnum];
  @override
  final String wireName = 'EditorChangeTypeEnum';

  @override
  Object serialize(Serializers serializers, EditorChangeTypeEnum object,
          {FullType specifiedType = FullType.unspecified}) =>
      _toWire[object.name] ?? object.name;

  @override
  EditorChangeTypeEnum deserialize(Serializers serializers, Object serialized,
          {FullType specifiedType = FullType.unspecified}) =>
      EditorChangeTypeEnum.valueOf(
          _fromWire[serialized] ?? (serialized is String ? serialized : ''));
}

class _$EditorChangeStatusEnumSerializer
    implements PrimitiveSerializer<EditorChangeStatusEnum> {
  static const Map<String, Object> _toWire = const <String, Object>{
    'draft': 'draft',
    'pendingReview': 'pending_review',
    'rejected': 'rejected',
    'approved': 'approved',
  };
  static const Map<Object, String> _fromWire = const <Object, String>{
    'draft': 'draft',
    'pending_review': 'pendingReview',
    'rejected': 'rejected',
    'approved': 'approved',
  };

  @override
  final Iterable<Type> types = const <Type>[EditorChangeStatusEnum];
  @override
  final String wireName = 'EditorChangeStatusEnum';

  @override
  Object serialize(Serializers serializers, EditorChangeStatusEnum object,
          {FullType specifiedType = FullType.unspecified}) =>
      _toWire[object.name] ?? object.name;

  @override
  EditorChangeStatusEnum deserialize(Serializers serializers, Object serialized,
          {FullType specifiedType = FullType.unspecified}) =>
      EditorChangeStatusEnum.valueOf(
          _fromWire[serialized] ?? (serialized is String ? serialized : ''));
}

class _$EditorChange extends EditorChange {
  @override
  final String id;
  @override
  final EditorChangeTypeEnum type;
  @override
  final String targetId;
  @override
  final JsonObject data;
  @override
  final EditorChangeStatusEnum status;
  @override
  final String author;
  @override
  final String? reviewer;
  @override
  final String? note;
  @override
  final DateTime updatedAt;
  @override
  final DateTime? reviewedAt;
  @override
  final DateTime? appliedAt;
  @override
  final BuiltList<JsonObject> reviewEvents;
  @override
  final String? payloadHash;

  factory _$EditorChange([void Function(EditorChangeBuilder)? updates]) =>
      (EditorChangeBuilder()..update(updates))._build();

  _$EditorChange._(
      {required this.id,
      required this.type,
      required this.targetId,
      required this.data,
      required this.status,
      required this.author,
      this.reviewer,
      this.note,
      required this.updatedAt,
      this.reviewedAt,
      this.appliedAt,
      required this.reviewEvents,
      this.payloadHash})
      : super._();
  @override
  EditorChange rebuild(void Function(EditorChangeBuilder) updates) =>
      (toBuilder()..update(updates)).build();

  @override
  EditorChangeBuilder toBuilder() => EditorChangeBuilder()..replace(this);

  @override
  bool operator ==(Object other) {
    if (identical(other, this)) return true;
    return other is EditorChange &&
        id == other.id &&
        type == other.type &&
        targetId == other.targetId &&
        data == other.data &&
        status == other.status &&
        author == other.author &&
        reviewer == other.reviewer &&
        note == other.note &&
        updatedAt == other.updatedAt &&
        reviewedAt == other.reviewedAt &&
        appliedAt == other.appliedAt &&
        reviewEvents == other.reviewEvents &&
        payloadHash == other.payloadHash;
  }

  @override
  int get hashCode {
    var _$hash = 0;
    _$hash = $jc(_$hash, id.hashCode);
    _$hash = $jc(_$hash, type.hashCode);
    _$hash = $jc(_$hash, targetId.hashCode);
    _$hash = $jc(_$hash, data.hashCode);
    _$hash = $jc(_$hash, status.hashCode);
    _$hash = $jc(_$hash, author.hashCode);
    _$hash = $jc(_$hash, reviewer.hashCode);
    _$hash = $jc(_$hash, note.hashCode);
    _$hash = $jc(_$hash, updatedAt.hashCode);
    _$hash = $jc(_$hash, reviewedAt.hashCode);
    _$hash = $jc(_$hash, appliedAt.hashCode);
    _$hash = $jc(_$hash, reviewEvents.hashCode);
    _$hash = $jc(_$hash, payloadHash.hashCode);
    _$hash = $jf(_$hash);
    return _$hash;
  }

  @override
  String toString() {
    return (newBuiltValueToStringHelper(r'EditorChange')
          ..add('id', id)
          ..add('type', type)
          ..add('targetId', targetId)
          ..add('data', data)
          ..add('status', status)
          ..add('author', author)
          ..add('reviewer', reviewer)
          ..add('note', note)
          ..add('updatedAt', updatedAt)
          ..add('reviewedAt', reviewedAt)
          ..add('appliedAt', appliedAt)
          ..add('reviewEvents', reviewEvents)
          ..add('payloadHash', payloadHash))
        .toString();
  }
}

class EditorChangeBuilder
    implements Builder<EditorChange, EditorChangeBuilder> {
  _$EditorChange? _$v;

  String? _id;
  String? get id => _$this._id;
  set id(String? id) => _$this._id = id;

  EditorChangeTypeEnum? _type;
  EditorChangeTypeEnum? get type => _$this._type;
  set type(EditorChangeTypeEnum? type) => _$this._type = type;

  String? _targetId;
  String? get targetId => _$this._targetId;
  set targetId(String? targetId) => _$this._targetId = targetId;

  JsonObject? _data;
  JsonObject? get data => _$this._data;
  set data(JsonObject? data) => _$this._data = data;

  EditorChangeStatusEnum? _status;
  EditorChangeStatusEnum? get status => _$this._status;
  set status(EditorChangeStatusEnum? status) => _$this._status = status;

  String? _author;
  String? get author => _$this._author;
  set author(String? author) => _$this._author = author;

  String? _reviewer;
  String? get reviewer => _$this._reviewer;
  set reviewer(String? reviewer) => _$this._reviewer = reviewer;

  String? _note;
  String? get note => _$this._note;
  set note(String? note) => _$this._note = note;

  DateTime? _updatedAt;
  DateTime? get updatedAt => _$this._updatedAt;
  set updatedAt(DateTime? updatedAt) => _$this._updatedAt = updatedAt;

  DateTime? _reviewedAt;
  DateTime? get reviewedAt => _$this._reviewedAt;
  set reviewedAt(DateTime? reviewedAt) => _$this._reviewedAt = reviewedAt;

  DateTime? _appliedAt;
  DateTime? get appliedAt => _$this._appliedAt;
  set appliedAt(DateTime? appliedAt) => _$this._appliedAt = appliedAt;

  ListBuilder<JsonObject>? _reviewEvents;
  ListBuilder<JsonObject> get reviewEvents =>
      _$this._reviewEvents ??= ListBuilder<JsonObject>();
  set reviewEvents(ListBuilder<JsonObject>? reviewEvents) =>
      _$this._reviewEvents = reviewEvents;

  String? _payloadHash;
  String? get payloadHash => _$this._payloadHash;
  set payloadHash(String? payloadHash) => _$this._payloadHash = payloadHash;

  EditorChangeBuilder() {
    EditorChange._defaults(this);
  }

  EditorChangeBuilder get _$this {
    final $v = _$v;
    if ($v != null) {
      _id = $v.id;
      _type = $v.type;
      _targetId = $v.targetId;
      _data = $v.data;
      _status = $v.status;
      _author = $v.author;
      _reviewer = $v.reviewer;
      _note = $v.note;
      _updatedAt = $v.updatedAt;
      _reviewedAt = $v.reviewedAt;
      _appliedAt = $v.appliedAt;
      _reviewEvents = $v.reviewEvents.toBuilder();
      _payloadHash = $v.payloadHash;
      _$v = null;
    }
    return this;
  }

  @override
  void replace(EditorChange other) {
    _$v = other as _$EditorChange;
  }

  @override
  void update(void Function(EditorChangeBuilder)? updates) {
    if (updates != null) updates(this);
  }

  @override
  EditorChange build() => _build();

  _$EditorChange _build() {
    _$EditorChange _$result;
    try {
      _$result = _$v ??
          _$EditorChange._(
            id: BuiltValueNullFieldError.checkNotNull(
                id, r'EditorChange', 'id'),
            type: BuiltValueNullFieldError.checkNotNull(
                type, r'EditorChange', 'type'),
            targetId: BuiltValueNullFieldError.checkNotNull(
                targetId, r'EditorChange', 'targetId'),
            data: BuiltValueNullFieldError.checkNotNull(
                data, r'EditorChange', 'data'),
            status: BuiltValueNullFieldError.checkNotNull(
                status, r'EditorChange', 'status'),
            author: BuiltValueNullFieldError.checkNotNull(
                author, r'EditorChange', 'author'),
            reviewer: reviewer,
            note: note,
            updatedAt: BuiltValueNullFieldError.checkNotNull(
                updatedAt, r'EditorChange', 'updatedAt'),
            reviewedAt: reviewedAt,
            appliedAt: appliedAt,
            reviewEvents: reviewEvents.build(),
            payloadHash: payloadHash,
          );
    } catch (_) {
      late String _$failedField;
      try {
        _$failedField = 'reviewEvents';
        reviewEvents.build();
      } catch (e) {
        throw BuiltValueNestedFieldError(
            r'EditorChange', _$failedField, e.toString());
      }
      rethrow;
    }
    replace(_$result);
    return _$result;
  }
}

// ignore_for_file: deprecated_member_use_from_same_package,type=lint
