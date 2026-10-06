import 'dart:math' as math;
import 'dart:typed_data';
import 'dart:ui' as ui;

import '../../../../core/diagnostics/frame_stats.dart';
import 'world_lighting.dart';
import 'world_module.dart';

/// One mesh placed into a scene: shifted by [dx]/[dy] and swaying sideways in
/// proportion to its height by [sway] (trees and plants). [coords] replaces the
/// mesh's own vertices for one frame of an animated part (windmill sails,
/// wings, a bobbing duck: see [WorldMesh.coordsAt]).
final class SceneInstance {
  const SceneInstance(
    this.mesh, {
    this.dx = 0,
    this.dy = 0,
    this.sway = 0,
    this.coords,
  });
  final WorldMesh mesh;
  final double dx, dy, sway;
  final Float32List? coords;
}

/// Something painted between the triangles instead of over all of them: a
/// halo of light, for instance. It is placed in the depth order at its scene
/// position, so whatever stands nearer to the viewer covers it: a lamp behind a
/// tree or a mountain no longer shines through. [ground] markers lie flat on
/// the terrain and are painted after the ground, before every upright object.
final class SceneMarker {
  const SceneMarker(this.x, this.y, this.z, this.paint, {this.ground = false});
  final double x, y, z;
  final bool ground;
  final void Function(ui.Canvas canvas) paint;
}

/// Oblique projection shared by the level path and the vitrine: rotate about the
/// vertical axis, squash depth to 0.7 and lift by 0.85 per unit height.
final class SceneProjection {
  SceneProjection({
    required this.yaw,
    this.focus = 0,
    required this.scale,
    required this.ox,
    required this.oy,
    this.squash = .7,
    this.lift = .85,
  }) : cosYaw = math.cos(yaw),
       sinYaw = math.sin(yaw);

  /// Screen position of the scene point ([x], [y], [z]); the same mapping the
  /// builder applies to every vertex.
  ui.Offset project(double x, double y, double z) {
    final yy = y - focus;
    final along = x * sinYaw + yy * cosYaw;
    return ui.Offset(
      ox + (x * cosYaw - yy * sinYaw) * scale,
      oy - (along * squash + z * lift) * scale,
    );
  }

  final double yaw, focus, scale, ox, oy;

  /// Depth squash and lift per unit of height; the defaults give the level
  /// path's oblique view, smaller `squash` looks more from the front.
  final double squash, lift;
  final double cosYaw, sinYaw;
}

enum SceneShading {
  /// Sun fixed in world space, gamma step (the level path's look).
  path,

  /// Sun fixed relative to the viewer while the model turns (vitrine).
  viewer,
}

/// Projects, shades and depth-sorts triangles into raw vertex buffers.
///
/// Everything that does not depend on the view (normals, face colours, vertex
/// arrays) is precomputed on the meshes; the per-scene work is one projection
/// per vertex, one depth key per face and a native numeric sort. Scratch buffers
/// are reused, so a build allocates only its result.
abstract final class SceneBuilder {
  static Float32List _px = Float32List(0),
      _py = Float32List(0),
      _pd = Float32List(0);
  // Depth key of every face (group * 65536 + 16-bit depth) and the order that
  // sorts them; counting sorts need no comparisons and keep equal keys in the
  // order the faces were added.
  static Int32List _keys = Int32List(0),
      _order = Int32List(0),
      _swap = Int32List(0);
  static final Int32List _bucket = Int32List(1025);
  static Float32List _pos = Float32List(0);
  static Int32List _col = Int32List(0);

  // The vitrine shows colours without the display gamma the path uses, so the
  // light is lifted a little to keep both views equally bright.
  static const _viewerGain = 1.22;
  static const _depthRange = 40.0;

  /// Depth quantised exactly like the faces' keys, so that markers and faces
  /// are ordered against each other consistently.
  static int _quantised(double depth) =>
      ((depth + _depthRange) / (2 * _depthRange) * 65535)
          .clamp(0, 65535)
          .floor();

