// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'level_progress.dart';

// **************************************************************************
// BuiltValueGenerator
// **************************************************************************

const LevelProgressStatusEnum _$levelProgressStatusEnum_locked =
    const LevelProgressStatusEnum._('locked');
const LevelProgressStatusEnum _$levelProgressStatusEnum_available =
    const LevelProgressStatusEnum._('available');
const LevelProgressStatusEnum _$levelProgressStatusEnum_inProgress =
    const LevelProgressStatusEnum._('inProgress');
const LevelProgressStatusEnum _$levelProgressStatusEnum_completed =
    const LevelProgressStatusEnum._('completed');

LevelProgressStatusEnum _$levelProgressStatusEnumValueOf(String name) {
  switch (name) {
    case 'locked':
      return _$levelProgressStatusEnum_locked;
    case 'available':
      return _$levelProgressStatusEnum_available;
    case 'inProgress':
      return _$levelProgressStatusEnum_inProgress;
    case 'completed':
      return _$levelProgressStatusEnum_completed;
    default:
      throw ArgumentError(name);
  }
}

final BuiltSet<LevelProgressStatusEnum> _$levelProgressStatusEnumValues =
    BuiltSet<LevelProgressStatusEnum>(const <LevelProgressStatusEnum>[
  _$levelProgressStatusEnum_locked,
  _$levelProgressStatusEnum_available,
  _$levelProgressStatusEnum_inProgress,
  _$levelProgressStatusEnum_completed,
]);

Serializer<LevelProgressStatusEnum> _$levelProgressStatusEnumSerializer =
    _$LevelProgressStatusEnumSerializer();

class _$LevelProgressStatusEnumSerializer
    implements PrimitiveSerializer<LevelProgressStatusEnum> {
  static const Map<String, Object> _toWire = const <String, Object>{
    'locked': 'locked',
    'available': 'available',
    'inProgress': 'in_progress',
    'completed': 'completed',
  };
  static const Map<Object, String> _fromWire = const <Object, String>{
    'locked': 'locked',
    'available': 'available',
    'in_progress': 'inProgress',
    'completed': 'completed',
  };

  @override
  final Iterable<Type> types = const <Type>[LevelProgressStatusEnum];
  @override
  final String wireName = 'LevelProgressStatusEnum';

  @override
  Object serialize(Serializers serializers, LevelProgressStatusEnum object,
          {FullType specifiedType = FullType.unspecified}) =>
      _toWire[object.name] ?? object.name;

  @override
  LevelProgressStatusEnum deserialize(
          Serializers serializers, Object serialized,
          {FullType specifiedType = FullType.unspecified}) =>
      LevelProgressStatusEnum.valueOf(
          _fromWire[serialized] ?? (serialized is String ? serialized : ''));
}

class _$LevelProgress extends LevelProgress {
  @override
  final String levelId;
  @override
  final LevelProgressStatusEnum status;
  @override
  final num percentage;
  @override
  final DateTime? completedAt;

  factory _$LevelProgress([void Function(LevelProgressBuilder)? updates]) =>
      (LevelProgressBuilder()..update(updates))._build();

  _$LevelProgress._(
      {required this.levelId,
      required this.status,
      required this.percentage,
      this.completedAt})
      : super._();
  @override
  LevelProgress rebuild(void Function(LevelProgressBuilder) updates) =>
      (toBuilder()..update(updates)).build();

  @override
  LevelProgressBuilder toBuilder() => LevelProgressBuilder()..replace(this);

  @override
  bool operator ==(Object other) {
    if (identical(other, this)) return true;
    return other is LevelProgress &&
        levelId == other.levelId &&
        status == other.status &&
        percentage == other.percentage &&
        completedAt == other.completedAt;
  }

  @override
  int get hashCode {
    var _$hash = 0;
    _$hash = $jc(_$hash, levelId.hashCode);
    _$hash = $jc(_$hash, status.hashCode);
    _$hash = $jc(_$hash, percentage.hashCode);
    _$hash = $jc(_$hash, completedAt.hashCode);
    _$hash = $jf(_$hash);
    return _$hash;
  }

  @override
  String toString() {
    return (newBuiltValueToStringHelper(r'LevelProgress')
          ..add('levelId', levelId)
          ..add('status', status)
          ..add('percentage', percentage)
          ..add('completedAt', completedAt))
        .toString();
  }
}

class LevelProgressBuilder
    implements Builder<LevelProgress, LevelProgressBuilder> {
  _$LevelProgress? _$v;

  String? _levelId;
  String? get levelId => _$this._levelId;
  set levelId(String? levelId) => _$this._levelId = levelId;

  LevelProgressStatusEnum? _status;
  LevelProgressStatusEnum? get status => _$this._status;
  set status(LevelProgressStatusEnum? status) => _$this._status = status;

  num? _percentage;
  num? get percentage => _$this._percentage;
  set percentage(num? percentage) => _$this._percentage = percentage;

  DateTime? _completedAt;
  DateTime? get completedAt => _$this._completedAt;
  set completedAt(DateTime? completedAt) => _$this._completedAt = completedAt;

  LevelProgressBuilder() {
    LevelProgress._defaults(this);
  }

  LevelProgressBuilder get _$this {
    final $v = _$v;
    if ($v != null) {
      _levelId = $v.levelId;
      _status = $v.status;
      _percentage = $v.percentage;
      _completedAt = $v.completedAt;
      _$v = null;
    }
    return this;
  }

  @override
  void replace(LevelProgress other) {
    _$v = other as _$LevelProgress;
  }

  @override
  void update(void Function(LevelProgressBuilder)? updates) {
    if (updates != null) updates(this);
  }

  @override
  LevelProgress build() => _build();

  _$LevelProgress _build() {
    final _$result = _$v ??
        _$LevelProgress._(
          levelId: BuiltValueNullFieldError.checkNotNull(
              levelId, r'LevelProgress', 'levelId'),
          status: BuiltValueNullFieldError.checkNotNull(
              status, r'LevelProgress', 'status'),
          percentage: BuiltValueNullFieldError.checkNotNull(
              percentage, r'LevelProgress', 'percentage'),
          completedAt: completedAt,
        );
    replace(_$result);
    return _$result;
  }
}

// ignore_for_file: deprecated_member_use_from_same_package,type=lint
