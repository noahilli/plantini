// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'plant_profile_cards_inner.dart';

// **************************************************************************
// BuiltValueGenerator
// **************************************************************************

class _$PlantProfileCardsInner extends PlantProfileCardsInner {
  @override
  final String heading;
  @override
  final String text;

  factory _$PlantProfileCardsInner(
          [void Function(PlantProfileCardsInnerBuilder)? updates]) =>
      (PlantProfileCardsInnerBuilder()..update(updates))._build();

  _$PlantProfileCardsInner._({required this.heading, required this.text})
      : super._();
  @override
  PlantProfileCardsInner rebuild(
          void Function(PlantProfileCardsInnerBuilder) updates) =>
      (toBuilder()..update(updates)).build();

  @override
  PlantProfileCardsInnerBuilder toBuilder() =>
      PlantProfileCardsInnerBuilder()..replace(this);

  @override
  bool operator ==(Object other) {
    if (identical(other, this)) return true;
    return other is PlantProfileCardsInner &&
        heading == other.heading &&
        text == other.text;
  }

  @override
  int get hashCode {
    var _$hash = 0;
    _$hash = $jc(_$hash, heading.hashCode);
    _$hash = $jc(_$hash, text.hashCode);
    _$hash = $jf(_$hash);
    return _$hash;
  }

  @override
  String toString() {
    return (newBuiltValueToStringHelper(r'PlantProfileCardsInner')
          ..add('heading', heading)
          ..add('text', text))
        .toString();
  }
}

class PlantProfileCardsInnerBuilder
    implements Builder<PlantProfileCardsInner, PlantProfileCardsInnerBuilder> {
  _$PlantProfileCardsInner? _$v;

  String? _heading;
  String? get heading => _$this._heading;
  set heading(String? heading) => _$this._heading = heading;

  String? _text;
  String? get text => _$this._text;
  set text(String? text) => _$this._text = text;

  PlantProfileCardsInnerBuilder() {
    PlantProfileCardsInner._defaults(this);
  }

  PlantProfileCardsInnerBuilder get _$this {
    final $v = _$v;
    if ($v != null) {
      _heading = $v.heading;
      _text = $v.text;
      _$v = null;
    }
    return this;
  }

  @override
  void replace(PlantProfileCardsInner other) {
    _$v = other as _$PlantProfileCardsInner;
  }

  @override
  void update(void Function(PlantProfileCardsInnerBuilder)? updates) {
    if (updates != null) updates(this);
  }

  @override
  PlantProfileCardsInner build() => _build();

  _$PlantProfileCardsInner _build() {
    final _$result = _$v ??
        _$PlantProfileCardsInner._(
          heading: BuiltValueNullFieldError.checkNotNull(
              heading, r'PlantProfileCardsInner', 'heading'),
          text: BuiltValueNullFieldError.checkNotNull(
              text, r'PlantProfileCardsInner', 'text'),
        );
    replace(_$result);
    return _$result;
  }
}

// ignore_for_file: deprecated_member_use_from_same_package,type=lint
