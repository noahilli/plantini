// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'editor_item_summary.dart';

// **************************************************************************
// BuiltValueGenerator
// **************************************************************************

const EditorItemSummaryTypeEnum _$editorItemSummaryTypeEnum_ecosystem =
    const EditorItemSummaryTypeEnum._('ecosystem');
const EditorItemSummaryTypeEnum _$editorItemSummaryTypeEnum_level =
    const EditorItemSummaryTypeEnum._('level');
const EditorItemSummaryTypeEnum _$editorItemSummaryTypeEnum_plant =
    const EditorItemSummaryTypeEnum._('plant');
const EditorItemSummaryTypeEnum _$editorItemSummaryTypeEnum_quiz =
    const EditorItemSummaryTypeEnum._('quiz');

EditorItemSummaryTypeEnum _$editorItemSummaryTypeEnumValueOf(String name) {
  switch (name) {
    case 'ecosystem':
      return _$editorItemSummaryTypeEnum_ecosystem;
    case 'level':
      return _$editorItemSummaryTypeEnum_level;
    case 'plant':
      return _$editorItemSummaryTypeEnum_plant;
    case 'quiz':
      return _$editorItemSummaryTypeEnum_quiz;
    default:
      throw ArgumentError(name);
  }
}

final BuiltSet<EditorItemSummaryTypeEnum> _$editorItemSummaryTypeEnumValues =
    BuiltSet<EditorItemSummaryTypeEnum>(const <EditorItemSummaryTypeEnum>[
  _$editorItemSummaryTypeEnum_ecosystem,
  _$editorItemSummaryTypeEnum_level,
  _$editorItemSummaryTypeEnum_plant,
  _$editorItemSummaryTypeEnum_quiz,
]);

Serializer<EditorItemSummaryTypeEnum> _$editorItemSummaryTypeEnumSerializer =
    _$EditorItemSummaryTypeEnumSerializer();

class _$EditorItemSummaryTypeEnumSerializer
    implements PrimitiveSerializer<EditorItemSummaryTypeEnum> {
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
  final Iterable<Type> types = const <Type>[EditorItemSummaryTypeEnum];
  @override
  final String wireName = 'EditorItemSummaryTypeEnum';

  @override
  Object serialize(Serializers serializers, EditorItemSummaryTypeEnum object,
          {FullType specifiedType = FullType.unspecified}) =>
      _toWire[object.name] ?? object.name;

  @override
  EditorItemSummaryTypeEnum deserialize(
          Serializers serializers, Object serialized,
          {FullType specifiedType = FullType.unspecified}) =>
      EditorItemSummaryTypeEnum.valueOf(
          _fromWire[serialized] ?? (serialized is String ? serialized : ''));
}

class _$EditorItemSummary extends EditorItemSummary {
  @override
  final String id;
  @override
  final EditorItemSummaryTypeEnum type;
  @override
  final String title;
  @override
  final String slug;
  @override
  final bool published;
  @override
  final String? reviewStatus;
  @override
  final String? ecosystemId;
  @override
  final BuiltList<String>? plantIds;
  @override
  final String? levelId;
  @override
  final String? plantId;
  @override
  final int? sequence;

  factory _$EditorItemSummary(
          [void Function(EditorItemSummaryBuilder)? updates]) =>
      (EditorItemSummaryBuilder()..update(updates))._build();

  _$EditorItemSummary._(
      {required this.id,
      required this.type,
      required this.title,
      required this.slug,
      required this.published,
      this.reviewStatus,
      this.ecosystemId,
      this.plantIds,
      this.levelId,
      this.plantId,
      this.sequence})
      : super._();
  @override
  EditorItemSummary rebuild(void Function(EditorItemSummaryBuilder) updates) =>
      (toBuilder()..update(updates)).build();

  @override
  EditorItemSummaryBuilder toBuilder() =>
      EditorItemSummaryBuilder()..replace(this);

  @override
  bool operator ==(Object other) {
    if (identical(other, this)) return true;
    return other is EditorItemSummary &&
        id == other.id &&
        type == other.type &&
        title == other.title &&
        slug == other.slug &&
        published == other.published &&
        reviewStatus == other.reviewStatus &&
        ecosystemId == other.ecosystemId &&
        plantIds == other.plantIds &&
        levelId == other.levelId &&
        plantId == other.plantId &&
        sequence == other.sequence;
  }

  @override
  int get hashCode {
    var _$hash = 0;
    _$hash = $jc(_$hash, id.hashCode);
    _$hash = $jc(_$hash, type.hashCode);
    _$hash = $jc(_$hash, title.hashCode);
    _$hash = $jc(_$hash, slug.hashCode);
    _$hash = $jc(_$hash, published.hashCode);
    _$hash = $jc(_$hash, reviewStatus.hashCode);
    _$hash = $jc(_$hash, ecosystemId.hashCode);
    _$hash = $jc(_$hash, plantIds.hashCode);
    _$hash = $jc(_$hash, levelId.hashCode);
    _$hash = $jc(_$hash, plantId.hashCode);
    _$hash = $jc(_$hash, sequence.hashCode);
    _$hash = $jf(_$hash);
    return _$hash;
  }

