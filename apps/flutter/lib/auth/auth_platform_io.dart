import 'dart:async';
import 'dart:io' show Platform;

import 'package:app_links/app_links.dart';
import 'package:openid_client/openid_client_io.dart' as openid;
import 'package:url_launcher/url_launcher.dart';

import 'auth_platform_interface.dart';

/// The desktop callback is deliberately an IPv4 literal. The local Keycloak
/// clients only allow this exact loopback URI and IPv6 is not routable in the
/// supported Plantini development and E2E environments.
final Uri desktopLoopbackRedirectUri = Uri.parse('http://127.0.0.1:4000/');

/// Phones return to the app through a registered URL scheme: the system opens
/// the app directly, even when it was paused in the background while the
/// browser showed the login (a loopback server does not survive that, and a
/// verification mail opened in another browser cannot reach it at all).
/// Keycloak's `plantini-mobile-*` clients allow exactly this redirect URI.
final Uri mobileDeepLinkRedirectUri = Uri.parse(
  'eu.plantini.app://oauth2redirect',
);

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
  Future<void> logout(openid.Credential credential) async {}

  @override
  Future<openid.Credential?> login(
    String issuerUrl,
    String clientId,
    List<String> scopes,
  ) async {
    final issuer = await openid.Issuer.discover(Uri.parse(issuerUrl));
    final client = openid.Client(issuer, clientId);
    if (_isPhone) {
      return _loginWithDeepLink(createMobilePkceFlow(client, scopes));
    }
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

/// Builds the same PKCE flow for phones, returning through [mobileDeepLinkRedirectUri].
openid.Flow createMobilePkceFlow(
  openid.Client client,
  Iterable<String> scopes,
) {
  final flow = openid.Flow.authorizationCodeWithPKCE(client);
  flow.scopes.addAll(scopes);
  flow.redirectUri = mobileDeepLinkRedirectUri;
  return flow;
}

bool get _isPhone => Platform.isAndroid || Platform.isIOS;

/// Opens the login page in the browser and waits for the deep link that
/// brings the player back to the app.
Future<openid.Credential?> _loginWithDeepLink(openid.Flow flow) async {
  final links = AppLinks();
  final returned = links.uriLinkStream.firstWhere(
    (uri) =>
        uri.scheme == mobileDeepLinkRedirectUri.scheme &&
        uri.host == mobileDeepLinkRedirectUri.host,
  );
  await _launchAuthorizationPage(flow.authenticationUri);
  // A login that is never finished must not hang forever.
  final uri = await returned.timeout(const Duration(minutes: 15));
  if (uri.queryParameters.containsKey('error')) {
    throw StateError(
      'Die Anmeldung wurde abgebrochen: ${uri.queryParameters['error']}',
    );
  }
  return flow.callback(uri.queryParameters);
}

AuthPlatformHelper getAuthPlatformHelper() => IoAuthPlatformHelper();
