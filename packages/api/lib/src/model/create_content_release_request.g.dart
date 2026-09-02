// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'create_content_release_request.dart';

// **************************************************************************
// BuiltValueGenerator
// **************************************************************************

class _$CreateContentReleaseRequest extends CreateContentReleaseRequest {
  @override
  final String releaseVersion;
  @override
  final bool? dryRun;

  factory _$CreateContentReleaseRequest(
          [void Function(CreateContentReleaseRequestBuilder)? updates]) =>
      (CreateContentReleaseRequestBuilder()..update(updates))._build();

  _$CreateContentReleaseRequest._({required this.releaseVersion, this.dryRun})
      : super._();
  @override
  CreateContentReleaseRequest rebuild(
          void Function(CreateContentReleaseRequestBuilder) updates) =>
      (toBuilder()..update(updates)).build();

  @override
  CreateContentReleaseRequestBuilder toBuilder() =>
      CreateContentReleaseRequestBuilder()..replace(this);

  @override
  bool operator ==(Object other) {
    if (identical(other, this)) return true;
    return other is CreateContentReleaseRequest &&
        releaseVersion == other.releaseVersion &&
        dryRun == other.dryRun;
  }

  @override
  int get hashCode {
    var _$hash = 0;
    _$hash = $jc(_$hash, releaseVersion.hashCode);
    _$hash = $jc(_$hash, dryRun.hashCode);
    _$hash = $jf(_$hash);
    return _$hash;
  }

  @override
  String toString() {
    return (newBuiltValueToStringHelper(r'CreateContentReleaseRequest')
          ..add('releaseVersion', releaseVersion)
          ..add('dryRun', dryRun))
        .toString();
  }
}

class CreateContentReleaseRequestBuilder
    implements
        Builder<CreateContentReleaseRequest,
            CreateContentReleaseRequestBuilder> {
  _$CreateContentReleaseRequest? _$v;

  String? _releaseVersion;
  String? get releaseVersion => _$this._releaseVersion;
  set releaseVersion(String? releaseVersion) =>
      _$this._releaseVersion = releaseVersion;

  bool? _dryRun;
  bool? get dryRun => _$this._dryRun;
  set dryRun(bool? dryRun) => _$this._dryRun = dryRun;

  CreateContentReleaseRequestBuilder() {
    CreateContentReleaseRequest._defaults(this);
  }

  CreateContentReleaseRequestBuilder get _$this {
    final $v = _$v;
    if ($v != null) {
      _releaseVersion = $v.releaseVersion;
      _dryRun = $v.dryRun;
      _$v = null;
    }
    return this;
  }

  @override
  void replace(CreateContentReleaseRequest other) {
    _$v = other as _$CreateContentReleaseRequest;
  }

  @override
  void update(void Function(CreateContentReleaseRequestBuilder)? updates) {
    if (updates != null) updates(this);
  }

  @override
  CreateContentReleaseRequest build() => _build();

  _$CreateContentReleaseRequest _build() {
    final _$result = _$v ??
        _$CreateContentReleaseRequest._(
          releaseVersion: BuiltValueNullFieldError.checkNotNull(
              releaseVersion, r'CreateContentReleaseRequest', 'releaseVersion'),
          dryRun: dryRun,
        );
    replace(_$result);
    return _$result;
  }
}

// ignore_for_file: deprecated_member_use_from_same_package,type=lint
