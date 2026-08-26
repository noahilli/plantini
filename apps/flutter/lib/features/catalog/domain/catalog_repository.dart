import '../../../core/result.dart';
import 'catalog_models.dart';

abstract interface class CatalogRepository {
  Future<Result<List<Ecosystem>>> listPublishedEcosystems();
  Future<Result<LevelContent>> getPublishedLevel(String levelId);
  Future<Result<List<Level>>> listPublishedLevels(String ecosystemId);
}
