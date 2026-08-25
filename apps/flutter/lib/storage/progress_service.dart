import 'package:flutter/foundation.dart';
import 'package:isar/isar.dart';
import 'isar_collection.dart';

class ProgressService extends ChangeNotifier {
  final Isar isar;

  ProgressService(this.isar);

  Future<void> markQuizPassed(String quizId) async {
    final progress = await isar.quizProgress.filter().quizIdEqualTo(quizId).findFirst() 
      ?? QuizProgress()..quizId = quizId;
    
    progress.isPassed = true;
    progress.pausedStateJson = null;
    progress.lastUpdated = DateTime.now();

    await isar.writeTxn(() async {
      await isar.quizProgress.put(progress);
    });
    
    notifyListeners();
  }

  Future<void> saveQuizPausedState(String quizId, String stateJson) async {
    final progress = await isar.quizProgress.filter().quizIdEqualTo(quizId).findFirst()
      ?? QuizProgress()..quizId = quizId..isPassed = false;
    
    progress.pausedStateJson = stateJson;
    progress.lastUpdated = DateTime.now();

    await isar.writeTxn(() async {
      await isar.quizProgress.put(progress);
    });
  }

  Future<QuizProgress?> getQuizProgress(String quizId) async {
    return await isar.quizProgress.filter().quizIdEqualTo(quizId).findFirst();
  }

  Future<void> updateLevelProgress(String levelId, double percentage, bool isCompleted) async {
    final progress = await isar.levelProgress.filter().levelIdEqualTo(levelId).findFirst()
      ?? LevelProgress()..levelId = levelId;
    
    progress.progressPercentage = percentage;
    progress.isCompleted = isCompleted;
    progress.lastUpdated = DateTime.now();

    await isar.writeTxn(() async {
      await isar.levelProgress.put(progress);
    });
    
    notifyListeners();
  }
  
  Future<LevelProgress?> getLevelProgress(String levelId) async {
    return await isar.levelProgress.filter().levelIdEqualTo(levelId).findFirst();
  }
}
