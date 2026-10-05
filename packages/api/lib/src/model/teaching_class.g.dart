// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'teaching_class.dart';

// **************************************************************************
// BuiltValueGenerator
// **************************************************************************

class _$TeachingClass extends TeachingClass {
  @override
  final String id;
  @override
  final String name;
  @override
  final String description;
  @override
  final int studentCount;
  @override
  final DateTime createdAt;

  factory _$TeachingClass([void Function(TeachingClassBuilder)? updates]) =>
      (TeachingClassBuilder()..update(updates))._build();

  _$TeachingClass._(
      {required this.id,
      required this.name,
      required this.description,
      required this.studentCount,
      required this.createdAt})
      : super._();
  @override
  TeachingClass rebuild(void Function(TeachingClassBuilder) updates) =>
      (toBuilder()..update(updates)).build();

  @override
  TeachingClassBuilder toBuilder() => TeachingClassBuilder()..replace(this);

  @override
  bool operator ==(Object other) {
    if (identical(other, this)) return true;
    return other is TeachingClass &&
        id == other.id &&
        name == other.name &&
        description == other.description &&
        studentCount == other.studentCount &&
        createdAt == other.createdAt;
  }

  @override
  int get hashCode {
    var _$hash = 0;
    _$hash = $jc(_$hash, id.hashCode);
    _$hash = $jc(_$hash, name.hashCode);
    _$hash = $jc(_$hash, description.hashCode);
    _$hash = $jc(_$hash, studentCount.hashCode);
    _$hash = $jc(_$hash, createdAt.hashCode);
    _$hash = $jf(_$hash);
    return _$hash;
  }

  @override
  String toString() {
    return (newBuiltValueToStringHelper(r'TeachingClass')
          ..add('id', id)
          ..add('name', name)
          ..add('description', description)
          ..add('studentCount', studentCount)
          ..add('createdAt', createdAt))
        .toString();
  }
}

class TeachingClassBuilder
    implements Builder<TeachingClass, TeachingClassBuilder> {
  _$TeachingClass? _$v;

  String? _id;
  String? get id => _$this._id;
  set id(String? id) => _$this._id = id;

  String? _name;
  String? get name => _$this._name;
  set name(String? name) => _$this._name = name;

  String? _description;
  String? get description => _$this._description;
  set description(String? description) => _$this._description = description;

  int? _studentCount;
  int? get studentCount => _$this._studentCount;
  set studentCount(int? studentCount) => _$this._studentCount = studentCount;

  DateTime? _createdAt;
  DateTime? get createdAt => _$this._createdAt;
  set createdAt(DateTime? createdAt) => _$this._createdAt = createdAt;

  TeachingClassBuilder() {
    TeachingClass._defaults(this);
  }

  TeachingClassBuilder get _$this {
    final $v = _$v;
    if ($v != null) {
      _id = $v.id;
      _name = $v.name;
      _description = $v.description;
      _studentCount = $v.studentCount;
      _createdAt = $v.createdAt;
      _$v = null;
    }
    return this;
  }

  @override
  void replace(TeachingClass other) {
    _$v = other as _$TeachingClass;
  }

  @override
  void update(void Function(TeachingClassBuilder)? updates) {
    if (updates != null) updates(this);
  }

  @override
  TeachingClass build() => _build();

  _$TeachingClass _build() {
    final _$result = _$v ??
        _$TeachingClass._(
          id: BuiltValueNullFieldError.checkNotNull(id, r'TeachingClass', 'id'),
          name: BuiltValueNullFieldError.checkNotNull(
              name, r'TeachingClass', 'name'),
          description: BuiltValueNullFieldError.checkNotNull(
              description, r'TeachingClass', 'description'),
          studentCount: BuiltValueNullFieldError.checkNotNull(
              studentCount, r'TeachingClass', 'studentCount'),
          createdAt: BuiltValueNullFieldError.checkNotNull(
              createdAt, r'TeachingClass', 'createdAt'),
        );
    replace(_$result);
    return _$result;
  }
}

// ignore_for_file: deprecated_member_use_from_same_package,type=lint
