import 'dart:convert';

import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../../../core/result.dart';
import '../domain/character_repository.dart';
import '../domain/character_spec.dart';
import '../presentation/widgets/character_kit.dart';

enum CharacterStatus { idle, loading, ready }

/// The player's character: loaded after login, cached on the device, and
/// written back when it changes. The 3D views read it through [PlayerLook].
///
/// Offline the cached character is used; a change that could not be sent yet
/// stays marked and is sent at the next sync. Without server answer and cache
/// a starter character is shown, nobody is forced into the creator by a dead
/// connection.
final class CharacterStore extends ChangeNotifier {
  CharacterStore({required this.repository, required this.preferences});

  static const _prefsKey = 'character_v1';

  final CharacterRepository repository;
  final SharedPreferences preferences;

  CharacterStatus _status = CharacterStatus.idle;
  bool _placeholder = false;
  Future<void>? _running;

  CharacterStatus get status => _status;
  CharacterSpec? get spec => PlayerLook.spec.value;

  /// The first login: the server has no character and nothing is cached.
  bool get needsCreation =>
      _status == CharacterStatus.ready && spec == null && !_placeholder;

  /// Loads the character (once at a time). Safe to call again, e.g. when the
  /// app returns to the front and the last try failed.
  Future<void> sync() => _running ??= _sync().whenComplete(() {
    _running = null;
  });

  Future<void> _sync() async {
    if (_status == CharacterStatus.ready && !_placeholder) return;
    _status = CharacterStatus.loading;
    notifyListeners();
    try {
      await _load();
    } catch (error, stack) {
      // Whatever goes wrong (kit asset, cache, server), the app must open:
      // the router holds the player on the boot screen until the status is ready.
      debugPrint('CharacterStore sync failed: $error\n$stack');
      if (PlayerLook.spec.value == null) {
        _placeholder = true;
        PlayerLook.spec.value = CharacterSpec.starter();
      }
    } finally {
      _status = CharacterStatus.ready;
      notifyListeners();
    }
  }

  Future<void> _load() async {
    await CharacterKit.load();
    final cached = _readCache();
    if (cached != null) PlayerLook.spec.value = cached.spec;

    final loaded = await repository.load();
    switch (loaded) {
      case Success<CharacterSpec?>(:final value):
        _placeholder = false;
        if (cached != null && cached.dirty) {
          // An offline change wins over what the server still has.
          await _push(cached.spec);
        } else if (value != null) {
          _apply(value, dirty: false);
        } else if (cached != null) {
          await _push(cached.spec);
        } else {
          PlayerLook.spec.value = null;
        }
      case Failure<CharacterSpec?>():
        if (cached == null) {
          _placeholder = true;
          PlayerLook.spec.value = CharacterSpec.starter();
        }
    }
  }

  /// Shows [spec] at once and sends it; a failed send is kept for later.
  Future<Result<CharacterSpec>> save(CharacterSpec spec) async {
    _placeholder = false;
    _apply(spec, dirty: true);
    notifyListeners();
    return _push(spec);
  }

  Future<Result<CharacterSpec>> _push(CharacterSpec spec) async {
    final saved = await repository.save(spec);
    if (saved case Success<CharacterSpec>(:final value)) {
      _apply(value, dirty: false);
      notifyListeners();
    }
    return saved;
  }

  /// Forget everything of the signed-in player (logout).
  void reset() {
    _status = CharacterStatus.idle;
    _placeholder = false;
    PlayerLook.spec.value = null;
    preferences.remove(_prefsKey);
    notifyListeners();
  }

  void _apply(CharacterSpec spec, {required bool dirty}) {
    PlayerLook.spec.value = spec;
    preferences.setString(
      _prefsKey,
      jsonEncode({'spec': spec.toJson(), 'dirty': dirty}),
    );
  }

  ({CharacterSpec spec, bool dirty})? _readCache() {
    try {
      final raw = preferences.getString(_prefsKey);
      if (raw == null) return null;
      final json = jsonDecode(raw) as Map<String, dynamic>;
      final spec = CharacterSpec.fromJson(json['spec']);
      return spec == null ? null : (spec: spec, dirty: json['dirty'] == true);
    } catch (_) {
      return null;
    }
  }
}
