//
// AUTO-GENERATED FILE, DO NOT MODIFY!
//

// ignore_for_file: unused_element
import 'package:built_collection/built_collection.dart';
import 'package:built_value/built_value.dart';
import 'package:built_value/serializer.dart';

part 'create_import_request.g.dart';

/// CreateImportRequest
///
/// Properties:
/// * [kind]
/// * [sourceVersion]
/// * [dryRun]
@BuiltValue()
abstract class CreateImportRequest
    implements Built<CreateImportRequest, CreateImportRequestBuilder> {
  @BuiltValueField(wireName: r'kind')
  CreateImportRequestKindEnum get kind;
  // enum kindEnum {  plants,  quiz_items,  translations,  };

  @BuiltValueField(wireName: r'sourceVersion')
  String get sourceVersion;

  @BuiltValueField(wireName: r'dryRun')
  bool? get dryRun;

  CreateImportRequest._();

  factory CreateImportRequest([void updates(CreateImportRequestBuilder b)]) =
      _$CreateImportRequest;

  @BuiltValueHook(initializeBuilder: true)
  static void _defaults(CreateImportRequestBuilder b) => b..dryRun = true;

  @BuiltValueSerializer(custom: true)
  static Serializer<CreateImportRequest> get serializer =>
      _$CreateImportRequestSerializer();
}

class _$CreateImportRequestSerializer
    implements PrimitiveSerializer<CreateImportRequest> {
  @override
  final Iterable<Type> types = const [
    CreateImportRequest,
    _$CreateImportRequest
  ];

  @override
  final String wireName = r'CreateImportRequest';

  Iterable<Object?> _serializeProperties(
    Serializers serializers,
    CreateImportRequest object, {
    FullType specifiedType = FullType.unspecified,
  }) sync* {
    yield r'kind';
    yield serializers.serialize(
      object.kind,
      specifiedType: const FullType(CreateImportRequestKindEnum),
    );
    yield r'sourceVersion';
    yield serializers.serialize(
      object.sourceVersion,
      specifiedType: const FullType(String),
    );
    if (object.dryRun != null) {
      yield r'dryRun';
      yield serializers.serialize(
        object.dryRun,
        specifiedType: const FullType(bool),
      );
    }
  }

  @override
  Object serialize(
    Serializers serializers,
    CreateImportRequest object, {
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
    required CreateImportRequestBuilder result,
    required List<Object?> unhandled,
  }) {
    for (var i = 0; i < serializedList.length; i += 2) {
      final key = serializedList[i] as String;
      final value = serializedList[i + 1];
      switch (key) {
        case r'kind':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType(CreateImportRequestKindEnum),
          ) as CreateImportRequestKindEnum;
          result.kind = valueDes;
          break;
        case r'sourceVersion':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType(String),
          ) as String;
          result.sourceVersion = valueDes;
          break;
        case r'dryRun':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType.nullable(bool),
          ) as bool?;
          if (valueDes == null) continue;
          result.dryRun = valueDes;
          break;
        default:
          unhandled.add(key);
          unhandled.add(value);
          break;
      }
    }
  }

  @override
  CreateImportRequest deserialize(
    Serializers serializers,
    Object serialized, {
    FullType specifiedType = FullType.unspecified,
  }) {
    final result = CreateImportRequestBuilder();
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

class CreateImportRequestKindEnum extends EnumClass {
  @BuiltValueEnumConst(wireName: r'plants')
  static const CreateImportRequestKindEnum plants =
      _$createImportRequestKindEnum_plants;
  @BuiltValueEnumConst(wireName: r'quiz_items')
  static const CreateImportRequestKindEnum quizItems =
      _$createImportRequestKindEnum_quizItems;
  @BuiltValueEnumConst(wireName: r'translations')
  static const CreateImportRequestKindEnum translations =
      _$createImportRequestKindEnum_translations;

  static Serializer<CreateImportRequestKindEnum> get serializer =>
      _$createImportRequestKindEnumSerializer;

  const CreateImportRequestKindEnum._(String name) : super(name);

  static BuiltSet<CreateImportRequestKindEnum> get values =>
      _$createImportRequestKindEnumValues;
  static CreateImportRequestKindEnum valueOf(String name) =>
      _$createImportRequestKindEnumValueOf(name);
}
