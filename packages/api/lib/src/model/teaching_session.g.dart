// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'teaching_session.dart';

// **************************************************************************
// BuiltValueGenerator
// **************************************************************************

class _$TeachingSession extends TeachingSession {
  @override
  final TeachingActor actor;
  @override
  final TeachingCapabilities capabilities;

  factory _$TeachingSession([void Function(TeachingSessionBuilder)? updates]) =>
      (TeachingSessionBuilder()..update(updates))._build();

  _$TeachingSession._({required this.actor, required this.capabilities})
      : super._();
  @override
  TeachingSession rebuild(void Function(TeachingSessionBuilder) updates) =>
      (toBuilder()..update(updates)).build();

  @override
  TeachingSessionBuilder toBuilder() => TeachingSessionBuilder()..replace(this);

  @override
  bool operator ==(Object other) {
    if (identical(other, this)) return true;
    return other is TeachingSession &&
        actor == other.actor &&
        capabilities == other.capabilities;
  }

  @override
  int get hashCode {
    var _$hash = 0;
    _$hash = $jc(_$hash, actor.hashCode);
    _$hash = $jc(_$hash, capabilities.hashCode);
    _$hash = $jf(_$hash);
    return _$hash;
  }

  @override
  String toString() {
    return (newBuiltValueToStringHelper(r'TeachingSession')
          ..add('actor', actor)
          ..add('capabilities', capabilities))
        .toString();
  }
}

class TeachingSessionBuilder
    implements Builder<TeachingSession, TeachingSessionBuilder> {
  _$TeachingSession? _$v;

  TeachingActorBuilder? _actor;
  TeachingActorBuilder get actor => _$this._actor ??= TeachingActorBuilder();
  set actor(TeachingActorBuilder? actor) => _$this._actor = actor;

  TeachingCapabilitiesBuilder? _capabilities;
  TeachingCapabilitiesBuilder get capabilities =>
      _$this._capabilities ??= TeachingCapabilitiesBuilder();
  set capabilities(TeachingCapabilitiesBuilder? capabilities) =>
      _$this._capabilities = capabilities;

  TeachingSessionBuilder() {
    TeachingSession._defaults(this);
  }

  TeachingSessionBuilder get _$this {
    final $v = _$v;
    if ($v != null) {
      _actor = $v.actor.toBuilder();
      _capabilities = $v.capabilities.toBuilder();
      _$v = null;
    }
    return this;
  }

  @override
  void replace(TeachingSession other) {
    _$v = other as _$TeachingSession;
  }

  @override
  void update(void Function(TeachingSessionBuilder)? updates) {
    if (updates != null) updates(this);
  }

  @override
  TeachingSession build() => _build();

  _$TeachingSession _build() {
    _$TeachingSession _$result;
    try {
      _$result = _$v ??
          _$TeachingSession._(
            actor: actor.build(),
            capabilities: capabilities.build(),
          );
    } catch (_) {
      late String _$failedField;
      try {
        _$failedField = 'actor';
        actor.build();
        _$failedField = 'capabilities';
        capabilities.build();
      } catch (e) {
        throw BuiltValueNestedFieldError(
            r'TeachingSession', _$failedField, e.toString());
      }
      rethrow;
    }
    replace(_$result);
    return _$result;
  }
}

// ignore_for_file: deprecated_member_use_from_same_package,type=lint
