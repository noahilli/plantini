import 'package:isar_plus/isar_plus.dart';

part 'isar_plant.g.dart';

/// Local Isar storage collection for cached plant profiles.
@collection
class IsarPlant {
  int id = 0;

  @Index(unique: true)
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
  late List<IsarPlantProfileCard> profileCards;
}

/// Embedded, additive profile content. Existing databases retain their plant
/// records; older records simply read this list as empty.
@embedded
class IsarPlantProfileCard {
  late String heading;
  late String text;
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
