import '../../../adapters/http/platform_api_client.dart';
import '../../../core/errors/app_failure.dart';
import '../../../core/result.dart';
import '../domain/collection_insights.dart';
import '../domain/insight_repository.dart';

/// Reads the server's cached species cards and collection shares. Both change
/// slowly, so results are kept in memory for a few minutes.
final class HttpInsightRepository implements InsightRepository {
  HttpInsightRepository(
    this._client, {
    DateTime Function()? now,
    this.statsTtl = const Duration(minutes: 10),
  }) : _now = now ?? DateTime.now;

  final PlatformApiClient _client;
  final DateTime Function() _now;
  final Duration statsTtl;

  CollectionStats? _stats;
  DateTime? _statsAt;
  final _cards = <String, SpeciesCard>{};

  @override
  Future<Result<CollectionStats>> collectionStats() async {
    final cached = _stats;
    final at = _statsAt;
    if (cached != null && at != null && _now().difference(at) < statsTtl) {
      return Result.success(cached);
    }
    final response = await _client.getJson(
      'stats/collection',
      requiresAuthentication: true,
    );
    return response.when(
      success: (value) {
        final stats = _parseStats(value.body);
        _stats = stats;
        _statsAt = _now();
        return Result.success(stats);
      },
      failure: Result.failure,
    );
  }

  @override
  Future<Result<SpeciesCard>> speciesCard(String key) async {
    final cached = _cards[key];
    if (cached != null) return Result.success(cached);
    final response = await _client.getJson(
      'species/${Uri.encodeComponent(key)}',
      requiresAuthentication: true,
    );
    return response.when(
      success: (value) {
        final card = _parseCard(value.body);
        if (card == null) {
          return Result.failure(
            const ContractFailure(
              message: 'Die Artkarte ist unvollständig.',
              missingFields: ['key', 'scientificName'],
            ),
          );
        }
        _cards[key] = card;
        return Result.success(card);
      },
      failure: Result.failure,
    );
  }
}

CollectionStats _parseStats(Map<String, dynamic> body) {
  if (body['available'] != true) return CollectionStats.unavailable;
  Map<String, CollectionShare> shares(Object? raw) {
    if (raw is! Map) return const {};
    final result = <String, CollectionShare>{};
    for (final entry in raw.entries) {
      final value = entry.value;
      if (entry.key is! String || value is! Map) continue;
      final share = value['share'];
      final label = value['label'];
      if (share is num && label is String) {
        result[entry.key as String] = CollectionShare(
          share: share.toDouble(),
          label: label,
        );
      }
    }
    return result;
  }

  return CollectionStats(
    available: true,
    plants: shares(body['plants']),
    species: shares(body['species']),
  );
}

SpeciesCard? _parseCard(Map<String, dynamic> body) {
  final key = body['key'];
  final scientificName = body['scientificName'];
  if (key is! String || scientificName is! String) return null;
  final photo = body['photo'];
  String? attribution;
  String? photoUrl;
  if (photo is Map) {
    photoUrl = photo['url'] as String?;
    final author = photo['author'] as String?;
    final license = photo['license'] as String?;
    attribution = [
      if (author != null && author.isNotEmpty) author,
      if (license != null && license.isNotEmpty) license.toUpperCase(),
    ].join(' · ');
    if (attribution.isEmpty) attribution = null;
  }
  return SpeciesCard(
    key: key,
    scientificName: scientificName,
    commonName: body['commonName'] as String?,
    summary: body['summary'] as String?,
    summarySource: body['summarySource'] as String?,
    photoUrl: photoUrl,
    photoAttribution: attribution,
  );
}
