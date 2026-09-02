// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'level.dart';

// **************************************************************************
// BuiltValueGenerator
// **************************************************************************

const LevelStatusEnum _$levelStatusEnum_locked =
    const LevelStatusEnum._('locked');
const LevelStatusEnum _$levelStatusEnum_available =
    const LevelStatusEnum._('available');
const LevelStatusEnum _$levelStatusEnum_inProgress =
    const LevelStatusEnum._('inProgress');
const LevelStatusEnum _$levelStatusEnum_completed =
    const LevelStatusEnum._('completed');

LevelStatusEnum _$levelStatusEnumValueOf(String name) {
  switch (name) {
    case 'locked':
      return _$levelStatusEnum_locked;
    case 'available':
      return _$levelStatusEnum_available;
    case 'inProgress':
      return _$levelStatusEnum_inProgress;
    case 'completed':
      return _$levelStatusEnum_completed;
    default:
      throw ArgumentError(name);
  }
}

final BuiltSet<LevelStatusEnum> _$levelStatusEnumValues =
    BuiltSet<LevelStatusEnum>(const <LevelStatusEnum>[
  _$levelStatusEnum_locked,
  _$levelStatusEnum_available,
  _$levelStatusEnum_inProgress,
  _$levelStatusEnum_completed,
]);

Serializer<LevelStatusEnum> _$levelStatusEnumSerializer =
    _$LevelStatusEnumSerializer();

class _$LevelStatusEnumSerializer
    implements PrimitiveSerializer<LevelStatusEnum> {
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
  final Iterable<Type> types = const <Type>[LevelStatusEnum];
  @override
  final String wireName = 'LevelStatusEnum';

  @override
  Object serialize(Serializers serializers, LevelStatusEnum object,
          {FullType specifiedType = FullType.unspecified}) =>
      _toWire[object.name] ?? object.name;

  @override
  LevelStatusEnum deserialize(Serializers serializers, Object serialized,
          {FullType specifiedType = FullType.unspecified}) =>
      LevelStatusEnum.valueOf(
          _fromWire[serialized] ?? (serialized is String ? serialized : ''));
}

class _$Level extends Level {
  @override
  final String id;
  @override
  final String ecosystemId;
  @override
  final String title;
  @override
  final int sequence;
  @override
  final String? learningGoal;
  @override
  final BuiltList<String>? plantIds;
  @override
  final CompletionRule completionRule;
  @override
  final LevelStatusEnum status;
  @override
  final num? progress;

  factory _$Level([void Function(LevelBuilder)? updates]) =>
      (LevelBuilder()..update(updates))._build();

  _$Level._(
      {required this.id,
      required this.ecosystemId,
      required this.title,
      required this.sequence,
      this.learningGoal,
      this.plantIds,
      required this.completionRule,
      required this.status,
      this.progress})
      : super._();
  @override
  Level rebuild(void Function(LevelBuilder) updates) =>
      (toBuilder()..update(updates)).build();

  @override
  LevelBuilder toBuilder() => LevelBuilder()..replace(this);

  @override
  bool operator ==(Object other) {
    if (identical(other, this)) return true;
    return other is Level &&
        id == other.id &&
        ecosystemId == other.ecosystemId &&
        title == other.title &&
        sequence == other.sequence &&
        learningGoal == other.learningGoal &&
        plantIds == other.plantIds &&
        completionRule == other.completionRule &&
        status == other.status &&
        progress == other.progress;
  }

  @override
  int get hashCode {
    var _$hash = 0;
    _$hash = $jc(_$hash, id.hashCode);
    _$hash = $jc(_$hash, ecosystemId.hashCode);
    _$hash = $jc(_$hash, title.hashCode);
    _$hash = $jc(_$hash, sequence.hashCode);
    _$hash = $jc(_$hash, learningGoal.hashCode);
    _$hash = $jc(_$hash, plantIds.hashCode);
    _$hash = $jc(_$hash, completionRule.hashCode);
    _$hash = $jc(_$hash, status.hashCode);
    _$hash = $jc(_$hash, progress.hashCode);
    _$hash = $jf(_$hash);
    return _$hash;
  }

