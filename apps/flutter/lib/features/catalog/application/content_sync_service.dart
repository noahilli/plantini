import 'dart:convert';

import 'package:crypto/crypto.dart';
import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../../../adapters/http/platform_api_client.dart';
import '../../../app/app_version.dart';
import '../../../core/errors/app_failure.dart';
import '../../../core/result.dart';
import '../../../core/storage/local_database.dart';
import '../infrastructure/models/isar_ecosystem.dart';
import '../infrastructure/models/isar_level.dart';
import '../infrastructure/models/isar_plant.dart';

/// Representation of a content package entry within a release manifest.
final class ContentPackageDescriptor {
  const ContentPackageDescriptor({
    required this.id,
    required this.url,
    required this.sha256,
    required this.bytes,
  });

  final String id;
  final String url;
  final String sha256;
  final int bytes;

  factory ContentPackageDescriptor.fromJson(Map<String, dynamic> json) {
    final id = json['id'] as String?;
    final url = json['url'] as String?;
    final sha256 = json['sha256'] as String?;
    final bytes = json['bytes'] as int?;

    final uri = url == null ? null : Uri.tryParse(url);
    if (id == null ||
        id.isEmpty ||
        url == null ||
        uri == null ||
        uri.hasScheme ||
        uri.hasAuthority ||
        uri.hasFragment ||
        uri.pathSegments.contains('..') ||
        sha256 == null ||
        !RegExp(r'^[a-fA-F0-9]{64}$').hasMatch(sha256) ||
        bytes == null ||
        bytes <= 0) {
      throw const FormatException(
        'ContentPackage contains invalid required fields.',
      );
    }

    return ContentPackageDescriptor(
      id: id,
      url: url,
      sha256: sha256,
      bytes: bytes,
    );
  }
}

/// Representation of the release manifest (/content/manifest).
final class ContentReleaseManifest {
  const ContentReleaseManifest({
    required this.version,
    required this.releasedAt,
    required this.schemaVersion,
    required this.minimumAppVersion,
    required this.packages,
    this.signature,
  });

  final String version;
  final String releasedAt;
  final String schemaVersion;
  final String minimumAppVersion;
  final List<ContentPackageDescriptor> packages;
  final String? signature;

  factory ContentReleaseManifest.fromJson(Map<String, dynamic> json) {
    final version = json['version'] as String?;
    final releasedAt = json['releasedAt'] as String?;
    final schemaVersion = json['schemaVersion'] as String?;
    final minimumAppVersion = json['minimumAppVersion'] as String?;
    final rawPackages = json['packages'] as List<dynamic>? ?? const [];
    final signature = json['signature'] as String?;

    if (version == null ||
        version.isEmpty ||
        releasedAt == null ||
        DateTime.tryParse(releasedAt) == null ||
        schemaVersion == null ||
        schemaVersion != '1.0' ||
        minimumAppVersion == null ||
        !RegExp(r'^\d+\.\d+\.\d+$').hasMatch(minimumAppVersion)) {
      throw const FormatException(
        'ContentManifest has invalid release metadata.',
      );
    }

    final packages = rawPackages
        .map(
          (p) => ContentPackageDescriptor.fromJson(p as Map<String, dynamic>),
        )
        .toList(growable: false);

    return ContentReleaseManifest(
      version: version,
      releasedAt: releasedAt,
      schemaVersion: schemaVersion,
      minimumAppVersion: minimumAppVersion,
      packages: packages,
      signature: signature,
    );
  }
}

/// Result summary of an atomic content sync operation.
final class ContentSyncResult {
  const ContentSyncResult({
    required this.version,
    required this.ecosystemCount,
    required this.levelCount,
    required this.plantCount,
  });

  final String version;
  final int ecosystemCount;
  final int levelCount;
  final int plantCount;
}

typedef PackageDownloader = Future<Result<Uint8List>> Function(String url);
typedef LocalReleaseProbe = Future<bool> Function(String version);

/// Service responsible for atomically downloading, validating (via SHA-256),
/// and persisting content releases into the local storage.
final class ContentSyncService {
  ContentSyncService({
    required this.apiClient,
    this.localDatabase,
    this.preferences,
    this.packageDownloader,
    this.localReleaseExists,
    this.appVersion,
  });

