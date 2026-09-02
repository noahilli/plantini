// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'event_batch_ack.dart';

// **************************************************************************
// BuiltValueGenerator
// **************************************************************************

class _$EventBatchAck extends EventBatchAck {
  @override
  final BuiltList<String> acceptedClientEventIds;
  @override
  final BuiltList<Problem>? rejected;

  factory _$EventBatchAck([void Function(EventBatchAckBuilder)? updates]) =>
      (EventBatchAckBuilder()..update(updates))._build();

  _$EventBatchAck._({required this.acceptedClientEventIds, this.rejected})
      : super._();
  @override
  EventBatchAck rebuild(void Function(EventBatchAckBuilder) updates) =>
      (toBuilder()..update(updates)).build();

  @override
  EventBatchAckBuilder toBuilder() => EventBatchAckBuilder()..replace(this);

  @override
  bool operator ==(Object other) {
    if (identical(other, this)) return true;
    return other is EventBatchAck &&
        acceptedClientEventIds == other.acceptedClientEventIds &&
        rejected == other.rejected;
  }

  @override
  int get hashCode {
    var _$hash = 0;
    _$hash = $jc(_$hash, acceptedClientEventIds.hashCode);
    _$hash = $jc(_$hash, rejected.hashCode);
    _$hash = $jf(_$hash);
    return _$hash;
  }

  @override
  String toString() {
    return (newBuiltValueToStringHelper(r'EventBatchAck')
          ..add('acceptedClientEventIds', acceptedClientEventIds)
          ..add('rejected', rejected))
        .toString();
  }
}

class EventBatchAckBuilder
    implements Builder<EventBatchAck, EventBatchAckBuilder> {
  _$EventBatchAck? _$v;

  ListBuilder<String>? _acceptedClientEventIds;
  ListBuilder<String> get acceptedClientEventIds =>
      _$this._acceptedClientEventIds ??= ListBuilder<String>();
  set acceptedClientEventIds(ListBuilder<String>? acceptedClientEventIds) =>
      _$this._acceptedClientEventIds = acceptedClientEventIds;

  ListBuilder<Problem>? _rejected;
  ListBuilder<Problem> get rejected =>
      _$this._rejected ??= ListBuilder<Problem>();
  set rejected(ListBuilder<Problem>? rejected) => _$this._rejected = rejected;

  EventBatchAckBuilder() {
    EventBatchAck._defaults(this);
  }

  EventBatchAckBuilder get _$this {
    final $v = _$v;
    if ($v != null) {
      _acceptedClientEventIds = $v.acceptedClientEventIds.toBuilder();
      _rejected = $v.rejected?.toBuilder();
      _$v = null;
    }
    return this;
  }

  @override
  void replace(EventBatchAck other) {
    _$v = other as _$EventBatchAck;
  }

  @override
  void update(void Function(EventBatchAckBuilder)? updates) {
    if (updates != null) updates(this);
  }

  @override
  EventBatchAck build() => _build();

  _$EventBatchAck _build() {
    _$EventBatchAck _$result;
    try {
      _$result = _$v ??
          _$EventBatchAck._(
            acceptedClientEventIds: acceptedClientEventIds.build(),
            rejected: _rejected?.build(),
          );
    } catch (_) {
      late String _$failedField;
      try {
        _$failedField = 'acceptedClientEventIds';
        acceptedClientEventIds.build();
        _$failedField = 'rejected';
        _rejected?.build();
      } catch (e) {
        throw BuiltValueNestedFieldError(
            r'EventBatchAck', _$failedField, e.toString());
      }
      rethrow;
    }
    replace(_$result);
    return _$result;
  }
}

// ignore_for_file: deprecated_member_use_from_same_package,type=lint
