// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'editor_dashboard.dart';

// **************************************************************************
// BuiltValueGenerator
// **************************************************************************

const EditorDashboardStorageScopeEnum
    _$editorDashboardStorageScopeEnum_uploadedPrivateMedia =
    const EditorDashboardStorageScopeEnum._('uploadedPrivateMedia');

EditorDashboardStorageScopeEnum _$editorDashboardStorageScopeEnumValueOf(
    String name) {
  switch (name) {
    case 'uploadedPrivateMedia':
      return _$editorDashboardStorageScopeEnum_uploadedPrivateMedia;
    default:
      throw ArgumentError(name);
  }
}

final BuiltSet<EditorDashboardStorageScopeEnum>
    _$editorDashboardStorageScopeEnumValues = BuiltSet<
        EditorDashboardStorageScopeEnum>(const <EditorDashboardStorageScopeEnum>[
  _$editorDashboardStorageScopeEnum_uploadedPrivateMedia,
]);

Serializer<EditorDashboardStorageScopeEnum>
    _$editorDashboardStorageScopeEnumSerializer =
    _$EditorDashboardStorageScopeEnumSerializer();

class _$EditorDashboardStorageScopeEnumSerializer
    implements PrimitiveSerializer<EditorDashboardStorageScopeEnum> {
  static const Map<String, Object> _toWire = const <String, Object>{
    'uploadedPrivateMedia': 'uploaded-private-media',
  };
  static const Map<Object, String> _fromWire = const <Object, String>{
    'uploaded-private-media': 'uploadedPrivateMedia',
  };

  @override
  final Iterable<Type> types = const <Type>[EditorDashboardStorageScopeEnum];
  @override
  final String wireName = 'EditorDashboardStorageScopeEnum';

  @override
  Object serialize(
          Serializers serializers, EditorDashboardStorageScopeEnum object,
          {FullType specifiedType = FullType.unspecified}) =>
      _toWire[object.name] ?? object.name;

  @override
  EditorDashboardStorageScopeEnum deserialize(
          Serializers serializers, Object serialized,
          {FullType specifiedType = FullType.unspecified}) =>
      EditorDashboardStorageScopeEnum.valueOf(
          _fromWire[serialized] ?? (serialized is String ? serialized : ''));
}

class _$EditorDashboard extends EditorDashboard {
  @override
  final int users;
  @override
  final int ecosystems;
  @override
  final int levels;
  @override
  final int plants;
  @override
  final int quizzes;
  @override
  final int learningElements;
  @override
  final int cards;
  @override
  final int pendingReview;
  @override
  final int approvedPendingRelease;
  @override
  final int? plantNetToday;
  @override
  final int storageBytes;
  @override
  final EditorDashboardStorageScopeEnum storageScope;

  factory _$EditorDashboard([void Function(EditorDashboardBuilder)? updates]) =>
      (EditorDashboardBuilder()..update(updates))._build();

  _$EditorDashboard._(
      {required this.users,
      required this.ecosystems,
      required this.levels,
      required this.plants,
      required this.quizzes,
      required this.learningElements,
      required this.cards,
      required this.pendingReview,
      required this.approvedPendingRelease,
      this.plantNetToday,
      required this.storageBytes,
      required this.storageScope})
      : super._();
  @override
  EditorDashboard rebuild(void Function(EditorDashboardBuilder) updates) =>
      (toBuilder()..update(updates)).build();

  @override
  EditorDashboardBuilder toBuilder() => EditorDashboardBuilder()..replace(this);

  @override
  bool operator ==(Object other) {
    if (identical(other, this)) return true;
    return other is EditorDashboard &&
        users == other.users &&
        ecosystems == other.ecosystems &&
        levels == other.levels &&
        plants == other.plants &&
        quizzes == other.quizzes &&
        learningElements == other.learningElements &&
        cards == other.cards &&
        pendingReview == other.pendingReview &&
        approvedPendingRelease == other.approvedPendingRelease &&
        plantNetToday == other.plantNetToday &&
        storageBytes == other.storageBytes &&
        storageScope == other.storageScope;
  }

  @override
  int get hashCode {
    var _$hash = 0;
    _$hash = $jc(_$hash, users.hashCode);
    _$hash = $jc(_$hash, ecosystems.hashCode);
    _$hash = $jc(_$hash, levels.hashCode);
    _$hash = $jc(_$hash, plants.hashCode);
    _$hash = $jc(_$hash, quizzes.hashCode);
    _$hash = $jc(_$hash, learningElements.hashCode);
    _$hash = $jc(_$hash, cards.hashCode);
    _$hash = $jc(_$hash, pendingReview.hashCode);
    _$hash = $jc(_$hash, approvedPendingRelease.hashCode);
    _$hash = $jc(_$hash, plantNetToday.hashCode);
    _$hash = $jc(_$hash, storageBytes.hashCode);
    _$hash = $jc(_$hash, storageScope.hashCode);
    _$hash = $jf(_$hash);
    return _$hash;
  }