  final PlatformApiClient apiClient;
  final LocalDatabase? localDatabase;
  final SharedPreferences? preferences;
  final PackageDownloader? packageDownloader;
  final LocalReleaseProbe? localReleaseExists;

  /// Optional injection; production defaults to the bundled pubspec/define.
  final String? appVersion;

  static const String activeContentVersionKey =
      'plantini.content.active_version';

  /// Returns the currently active local content version.
  String? get activeLocalVersion =>
      preferences?.getString(activeContentVersionKey);

  /// Fetches the manifest, downloads all packages, validates SHA-256 checksums,
  /// and atomically updates local storage.
  Future<Result<ContentSyncResult>> syncRelease({bool force = false}) async {
    // 1. Fetch manifest
    final manifestResponse = await apiClient.getJson('content/manifest');
    if (manifestResponse case Failure<ApiJsonResponse>(:final failure)) {
      return Result.failure(failure);
    }

    final body = (manifestResponse as Success<ApiJsonResponse>).value.body;
    final ContentReleaseManifest manifest;
    try {
      manifest = ContentReleaseManifest.fromJson(body);
    } catch (error) {
      return Result.failure(
        ContractFailure(
          message: 'Das Inhalts-Manifest entspricht nicht dem API-Vertrag.',
          cause: error,
          missingFields: const ['manifest structure'],
        ),
      );
    }

    // Enforce compatibility before any package download or cache mutation,
    // including forced syncs and releases already present locally.
    final String currentVersion;
    final List<int> current;
    final List<int> minimum;
    try {
      currentVersion = appVersion ?? await AppVersion.read();
      current = AppVersion.components(currentVersion);
      minimum = AppVersion.components(manifest.minimumAppVersion);
    } catch (error) {
      return Result.failure(
        ConfigurationFailure(
          message:
              'Die App-Version konnte nicht sicher ermittelt werden. '
              'Der bisherige Inhaltsstand bleibt erhalten.',
          cause: error,
        ),
      );
    }
    for (var index = 0; index < minimum.length; index++) {
      if (current[index] > minimum[index]) break;
      if (current[index] < minimum[index]) {
        return Result.failure(
          AppUpdateRequiredFailure(
            message:
                'App-Update erforderlich: Diese Inhalte benötigen mindestens '
                'Plantini ${manifest.minimumAppVersion} '
                '(installiert: $currentVersion). Bitte aktualisiere die App. '
                'Der bisherige Inhaltsstand bleibt erhalten.',
          ),
        );
      }
    }

    // Skip if already on this version and not forcing
    if (!force &&
        activeLocalVersion == manifest.version &&
        await _hasCompleteLocalRelease(manifest.version)) {
      debugPrint(
        'ContentSyncService: Local content is already up-to-date (${manifest.version}).',
      );
      return Result.success(
        ContentSyncResult(
          version: manifest.version,
          ecosystemCount: 0,
          levelCount: 0,
          plantCount: 0,
        ),
      );
    }

    // 2. Download and validate all packages in memory before any DB write
    final downloadedEcosystems = <IsarEcosystem>[];
    final downloadedLevels = <IsarLevel>[];
    final downloadedPlants = <IsarPlant>[];

    for (final pkg in manifest.packages) {
      final downloadResult = await _downloadPackageBytes(pkg.url);
      if (downloadResult case Failure<Uint8List>(:final failure)) {
        return Result.failure(failure);
      }

      final bytes = (downloadResult as Success<Uint8List>).value;

      // Validate SHA-256 Checksum
      final computedChecksum = sha256.convert(bytes).toString().toLowerCase();
      final expectedChecksum = pkg.sha256.toLowerCase();

      if (computedChecksum != expectedChecksum) {
        return Result.failure(
          ValidationFailure(
            message:
                'Integritätsfehler für Paket "${pkg.id}": Prüfsumme ungültig.',
            fieldErrors: {
              'expected': expectedChecksum,
              'actual': computedChecksum,
            },
          ),
        );
      }

      if (bytes.length != pkg.bytes) {
        return Result.failure(
          ValidationFailure(
            message: 'Integritätsfehler für Paket "${pkg.id}": Größe ungültig.',
            fieldErrors: {
              'expected': '${pkg.bytes}',
              'actual': '${bytes.length}',
            },
          ),
        );
      }

      // Parse payload
      try {
        final jsonString = utf8.decode(bytes);
        final dynamic parsed = jsonDecode(jsonString);

        switch (pkg.id) {
          case 'ecosystems':
            final items = _extractItemList(parsed);
            for (final item in items) {
              downloadedEcosystems.add(
                _parseIsarEcosystem(item, manifest.version),
              );
            }
          case 'levels':
            final items = _extractItemList(parsed);
            for (final item in items) {
              downloadedLevels.add(_parseIsarLevel(item, manifest.version));
            }
          case 'plants':
            final items = _extractItemList(parsed);
            for (final item in items) {
              downloadedPlants.add(_parseIsarPlant(item, manifest.version));
            }
        }
      } catch (error) {
        return Result.failure(
          ContractFailure(
            message: 'Paket "${pkg.id}" enthält ungültige JSON-Inhaltsdaten.',
            cause: error,
            missingFields: const ['packages payload'],
          ),
        );
      }
    }

    const requiredPackages = {'ecosystems', 'levels', 'plants'};
    final packageIds = manifest.packages.map((pkg) => pkg.id).toList();
    if (packageIds.length != requiredPackages.length ||
        packageIds.toSet().length != requiredPackages.length ||
        !packageIds.toSet().containsAll(requiredPackages)) {
      return Result.failure(
        const ContractFailure(
          message:
              'Das Inhalts-Manifest enthält nicht alle erforderlichen Pakete.',
          missingFields: ['ecosystems', 'levels', 'plants'],
        ),
      );
    }

    if (downloadedEcosystems.isEmpty ||
        downloadedLevels.isEmpty ||
        downloadedPlants.isEmpty) {
      return Result.failure(
        const ContractFailure(
          message: 'Das Inhaltsrelease ist unvollständig; der bisherige Stand bleibt erhalten.',
          missingFields: ['content items'],
        ),
      );
    }

    try {
      _validateRelationships(
        downloadedEcosystems,
        downloadedLevels,
        downloadedPlants,
        manifest.version,
      );
    } catch (error) {
      return Result.failure(
        ContractFailure(
          message: 'Das Inhaltsrelease enthält ungültige Beziehungen; der bisherige Stand bleibt erhalten.',
          cause: error,
          missingFields: const ['content relationships'],
        ),
      );
    }

    // 3. Atomically write to database
    final localDb = localDatabase;
    if (localDb != null && localDb.isar.isOpen) {
      try {
        localDb.isar.write((_) {
          localDb.ecosystems.clear();
          localDb.levels.clear();
          localDb.plants.clear();
          if (downloadedEcosystems.isNotEmpty) {
            for (final item in downloadedEcosystems) {
              if (item.id <= 0) item.id = localDb.ecosystems.autoIncrement();
            }
            localDb.ecosystems.putAll(downloadedEcosystems);
          }
          if (downloadedLevels.isNotEmpty) {
            for (final item in downloadedLevels) {
              if (item.id <= 0) item.id = localDb.levels.autoIncrement();
            }
            localDb.levels.putAll(downloadedLevels);
          }
          if (downloadedPlants.isNotEmpty) {
            for (final item in downloadedPlants) {
              if (item.id <= 0) item.id = localDb.plants.autoIncrement();
            }
            localDb.plants.putAll(downloadedPlants);
          }
        });
      } catch (error) {
        return Result.failure(
          StorageFailure(
            message:
                'Lokale Inhaltsdatenbank konnte nicht aktualisiert werden.',
            cause: error,
          ),
        );
      }
    }

    // 4. Update stored version on success
    await preferences?.setString(activeContentVersionKey, manifest.version);

    return Result.success(
      ContentSyncResult(
        version: manifest.version,
        ecosystemCount: downloadedEcosystems.length,
        levelCount: downloadedLevels.length,
        plantCount: downloadedPlants.length,
      ),
    );
  }

