// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'character_part.dart';

// **************************************************************************
// BuiltValueGenerator
// **************************************************************************

class _$CharacterPart extends CharacterPart {
  @override
  final String style;
  @override
  final String? color;

  factory _$CharacterPart([void Function(CharacterPartBuilder)? updates]) =>
      (CharacterPartBuilder()..update(updates))._build();

  _$CharacterPart._({required this.style, this.color}) : super._();
  @override
  CharacterPart rebuild(void Function(CharacterPartBuilder) updates) =>
      (toBuilder()..update(updates)).build();

  @override
  CharacterPartBuilder toBuilder() => CharacterPartBuilder()..replace(this);

  @override
  bool operator ==(Object other) {
    if (identical(other, this)) return true;
    return other is CharacterPart &&
        style == other.style &&
        color == other.color;
  }

  @override
  int get hashCode {
    var _$hash = 0;
    _$hash = $jc(_$hash, style.hashCode);
    _$hash = $jc(_$hash, color.hashCode);
    _$hash = $jf(_$hash);
    return _$hash;
  }

  @override
  String toString() {
    return (newBuiltValueToStringHelper(r'CharacterPart')
          ..add('style', style)
          ..add('color', color))
        .toString();
  }
}

class CharacterPartBuilder
    implements Builder<CharacterPart, CharacterPartBuilder> {
  _$CharacterPart? _$v;

  String? _style;
  String? get style => _$this._style;
  set style(String? style) => _$this._style = style;

  String? _color;
  String? get color => _$this._color;
  set color(String? color) => _$this._color = color;

  CharacterPartBuilder() {
    CharacterPart._defaults(this);
  }

  CharacterPartBuilder get _$this {
    final $v = _$v;
    if ($v != null) {
      _style = $v.style;
      _color = $v.color;
      _$v = null;
    }
    return this;
  }

  @override
  void replace(CharacterPart other) {
    _$v = other as _$CharacterPart;
  }

  @override
  void update(void Function(CharacterPartBuilder)? updates) {
    if (updates != null) updates(this);
  }

  @override
  CharacterPart build() => _build();

  _$CharacterPart _build() {
    final _$result = _$v ??
        _$CharacterPart._(
          style: BuiltValueNullFieldError.checkNotNull(
              style, r'CharacterPart', 'style'),
          color: color,
        );
    replace(_$result);
    return _$result;
  }
}

// ignore_for_file: deprecated_member_use_from_same_package,type=lint
