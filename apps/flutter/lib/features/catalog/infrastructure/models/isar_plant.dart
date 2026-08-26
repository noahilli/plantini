import 'package:isar/isar.dart';

part 'isar_plant.g.dart';

/// Local Isar storage collection for cached plant profiles.
@collection
class IsarPlant {
  Id id = Isar.autoIncrement;

  @Index(unique: true, replace: true)
  late String publicId;

  @Index()
  late String slug;

  late String scientificName;
  late String commonName;
  late String family;
  late String description;
  String? warning;
  late List<String> sources;
  late String releaseVersion;
  late List<IsarPlantMedia> media;
}

/// Embedded media metadata for an [IsarPlant].
@embedded
class IsarPlantMedia {
  late String publicId;
  String slug = '';
  late String url;
  late String altText;
  late String license;
  String? author;
}
