import 'dart:convert';

import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../../../core/errors/app_failure.dart';
import '../../../core/result.dart';
import '../domain/catalog_models.dart';
import '../domain/catalog_repository.dart';

/// Read-through cache for published content. It never invents content: a
/// network failure can only show a previously validated server response.
final class CachedCatalogRepository implements CatalogRepository {
  CachedCatalogRepository({required this._remote, required this._preferences});

  final CatalogRepository _remote;
  final SharedPreferences _preferences;

  @override
  Future<Result<List<Ecosystem>>> listPublishedEcosystems() => _cached(
    key: 'plantini.catalog.ecosystems.v1',
    loadRemote: _remote.listPublishedEcosystems,
    encode: (items) => items.map(_ecosystemToJson).toList(growable: false),
    decode: (value) {
      if (value is! List) {
        throw const FormatException('Ecosystem cache is not a list.');
      }
      return value
          .map((item) => _ecosystemFromJson(_map(item)))
          .toList(growable: false);
    },
  );

  @override
  Future<Result<LevelContent>> getPublishedLevel(String levelId) => _cached(
    key: 'plantini.catalog.level.$levelId.v1',
    loadRemote: () => _remote.getPublishedLevel(levelId),
    encode: (value) => {
      'contentVersion': value.contentVersion,
      'level': _levelToJson(value.level),
    },
    decode: (value) {
      final map = _map(value);
      final contentVersion = map['contentVersion'];
      if (contentVersion is! String) {
        throw const FormatException('Missing contentVersion.');
      }
      return LevelContent(
        level: _levelFromJson(_map(map['level'])),
        contentVersion: contentVersion,
      );
    },
  );

  @override
  Future<Result<List<Level>>> listPublishedLevels(String ecosystemId) =>
      _cached(
        key: 'plantini.catalog.ecosystem.$ecosystemId.levels.v1',
        loadRemote: () => _remote.listPublishedLevels(ecosystemId),
        encode: (items) => items.map(_levelToJson).toList(growable: false),
        decode: (value) {
          if (value is! List) {
            throw const FormatException('Level cache is not a list.');
          }
          return value
              .map((item) => _levelFromJson(_map(item)))
              .toList(growable: false);
        },
      );

  Future<Result<T>> _cached<T>({
    required String key,
    required Future<Result<T>> Function() loadRemote,
    required Object? Function(T value) encode,
    required T Function(Object? value) decode,
  }) async {
    final remote = await loadRemote();
    if (remote case Success<T>(:final value)) {
      try {
        await _preferences.setString(key, jsonEncode(encode(value)));
      } catch (error) {
        // A successful online response remains valid even if its cache write
        // fails; the next offline launch will truthfully lack local content.
        debugPrint(
          'CachedCatalogRepository: Failed to write cache for $key: $error',
        );
      }
      return Result.success(value);
    }
    final failure = (remote as Failure<T>).failure;
    try {
      final raw = _preferences.getString(key);
      if (raw == null) return Result.failure(failure);
      return Result.success(decode(jsonDecode(raw)));
    } catch (error) {
      return Result.failure(
        StorageFailure(
          message: 'Der lokale Inhaltscache konnte nicht gelesen werden.',
          cause: error,
        ),
      );
    }
  }
}

Map<String, Object?> _ecosystemToJson(Ecosystem value) => {
  'id': value.id,
  'slug': value.slug,
  'title': value.title,
  'releaseVersion': value.releaseVersion,
  'levelIds': value.levelIds,
  'description': value.description,
};

Ecosystem _ecosystemFromJson(Map<String, dynamic> value) => Ecosystem(
  id: _string(value, 'id'),
  slug: _string(value, 'slug'),
  title: _string(value, 'title'),
  releaseVersion: _string(value, 'releaseVersion'),
  levelIds: _stringList(value['levelIds']),
  description: value['description'] as String?,
);

Map<String, Object?> _levelToJson(Level value) => {
  'id': value.id,
  'ecosystemId': value.ecosystemId,
  'title': value.title,
  'sequence': value.sequence,
  'status': value.status.name,
  'minimumScore': value.minimumScore,
  'requiredQuizIds': value.requiredQuizIds,
  'plantIds': value.plantIds,
  'requiredPlantIds': value.requiredPlantIds,
  'learningGoal': value.learningGoal,
  'progress': value.progress,
  'blockedReason': value.blockedReason,
};

Level _levelFromJson(Map<String, dynamic> value) {
  final status = switch (value['status']) {
    'locked' => LevelStatus.locked,
    'available' => LevelStatus.available,
    'inProgress' => LevelStatus.inProgress,
    'completed' => LevelStatus.completed,
    _ => null,
  };
  if (status == null ||
      value['sequence'] is! int ||
      value['minimumScore'] is! num) {
    throw const FormatException('Cached level is malformed.');
  }
  return Level(
    id: _string(value, 'id'),
    ecosystemId: _string(value, 'ecosystemId'),
    title: _string(value, 'title'),
    sequence: value['sequence'] as int,
    status: status,
    minimumScore: (value['minimumScore'] as num).toDouble(),
    requiredQuizIds: _stringList(value['requiredQuizIds']),
    plantIds: _stringList(value['plantIds']),
    requiredPlantIds: _stringList(value['requiredPlantIds']),
    learningGoal: value['learningGoal'] as String?,
    progress: (value['progress'] as num?)?.toDouble(),
    blockedReason: value['blockedReason'] as String?,
  );
}

Map<String, dynamic> _map(Object? value) {
  if (value is! Map) {
    throw const FormatException('Cached value is not an object.');
  }
  return Map<String, dynamic>.from(value);
}

String _string(Map<String, dynamic> value, String key) {
  final field = value[key];
  if (field is! String || field.isEmpty) {
    throw FormatException('Cached $key is missing.');
  }
  return field;
}

List<String> _stringList(Object? value) {
  if (value is! List || value.any((item) => item is! String)) {
    throw const FormatException('Cached list is malformed.');
  }
  return value.cast<String>();
}
