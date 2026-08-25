import 'package:openid_client/openid_client.dart';

abstract class AuthPlatformHelper {
  Future<Credential?> login(String issuerUrl, String clientId, List<String> scopes);
  Future<Credential?> processRedirect(String issuerUrl, String clientId, List<String> scopes);
}

AuthPlatformHelper getAuthPlatformHelper() => throw UnsupportedError('Cannot create auth helper without platform implementation');
