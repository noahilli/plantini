// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'teaching_capabilities.dart';

// **************************************************************************
// BuiltValueGenerator
// **************************************************************************

class _$TeachingCapabilities extends TeachingCapabilities {
  @override
  final bool manageStudents;

  factory _$TeachingCapabilities(
          [void Function(TeachingCapabilitiesBuilder)? updates]) =>
      (TeachingCapabilitiesBuilder()..update(updates))._build();

  _$TeachingCapabilities._({required this.manageStudents}) : super._();
  @override
  TeachingCapabilities rebuild(
          void Function(TeachingCapabilitiesBuilder) updates) =>
      (toBuilder()..update(updates)).build();

  @override
  TeachingCapabilitiesBuilder toBuilder() =>
      TeachingCapabilitiesBuilder()..replace(this);

  @override
  bool operator ==(Object other) {
    if (identical(other, this)) return true;
    return other is TeachingCapabilities &&
        manageStudents == other.manageStudents;
  }

  @override
  int get hashCode {
    var _$hash = 0;
    _$hash = $jc(_$hash, manageStudents.hashCode);
    _$hash = $jf(_$hash);
    return _$hash;
  }

  @override
  String toString() {
    return (newBuiltValueToStringHelper(r'TeachingCapabilities')
          ..add('manageStudents', manageStudents))
        .toString();
  }
}

class TeachingCapabilitiesBuilder
    implements Builder<TeachingCapabilities, TeachingCapabilitiesBuilder> {
  _$TeachingCapabilities? _$v;

  bool? _manageStudents;
  bool? get manageStudents => _$this._manageStudents;
  set manageStudents(bool? manageStudents) =>
      _$this._manageStudents = manageStudents;

  TeachingCapabilitiesBuilder() {
    TeachingCapabilities._defaults(this);
  }

  TeachingCapabilitiesBuilder get _$this {
    final $v = _$v;
    if ($v != null) {
      _manageStudents = $v.manageStudents;
      _$v = null;
    }
    return this;
  }

  @override
  void replace(TeachingCapabilities other) {
    _$v = other as _$TeachingCapabilities;
  }

  @override
  void update(void Function(TeachingCapabilitiesBuilder)? updates) {
    if (updates != null) updates(this);
  }

  @override
  TeachingCapabilities build() => _build();

  _$TeachingCapabilities _build() {
    final _$result = _$v ??
        _$TeachingCapabilities._(
          manageStudents: BuiltValueNullFieldError.checkNotNull(
              manageStudents, r'TeachingCapabilities', 'manageStudents'),
        );
    replace(_$result);
    return _$result;
  }
}

// ignore_for_file: deprecated_member_use_from_same_package,type=lint
