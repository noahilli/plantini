//
// AUTO-GENERATED FILE, DO NOT MODIFY!
//

// ignore_for_file: unused_element
import 'package:built_collection/built_collection.dart';
import 'package:built_value/built_value.dart';
import 'package:built_value/serializer.dart';

part 'admin_dashboard.g.dart';

/// AdminDashboard
///
/// Properties:
/// * [generatedAt]
/// * [metrics]
@BuiltValue()
abstract class AdminDashboard
    implements Built<AdminDashboard, AdminDashboardBuilder> {
  @BuiltValueField(wireName: r'generatedAt')
  DateTime get generatedAt;

  @BuiltValueField(wireName: r'metrics')
  BuiltMap<String, num> get metrics;

  AdminDashboard._();

  factory AdminDashboard([void updates(AdminDashboardBuilder b)]) =
      _$AdminDashboard;

  @BuiltValueHook(initializeBuilder: true)
  static void _defaults(AdminDashboardBuilder b) => b;

  @BuiltValueSerializer(custom: true)
  static Serializer<AdminDashboard> get serializer =>
      _$AdminDashboardSerializer();
}

class _$AdminDashboardSerializer
    implements PrimitiveSerializer<AdminDashboard> {
  @override
  final Iterable<Type> types = const [AdminDashboard, _$AdminDashboard];

  @override
  final String wireName = r'AdminDashboard';

  Iterable<Object?> _serializeProperties(
    Serializers serializers,
    AdminDashboard object, {
    FullType specifiedType = FullType.unspecified,
  }) sync* {
    yield r'generatedAt';
    yield serializers.serialize(
      object.generatedAt,
      specifiedType: const FullType(DateTime),
    );
    yield r'metrics';
    yield serializers.serialize(
      object.metrics,
      specifiedType:
          const FullType(BuiltMap, [FullType(String), FullType(num)]),
    );
  }

  @override
  Object serialize(
    Serializers serializers,
    AdminDashboard object, {
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
    required AdminDashboardBuilder result,
    required List<Object?> unhandled,
  }) {
    for (var i = 0; i < serializedList.length; i += 2) {
      final key = serializedList[i] as String;
      final value = serializedList[i + 1];
      switch (key) {
        case r'generatedAt':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType(DateTime),
          ) as DateTime;
          result.generatedAt = valueDes;
          break;
        case r'metrics':
          final valueDes = serializers.deserialize(
            value,
            specifiedType:
                const FullType(BuiltMap, [FullType(String), FullType(num)]),
          ) as BuiltMap<String, num>;
          result.metrics.replace(valueDes);
          break;
        default:
          unhandled.add(key);
          unhandled.add(value);
          break;
      }
    }
  }

  @override
  AdminDashboard deserialize(
    Serializers serializers,
    Object serialized, {
    FullType specifiedType = FullType.unspecified,
  }) {
    final result = AdminDashboardBuilder();
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
