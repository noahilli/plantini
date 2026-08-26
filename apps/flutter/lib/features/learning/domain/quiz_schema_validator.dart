import '../../../core/errors/app_failure.dart';
import '../../../core/result.dart';
import 'learning_models.dart';

/// Validates the documented quiz extension point before it reaches a widget.
///
/// The current v1 contract cannot render flashcard backs or image media. Those
/// types therefore fail explicitly instead of being guessed from names or demo
/// URLs. Backend/content can add the fields through the contract process.
final class QuizSchemaValidator {
  const QuizSchemaValidator();

  Result<List<QuizItem>> validate(List<QuizItem> items) {
    for (final item in items) {
      if (item.id.isEmpty ||
          item.levelId.isEmpty ||
          item.contentVersion.isEmpty ||
          item.prompt.isEmpty) {
        return const Result.failure(
          ContractFailure(
            message: 'Ein Quiz-Element enthält unvollständige Pflichtfelder.',
            missingFields: ['id', 'levelId', 'contentVersion', 'prompt'],
          ),
        );
      }
      if (item.type == QuizItemType.flashcard) {
        return const Result.failure(
          ContractFailure(
            message:
                'Flashcards benötigen im Vertrag ein rückseitiges Lernfeld.',
            missingFields: ['flashcard.back'],
          ),
        );
      }
      if (item.type == QuizItemType.imageIdentification) {
        return const Result.failure(
          ContractFailure(
            message: 'Bilderkennungsfragen benötigen im Vertrag eine Medienreferenz mit Alt-Text.',
            missingFields: ['media.url', 'media.altText'],
          ),
        );
      }
      if (item.choices.isEmpty) {
        return Result.failure(
          ContractFailure(
            message: 'Die Quizfrage benötigt auswählbare Antworten.',
            missingFields: ['choices'],
          ),
        );
      }
      if (item.choices.any(
        (choice) => choice.id.isEmpty || choice.label.isEmpty,
      )) {
        return const Result.failure(
          ContractFailure(
            message:
                'Eine Quizantwort enthält keine stabile ID oder Beschriftung.',
            missingFields: ['choices[].id', 'choices[].label'],
          ),
        );
      }
    }
    return Result.success(items);
  }
}
