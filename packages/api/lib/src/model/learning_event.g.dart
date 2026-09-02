// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'learning_event.dart';

// **************************************************************************
// BuiltValueGenerator
// **************************************************************************

class _$LearningEvent extends LearningEvent {
  @override
  final String clientEventId;
  @override
  final String type;
  @override
  final DateTime occurredAt;
  @override
  final int payloadVersion;
  @override
  final JsonObject? payload;

  factory _$LearningEvent([void Function(LearningEventBuilder)? updates]) =>
      (LearningEventBuilder()..update(updates))._build();

  _$LearningEvent._(
      {required this.clientEventId,
      required this.type,
      required this.occurredAt,
      required this.payloadVersion,
      this.payload})
      : super._();
  @override
  LearningEvent rebuild(void Function(LearningEventBuilder) updates) =>
      (toBuilder()..update(updates)).build();

  @override
  LearningEventBuilder toBuilder() => LearningEventBuilder()..replace(this);

  @override
  bool operator ==(Object other) {
    if (identical(other, this)) return true;
    return other is LearningEvent &&
        clientEventId == other.clientEventId &&
        type == other.type &&
        occurredAt == other.occurredAt &&
        payloadVersion == other.payloadVersion &&
        payload == other.payload;
  }

  @override
  int get hashCode {
    var _$hash = 0;
    _$hash = $jc(_$hash, clientEventId.hashCode);
    _$hash = $jc(_$hash, type.hashCode);
    _$hash = $jc(_$hash, occurredAt.hashCode);
    _$hash = $jc(_$hash, payloadVersion.hashCode);
    _$hash = $jc(_$hash, payload.hashCode);
    _$hash = $jf(_$hash);
    return _$hash;
  }

  @override
  String toString() {
    return (newBuiltValueToStringHelper(r'LearningEvent')
          ..add('clientEventId', clientEventId)
          ..add('type', type)
          ..add('occurredAt', occurredAt)
          ..add('payloadVersion', payloadVersion)
          ..add('payload', payload))
        .toString();
  }
}

class LearningEventBuilder
    implements Builder<LearningEvent, LearningEventBuilder> {
  _$LearningEvent? _$v;

  String? _clientEventId;
  String? get clientEventId => _$this._clientEventId;
  set clientEventId(String? clientEventId) =>
      _$this._clientEventId = clientEventId;

  String? _type;
  String? get type => _$this._type;
  set type(String? type) => _$this._type = type;

  DateTime? _occurredAt;
  DateTime? get occurredAt => _$this._occurredAt;
  set occurredAt(DateTime? occurredAt) => _$this._occurredAt = occurredAt;

  int? _payloadVersion;
  int? get payloadVersion => _$this._payloadVersion;
  set payloadVersion(int? payloadVersion) =>
      _$this._payloadVersion = payloadVersion;

  JsonObject? _payload;
  JsonObject? get payload => _$this._payload;
  set payload(JsonObject? payload) => _$this._payload = payload;

  LearningEventBuilder() {
    LearningEvent._defaults(this);
  }

  LearningEventBuilder get _$this {
    final $v = _$v;
    if ($v != null) {
      _clientEventId = $v.clientEventId;
      _type = $v.type;
      _occurredAt = $v.occurredAt;
      _payloadVersion = $v.payloadVersion;
      _payload = $v.payload;
      _$v = null;
    }
    return this;
  }

  @override
  void replace(LearningEvent other) {
    _$v = other as _$LearningEvent;
  }

  @override
  void update(void Function(LearningEventBuilder)? updates) {
    if (updates != null) updates(this);
  }

  @override
  LearningEvent build() => _build();

  _$LearningEvent _build() {
    final _$result = _$v ??
        _$LearningEvent._(
          clientEventId: BuiltValueNullFieldError.checkNotNull(
              clientEventId, r'LearningEvent', 'clientEventId'),
          type: BuiltValueNullFieldError.checkNotNull(
              type, r'LearningEvent', 'type'),
          occurredAt: BuiltValueNullFieldError.checkNotNull(
              occurredAt, r'LearningEvent', 'occurredAt'),
          payloadVersion: BuiltValueNullFieldError.checkNotNull(
              payloadVersion, r'LearningEvent', 'payloadVersion'),
          payload: payload,
        );
    replace(_$result);
    return _$result;
  }
}

// ignore_for_file: deprecated_member_use_from_same_package,type=lint
