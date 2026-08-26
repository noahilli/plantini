import '../../../core/result.dart';
import 'field_models.dart';

/// Contract for field observations and plant identification service.
abstract interface class FieldRepository {
  Future<Result<MediaUpload>> reserveMediaUpload({
    required String clientMediaId,
    required String contentType,
    required int bytes,
    required String idempotencyKey,
  });

  Future<Result<MediaUpload>> uploadMediaContent({
    required String mediaId,
    required List<int> bytes,
    required String contentType,
    required String filename,
  });

  Future<Result<IdentificationJob>> submitObservation({
    required String clientJobId,
    required String mediaId,
    String? expectedPlantId,
    required String idempotencyKey,
  });

  Future<Result<IdentificationJob>> getIdentification(String jobId);

  Future<Result<IdentificationJob>> confirmIdentification({
    required String jobId,
    String? candidateId,
    String? confirmedPlantId,
  });
}
