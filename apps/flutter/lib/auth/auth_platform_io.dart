import 'package:flutter/foundation.dart';
import 'package:openid_client/openid_client_io.dart' as openid;
import 'package:url_launcher/url_launcher.dart';

import 'auth_platform_interface.dart';

class IoAuthPlatformHelper implements AuthPlatformHelper {
  @override
  Future<openid.Credential?> login(
    String issuerUrl,
    String clientId,
    List<String> scopes,
  ) async {
    try {
      var issuer = await openid.Issuer.discover(Uri.parse(issuerUrl));
      var client = openid.Client(issuer, clientId);

      void urlLauncher(String url) async {
        final uri = Uri.parse(url);
        if (await canLaunchUrl(uri)) {
          await launchUrl(uri, mode: LaunchMode.externalApplication);
        }
      }

      var authenticator = openid.Authenticator(
        client,
        scopes: scopes,
        port: 4000,
        urlLancher: urlLauncher,
      );

      var credential = await authenticator.authorize();
      return credential;
    } catch (e) {
      debugPrint('IO login failed: $e');
      return null;
    }
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

AuthPlatformHelper getAuthPlatformHelper() => IoAuthPlatformHelper();
