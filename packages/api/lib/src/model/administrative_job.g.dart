// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'administrative_job.dart';

// **************************************************************************
// BuiltValueGenerator
// **************************************************************************

const AdministrativeJobStatusEnum _$administrativeJobStatusEnum_pending =
    const AdministrativeJobStatusEnum._('pending');
const AdministrativeJobStatusEnum _$administrativeJobStatusEnum_processing =
    const AdministrativeJobStatusEnum._('processing');
const AdministrativeJobStatusEnum _$administrativeJobStatusEnum_completed =
    const AdministrativeJobStatusEnum._('completed');
const AdministrativeJobStatusEnum _$administrativeJobStatusEnum_failed =
    const AdministrativeJobStatusEnum._('failed');

AdministrativeJobStatusEnum _$administrativeJobStatusEnumValueOf(String name) {
  switch (name) {
    case 'pending':
      return _$administrativeJobStatusEnum_pending;
    case 'processing':
      return _$administrativeJobStatusEnum_processing;
    case 'completed':
      return _$administrativeJobStatusEnum_completed;
    case 'failed':
      return _$administrativeJobStatusEnum_failed;
    default:
      throw ArgumentError(name);
  }
}

final BuiltSet<AdministrativeJobStatusEnum>
    _$administrativeJobStatusEnumValues =
    BuiltSet<AdministrativeJobStatusEnum>(const <AdministrativeJobStatusEnum>[
  _$administrativeJobStatusEnum_pending,
  _$administrativeJobStatusEnum_processing,
  _$administrativeJobStatusEnum_completed,
  _$administrativeJobStatusEnum_failed,
]);

Serializer<AdministrativeJobStatusEnum>
    _$administrativeJobStatusEnumSerializer =
    _$AdministrativeJobStatusEnumSerializer();

class _$AdministrativeJobStatusEnumSerializer
    implements PrimitiveSerializer<AdministrativeJobStatusEnum> {
  static const Map<String, Object> _toWire = const <String, Object>{
    'pending': 'pending',
    'processing': 'processing',
    'completed': 'completed',
    'failed': 'failed',
  };
  static const Map<Object, String> _fromWire = const <Object, String>{
    'pending': 'pending',
    'processing': 'processing',
    'completed': 'completed',
    'failed': 'failed',
  };

  @override
  final Iterable<Type> types = const <Type>[AdministrativeJobStatusEnum];
  @override
  final String wireName = 'AdministrativeJobStatusEnum';

  @override
  Object serialize(Serializers serializers, AdministrativeJobStatusEnum object,
          {FullType specifiedType = FullType.unspecified}) =>
      _toWire[object.name] ?? object.name;

  @override
  AdministrativeJobStatusEnum deserialize(
          Serializers serializers, Object serialized,
          {FullType specifiedType = FullType.unspecified}) =>
      AdministrativeJobStatusEnum.valueOf(
          _fromWire[serialized] ?? (serialized is String ? serialized : ''));
}

class _$AdministrativeJob extends AdministrativeJob {
  @override
  final String id;
  @override
  final AdministrativeJobStatusEnum status;
  @override
  final DateTime createdAt;
  @override
  final String? failureCode;

  factory _$AdministrativeJob(
          [void Function(AdministrativeJobBuilder)? updates]) =>
      (AdministrativeJobBuilder()..update(updates))._build();

  _$AdministrativeJob._(
      {required this.id,
      required this.status,
      required this.createdAt,
      this.failureCode})
      : super._();
  @override
  AdministrativeJob rebuild(void Function(AdministrativeJobBuilder) updates) =>
      (toBuilder()..update(updates)).build();

  @override
  AdministrativeJobBuilder toBuilder() =>
      AdministrativeJobBuilder()..replace(this);

  @override
  bool operator ==(Object other) {
    if (identical(other, this)) return true;
    return other is AdministrativeJob &&
        id == other.id &&
        status == other.status &&
        createdAt == other.createdAt &&
        failureCode == other.failureCode;
  }

  @override
  int get hashCode {
    var _$hash = 0;
    _$hash = $jc(_$hash, id.hashCode);
    _$hash = $jc(_$hash, status.hashCode);
    _$hash = $jc(_$hash, createdAt.hashCode);
    _$hash = $jc(_$hash, failureCode.hashCode);
    _$hash = $jf(_$hash);
    return _$hash;
  }

  @override
  String toString() {
    return (newBuiltValueToStringHelper(r'AdministrativeJob')
          ..add('id', id)
          ..add('status', status)
          ..add('createdAt', createdAt)
          ..add('failureCode', failureCode))
        .toString();
  }
}

class AdministrativeJobBuilder
    implements Builder<AdministrativeJob, AdministrativeJobBuilder> {
  _$AdministrativeJob? _$v;

  String? _id;
  String? get id => _$this._id;
  set id(String? id) => _$this._id = id;

  AdministrativeJobStatusEnum? _status;
  AdministrativeJobStatusEnum? get status => _$this._status;
  set status(AdministrativeJobStatusEnum? status) => _$this._status = status;

  DateTime? _createdAt;
  DateTime? get createdAt => _$this._createdAt;
  set createdAt(DateTime? createdAt) => _$this._createdAt = createdAt;

  String? _failureCode;
  String? get failureCode => _$this._failureCode;
  set failureCode(String? failureCode) => _$this._failureCode = failureCode;

  AdministrativeJobBuilder() {
    AdministrativeJob._defaults(this);
  }

  AdministrativeJobBuilder get _$this {
    final $v = _$v;
    if ($v != null) {
      _id = $v.id;
      _status = $v.status;
      _createdAt = $v.createdAt;
      _failureCode = $v.failureCode;
      _$v = null;
    }
    return this;
  }

  @override
  void replace(AdministrativeJob other) {
    _$v = other as _$AdministrativeJob;
  }

  @override
  void update(void Function(AdministrativeJobBuilder)? updates) {
    if (updates != null) updates(this);
  }

  @override
  AdministrativeJob build() => _build();

  _$AdministrativeJob _build() {
    final _$result = _$v ??
        _$AdministrativeJob._(
          id: BuiltValueNullFieldError.checkNotNull(
              id, r'AdministrativeJob', 'id'),
          status: BuiltValueNullFieldError.checkNotNull(
              status, r'AdministrativeJob', 'status'),
          createdAt: BuiltValueNullFieldError.checkNotNull(
              createdAt, r'AdministrativeJob', 'createdAt'),
          failureCode: failureCode,
        );
    replace(_$result);
    return _$result;
  }
}

// ignore_for_file: deprecated_member_use_from_same_package,type=lint
