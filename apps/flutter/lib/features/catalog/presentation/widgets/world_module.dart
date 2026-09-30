import 'dart:convert';
import 'dart:math' as math;
import 'dart:typed_data';

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

  // ---- Precomputed once, so a frame never allocates per-vertex lists, never
  // ---- recomputes normals and never calls pow(). All faces are triangles.

  int get faceCount => faces.length;
  int get vertexCount => vertices.length;

  /// x, y, z per vertex.
  late final Float32List coords = _coords();
  Float32List _coords() {
    final out = Float32List(vertices.length * 3);
    for (var i = 0; i < vertices.length; i++) {
      out[i * 3] = vertices[i][0];
      out[i * 3 + 1] = vertices[i][1];
      out[i * 3 + 2] = vertices[i][2];
    }
    return out;
  }

  /// Vertex indices, three per face.
  late final Int32List triangles = () {
    final out = Int32List(faces.length * 3);
    for (var i = 0; i < faces.length; i++) {
      out[i * 3] = faces[i][0];
      out[i * 3 + 1] = faces[i][1];
      out[i * 3 + 2] = faces[i][2];
    }
    return out;
  }();

  /// Unit normal per face (x, y, z); (0, 0, 0) for degenerate faces.
  late final Float32List faceNormals = () {
    final c = coords, t = triangles;
    final out = Float32List(faces.length * 3);
    for (var f = 0; f < faces.length; f++) {
      final a = t[f * 3] * 3, b = t[f * 3 + 1] * 3, d = t[f * 3 + 2] * 3;
      final ux = c[b] - c[a],
          uy = c[b + 1] - c[a + 1],
          uz = c[b + 2] - c[a + 2];
      final vx = c[d] - c[a],
          vy = c[d + 1] - c[a + 1],
          vz = c[d + 2] - c[a + 2];
      final nx = uy * vz - uz * vy,
          ny = uz * vx - ux * vz,
          nz = ux * vy - uy * vx;
      final len = math.sqrt(nx * nx + ny * ny + nz * nz);
      if (len == 0) continue;
      out[f * 3] = nx / len;
      out[f * 3 + 1] = ny / len;
      out[f * 3 + 2] = nz / len;
    }
    return out;
  }();

  /// Level-path shading per face as ARGB: fixed sun in world space plus the
  /// gamma step the path view has always used.
  late final Int32List pathColors = () {
    final n = faceNormals;
    final out = Int32List(faces.length);
    for (var f = 0; f < faces.length; f++) {
      final light =
          .70 +
          .30 *
              (-n[f * 3] * .3 - n[f * 3 + 1] * .4 + n[f * 3 + 2] * .85).clamp(
                0.0,
                1.0,
              );
      int ch(double c) =>
          (math.pow(c * light, 1 / 2.2) * 255).round().clamp(0, 255);
      out[f] =
          0xFF000000 | (ch(color.r) << 16) | (ch(color.g) << 8) | ch(color.b);
    }
    return out;
  }();

  /// Draw-order group of the broad terrain planes: they go first, then props.
  /// Higher groups are painted earlier (same rule the path view always had).
  late final int groundGroup = () {
    if (name == 'earth' || name == 'grass') return 4;
    if (name.startsWith('Sandy stream')) return 3;
    if (name.startsWith('Flowing woodland')) return 2;
    if (name.startsWith('Animated water')) return 1;
    return 0;
  }();
}
