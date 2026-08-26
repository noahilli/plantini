/// Central content and domain constants for Plantini Flutter client.
///
/// NOTE: Domain content (ecosystems, levels, species profiles, quiz questions)
/// is dynamically fetched from backend API and Strapi CMS.
/// Hardcoded domain content values in UI widgets are prohibited (see STATUS-07).
abstract final class ContentConstants {
  /// Default fallback text when no description is available.
  static const String defaultEcosystemDescription =
      'Veröffentlichte Lerninhalte';

  /// Default learning goal placeholder when not provided by backend.
  static const String defaultLearningGoal =
      'Lerne die Merkmale dieses Levels kennen.';

  /// Default text when plant description is missing.
  static const String defaultPlantDescription =
      'Keine Beschreibung vorhanden.';

  /// Minimum threshold score default for level completion (0.0 to 1.0).
  static const double defaultMinimumScore = 0.8;
}
