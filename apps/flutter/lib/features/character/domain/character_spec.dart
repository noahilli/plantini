import 'dart:math' as math;

import 'package:flutter/painting.dart';

enum CharacterGender {
  female('Weiblich'),
  male('Männlich'),
  diverse('Divers');

  const CharacterGender(this.label);
  final String label;
}

/// One choice for a part: a style of the character kit and, unless the style
/// is [none], the colour it is tinted with.
final class PartChoice {
  const PartChoice(this.style, [this.color]);

  static const none = PartChoice('none');

  final String style;
  final Color? color;

  bool get isNone => style == 'none';

  PartChoice withColor(Color value) => PartChoice(style, value);

  @override
  bool operator ==(Object other) =>
      other is PartChoice && other.style == style && other.color == color;

  @override
  int get hashCode => Object.hash(style, color);
}

/// The player's avatar: which part of each kind, in which colour. It is stored
/// as a small JSON record (see the API's `Character`) and assembled from the
/// character kit by `CharacterKit`.
final class CharacterSpec {
  const CharacterSpec({
    required this.gender,
    required this.skin,
    required this.hair,
    required this.hat,
    required this.glasses,
    required this.top,
    required this.bottom,
    required this.shoes,
    required this.backpack,
  });

  static const version = 1;

  final CharacterGender gender;
  final Color skin;
  final PartChoice hair, hat, glasses, top, bottom, shoes, backpack;

  factory CharacterSpec.starter() => CharacterSpec(
    gender: CharacterGender.diverse,
    skin: CharacterOptions.skins[2].color,
    hair: PartChoice('short', CharacterOptions.hairColors[1].color),
    hat: PartChoice.none,
    glasses: PartChoice.none,
    top: PartChoice('tshirt', CharacterOptions.clothes[0].color),
    bottom: PartChoice('trousers', CharacterOptions.clothes[9].color),
    shoes: PartChoice('sneakers', CharacterOptions.clothes[8].color),
    backpack: PartChoice('rucksack', CharacterOptions.clothes[3].color),
  );

  factory CharacterSpec.random(math.Random random) {
    T pick<T>(List<T> items) => items[random.nextInt(items.length)];
    PartChoice choice(
      String part,
      List<NamedColor> colors, {
      bool canSkip = false,
    }) {
      final styles = CharacterOptions.styles[part]!;
      if (canSkip && random.nextInt(3) == 0) return PartChoice.none;
      final real = styles.where((s) => s.id != 'none').toList();
      return PartChoice(pick(real).id, pick(colors).color);
    }

    return CharacterSpec(
      gender: pick(CharacterGender.values),
      skin: pick(CharacterOptions.skins).color,
      hair: choice('hair', CharacterOptions.hairColors, canSkip: true),
      hat: choice('hat', CharacterOptions.clothes, canSkip: true),
      glasses: choice('glasses', CharacterOptions.clothes, canSkip: true),
      top: choice('top', CharacterOptions.clothes),
      bottom: choice('bottom', CharacterOptions.clothes),
      shoes: choice('shoes', CharacterOptions.clothes),
      backpack: choice('backpack', CharacterOptions.clothes, canSkip: true),
    );
  }

  CharacterSpec copyWith({
    CharacterGender? gender,
    Color? skin,
    PartChoice? hair,
    PartChoice? hat,
    PartChoice? glasses,
    PartChoice? top,
    PartChoice? bottom,
    PartChoice? shoes,
    PartChoice? backpack,
  }) => CharacterSpec(
    gender: gender ?? this.gender,
    skin: skin ?? this.skin,
    hair: hair ?? this.hair,
    hat: hat ?? this.hat,
    glasses: glasses ?? this.glasses,
    top: top ?? this.top,
    bottom: bottom ?? this.bottom,
    shoes: shoes ?? this.shoes,
    backpack: backpack ?? this.backpack,
  );

