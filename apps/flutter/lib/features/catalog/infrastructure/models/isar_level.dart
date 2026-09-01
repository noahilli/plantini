import 'package:isar_plus/isar_plus.dart';

part 'isar_level.g.dart';

/// Local Isar storage collection for cached level content.
@collection
class IsarLevel {
  int id = 0;

  @Index(unique: true)
  late String publicId;

  @Index()
  late String ecosystemId;

  late String title;
  late int sequence;

  late IsarLevelStatus status;

  late double minimumScore;
  late List<String> requiredQuizIds;
  late List<String> plantIds;
  List<String> requiredPlantIds = [];
  String? learningGoal;
  double? progress;
  String? blockedReason;
  String contentVersion = 'v1';
}

/// Mirror of level status for local storage.
enum IsarLevelStatus { locked, available, inProgress, completed }
