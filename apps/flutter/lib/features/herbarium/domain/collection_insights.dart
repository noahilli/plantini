/// Share of all accounts that have collected one plant or species.
final class CollectionShare {
  const CollectionShare({required this.share, required this.label});

  final double share;

  /// Formatted by the server: "12 %", or per mille below one percent ("3 ‰").
  final String label;
}

/// Aggregated collection shares. [available] is false while too few accounts
/// exist for a share to be published without singling anyone out.
final class CollectionStats {
  const CollectionStats({
    required this.available,
    this.plants = const {},
    this.species = const {},
  });

  static const unavailable = CollectionStats(available: false);

  final bool available;
  final Map<String, CollectionShare> plants;
  final Map<String, CollectionShare> species;

  /// A sentence for the plant / species, or null if nothing may be said yet.
  /// A plant missing from the published shares has not been collected by anyone.
  String? sentenceFor({String? plantId, String? speciesKey}) {
    if (!available) return null;
    final share = plantId != null ? plants[plantId] : species[speciesKey];
    if (share == null) return 'Noch niemand sonst hat diese Art gesammelt.';
    return '${share.label} der Nutzer*innen haben diese Art gesammelt.';
  }
}

/// Info card of a species found by users; shown in the herbarium only, never
/// in an ecosystem.
final class SpeciesCard {
  const SpeciesCard({
    required this.key,
    required this.scientificName,
    this.commonName,
    this.summary,
    this.summarySource,
    this.photoUrl,
    this.photoAttribution,
  });

  final String key;
  final String scientificName;
  final String? commonName;
  final String? summary;
  final String? summarySource;
  final String? photoUrl;

  /// "Author · licence", shown below the photo.
  final String? photoAttribution;
}
