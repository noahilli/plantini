// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'level_attempt.dart';

// **************************************************************************
// BuiltValueGenerator
// **************************************************************************

const LevelAttemptStatusEnum _$levelAttemptStatusEnum_active =
    const LevelAttemptStatusEnum._('active');
const LevelAttemptStatusEnum _$levelAttemptStatusEnum_completed =
    const LevelAttemptStatusEnum._('completed');
const LevelAttemptStatusEnum _$levelAttemptStatusEnum_expired =
    const LevelAttemptStatusEnum._('expired');

LevelAttemptStatusEnum _$levelAttemptStatusEnumValueOf(String name) {
  switch (name) {
    case 'active':
      return _$levelAttemptStatusEnum_active;
    case 'completed':
      return _$levelAttemptStatusEnum_completed;
    case 'expired':
      return _$levelAttemptStatusEnum_expired;
    default:
      throw ArgumentError(name);
  }
}

final BuiltSet<LevelAttemptStatusEnum> _$levelAttemptStatusEnumValues =
    BuiltSet<LevelAttemptStatusEnum>(const <LevelAttemptStatusEnum>[
  _$levelAttemptStatusEnum_active,
  _$levelAttemptStatusEnum_completed,
  _$levelAttemptStatusEnum_expired,
]);

Serializer<LevelAttemptStatusEnum> _$levelAttemptStatusEnumSerializer =
    _$LevelAttemptStatusEnumSerializer();

class _$LevelAttemptStatusEnumSerializer
    implements PrimitiveSerializer<LevelAttemptStatusEnum> {
  static const Map<String, Object> _toWire = const <String, Object>{
    'active': 'active',
    'completed': 'completed',
    'expired': 'expired',
  };
  static const Map<Object, String> _fromWire = const <Object, String>{
    'active': 'active',
    'completed': 'completed',
    'expired': 'expired',
  };

  @override
  final Iterable<Type> types = const <Type>[LevelAttemptStatusEnum];
  @override
  final String wireName = 'LevelAttemptStatusEnum';

  @override
  Object serialize(Serializers serializers, LevelAttemptStatusEnum object,
          {FullType specifiedType = FullType.unspecified}) =>
      _toWire[object.name] ?? object.name;

  @override
  LevelAttemptStatusEnum deserialize(Serializers serializers, Object serialized,
          {FullType specifiedType = FullType.unspecified}) =>
      LevelAttemptStatusEnum.valueOf(
          _fromWire[serialized] ?? (serialized is String ? serialized : ''));
}

class _$LevelAttempt extends LevelAttempt {
  @override
  final String id;
  @override
  final String levelId;
  @override
  final LevelAttemptStatusEnum status;
  @override
  final String contentVersion;
  @override
  final DateTime? startedAt;

  factory _$LevelAttempt([void Function(LevelAttemptBuilder)? updates]) =>
      (LevelAttemptBuilder()..update(updates))._build();

  _$LevelAttempt._(
      {required this.id,
      required this.levelId,
      required this.status,
      required this.contentVersion,
      this.startedAt})
      : super._();
  @override
  LevelAttempt rebuild(void Function(LevelAttemptBuilder) updates) =>
      (toBuilder()..update(updates)).build();

  @override
  LevelAttemptBuilder toBuilder() => LevelAttemptBuilder()..replace(this);

  @override
  bool operator ==(Object other) {
    if (identical(other, this)) return true;
    return other is LevelAttempt &&
        id == other.id &&
        levelId == other.levelId &&
        status == other.status &&
        contentVersion == other.contentVersion &&
        startedAt == other.startedAt;
  }

  @override
  int get hashCode {
    var _$hash = 0;
    _$hash = $jc(_$hash, id.hashCode);
    _$hash = $jc(_$hash, levelId.hashCode);
    _$hash = $jc(_$hash, status.hashCode);
    _$hash = $jc(_$hash, contentVersion.hashCode);
    _$hash = $jc(_$hash, startedAt.hashCode);
    _$hash = $jf(_$hash);
    return _$hash;
  }

  @override
  String toString() {
    return (newBuiltValueToStringHelper(r'LevelAttempt')
          ..add('id', id)
          ..add('levelId', levelId)
          ..add('status', status)
          ..add('contentVersion', contentVersion)
          ..add('startedAt', startedAt))
        .toString();
  }
}

class LevelAttemptBuilder
    implements Builder<LevelAttempt, LevelAttemptBuilder> {
  _$LevelAttempt? _$v;

  String? _id;
  String? get id => _$this._id;
  set id(String? id) => _$this._id = id;

  String? _levelId;
  String? get levelId => _$this._levelId;
  set levelId(String? levelId) => _$this._levelId = levelId;

  LevelAttemptStatusEnum? _status;
  LevelAttemptStatusEnum? get status => _$this._status;
  set status(LevelAttemptStatusEnum? status) => _$this._status = status;

  String? _contentVersion;
  String? get contentVersion => _$this._contentVersion;
  set contentVersion(String? contentVersion) =>
      _$this._contentVersion = contentVersion;

  DateTime? _startedAt;
  DateTime? get startedAt => _$this._startedAt;
  set startedAt(DateTime? startedAt) => _$this._startedAt = startedAt;

  LevelAttemptBuilder() {
    LevelAttempt._defaults(this);
  }

  LevelAttemptBuilder get _$this {
    final $v = _$v;
    if ($v != null) {
      _id = $v.id;
      _levelId = $v.levelId;
      _status = $v.status;
      _contentVersion = $v.contentVersion;
      _startedAt = $v.startedAt;
      _$v = null;
    }
    return this;
  }

  @override
  void replace(LevelAttempt other) {
    _$v = other as _$LevelAttempt;
  }

  @override
  void update(void Function(LevelAttemptBuilder)? updates) {
    if (updates != null) updates(this);
  }

  @override
  LevelAttempt build() => _build();

  _$LevelAttempt _build() {
    final _$result = _$v ??
        _$LevelAttempt._(
          id: BuiltValueNullFieldError.checkNotNull(id, r'LevelAttempt', 'id'),
          levelId: BuiltValueNullFieldError.checkNotNull(
              levelId, r'LevelAttempt', 'levelId'),
          status: BuiltValueNullFieldError.checkNotNull(
              status, r'LevelAttempt', 'status'),
          contentVersion: BuiltValueNullFieldError.checkNotNull(
              contentVersion, r'LevelAttempt', 'contentVersion'),
          startedAt: startedAt,
        );
    replace(_$result);
    return _$result;
  }
}

// ignore_for_file: deprecated_member_use_from_same_package,type=lint
