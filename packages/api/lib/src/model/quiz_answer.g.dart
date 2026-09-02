// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'quiz_answer.dart';

// **************************************************************************
// BuiltValueGenerator
// **************************************************************************

class _$QuizAnswer extends QuizAnswer {
  @override
  final String quizItemId;
  @override
  final String choiceId;

  factory _$QuizAnswer([void Function(QuizAnswerBuilder)? updates]) =>
      (QuizAnswerBuilder()..update(updates))._build();

  _$QuizAnswer._({required this.quizItemId, required this.choiceId})
      : super._();
  @override
  QuizAnswer rebuild(void Function(QuizAnswerBuilder) updates) =>
      (toBuilder()..update(updates)).build();

  @override
  QuizAnswerBuilder toBuilder() => QuizAnswerBuilder()..replace(this);

  @override
  bool operator ==(Object other) {
    if (identical(other, this)) return true;
    return other is QuizAnswer &&
        quizItemId == other.quizItemId &&
        choiceId == other.choiceId;
  }

  @override
  int get hashCode {
    var _$hash = 0;
    _$hash = $jc(_$hash, quizItemId.hashCode);
    _$hash = $jc(_$hash, choiceId.hashCode);
    _$hash = $jf(_$hash);
    return _$hash;
  }

  @override
  String toString() {
    return (newBuiltValueToStringHelper(r'QuizAnswer')
          ..add('quizItemId', quizItemId)
          ..add('choiceId', choiceId))
        .toString();
  }
}

class QuizAnswerBuilder implements Builder<QuizAnswer, QuizAnswerBuilder> {
  _$QuizAnswer? _$v;

  String? _quizItemId;
  String? get quizItemId => _$this._quizItemId;
  set quizItemId(String? quizItemId) => _$this._quizItemId = quizItemId;

  String? _choiceId;
  String? get choiceId => _$this._choiceId;
  set choiceId(String? choiceId) => _$this._choiceId = choiceId;

  QuizAnswerBuilder() {
    QuizAnswer._defaults(this);
  }

  QuizAnswerBuilder get _$this {
    final $v = _$v;
    if ($v != null) {
      _quizItemId = $v.quizItemId;
      _choiceId = $v.choiceId;
      _$v = null;
    }
    return this;
  }

  @override
  void replace(QuizAnswer other) {
    _$v = other as _$QuizAnswer;
  }

  @override
  void update(void Function(QuizAnswerBuilder)? updates) {
    if (updates != null) updates(this);
  }

  @override
  QuizAnswer build() => _build();

  _$QuizAnswer _build() {
    final _$result = _$v ??
        _$QuizAnswer._(
          quizItemId: BuiltValueNullFieldError.checkNotNull(
              quizItemId, r'QuizAnswer', 'quizItemId'),
          choiceId: BuiltValueNullFieldError.checkNotNull(
              choiceId, r'QuizAnswer', 'choiceId'),
        );
    replace(_$result);
    return _$result;
  }
}

// ignore_for_file: deprecated_member_use_from_same_package,type=lint
