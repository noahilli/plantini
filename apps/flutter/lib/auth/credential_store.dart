import 'dart:convert';

import 'package:flutter/foundation.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:openid_client/openid_client.dart';
import 'package:shared_preferences/shared_preferences.dart';

/// Persists the serialised OIDC credential only through the platform secure
/// storage implementation. UI code never sees a refresh token or writes it to
/// normal preferences, logs, or the offline content cache.
abstract interface class CredentialStore {
  Future<Credential?> read();
  Future<void> write(Credential credential);
  Future<void> clear();
}

/// A platform keyring failure is distinct from an OIDC configuration error.
/// Linux deployments need libsecret and a running Secret Service to persist a
/// refresh token securely; callers can present an actionable recovery state.
final class CredentialStoreUnavailable implements Exception {
  const CredentialStoreUnavailable(this.cause);

  final Object cause;
}

/// Development builds on the web only: browsers expose WebCrypto (which the
/// secure storage plugin needs) just on https and localhost, so a demo opened by
/// the computer's address on a local network (`http://192.168.x.x`) cannot use
/// it. This store keeps the credential in the browser's local storage instead.
/// It is never created for staging or production builds (see [AuthService]).
final class InsecureDevCredentialStore implements CredentialStore {
  static const _key = 'plantini.oidc.credential.dev';

  @override
  Future<Credential?> read() async {
    final encoded = (await SharedPreferences.getInstance()).getString(_key);
    if (encoded == null || encoded.isEmpty) return null;
    try {
      return Credential.fromJson(jsonDecode(encoded) as Map<String, dynamic>);
    } catch (_) {
      await clear();
      return null;
    }
  }

  @override
  Future<void> write(Credential credential) async {
    await (await SharedPreferences.getInstance()).setString(
      _key,
      jsonEncode(credential.toJson()),
    );
  }

  @override
  Future<void> clear() async {
    await (await SharedPreferences.getInstance()).remove(_key);
  }
}

final class SecureCredentialStore implements CredentialStore {
  SecureCredentialStore({
    FlutterSecureStorage? storage,
    CredentialStore? developmentFallback,
  }) : _storage = storage ?? const FlutterSecureStorage(),
       _fallback = developmentFallback;

  static const _key = 'plantini.oidc.credential.v1';
  final FlutterSecureStorage _storage;

  /// Used only when the secure storage cannot work at all (development, web).
  final CredentialStore? _fallback;

  @override
  Future<Credential?> read() async {
    final String? encoded;
    try {
      encoded = await _storage.read(key: _key);
    } catch (error) {
      final fallback = _fallback;
      if (fallback != null) return fallback.read();
      throw CredentialStoreUnavailable(error);
    }
    if (encoded == null || encoded.isEmpty) return _fallback?.read();
    try {
      final value = jsonDecode(encoded);
      if (value is! Map<String, dynamic>) return null;
      return Credential.fromJson(value);
    } catch (error) {
      debugPrint(
        'SecureCredentialStore: corrupted credential in storage, clearing: $error',
      );
      await clear();
      return null;
    }
  }

  @override
  Future<void> write(Credential credential) async {
    try {
      await _storage.write(key: _key, value: jsonEncode(credential.toJson()));
    } catch (error) {
      final fallback = _fallback;
      if (fallback != null) return fallback.write(credential);
      throw CredentialStoreUnavailable(error);
    }
  }

  @override
  Future<void> clear() async {
    try {
      await _storage.delete(key: _key);
    } catch (error) {
      debugPrint('SecureCredentialStore: could not clear credential: $error');
    }
    await _fallback?.clear();
  }
}