  /// Fills [_order] with the indices 0..count-1 sorted by ascending [_keys]
  /// (stable): two counting passes over 10 bits each (the keys are < 2^20).
  static void _sortKeys(int count) {
    if (_order.length < count) {
      _order = Int32List(count);
      _swap = Int32List(count);
    }
    var from = _order, to = _swap;
    for (var i = 0; i < count; i++) {
      from[i] = i;
    }
    for (var pass = 0; pass < 2; pass++) {
      final shift = pass * 10;
      _bucket.fillRange(0, 1025, 0);
      for (var i = 0; i < count; i++) {
        _bucket[((_keys[from[i]] >> shift) & 1023) + 1]++;
      }
      for (var b = 0; b < 1024; b++) {
        _bucket[b + 1] += _bucket[b];
      }
      for (var i = 0; i < count; i++) {
        final index = from[i];
        to[_bucket[(_keys[index] >> shift) & 1023]++] = index;
      }
      final t = from;
      from = to;
      to = t;
    }
    // Two passes: the result is back in [_order].
  }

  /// [cullHeight] / [cullWidth]: skip faces that lie completely outside the
  /// viewport (above or below, left or right of it).
  /// [haze] pulls far faces towards a colour (aerial perspective in the path
  /// view): the colour and how strongly the farthest faces take it.
  static ui.Vertices? build(
    List<SceneInstance> instances,
    SceneProjection p, {
    SceneShading shading = SceneShading.path,
    WorldLighting? lighting,
    double? cullHeight,
    double? cullWidth,
    ui.Color? haze,
    double hazeStrength = 0,
  }) {
    final count = _assemble(
      instances,
      p,
      shading,
      lighting ?? WorldLighting.of(DayPhase.noon),
      cullHeight,
      cullWidth,
      haze,
      hazeStrength,
    );
    if (count == 0) return null;
    _sortKeys(count);
    final (outPos, outCol) = _ordered(count);
    return ui.Vertices.raw(ui.VertexMode.triangles, outPos, colors: outCol);
  }

  /// Paints the scene far to near, with [markers] placed between the triangles
  /// at their own depth.
  static void paintScene(
    ui.Canvas canvas,
    List<SceneInstance> instances,
    SceneProjection p, {
    List<SceneMarker> markers = const [],
    SceneShading shading = SceneShading.path,
    WorldLighting? lighting,
    double? cullHeight,
    double? cullWidth,
    ui.Color? haze,
    double hazeStrength = 0,
  }) {
    final clock = Stopwatch()..start();
    final count = _assemble(
      instances,
      p,
      shading,
      lighting ?? WorldLighting.of(DayPhase.noon),
      cullHeight,
      cullWidth,
      haze,
      hazeStrength,
    );
    FrameStats.note('scene-assemble', clock.elapsed);
    clock.reset();
    _sortKeys(count);
    FrameStats.note('scene-sort', clock.elapsed);
    clock.reset();
    final (outPos, outCol) = _ordered(count);
    FrameStats.note('scene-order', clock.elapsed);
    clock.reset();

    // Where each marker falls in the far-to-near order: after every face whose
    // key is larger than its own.
    final cos = p.cosYaw, sin = p.sinYaw;
    final placed = <(int, SceneMarker)>[];
    for (final m in markers) {
      final int key;
      if (m.ground) {
        key = 65535; // after every group >= 1, before the upright group 0
      } else {
        final along = m.x * sin + (m.y - p.focus) * cos;
        // Painted before the faces of the same quantised depth, so the lamp
        // itself (same depth) is drawn on top of its own glow.
        key = _quantised(along * p.lift - m.z * p.squash);
      }
      placed.add((count - _upperBound(count, key), m));
    }
    placed.sort((a, b) => a.$1.compareTo(b.$1));

    var from = 0;
    void flush(int to) {
      if (to <= from) return;
      final v = ui.Vertices.raw(
        ui.VertexMode.triangles,
        Float32List.sublistView(outPos, from * 6, to * 6),
        colors: Int32List.sublistView(outCol, from * 3, to * 3),
      );
      canvas.drawVertices(v, ui.BlendMode.srcOver, ui.Paint());
      v.dispose();
      from = to;
    }

    for (final (at, marker) in placed) {
      flush(at);
      marker.paint(canvas);
    }
    flush(count);
    FrameStats.note('scene-draw', clock.elapsed);
  }

