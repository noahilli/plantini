//
// AUTO-GENERATED FILE, DO NOT MODIFY!
//

// ignore_for_file: unused_element
import 'package:built_collection/built_collection.dart';
import 'package:built_value/built_value.dart';
import 'package:built_value/serializer.dart';

part 'editor_dashboard.g.dart';

/// EditorDashboard
///
/// Properties:
/// * [users]
/// * [ecosystems]
/// * [levels]
/// * [plants]
/// * [quizzes]
/// * [learningElements]
/// * [cards]
/// * [pendingReview]
/// * [approvedPendingRelease]
/// * [plantNetToday]
/// * [storageBytes]
/// * [storageScope]
@BuiltValue()
abstract class EditorDashboard
    implements Built<EditorDashboard, EditorDashboardBuilder> {
  @BuiltValueField(wireName: r'users')
  int get users;

  @BuiltValueField(wireName: r'ecosystems')
  int get ecosystems;

  @BuiltValueField(wireName: r'levels')
  int get levels;

  @BuiltValueField(wireName: r'plants')
  int get plants;

  @BuiltValueField(wireName: r'quizzes')
  int get quizzes;

  @BuiltValueField(wireName: r'learningElements')
  int get learningElements;

  @BuiltValueField(wireName: r'cards')
  int get cards;

  @BuiltValueField(wireName: r'pendingReview')
  int get pendingReview;

  @BuiltValueField(wireName: r'approvedPendingRelease')
  int get approvedPendingRelease;

  @BuiltValueField(wireName: r'plantNetToday')
  int? get plantNetToday;

  @BuiltValueField(wireName: r'storageBytes')
  int get storageBytes;

  @BuiltValueField(wireName: r'storageScope')
  EditorDashboardStorageScopeEnum get storageScope;
  // enum storageScopeEnum {  uploaded-private-media,  };

  EditorDashboard._();

  factory EditorDashboard([void updates(EditorDashboardBuilder b)]) =
      _$EditorDashboard;

  @BuiltValueHook(initializeBuilder: true)
  static void _defaults(EditorDashboardBuilder b) => b;

  @BuiltValueSerializer(custom: true)
  static Serializer<EditorDashboard> get serializer =>
      _$EditorDashboardSerializer();
}

class _$EditorDashboardSerializer
    implements PrimitiveSerializer<EditorDashboard> {
  @override
  final Iterable<Type> types = const [EditorDashboard, _$EditorDashboard];

  @override
  final String wireName = r'EditorDashboard';

  Iterable<Object?> _serializeProperties(
    Serializers serializers,
    EditorDashboard object, {
    FullType specifiedType = FullType.unspecified,
  }) sync* {
    yield r'users';
    yield serializers.serialize(
      object.users,
      specifiedType: const FullType(int),
    );
    yield r'ecosystems';
    yield serializers.serialize(
      object.ecosystems,
      specifiedType: const FullType(int),
    );
    yield r'levels';
    yield serializers.serialize(
      object.levels,
      specifiedType: const FullType(int),
    );
    yield r'plants';
    yield serializers.serialize(
      object.plants,
      specifiedType: const FullType(int),
    );
    yield r'quizzes';
    yield serializers.serialize(
      object.quizzes,
      specifiedType: const FullType(int),
    );
    yield r'learningElements';
    yield serializers.serialize(
      object.learningElements,
      specifiedType: const FullType(int),
    );
    yield r'cards';
    yield serializers.serialize(
      object.cards,
      specifiedType: const FullType(int),
    );
    yield r'pendingReview';
    yield serializers.serialize(
      object.pendingReview,
      specifiedType: const FullType(int),
    );
    yield r'approvedPendingRelease';
    yield serializers.serialize(
      object.approvedPendingRelease,
      specifiedType: const FullType(int),
    );
    if (object.plantNetToday != null) {
      yield r'plantNetToday';
      yield serializers.serialize(
        object.plantNetToday,
        specifiedType: const FullType.nullable(int),
      );
    }
    yield r'storageBytes';
    yield serializers.serialize(
      object.storageBytes,
      specifiedType: const FullType(int),
    );
    yield r'storageScope';
    yield serializers.serialize(
      object.storageScope,
      specifiedType: const FullType(EditorDashboardStorageScopeEnum),
    );
  }

  @override
  Object serialize(
    Serializers serializers,
    EditorDashboard object, {
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
    required EditorDashboardBuilder result,
    required List<Object?> unhandled,
  }) {
    for (var i = 0; i < serializedList.length; i += 2) {
      final key = serializedList[i] as String;
      final value = serializedList[i + 1];
      switch (key) {
        case r'users':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType(int),
          ) as int;
          result.users = valueDes;
          break;
        case r'ecosystems':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType(int),
          ) as int;
          result.ecosystems = valueDes;
          break;
        case r'levels':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType(int),
          ) as int;
          result.levels = valueDes;
          break;
        case r'plants':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType(int),
          ) as int;
          result.plants = valueDes;
          break;
        case r'quizzes':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType(int),
          ) as int;
          result.quizzes = valueDes;
          break;
        case r'learningElements':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType(int),
          ) as int;
          result.learningElements = valueDes;
          break;
        case r'cards':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType(int),
          ) as int;
          result.cards = valueDes;
          break;
        case r'pendingReview':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType(int),
          ) as int;
          result.pendingReview = valueDes;
          break;
        case r'approvedPendingRelease':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType(int),
          ) as int;
          result.approvedPendingRelease = valueDes;
          break;
        case r'plantNetToday':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType.nullable(int),
          ) as int?;
          if (valueDes == null) continue;
          result.plantNetToday = valueDes;
          break;
        case r'storageBytes':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType(int),
          ) as int;
          result.storageBytes = valueDes;
          break;
        case r'storageScope':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType(EditorDashboardStorageScopeEnum),
          ) as EditorDashboardStorageScopeEnum;
          result.storageScope = valueDes;
          break;
        default:
          unhandled.add(key);
          unhandled.add(value);
          break;
      }
    }
  }

  @override
  EditorDashboard deserialize(
    Serializers serializers,
    Object serialized, {
    FullType specifiedType = FullType.unspecified,
  }) {
    final result = EditorDashboardBuilder();
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

class EditorDashboardStorageScopeEnum extends EnumClass {
  @BuiltValueEnumConst(wireName: r'uploaded-private-media')
  static const EditorDashboardStorageScopeEnum uploadedPrivateMedia =
      _$editorDashboardStorageScopeEnum_uploadedPrivateMedia;

  static Serializer<EditorDashboardStorageScopeEnum> get serializer =>
      _$editorDashboardStorageScopeEnumSerializer;

  const EditorDashboardStorageScopeEnum._(String name) : super(name);

  static BuiltSet<EditorDashboardStorageScopeEnum> get values =>
      _$editorDashboardStorageScopeEnumValues;
  static EditorDashboardStorageScopeEnum valueOf(String name) =>
      _$editorDashboardStorageScopeEnumValueOf(name);
}
