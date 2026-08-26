import 'package:flutter_test/flutter_test.dart';
import 'package:plantini_app/app/app_config.dart';
import 'package:plantini_app/core/errors/app_failure.dart';

void main() {
  test('accepts explicit v1 development configuration', () {
    final config = AppConfig.fromValues(
      environment: PlantiniEnvironment.development,
      apiBaseUrl: 'http://127.0.0.1:1338/api/v1',
      oidcIssuerUrl: 'http://127.0.0.1:8082/realms/plantini',
      oidcClientId: 'plantini-web-dev',
    );

    expect(config.apiBaseUri.toString(), 'http://127.0.0.1:1338/api/v1/');
    expect(config.oidcClientId, 'plantini-web-dev');
  });

  test(
    'rejects localhost-like missing configuration and wrong API boundary',
    () {
      expect(
        () => AppConfig.fromValues(
          environment: PlantiniEnvironment.development,
          apiBaseUrl: '',
          oidcIssuerUrl: 'http://127.0.0.1:8082/realms/plantini',
          oidcClientId: 'plantini-web-dev',
        ),
        throwsA(isA<ConfigurationFailure>()),
      );
      expect(
        () => AppConfig.fromValues(
          environment: PlantiniEnvironment.development,
          apiBaseUrl: 'http://127.0.0.1:1338/api',
          oidcIssuerUrl: 'http://127.0.0.1:8082/realms/plantini',
          oidcClientId: 'plantini-web-dev',
        ),
        throwsA(isA<ConfigurationFailure>()),
      );
    },
  );

  test('requires HTTPS for production configuration', () {
    expect(
      () => AppConfig.fromValues(
        environment: PlantiniEnvironment.production,
        apiBaseUrl: 'http://127.0.0.1:1338/api/v1',
        oidcIssuerUrl: 'https://identity.example.test/realms/plantini',
        oidcClientId: 'plantini-web-production',
      ),
      throwsA(isA<ConfigurationFailure>()),
    );
  });
}