  /// Number of faces whose key is <= [key] (they are painted after a marker
  /// with that key; the faces with a larger key before it).
  static int _upperBound(int count, int key) {
    var lo = 0, hi = count;
    while (lo < hi) {
      final mid = (lo + hi) >> 1;
      if (_keys[_order[mid]] <= key) {
        lo = mid + 1;
      } else {
        hi = mid;
      }
    }
    return lo;
  }

  /// Far to near: the largest key (highest group, deepest) is painted first,
  /// and of equal keys the face added last.
  static (Float32List, Int32List) _ordered(int count) {
    final outPos = Float32List(count * 6);
    final outCol = Int32List(count * 3);
    for (var i = 0; i < count; i++) {
      final src = _order[count - 1 - i];
      final so = src * 6, oo = i * 6;
      outPos[oo] = _pos[so];
      outPos[oo + 1] = _pos[so + 1];
      outPos[oo + 2] = _pos[so + 2];
      outPos[oo + 3] = _pos[so + 3];
      outPos[oo + 4] = _pos[so + 4];
      outPos[oo + 5] = _pos[so + 5];
      outCol[i * 3] = _col[src * 3];
      outCol[i * 3 + 1] = _col[src * 3 + 1];
      outCol[i * 3 + 2] = _col[src * 3 + 2];
    }
    return (outPos, outCol);
  }

  /// Scales the colour channels of [argb] by [k] (alpha untouched).
  static int _scale(int argb, double k) {
    final r = (((argb >> 16) & 255) * k).round().clamp(0, 255);
    final g = (((argb >> 8) & 255) * k).round().clamp(0, 255);
    final b = ((argb & 255) * k).round().clamp(0, 255);
    return (argb & 0xFF000000) | (r << 16) | (g << 8) | b;
  }

  /// Mixes [argb] towards [towards] by [k] (0..1).
  static int _mix(int argb, int towards, double k) {
    int ch(int shift) {
      final a = (argb >> shift) & 255, b = (towards >> shift) & 255;
      return (a + (b - a) * k).round().clamp(0, 255);
    }

    return (argb & 0xFF000000) | (ch(16) << 16) | (ch(8) << 8) | ch(0);
  }

