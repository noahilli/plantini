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
  final String releaseVersion;
  final List<PlantMedia> media;
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
