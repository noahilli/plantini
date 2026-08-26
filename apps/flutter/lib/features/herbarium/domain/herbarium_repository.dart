import '../../../core/result.dart';
import 'herbarium_models.dart';

/// Contract for herbarium data storage and synchronization.
abstract interface class HerbariumRepository {
  Future<Result<List<HerbariumEntry>>> listEntries({
    int page = 1,
    int pageSize = 20,
  });

  Future<Result<HerbariumEntry>> getEntry(String id);

  Future<Result<HerbariumEntry>> createEntry({
    required String clientObservationId,
    required DateTime observedAt,
    String? note,
    String? mediaId,
    String? identificationJobId,
    required String idempotencyKey,
  });

  Future<Result<void>> deleteEntry({
    required String id,
    required String ifMatchVersion,
  });

  Future<Result<List<HerbariumEntry>>> syncEntries();
}
