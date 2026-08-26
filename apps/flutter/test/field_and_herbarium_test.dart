import 'package:flutter_test/flutter_test.dart';
import 'package:plantini_app/core/result.dart';
import 'package:plantini_app/features/field/application/field_use_cases.dart';
import 'package:plantini_app/features/field/domain/field_models.dart';
import 'package:plantini_app/features/field/domain/field_repository.dart';
import 'package:plantini_app/features/herbarium/application/herbarium_use_cases.dart';
import 'package:plantini_app/features/herbarium/domain/herbarium_models.dart';
import 'package:plantini_app/features/herbarium/domain/herbarium_repository.dart';

final class MockFieldRepository implements FieldRepository {
  IdentificationJob? jobToReturn;

  @override
  Future<Result<IdentificationJob>> submitObservation({
    required String clientJobId,
    required String mediaId,
    String? expectedPlantId,
    required String idempotencyKey,
  }) async {
    return Result.success(
      jobToReturn ??
          IdentificationJob(
            id: 'job-123',
            status: 'pending',
            createdAt: DateTime.parse('2026-08-26T12:00:00.000Z'),
          ),
    );
  }

  @override
  Future<Result<IdentificationJob>> getIdentification(String jobId) async {
    return Result.success(
      jobToReturn ??
          IdentificationJob(
            id: jobId,
            status: 'identified',
            createdAt: DateTime.parse('2026-08-26T12:00:00.000Z'),
            candidates: const [
              IdentificationCandidate(
                scientificName: 'Bellis perennis',
                commonName: 'Gänseblümchen',
                score: 0.95,
              ),
            ],
          ),
    );
  }

  @override
  Future<Result<IdentificationJob>> confirmIdentification({
    required String jobId,
    required String confirmedPlantId,
  }) async {
    return Result.success(
      IdentificationJob(
        id: jobId,
        status: 'identified',
        createdAt: DateTime.parse('2026-08-26T12:00:00.000Z'),
        confirmedPlantId: confirmedPlantId,
      ),
    );
  }
}

final class MockHerbariumRepository implements HerbariumRepository {
  final List<HerbariumEntry> entries = [];

  @override
  Future<Result<List<HerbariumEntry>>> listEntries({
    int page = 1,
    int pageSize = 20,
  }) async {
    return Result.success(entries);
  }

  @override
  Future<Result<HerbariumEntry>> getEntry(String id) async {
    final entry = entries.firstWhere((e) => e.id == id);
    return Result.success(entry);
  }

  @override
  Future<Result<HerbariumEntry>> createEntry({
    required String clientObservationId,
    required DateTime observedAt,
    String? note,
    String? mediaId,
    String? mediaUrl,
    String? plantName,
    String? scientificName,
    String? identificationResult,
    String? identificationJobId,
    required String idempotencyKey,
  }) async {
    final entry = HerbariumEntry(
      id: 'entry-new',
      observedAt: observedAt,
      note: note ?? '',
      mediaUrl: mediaUrl,
      plantName: plantName,
      scientificName: scientificName,
      identificationResult: identificationResult,
      identificationJobId: identificationJobId,
      version: 'v1',
      syncStatus: SyncStatus.synced,
    );
    entries.add(entry);
    return Result.success(entry);
  }

  @override
  Future<Result<void>> deleteEntry({
    required String id,
    required String ifMatchVersion,
  }) async {
    entries.removeWhere((e) => e.id == id);
    return const Result.success(null);
  }

  @override
  Future<Result<List<HerbariumEntry>>> syncEntries() async {
    return Result.success(entries);
  }
}

void main() {
  group('Field Use Cases', () {
    test('SubmitObservation delegates to repository', () async {
      final repo = MockFieldRepository();
      final submitUseCase = SubmitObservation(repo);

      final result = await submitUseCase(
        clientJobId: 'client-job-1',
        mediaId: 'media-1',
        idempotencyKey: 'key-1',
      );

      expect(result.isSuccess, isTrue);
      final job = (result as Success<IdentificationJob>).value;
      expect(job.id, 'job-123');
      expect(job.status, 'pending');
    });

    test('GetIdentificationStatus delegates to repository', () async {
      final repo = MockFieldRepository();
      final getStatusUseCase = GetIdentificationStatus(repo);

      final result = await getStatusUseCase('job-123');

      expect(result.isSuccess, isTrue);
      final job = (result as Success<IdentificationJob>).value;
      expect(job.id, 'job-123');
      expect(job.candidates.first.scientificName, 'Bellis perennis');
    });
  });

  group('Herbarium Use Cases', () {
    test('ListHerbarium, DeleteEntry, and SyncEntries perform correctly', () async {
      final repo = MockHerbariumRepository();
      final entry = HerbariumEntry(
        id: 'entry-1',
        observedAt: DateTime.parse('2026-08-26T10:00:00.000Z'),
        note: 'Gefunden im Park',
        confirmedPlantId: 'plant-1',
        version: 'v1',
        syncStatus: SyncStatus.synced,
      );
      repo.entries.add(entry);

      final listUseCase = ListHerbarium(repo);
      final listResult = await listUseCase();
      expect(listResult.isSuccess, isTrue);
      expect((listResult as Success<List<HerbariumEntry>>).value.length, 1);

      final syncUseCase = SyncEntries(repo);
      final syncResult = await syncUseCase();
      expect(syncResult.isSuccess, isTrue);

      final deleteUseCase = DeleteEntry(repo);
      final deleteResult = await deleteUseCase(id: 'entry-1', ifMatchVersion: 'v1');
      expect(deleteResult.isSuccess, isTrue);
      expect(repo.entries, isEmpty);
    });
  });
}
