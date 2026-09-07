import '../../../core/result.dart';

/// The API checks both the quiz journey and the unique confirmed target species.
final class EcosystemJourney {
  const EcosystemJourney({
    required this.ecosystemId,
    required this.completed,
    required this.totalLevels,
    required this.completedLevelIds,
    required this.requiredPlantIds,
    required this.collectedPlantIds,
  });
  final String ecosystemId;
  final bool completed;
  final int totalLevels;
  final Set<String> completedLevelIds;
  final List<String> requiredPlantIds;
  final Set<String> collectedPlantIds;
}

abstract interface class EcosystemJourneyRepository {
  Future<Result<EcosystemJourney>> getProgress(String ecosystemId);
}
