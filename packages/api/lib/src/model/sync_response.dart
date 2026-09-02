//
// AUTO-GENERATED FILE, DO NOT MODIFY!
//

// ignore_for_file: unused_element
import 'package:built_collection/built_collection.dart';
import 'package:openapi/src/model/progress_snapshot.dart';
import 'package:built_value/built_value.dart';
import 'package:built_value/serializer.dart';

part 'sync_response.g.dart';

/// SyncResponse
///
/// Properties:
/// * [progress]
/// * [acknowledgedClientEventIds]
/// * [contentCursor]
@BuiltValue()
abstract class SyncResponse
    implements Built<SyncResponse, SyncResponseBuilder> {
  @BuiltValueField(wireName: r'progress')
  ProgressSnapshot get progress;

  @BuiltValueField(wireName: r'acknowledgedClientEventIds')
  BuiltList<String> get acknowledgedClientEventIds;

  @BuiltValueField(wireName: r'contentCursor')
  String? get contentCursor;

  SyncResponse._();

  factory SyncResponse([void updates(SyncResponseBuilder b)]) = _$SyncResponse;

  @BuiltValueHook(initializeBuilder: true)
  static void _defaults(SyncResponseBuilder b) => b;

  @BuiltValueSerializer(custom: true)
  static Serializer<SyncResponse> get serializer => _$SyncResponseSerializer();
}

class _$SyncResponseSerializer implements PrimitiveSerializer<SyncResponse> {
  @override
  final Iterable<Type> types = const [SyncResponse, _$SyncResponse];

  @override
  final String wireName = r'SyncResponse';

  Iterable<Object?> _serializeProperties(
    Serializers serializers,
    SyncResponse object, {
    FullType specifiedType = FullType.unspecified,
  }) sync* {
    yield r'progress';
    yield serializers.serialize(
      object.progress,
      specifiedType: const FullType(ProgressSnapshot),
    );
    yield r'acknowledgedClientEventIds';
    yield serializers.serialize(
      object.acknowledgedClientEventIds,
      specifiedType: const FullType(BuiltList, [FullType(String)]),
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
    SyncResponse object, {
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
    required SyncResponseBuilder result,
    required List<Object?> unhandled,
  }) {
    for (var i = 0; i < serializedList.length; i += 2) {
      final key = serializedList[i] as String;
      final value = serializedList[i + 1];
      switch (key) {
        case r'progress':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType(ProgressSnapshot),
          ) as ProgressSnapshot;
          result.progress.replace(valueDes);
          break;
        case r'acknowledgedClientEventIds':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType(BuiltList, [FullType(String)]),
          ) as BuiltList<String>;
          result.acknowledgedClientEventIds.replace(valueDes);
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
  SyncResponse deserialize(
    Serializers serializers,
    Object serialized, {
    FullType specifiedType = FullType.unspecified,
  }) {
    final result = SyncResponseBuilder();
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
