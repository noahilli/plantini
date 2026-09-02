// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'quiz_item.dart';

// **************************************************************************
// BuiltValueGenerator
// **************************************************************************

const QuizItemTypeEnum _$quizItemTypeEnum_multipleChoice =
    const QuizItemTypeEnum._('multipleChoice');
const QuizItemTypeEnum _$quizItemTypeEnum_flashcard =
    const QuizItemTypeEnum._('flashcard');
const QuizItemTypeEnum _$quizItemTypeEnum_imageIdentification =
    const QuizItemTypeEnum._('imageIdentification');
const QuizItemTypeEnum _$quizItemTypeEnum_featureMatch =
    const QuizItemTypeEnum._('featureMatch');

QuizItemTypeEnum _$quizItemTypeEnumValueOf(String name) {
  switch (name) {
    case 'multipleChoice':
      return _$quizItemTypeEnum_multipleChoice;
    case 'flashcard':
      return _$quizItemTypeEnum_flashcard;
    case 'imageIdentification':
      return _$quizItemTypeEnum_imageIdentification;
    case 'featureMatch':
      return _$quizItemTypeEnum_featureMatch;
    default:
      throw ArgumentError(name);
  }
}

final BuiltSet<QuizItemTypeEnum> _$quizItemTypeEnumValues =
    BuiltSet<QuizItemTypeEnum>(const <QuizItemTypeEnum>[
  _$quizItemTypeEnum_multipleChoice,
  _$quizItemTypeEnum_flashcard,
  _$quizItemTypeEnum_imageIdentification,
  _$quizItemTypeEnum_featureMatch,
]);

Serializer<QuizItemTypeEnum> _$quizItemTypeEnumSerializer =
    _$QuizItemTypeEnumSerializer();

class _$QuizItemTypeEnumSerializer
    implements PrimitiveSerializer<QuizItemTypeEnum> {
  static const Map<String, Object> _toWire = const <String, Object>{
    'multipleChoice': 'multiple_choice',
    'flashcard': 'flashcard',
    'imageIdentification': 'image_identification',
    'featureMatch': 'feature_match',
  };
  static const Map<Object, String> _fromWire = const <Object, String>{
    'multiple_choice': 'multipleChoice',
    'flashcard': 'flashcard',
    'image_identification': 'imageIdentification',
    'feature_match': 'featureMatch',
  };

  @override
  final Iterable<Type> types = const <Type>[QuizItemTypeEnum];
  @override
  final String wireName = 'QuizItemTypeEnum';

  @override
  Object serialize(Serializers serializers, QuizItemTypeEnum object,
          {FullType specifiedType = FullType.unspecified}) =>
      _toWire[object.name] ?? object.name;

  @override
  QuizItemTypeEnum deserialize(Serializers serializers, Object serialized,
          {FullType specifiedType = FullType.unspecified}) =>
      QuizItemTypeEnum.valueOf(
          _fromWire[serialized] ?? (serialized is String ? serialized : ''));
}

class _$QuizItem extends QuizItem {
  @override
  final String id;
  @override
  final String levelId;
  @override
  final QuizItemTypeEnum type;
  @override
  final String contentVersion;
  @override
  final String prompt;
  @override
  final BuiltList<QuizChoice>? choices;

  factory _$QuizItem([void Function(QuizItemBuilder)? updates]) =>
      (QuizItemBuilder()..update(updates))._build();

  _$QuizItem._(
      {required this.id,
      required this.levelId,
      required this.type,
      required this.contentVersion,
      required this.prompt,
      this.choices})
      : super._();
  @override
  QuizItem rebuild(void Function(QuizItemBuilder) updates) =>
      (toBuilder()..update(updates)).build();

  @override
  QuizItemBuilder toBuilder() => QuizItemBuilder()..replace(this);

