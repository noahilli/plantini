// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'level.dart';

// **************************************************************************
// BuiltValueGenerator
// **************************************************************************

class _$Level extends Level {
  @override
  final String id;
  @override
  final String title;
  @override
  final bool? isUnlocked;
  @override
  final double? progress;

  factory _$Level([void Function(LevelBuilder)? updates]) =>
      (LevelBuilder()..update(updates))._build();

  _$Level._(
      {required this.id, required this.title, this.isUnlocked, this.progress})
      : super._();
  @override
  Level rebuild(void Function(LevelBuilder) updates) =>
      (toBuilder()..update(updates)).build();

  @override
  LevelBuilder toBuilder() => LevelBuilder()..replace(this);

  @override
  bool operator ==(Object other) {
    if (identical(other, this)) return true;
    return other is Level &&
        id == other.id &&
        title == other.title &&
        isUnlocked == other.isUnlocked &&
        progress == other.progress;
  }

  @override
  int get hashCode {
    var _$hash = 0;
    _$hash = $jc(_$hash, id.hashCode);
    _$hash = $jc(_$hash, title.hashCode);
    _$hash = $jc(_$hash, isUnlocked.hashCode);
    _$hash = $jc(_$hash, progress.hashCode);
    _$hash = $jf(_$hash);
    return _$hash;
  }

  @override
  String toString() {
    return (newBuiltValueToStringHelper(r'Level')
          ..add('id', id)
          ..add('title', title)
          ..add('isUnlocked', isUnlocked)
          ..add('progress', progress))
        .toString();
  }
}

class LevelBuilder implements Builder<Level, LevelBuilder> {
  _$Level? _$v;

  String? _id;
  String? get id => _$this._id;
  set id(String? id) => _$this._id = id;

  String? _title;
  String? get title => _$this._title;
  set title(String? title) => _$this._title = title;

  bool? _isUnlocked;
  bool? get isUnlocked => _$this._isUnlocked;
  set isUnlocked(bool? isUnlocked) => _$this._isUnlocked = isUnlocked;

  double? _progress;
  double? get progress => _$this._progress;
  set progress(double? progress) => _$this._progress = progress;

  LevelBuilder() {
    Level._defaults(this);
  }

  LevelBuilder get _$this {
    final $v = _$v;
    if ($v != null) {
      _id = $v.id;
      _title = $v.title;
      _isUnlocked = $v.isUnlocked;
      _progress = $v.progress;
      _$v = null;
    }
    return this;
  }

  @override
  void replace(Level other) {
    _$v = other as _$Level;
  }

  @override
  void update(void Function(LevelBuilder)? updates) {
    if (updates != null) updates(this);
  }

  @override
  Level build() => _build();

  _$Level _build() {
    final _$result = _$v ??
        _$Level._(
          id: BuiltValueNullFieldError.checkNotNull(id, r'Level', 'id'),
          title:
              BuiltValueNullFieldError.checkNotNull(title, r'Level', 'title'),
          isUnlocked: isUnlocked,
          progress: progress,
        );
    replace(_$result);
    return _$result;
  }
}

// ignore_for_file: deprecated_member_use_from_same_package,type=lint
