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
  }) {
    // The scenery is lit by the module's own lamps and shaded towards the
    // ground; the player (replaced at run time) is neither.
    for (final mesh in meshes) {
      if (mesh.motion == 'ranger') continue;
      mesh.attach(lightsOf(mesh.variant ?? -1));
    }
  }

  final _lightsByVariant = <int, List<List<double>>>{};

  /// The lamps that exist in the modules drawn with [variant] (0 or 1): the
  /// lanterns and huts (no variant) plus the lamps of that variant's own
  /// props. Pass -1 for the lanterns and huts alone.
  List<List<double>> lightsOf(int variant) => _lightsByVariant[variant] ??= [
    for (final l in lights)
      if (l.length < 5 || l[4] == variant) l,
  ];
  final List<WorldMesh> meshes;
  final List<List<double>> slots;

  /// Light sources for the evening and night: [x, y, z, radius]. The app draws
  /// a soft halo around each (huts and lanterns).
  final List<List<double>> lights;

  /// Where fireflies fly (meadow only), or null.
  final FireflyField? fireflies;

  final _shadowPieces = <(DayPhase, int), List<WorldMesh>>{};

  /// The ground shadows of this module for one time of day, in module
  /// coordinates: ONE silhouette per tree or prop (the parts that belong
  /// together share a `shadow` group, trees their pivot) and a soft contact
  /// blot at its foot, so the sun's shadows never pile up into darker spots.
  List<WorldMesh> shadowPieces(WorldLighting lighting, int variant) =>
      _shadowPieces[(lighting.phase, variant)] ??= () {
        final groups = <String, List<WorldMesh>>{};
        for (final mesh in meshes) {
          if (!mesh.inVariant(variant)) continue;
          final key = mesh.shadowKey;
          if (key != null) (groups[key] ??= []).add(mesh);
        }
        final out = <WorldMesh>[];
        groups.forEach((key, parts) {
          final hull = WorldMesh.shadowOf(parts, lighting, key);
          if (hull != null) out.add(hull);
          final blot = WorldMesh.contactOf(parts, lighting, key);
          if (blot != null) out.add(blot);
        });
        return out;
      }();

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
      slot = j['slot'] as int?,
      layer = j['layer'] as String?,
      shadowGroup = j['shadow'] as String?,
      pivot = (j['pivot'] as List?)?.map((n) => (n as num).toDouble()).toList(),
      anim = j['anim'] as Map<String, dynamic>?,
      dayOnly = j['day'] == true,
      variant = j['variant'] as int?,
      _glowRgb = (j['glow'] as List?)?.map((n) => (n as num).toInt()).toList();

  /// A flat-coloured mesh made in code (shadows).
  WorldMesh.synthetic({
    required this.name,
    required this.vertices,
    required this.faces,
    required int argb,
    required this.motion,
  }) : color = Color(argb),
       slot = null,
       layer = null,
       shadowGroup = null,
       pivot = null,
       anim = null,
       dayOnly = false,
       variant = null,
       _glowRgb = null,
       _fixedArgb = argb;

  int? _fixedArgb;
  final List<List<double>> vertices;
  final String name;
  final List<List<int>> faces;
  final Color color;
  final String motion;
  final int? slot;

  /// `decal` / `decal2`: flat things lying on the ground (lily pads, blankets,
  /// ice) that are painted over the terrain and the water, before everything
  /// upright. Null for ordinary scenery.
  final String? layer;

  /// Parts with the same `shadow` id throw ONE shadow together.
  final String? shadowGroup;

  /// Blender origin of a tree; also the rotation centre of animated parts.
  final List<double>? pivot;

  /// Parameters of an animated part (see [coordsAt]); null if it stands still.
  final Map<String, dynamic>? anim;

  /// Butterflies and the like: not there at night.
  final bool dayOnly;

  /// 0 or 1: the scenery that only the even or the odd modules of a path get
  /// (so the same windmill does not stand every ten units); null for what
  /// every module has.
  final int? variant;

  /// Whether this mesh belongs to modules drawn with [v] (0 or 1).
  bool inVariant(int v) => variant == null || variant == v;

  final List<int>? _glowRgb;

  /// The colour a `glow` mesh shines in when the lamps are lit: its own
  /// `glow` colour if it has one (fairy mushrooms, the campfire), otherwise the
  /// warm window light (slightly stronger at night).
  int glowArgb(WorldLighting lighting) {
    final rgb = _glowRgb;
    if (rgb != null) {
      return 0xFF000000 | (rgb[0] << 16) | (rgb[1] << 8) | rgb[2];
    }
    return lighting.phase == DayPhase.night ? 0xFFFFE08A : 0xFFFFC878;
  }

  /// Key of the shadow this mesh contributes to, or null if it casts none.
  /// Trees (motion `tree`) without an explicit group share their pivot.
  late final String? shadowKey = () {
    if (shadowGroup != null) return shadowGroup;
    if (motion != 'tree') return null;
    final p = pivot;
    return p == null
        ? 'tree:$name'
        : 'tree:${p[0].toStringAsFixed(2)},${p[1].toStringAsFixed(2)}';
  }();

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

  /// Axis-aligned box of the mesh (minX, minY, minZ, maxX, maxY, maxZ), so a
  /// whole mesh that lies outside the view can be skipped without projecting
  /// its vertices.
  late final Float32List bounds = () {
    final c = coords;
    final out = Float32List.fromList([
      double.infinity,
      double.infinity,
      double.infinity,
      -double.infinity,
      -double.infinity,
      -double.infinity,
    ]);
    for (var v = 0; v < vertexCount; v++) {
      for (var k = 0; k < 3; k++) {
        final value = c[v * 3 + k];
        if (value < out[k]) out[k] = value;
        if (value > out[3 + k]) out[3 + k] = value;
      }
    }
    return out;
  }();

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
      return Int32List(faces.length)
        ..fillRange(0, faces.length, glowArgb(lighting));
    }
    final fixed = _fixedArgb;
    if (fixed != null) {
      return Int32List(faces.length)..fillRange(0, faces.length, fixed);
    }
    final n = faceNormals;
    final out = Int32List(faces.length);
    final lamp = lighting.lamps && _lamps.isNotEmpty
        ? _lampLight(lighting)
        : null;
    for (var f = 0; f < faces.length; f++) {
      out[f] = lighting.shade(
        color.r,
        color.g,
        color.b,
        n[f * 3],
        n[f * 3 + 1],
        n[f * 3 + 2],
        gamma: true,
        lamp: lamp == null ? null : lamp[f],
      );
    }
    return out;
  }();

  /// Warm light that the lamps of the module throw on each face: facing the
  /// lamp, within about 2.4 radii, fading with the square of the distance.
  /// Null entries for faces that get none. Big faces are skipped (see
  /// [faceAreas]); a face that turns its back to the lamp stays dark, so no
  /// light reaches the far side of a trunk or a hut.
  List<List<double>?> _lampLight(WorldLighting lighting) {
    final strength = lighting.phase == DayPhase.night ? 1.15 : .6;
    const warm = [1.0, .66, .30];
    final n = faceNormals, ctr = faceCenters, area = faceAreas;
    final out = List<List<double>?>.filled(faces.length, null);
    for (var f = 0; f < faces.length; f++) {
      if (area[f] > .9) continue;
      var k = 0.0;
      for (final l in _lamps) {
        final dx = l[0] - ctr[f * 3],
            dy = l[1] - ctr[f * 3 + 1],
            dz = l[2] - ctr[f * 3 + 2];
        final d = math.sqrt(dx * dx + dy * dy + dz * dz);
        final reach = l[3] * 2.4;
        if (d >= reach || d < 1e-4) continue;
        final facing =
            (n[f * 3] * dx + n[f * 3 + 1] * dy + n[f * 3 + 2] * dz) / d;
        if (facing <= 0) continue;
        final fall = 1 - d / reach;
        k += fall * fall * facing;
      }
      if (k > .004) {
        k = math.min(k, 1.0) * strength;
        out[f] = [warm[0] * k, warm[1] * k, warm[2] * k];
      }
    }
    return out;
  }

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

  /// Draw-order group: the broad terrain planes go first, then the water,
  /// the flat decals and the shadows, then everything upright (group 0).
  /// Higher groups are painted earlier. [SceneMarker] relies on the split at
  /// group 1: a ground marker (pool of light) lies after every group >= 1 and
  /// before group 0.
  late final int groundGroup = () {
    if (motion == 'shadow') return 4;
    if (name == 'earth' || name == 'grass') return 7;
    if (name.startsWith('Sandy stream')) return 6;
    if (name.startsWith('Flowing woodland')) return 5;
    if (name.startsWith('Animated water')) return 3;
    if (layer == 'decal') return 2;
    if (layer == 'decal2') return 1;
    return 0;
  }();

  // ---- Light and shade that belong to the module ---------------------------

  List<List<double>> _lamps = const [];
  bool _modelled = false;

  /// Hands the mesh the module's lamps (they warm the faces near them in the
  /// evening and at night) and switches on the shading towards the ground.
  void attach(List<List<double>> lamps) {
    _lamps = lamps;
    _modelled = true;
  }

  /// Centre of every face (x, y, z).
  late final Float32List faceCenters = () {
    final c = coords, t = triangles;
    final out = Float32List(faces.length * 3);
    for (var f = 0; f < faces.length; f++) {
      for (var k = 0; k < 3; k++) {
        out[f * 3 + k] =
            (c[t[f * 3] * 3 + k] +
                c[t[f * 3 + 1] * 3 + k] +
                c[t[f * 3 + 2] * 3 + k]) /
            3;
      }
    }
    return out;
  }();

  /// Area of every face. Large faces (the ground, mountain flanks) are never
  /// lit per face by a lamp: a single colour would flood the whole plane.
  late final Float32List faceAreas = () {
    final c = coords, t = triangles;
    final out = Float32List(faces.length);
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
      out[f] = .5 * math.sqrt(nx * nx + ny * ny + nz * nz);
    }
    return out;
  }();

  /// Brightness per vertex for upright scenery: a little darker at the foot,
  /// a little lighter at the top, so trees and bushes look rounded instead of
  /// cut from flat paper. Null for flat things and everything that glows.
  late final Float32List? vertexShade = () {
    if (!_modelled || groundGroup != 0 || motion == 'glow') return null;
    final c = coords;
    var lo = double.infinity, hi = -double.infinity;
    for (var v = 0; v < vertexCount; v++) {
      lo = math.min(lo, c[v * 3 + 2]);
      hi = math.max(hi, c[v * 3 + 2]);
    }
    if (hi - lo < .12) return null;
    final out = Float32List(vertexCount);
    for (var v = 0; v < vertexCount; v++) {
      out[v] = .78 + .34 * ((c[v * 3 + 2] - lo) / (hi - lo));
    }
    return out;
  }();

  // ---- Animated parts -------------------------------------------------------

  /// Coordinates of the animated part per frame (180 frames per 6 s loop, see
  /// `_framesPerLoop` in the path view); [coordsAt] takes the loop position.
  final _frames = <int, Float32List>{};

  /// Vertex coordinates of an animated part at [loop] (0..1 is one 6 s loop,
  /// every frequency a whole number so that the loop closes). Meshes without
  /// `anim` return their own [coords].
  ///
  /// motion `spin`: turns about `axis` through `pivot` ([freq] times per loop);
  /// `flap`: swings about `axis` by +-`amp` radians and drifts along a small
  /// loop `drift` ([rx, ry, rz]); `bob`: rises and falls by `amp`;
  /// `hop`: leaps by `amp`; `orbit`: flies a circle of radius `radius`,
  /// turning with it. Face normals are not rotated (the parts are small).
  Float32List coordsAt(double loop) {
    final a = anim;
    if (a == null) return coords;
    final key = (loop * 180).round() % 180;
    return _frames[key] ??= _animate(a, key / 180);
  }

  Float32List _animate(Map<String, dynamic> a, double loop) {
    double n(String k, [double d = 0]) => (a[k] as num?)?.toDouble() ?? d;
    List<double> vec(String k, List<double> d) =>
        (a[k] as List?)?.map((e) => (e as num).toDouble()).toList() ?? d;
    final freq = n('freq', 1);
    final t = 2 * math.pi * freq * loop + 2 * math.pi * n('phase');
    final pv = vec('pivot', pivot ?? const [0, 0, 0]);
    final axis = vec('axis', const [0, 0, 1]);
    final len = math.sqrt(
      axis[0] * axis[0] + axis[1] * axis[1] + axis[2] * axis[2],
    );
    final ux = axis[0] / len, uy = axis[1] / len, uz = axis[2] / len;
    double angle = 0, ox = 0, oy = 0, oz = 0;
    switch (motion) {
      case 'spin':
        angle = t;
      case 'flap':
        angle = n('amp', .7) * math.sin(t);
        final d = vec('drift', const [0, 0, 0]);
        final df = n('driftFreq', 1);
        final dt = 2 * math.pi * df * loop + 2 * math.pi * n('phase');
        ox = d[0] * math.sin(dt);
        oy = d[1] * math.sin(dt + math.pi / 2);
        oz = d[2] * math.sin(2 * dt);
      case 'bob':
        oz = n('amp', .03) * math.sin(t);
        angle = n('roll') * math.sin(t + 1);
      case 'hop':
        oz = n('amp', .25) * math.sin(t / 2).abs();
      case 'orbit':
        final r = n('radius', 1);
        angle = t; // turn with the circle
        ox = r * (math.cos(t) - 1);
        oy = r * math.sin(t);
        oz = n('amp') * math.sin(2 * t);
    }
    final cosA = math.cos(angle), sinA = math.sin(angle);
    final c = coords;
    final out = Float32List(c.length);
    for (var v = 0; v < vertexCount; v++) {
      final x = c[v * 3] - pv[0],
          y = c[v * 3 + 1] - pv[1],
          z = c[v * 3 + 2] - pv[2];
      // Rodrigues' rotation about the unit axis.
      final dot = ux * x + uy * y + uz * z;
      final cx = uy * z - uz * y, cy = uz * x - ux * z, cz = ux * y - uy * x;
      out[v * 3] = (x * cosA + cx * sinA + ux * dot * (1 - cosA) + pv[0] + ox)
          .toDouble();
      out[v * 3 +
          1] = (y * cosA + cy * sinA + uy * dot * (1 - cosA) + pv[1] + oy)
          .toDouble();
      out[v * 3 +
          2] = (z * cosA + cz * sinA + uz * dot * (1 - cosA) + pv[2] + oz)
          .toDouble();
    }
    return out;
  }

  /// A soft blot at the foot of the parts of one shadow group: three stacked
  /// translucent rings that read as a gradient. Null if there is no foot.
  static WorldMesh? contactOf(
    List<WorldMesh> meshes,
    WorldLighting lighting,
    String name,
  ) {
    var minX = double.infinity, maxX = -double.infinity;
    var minY = double.infinity, maxY = -double.infinity;
    for (final mesh in meshes) {
      final c = mesh.coords;
      for (var v = 0; v < mesh.vertexCount; v++) {
        if (c[v * 3 + 2] > .45) continue;
        minX = math.min(minX, c[v * 3]);
        maxX = math.max(maxX, c[v * 3]);
        minY = math.min(minY, c[v * 3 + 1]);
        maxY = math.max(maxY, c[v * 3 + 1]);
      }
    }
    if (minX > maxX) return null;
    final cx = (minX + maxX) / 2, cy = (minY + maxY) / 2;
    final span = math.max((maxX - minX), (maxY - minY));
    // Long things (a fence, a bridge) get their silhouette only: a blot as big
    // as they are would just darken the meadow.
    if (span > 1.1) return null;
    final r = span / 2 * 1.35 + .1;
    final base = switch (lighting.phase) {
      DayPhase.night => 0x0C,
      DayPhase.noon => 0x1A,
      _ => 0x16,
    };
    final vertices = <List<double>>[];
    final faces = <List<int>>[];
    for (final scale in const [1.0, .72, .46]) {
      final first = vertices.length;
      for (var i = 0; i < 10; i++) {
        final a = i * math.pi * 2 / 10;
        vertices.add([
          cx + math.cos(a) * r * scale,
          cy + math.sin(a) * r * scale * .85,
          .03,
        ]);
      }
      for (var i = 1; i < 9; i++) {
        faces.add([first, first + i, first + i + 1]);
      }
    }
    // Different alphas per ring would need separate meshes; one colour per
    // mesh is the rule, so the three rings share one and simply overlap.
    return WorldMesh.synthetic(
      name: '$name-contact',
      vertices: vertices,
      faces: faces,
      argb: (base << 24) | 0x1C2618,
      motion: 'shadow',
    );
  }
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