  @override
  bool operator ==(Object other) {
    if (identical(other, this)) return true;
    return other is QuizItem &&
        id == other.id &&
        levelId == other.levelId &&
        type == other.type &&
        contentVersion == other.contentVersion &&
        prompt == other.prompt &&
        choices == other.choices;
  }

  @override
  int get hashCode {
    var _$hash = 0;
    _$hash = $jc(_$hash, id.hashCode);
    _$hash = $jc(_$hash, levelId.hashCode);
    _$hash = $jc(_$hash, type.hashCode);
    _$hash = $jc(_$hash, contentVersion.hashCode);
    _$hash = $jc(_$hash, prompt.hashCode);
    _$hash = $jc(_$hash, choices.hashCode);
    _$hash = $jf(_$hash);
    return _$hash;
  }

  @override
  String toString() {
    return (newBuiltValueToStringHelper(r'QuizItem')
          ..add('id', id)
          ..add('levelId', levelId)
          ..add('type', type)
          ..add('contentVersion', contentVersion)
          ..add('prompt', prompt)
          ..add('choices', choices))
        .toString();
  }
}

class QuizItemBuilder implements Builder<QuizItem, QuizItemBuilder> {
  _$QuizItem? _$v;

  String? _id;
  String? get id => _$this._id;
  set id(String? id) => _$this._id = id;

  String? _levelId;
  String? get levelId => _$this._levelId;
  set levelId(String? levelId) => _$this._levelId = levelId;

  QuizItemTypeEnum? _type;
  QuizItemTypeEnum? get type => _$this._type;
  set type(QuizItemTypeEnum? type) => _$this._type = type;

  String? _contentVersion;
  String? get contentVersion => _$this._contentVersion;
  set contentVersion(String? contentVersion) =>
      _$this._contentVersion = contentVersion;

  String? _prompt;
  String? get prompt => _$this._prompt;
  set prompt(String? prompt) => _$this._prompt = prompt;

  ListBuilder<QuizChoice>? _choices;
  ListBuilder<QuizChoice> get choices =>
      _$this._choices ??= ListBuilder<QuizChoice>();
  set choices(ListBuilder<QuizChoice>? choices) => _$this._choices = choices;

  QuizItemBuilder() {
    QuizItem._defaults(this);
  }

  QuizItemBuilder get _$this {
    final $v = _$v;
    if ($v != null) {
      _id = $v.id;
      _levelId = $v.levelId;
      _type = $v.type;
      _contentVersion = $v.contentVersion;
      _prompt = $v.prompt;
      _choices = $v.choices?.toBuilder();
      _$v = null;
    }
    return this;
  }

  @override
  void replace(QuizItem other) {
    _$v = other as _$QuizItem;
  }

  @override
  void update(void Function(QuizItemBuilder)? updates) {
    if (updates != null) updates(this);
  }

  @override
  QuizItem build() => _build();

  _$QuizItem _build() {
    _$QuizItem _$result;
    try {
      _$result = _$v ??
          _$QuizItem._(
            id: BuiltValueNullFieldError.checkNotNull(id, r'QuizItem', 'id'),
            levelId: BuiltValueNullFieldError.checkNotNull(
                levelId, r'QuizItem', 'levelId'),
            type: BuiltValueNullFieldError.checkNotNull(
                type, r'QuizItem', 'type'),
            contentVersion: BuiltValueNullFieldError.checkNotNull(
                contentVersion, r'QuizItem', 'contentVersion'),
            prompt: BuiltValueNullFieldError.checkNotNull(
                prompt, r'QuizItem', 'prompt'),
            choices: _choices?.build(),
          );
    } catch (_) {
      late String _$failedField;
      try {
        _$failedField = 'choices';
        _choices?.build();
      } catch (e) {
        throw BuiltValueNestedFieldError(
            r'QuizItem', _$failedField, e.toString());
      }
      rethrow;
    }
    replace(_$result);
    return _$result;
  }
}

// ignore_for_file: deprecated_member_use_from_same_package,type=lint
