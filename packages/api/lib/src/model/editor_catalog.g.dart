// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'editor_catalog.dart';

// **************************************************************************
// BuiltValueGenerator
// **************************************************************************

class _$EditorCatalog extends EditorCatalog {
  @override
  final BuiltList<EditorItemSummary> ecosystems;
  @override
  final BuiltList<EditorItemSummary> levels;
  @override
  final BuiltList<EditorItemSummary> plants;
  @override
  final BuiltList<EditorItemSummary> quizzes;

  factory _$EditorCatalog([void Function(EditorCatalogBuilder)? updates]) =>
      (EditorCatalogBuilder()..update(updates))._build();

  _$EditorCatalog._(
      {required this.ecosystems,
      required this.levels,
      required this.plants,
      required this.quizzes})
      : super._();
  @override
  EditorCatalog rebuild(void Function(EditorCatalogBuilder) updates) =>
      (toBuilder()..update(updates)).build();

  @override
  EditorCatalogBuilder toBuilder() => EditorCatalogBuilder()..replace(this);

  @override
  bool operator ==(Object other) {
    if (identical(other, this)) return true;
    return other is EditorCatalog &&
        ecosystems == other.ecosystems &&
        levels == other.levels &&
        plants == other.plants &&
        quizzes == other.quizzes;
  }

  @override
  int get hashCode {
    var _$hash = 0;
    _$hash = $jc(_$hash, ecosystems.hashCode);
    _$hash = $jc(_$hash, levels.hashCode);
    _$hash = $jc(_$hash, plants.hashCode);
    _$hash = $jc(_$hash, quizzes.hashCode);
    _$hash = $jf(_$hash);
    return _$hash;
  }

  @override
  String toString() {
    return (newBuiltValueToStringHelper(r'EditorCatalog')
          ..add('ecosystems', ecosystems)
          ..add('levels', levels)
          ..add('plants', plants)
          ..add('quizzes', quizzes))
        .toString();
  }
}

class EditorCatalogBuilder
    implements Builder<EditorCatalog, EditorCatalogBuilder> {
  _$EditorCatalog? _$v;

  ListBuilder<EditorItemSummary>? _ecosystems;
  ListBuilder<EditorItemSummary> get ecosystems =>
      _$this._ecosystems ??= ListBuilder<EditorItemSummary>();
  set ecosystems(ListBuilder<EditorItemSummary>? ecosystems) =>
      _$this._ecosystems = ecosystems;

  ListBuilder<EditorItemSummary>? _levels;
  ListBuilder<EditorItemSummary> get levels =>
      _$this._levels ??= ListBuilder<EditorItemSummary>();
  set levels(ListBuilder<EditorItemSummary>? levels) => _$this._levels = levels;

  ListBuilder<EditorItemSummary>? _plants;
  ListBuilder<EditorItemSummary> get plants =>
      _$this._plants ??= ListBuilder<EditorItemSummary>();
  set plants(ListBuilder<EditorItemSummary>? plants) => _$this._plants = plants;

  ListBuilder<EditorItemSummary>? _quizzes;
  ListBuilder<EditorItemSummary> get quizzes =>
      _$this._quizzes ??= ListBuilder<EditorItemSummary>();
  set quizzes(ListBuilder<EditorItemSummary>? quizzes) =>
      _$this._quizzes = quizzes;

  EditorCatalogBuilder() {
    EditorCatalog._defaults(this);
  }

  EditorCatalogBuilder get _$this {
    final $v = _$v;
    if ($v != null) {
      _ecosystems = $v.ecosystems.toBuilder();
      _levels = $v.levels.toBuilder();
      _plants = $v.plants.toBuilder();
      _quizzes = $v.quizzes.toBuilder();
      _$v = null;
    }
    return this;
  }

  @override
  void replace(EditorCatalog other) {
    _$v = other as _$EditorCatalog;
  }

  @override
  void update(void Function(EditorCatalogBuilder)? updates) {
    if (updates != null) updates(this);
  }

  @override
  EditorCatalog build() => _build();

  _$EditorCatalog _build() {
    _$EditorCatalog _$result;
    try {
      _$result = _$v ??
          _$EditorCatalog._(
            ecosystems: ecosystems.build(),
            levels: levels.build(),
            plants: plants.build(),
            quizzes: quizzes.build(),
          );
    } catch (_) {
      late String _$failedField;
      try {
        _$failedField = 'ecosystems';
        ecosystems.build();
        _$failedField = 'levels';
        levels.build();
        _$failedField = 'plants';
        plants.build();
        _$failedField = 'quizzes';
        quizzes.build();
      } catch (e) {
        throw BuiltValueNestedFieldError(
            r'EditorCatalog', _$failedField, e.toString());
      }
      rethrow;
    }
    replace(_$result);
    return _$result;
  }
}

// ignore_for_file: deprecated_member_use_from_same_package,type=lint
