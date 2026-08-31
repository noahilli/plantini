// ignore_for_file: avoid_web_libraries_in_flutter

import 'dart:convert';
import 'dart:html' as html;
import 'dart:math';

import 'package:flutter/foundation.dart';
import 'package:openid_client/openid_client.dart' as openid;

import 'auth_platform_interface.dart';

/// Browser implementation of Authorization Code + PKCE.
///
/// `openid_client_browser.Authenticator` only implements the implicit flow;
/// that flow is disabled in the realm. Keeping this implementation explicit
/// prevents a security-configured Keycloak client from silently falling back
/// to an incompatible browser grant.
class WebAuthPlatformHelper implements AuthPlatformHelper {
  static const _transactionKey = 'plantini.oidc.pkce.transaction.v1';

  @override
  Future<openid.Credential?> login(
    String issuerUrl,
    String clientId,
    List<String> scopes,
  ) async {
    final redirectUri = _callbackUri();
    final state = _opaqueValue(48);
    final verifier = _opaqueValue(96);
    final issuer = await openid.Issuer.discover(Uri.parse(issuerUrl));
    final client = openid.Client(issuer, clientId);
    final flow = openid.Flow.authorizationCodeWithPKCE(
      client,
      state: state,
      codeVerifier: verifier,
      scopes: scopes,
    )..redirectUri = redirectUri;

    html.window.sessionStorage[_transactionKey] = jsonEncode({
      'issuerUrl': issuerUrl,
      'clientId': clientId,
      'scopes': scopes,
      'state': state,
      'verifier': verifier,
      'redirectUri': redirectUri.toString(),
    });
    html.window.location.assign(flow.authenticationUri.toString());
    return null;
  }

  @override
  Future<openid.Credential?> processRedirect(
    String issuerUrl,
    String clientId,
    List<String> scopes,
  ) async {
    final current = Uri.base;
    final code = current.queryParameters['code'];
    final error = current.queryParameters['error'];
    if (code == null || code.isEmpty) {
      if (error != null && error.isNotEmpty) {
        throw StateError('OIDC authorization failed: $error');
      }
      return null;
    }

    final transaction = _readTransaction();
    if (transaction == null ||
        transaction.issuerUrl != issuerUrl ||
        transaction.clientId != clientId ||
        !_sameScopes(transaction.scopes, scopes) ||
        transaction.redirectUri != _callbackUri().toString()) {
      throw StateError(
        'OIDC callback does not match the pending PKCE transaction.',
      );
    }

    final issuer = await openid.Issuer.discover(Uri.parse(issuerUrl));
    final client = openid.Client(issuer, clientId);
    final flow = openid.Flow.authorizationCodeWithPKCE(
      client,
      state: transaction.state,
      codeVerifier: transaction.verifier,
      scopes: transaction.scopes,
    )..redirectUri = Uri.parse(transaction.redirectUri);

    try {
      final credential = await flow.callback(current.queryParameters);
      html.window.sessionStorage.remove(_transactionKey);
      return credential;
    } catch (error) {
      debugPrint('WebAuthPlatformHelper callback failed: $error');
      html.window.sessionStorage.remove(_transactionKey);
      rethrow;
    }
  }

  @override
  Future<void> completeRedirect() async {
    final current = Uri.parse(html.window.location.href);
    if (!current.queryParameters.containsKey('code') &&
        !current.queryParameters.containsKey('state') &&
        !current.queryParameters.containsKey('session_state')) {
      return;
    }
    // Persisting the credential happens before this handoff. A same-origin
    // replacement then boots the app from a clean URL and prevents Flutter's
    // router from restoring its startup callback location.
    final unloading = html.window.onUnload.first;
    html.window.location.replace('/');
    // Do not publish authenticated router state from the callback document.
    // The clean document restores that state from secure storage.
    await unloading;
  }

  Uri _callbackUri() {
    final current = Uri.base;
    // A hash-routed Flutter page must not leak its current route into the
    // OIDC redirect URI. Keycloak validates redirect URIs exactly, while the
    // fragment is client-only and must never be part of that contract.
    return Uri(
      scheme: current.scheme,
      userInfo: current.userInfo,
      host: current.host,
      port: current.hasPort ? current.port : null,
      path: '/auth/callback',
    );
  }

  _PkceTransaction? _readTransaction() {
    final encoded = html.window.sessionStorage[_transactionKey];
    if (encoded == null || encoded.isEmpty) return null;
    try {
      final value = jsonDecode(encoded);
      if (value is! Map<String, dynamic>) return null;
      final issuerUrl = value['issuerUrl'];
      final clientId = value['clientId'];
      final state = value['state'];
      final verifier = value['verifier'];
      final redirectUri = value['redirectUri'];
      final rawScopes = value['scopes'];
      if (issuerUrl is! String ||
          clientId is! String ||
          state is! String ||
          verifier is! String ||
          redirectUri is! String ||
          rawScopes is! List ||
          rawScopes.any((scope) => scope is! String)) {
        return null;
      }
      return _PkceTransaction(
        issuerUrl: issuerUrl,
        clientId: clientId,
        state: state,
        verifier: verifier,
        redirectUri: redirectUri,
        scopes: rawScopes.cast<String>(),
      );
    } catch (error) {
      debugPrint(
        'WebAuthPlatformHelper: corrupted PKCE transaction in storage: $error',
      );
      return null;
    }
  }
}

final class _PkceTransaction {
  const _PkceTransaction({
    required this.issuerUrl,
    required this.clientId,
    required this.state,
    required this.verifier,
    required this.redirectUri,
    required this.scopes,
  });

  final String issuerUrl;
  final String clientId;
  final String state;
  final String verifier;
  final String redirectUri;
  final List<String> scopes;
}

String _opaqueValue(int length) {
  const alphabet =
      'ABCDEFGHIJKLMNOPQRSTUVWXYZabcdefghijklmnopqrstuvwxyz0123456789-._~';
  final random = Random.secure();
  return List.generate(
    length,
    (_) => alphabet[random.nextInt(alphabet.length)],
  ).join();
}

bool _sameScopes(List<String> first, List<String> second) =>
    first.length == second.length && first.every(second.contains);

AuthPlatformHelper getAuthPlatformHelper() => WebAuthPlatformHelper();
