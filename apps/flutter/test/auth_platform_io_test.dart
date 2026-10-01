import 'package:flutter_test/flutter_test.dart';
import 'package:openid_client/openid_client_io.dart' as openid;
import 'package:plantini_app/auth/auth_platform_io.dart';

void main() {
  test('desktop login uses the IPv4 loopback PKCE callback', () {
    final issuer = openid.Issuer(
      openid.OpenIdProviderMetadata.fromJson({
        'issuer': 'https://identity.example.test/realms/plantini',
        'authorization_endpoint': 'https://identity.example.test/realms/plantini/protocol/openid-connect/auth',
        'token_endpoint': 'https://identity.example.test/realms/plantini/protocol/openid-connect/token',
        'response_types_supported': ['code'],
        'token_endpoint_auth_methods_supported': ['none'],
        'scopes_supported': ['openid', 'profile', 'email'],
      }),
    );

    final flow = createDesktopPkceFlow(
      openid.Client(issuer, 'plantini-mobile-dev'),
      const ['openid', 'profile', 'email'],
    );

    expect(desktopLoopbackRedirectUri.host, '127.0.0.1');
    expect(flow.redirectUri, desktopLoopbackRedirectUri);
    expect(
      flow.authenticationUri.queryParameters['code_challenge_method'],
      'S256',
    );
    expect(
      flow.authenticationUri.queryParameters['redirect_uri'],
      'http://127.0.0.1:4000/',
    );
  });

  test(
    'phone login returns through the app URL scheme, not a loopback server',
    () {
      final issuer = openid.Issuer(
        openid.OpenIdProviderMetadata.fromJson({
          'issuer': 'https://identity.example.test/realms/plantini',
          'authorization_endpoint': 'https://identity.example.test/realms/plantini/protocol/openid-connect/auth',
          'token_endpoint': 'https://identity.example.test/realms/plantini/protocol/openid-connect/token',
          'response_types_supported': ['code'],
          'token_endpoint_auth_methods_supported': ['none'],
          'scopes_supported': ['openid', 'profile', 'email'],
        }),
      );

      final flow = createMobilePkceFlow(
        openid.Client(issuer, 'plantini-mobile-production'),
        const ['openid', 'profile', 'email'],
      );

      expect(
        flow.authenticationUri.queryParameters['redirect_uri'],
        'eu.plantini.app://oauth2redirect',
      );
      expect(
        flow.authenticationUri.queryParameters['code_challenge_method'],
        'S256',
      );
      expect(flow.authenticationUri.queryParameters['state'], isNotEmpty);
    },
  );
}
