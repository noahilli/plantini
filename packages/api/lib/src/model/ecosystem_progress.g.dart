// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'ecosystem_progress.dart';

// **************************************************************************
// BuiltValueGenerator
// **************************************************************************

const EcosystemProgressStatusEnum _$ecosystemProgressStatusEnum_inProgress =
    const EcosystemProgressStatusEnum._('inProgress');
const EcosystemProgressStatusEnum
    _$ecosystemProgressStatusEnum_collectionPending =
    const EcosystemProgressStatusEnum._('collectionPending');
const EcosystemProgressStatusEnum _$ecosystemProgressStatusEnum_completed =
    const EcosystemProgressStatusEnum._('completed');

EcosystemProgressStatusEnum _$ecosystemProgressStatusEnumValueOf(String name) {
  switch (name) {
    case 'inProgress':
      return _$ecosystemProgressStatusEnum_inProgress;
    case 'collectionPending':
      return _$ecosystemProgressStatusEnum_collectionPending;
    case 'completed':
      return _$ecosystemProgressStatusEnum_completed;
    default:
      throw ArgumentError(name);
  }
}

final BuiltSet<EcosystemProgressStatusEnum>
    _$ecosystemProgressStatusEnumValues =
    BuiltSet<EcosystemProgressStatusEnum>(const <EcosystemProgressStatusEnum>[
  _$ecosystemProgressStatusEnum_inProgress,
  _$ecosystemProgressStatusEnum_collectionPending,
  _$ecosystemProgressStatusEnum_completed,
]);

Serializer<EcosystemProgressStatusEnum>
    _$ecosystemProgressStatusEnumSerializer =
    _$EcosystemProgressStatusEnumSerializer();

class _$EcosystemProgressStatusEnumSerializer
    implements PrimitiveSerializer<EcosystemProgressStatusEnum> {
  static const Map<String, Object> _toWire = const <String, Object>{
    'inProgress': 'in_progress',
    'collectionPending': 'collection_pending',
    'completed': 'completed',
  };
  static const Map<Object, String> _fromWire = const <Object, String>{
    'in_progress': 'inProgress',
    'collection_pending': 'collectionPending',
    'completed': 'completed',
  };

  @override
  final Iterable<Type> types = const <Type>[EcosystemProgressStatusEnum];
  @override
  final String wireName = 'EcosystemProgressStatusEnum';

  @override
  Object serialize(Serializers serializers, EcosystemProgressStatusEnum object,
          {FullType specifiedType = FullType.unspecified}) =>
      _toWire[object.name] ?? object.name;

  @override
  EcosystemProgressStatusEnum deserialize(
          Serializers serializers, Object serialized,
          {FullType specifiedType = FullType.unspecified}) =>
      EcosystemProgressStatusEnum.valueOf(
          _fromWire[serialized] ?? (serialized is String ? serialized : ''));
}

class _$EcosystemProgress extends EcosystemProgress {
  @override
  final String ecosystemId;
  @override
  final EcosystemProgressStatusEnum status;
  @override
  final bool completed;
  @override
  final int totalLevels;
  @override
  final int completedLevelCount;
  @override
  final BuiltSet<String> completedLevelIds;
  @override
  final BuiltSet<String> requiredPlantIds;
  @override
  final BuiltSet<String> collectedPlantIds;
  @override
  final BuiltSet<String> missingPlantIds;

  factory _$EcosystemProgress(
          [void Function(EcosystemProgressBuilder)? updates]) =>
      (EcosystemProgressBuilder()..update(updates))._build();

  _$EcosystemProgress._(
      {required this.ecosystemId,
      required this.status,
      required this.completed,
      required this.totalLevels,
      required this.completedLevelCount,
      required this.completedLevelIds,
      required this.requiredPlantIds,
      required this.collectedPlantIds,
      required this.missingPlantIds})
      : super._();
  @override
  EcosystemProgress rebuild(void Function(EcosystemProgressBuilder) updates) =>
      (toBuilder()..update(updates)).build();

  @override
  EcosystemProgressBuilder toBuilder() =>
      EcosystemProgressBuilder()..replace(this);

  @override
  bool operator ==(Object other) {
    if (identical(other, this)) return true;
    return other is EcosystemProgress &&
        ecosystemId == other.ecosystemId &&
        status == other.status &&
        completed == other.completed &&
        totalLevels == other.totalLevels &&
        completedLevelCount == other.completedLevelCount &&
        completedLevelIds == other.completedLevelIds &&
        requiredPlantIds == other.requiredPlantIds &&
        collectedPlantIds == other.collectedPlantIds &&
        missingPlantIds == other.missingPlantIds;
  }

  @override
  int get hashCode {
    var _$hash = 0;
    _$hash = $jc(_$hash, ecosystemId.hashCode);
    _$hash = $jc(_$hash, status.hashCode);
    _$hash = $jc(_$hash, completed.hashCode);
    _$hash = $jc(_$hash, totalLevels.hashCode);
    _$hash = $jc(_$hash, completedLevelCount.hashCode);
    _$hash = $jc(_$hash, completedLevelIds.hashCode);
    _$hash = $jc(_$hash, requiredPlantIds.hashCode);
    _$hash = $jc(_$hash, collectedPlantIds.hashCode);
    _$hash = $jc(_$hash, missingPlantIds.hashCode);
    _$hash = $jf(_$hash);
    return _$hash;
  }

