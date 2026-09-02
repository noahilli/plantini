// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'completion_rule.dart';

// **************************************************************************
// BuiltValueGenerator
// **************************************************************************

class _$CompletionRule extends CompletionRule {
  @override
  final num minimumScore;
  @override
  final BuiltList<String>? requiredQuizIds;

  factory _$CompletionRule([void Function(CompletionRuleBuilder)? updates]) =>
      (CompletionRuleBuilder()..update(updates))._build();

  _$CompletionRule._({required this.minimumScore, this.requiredQuizIds})
      : super._();
  @override
  CompletionRule rebuild(void Function(CompletionRuleBuilder) updates) =>
      (toBuilder()..update(updates)).build();

  @override
  CompletionRuleBuilder toBuilder() => CompletionRuleBuilder()..replace(this);

  @override
  bool operator ==(Object other) {
    if (identical(other, this)) return true;
    return other is CompletionRule &&
        minimumScore == other.minimumScore &&
        requiredQuizIds == other.requiredQuizIds;
  }

  @override
  int get hashCode {
    var _$hash = 0;
    _$hash = $jc(_$hash, minimumScore.hashCode);
    _$hash = $jc(_$hash, requiredQuizIds.hashCode);
    _$hash = $jf(_$hash);
    return _$hash;
  }

  @override
  String toString() {
    return (newBuiltValueToStringHelper(r'CompletionRule')
          ..add('minimumScore', minimumScore)
          ..add('requiredQuizIds', requiredQuizIds))
        .toString();
  }
}

class CompletionRuleBuilder
    implements Builder<CompletionRule, CompletionRuleBuilder> {
  _$CompletionRule? _$v;

  num? _minimumScore;
  num? get minimumScore => _$this._minimumScore;
  set minimumScore(num? minimumScore) => _$this._minimumScore = minimumScore;

  ListBuilder<String>? _requiredQuizIds;
  ListBuilder<String> get requiredQuizIds =>
      _$this._requiredQuizIds ??= ListBuilder<String>();
  set requiredQuizIds(ListBuilder<String>? requiredQuizIds) =>
      _$this._requiredQuizIds = requiredQuizIds;

  CompletionRuleBuilder() {
    CompletionRule._defaults(this);
  }

  CompletionRuleBuilder get _$this {
    final $v = _$v;
    if ($v != null) {
      _minimumScore = $v.minimumScore;
      _requiredQuizIds = $v.requiredQuizIds?.toBuilder();
      _$v = null;
    }
    return this;
  }

  @override
  void replace(CompletionRule other) {
    _$v = other as _$CompletionRule;
  }

  @override
  void update(void Function(CompletionRuleBuilder)? updates) {
    if (updates != null) updates(this);
  }

  @override
  CompletionRule build() => _build();

  _$CompletionRule _build() {
    _$CompletionRule _$result;
    try {
      _$result = _$v ??
          _$CompletionRule._(
            minimumScore: BuiltValueNullFieldError.checkNotNull(
                minimumScore, r'CompletionRule', 'minimumScore'),
            requiredQuizIds: _requiredQuizIds?.build(),
          );
    } catch (_) {
      late String _$failedField;
      try {
        _$failedField = 'requiredQuizIds';
        _requiredQuizIds?.build();
      } catch (e) {
        throw BuiltValueNestedFieldError(
            r'CompletionRule', _$failedField, e.toString());
      }
      rethrow;
    }
    replace(_$result);
    return _$result;
  }
}

// ignore_for_file: deprecated_member_use_from_same_package,type=lint
