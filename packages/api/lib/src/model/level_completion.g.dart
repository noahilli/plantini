// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'level_completion.dart';

// **************************************************************************
// BuiltValueGenerator
// **************************************************************************

const LevelCompletionStatusEnum _$levelCompletionStatusEnum_completed =
    const LevelCompletionStatusEnum._('completed');
const LevelCompletionStatusEnum _$levelCompletionStatusEnum_failed =
    const LevelCompletionStatusEnum._('failed');

LevelCompletionStatusEnum _$levelCompletionStatusEnumValueOf(String name) {
  switch (name) {
    case 'completed':
      return _$levelCompletionStatusEnum_completed;
    case 'failed':
      return _$levelCompletionStatusEnum_failed;
    default:
      throw ArgumentError(name);
  }
}

final BuiltSet<LevelCompletionStatusEnum> _$levelCompletionStatusEnumValues =
    BuiltSet<LevelCompletionStatusEnum>(const <LevelCompletionStatusEnum>[
  _$levelCompletionStatusEnum_completed,
  _$levelCompletionStatusEnum_failed,
]);

Serializer<LevelCompletionStatusEnum> _$levelCompletionStatusEnumSerializer =
    _$LevelCompletionStatusEnumSerializer();

class _$LevelCompletionStatusEnumSerializer
    implements PrimitiveSerializer<LevelCompletionStatusEnum> {
  static const Map<String, Object> _toWire = const <String, Object>{
    'completed': 'completed',
    'failed': 'failed',
  };
  static const Map<Object, String> _fromWire = const <Object, String>{
    'completed': 'completed',
    'failed': 'failed',
  };

  @override
  final Iterable<Type> types = const <Type>[LevelCompletionStatusEnum];
  @override
  final String wireName = 'LevelCompletionStatusEnum';

  @override
  Object serialize(Serializers serializers, LevelCompletionStatusEnum object,
          {FullType specifiedType = FullType.unspecified}) =>
      _toWire[object.name] ?? object.name;

  @override
  LevelCompletionStatusEnum deserialize(
          Serializers serializers, Object serialized,
          {FullType specifiedType = FullType.unspecified}) =>
      LevelCompletionStatusEnum.valueOf(
          _fromWire[serialized] ?? (serialized is String ? serialized : ''));
}

class _$LevelCompletion extends LevelCompletion {
  @override
  final String attemptId;
  @override
  final bool passed;
  @override
  final num score;
  @override
  final LevelCompletionStatusEnum status;
  @override
  final ProgressSnapshot? progress;

  factory _$LevelCompletion([void Function(LevelCompletionBuilder)? updates]) =>
      (LevelCompletionBuilder()..update(updates))._build();

  _$LevelCompletion._(
      {required this.attemptId,
      required this.passed,
      required this.score,
      required this.status,
      this.progress})
      : super._();
  @override
  LevelCompletion rebuild(void Function(LevelCompletionBuilder) updates) =>
      (toBuilder()..update(updates)).build();

  @override
  LevelCompletionBuilder toBuilder() => LevelCompletionBuilder()..replace(this);

  @override
  bool operator ==(Object other) {
    if (identical(other, this)) return true;
    return other is LevelCompletion &&
        attemptId == other.attemptId &&
        passed == other.passed &&
        score == other.score &&
        status == other.status &&
        progress == other.progress;
  }

  @override
  int get hashCode {
    var _$hash = 0;
    _$hash = $jc(_$hash, attemptId.hashCode);
    _$hash = $jc(_$hash, passed.hashCode);
    _$hash = $jc(_$hash, score.hashCode);
    _$hash = $jc(_$hash, status.hashCode);
    _$hash = $jc(_$hash, progress.hashCode);
    _$hash = $jf(_$hash);
    return _$hash;
  }

  @override
  String toString() {
    return (newBuiltValueToStringHelper(r'LevelCompletion')
          ..add('attemptId', attemptId)
          ..add('passed', passed)
          ..add('score', score)
          ..add('status', status)
          ..add('progress', progress))
        .toString();
  }
}

class LevelCompletionBuilder
    implements Builder<LevelCompletion, LevelCompletionBuilder> {
  _$LevelCompletion? _$v;

  String? _attemptId;
  String? get attemptId => _$this._attemptId;
  set attemptId(String? attemptId) => _$this._attemptId = attemptId;

  bool? _passed;
  bool? get passed => _$this._passed;
  set passed(bool? passed) => _$this._passed = passed;

  num? _score;
  num? get score => _$this._score;
  set score(num? score) => _$this._score = score;

  LevelCompletionStatusEnum? _status;
  LevelCompletionStatusEnum? get status => _$this._status;
  set status(LevelCompletionStatusEnum? status) => _$this._status = status;

  ProgressSnapshotBuilder? _progress;
  ProgressSnapshotBuilder get progress =>
      _$this._progress ??= ProgressSnapshotBuilder();
  set progress(ProgressSnapshotBuilder? progress) =>
      _$this._progress = progress;

  LevelCompletionBuilder() {
    LevelCompletion._defaults(this);
  }

  LevelCompletionBuilder get _$this {
    final $v = _$v;
    if ($v != null) {
      _attemptId = $v.attemptId;
      _passed = $v.passed;
      _score = $v.score;
      _status = $v.status;
      _progress = $v.progress?.toBuilder();
      _$v = null;
    }
    return this;
  }

  @override
  void replace(LevelCompletion other) {
    _$v = other as _$LevelCompletion;
  }

  @override
  void update(void Function(LevelCompletionBuilder)? updates) {
    if (updates != null) updates(this);
  }

  @override
  LevelCompletion build() => _build();

  _$LevelCompletion _build() {
    _$LevelCompletion _$result;
    try {
      _$result = _$v ??
          _$LevelCompletion._(
            attemptId: BuiltValueNullFieldError.checkNotNull(
                attemptId, r'LevelCompletion', 'attemptId'),
            passed: BuiltValueNullFieldError.checkNotNull(
                passed, r'LevelCompletion', 'passed'),
            score: BuiltValueNullFieldError.checkNotNull(
                score, r'LevelCompletion', 'score'),
            status: BuiltValueNullFieldError.checkNotNull(
                status, r'LevelCompletion', 'status'),
            progress: _progress?.build(),
          );
    } catch (_) {
      late String _$failedField;
      try {
        _$failedField = 'progress';
        _progress?.build();
      } catch (e) {
        throw BuiltValueNestedFieldError(
            r'LevelCompletion', _$failedField, e.toString());
      }
      rethrow;
    }
    replace(_$result);
    return _$result;
  }
}

// ignore_for_file: deprecated_member_use_from_same_package,type=lint
