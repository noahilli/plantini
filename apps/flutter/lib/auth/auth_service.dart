import 'package:flutter/foundation.dart';
import 'package:openid_client/openid_client.dart';

import '../app/app_config.dart';
import '../core/errors/app_failure.dart';
import 'credential_store.dart';
import 'auth_platform_interface.dart' hide getAuthPlatformHelper;
import 'auth_platform_io.dart' if (dart.library.html) 'auth_platform_web.dart';

enum AuthState { initializing, unauthenticated, authenticated, failed }

/// Owns the Authorization Code + PKCE session. It never manufactures an
/// access token: requests without a current Keycloak credential are rejected
/// by the API and represented in the UI as an explicit signed-out state.
final class AuthService extends ChangeNotifier {
  AuthService({
    required this._config,
    AuthPlatformHelper? helper,
    CredentialStore? credentialStore,
  }) : _helper = helper ?? getAuthPlatformHelper(),
       _credentialStore = credentialStore ?? SecureCredentialStore();

  final AppConfig _config;
  final AuthPlatformHelper _helper;
  final CredentialStore _credentialStore;
  Credential? _credential;
  AuthState _state = AuthState.initializing;
  AppFailure? _failure;

  AuthState get state => _state;
  bool get isAuthenticated =>
      _state == AuthState.authenticated && _credential != null;
  AppFailure? get failure => _failure;
  String get issuerUrl => _config.oidcIssuerUri.toString();
  String get clientId => _config.oidcClientId;

  Future<void> initialize() async {
    try {
      final credential = await _helper.processRedirect(
        issuerUrl,
        clientId,
        const ['openid', 'profile', 'email'],
      );
      _credential = credential ?? await _credentialStore.read();
      if (credential != null) await _credentialStore.write(credential);
      _state = _credential == null
          ? AuthState.unauthenticated
          : AuthState.authenticated;
      _failure = null;
    } catch (_) {
      _credential = null;
      _state = AuthState.failed;
      _failure = const ConfigurationFailure(
        message: 'Die Anmeldung konnte nicht initialisiert werden. Prüfe die bereitgestellte OIDC-Konfiguration.',
      );
    }
    notifyListeners();
  }

  Future<void> login() async {
    _failure = null;
    try {
      final credential = await _helper.login(issuerUrl, clientId, const [
        'openid',
        'profile',
        'email',
      ]);
      if (credential != null) {
        _credential = credential;
        await _credentialStore.write(credential);
        _state = AuthState.authenticated;
        notifyListeners();
      }
      // Web navigation returns here only after the redirect, where initialize
      // resolves the credential. Do not mark that transition as a failure.
    } catch (_) {
      _state = AuthState.failed;
      _failure = const UnauthorizedFailure(
        message: 'Die Anmeldung konnte nicht abgeschlossen werden. Bitte versuche es erneut.',
      );
      notifyListeners();
    }
  }

  Future<String?> getAccessToken() async {
    final credential = _credential;
    if (credential == null) return null;
    try {
      final tokenResponse = await credential.getTokenResponse();
      final token = tokenResponse.accessToken;
      if (token != null && token.isNotEmpty) return token;
    } catch (_) {
      _credential = null;
      await _credentialStore.clear();
      _state = AuthState.unauthenticated;
      _failure = const UnauthorizedFailure(
        message: 'Deine Sitzung ist abgelaufen. Bitte melde dich erneut an.',
      );
      notifyListeners();
    }
    return null;
  }

  Future<void> logout() async {
    // The local client state is cleared immediately. Global RP-initiated
    // logout is deliberately added only with an approved post-logout redirect
    // per environment; no localhost fallback is guessed here.
    _credential = null;
    await _credentialStore.clear();
    _state = AuthState.unauthenticated;
    _failure = null;
    notifyListeners();
  }
}
