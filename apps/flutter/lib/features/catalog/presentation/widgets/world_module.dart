import 'dart:convert';

import 'package:flutter/services.dart';

/// Parsed Blender module (assets/worlds/*_module.json): plain mesh data that
/// both the level-path renderer and the ecosystem vitrine project themselves.
final class WorldModule {
  WorldModule(this.meshes, this.slots);
  final List<WorldMesh> meshes;
  final List<List<double>> slots;

  static final _cache = <String, Future<WorldModule>>{};

  /// Loads and caches a module by asset name (`forest`, `meadow`, `alpine`).
  static Future<WorldModule> load(String asset) => _cache.putIfAbsent(
    asset,
    () => rootBundle
        .loadString('assets/worlds/${asset}_module.json')
        .then(
          (text) =>
              WorldModule.fromJson(jsonDecode(text) as Map<String, dynamic>),
        ),
  );
  factory WorldModule.fromJson(Map<String, dynamic> data) => WorldModule(
    (data['meshes'] as List)
        .map((m) => WorldMesh(m as Map<String, dynamic>))
        .toList(),
    (data['slots'] as List)
        .map((v) => (v as List).map((n) => (n as num).toDouble()).toList())
        .toList(),
  );
}

final class WorldMesh {
  WorldMesh(Map<String, dynamic> j)
    : name = j['name'] as String,
      vertices = (j['vertices'] as List)
          .map((v) => (v as List).map((n) => (n as num).toDouble()).toList())
          .toList(),
      faces = (j['faces'] as List).map((v) => (v as List).cast<int>()).toList(),
      color = Color.fromRGBO(
        ((j['color'][0] as num) * 255).round(),
        ((j['color'][1] as num) * 255).round(),
        ((j['color'][2] as num) * 255).round(),
        1,
      ),
      motion = j['motion'] as String,
      slot = j['slot'] as int?;
  final List<List<double>> vertices;
  final String name;
  final List<List<int>> faces;
  final Color color;
  final String motion;
  final int? slot;
}