  @override
  String toString() {
    return (newBuiltValueToStringHelper(r'Level')
          ..add('id', id)
          ..add('ecosystemId', ecosystemId)
          ..add('title', title)
          ..add('sequence', sequence)
          ..add('learningGoal', learningGoal)
          ..add('plantIds', plantIds)
          ..add('completionRule', completionRule)
          ..add('status', status)
          ..add('progress', progress))
        .toString();
  }
}

class LevelBuilder implements Builder<Level, LevelBuilder> {
  _$Level? _$v;

  String? _id;
  String? get id => _$this._id;
  set id(String? id) => _$this._id = id;

  String? _ecosystemId;
  String? get ecosystemId => _$this._ecosystemId;
  set ecosystemId(String? ecosystemId) => _$this._ecosystemId = ecosystemId;

  String? _title;
  String? get title => _$this._title;
  set title(String? title) => _$this._title = title;

  int? _sequence;
  int? get sequence => _$this._sequence;
  set sequence(int? sequence) => _$this._sequence = sequence;

  String? _learningGoal;
  String? get learningGoal => _$this._learningGoal;
  set learningGoal(String? learningGoal) => _$this._learningGoal = learningGoal;

  ListBuilder<String>? _plantIds;
  ListBuilder<String> get plantIds =>
      _$this._plantIds ??= ListBuilder<String>();
  set plantIds(ListBuilder<String>? plantIds) => _$this._plantIds = plantIds;

  CompletionRuleBuilder? _completionRule;
  CompletionRuleBuilder get completionRule =>
      _$this._completionRule ??= CompletionRuleBuilder();
  set completionRule(CompletionRuleBuilder? completionRule) =>
      _$this._completionRule = completionRule;

  LevelStatusEnum? _status;
  LevelStatusEnum? get status => _$this._status;
  set status(LevelStatusEnum? status) => _$this._status = status;

  num? _progress;
  num? get progress => _$this._progress;
  set progress(num? progress) => _$this._progress = progress;

  LevelBuilder() {
    Level._defaults(this);
  }

  LevelBuilder get _$this {
    final $v = _$v;
    if ($v != null) {
      _id = $v.id;
      _ecosystemId = $v.ecosystemId;
      _title = $v.title;
      _sequence = $v.sequence;
      _learningGoal = $v.learningGoal;
      _plantIds = $v.plantIds?.toBuilder();
      _completionRule = $v.completionRule.toBuilder();
      _status = $v.status;
      _progress = $v.progress;
      _$v = null;
    }
    return this;
  }

  @override
  void replace(Level other) {
    _$v = other as _$Level;
  }

  @override
  void update(void Function(LevelBuilder)? updates) {
    if (updates != null) updates(this);
  }

  @override
  Level build() => _build();

  _$Level _build() {
    _$Level _$result;
    try {
      _$result = _$v ??
          _$Level._(
            id: BuiltValueNullFieldError.checkNotNull(id, r'Level', 'id'),
            ecosystemId: BuiltValueNullFieldError.checkNotNull(
                ecosystemId, r'Level', 'ecosystemId'),
            title:
                BuiltValueNullFieldError.checkNotNull(title, r'Level', 'title'),
            sequence: BuiltValueNullFieldError.checkNotNull(
                sequence, r'Level', 'sequence'),
            learningGoal: learningGoal,
            plantIds: _plantIds?.build(),
            completionRule: completionRule.build(),
            status: BuiltValueNullFieldError.checkNotNull(
                status, r'Level', 'status'),
            progress: progress,
          );
    } catch (_) {
      late String _$failedField;
      try {
        _$failedField = 'plantIds';
        _plantIds?.build();
        _$failedField = 'completionRule';
        completionRule.build();
      } catch (e) {
        throw BuiltValueNestedFieldError(r'Level', _$failedField, e.toString());
      }
      rethrow;
    }
    replace(_$result);
    return _$result;
  }
}

// ignore_for_file: deprecated_member_use_from_same_package,type=lint
