// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'quiz.dart';

// **************************************************************************
// BuiltValueGenerator
// **************************************************************************

const QuizQuizTypeEnum _$quizQuizTypeEnum_multipleChoice =
    const QuizQuizTypeEnum._('multipleChoice');
const QuizQuizTypeEnum _$quizQuizTypeEnum_flashcard =
    const QuizQuizTypeEnum._('flashcard');
const QuizQuizTypeEnum _$quizQuizTypeEnum_identification =
    const QuizQuizTypeEnum._('identification');

QuizQuizTypeEnum _$quizQuizTypeEnumValueOf(String name) {
  switch (name) {
    case 'multipleChoice':
      return _$quizQuizTypeEnum_multipleChoice;
    case 'flashcard':
      return _$quizQuizTypeEnum_flashcard;
    case 'identification':
      return _$quizQuizTypeEnum_identification;
    default:
      throw ArgumentError(name);
  }
}

final BuiltSet<QuizQuizTypeEnum> _$quizQuizTypeEnumValues =
    BuiltSet<QuizQuizTypeEnum>(const <QuizQuizTypeEnum>[
  _$quizQuizTypeEnum_multipleChoice,
  _$quizQuizTypeEnum_flashcard,
  _$quizQuizTypeEnum_identification,
]);

Serializer<QuizQuizTypeEnum> _$quizQuizTypeEnumSerializer =
    _$QuizQuizTypeEnumSerializer();

class _$QuizQuizTypeEnumSerializer
    implements PrimitiveSerializer<QuizQuizTypeEnum> {
  static const Map<String, Object> _toWire = const <String, Object>{
    'multipleChoice': 'multiple-choice',
    'flashcard': 'flashcard',
    'identification': 'identification',
  };
  static const Map<Object, String> _fromWire = const <Object, String>{
    'multiple-choice': 'multipleChoice',
    'flashcard': 'flashcard',
    'identification': 'identification',
  };

  @override
  final Iterable<Type> types = const <Type>[QuizQuizTypeEnum];
  @override
  final String wireName = 'QuizQuizTypeEnum';

  @override
  Object serialize(Serializers serializers, QuizQuizTypeEnum object,
          {FullType specifiedType = FullType.unspecified}) =>
      _toWire[object.name] ?? object.name;

  @override
  QuizQuizTypeEnum deserialize(Serializers serializers, Object serialized,
          {FullType specifiedType = FullType.unspecified}) =>
      QuizQuizTypeEnum.valueOf(
          _fromWire[serialized] ?? (serialized is String ? serialized : ''));
}

class _$Quiz extends Quiz {
  @override
  final String id;
  @override
  final String title;
  @override
  final QuizQuizTypeEnum quizType;
  @override
  final JsonObject? data;

  factory _$Quiz([void Function(QuizBuilder)? updates]) =>
      (QuizBuilder()..update(updates))._build();

  _$Quiz._(
      {required this.id,
      required this.title,
      required this.quizType,
      this.data})
      : super._();
  @override
  Quiz rebuild(void Function(QuizBuilder) updates) =>
      (toBuilder()..update(updates)).build();

  @override
  QuizBuilder toBuilder() => QuizBuilder()..replace(this);

  @override
  bool operator ==(Object other) {
    if (identical(other, this)) return true;
    return other is Quiz &&
        id == other.id &&
        title == other.title &&
        quizType == other.quizType &&
        data == other.data;
  }

  @override
  int get hashCode {
    var _$hash = 0;
    _$hash = $jc(_$hash, id.hashCode);
    _$hash = $jc(_$hash, title.hashCode);
    _$hash = $jc(_$hash, quizType.hashCode);
    _$hash = $jc(_$hash, data.hashCode);
    _$hash = $jf(_$hash);
    return _$hash;
  }

  @override
  String toString() {
    return (newBuiltValueToStringHelper(r'Quiz')
          ..add('id', id)
          ..add('title', title)
          ..add('quizType', quizType)
          ..add('data', data))
        .toString();
  }
}

class QuizBuilder implements Builder<Quiz, QuizBuilder> {
  _$Quiz? _$v;

  String? _id;
  String? get id => _$this._id;
  set id(String? id) => _$this._id = id;

  String? _title;
  String? get title => _$this._title;
  set title(String? title) => _$this._title = title;

  QuizQuizTypeEnum? _quizType;
  QuizQuizTypeEnum? get quizType => _$this._quizType;
  set quizType(QuizQuizTypeEnum? quizType) => _$this._quizType = quizType;

  JsonObject? _data;
  JsonObject? get data => _$this._data;
  set data(JsonObject? data) => _$this._data = data;

  QuizBuilder() {
    Quiz._defaults(this);
  }

  QuizBuilder get _$this {
    final $v = _$v;
    if ($v != null) {
      _id = $v.id;
      _title = $v.title;
      _quizType = $v.quizType;
      _data = $v.data;
      _$v = null;
    }
    return this;
  }

  @override
  void replace(Quiz other) {
    _$v = other as _$Quiz;
  }

  @override
  void update(void Function(QuizBuilder)? updates) {
    if (updates != null) updates(this);
  }

  @override
  Quiz build() => _build();

  _$Quiz _build() {
    final _$result = _$v ??
        _$Quiz._(
          id: BuiltValueNullFieldError.checkNotNull(id, r'Quiz', 'id'),
          title: BuiltValueNullFieldError.checkNotNull(title, r'Quiz', 'title'),
          quizType: BuiltValueNullFieldError.checkNotNull(
              quizType, r'Quiz', 'quizType'),
          data: data,
        );
    replace(_$result);
    return _$result;
  }
}

// ignore_for_file: deprecated_member_use_from_same_package,type=lint
