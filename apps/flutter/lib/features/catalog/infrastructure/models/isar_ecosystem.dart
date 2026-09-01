import 'package:isar_plus/isar_plus.dart';

part 'isar_ecosystem.g.dart';

/// Local Isar storage collection for cached ecosystem content.
@collection
class IsarEcosystem {
  int id = 0;

  @Index(unique: true)
  late String publicId;

  late String slug;
  late String title;
  late String releaseVersion;
  late List<String> levelIds;
  String? description;
}
