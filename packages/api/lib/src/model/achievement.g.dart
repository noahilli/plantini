// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'achievement.dart';

// **************************************************************************
// BuiltValueGenerator
// **************************************************************************

const AchievementStatusEnum _$achievementStatusEnum_earned =
    const AchievementStatusEnum._('earned');
const AchievementStatusEnum _$achievementStatusEnum_next =
    const AchievementStatusEnum._('next');
const AchievementStatusEnum _$achievementStatusEnum_locked =
    const AchievementStatusEnum._('locked');

AchievementStatusEnum _$achievementStatusEnumValueOf(String name) {
  switch (name) {
    case 'earned':
      return _$achievementStatusEnum_earned;
    case 'next':
      return _$achievementStatusEnum_next;
    case 'locked':
      return _$achievementStatusEnum_locked;
    default:
      throw ArgumentError(name);
  }
}

final BuiltSet<AchievementStatusEnum> _$achievementStatusEnumValues =
    BuiltSet<AchievementStatusEnum>(const <AchievementStatusEnum>[
  _$achievementStatusEnum_earned,
  _$achievementStatusEnum_next,
  _$achievementStatusEnum_locked,
]);

Serializer<AchievementStatusEnum> _$achievementStatusEnumSerializer =
    _$AchievementStatusEnumSerializer();

class _$AchievementStatusEnumSerializer
    implements PrimitiveSerializer<AchievementStatusEnum> {
  static const Map<String, Object> _toWire = const <String, Object>{
    'earned': 'earned',
    'next': 'next',
    'locked': 'locked',
  };
  static const Map<Object, String> _fromWire = const <Object, String>{
    'earned': 'earned',
    'next': 'next',
    'locked': 'locked',
  };

  @override
  final Iterable<Type> types = const <Type>[AchievementStatusEnum];
  @override
  final String wireName = 'AchievementStatusEnum';

  @override
  Object serialize(Serializers serializers, AchievementStatusEnum object,
          {FullType specifiedType = FullType.unspecified}) =>
      _toWire[object.name] ?? object.name;

  @override
  AchievementStatusEnum deserialize(Serializers serializers, Object serialized,
          {FullType specifiedType = FullType.unspecified}) =>
      AchievementStatusEnum.valueOf(
          _fromWire[serialized] ?? (serialized is String ? serialized : ''));
}

class _$Achievement extends Achievement {
  @override
  final String id;
  @override
  final AchievementStatusEnum status;
  @override
  final String title;
  @override
  final String? description;
  @override
  final DateTime? earnedAt;

  factory _$Achievement([void Function(AchievementBuilder)? updates]) =>
      (AchievementBuilder()..update(updates))._build();

  _$Achievement._(
      {required this.id,
      required this.status,
      required this.title,
      this.description,
      this.earnedAt})
      : super._();
  @override
  Achievement rebuild(void Function(AchievementBuilder) updates) =>
      (toBuilder()..update(updates)).build();

  @override
  AchievementBuilder toBuilder() => AchievementBuilder()..replace(this);

  @override
  bool operator ==(Object other) {
    if (identical(other, this)) return true;
    return other is Achievement &&
        id == other.id &&
        status == other.status &&
        title == other.title &&
        description == other.description &&
        earnedAt == other.earnedAt;
  }

  @override
  int get hashCode {
    var _$hash = 0;
    _$hash = $jc(_$hash, id.hashCode);
    _$hash = $jc(_$hash, status.hashCode);
    _$hash = $jc(_$hash, title.hashCode);
    _$hash = $jc(_$hash, description.hashCode);
    _$hash = $jc(_$hash, earnedAt.hashCode);
    _$hash = $jf(_$hash);
    return _$hash;
  }

  @override
  String toString() {
    return (newBuiltValueToStringHelper(r'Achievement')
          ..add('id', id)
          ..add('status', status)
          ..add('title', title)
          ..add('description', description)
          ..add('earnedAt', earnedAt))
        .toString();
  }
}

class AchievementBuilder implements Builder<Achievement, AchievementBuilder> {
  _$Achievement? _$v;

  String? _id;
  String? get id => _$this._id;
  set id(String? id) => _$this._id = id;

  AchievementStatusEnum? _status;
  AchievementStatusEnum? get status => _$this._status;
  set status(AchievementStatusEnum? status) => _$this._status = status;

  String? _title;
  String? get title => _$this._title;
  set title(String? title) => _$this._title = title;

  String? _description;
  String? get description => _$this._description;
  set description(String? description) => _$this._description = description;

  DateTime? _earnedAt;
  DateTime? get earnedAt => _$this._earnedAt;
  set earnedAt(DateTime? earnedAt) => _$this._earnedAt = earnedAt;

  AchievementBuilder() {
    Achievement._defaults(this);
  }

  AchievementBuilder get _$this {
    final $v = _$v;
    if ($v != null) {
      _id = $v.id;
      _status = $v.status;
      _title = $v.title;
      _description = $v.description;
      _earnedAt = $v.earnedAt;
      _$v = null;
    }
    return this;
  }

  @override
  void replace(Achievement other) {
    _$v = other as _$Achievement;
  }

  @override
  void update(void Function(AchievementBuilder)? updates) {
    if (updates != null) updates(this);
  }

  @override
  Achievement build() => _build();

  _$Achievement _build() {
    final _$result = _$v ??
        _$Achievement._(
          id: BuiltValueNullFieldError.checkNotNull(id, r'Achievement', 'id'),
          status: BuiltValueNullFieldError.checkNotNull(
              status, r'Achievement', 'status'),
          title: BuiltValueNullFieldError.checkNotNull(
              title, r'Achievement', 'title'),
          description: description,
          earnedAt: earnedAt,
        );
    replace(_$result);
    return _$result;
  }
}

// ignore_for_file: deprecated_member_use_from_same_package,type=lint
