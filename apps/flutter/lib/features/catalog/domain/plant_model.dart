/// Immutable published plant content models.
final class Plant {
  const Plant({
    required this.id,
    required this.slug,
    required this.scientificName,
    required this.commonName,
    required this.family,
    required this.description,
    this.warning,
    this.sources = const [],
    this.profileCards = const [],
    required this.releaseVersion,
    this.media = const [],
  });

  final String id;
  final String slug;
  final String scientificName;
  final String commonName;
  final String family;
  final String description;
  final String? warning;
  final List<String> sources;
  final List<PlantProfileCard> profileCards;
  final String releaseVersion;
  final List<PlantMedia> media;
}

/// A readable, published field-note section. It deliberately contains no quiz
/// solution data, so the plant profile stays a learning aid rather than an
/// answer key.
final class PlantProfileCard {
  const PlantProfileCard({required this.heading, required this.text});

  final String heading;
  final String text;
}

final class PlantMedia {
  const PlantMedia({
    required this.id,
    this.slug = '',
    required this.url,
    required this.altText,
    required this.license,
    this.author,
  });

  final String id;
  final String slug;
  final String url;
  final String altText;
  final String license;
  final String? author;
}
