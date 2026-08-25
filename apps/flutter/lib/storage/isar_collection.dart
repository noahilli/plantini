import 'package:isar/isar.dart';

part 'isar_collection.g.dart';

@collection
class Plant {
  Id id = Isar.autoIncrement;

  String? name;
  String? species;
  DateTime? lastSeen;
}

@collection
class QuizProgress {
  Id id = Isar.autoIncrement;

  @Index(unique: true, replace: true)
  late String quizId;

  late bool isPassed;

  /// Optionally store the state to resume later if interrupted
  String? pausedStateJson;

  late DateTime lastUpdated;
}

@collection
class LevelProgress {
  Id id = Isar.autoIncrement;

  @Index(unique: true, replace: true)
  late String levelId;

  late bool isCompleted;
  
  late double progressPercentage;
  
  late DateTime lastUpdated;
}

@collection
class OfflineObservation {
  Id id = Isar.autoIncrement;

  late String imagePath;
  late String organ;
  
  double? latitude;
  double? longitude;
  String? notes;
  
  late DateTime capturedAt;
  bool isSynced = false;
}

