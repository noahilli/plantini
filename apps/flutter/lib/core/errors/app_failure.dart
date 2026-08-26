/// A typed, user-safe failure that can cross the application boundary.
///
/// Raw transport and platform exceptions must remain inside infrastructure
/// adapters. Keeping the failure vocabulary small lets the UI expose honest
/// recovery states without leaking endpoints, tokens, or stack traces.
sealed class AppFailure implements Exception {
  const AppFailure({required this.code, required this.message, this.cause});

  final String code;
  final String message;
  final Object? cause;

  bool get isRetryable => switch (this) {
    NetworkFailure() || ServerFailure() || TimeoutFailure() => true,
    _ => false,
  };

  @override
  String toString() => '$runtimeType($code)';
}

final class ConfigurationFailure extends AppFailure {
  const ConfigurationFailure({required super.message, super.cause})
    : super(code: 'configuration_invalid');
}

final class NetworkFailure extends AppFailure {
  const NetworkFailure({required super.message, super.cause})
    : super(code: 'network_unavailable');
}

final class TimeoutFailure extends AppFailure {
  const TimeoutFailure({required super.message, super.cause})
    : super(code: 'request_timeout');
}

final class ServerFailure extends AppFailure {
  const ServerFailure({
    required super.message,
    required this.statusCode,
    this.traceId,
    super.cause,
  }) : super(code: 'server_error');

  final int? statusCode;
  final String? traceId;
}

final class UnauthorizedFailure extends AppFailure {
  const UnauthorizedFailure({required super.message, super.cause})
    : super(code: 'unauthorized');
}

final class PermissionFailure extends AppFailure {
  const PermissionFailure({required super.message, super.cause})
    : super(code: 'permission_denied');
}

final class ValidationFailure extends AppFailure {
  const ValidationFailure({
    required super.message,
    this.fieldErrors = const {},
    super.cause,
  }) : super(code: 'validation_failed');

  final Map<String, String> fieldErrors;
}

final class ContractFailure extends AppFailure {
  const ContractFailure({
    required super.message,
    required this.missingFields,
    super.cause,
  }) : super(code: 'contract_violation');

  final List<String> missingFields;
}

final class NotFoundFailure extends AppFailure {
  const NotFoundFailure({required super.message, super.cause})
    : super(code: 'not_found');
}

final class ConflictFailure extends AppFailure {
  const ConflictFailure({required super.message, super.cause})
    : super(code: 'conflict');
}

final class StorageFailure extends AppFailure {
  const StorageFailure({required super.message, super.cause})
    : super(code: 'storage_failed');
}
