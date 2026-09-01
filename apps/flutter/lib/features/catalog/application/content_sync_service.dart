import 'dart:convert';

import 'package:crypto/crypto.dart';
import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../../../adapters/http/platform_api_client.dart';
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
    final bytes = json['bytes'] as int? ?? 0;

    if (id == null || url == null || sha256 == null) {
      throw const FormatException(
        'ContentPackage contains missing required fields.',
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
    final releasedAt = json['releasedAt'] as String? ?? '';
    final schemaVersion = json['schemaVersion'] as String? ?? '1.0';
    final minimumAppVersion = json['minimumAppVersion'] as String? ?? '0.1.0';
    final rawPackages = json['packages'] as List<dynamic>? ?? const [];
    final signature = json['signature'] as String?;

    if (version == null) {
      throw const FormatException('ContentManifest missing version field.');
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

/// Service responsible for atomically downloading, validating (via SHA-256),
/// and persisting content releases into the local storage.
final class ContentSyncService {
  ContentSyncService({
    required this.apiClient,
    this.localDatabase,
    this.preferences,
    this.packageDownloader,
  });

  final PlatformApiClient apiClient;
  final LocalDatabase? localDatabase;
  final SharedPreferences? preferences;
  final PackageDownloader? packageDownloader;

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

    // Skip if already on this version and not forcing
    if (!force && activeLocalVersion == manifest.version) {
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

    // 3. Atomically write to database
    final localDb = localDatabase;
    if (localDb != null && localDb.isar.isOpen) {
      try {
        await localDb.isar.writeTxn(() async {
          if (downloadedEcosystems.isNotEmpty) {
            await localDb.ecosystems.putAll(downloadedEcosystems);
          }
          if (downloadedLevels.isNotEmpty) {
            await localDb.levels.putAll(downloadedLevels);
          }
          if (downloadedPlants.isNotEmpty) {
            await localDb.plants.putAll(downloadedPlants);
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

  Future<Result<Uint8List>> _downloadPackageBytes(String url) async {
    final downloader = packageDownloader;
    if (downloader != null) {
      return downloader(url);
    }

    final relative = url.startsWith('/api/v1/')
        ? url.substring('/api/v1/'.length)
        : url.startsWith('/')
        ? url.substring(1)
        : url;

    final response = await apiClient.getJson(relative);
    return response.when(
      success: (value) {
        final jsonString = jsonEncode(value.body);
        return Result.success(Uint8List.fromList(utf8.encode(jsonString)));
      },
      failure: Result.failure,
    );
  }

  List<Map<String, dynamic>> _extractItemList(dynamic parsed) {
    if (parsed is List) {
      return parsed.cast<Map<String, dynamic>>();
    }
    if (parsed is Map<String, dynamic> && parsed['items'] is List) {
      return (parsed['items'] as List).cast<Map<String, dynamic>>();
    }
    return const [];
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
      ..learningGoal = map['learningGoal'] as String?
      ..contentVersion = version;
  }

  IsarPlant _parseIsarPlant(Map<String, dynamic> map, String version) {
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
            ..author = mediaMap['author'] as String?;
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
      ..releaseVersion = version
      ..media = mediaList;
  }
}
