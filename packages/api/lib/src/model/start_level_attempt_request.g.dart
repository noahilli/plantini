// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'start_level_attempt_request.dart';

// **************************************************************************
// BuiltValueGenerator
// **************************************************************************

class _$StartLevelAttemptRequest extends StartLevelAttemptRequest {
  @override
  final String levelId;
  @override
  final String clientAttemptId;
  @override
  final String contentVersion;

  factory _$StartLevelAttemptRequest(
          [void Function(StartLevelAttemptRequestBuilder)? updates]) =>
      (StartLevelAttemptRequestBuilder()..update(updates))._build();

  _$StartLevelAttemptRequest._(
      {required this.levelId,
      required this.clientAttemptId,
      required this.contentVersion})
      : super._();
  @override
  StartLevelAttemptRequest rebuild(
          void Function(StartLevelAttemptRequestBuilder) updates) =>
      (toBuilder()..update(updates)).build();

  @override
  StartLevelAttemptRequestBuilder toBuilder() =>
      StartLevelAttemptRequestBuilder()..replace(this);

  @override
  bool operator ==(Object other) {
    if (identical(other, this)) return true;
    return other is StartLevelAttemptRequest &&
        levelId == other.levelId &&
        clientAttemptId == other.clientAttemptId &&
        contentVersion == other.contentVersion;
  }

  @override
  int get hashCode {
    var _$hash = 0;
    _$hash = $jc(_$hash, levelId.hashCode);
    _$hash = $jc(_$hash, clientAttemptId.hashCode);
    _$hash = $jc(_$hash, contentVersion.hashCode);
    _$hash = $jf(_$hash);
    return _$hash;
  }

  @override
  String toString() {
    return (newBuiltValueToStringHelper(r'StartLevelAttemptRequest')
          ..add('levelId', levelId)
          ..add('clientAttemptId', clientAttemptId)
          ..add('contentVersion', contentVersion))
        .toString();
  }
}

class StartLevelAttemptRequestBuilder
    implements
        Builder<StartLevelAttemptRequest, StartLevelAttemptRequestBuilder> {
  _$StartLevelAttemptRequest? _$v;

  String? _levelId;
  String? get levelId => _$this._levelId;
  set levelId(String? levelId) => _$this._levelId = levelId;

  String? _clientAttemptId;
  String? get clientAttemptId => _$this._clientAttemptId;
  set clientAttemptId(String? clientAttemptId) =>
      _$this._clientAttemptId = clientAttemptId;

  String? _contentVersion;
  String? get contentVersion => _$this._contentVersion;
  set contentVersion(String? contentVersion) =>
      _$this._contentVersion = contentVersion;

  StartLevelAttemptRequestBuilder() {
    StartLevelAttemptRequest._defaults(this);
  }

  StartLevelAttemptRequestBuilder get _$this {
    final $v = _$v;
    if ($v != null) {
      _levelId = $v.levelId;
      _clientAttemptId = $v.clientAttemptId;
      _contentVersion = $v.contentVersion;
      _$v = null;
    }
    return this;
  }

  @override
  void replace(StartLevelAttemptRequest other) {
    _$v = other as _$StartLevelAttemptRequest;
  }

  @override
  void update(void Function(StartLevelAttemptRequestBuilder)? updates) {
    if (updates != null) updates(this);
  }

  @override
  StartLevelAttemptRequest build() => _build();

  _$StartLevelAttemptRequest _build() {
    final _$result = _$v ??
        _$StartLevelAttemptRequest._(
          levelId: BuiltValueNullFieldError.checkNotNull(
              levelId, r'StartLevelAttemptRequest', 'levelId'),
          clientAttemptId: BuiltValueNullFieldError.checkNotNull(
              clientAttemptId, r'StartLevelAttemptRequest', 'clientAttemptId'),
          contentVersion: BuiltValueNullFieldError.checkNotNull(
              contentVersion, r'StartLevelAttemptRequest', 'contentVersion'),
        );
    replace(_$result);
    return _$result;
  }
}

// ignore_for_file: deprecated_member_use_from_same_package,type=lint