  PartChoice part(String name) => switch (name) {
    'hair' => hair,
    'hat' => hat,
    'glasses' => glasses,
    'top' => top,
    'bottom' => bottom,
    'shoes' => shoes,
    'backpack' => backpack,
    _ => PartChoice.none,
  };

  CharacterSpec withPart(String name, PartChoice value) => switch (name) {
    'hair' => copyWith(hair: value),
    'hat' => copyWith(hat: value),
    'glasses' => copyWith(glasses: value),
    'top' => copyWith(top: value),
    'bottom' => copyWith(bottom: value),
    'shoes' => copyWith(shoes: value),
    'backpack' => copyWith(backpack: value),
    _ => this,
  };

  Map<String, Object?> toJson() => {
    'v': version,
    'gender': gender.name,
    'skin': hexOf(skin),
    for (final name in CharacterOptions.partNames)
      name: {
        'style': part(name).style,
        if (!part(name).isNone) 'color': hexOf(part(name).color!),
      },
  };

  /// Null if [json] is not a character this app version understands (unknown
  /// style, bad colour, other version): the caller then asks for a new one.
  static CharacterSpec? fromJson(Object? json) {
    if (json is! Map || json['v'] != version) return null;
    final gender = CharacterGender.values
        .where((g) => g.name == json['gender'])
        .firstOrNull;
    final skin = colorOf(json['skin']);
    if (gender == null || skin == null) return null;
    final parts = <String, PartChoice>{};
    for (final name in CharacterOptions.partNames) {
      final raw = json[name];
      final required = name == 'top' || name == 'bottom' || name == 'shoes';
      if (raw == null) {
        if (required) return null;
        parts[name] = PartChoice.none;
        continue;
      }
      if (raw is! Map) return null;
      final style = raw['style'];
      final known = CharacterOptions.styles[name]!.any((s) => s.id == style);
      if (style is! String || !known) return null;
      if (style == 'none') {
        parts[name] = PartChoice.none;
        continue;
      }
      final color = colorOf(raw['color']);
      if (color == null) return null;
      parts[name] = PartChoice(style, color);
    }
    return CharacterSpec(
      gender: gender,
      skin: skin,
      hair: parts['hair']!,
      hat: parts['hat']!,
      glasses: parts['glasses']!,
      top: parts['top']!,
      bottom: parts['bottom']!,
      shoes: parts['shoes']!,
      backpack: parts['backpack']!,
    );
  }

  /// Identity for caches: equal looks give equal keys.
  String get cacheKey => toJson().toString();

  @override
  bool operator ==(Object other) =>
      other is CharacterSpec && other.cacheKey == cacheKey;

  @override
  int get hashCode => cacheKey.hashCode;

  static String hexOf(Color c) {
    String two(double v) =>
        (v * 255).round().clamp(0, 255).toRadixString(16).padLeft(2, '0');
    return '#${two(c.r)}${two(c.g)}${two(c.b)}';
  }

  static Color? colorOf(Object? hex) {
    if (hex is! String || !RegExp(r'^#[0-9a-fA-F]{6}$').hasMatch(hex)) {
      return null;
    }
    return Color(0xFF000000 | int.parse(hex.substring(1), radix: 16));
  }
}

final class NamedColor {
  const NamedColor(this.name, this.color);
  final String name;
  final Color color;
}

final class StyleOption {
  const StyleOption(this.id, this.label);
  final String id, label;
}

/// What the creator offers. The server accepts exactly these styles.
abstract final class CharacterOptions {
  static const partNames = [
    'hair',
    'hat',
    'glasses',
    'top',
    'bottom',
    'shoes',
    'backpack',
  ];

  static const partLabels = {
    'hair': 'Haare',
    'hat': 'Kopfbedeckung',
    'glasses': 'Brille',
    'top': 'Oberteil',
    'bottom': 'Unterteil',
    'shoes': 'Schuhe',
    'backpack': 'Rucksack',
  };

