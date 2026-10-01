import 'dart:convert';
import 'dart:math' as math;
import 'dart:typed_data';

import 'package:flutter/services.dart';

import 'world_lighting.dart';

/// Parsed Blender module (assets/worlds/*_module.json): plain mesh data that
/// both the level-path renderer and the ecosystem vitrine project themselves.
final class WorldModule {
  WorldModule(
    this.meshes,
    this.slots, {
    this.lights = const [],
    this.fireflies,
  });
  final List<WorldMesh> meshes;
  final List<List<double>> slots;

  /// Light sources for the evening and night: [x, y, z, radius]. The app draws
  /// a soft halo around each (huts and lanterns).
  final List<List<double>> lights;

  /// Where fireflies fly (meadow only), or null.
  final FireflyField? fireflies;

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
    lights: [
      for (final l in (data['lights'] as List? ?? const []))
        [for (final n in l as List) (n as num).toDouble()],
    ],
    fireflies: data['fireflies'] == null
        ? null
        : FireflyField.fromJson(data['fireflies'] as Map<String, dynamic>),
  );
}

/// A swarm of fireflies over a rectangle of the module.
final class FireflyField {
  const FireflyField({
    required this.count,
    required this.x0,
    required this.x1,
    required this.y0,
    required this.y1,
    required this.z0,
    required this.z1,
  });

  factory FireflyField.fromJson(Map<String, dynamic> json) {
    final area = (json['area'] as List)
        .map((n) => (n as num).toDouble())
        .toList();
    final z = (json['z'] as List).map((n) => (n as num).toDouble()).toList();
    return FireflyField(
      count: json['count'] as int,
      x0: area[0],
      x1: area[1],
      y0: area[2],
      y1: area[3],
      z0: z[0],
      z1: z[1],
    );
  }

  final int count;
  final double x0, x1, y0, y1, z0, z1;

  /// Position and glow of firefly [i] at [phase] (0..1 is one 6 s loop, every
  /// frequency is a whole number so the loop is seamless): x, y, z, brightness.
  List<double> at(int i, double phase, {int salt = 0}) {
    double r(int k) {
      var h = (i * 374761393 + k * 668265263 + salt * 2246822519) & 0x7fffffff;
      h = ((h ^ (h >> 13)) * 1274126177) & 0x7fffffff;
      return (h % 10000) / 10000;
    }

    final t = phase * 2 * math.pi;
    final x =
        x0 +
        r(1) * (x1 - x0) +
        .35 * math.sin(t * (1 + (r(2) * 2).floor()) + r(3) * 6.28);
    final y =
        y0 +
        r(4) * (y1 - y0) +
        .35 * math.cos(t * (1 + (r(5) * 2).floor()) + r(6) * 6.28);
    final z = z0 + r(7) * (z1 - z0) + .12 * math.sin(t * 2 + r(8) * 6.28);
    final blink = math.sin(t * (2 + (r(9) * 2).floor()) + r(10) * 6.28);
    return [x, y, z, blink > 0 ? blink * blink : 0.0];
  }
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

  /// A flat-coloured mesh made in code (shadows).
  WorldMesh.synthetic({
    required this.name,
    required this.vertices,
    required this.faces,
    required int argb,
    required this.motion,
  }) : color = Color(argb),
       slot = null,
       _fixedArgb = argb;

  int? _fixedArgb;
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

  final _pathColors = <DayPhase, Int32List>{};

  /// Level-path shading per face as ARGB for one time of day (computed once per
  /// phase): the sun fixed in world space plus the gamma step the path view
  /// has always used.
  Int32List pathColorsFor(
    WorldLighting lighting,
  ) => _pathColors[lighting.phase] ??= () {
    // Lit windows and lantern glass: warm light in the evening and at night.
    if (motion == 'glow' && lighting.lamps) {
      final argb = lighting.phase == DayPhase.night ? 0xFFFFE08A : 0xFFFFC878;
      return Int32List(faces.length)..fillRange(0, faces.length, argb);
    }
    final fixed = _fixedArgb;
    if (fixed != null) {
      return Int32List(faces.length)..fillRange(0, faces.length, fixed);
    }
    final n = faceNormals;
    final out = Int32List(faces.length);
    for (var f = 0; f < faces.length; f++) {
      out[f] = lighting.shade(
        color.r,
        color.g,
        color.b,
        n[f * 3],
        n[f * 3 + 1],
        n[f * 3 + 2],
        gamma: true,
      );
    }
    return out;
  }();

