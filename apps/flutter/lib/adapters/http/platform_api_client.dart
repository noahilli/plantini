import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';

import '../../app/app_config.dart';
import '../../core/errors/app_failure.dart';
import '../../core/result.dart';

typedef AccessTokenProvider = Future<String?> Function();

/// The only HTTP entry point for feature adapters.
///
/// It deliberately exposes JSON and multipart primitives rather than generated
/// API models. Feature DTO mappers own the contract-to-domain translation and
/// can report an incomplete `/api/v1` contract precisely.
final class PlatformApiClient {
  PlatformApiClient({
    required AppConfig config,
    required this._accessTokenProvider,
    Dio? dio,
  }) : _dio =
           dio ??
           Dio(
             BaseOptions(
               baseUrl: config.apiBaseUri.toString(),
               connectTimeout: const Duration(seconds: 12),
               receiveTimeout: const Duration(seconds: 20),
               sendTimeout: const Duration(seconds: 30),
               headers: const {'Accept': 'application/json'},
             ),
           );

  final Dio _dio;
  final AccessTokenProvider _accessTokenProvider;

  Future<Result<ApiJsonResponse>> getJson(
    String path, {
    Map<String, Object?> queryParameters = const {},
    bool requiresAuthentication = false,
  }) => _requestJson(
    method: 'GET',
    path: path,
    queryParameters: queryParameters,
    requiresAuthentication: requiresAuthentication,
  );

  Future<Result<ApiJsonResponse>> postJson(
    String path, {
    required Map<String, Object?> body,
    String? idempotencyKey,
    bool requiresAuthentication = true,
  }) => _requestJson(
    method: 'POST',
    path: path,
    body: body,
    idempotencyKey: idempotencyKey,
    requiresAuthentication: requiresAuthentication,
  );

  Future<Result<ApiJsonResponse>> patchJson(
    String path, {
    required Map<String, Object?> body,
    String? idempotencyKey,
    String? ifMatchVersion,
    bool requiresAuthentication = true,
  }) => _requestJson(
    method: 'PATCH',
    path: path,
    body: body,
    idempotencyKey: idempotencyKey,
    ifMatchVersion: ifMatchVersion,
    requiresAuthentication: requiresAuthentication,
  );

  Future<Result<ApiJsonResponse>> postMultipart(
    String path, {
    required Map<String, Object?> fields,
    required Uint8List bytes,
    required String mediaType,
    required String filename,
    String? idempotencyKey,
    bool requiresAuthentication = true,
  }) async {
    final form = FormData.fromMap({
      ...fields,
      'image': MultipartFile.fromBytes(
        bytes,
        filename: filename,
        contentType: DioMediaType.parse(mediaType),
      ),
    });
    return _requestJson(
      method: 'POST',
      path: path,
      body: form,
      idempotencyKey: idempotencyKey,
      requiresAuthentication: requiresAuthentication,
    );
  }

  Future<Result<ApiJsonResponse>> deleteJson(
    String path, {
    String? idempotencyKey,
    String? ifMatchVersion,
    bool requiresAuthentication = true,
  }) => _requestJson(
    method: 'DELETE',
    path: path,
    idempotencyKey: idempotencyKey,
    ifMatchVersion: ifMatchVersion,
    requiresAuthentication: requiresAuthentication,
  );

