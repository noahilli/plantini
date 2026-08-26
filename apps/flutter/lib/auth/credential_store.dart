import 'dart:convert';

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

final class SecureCredentialStore implements CredentialStore {
  SecureCredentialStore({FlutterSecureStorage? storage})
    : _storage = storage ?? const FlutterSecureStorage();

  static const _key = 'plantini.oidc.credential.v1';
  final FlutterSecureStorage _storage;

  @override
  Future<Credential?> read() async {
    final encoded = await _storage.read(key: _key);
    if (encoded == null || encoded.isEmpty) return null;
    try {
      final value = jsonDecode(encoded);
      if (value is! Map<String, dynamic>) return null;
      return Credential.fromJson(value);
    } catch (_) {
      await clear();
      return null;
    }
  }

  @override
  Future<void> write(Credential credential) =>
      _storage.write(key: _key, value: jsonEncode(credential.toJson()));

  @override
  Future<void> clear() => _storage.delete(key: _key);
}
