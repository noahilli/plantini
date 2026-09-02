// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'learning_event_batch.dart';

// **************************************************************************
// BuiltValueGenerator
// **************************************************************************

class _$LearningEventBatch extends LearningEventBatch {
  @override
  final BuiltList<LearningEvent> events;

  factory _$LearningEventBatch(
          [void Function(LearningEventBatchBuilder)? updates]) =>
      (LearningEventBatchBuilder()..update(updates))._build();

  _$LearningEventBatch._({required this.events}) : super._();
  @override
  LearningEventBatch rebuild(
          void Function(LearningEventBatchBuilder) updates) =>
      (toBuilder()..update(updates)).build();

  @override
  LearningEventBatchBuilder toBuilder() =>
      LearningEventBatchBuilder()..replace(this);

  @override
  bool operator ==(Object other) {
    if (identical(other, this)) return true;
    return other is LearningEventBatch && events == other.events;
  }

  @override
  int get hashCode {
    var _$hash = 0;
    _$hash = $jc(_$hash, events.hashCode);
    _$hash = $jf(_$hash);
    return _$hash;
  }

  @override
  String toString() {
    return (newBuiltValueToStringHelper(r'LearningEventBatch')
          ..add('events', events))
        .toString();
  }
}

class LearningEventBatchBuilder
    implements Builder<LearningEventBatch, LearningEventBatchBuilder> {
  _$LearningEventBatch? _$v;

  ListBuilder<LearningEvent>? _events;
  ListBuilder<LearningEvent> get events =>
      _$this._events ??= ListBuilder<LearningEvent>();
  set events(ListBuilder<LearningEvent>? events) => _$this._events = events;

  LearningEventBatchBuilder() {
    LearningEventBatch._defaults(this);
  }

  LearningEventBatchBuilder get _$this {
    final $v = _$v;
    if ($v != null) {
      _events = $v.events.toBuilder();
      _$v = null;
    }
    return this;
  }

  @override
  void replace(LearningEventBatch other) {
    _$v = other as _$LearningEventBatch;
  }

  @override
  void update(void Function(LearningEventBatchBuilder)? updates) {
    if (updates != null) updates(this);
  }

  @override
  LearningEventBatch build() => _build();

  _$LearningEventBatch _build() {
    _$LearningEventBatch _$result;
    try {
      _$result = _$v ??
          _$LearningEventBatch._(
            events: events.build(),
          );
    } catch (_) {
      late String _$failedField;
      try {
        _$failedField = 'events';
        events.build();
      } catch (e) {
        throw BuiltValueNestedFieldError(
            r'LearningEventBatch', _$failedField, e.toString());
      }
      rethrow;
    }
    replace(_$result);
    return _$result;
  }
}

// ignore_for_file: deprecated_member_use_from_same_package,type=lint