  final _shadows = <DayPhase, WorldMesh?>{};

  /// The silhouette this mesh throws on the ground for [lighting], see
  /// [shadowOf]. Coordinates are local to the mesh; place it with the mesh's
  /// own offset.
  WorldMesh? shadowFor(WorldLighting lighting) => _shadows.putIfAbsent(
    lighting.phase,
    () => shadowOf([this], lighting, name),
  );

  /// One translucent polygon: the convex hull of all vertices of [meshes]
  /// projected along the light onto the ground plane. Null while the hull is
  /// degenerate. Several meshes (a character) share ONE polygon, so their
  /// shadows do not pile up into a darker patch.
  static WorldMesh? shadowOf(
    List<WorldMesh> meshes,
    WorldLighting lighting,
    String name,
  ) {
    // Very low sun would throw endless shadows; cap the stretch.
    final lz = math.max(lighting.toSun[2], .7);
    final dx = lighting.toSun[0] / lz, dy = lighting.toSun[1] / lz;
    final pts = <List<double>>[];
    for (final mesh in meshes) {
      final c = mesh.coords;
      for (var v = 0; v < mesh.vertexCount; v++) {
        final z = math.max(c[v * 3 + 2], 0);
        pts.add([c[v * 3] - z * dx, c[v * 3 + 1] - z * dy]);
      }
    }
    final hull = _convexHull(pts);
    if (hull.length < 3) return null;
    final alpha = switch (lighting.phase) {
      DayPhase.night => 0x22,
      DayPhase.noon => 0x40,
      _ => 0x3A,
    };
    return WorldMesh.synthetic(
      name: '$name-shadow',
      vertices: [
        for (final p in hull) [p[0], p[1], .02],
      ],
      faces: [
        for (var i = 1; i < hull.length - 1; i++) [0, i, i + 1],
      ],
      argb: (alpha << 24) | 0x1C2618,
      motion: 'shadow',
    );
  }

  /// Draw-order group of the broad terrain planes: they go first, then props.
  /// Higher groups are painted earlier (same rule the path view always had).
  late final int groundGroup = () {
    if (motion == 'shadow') return 2;
    if (name == 'earth' || name == 'grass') return 4;
    if (name.startsWith('Sandy stream')) return 3;
    if (name.startsWith('Flowing woodland')) return 2;
    if (name.startsWith('Animated water')) return 1;
    return 0;
  }();
}

/// Andrew's monotone chain, counter-clockwise, without the closing point.
List<List<double>> _convexHull(List<List<double>> points) {
  final p = [
    ...points,
  ]..sort((a, b) => a[0] != b[0] ? a[0].compareTo(b[0]) : a[1].compareTo(b[1]));
  if (p.length < 3) return p;
  double cross(List<double> o, List<double> a, List<double> b) =>
      (a[0] - o[0]) * (b[1] - o[1]) - (a[1] - o[1]) * (b[0] - o[0]);
  final lower = <List<double>>[];
  for (final q in p) {
    while (lower.length >= 2 &&
        cross(lower[lower.length - 2], lower.last, q) <= 0) {
      lower.removeLast();
    }
    lower.add(q);
  }
  final upper = <List<double>>[];
  for (final q in p.reversed) {
    while (upper.length >= 2 &&
        cross(upper[upper.length - 2], upper.last, q) <= 0) {
      upper.removeLast();
    }
    upper.add(q);
  }
  lower.removeLast();
  upper.removeLast();
  return [...lower, ...upper];
}
