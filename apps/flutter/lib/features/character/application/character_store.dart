import 'dart:convert';

import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../../../core/result.dart';
import '../domain/character_repository.dart';
import '../presentation/widgets/explorer_roster.dart';

enum CharacterStatus { idle, loading, ready }

/// Which explorer the player chose: loaded after login, cached on the device,
/// written back when it changes. The 3D views read it through [PlayerLook].
///
/// Offline the cached choice is used; a change that could not be sent yet is
/// marked and sent at the next sync. Without server answer and cache a default
/// explorer is shown, nobody is forced into the selector by a dead connection.
final class CharacterStore extends ChangeNotifier {
  CharacterStore({required this.repository, required this.preferences});

  static const _prefsKey = 'explorer_v2';
  static const fallbackId = 'kai';

  final CharacterRepository repository;
  final SharedPreferences preferences;

  CharacterStatus _status = CharacterStatus.idle;
  bool _placeholder = false;
  Future<void>? _running;

  CharacterStatus get status => _status;
  String? get explorerId => PlayerLook.id.value;

  /// The first login: the server has none and nothing is cached.
  bool get needsSelection =>
      _status == CharacterStatus.ready && explorerId == null && !_placeholder;

  /// Loads the choice (once at a time). Safe to call again, e.g. when the app
  /// returns to the front and the last try failed.
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
      // The router holds the player on the boot screen until the status is
      // ready, so whatever fails here (asset, cache, server) must not stick.
      debugPrint('CharacterStore sync failed: $error\n$stack');
      if (PlayerLook.id.value == null) {
        _placeholder = true;
        PlayerLook.id.value = fallbackId;
      }
    } finally {
      _status = CharacterStatus.ready;
      notifyListeners();
    }
  }

  Future<void> _load() async {
    final roster = await ExplorerRoster.load();
    final cached = _readCache(roster);
    if (cached != null) PlayerLook.id.value = cached.id;

    final loaded = await repository.load();
    switch (loaded) {
      case Success<String?>(:final value):
        _placeholder = false;
        final server = roster.byId(value)?.id;
        if (cached != null && cached.dirty) {
          await _push(cached.id); // an offline change wins
        } else if (server != null) {
          _apply(server, dirty: false);
        } else if (cached != null) {
          await _push(cached.id);
        } else {
          PlayerLook.id.value = null;
        }
      case Failure<String?>():
        if (cached == null) {
          _placeholder = true;
          PlayerLook.id.value = fallbackId;
        }
    }
  }

  /// Shows [explorerId] at once and sends it; a failed send is kept for later.
  Future<Result<String>> choose(String explorerId) async {
    _placeholder = false;
    _apply(explorerId, dirty: true);
    notifyListeners();
    return _push(explorerId);
  }

  Future<Result<String>> _push(String explorerId) async {
    final saved = await repository.save(explorerId);
    if (saved case Success<String>(:final value)) {
      _apply(value, dirty: false);
      notifyListeners();
    }
    return saved;
  }

  /// Forget everything of the signed-in player (logout).
  void reset() {
    _status = CharacterStatus.idle;
    _placeholder = false;
    PlayerLook.id.value = null;
    preferences.remove(_prefsKey);
    notifyListeners();
  }

  void _apply(String id, {required bool dirty}) {
    PlayerLook.id.value = id;
    preferences.setString(_prefsKey, jsonEncode({'id': id, 'dirty': dirty}));
  }

  ({String id, bool dirty})? _readCache(ExplorerRoster roster) {
    try {
      final raw = preferences.getString(_prefsKey);
      if (raw == null) return null;
      final json = jsonDecode(raw) as Map<String, dynamic>;
      final id = roster.byId(json['id'] as String?)?.id;
      return id == null ? null : (id: id, dirty: json['dirty'] == true);
    } catch (_) {
      return null;
    }
  }
}
