import '../../../core/result.dart';
import 'collection_insights.dart';

abstract interface class InsightRepository {
  /// Shares of accounts that collected each plant / species (cached briefly).
  Future<Result<CollectionStats>> collectionStats();

  Future<Result<SpeciesCard>> speciesCard(String key);
}
