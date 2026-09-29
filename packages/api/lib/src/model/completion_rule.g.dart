// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'completion_rule.dart';

// **************************************************************************
// BuiltValueGenerator
// **************************************************************************

const CompletionRuleCollectionScopeEnum
    _$completionRuleCollectionScopeEnum_level =
    const CompletionRuleCollectionScopeEnum._('level');
const CompletionRuleCollectionScopeEnum
    _$completionRuleCollectionScopeEnum_ecosystem =
    const CompletionRuleCollectionScopeEnum._('ecosystem');

CompletionRuleCollectionScopeEnum _$completionRuleCollectionScopeEnumValueOf(
    String name) {
  switch (name) {
    case 'level':
      return _$completionRuleCollectionScopeEnum_level;
    case 'ecosystem':
      return _$completionRuleCollectionScopeEnum_ecosystem;
    default:
      throw ArgumentError(name);
  }
}

final BuiltSet<CompletionRuleCollectionScopeEnum>
    _$completionRuleCollectionScopeEnumValues = BuiltSet<
        CompletionRuleCollectionScopeEnum>(const <CompletionRuleCollectionScopeEnum>[
  _$completionRuleCollectionScopeEnum_level,
  _$completionRuleCollectionScopeEnum_ecosystem,
]);

Serializer<CompletionRuleCollectionScopeEnum>
    _$completionRuleCollectionScopeEnumSerializer =
    _$CompletionRuleCollectionScopeEnumSerializer();

class _$CompletionRuleCollectionScopeEnumSerializer
    implements PrimitiveSerializer<CompletionRuleCollectionScopeEnum> {
  static const Map<String, Object> _toWire = const <String, Object>{
    'level': 'level',
    'ecosystem': 'ecosystem',
  };
  static const Map<Object, String> _fromWire = const <Object, String>{
    'level': 'level',
    'ecosystem': 'ecosystem',
  };

  @override
  final Iterable<Type> types = const <Type>[CompletionRuleCollectionScopeEnum];
  @override
  final String wireName = 'CompletionRuleCollectionScopeEnum';

  @override
  Object serialize(
          Serializers serializers, CompletionRuleCollectionScopeEnum object,
          {FullType specifiedType = FullType.unspecified}) =>
      _toWire[object.name] ?? object.name;

  @override
  CompletionRuleCollectionScopeEnum deserialize(
          Serializers serializers, Object serialized,
          {FullType specifiedType = FullType.unspecified}) =>
      CompletionRuleCollectionScopeEnum.valueOf(
          _fromWire[serialized] ?? (serialized is String ? serialized : ''));
}

class _$CompletionRule extends CompletionRule {
  @override
  final num minimumScore;
  @override
  final BuiltList<String>? requiredQuizIds;
  @override
  final BuiltList<String>? requiredLevelIds;
  @override
  final BuiltSet<String>? requiredPlantIds;
  @override
  final CompletionRuleCollectionScopeEnum? collectionScope;

  factory _$CompletionRule([void Function(CompletionRuleBuilder)? updates]) =>
      (CompletionRuleBuilder()..update(updates))._build();

  _$CompletionRule._(
      {required this.minimumScore,
      this.requiredQuizIds,
      this.requiredLevelIds,
      this.requiredPlantIds,
      this.collectionScope})
      : super._();
  @override
  CompletionRule rebuild(void Function(CompletionRuleBuilder) updates) =>
      (toBuilder()..update(updates)).build();

  @override
  CompletionRuleBuilder toBuilder() => CompletionRuleBuilder()..replace(this);

  @override
  bool operator ==(Object other) {
    if (identical(other, this)) return true;
    return other is CompletionRule &&
        minimumScore == other.minimumScore &&
        requiredQuizIds == other.requiredQuizIds &&
        requiredLevelIds == other.requiredLevelIds &&
        requiredPlantIds == other.requiredPlantIds &&
        collectionScope == other.collectionScope;
  }

