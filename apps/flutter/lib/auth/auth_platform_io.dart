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

/// Phones return to the app through a verified Android App Link
/// (`https://plantini.eu/app/login`, served by the homepage). Unlike a loopback
/// server it survives the app being paused behind the browser, and unlike a
/// bare custom scheme a plain https redirect is never blocked by the browser:
/// where the system does not open the app by itself, that page forwards code
/// and state to the custom scheme [mobileSchemeLink] and offers a button.
/// Keycloak's `plantini-mobile-*` clients allow exactly these redirect URIs.
final Uri mobileDeepLinkRedirectUri = Uri.parse(
  'https://plantini.eu/app/login',
);

/// What the landing page forwards to when the App Link did not open the app.
final Uri mobileSchemeLink = Uri.parse('eu.plantini.app://oauth2redirect');

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

Future<void> _launchAuthorizationPage(Uri uri, {bool inApp = false}) async {
  // A Custom Tab (in-app browser view) belongs to the app, so Chrome hands the
  // redirect back to it more readily than from a free-standing browser tab.
  var launched =
      inApp && await launchUrl(uri, mode: LaunchMode.inAppBrowserView);
  launched =
      launched || await launchUrl(uri, mode: LaunchMode.externalApplication);
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

/// Whether [uri] is the browser handing the login result back to the app.
bool isLoginReturnLink(Uri uri) =>
    (uri.scheme == mobileDeepLinkRedirectUri.scheme &&
        uri.host == mobileDeepLinkRedirectUri.host &&
        uri.path.startsWith(mobileDeepLinkRedirectUri.path)) ||
    (uri.scheme == mobileSchemeLink.scheme &&
        uri.host == mobileSchemeLink.host);

/// Opens the login page in the browser and waits for the deep link that
/// brings the player back to the app.
Future<openid.Credential?> _loginWithDeepLink(openid.Flow flow) async {
  final links = AppLinks();
  final returned = links.uriLinkStream.firstWhere(isLoginReturnLink);
  await _launchAuthorizationPage(flow.authenticationUri, inApp: true);
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
