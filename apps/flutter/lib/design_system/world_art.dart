/// Locally bundled, generated low-poly illustrations. These are game scenery,
/// never botanical identification photographs.
abstract final class WorldArt {
  static const forest = 'assets/worlds/forest.png';
  static const meadow = 'assets/worlds/meadow.png';
  static const alpine = 'assets/worlds/alpine.png';
  static const explorer = 'assets/worlds/explorer.png';

  static String forSlug(String slug) {
    final value = slug.toLowerCase();
    if (value.contains('alpen') ||
        value.contains('alpin') ||
        value.contains('berg') ||
        value.contains('mountain')) {
      return alpine;
    }
    if (value.contains('wiese') || value.contains('meadow')) return meadow;
    return forest;
  }
}