  @override
  String toString() {
    return (newBuiltValueToStringHelper(r'EditorItemSummary')
          ..add('id', id)
          ..add('type', type)
          ..add('title', title)
          ..add('slug', slug)
          ..add('published', published)
          ..add('reviewStatus', reviewStatus)
          ..add('ecosystemId', ecosystemId)
          ..add('plantIds', plantIds)
          ..add('levelId', levelId)
          ..add('plantId', plantId)
          ..add('sequence', sequence))
        .toString();
  }
}

class EditorItemSummaryBuilder
    implements Builder<EditorItemSummary, EditorItemSummaryBuilder> {
  _$EditorItemSummary? _$v;

  String? _id;
  String? get id => _$this._id;
  set id(String? id) => _$this._id = id;

  EditorItemSummaryTypeEnum? _type;
  EditorItemSummaryTypeEnum? get type => _$this._type;
  set type(EditorItemSummaryTypeEnum? type) => _$this._type = type;

  String? _title;
  String? get title => _$this._title;
  set title(String? title) => _$this._title = title;

  String? _slug;
  String? get slug => _$this._slug;
  set slug(String? slug) => _$this._slug = slug;

  bool? _published;
  bool? get published => _$this._published;
  set published(bool? published) => _$this._published = published;

  String? _reviewStatus;
  String? get reviewStatus => _$this._reviewStatus;
  set reviewStatus(String? reviewStatus) => _$this._reviewStatus = reviewStatus;

  String? _ecosystemId;
  String? get ecosystemId => _$this._ecosystemId;
  set ecosystemId(String? ecosystemId) => _$this._ecosystemId = ecosystemId;

  ListBuilder<String>? _plantIds;
  ListBuilder<String> get plantIds =>
      _$this._plantIds ??= ListBuilder<String>();
  set plantIds(ListBuilder<String>? plantIds) => _$this._plantIds = plantIds;

  String? _levelId;
  String? get levelId => _$this._levelId;
  set levelId(String? levelId) => _$this._levelId = levelId;

  String? _plantId;
  String? get plantId => _$this._plantId;
  set plantId(String? plantId) => _$this._plantId = plantId;

  int? _sequence;
  int? get sequence => _$this._sequence;
  set sequence(int? sequence) => _$this._sequence = sequence;

  EditorItemSummaryBuilder() {
    EditorItemSummary._defaults(this);
  }

  EditorItemSummaryBuilder get _$this {
    final $v = _$v;
    if ($v != null) {
      _id = $v.id;
      _type = $v.type;
      _title = $v.title;
      _slug = $v.slug;
      _published = $v.published;
      _reviewStatus = $v.reviewStatus;
      _ecosystemId = $v.ecosystemId;
      _plantIds = $v.plantIds?.toBuilder();
      _levelId = $v.levelId;
      _plantId = $v.plantId;
      _sequence = $v.sequence;
      _$v = null;
    }
    return this;
  }

  @override
  void replace(EditorItemSummary other) {
    _$v = other as _$EditorItemSummary;
  }

  @override
  void update(void Function(EditorItemSummaryBuilder)? updates) {
    if (updates != null) updates(this);
  }

  @override
  EditorItemSummary build() => _build();

  _$EditorItemSummary _build() {
    _$EditorItemSummary _$result;
    try {
      _$result = _$v ??
          _$EditorItemSummary._(
            id: BuiltValueNullFieldError.checkNotNull(
                id, r'EditorItemSummary', 'id'),
            type: BuiltValueNullFieldError.checkNotNull(
                type, r'EditorItemSummary', 'type'),
            title: BuiltValueNullFieldError.checkNotNull(
                title, r'EditorItemSummary', 'title'),
            slug: BuiltValueNullFieldError.checkNotNull(
                slug, r'EditorItemSummary', 'slug'),
            published: BuiltValueNullFieldError.checkNotNull(
                published, r'EditorItemSummary', 'published'),
            reviewStatus: reviewStatus,
            ecosystemId: ecosystemId,
            plantIds: _plantIds?.build(),
            levelId: levelId,
            plantId: plantId,
            sequence: sequence,
          );
    } catch (_) {
      late String _$failedField;
      try {
        _$failedField = 'plantIds';
        _plantIds?.build();
      } catch (e) {
        throw BuiltValueNestedFieldError(
            r'EditorItemSummary', _$failedField, e.toString());
      }
      rethrow;
    }
    replace(_$result);
    return _$result;
  }
}

// ignore_for_file: deprecated_member_use_from_same_package,type=lint
