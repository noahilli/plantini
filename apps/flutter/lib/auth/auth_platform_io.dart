import 'dart:async';

import 'package:openid_client/openid_client_io.dart' as openid;
import 'package:url_launcher/url_launcher.dart';

import 'auth_platform_interface.dart';

/// The desktop callback is deliberately an IPv4 literal. The local Keycloak
/// clients only allow this exact loopback URI and IPv6 is not routable in the
/// supported Plantini development and E2E environments.
final Uri desktopLoopbackRedirectUri = Uri.parse('http://127.0.0.1:4000/');

/// Builds a PKCE authorization-code flow for desktop clients. Keeping this
/// outside the widget layer makes the redirect and PKCE invariant testable.
openid.Flow createDesktopPkceFlow(
  openid.Client client,
  Iterable<String> scopes,
) {
  final flow = openid.Flow.authorizationCodeWithPKCE(client);
  flow.scopes.addAll(scopes);
  flow.redirectUri = desktopLoopbackRedirectUri;
  return flow;
}

final class IoAuthPlatformHelper implements AuthPlatformHelper {
  @override
  Future<void> completeRedirect() async {}

  @override
  Future<openid.Credential?> login(
    String issuerUrl,
    String clientId,
    List<String> scopes,
  ) async {
    final issuer = await openid.Issuer.discover(Uri.parse(issuerUrl));
    final client = openid.Client(issuer, clientId);
    final flow = createDesktopPkceFlow(client, scopes);
    final authorizationUri = flow.authenticationUri;

    if (!await canLaunchUrl(authorizationUri)) {
      throw StateError('Kein Browser kann die Anmeldung öffnen.');
    }

    final authenticator = openid.Authenticator.fromFlow(
      flow,
      urlLancher: (url) {
        unawaited(_launchAuthorizationPage(Uri.parse(url)));
      },
    );
    return authenticator.authorize();
  }

  @override
  Future<openid.Credential?> processRedirect(
    String issuerUrl,
    String clientId,
    List<String> scopes,
  ) async {
    return null;
  }
}

Future<void> _launchAuthorizationPage(Uri uri) async {
  final launched = await launchUrl(uri, mode: LaunchMode.externalApplication);
  if (!launched) {
    throw StateError('Der Browser konnte die Anmeldung nicht öffnen.');
  }
}

AuthPlatformHelper getAuthPlatformHelper() => IoAuthPlatformHelper();