  @override
  int get hashCode {
    var _$hash = 0;
    _$hash = $jc(_$hash, minimumScore.hashCode);
    _$hash = $jc(_$hash, requiredQuizIds.hashCode);
    _$hash = $jc(_$hash, requiredLevelIds.hashCode);
    _$hash = $jc(_$hash, requiredPlantIds.hashCode);
    _$hash = $jc(_$hash, collectionScope.hashCode);
    _$hash = $jf(_$hash);
    return _$hash;
  }

  @override
  String toString() {
    return (newBuiltValueToStringHelper(r'CompletionRule')
          ..add('minimumScore', minimumScore)
          ..add('requiredQuizIds', requiredQuizIds)
          ..add('requiredLevelIds', requiredLevelIds)
          ..add('requiredPlantIds', requiredPlantIds)
          ..add('collectionScope', collectionScope))
        .toString();
  }
}

class CompletionRuleBuilder
    implements Builder<CompletionRule, CompletionRuleBuilder> {
  _$CompletionRule? _$v;

  num? _minimumScore;
  num? get minimumScore => _$this._minimumScore;
  set minimumScore(num? minimumScore) => _$this._minimumScore = minimumScore;

  ListBuilder<String>? _requiredQuizIds;
  ListBuilder<String> get requiredQuizIds =>
      _$this._requiredQuizIds ??= ListBuilder<String>();
  set requiredQuizIds(ListBuilder<String>? requiredQuizIds) =>
      _$this._requiredQuizIds = requiredQuizIds;

  ListBuilder<String>? _requiredLevelIds;
  ListBuilder<String> get requiredLevelIds =>
      _$this._requiredLevelIds ??= ListBuilder<String>();
  set requiredLevelIds(ListBuilder<String>? requiredLevelIds) =>
      _$this._requiredLevelIds = requiredLevelIds;

  SetBuilder<String>? _requiredPlantIds;
  SetBuilder<String> get requiredPlantIds =>
      _$this._requiredPlantIds ??= SetBuilder<String>();
  set requiredPlantIds(SetBuilder<String>? requiredPlantIds) =>
      _$this._requiredPlantIds = requiredPlantIds;

  CompletionRuleCollectionScopeEnum? _collectionScope;
  CompletionRuleCollectionScopeEnum? get collectionScope =>
      _$this._collectionScope;
  set collectionScope(CompletionRuleCollectionScopeEnum? collectionScope) =>
      _$this._collectionScope = collectionScope;

  CompletionRuleBuilder() {
    CompletionRule._defaults(this);
  }

  CompletionRuleBuilder get _$this {
    final $v = _$v;
    if ($v != null) {
      _minimumScore = $v.minimumScore;
      _requiredQuizIds = $v.requiredQuizIds?.toBuilder();
      _requiredLevelIds = $v.requiredLevelIds?.toBuilder();
      _requiredPlantIds = $v.requiredPlantIds?.toBuilder();
      _collectionScope = $v.collectionScope;
      _$v = null;
    }
    return this;
  }

  @override
  void replace(CompletionRule other) {
    _$v = other as _$CompletionRule;
  }

  @override
  void update(void Function(CompletionRuleBuilder)? updates) {
    if (updates != null) updates(this);
  }

  @override
  CompletionRule build() => _build();

  _$CompletionRule _build() {
    _$CompletionRule _$result;
    try {
      _$result = _$v ??
          _$CompletionRule._(
            minimumScore: BuiltValueNullFieldError.checkNotNull(
                minimumScore, r'CompletionRule', 'minimumScore'),
            requiredQuizIds: _requiredQuizIds?.build(),
            requiredLevelIds: _requiredLevelIds?.build(),
            requiredPlantIds: _requiredPlantIds?.build(),
            collectionScope: collectionScope,
          );
    } catch (_) {
      late String _$failedField;
      try {
        _$failedField = 'requiredQuizIds';
        _requiredQuizIds?.build();
        _$failedField = 'requiredLevelIds';
        _requiredLevelIds?.build();
        _$failedField = 'requiredPlantIds';
        _requiredPlantIds?.build();
      } catch (e) {
        throw BuiltValueNestedFieldError(
            r'CompletionRule', _$failedField, e.toString());
      }
      rethrow;
    }
    replace(_$result);
    return _$result;
  }
}

// ignore_for_file: deprecated_member_use_from_same_package,type=lint