  Future<bool> _hasCompleteLocalRelease(String version) async {
    final probe = localReleaseExists;
    if (probe != null) return probe(version);
    final localDb = localDatabase;
    if (localDb == null) return true;
    if (!localDb.isar.isOpen) return false;
    try {
      final ecosystemCount = localDb.ecosystems.count();
      final levelCount = localDb.levels.count();
      final plantCount = localDb.plants.count();
      if (ecosystemCount == 0 || levelCount == 0 || plantCount == 0) {
        return false;
      }
      return ecosystemCount > 0 && levelCount > 0 && plantCount > 0;
    } catch (error) {
      debugPrint(
        'ContentSyncService: Could not verify local release $version: $error',
      );
      return false;
    }
  }

  Future<Result<Uint8List>> _downloadPackageBytes(String url) async {
    final downloader = packageDownloader;
    if (downloader != null) {
      return downloader(url);
    }

    // Hash the original wire bytes. Re-encoding a parsed JSON response changes
    // whitespace and key ordering, making a valid immutable package fail SHA-256.
    return apiClient.getBytes(url, accept: 'application/json');
  }

  List<Map<String, dynamic>> _extractItemList(dynamic parsed) {
    if (parsed is List) {
      return parsed.cast<Map<String, dynamic>>();
    }
    if (parsed is Map<String, dynamic> && parsed['items'] is List) {
      return (parsed['items'] as List).cast<Map<String, dynamic>>();
    }
    throw const FormatException('Content package needs an items list.');
  }

