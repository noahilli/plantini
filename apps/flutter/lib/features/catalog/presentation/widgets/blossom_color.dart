import 'package:flutter/material.dart';

import '../../domain/plant_model.dart';

/// Blossom colour families named by the published plant text.
///
/// The card tint is decorative. The family only steers which hues of the
/// photo are sampled; it is read from the editorial profile ("weiße Blüte",
/// "violette Zungenblüten"), never invented from a plant name or a photo.
enum BlossomHue {
  white(Color(0xFFF7F5E9)),
  yellow(Color(0xFFE8C547)),
  orange(Color(0xFFE59A4A)),
  red(Color(0xFFD95B4A)),
  pink(Color(0xFFE79DB8)),
  purple(Color(0xFFB05C9A)),
  violet(Color(0xFF8C78C8)),
  blue(Color(0xFF6F92D8));

  const BlossomHue(this.fallback);

  /// Used when the photo shows no pixel of this family.
  final Color fallback;

  /// HSV hue window (degrees) in which petals of this family are sampled.
  bool containsHue(double hue) => switch (this) {
    BlossomHue.white => false,
    BlossomHue.yellow => hue >= 38 && hue <= 72,
    BlossomHue.orange => hue >= 12 && hue <= 46,
    BlossomHue.red => hue >= 344 || hue <= 14,
    BlossomHue.pink => hue >= 318 && hue <= 352,
    BlossomHue.purple => hue >= 285 && hue <= 335,
    BlossomHue.violet => hue >= 242 && hue <= 292,
    BlossomHue.blue => hue >= 196 && hue <= 250,
  };
}

// Longer, more specific words come first: at one position the first
// alternative wins ("purpurrosa" is pink, "blauviolett" is violet).
final _colorWord = RegExp(
  r'(?<![a-zäöüß])(?:'
  r'(?<white>silberweiß\w*|weißlich\w*|weiß\w*)|'
  r'(?<pink>purpurrosa\w*|rosarot\w*|rosa\w*)|'
  r'(?<violet>blauviolett\w*|violett\w*|lila\w*)|'
  r'(?<purple>purpur\w*)|'
  r'(?<blue>tiefblau\w*|blau\w*)|'
  r'(?<yellow>gelb\w*)|'
  r'(?<orange>orange\w*)|'
  r'(?<red>rot\w*)'
  r')',
  caseSensitive: false,
);

final _blossomNoun = RegExp(
  r'blüt|blume|blumen|krone|glocke|trichter|köpfchen|blütenkorb|blütenkörb',
  caseSensitive: false,
);

/// The blossom colour family the profile names first, or null if it names
/// none (ferns, plantains, trees). Sentences that do not talk about blossoms
/// are ignored, so "rote Früchte" or "weißgraue Rinde" do not count.
BlossomHue? blossomHueOf(Plant plant) {
  final text = [
    plant.description,
    for (final card in plant.profileCards) '${card.heading}. ${card.text}',
  ].join(' ');
  for (final sentence in text.split(RegExp(r'(?<=[.!?])\s+'))) {
    if (!_blossomNoun.hasMatch(sentence)) continue;
    final match = _colorWord.firstMatch(sentence);
    if (match == null) continue;
    for (final hue in BlossomHue.values) {
      if (match.namedGroup(hue.name) != null) return hue;
    }
  }
  return null;
}
