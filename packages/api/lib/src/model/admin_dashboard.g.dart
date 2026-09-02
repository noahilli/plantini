// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'admin_dashboard.dart';

// **************************************************************************
// BuiltValueGenerator
// **************************************************************************

class _$AdminDashboard extends AdminDashboard {
  @override
  final DateTime generatedAt;
  @override
  final BuiltMap<String, num> metrics;

  factory _$AdminDashboard([void Function(AdminDashboardBuilder)? updates]) =>
      (AdminDashboardBuilder()..update(updates))._build();

  _$AdminDashboard._({required this.generatedAt, required this.metrics})
      : super._();
  @override
  AdminDashboard rebuild(void Function(AdminDashboardBuilder) updates) =>
      (toBuilder()..update(updates)).build();

  @override
  AdminDashboardBuilder toBuilder() => AdminDashboardBuilder()..replace(this);

  @override
  bool operator ==(Object other) {
    if (identical(other, this)) return true;
    return other is AdminDashboard &&
        generatedAt == other.generatedAt &&
        metrics == other.metrics;
  }

  @override
  int get hashCode {
    var _$hash = 0;
    _$hash = $jc(_$hash, generatedAt.hashCode);
    _$hash = $jc(_$hash, metrics.hashCode);
    _$hash = $jf(_$hash);
    return _$hash;
  }

  @override
  String toString() {
    return (newBuiltValueToStringHelper(r'AdminDashboard')
          ..add('generatedAt', generatedAt)
          ..add('metrics', metrics))
        .toString();
  }
}

class AdminDashboardBuilder
    implements Builder<AdminDashboard, AdminDashboardBuilder> {
  _$AdminDashboard? _$v;

  DateTime? _generatedAt;
  DateTime? get generatedAt => _$this._generatedAt;
  set generatedAt(DateTime? generatedAt) => _$this._generatedAt = generatedAt;

  MapBuilder<String, num>? _metrics;
  MapBuilder<String, num> get metrics =>
      _$this._metrics ??= MapBuilder<String, num>();
  set metrics(MapBuilder<String, num>? metrics) => _$this._metrics = metrics;

  AdminDashboardBuilder() {
    AdminDashboard._defaults(this);
  }

  AdminDashboardBuilder get _$this {
    final $v = _$v;
    if ($v != null) {
      _generatedAt = $v.generatedAt;
      _metrics = $v.metrics.toBuilder();
      _$v = null;
    }
    return this;
  }

  @override
  void replace(AdminDashboard other) {
    _$v = other as _$AdminDashboard;
  }

  @override
  void update(void Function(AdminDashboardBuilder)? updates) {
    if (updates != null) updates(this);
  }

  @override
  AdminDashboard build() => _build();

  _$AdminDashboard _build() {
    _$AdminDashboard _$result;
    try {
      _$result = _$v ??
          _$AdminDashboard._(
            generatedAt: BuiltValueNullFieldError.checkNotNull(
                generatedAt, r'AdminDashboard', 'generatedAt'),
            metrics: metrics.build(),
          );
    } catch (_) {
      late String _$failedField;
      try {
        _$failedField = 'metrics';
        metrics.build();
      } catch (e) {
        throw BuiltValueNestedFieldError(
            r'AdminDashboard', _$failedField, e.toString());
      }
      rethrow;
    }
    replace(_$result);
    return _$result;
  }
}

// ignore_for_file: deprecated_member_use_from_same_package,type=lint
