//
// AUTO-GENERATED FILE, DO NOT MODIFY!
//

// ignore_for_file: unused_element
import 'package:built_collection/built_collection.dart';
import 'package:openapi/src/model/learning_event.dart';
import 'package:built_value/built_value.dart';
import 'package:built_value/serializer.dart';

part 'sync_request.g.dart';

/// SyncRequest
///
/// Properties:
/// * [events]
/// * [contentCursor]
@BuiltValue()
abstract class SyncRequest implements Built<SyncRequest, SyncRequestBuilder> {
  @BuiltValueField(wireName: r'events')
  BuiltList<LearningEvent> get events;

  @BuiltValueField(wireName: r'contentCursor')
  String? get contentCursor;

  SyncRequest._();

  factory SyncRequest([void updates(SyncRequestBuilder b)]) = _$SyncRequest;

  @BuiltValueHook(initializeBuilder: true)
  static void _defaults(SyncRequestBuilder b) => b;

  @BuiltValueSerializer(custom: true)
  static Serializer<SyncRequest> get serializer => _$SyncRequestSerializer();
}

class _$SyncRequestSerializer implements PrimitiveSerializer<SyncRequest> {
  @override
  final Iterable<Type> types = const [SyncRequest, _$SyncRequest];

  @override
  final String wireName = r'SyncRequest';

  Iterable<Object?> _serializeProperties(
    Serializers serializers,
    SyncRequest object, {
    FullType specifiedType = FullType.unspecified,
  }) sync* {
    yield r'events';
    yield serializers.serialize(
      object.events,
      specifiedType: const FullType(BuiltList, [FullType(LearningEvent)]),
    );
    if (object.contentCursor != null) {
      yield r'contentCursor';
      yield serializers.serialize(
        object.contentCursor,
        specifiedType: const FullType(String),
      );
    }
  }

  @override
  Object serialize(
    Serializers serializers,
    SyncRequest object, {
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
    required SyncRequestBuilder result,
    required List<Object?> unhandled,
  }) {
    for (var i = 0; i < serializedList.length; i += 2) {
      final key = serializedList[i] as String;
      final value = serializedList[i + 1];
      switch (key) {
        case r'events':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType(BuiltList, [FullType(LearningEvent)]),
          ) as BuiltList<LearningEvent>;
          result.events.replace(valueDes);
          break;
        case r'contentCursor':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType.nullable(String),
          ) as String?;
          if (valueDes == null) continue;
          result.contentCursor = valueDes;
          break;
        default:
          unhandled.add(key);
          unhandled.add(value);
          break;
      }
    }
  }

  @override
  SyncRequest deserialize(
    Serializers serializers,
    Object serialized, {
    FullType specifiedType = FullType.unspecified,
  }) {
    final result = SyncRequestBuilder();
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
