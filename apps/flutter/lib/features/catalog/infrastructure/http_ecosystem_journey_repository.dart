import '../../../adapters/http/platform_api_client.dart';
import '../../../core/errors/app_failure.dart';
import '../../../core/result.dart';
import '../domain/ecosystem_journey.dart';

final class HttpEcosystemJourneyRepository
    implements EcosystemJourneyRepository {
  const HttpEcosystemJourneyRepository(this._client);
  final PlatformApiClient _client;
  @override
  Future<Result<EcosystemJourney>> getProgress(String ecosystemId) async {
    final response = await _client.getJson(
      'ecosystems/$ecosystemId/progress',
      requiresAuthentication: true,
    );
    if (response case Failure<ApiJsonResponse>(:final failure)) {
      return Result.failure(failure);
    }
    try {
      final json = (response as Success<ApiJsonResponse>).value.body;
      List<String> ids(String key) {
        final value = json[key];
        if (value is! List || value.any((id) => id is! String || id.isEmpty)) {
          throw const FormatException();
        }
        final values = value.cast<String>();
        if (values.toSet().length != values.length) {
          throw const FormatException();
        }
        return values;
      }

      final completedIds = ids('completedLevelIds').toSet();
      final targets = ids('requiredPlantIds');
      final collected = ids('collectedPlantIds').toSet();
      final total = json['totalLevels'];
      final completed = json['completed'];
      if (json['ecosystemId'] != ecosystemId ||
          total is! int ||
          total <= 0 ||
          completed is! bool ||
          completedIds.length > total ||
          !collected.every(targets.contains) ||
          (completed &&
              (completedIds.length != total ||
                  collected.length != targets.length))) {
        throw const FormatException();
      }
      return Result.success(
        EcosystemJourney(
          ecosystemId: ecosystemId,
          completed: completed,
          totalLevels: total,
          completedLevelIds: completedIds,
          requiredPlantIds: targets,
          collectedPlantIds: collected,
        ),
      );
    } catch (_) {
      return const Result.failure(
        ContractFailure(
          message: 'Der Ökosystem-Abschluss konnte nicht zuverlässig geprüft werden.',
          missingFields: ['ecosystem progress'],
        ),
      );
    }
  }
}
