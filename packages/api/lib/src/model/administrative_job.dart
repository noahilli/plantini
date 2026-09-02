//
// AUTO-GENERATED FILE, DO NOT MODIFY!
//

// ignore_for_file: unused_element
import 'package:built_collection/built_collection.dart';
import 'package:built_value/built_value.dart';
import 'package:built_value/serializer.dart';

part 'administrative_job.g.dart';

/// AdministrativeJob
///
/// Properties:
/// * [id]
/// * [status]
/// * [createdAt]
/// * [failureCode]
@BuiltValue()
abstract class AdministrativeJob
    implements Built<AdministrativeJob, AdministrativeJobBuilder> {
  @BuiltValueField(wireName: r'id')
  String get id;

  @BuiltValueField(wireName: r'status')
  AdministrativeJobStatusEnum get status;
  // enum statusEnum {  pending,  processing,  completed,  failed,  };

  @BuiltValueField(wireName: r'createdAt')
  DateTime get createdAt;

  @BuiltValueField(wireName: r'failureCode')
  String? get failureCode;

  AdministrativeJob._();

  factory AdministrativeJob([void updates(AdministrativeJobBuilder b)]) =
      _$AdministrativeJob;

  @BuiltValueHook(initializeBuilder: true)
  static void _defaults(AdministrativeJobBuilder b) => b;

  @BuiltValueSerializer(custom: true)
  static Serializer<AdministrativeJob> get serializer =>
      _$AdministrativeJobSerializer();
}

class _$AdministrativeJobSerializer
    implements PrimitiveSerializer<AdministrativeJob> {
  @override
  final Iterable<Type> types = const [AdministrativeJob, _$AdministrativeJob];

  @override
  final String wireName = r'AdministrativeJob';

  Iterable<Object?> _serializeProperties(
    Serializers serializers,
    AdministrativeJob object, {
    FullType specifiedType = FullType.unspecified,
  }) sync* {
    yield r'id';
    yield serializers.serialize(
      object.id,
      specifiedType: const FullType(String),
    );
    yield r'status';
    yield serializers.serialize(
      object.status,
      specifiedType: const FullType(AdministrativeJobStatusEnum),
    );
    yield r'createdAt';
    yield serializers.serialize(
      object.createdAt,
      specifiedType: const FullType(DateTime),
    );
    if (object.failureCode != null) {
      yield r'failureCode';
      yield serializers.serialize(
        object.failureCode,
        specifiedType: const FullType(String),
      );
    }
  }

  @override
  Object serialize(
    Serializers serializers,
    AdministrativeJob object, {
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
    required AdministrativeJobBuilder result,
    required List<Object?> unhandled,
  }) {
    for (var i = 0; i < serializedList.length; i += 2) {
      final key = serializedList[i] as String;
      final value = serializedList[i + 1];
      switch (key) {
        case r'id':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType(String),
          ) as String;
          result.id = valueDes;
          break;
        case r'status':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType(AdministrativeJobStatusEnum),
          ) as AdministrativeJobStatusEnum;
          result.status = valueDes;
          break;
        case r'createdAt':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType(DateTime),
          ) as DateTime;
          result.createdAt = valueDes;
          break;
        case r'failureCode':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType.nullable(String),
          ) as String?;
          if (valueDes == null) continue;
          result.failureCode = valueDes;
          break;
        default:
          unhandled.add(key);
          unhandled.add(value);
          break;
      }
    }
  }

  @override
  AdministrativeJob deserialize(
    Serializers serializers,
    Object serialized, {
    FullType specifiedType = FullType.unspecified,
  }) {
    final result = AdministrativeJobBuilder();
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

class AdministrativeJobStatusEnum extends EnumClass {
  @BuiltValueEnumConst(wireName: r'pending')
  static const AdministrativeJobStatusEnum pending =
      _$administrativeJobStatusEnum_pending;
  @BuiltValueEnumConst(wireName: r'processing')
  static const AdministrativeJobStatusEnum processing =
      _$administrativeJobStatusEnum_processing;
  @BuiltValueEnumConst(wireName: r'completed')
  static const AdministrativeJobStatusEnum completed =
      _$administrativeJobStatusEnum_completed;
  @BuiltValueEnumConst(wireName: r'failed')
  static const AdministrativeJobStatusEnum failed =
      _$administrativeJobStatusEnum_failed;

  static Serializer<AdministrativeJobStatusEnum> get serializer =>
      _$administrativeJobStatusEnumSerializer;

  const AdministrativeJobStatusEnum._(String name) : super(name);

  static BuiltSet<AdministrativeJobStatusEnum> get values =>
      _$administrativeJobStatusEnumValues;
  static AdministrativeJobStatusEnum valueOf(String name) =>
      _$administrativeJobStatusEnumValueOf(name);
}