  void _validateRelationships(
    List<IsarEcosystem> ecosystems,
    List<IsarLevel> levels,
    List<IsarPlant> plants,
    String version,
  ) {
    final ecosystemById = {for (final item in ecosystems) item.publicId: item};
    final levelById = {for (final item in levels) item.publicId: item};
    final plantById = {for (final item in plants) item.publicId: item};
    if (ecosystemById.length != ecosystems.length ||
        levelById.length != levels.length ||
        plantById.length != plants.length) {
      throw const FormatException('Duplicate content IDs.');
    }
    for (final plant in plants) {
      if (plant.publicId.isEmpty ||
          plant.slug.isEmpty ||
          plant.scientificName.isEmpty ||
          plant.commonName.isEmpty ||
          plant.releaseVersion != version) {
        throw const FormatException('Invalid plant identity or version.');
      }
    }
    final plantsByEcosystem = <String, Set<String>>{};
    for (final ecosystem in ecosystems) {
      if (ecosystem.publicId.isEmpty ||
          ecosystem.slug.isEmpty ||
          ecosystem.title.isEmpty ||
          ecosystem.releaseVersion != version ||
          ecosystem.levelIds.isEmpty ||
          ecosystem.levelIds.toSet().length != ecosystem.levelIds.length) {
        throw const FormatException('Invalid ecosystem identity or levels.');
      }
      final scopedPlants = <String>{};
      for (final id in ecosystem.levelIds) {
        final level = levelById[id];
        if (level == null || level.ecosystemId != ecosystem.publicId) {
          throw const FormatException('Ecosystem references a missing level.');
        }
        scopedPlants.addAll(level.plantIds);
      }
      plantsByEcosystem[ecosystem.publicId] = scopedPlants;
    }
    final sequences = <String, Set<int>>{};
    for (final level in levels) {
      final ecosystem = ecosystemById[level.ecosystemId];
      if (level.publicId.isEmpty ||
          ecosystem == null ||
          !ecosystem.levelIds.contains(level.publicId) ||
          level.title.isEmpty ||
          level.sequence < 1 ||
          !level.minimumScore.isFinite ||
          level.minimumScore < 0 ||
          level.minimumScore > 1 ||
          level.contentVersion != version ||
          level.plantIds.isEmpty ||
          level.plantIds.toSet().length != level.plantIds.length ||
          level.plantIds.any((id) => !plantById.containsKey(id)) ||
          level.requiredQuizIds.isEmpty ||
          level.requiredQuizIds.any((id) => id.isEmpty) ||
          level.requiredQuizIds.toSet().length !=
              level.requiredQuizIds.length ||
          level.requiredPlantIds.any(
            (id) => !plantsByEcosystem[level.ecosystemId]!.contains(id),
          ) ||
          level.requiredLevelIds.any(
            (id) =>
                levelById[id]?.ecosystemId != level.ecosystemId ||
                (levelById[id]?.sequence ?? 0) >= level.sequence,
          ) ||
          !(sequences
              .putIfAbsent(level.ecosystemId, () => <int>{})
              .add(level.sequence))) {
        throw const FormatException('Invalid level rules or references.');
      }
    }
  }

