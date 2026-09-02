// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'complete_level_attempt_request.dart';

// **************************************************************************
// BuiltValueGenerator
// **************************************************************************

class _$CompleteLevelAttemptRequest extends CompleteLevelAttemptRequest {
  @override
  final String clientEventId;
  @override
  final BuiltList<QuizAnswer> answers;

  factory _$CompleteLevelAttemptRequest(
          [void Function(CompleteLevelAttemptRequestBuilder)? updates]) =>
      (CompleteLevelAttemptRequestBuilder()..update(updates))._build();

  _$CompleteLevelAttemptRequest._(
      {required this.clientEventId, required this.answers})
      : super._();
  @override
  CompleteLevelAttemptRequest rebuild(
          void Function(CompleteLevelAttemptRequestBuilder) updates) =>
      (toBuilder()..update(updates)).build();

  @override
  CompleteLevelAttemptRequestBuilder toBuilder() =>
      CompleteLevelAttemptRequestBuilder()..replace(this);

  @override
  bool operator ==(Object other) {
    if (identical(other, this)) return true;
    return other is CompleteLevelAttemptRequest &&
        clientEventId == other.clientEventId &&
        answers == other.answers;
  }

  @override
  int get hashCode {
    var _$hash = 0;
    _$hash = $jc(_$hash, clientEventId.hashCode);
    _$hash = $jc(_$hash, answers.hashCode);
    _$hash = $jf(_$hash);
    return _$hash;
  }

  @override
  String toString() {
    return (newBuiltValueToStringHelper(r'CompleteLevelAttemptRequest')
          ..add('clientEventId', clientEventId)
          ..add('answers', answers))
        .toString();
  }
}

class CompleteLevelAttemptRequestBuilder
    implements
        Builder<CompleteLevelAttemptRequest,
            CompleteLevelAttemptRequestBuilder> {
  _$CompleteLevelAttemptRequest? _$v;

  String? _clientEventId;
  String? get clientEventId => _$this._clientEventId;
  set clientEventId(String? clientEventId) =>
      _$this._clientEventId = clientEventId;

  ListBuilder<QuizAnswer>? _answers;
  ListBuilder<QuizAnswer> get answers =>
      _$this._answers ??= ListBuilder<QuizAnswer>();
  set answers(ListBuilder<QuizAnswer>? answers) => _$this._answers = answers;

  CompleteLevelAttemptRequestBuilder() {
    CompleteLevelAttemptRequest._defaults(this);
  }

  CompleteLevelAttemptRequestBuilder get _$this {
    final $v = _$v;
    if ($v != null) {
      _clientEventId = $v.clientEventId;
      _answers = $v.answers.toBuilder();
      _$v = null;
    }
    return this;
  }

  @override
  void replace(CompleteLevelAttemptRequest other) {
    _$v = other as _$CompleteLevelAttemptRequest;
  }

  @override
  void update(void Function(CompleteLevelAttemptRequestBuilder)? updates) {
    if (updates != null) updates(this);
  }

  @override
  CompleteLevelAttemptRequest build() => _build();

  _$CompleteLevelAttemptRequest _build() {
    _$CompleteLevelAttemptRequest _$result;
    try {
      _$result = _$v ??
          _$CompleteLevelAttemptRequest._(
            clientEventId: BuiltValueNullFieldError.checkNotNull(
                clientEventId, r'CompleteLevelAttemptRequest', 'clientEventId'),
            answers: answers.build(),
          );
    } catch (_) {
      late String _$failedField;
      try {
        _$failedField = 'answers';
        answers.build();
      } catch (e) {
        throw BuiltValueNestedFieldError(
            r'CompleteLevelAttemptRequest', _$failedField, e.toString());
      }
      rethrow;
    }
    replace(_$result);
    return _$result;
  }
}

// ignore_for_file: deprecated_member_use_from_same_package,type=lint
