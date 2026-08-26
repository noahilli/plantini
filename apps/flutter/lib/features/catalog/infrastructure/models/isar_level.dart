import 'package:isar/isar.dart';

part 'isar_level.g.dart';

/// Local Isar storage collection for cached level content.
@collection
class IsarLevel {
  Id id = Isar.autoIncrement;

  @Index(unique: true, replace: true)
  late String publicId;

  @Index()
  late String ecosystemId;

  late String title;
  late int sequence;

  @Enumerated(EnumType.name)
  late IsarLevelStatus status;

  late double minimumScore;
  late List<String> requiredQuizIds;
  late List<String> plantIds;
  String? learningGoal;
  double? progress;
  String? blockedReason;
  String contentVersion = 'v1';
}

/// Mirror of level status for local storage.
enum IsarLevelStatus {
  locked,
  available,
  inProgress,
  completed,
}
