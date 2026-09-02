// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'sync_response.dart';

// **************************************************************************
// BuiltValueGenerator
// **************************************************************************

class _$SyncResponse extends SyncResponse {
  @override
  final ProgressSnapshot progress;
  @override
  final BuiltList<String> acknowledgedClientEventIds;
  @override
  final String? contentCursor;

  factory _$SyncResponse([void Function(SyncResponseBuilder)? updates]) =>
      (SyncResponseBuilder()..update(updates))._build();

  _$SyncResponse._(
      {required this.progress,
      required this.acknowledgedClientEventIds,
      this.contentCursor})
      : super._();
  @override
  SyncResponse rebuild(void Function(SyncResponseBuilder) updates) =>
      (toBuilder()..update(updates)).build();

  @override
  SyncResponseBuilder toBuilder() => SyncResponseBuilder()..replace(this);

  @override
  bool operator ==(Object other) {
    if (identical(other, this)) return true;
    return other is SyncResponse &&
        progress == other.progress &&
        acknowledgedClientEventIds == other.acknowledgedClientEventIds &&
        contentCursor == other.contentCursor;
  }

  @override
  int get hashCode {
    var _$hash = 0;
    _$hash = $jc(_$hash, progress.hashCode);
    _$hash = $jc(_$hash, acknowledgedClientEventIds.hashCode);
    _$hash = $jc(_$hash, contentCursor.hashCode);
    _$hash = $jf(_$hash);
    return _$hash;
  }

  @override
  String toString() {
    return (newBuiltValueToStringHelper(r'SyncResponse')
          ..add('progress', progress)
          ..add('acknowledgedClientEventIds', acknowledgedClientEventIds)
          ..add('contentCursor', contentCursor))
        .toString();
  }
}

class SyncResponseBuilder
    implements Builder<SyncResponse, SyncResponseBuilder> {
  _$SyncResponse? _$v;

  ProgressSnapshotBuilder? _progress;
  ProgressSnapshotBuilder get progress =>
      _$this._progress ??= ProgressSnapshotBuilder();
  set progress(ProgressSnapshotBuilder? progress) =>
      _$this._progress = progress;

  ListBuilder<String>? _acknowledgedClientEventIds;
  ListBuilder<String> get acknowledgedClientEventIds =>
      _$this._acknowledgedClientEventIds ??= ListBuilder<String>();
  set acknowledgedClientEventIds(
          ListBuilder<String>? acknowledgedClientEventIds) =>
      _$this._acknowledgedClientEventIds = acknowledgedClientEventIds;

  String? _contentCursor;
  String? get contentCursor => _$this._contentCursor;
  set contentCursor(String? contentCursor) =>
      _$this._contentCursor = contentCursor;

  SyncResponseBuilder() {
    SyncResponse._defaults(this);
  }

  SyncResponseBuilder get _$this {
    final $v = _$v;
    if ($v != null) {
      _progress = $v.progress.toBuilder();
      _acknowledgedClientEventIds = $v.acknowledgedClientEventIds.toBuilder();
      _contentCursor = $v.contentCursor;
      _$v = null;
    }
    return this;
  }

  @override
  void replace(SyncResponse other) {
    _$v = other as _$SyncResponse;
  }

  @override
  void update(void Function(SyncResponseBuilder)? updates) {
    if (updates != null) updates(this);
  }

  @override
  SyncResponse build() => _build();

  _$SyncResponse _build() {
    _$SyncResponse _$result;
    try {
      _$result = _$v ??
          _$SyncResponse._(
            progress: progress.build(),
            acknowledgedClientEventIds: acknowledgedClientEventIds.build(),
            contentCursor: contentCursor,
          );
    } catch (_) {
      late String _$failedField;
      try {
        _$failedField = 'progress';
        progress.build();
        _$failedField = 'acknowledgedClientEventIds';
        acknowledgedClientEventIds.build();
      } catch (e) {
        throw BuiltValueNestedFieldError(
            r'SyncResponse', _$failedField, e.toString());
      }
      rethrow;
    }
    replace(_$result);
    return _$result;
  }
}

// ignore_for_file: deprecated_member_use_from_same_package,type=lint