  /// Projects, shades and keys every face into the scratch buffers; returns
  /// the number of faces. Three colours per face (one per corner) so that
  /// shapes can darken towards the ground.
  static int _assemble(
    List<SceneInstance> instances,
    SceneProjection p,
    SceneShading shading,
    WorldLighting lighting,
    double? cullHeight,
    double? cullWidth,
    ui.Color? haze,
    double hazeStrength,
  ) {
    var total = 0, maxVertices = 0;
    for (final i in instances) {
      total += i.mesh.faceCount;
      maxVertices = math.max(maxVertices, i.mesh.vertexCount);
    }
    if (total == 0) return 0;
    if (_px.length < maxVertices) {
      _px = Float32List(maxVertices);
      _py = Float32List(maxVertices);
      _pd = Float32List(maxVertices);
    }
    if (_keys.length < total) {
      _keys = Int32List(total);
      _pos = Float32List(total * 6);
      _col = Int32List(total * 3);
    }
    final cos = p.cosYaw, sin = p.sinYaw;
    final px = _px, py = _py, pd = _pd;
    final keys = _keys, pos = _pos, col = _col;
    final hazeArgb = haze?.toARGB32() ?? 0;
    final useHaze = haze != null && hazeStrength > 0;
    var count = 0;

    for (final inst in instances) {
      final mesh = inst.mesh;
      if ((cullHeight != null || cullWidth != null) &&
          _outside(mesh, inst, p, cullWidth, cullHeight)) {
        continue;
      }
      final c = inst.coords ?? mesh.coords;
      final vertexCount = mesh.vertexCount;
      for (var v = 0; v < vertexCount; v++) {
        final z = c[v * 3 + 2];
        final x =
            c[v * 3] +
            inst.dx +
            (inst.sway == 0 ? 0 : inst.sway * (z > 0 ? z : 0));
        final yy = c[v * 3 + 1] + inst.dy - p.focus;
        final along = x * sin + yy * cos;
        px[v] = p.ox + (x * cos - yy * sin) * p.scale;
        py[v] = p.oy - (along * p.squash + z * p.lift) * p.scale;
        // Distance along the view ray: perpendicular to the screen direction
        // (squash, lift), i.e. .85 / .7 for the level path's oblique view.
        pd[v] = along * p.lift - z * p.squash;
      }
      final t = mesh.triangles;
      final group = mesh.groundGroup * 65536;
      final normals = mesh.faceNormals;
      final baseR = mesh.color.r, baseG = mesh.color.g, baseB = mesh.color.b;
      final pathColors = mesh.pathColorsFor(lighting);
      final shade = mesh.vertexShade;
      final glows = mesh.motion == 'glow';
      for (var f = 0; f < mesh.faceCount; f++) {
        final a = t[f * 3], b = t[f * 3 + 1], d = t[f * 3 + 2];
        final ya = py[a], yb = py[b], yd = py[d];
        if (cullHeight != null &&
            ((ya < -40 && yb < -40 && yd < -40) ||
                (ya > cullHeight + 40 &&
                    yb > cullHeight + 40 &&
                    yd > cullHeight + 40))) {
          continue;
        }
        if (cullWidth != null) {
          final xa = px[a], xb = px[b], xd = px[d];
          if ((xa < -40 && xb < -40 && xd < -40) ||
              (xa > cullWidth + 40 &&
                  xb > cullWidth + 40 &&
                  xd > cullWidth + 40)) {
            continue;
          }
        }
        final depth = (pd[a] + pd[b] + pd[d]) / 3;
        keys[count] = group + _quantised(depth);
        final o = count * 6;
        pos[o] = px[a];
        pos[o + 1] = ya;
        pos[o + 2] = px[b];
        pos[o + 3] = yb;
        pos[o + 4] = px[d];
        pos[o + 5] = yd;
        int face;
        if (shading == SceneShading.path) {
          face = pathColors[f];
        } else {
          final nx = normals[f * 3],
              ny = normals[f * 3 + 1],
              nz = normals[f * 3 + 2];
          // The model turns under a light that stays put relative to the viewer.
          final lx = nx * cos - ny * sin, ly = nx * sin + ny * cos;
          face = glows && lighting.lamps
              ? mesh.glowArgb(lighting)
              : lighting.shade(
                  baseR * _viewerGain,
                  baseG * _viewerGain,
                  baseB * _viewerGain,
                  lx,
                  ly,
                  nz,
                  gamma: false,
                );
        }
        if (useHaze && !glows) {
          // Far faces melt into the sky: aerial perspective.
          final k = ((depth - _hazeStart) / _hazeSpan).clamp(0.0, 1.0);
          if (k > 0) {
            face = _mix(face, hazeArgb, k * k * (3 - 2 * k) * hazeStrength);
          }
        }
        final co = count * 3;
        if (shade == null) {
          col[co] = face;
          col[co + 1] = face;
          col[co + 2] = face;
        } else {
          col[co] = _scale(face, shade[a]);
          col[co + 1] = _scale(face, shade[b]);
          col[co + 2] = _scale(face, shade[d]);
        }
        count++;
      }
    }
    return count;
  }

