import 'package:flutter/foundation.dart';
import 'package:openid_client/openid_client_browser.dart' as openid;
import 'auth_platform_interface.dart';

class WebAuthPlatformHelper implements AuthPlatformHelper {
  @override
  Future<openid.Credential?> login(String issuerUrl, String clientId, List<String> scopes) async {
    try {
      var issuer = await openid.Issuer.discover(Uri.parse(issuerUrl));
      var client = openid.Client(issuer, clientId);
      var authenticator = openid.Authenticator(client, scopes: scopes);
      authenticator.authorize();
      return null;
    } catch (e) {
      debugPrint('Web login failed: $e');
      return null;
    }
  }

  @override
  Future<openid.Credential?> processRedirect(String issuerUrl, String clientId, List<String> scopes) async {
    try {
      var issuer = await openid.Issuer.discover(Uri.parse(issuerUrl));
      var client = openid.Client(issuer, clientId);
      var credential = await openid.Authenticator(client, scopes: scopes).credential;
      return credential;
    } catch (e) {
      debugPrint('Web processRedirect failed: $e');
      return null;
    }
  }
}

AuthPlatformHelper getAuthPlatformHelper() => WebAuthPlatformHelper();
