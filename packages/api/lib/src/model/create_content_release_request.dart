//
// AUTO-GENERATED FILE, DO NOT MODIFY!
//

// ignore_for_file: unused_element
import 'package:built_value/built_value.dart';
import 'package:built_value/serializer.dart';

part 'create_content_release_request.g.dart';

/// CreateContentReleaseRequest
///
/// Properties:
/// * [releaseVersion]
/// * [dryRun]
@BuiltValue()
abstract class CreateContentReleaseRequest
    implements
        Built<CreateContentReleaseRequest, CreateContentReleaseRequestBuilder> {
  @BuiltValueField(wireName: r'releaseVersion')
  String get releaseVersion;

  @BuiltValueField(wireName: r'dryRun')
  bool? get dryRun;

  CreateContentReleaseRequest._();

  factory CreateContentReleaseRequest(
          [void updates(CreateContentReleaseRequestBuilder b)]) =
      _$CreateContentReleaseRequest;

  @BuiltValueHook(initializeBuilder: true)
  static void _defaults(CreateContentReleaseRequestBuilder b) =>
      b..dryRun = false;

  @BuiltValueSerializer(custom: true)
  static Serializer<CreateContentReleaseRequest> get serializer =>
      _$CreateContentReleaseRequestSerializer();
}

class _$CreateContentReleaseRequestSerializer
    implements PrimitiveSerializer<CreateContentReleaseRequest> {
  @override
  final Iterable<Type> types = const [
    CreateContentReleaseRequest,
    _$CreateContentReleaseRequest
  ];

  @override
  final String wireName = r'CreateContentReleaseRequest';

  Iterable<Object?> _serializeProperties(
    Serializers serializers,
    CreateContentReleaseRequest object, {
    FullType specifiedType = FullType.unspecified,
  }) sync* {
    yield r'releaseVersion';
    yield serializers.serialize(
      object.releaseVersion,
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
    CreateContentReleaseRequest object, {
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
    required CreateContentReleaseRequestBuilder result,
    required List<Object?> unhandled,
  }) {
    for (var i = 0; i < serializedList.length; i += 2) {
      final key = serializedList[i] as String;
      final value = serializedList[i + 1];
      switch (key) {
        case r'releaseVersion':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType(String),
          ) as String;
          result.releaseVersion = valueDes;
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
  CreateContentReleaseRequest deserialize(
    Serializers serializers,
    Object serialized, {
    FullType specifiedType = FullType.unspecified,
  }) {
    final result = CreateContentReleaseRequestBuilder();
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
