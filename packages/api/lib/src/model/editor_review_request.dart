//
// AUTO-GENERATED FILE, DO NOT MODIFY!
//

// ignore_for_file: unused_element
import 'package:built_value/built_value.dart';
import 'package:built_value/serializer.dart';

part 'editor_review_request.g.dart';

/// EditorReviewRequest
///
/// Properties:
/// * [note]
@BuiltValue()
abstract class EditorReviewRequest
    implements Built<EditorReviewRequest, EditorReviewRequestBuilder> {
  @BuiltValueField(wireName: r'note')
  String? get note;

  EditorReviewRequest._();

  factory EditorReviewRequest([void updates(EditorReviewRequestBuilder b)]) =
      _$EditorReviewRequest;

  @BuiltValueHook(initializeBuilder: true)
  static void _defaults(EditorReviewRequestBuilder b) => b;

  @BuiltValueSerializer(custom: true)
  static Serializer<EditorReviewRequest> get serializer =>
      _$EditorReviewRequestSerializer();
}

class _$EditorReviewRequestSerializer
    implements PrimitiveSerializer<EditorReviewRequest> {
  @override
  final Iterable<Type> types = const [
    EditorReviewRequest,
    _$EditorReviewRequest
  ];

  @override
  final String wireName = r'EditorReviewRequest';

  Iterable<Object?> _serializeProperties(
    Serializers serializers,
    EditorReviewRequest object, {
    FullType specifiedType = FullType.unspecified,
  }) sync* {
    if (object.note != null) {
      yield r'note';
      yield serializers.serialize(
        object.note,
        specifiedType: const FullType(String),
      );
    }
  }

  @override
  Object serialize(
    Serializers serializers,
    EditorReviewRequest object, {
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
    required EditorReviewRequestBuilder result,
    required List<Object?> unhandled,
  }) {
    for (var i = 0; i < serializedList.length; i += 2) {
      final key = serializedList[i] as String;
      final value = serializedList[i + 1];
      switch (key) {
        case r'note':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType.nullable(String),
          ) as String?;
          if (valueDes == null) continue;
          result.note = valueDes;
          break;
        default:
          unhandled.add(key);
          unhandled.add(value);
          break;
      }
    }
  }

  @override
  EditorReviewRequest deserialize(
    Serializers serializers,
    Object serialized, {
    FullType specifiedType = FullType.unspecified,
  }) {
    final result = EditorReviewRequestBuilder();
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
