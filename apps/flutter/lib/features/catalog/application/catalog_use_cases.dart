import '../../../core/result.dart';
import '../domain/catalog_models.dart';
import '../domain/catalog_repository.dart';

final class LoadPublishedEcosystems {
  const LoadPublishedEcosystems(this._repository);

  final CatalogRepository _repository;

  Future<Result<List<Ecosystem>>> call() =>
      _repository.listPublishedEcosystems();
}

final class LoadPublishedLevels {
  const LoadPublishedLevels(this._repository);

  final CatalogRepository _repository;

  Future<Result<List<Level>>> call(String ecosystemId) =>
      _repository.listPublishedLevels(ecosystemId);
}

final class LoadPublishedLevel {
  const LoadPublishedLevel(this._repository);

  final CatalogRepository _repository;

  Future<Result<LevelContent>> call(String levelId) =>
      _repository.getPublishedLevel(levelId);
}

final class LoadPublishedPlant {
  const LoadPublishedPlant(this._repository);

  final CatalogRepository _repository;

  Future<Result<Plant>> call(String plantId) =>
      _repository.getPublishedPlant(plantId);
}
