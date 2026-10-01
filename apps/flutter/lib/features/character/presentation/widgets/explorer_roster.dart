import 'dart:convert';

import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';

import '../../../catalog/presentation/widgets/world_lighting.dart';
import '../../../catalog/presentation/widgets/world_module.dart';
import '../../domain/explorer.dart';

/// The nine explorers, loaded once from `assets/characters/explorers.json`.
final class ExplorerRoster {
  ExplorerRoster._(this.explorers);

  static ExplorerRoster? _loaded;

  /// The roster once [load] has completed, else null.
  static ExplorerRoster? get loaded => _loaded;

  static Future<ExplorerRoster> load() async {
    final existing = _loaded;
    if (existing != null) return existing;
    final text = await rootBundle.loadString(
      'assets/characters/explorers.json',
    );
    return _loaded = ExplorerRoster.parse(
      jsonDecode(text) as Map<String, dynamic>,
    );
  }

  @visibleForTesting
  factory ExplorerRoster.parse(Map<String, dynamic> json) {
    final list = <Explorer>[];
    for (final raw in json['characters'] as List) {
      final c = raw as Map<String, dynamic>;
      final group = ExplorerGroup.values.byName(c['group'] as String);
      list.add(
        Explorer(
          id: c['id'] as String,
          name: c['name'] as String,
          group: group,
          blurb: c['blurb'] as String,
          meshes: [
            for (final m in c['meshes'] as List)
              WorldMesh({
                'name': 'Explorer ${(m as Map)['name']}',
                'vertices': m['vertices'],
                'faces': m['faces'],
                'color': m['color'],
                'motion': 'ranger',
                'slot': null,
              }),
          ],
        ),
      );
    }
    return ExplorerRoster._(list);
  }

  final List<Explorer> explorers;

  Explorer? byId(String? id) {
    for (final e in explorers) {
      if (e.id == id) return e;
    }
    return null;
  }

  List<Explorer> inGroup(ExplorerGroup group) => [
    for (final e in explorers)
      if (e.group == group) e,
  ];
}

/// The signed-in player's explorer, shared by every 3D view (level path,
/// vitrines, profile). Views listen to [id] and draw [meshes] in place of the
/// default ranger.
abstract final class PlayerLook {
  static final ValueNotifier<String?> id = ValueNotifier(null);

  static Explorer? get explorer => ExplorerRoster.loaded?.byId(id.value);

  /// [module]'s meshes with the ranger replaced by the player's explorer.
  static List<WorldMesh> meshesFor(WorldModule module) {
    final mine = explorer;
    if (mine == null) return module.meshes;
    return [
      ...module.meshes.where((m) => m.motion != 'ranger'),
      ...mine.meshes,
    ];
  }

  static String get cacheKey => id.value ?? '-';

  static final _shadows = <String, WorldMesh?>{};

  /// The explorer's single shadow polygon for [lighting] (null: none).
  static WorldMesh? shadow(WorldLighting lighting) {
    final mine = explorer;
    if (mine == null) return null;
    return _shadows.putIfAbsent(
      '${lighting.phase.name}|${mine.id}',
      () => WorldMesh.shadowOf(mine.meshes, lighting, 'player'),
    );
  }
}