  @override
  String toString() {
    return (newBuiltValueToStringHelper(r'EditorDashboard')
          ..add('users', users)
          ..add('ecosystems', ecosystems)
          ..add('levels', levels)
          ..add('plants', plants)
          ..add('quizzes', quizzes)
          ..add('learningElements', learningElements)
          ..add('cards', cards)
          ..add('pendingReview', pendingReview)
          ..add('approvedPendingRelease', approvedPendingRelease)
          ..add('plantNetToday', plantNetToday)
          ..add('storageBytes', storageBytes)
          ..add('storageScope', storageScope))
        .toString();
  }
}

class EditorDashboardBuilder
    implements Builder<EditorDashboard, EditorDashboardBuilder> {
  _$EditorDashboard? _$v;

  int? _users;
  int? get users => _$this._users;
  set users(int? users) => _$this._users = users;

  int? _ecosystems;
  int? get ecosystems => _$this._ecosystems;
  set ecosystems(int? ecosystems) => _$this._ecosystems = ecosystems;

  int? _levels;
  int? get levels => _$this._levels;
  set levels(int? levels) => _$this._levels = levels;

  int? _plants;
  int? get plants => _$this._plants;
  set plants(int? plants) => _$this._plants = plants;

  int? _quizzes;
  int? get quizzes => _$this._quizzes;
  set quizzes(int? quizzes) => _$this._quizzes = quizzes;

  int? _learningElements;
  int? get learningElements => _$this._learningElements;
  set learningElements(int? learningElements) =>
      _$this._learningElements = learningElements;

  int? _cards;
  int? get cards => _$this._cards;
  set cards(int? cards) => _$this._cards = cards;

  int? _pendingReview;
  int? get pendingReview => _$this._pendingReview;
  set pendingReview(int? pendingReview) =>
      _$this._pendingReview = pendingReview;

  int? _approvedPendingRelease;
  int? get approvedPendingRelease => _$this._approvedPendingRelease;
  set approvedPendingRelease(int? approvedPendingRelease) =>
      _$this._approvedPendingRelease = approvedPendingRelease;

  int? _plantNetToday;
  int? get plantNetToday => _$this._plantNetToday;
  set plantNetToday(int? plantNetToday) =>
      _$this._plantNetToday = plantNetToday;

  int? _storageBytes;
  int? get storageBytes => _$this._storageBytes;
  set storageBytes(int? storageBytes) => _$this._storageBytes = storageBytes;

  EditorDashboardStorageScopeEnum? _storageScope;
  EditorDashboardStorageScopeEnum? get storageScope => _$this._storageScope;
  set storageScope(EditorDashboardStorageScopeEnum? storageScope) =>
      _$this._storageScope = storageScope;

  EditorDashboardBuilder() {
    EditorDashboard._defaults(this);
  }

  EditorDashboardBuilder get _$this {
    final $v = _$v;
    if ($v != null) {
      _users = $v.users;
      _ecosystems = $v.ecosystems;
      _levels = $v.levels;
      _plants = $v.plants;
      _quizzes = $v.quizzes;
      _learningElements = $v.learningElements;
      _cards = $v.cards;
      _pendingReview = $v.pendingReview;
      _approvedPendingRelease = $v.approvedPendingRelease;
      _plantNetToday = $v.plantNetToday;
      _storageBytes = $v.storageBytes;
      _storageScope = $v.storageScope;
      _$v = null;
    }
    return this;
  }

  @override
  void replace(EditorDashboard other) {
    _$v = other as _$EditorDashboard;
  }

  @override
  void update(void Function(EditorDashboardBuilder)? updates) {
    if (updates != null) updates(this);
  }

  @override
  EditorDashboard build() => _build();

  _$EditorDashboard _build() {
    final _$result = _$v ??
        _$EditorDashboard._(
          users: BuiltValueNullFieldError.checkNotNull(
              users, r'EditorDashboard', 'users'),
          ecosystems: BuiltValueNullFieldError.checkNotNull(
              ecosystems, r'EditorDashboard', 'ecosystems'),
          levels: BuiltValueNullFieldError.checkNotNull(
              levels, r'EditorDashboard', 'levels'),
          plants: BuiltValueNullFieldError.checkNotNull(
              plants, r'EditorDashboard', 'plants'),
          quizzes: BuiltValueNullFieldError.checkNotNull(
              quizzes, r'EditorDashboard', 'quizzes'),
          learningElements: BuiltValueNullFieldError.checkNotNull(
              learningElements, r'EditorDashboard', 'learningElements'),
          cards: BuiltValueNullFieldError.checkNotNull(
              cards, r'EditorDashboard', 'cards'),
          pendingReview: BuiltValueNullFieldError.checkNotNull(
              pendingReview, r'EditorDashboard', 'pendingReview'),
          approvedPendingRelease: BuiltValueNullFieldError.checkNotNull(
              approvedPendingRelease,
              r'EditorDashboard',
              'approvedPendingRelease'),
          plantNetToday: plantNetToday,
          storageBytes: BuiltValueNullFieldError.checkNotNull(
              storageBytes, r'EditorDashboard', 'storageBytes'),
          storageScope: BuiltValueNullFieldError.checkNotNull(
              storageScope, r'EditorDashboard', 'storageScope'),
        );
    replace(_$result);
    return _$result;
  }
}

// ignore_for_file: deprecated_member_use_from_same_package,type=lint