  @override
  String toString() {
    return (newBuiltValueToStringHelper(r'EcosystemProgress')
          ..add('ecosystemId', ecosystemId)
          ..add('status', status)
          ..add('completed', completed)
          ..add('totalLevels', totalLevels)
          ..add('completedLevelCount', completedLevelCount)
          ..add('completedLevelIds', completedLevelIds)
          ..add('requiredPlantIds', requiredPlantIds)
          ..add('collectedPlantIds', collectedPlantIds)
          ..add('missingPlantIds', missingPlantIds))
        .toString();
  }
}

class EcosystemProgressBuilder
    implements Builder<EcosystemProgress, EcosystemProgressBuilder> {
  _$EcosystemProgress? _$v;

  String? _ecosystemId;
  String? get ecosystemId => _$this._ecosystemId;
  set ecosystemId(String? ecosystemId) => _$this._ecosystemId = ecosystemId;

  EcosystemProgressStatusEnum? _status;
  EcosystemProgressStatusEnum? get status => _$this._status;
  set status(EcosystemProgressStatusEnum? status) => _$this._status = status;

  bool? _completed;
  bool? get completed => _$this._completed;
  set completed(bool? completed) => _$this._completed = completed;

  int? _totalLevels;
  int? get totalLevels => _$this._totalLevels;
  set totalLevels(int? totalLevels) => _$this._totalLevels = totalLevels;

  int? _completedLevelCount;
  int? get completedLevelCount => _$this._completedLevelCount;
  set completedLevelCount(int? completedLevelCount) =>
      _$this._completedLevelCount = completedLevelCount;

  SetBuilder<String>? _completedLevelIds;
  SetBuilder<String> get completedLevelIds =>
      _$this._completedLevelIds ??= SetBuilder<String>();
  set completedLevelIds(SetBuilder<String>? completedLevelIds) =>
      _$this._completedLevelIds = completedLevelIds;

  SetBuilder<String>? _requiredPlantIds;
  SetBuilder<String> get requiredPlantIds =>
      _$this._requiredPlantIds ??= SetBuilder<String>();
  set requiredPlantIds(SetBuilder<String>? requiredPlantIds) =>
      _$this._requiredPlantIds = requiredPlantIds;

  SetBuilder<String>? _collectedPlantIds;
  SetBuilder<String> get collectedPlantIds =>
      _$this._collectedPlantIds ??= SetBuilder<String>();
  set collectedPlantIds(SetBuilder<String>? collectedPlantIds) =>
      _$this._collectedPlantIds = collectedPlantIds;

  SetBuilder<String>? _missingPlantIds;
  SetBuilder<String> get missingPlantIds =>
      _$this._missingPlantIds ??= SetBuilder<String>();
  set missingPlantIds(SetBuilder<String>? missingPlantIds) =>
      _$this._missingPlantIds = missingPlantIds;

  EcosystemProgressBuilder() {
    EcosystemProgress._defaults(this);
  }

  EcosystemProgressBuilder get _$this {
    final $v = _$v;
    if ($v != null) {
      _ecosystemId = $v.ecosystemId;
      _status = $v.status;
      _completed = $v.completed;
      _totalLevels = $v.totalLevels;
      _completedLevelCount = $v.completedLevelCount;
      _completedLevelIds = $v.completedLevelIds.toBuilder();
      _requiredPlantIds = $v.requiredPlantIds.toBuilder();
      _collectedPlantIds = $v.collectedPlantIds.toBuilder();
      _missingPlantIds = $v.missingPlantIds.toBuilder();
      _$v = null;
    }
    return this;
  }

  @override
  void replace(EcosystemProgress other) {
    _$v = other as _$EcosystemProgress;
  }

  @override
  void update(void Function(EcosystemProgressBuilder)? updates) {
    if (updates != null) updates(this);
  }

  @override
  EcosystemProgress build() => _build();

  _$EcosystemProgress _build() {
    _$EcosystemProgress _$result;
    try {
      _$result = _$v ??
          _$EcosystemProgress._(
            ecosystemId: BuiltValueNullFieldError.checkNotNull(
                ecosystemId, r'EcosystemProgress', 'ecosystemId'),
            status: BuiltValueNullFieldError.checkNotNull(
                status, r'EcosystemProgress', 'status'),
            completed: BuiltValueNullFieldError.checkNotNull(
                completed, r'EcosystemProgress', 'completed'),
            totalLevels: BuiltValueNullFieldError.checkNotNull(
                totalLevels, r'EcosystemProgress', 'totalLevels'),
            completedLevelCount: BuiltValueNullFieldError.checkNotNull(
                completedLevelCount,
                r'EcosystemProgress',
                'completedLevelCount'),
            completedLevelIds: completedLevelIds.build(),
            requiredPlantIds: requiredPlantIds.build(),
            collectedPlantIds: collectedPlantIds.build(),
            missingPlantIds: missingPlantIds.build(),
          );
    } catch (_) {
      late String _$failedField;
      try {
        _$failedField = 'completedLevelIds';
        completedLevelIds.build();
        _$failedField = 'requiredPlantIds';
        requiredPlantIds.build();
        _$failedField = 'collectedPlantIds';
        collectedPlantIds.build();
        _$failedField = 'missingPlantIds';
        missingPlantIds.build();
      } catch (e) {
        throw BuiltValueNestedFieldError(
            r'EcosystemProgress', _$failedField, e.toString());
      }
      rethrow;
    }
    replace(_$result);
    return _$result;
  }
}

// ignore_for_file: deprecated_member_use_from_same_package,type=lint
