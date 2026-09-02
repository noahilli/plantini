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
@BuiltValue()
abstract class CompletionRule
    implements Built<CompletionRule, CompletionRuleBuilder> {
  @BuiltValueField(wireName: r'minimumScore')
  num get minimumScore;

  @BuiltValueField(wireName: r'requiredQuizIds')
  BuiltList<String>? get requiredQuizIds;

  CompletionRule._();

  factory CompletionRule([void updates(CompletionRuleBuilder b)]) =
      _$CompletionRule;

  @BuiltValueHook(initializeBuilder: true)
  static void _defaults(CompletionRuleBuilder b) => b;

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
