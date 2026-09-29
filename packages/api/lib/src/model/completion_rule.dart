//
// AUTO-GENERATED FILE, DO NOT MODIFY!
//

// ignore_for_file: unused_element
import 'package:built_collection/built_collection.dart';
import 'package:built_value/built_value.dart';
import 'package:built_value/serializer.dart';

part 'completion_rule.g.dart';

/// CompletionRule
///
/// Properties:
/// * [minimumScore]
/// * [requiredQuizIds]
/// * [requiredLevelIds]
/// * [requiredPlantIds] - Explicit collection targets. Ecosystem-scoped ordinary levels return []; only the final level lists the three public UUIDs. Clients must not infer targets from plantIds.
/// * [collectionScope] - Legacy rules default to level and retain their per-level collection gate. Ecosystem rules never block quiz completion; GET ecosystem progress evaluates the final collection gate.
@BuiltValue()
abstract class CompletionRule
    implements Built<CompletionRule, CompletionRuleBuilder> {
  @BuiltValueField(wireName: r'minimumScore')
  num get minimumScore;

  @BuiltValueField(wireName: r'requiredQuizIds')
  BuiltList<String>? get requiredQuizIds;

  @BuiltValueField(wireName: r'requiredLevelIds')
  BuiltList<String>? get requiredLevelIds;

  /// Explicit collection targets. Ecosystem-scoped ordinary levels return []; only the final level lists the three public UUIDs. Clients must not infer targets from plantIds.
  @BuiltValueField(wireName: r'requiredPlantIds')
  BuiltSet<String>? get requiredPlantIds;

  /// Legacy rules default to level and retain their per-level collection gate. Ecosystem rules never block quiz completion; GET ecosystem progress evaluates the final collection gate.
  @BuiltValueField(wireName: r'collectionScope')
  CompletionRuleCollectionScopeEnum? get collectionScope;
  // enum collectionScopeEnum {  level,  ecosystem,  };

  CompletionRule._();

  factory CompletionRule([void updates(CompletionRuleBuilder b)]) =
      _$CompletionRule;

  @BuiltValueHook(initializeBuilder: true)
  static void _defaults(CompletionRuleBuilder b) =>
      b..collectionScope = CompletionRuleCollectionScopeEnum.valueOf('level');

  @BuiltValueSerializer(custom: true)
  static Serializer<CompletionRule> get serializer =>
      _$CompletionRuleSerializer();
}

class _$CompletionRuleSerializer
    implements PrimitiveSerializer<CompletionRule> {
  @override
  final Iterable<Type> types = const [CompletionRule, _$CompletionRule];

  @override
  final String wireName = r'CompletionRule';

  Iterable<Object?> _serializeProperties(
    Serializers serializers,
    CompletionRule object, {
    FullType specifiedType = FullType.unspecified,
  }) sync* {
    yield r'minimumScore';
    yield serializers.serialize(
      object.minimumScore,
      specifiedType: const FullType(num),
    );
    if (object.requiredQuizIds != null) {
      yield r'requiredQuizIds';
      yield serializers.serialize(
        object.requiredQuizIds,
        specifiedType: const FullType(BuiltList, [FullType(String)]),
      );
    }
    if (object.requiredLevelIds != null) {
      yield r'requiredLevelIds';
      yield serializers.serialize(
        object.requiredLevelIds,
        specifiedType: const FullType(BuiltList, [FullType(String)]),
      );
    }
    if (object.requiredPlantIds != null) {
      yield r'requiredPlantIds';
      yield serializers.serialize(
        object.requiredPlantIds,
        specifiedType: const FullType(BuiltSet, [FullType(String)]),
      );
    }
    if (object.collectionScope != null) {
      yield r'collectionScope';
      yield serializers.serialize(
        object.collectionScope,
        specifiedType: const FullType(CompletionRuleCollectionScopeEnum),
      );
    }
  }

  @override
  Object serialize(
    Serializers serializers,
    CompletionRule object, {
    FullType specifiedType = FullType.unspecified,
  }) {
    return _serializeProperties(serializers, object,
            specifiedType: specifiedType)
        .toList();
  }

  void _deserializeProperties(
    Serializers serializers,
    Object serialized, {
    FullType specifiedType = FullType.unspecified,
    required List<Object?> serializedList,
    required CompletionRuleBuilder result,
    required List<Object?> unhandled,
  }) {
    for (var i = 0; i < serializedList.length; i += 2) {
      final key = serializedList[i] as String;
      final value = serializedList[i + 1];
      switch (key) {
        case r'minimumScore':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType(num),
          ) as num;
          result.minimumScore = valueDes;
          break;
        case r'requiredQuizIds':
          final valueDes = serializers.deserialize(
            value,
            specifiedType:
                const FullType.nullable(BuiltList, [FullType(String)]),
          ) as BuiltList<String>?;
          if (valueDes == null) continue;
          result.requiredQuizIds.replace(valueDes);
          break;
        case r'requiredLevelIds':
          final valueDes = serializers.deserialize(
            value,
            specifiedType:
                const FullType.nullable(BuiltList, [FullType(String)]),
          ) as BuiltList<String>?;
          if (valueDes == null) continue;
          result.requiredLevelIds.replace(valueDes);
          break;
        case r'requiredPlantIds':
          final valueDes = serializers.deserialize(
            value,
            specifiedType:
                const FullType.nullable(BuiltSet, [FullType(String)]),
          ) as BuiltSet<String>?;
          if (valueDes == null) continue;
          result.requiredPlantIds.replace(valueDes);
          break;
        case r'collectionScope':
          final valueDes = serializers.deserialize(
            value,
            specifiedType:
                const FullType.nullable(CompletionRuleCollectionScopeEnum),
          ) as CompletionRuleCollectionScopeEnum?;
          if (valueDes == null) continue;
          result.collectionScope = valueDes;
          break;
        default:
          unhandled.add(key);
          unhandled.add(value);
          break;
      }
    }
  }

  @override
  CompletionRule deserialize(
    Serializers serializers,
    Object serialized, {
    FullType specifiedType = FullType.unspecified,
  }) {
    final result = CompletionRuleBuilder();
    final serializedList = (serialized as Iterable<Object?>).toList();
    final unhandled = <Object?>[];
    _deserializeProperties(
      serializers,
      serialized,
      specifiedType: specifiedType,
      serializedList: serializedList,
      unhandled: unhandled,
      result: result,
    );
    return result.build();
  }
}

/// Legacy rules default to level and retain their per-level collection gate. Ecosystem rules never block quiz completion; GET ecosystem progress evaluates the final collection gate.
class CompletionRuleCollectionScopeEnum extends EnumClass {
  @BuiltValueEnumConst(wireName: r'level')
  static const CompletionRuleCollectionScopeEnum level =
      _$completionRuleCollectionScopeEnum_level;
  @BuiltValueEnumConst(wireName: r'ecosystem')
  static const CompletionRuleCollectionScopeEnum ecosystem =
      _$completionRuleCollectionScopeEnum_ecosystem;

  static Serializer<CompletionRuleCollectionScopeEnum> get serializer =>
      _$completionRuleCollectionScopeEnumSerializer;

  const CompletionRuleCollectionScopeEnum._(String name) : super(name);

  static BuiltSet<CompletionRuleCollectionScopeEnum> get values =>
      _$completionRuleCollectionScopeEnumValues;
  static CompletionRuleCollectionScopeEnum valueOf(String name) =>
      _$completionRuleCollectionScopeEnumValueOf(name);
}