  IsarEcosystem _parseIsarEcosystem(Map<String, dynamic> map, String version) {
    return IsarEcosystem()
      ..publicId = map['id'] as String? ?? ''
      ..slug = map['slug'] as String? ?? ''
      ..title = map['name'] as String? ?? map['title'] as String? ?? ''
      ..releaseVersion = map['releaseVersion'] as String? ?? version
      ..levelIds = (map['levelIds'] as List<dynamic>?)?.cast<String>() ?? []
      ..description = map['description'] as String?;
  }

  IsarLevel _parseIsarLevel(Map<String, dynamic> map, String version) {
    final completion = map['completionRule'] as Map<String, dynamic>?;
    return IsarLevel()
      ..publicId = map['id'] as String? ?? ''
      ..ecosystemId = map['ecosystemId'] as String? ?? ''
      ..title = map['title'] as String? ?? ''
      ..sequence = map['sequence'] as int? ?? 1
      ..status = IsarLevelStatus.available
      ..minimumScore = (completion?['minimumScore'] as num?)?.toDouble() ?? 0.8
      ..requiredQuizIds =
          (completion?['requiredQuizIds'] as List<dynamic>?)?.cast<String>() ??
          []
      ..plantIds = (map['plantIds'] as List<dynamic>?)?.cast<String>() ?? []
      ..requiredPlantIds =
          (completion?['requiredPlantIds'] as List<dynamic>?)?.cast<String>() ??
          []
      ..requiredLevelIds =
          (completion?['requiredLevelIds'] as List<dynamic>?)?.cast<String>() ??
          []
      ..learningGoal = map['learningGoal'] as String?
      ..contentVersion = version;
  }

  IsarPlant _parseIsarPlant(Map<String, dynamic> map, String version) {
    final rawProfileCards = (map['profileCards'] as List<dynamic>?) ?? [];
    final profileCards = rawProfileCards
        .whereType<Map>()
        .map((card) {
          final values = Map<String, dynamic>.from(card);
          return IsarPlantProfileCard()
            ..heading = values['heading'] as String? ?? ''
            ..text = values['text'] as String? ?? '';
        })
        .where((card) => card.heading.isNotEmpty && card.text.isNotEmpty)
        .toList(growable: false);
    final rawMedia = (map['media'] as List<dynamic>?) ?? [];
    final mediaList = rawMedia
        .map((m) {
          final mediaMap = m as Map<String, dynamic>;
          return IsarPlantMedia()
            ..publicId = mediaMap['id'] as String? ?? ''
            ..slug = mediaMap['slug'] as String? ?? ''
            ..url = mediaMap['url'] as String? ?? ''
            ..altText = mediaMap['altText'] as String? ?? ''
            ..license = mediaMap['license'] as String? ?? 'CC-BY-4.0'
            ..author = mediaMap['author'] as String?
            ..source = mediaMap['source'] as String?
            ..licenseUrl = mediaMap['licenseUrl'] as String?
            ..automatic = mediaMap['automatic'] == true;
        })
        .toList(growable: false);

    return IsarPlant()
      ..publicId = map['id'] as String? ?? ''
      ..slug = map['slug'] as String? ?? ''
      ..scientificName = map['scientificName'] as String? ?? ''
      ..commonName = map['commonName'] as String? ?? ''
      ..family = map['family'] as String? ?? ''
      ..description = map['description'] as String? ?? ''
      ..warning = map['warning'] as String?
      ..sources = (map['sources'] as List<dynamic>?)?.cast<String>() ?? []
      ..profileCards = profileCards
      ..releaseVersion = version
      ..media = mediaList;
  }
}
