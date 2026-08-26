import 'dart:convert';

import 'package:flutter/foundation.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:openid_client/openid_client.dart';

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

final class SecureCredentialStore implements CredentialStore {
  SecureCredentialStore({FlutterSecureStorage? storage})
    : _storage = storage ?? const FlutterSecureStorage();

  static const _key = 'plantini.oidc.credential.v1';
  final FlutterSecureStorage _storage;

  @override
  Future<Credential?> read() async {
    final String? encoded;
    try {
      encoded = await _storage.read(key: _key);
    } catch (error) {
      throw CredentialStoreUnavailable(error);
    }
    if (encoded == null || encoded.isEmpty) return null;
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
  }
}
