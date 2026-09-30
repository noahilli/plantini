import 'dart:convert';
import 'dart:math' as math;

import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';

import '../../../catalog/presentation/widgets/world_lighting.dart';
import '../../../catalog/presentation/widgets/world_module.dart';
import '../../domain/character_spec.dart';

/// Assembles a [CharacterSpec] from the kit modelled in Blender
/// (`tools/blender/create_character_parts.py`, exported to
/// `assets/characters/parts.json`): it picks the parts, tints them and widens
/// or narrows the body for the chosen gender. The result is ordinary
/// [WorldMesh]es with motion `ranger`, so every 3D view places them exactly
/// where the ranger used to stand.
final class CharacterKit {
  CharacterKit._(this._parts, this._defaults);

  static CharacterKit? _loaded;

  /// The kit once [load] has completed, else null.
  static CharacterKit? get loaded => _loaded;

  static Future<CharacterKit> load() async {
    final existing = _loaded;
    if (existing != null) return existing;
    final text = await rootBundle.loadString('assets/characters/parts.json');
    return _loaded = CharacterKit.parse(
      jsonDecode(text) as Map<String, dynamic>,
    );
  }

  @visibleForTesting
  factory CharacterKit.parse(Map<String, dynamic> json) {
    final parts = <String, List<_KitPart>>{};
    for (final entry in (json['parts'] as Map<String, dynamic>).entries) {
      parts[entry.key] = [
        for (final raw in entry.value as List)
          _KitPart.fromJson(raw as Map<String, dynamic>),
      ];
    }
    final defaults = <String, Color>{};
    for (final entry in (json['defaults'] as Map<String, dynamic>).entries) {
      final c = (entry.value as List)
          .map((v) => (v as num).toDouble())
          .toList();
      defaults[entry.key] = Color.from(
        alpha: 1,
        red: c[0],
        green: c[1],
        blue: c[2],
      );
    }
    return CharacterKit._(parts, defaults);
  }

  final Map<String, List<_KitPart>> _parts;
  final Map<String, Color> _defaults;
  final _cache = <String, List<WorldMesh>>{};

  /// Whether the kit has a part for [part] / [style] (used to validate specs).
  bool has(String part, String style) => _parts.containsKey('$part.$style');

  static const _bodyWidth = {
    CharacterGender.female: .92,
    CharacterGender.male: 1.08,
    CharacterGender.diverse: 1.0,
  };

  List<WorldMesh> build(CharacterSpec spec) {
    final key = spec.cacheKey;
    final hit = _cache.remove(key);
    if (hit != null) return _cache[key] = hit;
    final meshes = <WorldMesh>[];
    final hasHat = !spec.hat.isNone;
    final width = _bodyWidth[spec.gender]!;

    void addCategory(String category, String style, Color? tint) {
      for (final part in _parts['$category.$style'] ?? const <_KitPart>[]) {
        if (part.hideWithHat && hasHat) continue;
        final color = switch (part.tint) {
          'skin' => spec.skin,
          'fixed-eye' || 'fixed-sole' => _defaults[part.tint]!,
          _ => tint ?? _defaults[part.tint]!,
        };
        final head =
            category == 'hair' ||
            category == 'hat' ||
            category == 'glasses' ||
            part.name == 'head' ||
            part.name == 'eyes';
        meshes.add(part.toMesh(color, head ? 1 : width));
      }
    }

    addCategory('body', 'base', null);
    for (final category in CharacterOptions.partNames) {
      final choice = spec.part(category);
      if (choice.isNone) continue;
      addCategory(category, choice.style, choice.color);
    }
    if (_cache.length >= 8) _cache.remove(_cache.keys.first);
    return _cache[key] = meshes;
  }
}

final class _KitPart {
  _KitPart({
    required this.name,
    required this.tint,
    required this.shade,
    required this.hideWithHat,
    required this.vertices,
    required this.faces,
  });

  factory _KitPart.fromJson(Map<String, dynamic> json) => _KitPart(
    name: json['name'] as String,
    tint: json['tint'] as String,
    shade: (json['shade'] as num).toDouble(),
    hideWithHat: json['hideWithHat'] == true,
    vertices: [
      for (final v in json['vertices'] as List)
        [for (final n in v as List) (n as num).toDouble()],
    ],
    faces: [for (final f in json['faces'] as List) (f as List).cast<int>()],
  );

  final String name, tint;
  final double shade;
  final bool hideWithHat;
  final List<List<double>> vertices;
  final List<List<int>> faces;

  /// [color] is an sRGB colour; meshes hold linear colour like the Blender
  /// modules (the path view applies the display gamma after lighting).
  WorldMesh toMesh(Color color, double width) {
    double linear(double channel) =>
        (math.pow(channel, 2.2).toDouble() * shade).clamp(0.0, 1.0);
    return WorldMesh({
      'name': 'Character $name',
      'vertices': width == 1
          ? vertices
          : [
              for (final v in vertices) [v[0] * width, v[1], v[2]],
            ],
      'faces': faces,
      'color': [linear(color.r), linear(color.g), linear(color.b)],
      'motion': 'ranger',
      'slot': null,
    });
  }
}

/// The signed-in player's look, shared by every 3D view (the level path, the
/// vitrines, the profile). Views listen to [spec] and draw [meshes] in place
/// of the default ranger.
abstract final class PlayerLook {
  static final ValueNotifier<CharacterSpec?> spec = ValueNotifier(null);

  /// The player's meshes, or null to keep the module's own ranger.
  static List<WorldMesh>? meshes() {
    final current = spec.value;
    final kit = CharacterKit.loaded;
    if (current == null || kit == null) return null;
    return kit.build(current);
  }

  static String get cacheKey => spec.value?.cacheKey ?? '-';

  /// [module]'s meshes with the ranger replaced by the player's character.
  static List<WorldMesh> meshesFor(WorldModule module) {
    final look = meshes();
    if (look == null) return module.meshes;
    return [...module.meshes.where((m) => m.motion != 'ranger'), ...look];
  }

  static final _shadows = <String, WorldMesh?>{};

  /// The player's single shadow polygon for [lighting] (null: none).
  static WorldMesh? shadow(WorldLighting lighting) {
    final look = meshes();
    if (look == null) return null;
    final key = '${lighting.phase.name}|$cacheKey';
    if (!_shadows.containsKey(key) && _shadows.length >= 12) {
      _shadows.remove(_shadows.keys.first);
    }
    return _shadows.putIfAbsent(
      key,
      () => WorldMesh.shadowOf(look, lighting, 'player'),
    );
  }
}