  /// Whether the whole mesh lies outside the viewport: its bounding box,
  /// projected, is clear of it by a margin that also covers sway and the
  /// swing of animated parts.
  static bool _outside(
    WorldMesh mesh,
    SceneInstance inst,
    SceneProjection p,
    double? width,
    double? height,
  ) {
    final b = mesh.bounds;
    final margin = mesh.anim == null ? 40.0 : 40.0 + p.scale * 1.8;
    final grow = mesh.anim == null ? 0.0 : 1.8;
    var minX = double.infinity, maxX = -double.infinity;
    var minY = double.infinity, maxY = -double.infinity;
    for (var i = 0; i < 8; i++) {
      final x = (i & 1 == 0 ? b[0] - grow : b[3] + grow) + inst.dx;
      final y = (i & 2 == 0 ? b[1] - grow : b[4] + grow) + inst.dy - p.focus;
      final z = i & 4 == 0 ? b[2] : b[5] + grow;
      final along = x * p.sinYaw + y * p.cosYaw;
      final sx = p.ox + (x * p.cosYaw - y * p.sinYaw) * p.scale;
      final sy = p.oy - (along * p.squash + z * p.lift) * p.scale;
      if (sx < minX) minX = sx;
      if (sx > maxX) maxX = sx;
      if (sy < minY) minY = sy;
      if (sy > maxY) maxY = sy;
    }
    if (width != null && (maxX < -margin || minX > width + margin)) return true;
    if (height != null && (maxY < -margin || minY > height + margin)) {
      return true;
    }
    return false;
  }

  // Haze starts at this depth along the view ray and is complete [_hazeSpan]
  // further: roughly the middle of the screen up to its far edge.
  static const _hazeStart = .5;
  static const _hazeSpan = 5.5;
}

/// The markers of a module's lamps ([lights]: x, y, z, radius) for the evening
/// and the night: a pool of light on the ground and a glow at the lamp, each
/// placed in the depth order of the scene. [dy] shifts the module along the
/// path; [canvasSize] skips what is far outside the picture.
List<SceneMarker> lightMarkers(
  List<List<double>> lights,
  SceneProjection p,
  WorldLighting lighting,
  ui.Size canvasSize, {
  double dy = 0,
}) {
  if (!lighting.lamps) return const [];
  final out = <SceneMarker>[];
  for (final l in lights) {
    final radius = l[3] * p.scale;
    final lamp = p.project(l[0], l[1] + dy, l[2]);
    if (lamp.dx < -radius * 2 ||
        lamp.dx > canvasSize.width + radius * 2 ||
        lamp.dy < -radius * 2 ||
        lamp.dy > canvasSize.height + radius * 2) {
      continue;
    }
    final ground = p.project(l[0], l[1] + dy, .1);
    out
      ..add(
        SceneMarker(
          l[0],
          l[1] + dy,
          .1,
          (c) => paintLightPool(c, ground, radius, lighting),
          ground: true,
        ),
      )
      ..add(
        SceneMarker(
          l[0],
          l[1] + dy,
          l[2],
          (c) => paintLightOrb(c, lamp, radius, lighting),
        ),
      );
  }
  return out;
}

/// Recorded pictures for one view state, addressed by animation phase. A new
/// key (the view changed) retires the old pictures; they are disposed one call
/// later so a layer that still references them is never affected.
final class PictureCache {
  Object? _key;
  final _pictures = <int, ui.Picture>{};
  final _retired = <ui.Picture>[];

  ui.Picture obtain(Object key, int slot, ui.Picture Function() record) {
    for (final picture in _retired) {
      picture.dispose();
    }
    _retired.clear();
    if (_key != key) {
      _retired.addAll(_pictures.values);
      _pictures.clear();
      _key = key;
    }
    return _pictures[slot] ??= record();
  }

  void dispose() {
    for (final picture in [..._pictures.values, ..._retired]) {
      picture.dispose();
    }
    _pictures.clear();
    _retired.clear();
  }
}
