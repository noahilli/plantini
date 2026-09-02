// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'quiz_choice.dart';

// **************************************************************************
// BuiltValueGenerator
// **************************************************************************

class _$QuizChoice extends QuizChoice {
  @override
  final String id;
  @override
  final String label;

  factory _$QuizChoice([void Function(QuizChoiceBuilder)? updates]) =>
      (QuizChoiceBuilder()..update(updates))._build();

  _$QuizChoice._({required this.id, required this.label}) : super._();
  @override
  QuizChoice rebuild(void Function(QuizChoiceBuilder) updates) =>
      (toBuilder()..update(updates)).build();

  @override
  QuizChoiceBuilder toBuilder() => QuizChoiceBuilder()..replace(this);

  @override
  bool operator ==(Object other) {
    if (identical(other, this)) return true;
    return other is QuizChoice && id == other.id && label == other.label;
  }

  @override
  int get hashCode {
    var _$hash = 0;
    _$hash = $jc(_$hash, id.hashCode);
    _$hash = $jc(_$hash, label.hashCode);
    _$hash = $jf(_$hash);
    return _$hash;
  }

  @override
  String toString() {
    return (newBuiltValueToStringHelper(r'QuizChoice')
          ..add('id', id)
          ..add('label', label))
        .toString();
  }
}

class QuizChoiceBuilder implements Builder<QuizChoice, QuizChoiceBuilder> {
  _$QuizChoice? _$v;

  String? _id;
  String? get id => _$this._id;
  set id(String? id) => _$this._id = id;

  String? _label;
  String? get label => _$this._label;
  set label(String? label) => _$this._label = label;

  QuizChoiceBuilder() {
    QuizChoice._defaults(this);
  }

  QuizChoiceBuilder get _$this {
    final $v = _$v;
    if ($v != null) {
      _id = $v.id;
      _label = $v.label;
      _$v = null;
    }
    return this;
  }

  @override
  void replace(QuizChoice other) {
    _$v = other as _$QuizChoice;
  }

  @override
  void update(void Function(QuizChoiceBuilder)? updates) {
    if (updates != null) updates(this);
  }

  @override
  QuizChoice build() => _build();

  _$QuizChoice _build() {
    final _$result = _$v ??
        _$QuizChoice._(
          id: BuiltValueNullFieldError.checkNotNull(id, r'QuizChoice', 'id'),
          label: BuiltValueNullFieldError.checkNotNull(
              label, r'QuizChoice', 'label'),
        );
    replace(_$result);
    return _$result;
  }
}

// ignore_for_file: deprecated_member_use_from_same_package,type=lint
