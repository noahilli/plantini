import 'package:isar/isar.dart';

part 'isar_ecosystem.g.dart';

/// Local Isar storage collection for cached ecosystem content.
@collection
class IsarEcosystem {
  Id id = Isar.autoIncrement;

  @Index(unique: true, replace: true)
  late String publicId;

  late String slug;
  late String title;
  late String releaseVersion;
  late List<String> levelIds;
  String? description;
}
