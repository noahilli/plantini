import 'package:dio/dio.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:plantini_app/adapters/http/platform_api_client.dart';
import 'package:plantini_app/app/app_config.dart';
import 'package:plantini_app/core/errors/app_failure.dart';
import 'package:plantini_app/core/result.dart';

AppConfig get _config => AppConfig.fromValues(
  environment: PlantiniEnvironment.development,
  apiBaseUrl: 'http://127.0.0.1:1338/api/v1',
  oidcIssuerUrl: 'http://127.0.0.1:8082/realms/plantini',
  oidcClientId: 'plantini-mobile-dev',
);

void main() {
  test('fails locally when a protected request has no access token', () async {
    var requested = false;
    final dio = Dio()
      ..interceptors.add(
        InterceptorsWrapper(
          onRequest: (options, handler) {
            requested = true;
            handler.next(options);
          },
        ),
      );
    final client = PlatformApiClient(
      config: _config,
      dio: dio,
      accessTokenProvider: () async => null,
    );

    final result = await client.getJson(
      'levels/10000000-0000-4000-8000-000000000010',
      requiresAuthentication: true,
    );

    expect(requested, isFalse);
    expect(result, isA<Failure<ApiJsonResponse>>());
    expect(
      (result as Failure<ApiJsonResponse>).failure,
      isA<UnauthorizedFailure>(),
    );
  });
}
