export 'plant_model.dart';

/// Immutable published-content models. They deliberately contain no transport
/// or persistence annotations.
final class Ecosystem {
  const Ecosystem({
    required this.id,
    required this.slug,
    required this.title,
    required this.releaseVersion,
    required this.levelIds,
    this.description,
  });

  final String id;
  final String slug;
  final String title;
  final String releaseVersion;
  final List<String> levelIds;
  final String? description;
}

final class Level {
  const Level({
    required this.id,
    required this.ecosystemId,
    required this.title,
    required this.sequence,
    required this.status,
    required this.minimumScore,
    required this.requiredQuizIds,
    required this.plantIds,
    this.learningGoal,
    this.progress,
    this.blockedReason,
  });

  final String id;
  final String ecosystemId;
  final String title;
  final int sequence;
  final LevelStatus status;
  final double minimumScore;
  final List<String> requiredQuizIds;
  final List<String> plantIds;
  final String? learningGoal;
  final double? progress;
  final String? blockedReason;

  bool get isUnlocked => status != LevelStatus.locked;
}

enum LevelStatus { locked, available, inProgress, completed }

final class LearningUnit {
  const LearningUnit({
    required this.id,
    required this.levelId,
    required this.contentVersion,
    required this.title,
    required this.body,
    required this.learningGoal,
    this.imageUrl,
    this.imageAltText,
    this.safetyNotice,
  });

  final String id;
  final String levelId;
  final String contentVersion;
  final String title;
  final String body;
  final String learningGoal;
  final Uri? imageUrl;
  final String? imageAltText;
  final String? safetyNotice;
}

final class LevelContent {
  const LevelContent({required this.level, required this.contentVersion});

  final Level level;
  final String contentVersion;
}