  Future<Result<ApiJsonResponse>> _requestJson({
    required String method,
    required String path,
    Map<String, Object?> queryParameters = const {},
    Object? body,
    String? idempotencyKey,
    String? ifMatchVersion,
    bool requiresAuthentication = false,
  }) async {
    int attempt = 0;
    while (attempt < 2) {
      attempt++;
      try {
        final token = await _accessTokenProvider();
        if (requiresAuthentication && (token == null || token.isEmpty)) {
          return Result.failure(
            const UnauthorizedFailure(
              message:
                  'Deine Sitzung ist abgelaufen. Bitte melde dich erneut an.',
            ),
          );
        }
        final requestBody = body is FormData ? body.clone() : body;
        final response = await _dio.request<Object?>(
          _relativePath(path),
          data: requestBody,
          queryParameters: queryParameters,
          options: Options(
            method: method,
            contentType: body is FormData
                ? 'multipart/form-data'
                : 'application/json',
            headers: {
              if (token != null && token.isNotEmpty)
                'Authorization': 'Bearer $token',
              if (idempotencyKey != null) 'Idempotency-Key': idempotencyKey,
              if (ifMatchVersion != null) 'If-Match': ifMatchVersion,
            },
          ),
        );
        final data = response.data;
        if (data is Map<String, dynamic>) {
          return Result.success(
            ApiJsonResponse(
              body: data,
              statusCode: response.statusCode ?? 0,
              traceId: _traceId(response.headers),
            ),
          );
        }
        if ((response.statusCode == 202 || response.statusCode == 204) &&
            (data == null || data == '')) {
          return Result.success(
            ApiJsonResponse(
              body: const {},
              statusCode: response.statusCode ?? 0,
              traceId: _traceId(response.headers),
            ),
          );
        }
        return Result.failure(
          const ContractFailure(
            message:
                'Die API lieferte kein im Vertrag vorgesehenes JSON-Objekt.',
            missingFields: ['JSON object response body'],
          ),
        );
      } on DioException catch (error) {
        if (error.response?.statusCode == 401 && attempt == 1) {
          continue;
        }
        debugPrint('PlatformApiClient: DioException on $path: $error');
        return Result.failure(_mapDioFailure(error));
      } on AppFailure catch (failure) {
        debugPrint(
          'PlatformApiClient: AppFailure on $path: ${failure.message}',
        );
        return Result.failure(failure);
      } catch (error) {
        debugPrint('PlatformApiClient: unexpected error on $path: $error');
        return Result.failure(
          NetworkFailure(
            message: 'Die Verbindung zur Plantini-API konnte nicht aufgebaut werden.',
            cause: error,
          ),
        );
      }
    }
    return Result.failure(
      const NetworkFailure(
        message:
            'Die Verbindung zur Plantini-API konnte nicht aufgebaut werden.',
      ),
    );
  }

  String _relativePath(String path) {
    if (path.startsWith('/')) {
      throw const ConfigurationFailure(
        message: 'API-Pfade müssen relativ zu /api/v1 angegeben werden.',
      );
    }
    return path;
  }

  AppFailure _mapDioFailure(DioException error) {
    final statusCode = error.response?.statusCode;
    final traceId = _traceId(error.response?.headers);
    final body = error.response?.data;
    final problem = body is Map ? body : const <Object?, Object?>{};
    final detail = problem['detail'] ?? problem['title'];
    final message = detail is String && detail.isNotEmpty
        ? detail
        : 'Die Anfrage an die Plantini-API ist fehlgeschlagen.';

    if (statusCode == 401) {
      return UnauthorizedFailure(
        message: 'Deine Sitzung ist abgelaufen. Bitte melde dich erneut an.',
        cause: error,
      );
    }
    if (statusCode == 403) {
      return PermissionFailure(
        message: 'Du hast keine Berechtigung für diese Aktion.',
        cause: error,
      );
    }
    if (statusCode == 404) {
      return NotFoundFailure(
        message: 'Der angeforderte Inhalt wurde nicht gefunden.',
        cause: error,
      );
    }
    if (statusCode == 409) {
      return ConflictFailure(message: message, cause: error);
    }
    if (statusCode != null && statusCode >= 400 && statusCode < 500) {
      final fieldErrors = <String, String>{};
      final fields = problem['fieldErrors'];
      if (fields is Map) {
        for (final entry in fields.entries) {
          if (entry.key is String && entry.value is String) {
            fieldErrors[entry.key as String] = entry.value as String;
          }
        }
      }
      return ValidationFailure(
        message: message,
        fieldErrors: fieldErrors,
        cause: error,
      );
    }
    if (error.type == DioExceptionType.connectionTimeout ||
        error.type == DioExceptionType.receiveTimeout ||
        error.type == DioExceptionType.sendTimeout) {
      return TimeoutFailure(
        message: 'Die Plantini-API hat nicht rechtzeitig geantwortet.',
        cause: error,
      );
    }
    if (statusCode != null) {
      return ServerFailure(
        message: message,
        statusCode: statusCode,
        traceId: traceId,
        cause: error,
      );
    }
    return NetworkFailure(
      message: 'Keine Netzwerkverbindung zur Plantini-API.',
      cause: error,
    );
  }

  String? _traceId(Headers? headers) =>
      headers?.value('x-correlation-id') ?? headers?.value('x-request-id');
}

final class ApiJsonResponse {
  const ApiJsonResponse({
    required this.body,
    required this.statusCode,
    this.traceId,
  });

  final Map<String, dynamic> body;
  final int statusCode;
  final String? traceId;
}