  static const styles = {
    'hair': [
      StyleOption('short', 'Kurz'),
      StyleOption('long', 'Lang'),
      StyleOption('bun', 'Dutt'),
      StyleOption('ponytail', 'Zopf'),
      StyleOption('curly', 'Locken'),
      StyleOption('buzz', 'Stoppeln'),
      StyleOption('none', 'Glatze'),
    ],
    'hat': [
      StyleOption('cap', 'Kappe'),
      StyleOption('sunhat', 'Sonnenhut'),
      StyleOption('beanie', 'Mütze'),
      StyleOption('ranger', 'Rangerhut'),
      StyleOption('none', 'Keine'),
    ],
    'glasses': [
      StyleOption('round', 'Rund'),
      StyleOption('square', 'Eckig'),
      StyleOption('sunglasses', 'Sonnenbrille'),
      StyleOption('none', 'Keine'),
    ],
    'top': [
      StyleOption('tshirt', 'T-Shirt'),
      StyleOption('hoodie', 'Kapuzenpulli'),
      StyleOption('jacket', 'Jacke'),
      StyleOption('sweater', 'Pullover'),
    ],
    'bottom': [
      StyleOption('trousers', 'Hose'),
      StyleOption('shorts', 'Shorts'),
      StyleOption('skirt', 'Rock'),
    ],
    'shoes': [
      StyleOption('sneakers', 'Sneaker'),
      StyleOption('boots', 'Stiefel'),
      StyleOption('rainboots', 'Gummistiefel'),
    ],
    'backpack': [
      StyleOption('rucksack', 'Rucksack'),
      StyleOption('none', 'Keiner'),
    ],
  };

  static const skins = [
    NamedColor('Sehr hell', Color(0xFFF6D9C0)),
    NamedColor('Hell', Color(0xFFF0C8A0)),
    NamedColor('Mittel', Color(0xFFE8B98F)),
    NamedColor('Gebräunt', Color(0xFFC58C5C)),
    NamedColor('Braun', Color(0xFF9C6B45)),
    NamedColor('Dunkelbraun', Color(0xFF7A4E32)),
    NamedColor('Dunkel', Color(0xFF5B3A26)),
    NamedColor('Sehr dunkel', Color(0xFF3F2818)),
  ];

  static const hairColors = [
    NamedColor('Schwarz', Color(0xFF1F1A16)),
    NamedColor('Dunkelbraun', Color(0xFF3B2414)),
    NamedColor('Braun', Color(0xFF5B3A22)),
    NamedColor('Kastanie', Color(0xFF8A4B25)),
    NamedColor('Rot', Color(0xFFA8431F)),
    NamedColor('Blond', Color(0xFFD9A441)),
    NamedColor('Hellblond', Color(0xFFEBD38A)),
    NamedColor('Grau', Color(0xFF9A9A98)),
    NamedColor('Blau', Color(0xFF3F6FD0)),
    NamedColor('Rosa', Color(0xFFE07AA8)),
  ];

  static const clothes = [
    NamedColor('Rot', Color(0xFFC5453F)),
    NamedColor('Orange', Color(0xFFD9602F)),
    NamedColor('Gelb', Color(0xFFE0A030)),
    NamedColor('Grün', Color(0xFF2F7A58)),
    NamedColor('Moosgrün', Color(0xFF6B7F3A)),
    NamedColor('Blau', Color(0xFF3F7FD0)),
    NamedColor('Dunkelblau', Color(0xFF2F4A7A)),
    NamedColor('Violett', Color(0xFF7A5BD0)),
    NamedColor('Weiß', Color(0xFFE8E4D8)),
    NamedColor('Grau', Color(0xFF3D4860)),
    NamedColor('Braun', Color(0xFF6A4428)),
    NamedColor('Schwarz', Color(0xFF2D2A28)),
  ];

  /// The colours offered for [part].
  static List<NamedColor> colorsFor(String part) =>
      part == 'hair' ? hairColors : clothes;
}
