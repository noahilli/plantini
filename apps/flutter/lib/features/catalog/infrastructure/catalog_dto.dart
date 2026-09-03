import '../../../core/errors/app_failure.dart';
import '../../../core/result.dart';
import '../domain/catalog_models.dart';

/// Isolated `/api/v1` DTO mappers.
///
/// The API owner still has to pin these fields in OpenAPI. Missing values are
/// surfaced as [ContractFailure]; no content is manufactured in the client.
final class CatalogDto {
  const CatalogDto._();

  static Result<List<Ecosystem>> ecosystemsFromEnvelope(
    Map<String, dynamic> body,
  ) {
    final items = body['items'];
    if (items is! List) {
      return const Result.failure(
        ContractFailure(
          message: 'GET /ecosystems benötigt ein items-Array.',
          missingFields: ['items'],
        ),
      );
    }
    final ecosystems = <Ecosystem>[];
    for (var index = 0; index < items.length; index++) {
      final item = items[index];
      if (item is! Map<String, dynamic>) {
        return Result.failure(
          ContractFailure(
            message: 'GET /ecosystems enthält ein ungültiges Element.',
            missingFields: ['items[$index] object'],
          ),
        );
      }
      final result = ecosystemFromJson(item);
      if (result case Failure<Ecosystem>(:final failure)) {
        return Result.failure(failure);
      }
      ecosystems.add((result as Success<Ecosystem>).value);
    }
    return Result.success(ecosystems);
  }

  static Result<Ecosystem> ecosystemFromJson(Map<String, dynamic> json) {
    final fields = _requiredStrings(json, const [
      'id',
      'slug',
      'name',
      'releaseVersion',
    ]);
    if (fields case Failure<Map<String, String>>(:final failure)) {
      return Result.failure(failure);
    }
    final values = (fields as Success<Map<String, String>>).value;
    return Result.success(
      Ecosystem(
        id: values['id']!,
        slug: values['slug']!,
        title: values['name']!,
        releaseVersion: values['releaseVersion']!,
        levelIds: _stringList(json, 'levelIds'),
        description: _optionalString(json, 'description'),
      ),
    );
  }

  static Result<Level> levelFromJson(Map<String, dynamic> json) {
    final fields = _requiredStrings(json, const ['id', 'ecosystemId', 'title']);
    if (fields case Failure<Map<String, String>>(:final failure)) {
      return Result.failure(failure);
    }
    final values = (fields as Success<Map<String, String>>).value;
    final sequence = json['sequence'];
    final status = _levelStatus(json['status']);
    final completionRule = json['completionRule'];
    if (sequence is! int ||
        status == null ||
        completionRule is! Map<String, dynamic>) {
      return const Result.failure(
        ContractFailure(
          message: 'Level benötigt sequence, status und completionRule.',
          missingFields: ['sequence', 'status', 'completionRule'],
        ),
      );
    }
    final minimumScore = completionRule['minimumScore'];
    if (minimumScore is! num) {
      return const Result.failure(
        ContractFailure(
          message: 'completionRule benötigt minimumScore.',
          missingFields: ['completionRule.minimumScore'],
        ),
      );
    }
    final progress = json['progress'];
    if (progress != null && progress is! num) {
      return const Result.failure(
        ContractFailure(
          message: 'Level progress muss eine Zahl sein.',
          missingFields: ['progress'],
        ),
      );
    }
    return Result.success(
      Level(
        id: values['id']!,
        ecosystemId: values['ecosystemId']!,
        title: values['title']!,
        sequence: sequence,
        status: status,
        minimumScore: minimumScore.toDouble(),
        requiredQuizIds: _stringList(completionRule, 'requiredQuizIds'),
        plantIds: _stringList(json, 'plantIds'),
        requiredPlantIds: _stringList(completionRule, 'requiredPlantIds'),
        learningGoal: _optionalString(json, 'learningGoal'),
        progress: progress?.toDouble(),
        blockedReason: _optionalString(json, 'blockedReason'),
      ),
    );
  }

  static Result<String> manifestVersionFromJson(Map<String, dynamic> json) {
    final fields = _requiredStrings(json, const ['version']);
    return fields.when(
      success: (values) => Result.success(values['version']!),
      failure: Result.failure,
    );
  }

  static Result<Plant> plantFromJson(Map<String, dynamic> json) {
    final fields = _requiredStrings(json, const [
      'id',
      'scientificName',
      'releaseVersion',
    ]);
    if (fields case Failure<Map<String, String>>(:final failure)) {
      return Result.failure(failure);
    }
    final values = (fields as Success<Map<String, String>>).value;
    final commonName =
        _optionalString(json, 'commonName') ?? values['scientificName']!;
    return Result.success(
      Plant(
        id: values['id']!,
        slug: values['id']!,
        scientificName: values['scientificName']!,
        commonName: commonName,
        family: _optionalString(json, 'family') ?? '',
        description: _optionalString(json, 'description') ?? '',
        warning: _optionalString(json, 'warning'),
        sources: _stringList(json, 'sources'),
        releaseVersion: values['releaseVersion']!,
      ),
    );
  }

  static Result<Map<String, String>> _requiredStrings(
    Map<String, dynamic> json,
    List<String> keys,
  ) {
    final missing = <String>[];
    final values = <String, String>{};
    for (final key in keys) {
      final value = json[key];
      if (value is! String || value.trim().isEmpty) {
        missing.add(key);
      } else {
        values[key] = value.trim();
      }
    }
    if (missing.isNotEmpty) {
      return Result.failure(
        ContractFailure(
          message: 'Die API-Antwort enthält Pflichtfelder nicht vollständig.',
          missingFields: missing,
        ),
      );
    }
    return Result.success(values);
  }

  static String? _optionalString(Map<String, dynamic> json, String key) {
    final value = json[key];
    return value is String && value.trim().isNotEmpty ? value.trim() : null;
  }

  static List<String> _stringList(Map<String, dynamic> json, String key) {
    final values = json[key];
    if (values == null) return const [];
    if (values is! List ||
        values.any((value) => value is! String || value.isEmpty)) {
      throw const ContractFailure(
        message: 'Eine API-Liste enthält keinen gültigen Stringwert.',
        missingFields: ['list of strings'],
      );
    }
    return values.cast<String>();
  }

  static LevelStatus? _levelStatus(Object? value) => switch (value) {
    'locked' => LevelStatus.locked,
    'available' => LevelStatus.available,
    'in_progress' => LevelStatus.inProgress,
    'completed' => LevelStatus.completed,
    _ => null,
  };
}
