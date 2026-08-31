import 'package:openid_client/openid_client.dart';

abstract class AuthPlatformHelper {
  Future<Credential?> login(
    String issuerUrl,
    String clientId,
    List<String> scopes,
  );
  Future<Credential?> processRedirect(
    String issuerUrl,
    String clientId,
    List<String> scopes,
  );

  /// Removes one-time callback parameters after the credential was persisted.
  /// Non-browser platforms have no top-level URL to clean up.
  Future<void> completeRedirect() async {}
}

AuthPlatformHelper getAuthPlatformHelper() => throw UnsupportedError(
  'Cannot create auth helper without platform implementation',
);
