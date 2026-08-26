import '../core/errors/app_failure.dart';

enum PlantiniEnvironment { development, staging, production }

/// All deploy-time values are passed with --dart-define.
///
/// There is deliberately no localhost, emulator, IPv6, or fallback endpoint
/// here. A malformed deployment fails visibly during bootstrap instead of
/// accidentally sending user data to a development server.
final class AppConfig {
  const AppConfig({
    required this.environment,
    required this.apiBaseUri,
    required this.oidcIssuerUri,
    required this.oidcClientId,
  });

  final PlantiniEnvironment environment;
  final Uri apiBaseUri;
  final Uri oidcIssuerUri;
  final String oidcClientId;

  factory AppConfig.fromDartDefines() {
    const environmentValue = String.fromEnvironment(
      'PLANTINI_ENV',
      defaultValue: 'development',
    );
    const apiValue = String.fromEnvironment('PLANTINI_API_BASE_URL');
    const issuerValue = String.fromEnvironment('PLANTINI_OIDC_ISSUER_URL');
    const clientId = String.fromEnvironment('PLANTINI_OIDC_CLIENT_ID');

    final environment = switch (environmentValue) {
      'development' => PlantiniEnvironment.development,
      'staging' => PlantiniEnvironment.staging,
      'production' => PlantiniEnvironment.production,
      _ => throw ConfigurationFailure(
        message: 'PLANTINI_ENV muss development, staging oder production sein.',
      ),
    };

    return AppConfig.fromValues(
      environment: environment,
      apiBaseUrl: apiValue,
      oidcIssuerUrl: issuerValue,
      oidcClientId: clientId,
    );
  }

  factory AppConfig.fromValues({
    required PlantiniEnvironment environment,
    required String apiBaseUrl,
    required String oidcIssuerUrl,
    required String oidcClientId,
  }) {
    final apiBaseUri = _parseAbsoluteUri('PLANTINI_API_BASE_URL', apiBaseUrl);
    final oidcIssuerUri = _parseAbsoluteUri(
      'PLANTINI_OIDC_ISSUER_URL',
      oidcIssuerUrl,
    );

    if (!_hasApiV1Path(apiBaseUri)) {
      throw const ConfigurationFailure(
        message: 'PLANTINI_API_BASE_URL muss auf /api/v1 enden.',
      );
    }
    if (oidcClientId.trim().isEmpty) {
      throw const ConfigurationFailure(
        message: 'PLANTINI_OIDC_CLIENT_ID fehlt.',
      );
    }
    if (environment == PlantiniEnvironment.production &&
        (apiBaseUri.scheme != 'https' || oidcIssuerUri.scheme != 'https')) {
      throw const ConfigurationFailure(
        message: 'Production verlangt HTTPS für API und OIDC.',
      );
    }

    return AppConfig(
      environment: environment,
      apiBaseUri: _normaliseBaseUri(apiBaseUri),
      oidcIssuerUri: _normaliseBaseUri(oidcIssuerUri),
      oidcClientId: oidcClientId.trim(),
    );
  }

  static Uri _parseAbsoluteUri(String key, String value) {
    final uri = Uri.tryParse(value.trim());
    if (uri == null || !uri.hasScheme || uri.host.isEmpty) {
      throw ConfigurationFailure(message: '$key muss eine absolute URL sein.');
    }
    if (uri.scheme != 'http' && uri.scheme != 'https') {
      throw ConfigurationFailure(
        message: '$key muss http oder https verwenden.',
      );
    }
    return uri;
  }

  static bool _hasApiV1Path(Uri uri) {
    final path = uri.path.replaceAll(RegExp(r'/+$'), '');
    return path == '/api/v1';
  }

  static Uri _normaliseBaseUri(Uri uri) {
    final path = uri.path.replaceAll(RegExp(r'/+$'), '');
    return uri.replace(path: '$path/', query: null, fragment: null);
  }
}
