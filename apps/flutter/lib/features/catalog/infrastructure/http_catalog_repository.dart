import '../../../adapters/http/platform_api_client.dart';
import '../../../core/result.dart';
import '../domain/catalog_models.dart';
import '../domain/catalog_repository.dart';
import 'catalog_dto.dart';

final class HttpCatalogRepository implements CatalogRepository {
  const HttpCatalogRepository(this._client);

  final PlatformApiClient _client;

  @override
  Future<Result<List<Ecosystem>>> listPublishedEcosystems() async {
    final response = await _client.getJson('ecosystems');
    return response.when(
      success: (value) => CatalogDto.ecosystemsFromEnvelope(value.body),
      failure: Result.failure,
    );
  }

  @override
  Future<Result<List<Level>>> listPublishedLevels(String ecosystemId) async {
    final ecosystemResponse = await _client.getJson('ecosystems/$ecosystemId');
    if (ecosystemResponse case Failure<ApiJsonResponse>(:final failure)) {
      return Result.failure(failure);
    }
    final ecosystem = CatalogDto.ecosystemFromJson(
      (ecosystemResponse as Success<ApiJsonResponse>).value.body,
    );
    if (ecosystem case Failure<Ecosystem>(:final failure)) {
      return Result.failure(failure);
    }
    final result = (ecosystem as Success<Ecosystem>).value;
    final levelResults = await Future.wait(
      result.levelIds.map((id) async {
        final response = await _client.getJson(
          'levels/$id',
          requiresAuthentication: true,
        );
        return response.when(
          success: (value) => CatalogDto.levelFromJson(value.body),
          failure: Result.failure,
        );
      }),
    );
    final levels = <Level>[];
    for (final level in levelResults) {
      if (level case Failure<Level>(:final failure)) {
        return Result.failure(failure);
      }
      levels.add((level as Success<Level>).value);
    }
    levels.sort((left, right) => left.sequence.compareTo(right.sequence));
    return Result.success(levels);
  }

  @override
  Future<Result<LevelContent>> getPublishedLevel(String levelId) async {
    final responses = await Future.wait([
      _client.getJson('levels/$levelId', requiresAuthentication: true),
      _client.getJson('content/manifest'),
    ]);
    final levelResponse = responses[0];
    final manifestResponse = responses[1];
    if (levelResponse case Failure<ApiJsonResponse>(:final failure)) {
      return Result.failure(failure);
    }
    if (manifestResponse case Failure<ApiJsonResponse>(:final failure)) {
      return Result.failure(failure);
    }
    final level = CatalogDto.levelFromJson(
      (levelResponse as Success<ApiJsonResponse>).value.body,
    );
    if (level case Failure<Level>(:final failure)) {
      return Result.failure(failure);
    }
    final contentVersion = CatalogDto.manifestVersionFromJson(
      (manifestResponse as Success<ApiJsonResponse>).value.body,
    );
    if (contentVersion case Failure<String>(:final failure)) {
      return Result.failure(failure);
    }
    return Result.success(
      LevelContent(
        level: (level as Success<Level>).value,
        contentVersion: (contentVersion as Success<String>).value,
      ),
    );
  }

  @override
  Future<Result<Plant>> getPublishedPlant(String plantId) async {
    final response = await _client.getJson('plants/$plantId');
    return response.when(
      success: (value) => CatalogDto.plantFromJson(value.body),
      failure: Result.failure,
    );
  }
}
