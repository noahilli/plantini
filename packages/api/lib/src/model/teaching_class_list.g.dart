// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'teaching_class_list.dart';

// **************************************************************************
// BuiltValueGenerator
// **************************************************************************

class _$TeachingClassList extends TeachingClassList {
  @override
  final BuiltList<TeachingClass> classes;

  factory _$TeachingClassList(
          [void Function(TeachingClassListBuilder)? updates]) =>
      (TeachingClassListBuilder()..update(updates))._build();

  _$TeachingClassList._({required this.classes}) : super._();
  @override
  TeachingClassList rebuild(void Function(TeachingClassListBuilder) updates) =>
      (toBuilder()..update(updates)).build();

  @override
  TeachingClassListBuilder toBuilder() =>
      TeachingClassListBuilder()..replace(this);

  @override
  bool operator ==(Object other) {
    if (identical(other, this)) return true;
    return other is TeachingClassList && classes == other.classes;
  }

  @override
  int get hashCode {
    var _$hash = 0;
    _$hash = $jc(_$hash, classes.hashCode);
    _$hash = $jf(_$hash);
    return _$hash;
  }

  @override
  String toString() {
    return (newBuiltValueToStringHelper(r'TeachingClassList')
          ..add('classes', classes))
        .toString();
  }
}

class TeachingClassListBuilder
    implements Builder<TeachingClassList, TeachingClassListBuilder> {
  _$TeachingClassList? _$v;

  ListBuilder<TeachingClass>? _classes;
  ListBuilder<TeachingClass> get classes =>
      _$this._classes ??= ListBuilder<TeachingClass>();
  set classes(ListBuilder<TeachingClass>? classes) => _$this._classes = classes;

  TeachingClassListBuilder() {
    TeachingClassList._defaults(this);
  }

  TeachingClassListBuilder get _$this {
    final $v = _$v;
    if ($v != null) {
      _classes = $v.classes.toBuilder();
      _$v = null;
    }
    return this;
  }

  @override
  void replace(TeachingClassList other) {
    _$v = other as _$TeachingClassList;
  }

  @override
  void update(void Function(TeachingClassListBuilder)? updates) {
    if (updates != null) updates(this);
  }

  @override
  TeachingClassList build() => _build();

  _$TeachingClassList _build() {
    _$TeachingClassList _$result;
    try {
      _$result = _$v ??
          _$TeachingClassList._(
            classes: classes.build(),
          );
    } catch (_) {
      late String _$failedField;
      try {
        _$failedField = 'classes';
        classes.build();
      } catch (e) {
        throw BuiltValueNestedFieldError(
            r'TeachingClassList', _$failedField, e.toString());
      }
      rethrow;
    }
    replace(_$result);
    return _$result;
  }
}

// ignore_for_file: deprecated_member_use_from_same_package,type=lint
