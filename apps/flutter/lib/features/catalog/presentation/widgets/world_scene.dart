import 'dart:math' as math;
import 'dart:typed_data';
import 'dart:ui' as ui;

import 'world_lighting.dart';
import 'world_module.dart';

/// One mesh placed into a scene: shifted by [dx]/[dy] and swaying sideways in
/// proportion to its height by [sway] (trees and plants).
final class SceneInstance {
  const SceneInstance(this.mesh, {this.dx = 0, this.dy = 0, this.sway = 0});
  final WorldMesh mesh;
  final double dx, dy, sway;
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
  static Float64List _keys = Float64List(0);
  static Float32List _pos = Float32List(0);
  static Int32List _col = Int32List(0);

  // The vitrine shows colours without the display gamma the path uses, so the
  // light is lifted a little to keep both views equally bright.
  static const _viewerGain = 1.22;
  static const _idxRange = 1048576.0; // faces per scene < 2^20
  static const _depthRange = 40.0;

  /// [cullHeight]: skip faces that lie completely above or below the viewport.
  static ui.Vertices? build(
    List<SceneInstance> instances,
    SceneProjection p, {
    SceneShading shading = SceneShading.path,
    WorldLighting? lighting,
    double? cullHeight,
  }) {
    lighting ??= WorldLighting.of(DayPhase.noon);
    var total = 0, maxVertices = 0;
    for (final i in instances) {
      total += i.mesh.faceCount;
      maxVertices = math.max(maxVertices, i.mesh.vertexCount);
    }
    if (total == 0) return null;
    if (_px.length < maxVertices) {
      _px = Float32List(maxVertices);
      _py = Float32List(maxVertices);
      _pd = Float32List(maxVertices);
    }
    if (_keys.length < total) {
      _keys = Float64List(total);
      _pos = Float32List(total * 6);
      _col = Int32List(total);
    }
    final cos = p.cosYaw, sin = p.sinYaw;
    final px = _px, py = _py, pd = _pd;
    final keys = _keys, pos = _pos, col = _col;
    var count = 0;

    for (final inst in instances) {
      final mesh = inst.mesh;
      final c = mesh.coords;
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
      final group = mesh.groundGroup * 65536.0;
      final normals = mesh.faceNormals;
      final baseR = mesh.color.r, baseG = mesh.color.g, baseB = mesh.color.b;
      final pathColors = mesh.pathColorsFor(lighting);
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
        final depth = (pd[a] + pd[b] + pd[d]) / 3;
        final q = ((depth + _depthRange) / (2 * _depthRange) * 65535)
            .clamp(0, 65535)
            .floorToDouble();
        keys[count] = (group + q) * _idxRange + count;
        final o = count * 6;
        pos[o] = px[a];
        pos[o + 1] = ya;
        pos[o + 2] = px[b];
        pos[o + 3] = yb;
        pos[o + 4] = px[d];
        pos[o + 5] = yd;
        if (shading == SceneShading.path) {
          col[count] = pathColors[f];
        } else {
          final nx = normals[f * 3],
              ny = normals[f * 3 + 1],
              nz = normals[f * 3 + 2];
          // The model turns under a light that stays put relative to the viewer.
          final lx = nx * cos - ny * sin, ly = nx * sin + ny * cos;
          col[count] = mesh.motion == 'glow' && lighting.lamps
              ? (lighting.phase == DayPhase.night ? 0xFFFFE08A : 0xFFFFC878)
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
        count++;
      }
    }
    if (count == 0) return null;

    final sorted = Float64List.sublistView(keys, 0, count)..sort();
    final outPos = Float32List(count * 6);
    final outCol = Int32List(count * 3);
    // Far to near: the largest key (highest group, deepest) is painted first.
    for (var i = 0; i < count; i++) {
      final src = (sorted[count - 1 - i] % _idxRange).toInt();
      final so = src * 6, oo = i * 6;
      outPos[oo] = pos[so];
      outPos[oo + 1] = pos[so + 1];
      outPos[oo + 2] = pos[so + 2];
      outPos[oo + 3] = pos[so + 3];
      outPos[oo + 4] = pos[so + 4];
      outPos[oo + 5] = pos[so + 5];
      final colour = col[src];
      outCol[i * 3] = colour;
      outCol[i * 3 + 1] = colour;
      outCol[i * 3 + 2] = colour;
    }
    return ui.Vertices.raw(ui.VertexMode.triangles, outPos, colors: outCol);
  }
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
