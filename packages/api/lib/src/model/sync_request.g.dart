// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'sync_request.dart';

// **************************************************************************
// BuiltValueGenerator
// **************************************************************************

class _$SyncRequest extends SyncRequest {
  @override
  final BuiltList<LearningEvent> events;
  @override
  final String? contentCursor;

  factory _$SyncRequest([void Function(SyncRequestBuilder)? updates]) =>
      (SyncRequestBuilder()..update(updates))._build();

  _$SyncRequest._({required this.events, this.contentCursor}) : super._();
  @override
  SyncRequest rebuild(void Function(SyncRequestBuilder) updates) =>
      (toBuilder()..update(updates)).build();

  @override
  SyncRequestBuilder toBuilder() => SyncRequestBuilder()..replace(this);

  @override
  bool operator ==(Object other) {
    if (identical(other, this)) return true;
    return other is SyncRequest &&
        events == other.events &&
        contentCursor == other.contentCursor;
  }

  @override
  int get hashCode {
    var _$hash = 0;
    _$hash = $jc(_$hash, events.hashCode);
    _$hash = $jc(_$hash, contentCursor.hashCode);
    _$hash = $jf(_$hash);
    return _$hash;
  }

  @override
  String toString() {
    return (newBuiltValueToStringHelper(r'SyncRequest')
          ..add('events', events)
          ..add('contentCursor', contentCursor))
        .toString();
  }
}

class SyncRequestBuilder implements Builder<SyncRequest, SyncRequestBuilder> {
  _$SyncRequest? _$v;

  ListBuilder<LearningEvent>? _events;
  ListBuilder<LearningEvent> get events =>
      _$this._events ??= ListBuilder<LearningEvent>();
  set events(ListBuilder<LearningEvent>? events) => _$this._events = events;

  String? _contentCursor;
  String? get contentCursor => _$this._contentCursor;
  set contentCursor(String? contentCursor) =>
      _$this._contentCursor = contentCursor;

  SyncRequestBuilder() {
    SyncRequest._defaults(this);
  }

  SyncRequestBuilder get _$this {
    final $v = _$v;
    if ($v != null) {
      _events = $v.events.toBuilder();
      _contentCursor = $v.contentCursor;
      _$v = null;
    }
    return this;
  }

  @override
  void replace(SyncRequest other) {
    _$v = other as _$SyncRequest;
  }

  @override
  void update(void Function(SyncRequestBuilder)? updates) {
    if (updates != null) updates(this);
  }

  @override
  SyncRequest build() => _build();

  _$SyncRequest _build() {
    _$SyncRequest _$result;
    try {
      _$result = _$v ??
          _$SyncRequest._(
            events: events.build(),
            contentCursor: contentCursor,
          );
    } catch (_) {
      late String _$failedField;
      try {
        _$failedField = 'events';
        events.build();
      } catch (e) {
        throw BuiltValueNestedFieldError(
            r'SyncRequest', _$failedField, e.toString());
      }
      rethrow;
    }
    replace(_$result);
    return _$result;
  }
}

// ignore_for_file: deprecated_member_use_from_same_package,type=lint
