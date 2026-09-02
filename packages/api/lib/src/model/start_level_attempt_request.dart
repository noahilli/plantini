//
// AUTO-GENERATED FILE, DO NOT MODIFY!
//

// ignore_for_file: unused_element
import 'package:built_value/built_value.dart';
import 'package:built_value/serializer.dart';

part 'start_level_attempt_request.g.dart';

/// StartLevelAttemptRequest
///
/// Properties:
/// * [levelId]
/// * [clientAttemptId]
/// * [contentVersion]
@BuiltValue()
abstract class StartLevelAttemptRequest
    implements
        Built<StartLevelAttemptRequest, StartLevelAttemptRequestBuilder> {
  @BuiltValueField(wireName: r'levelId')
  String get levelId;

  @BuiltValueField(wireName: r'clientAttemptId')
  String get clientAttemptId;

  @BuiltValueField(wireName: r'contentVersion')
  String get contentVersion;

  StartLevelAttemptRequest._();

  factory StartLevelAttemptRequest(
          [void updates(StartLevelAttemptRequestBuilder b)]) =
      _$StartLevelAttemptRequest;

  @BuiltValueHook(initializeBuilder: true)
  static void _defaults(StartLevelAttemptRequestBuilder b) => b;

  @BuiltValueSerializer(custom: true)
  static Serializer<StartLevelAttemptRequest> get serializer =>
      _$StartLevelAttemptRequestSerializer();
}

class _$StartLevelAttemptRequestSerializer
    implements PrimitiveSerializer<StartLevelAttemptRequest> {
  @override
  final Iterable<Type> types = const [
    StartLevelAttemptRequest,
    _$StartLevelAttemptRequest
  ];

  @override
  final String wireName = r'StartLevelAttemptRequest';

  Iterable<Object?> _serializeProperties(
    Serializers serializers,
    StartLevelAttemptRequest object, {
    FullType specifiedType = FullType.unspecified,
  }) sync* {
    yield r'levelId';
    yield serializers.serialize(
      object.levelId,
      specifiedType: const FullType(String),
    );
    yield r'clientAttemptId';
    yield serializers.serialize(
      object.clientAttemptId,
      specifiedType: const FullType(String),
    );
    yield r'contentVersion';
    yield serializers.serialize(
      object.contentVersion,
      specifiedType: const FullType(String),
    );
  }

  @override
  Object serialize(
    Serializers serializers,
    StartLevelAttemptRequest object, {
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
    required StartLevelAttemptRequestBuilder result,
    required List<Object?> unhandled,
  }) {
    for (var i = 0; i < serializedList.length; i += 2) {
      final key = serializedList[i] as String;
      final value = serializedList[i + 1];
      switch (key) {
        case r'levelId':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType(String),
          ) as String;
          result.levelId = valueDes;
          break;
        case r'clientAttemptId':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType(String),
          ) as String;
          result.clientAttemptId = valueDes;
          break;
        case r'contentVersion':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType(String),
          ) as String;
          result.contentVersion = valueDes;
          break;
        default:
          unhandled.add(key);
          unhandled.add(value);
          break;
      }
    }
  }

  @override
  StartLevelAttemptRequest deserialize(
    Serializers serializers,
    Object serialized, {
    FullType specifiedType = FullType.unspecified,
  }) {
    final result = StartLevelAttemptRequestBuilder();
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
