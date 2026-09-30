import 'dart:convert';
import 'dart:math' as math;
import 'dart:ui' as ui;

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../../../../core/diagnostics/frame_stats.dart';
import '../../../../core/theme/app_colors.dart';
import '../../domain/catalog_models.dart';
import 'world_module.dart';

enum EcosystemWorld {
  forest('forest', 'Waldpfad', Color(0xFFE2E9DC)),
  meadow('meadow', 'Wiesenpfad', Color(0xFFEEF1D9)),
  alpine('alpine', 'Bergpfad', Color(0xFFE3EDF0));

  const EcosystemWorld(this.asset, this.title, this.background);
  final String asset, title;
  final Color background;

  /// One-word name for plaques and small tiles.
  String get shortName => switch (this) {
    forest => 'Wald',
    meadow => 'Wiese',
    alpine => 'Alpen',
  };

  static EcosystemWorld? forSlug(String slug) {
    final s = slug.toLowerCase();
    if (s.contains('alpen') ||
        s.contains('alpin') ||
        s.contains('berg') ||
        s.contains('mountain')) {
      return alpine;
    }
    if (s.contains('wiese') || s.contains('meadow')) return meadow;
    if (s.contains('wald') || s.contains('forest')) return forest;
    return null;
  }
}

/// Real, projected Blender mesh geometry. No native GL plugin or remote CDN.
/// Only the current module and its neighbours are rendered, regardless of size.
final class ModularForestView extends StatefulWidget {
  const ModularForestView({
    super.key,
    required this.levels,
    this.world = EcosystemWorld.forest,
    this.onLevelTap,
    this.finale,
  });
  final List<Level> levels;
  final EcosystemWorld world;
  final ValueChanged<Level>? onLevelTap;
  final Widget? finale;
  @override
  State<ModularForestView> createState() => _ModularForestViewState();
}

final class _ModularForestViewState extends State<ModularForestView>
    with SingleTickerProviderStateMixin {
  static final _modules = <EcosystemWorld, Future<WorldModule>>{};
  Future<WorldModule> get _module => _modules.putIfAbsent(
    widget.world,
    () => rootBundle
        .loadString('assets/worlds/${widget.world.asset}_module.json')
        .then(
          (s) => WorldModule.fromJson(jsonDecode(s) as Map<String, dynamic>),
        ),
  );
  late final AnimationController _clock = AnimationController(
    vsync: this,
    duration: const Duration(seconds: 6),
  );
  late double _position = _initialModule.toDouble();
  bool _paused = false;
  double _yaw = .12;
  final _frames = ValueNotifier<int>(0);
  int _lastFrameMs = -100;
  @override
  void initState() {
    super.initState();
    _clock.addListener(() {
      final now = _clock.lastElapsedDuration?.inMilliseconds ?? 0;
      if (now - _lastFrameMs >= 40 || now < _lastFrameMs) {
        _lastFrameMs = now;
        _frames.value++;
      }
    });
  }

  List<Level> get _levels =>
      [...widget.levels]..sort((a, b) => a.sequence.compareTo(b.sequence));
  int get _count => (widget.levels.length / 6).ceil();
  int get _initialModule {
    final i = _levels.indexWhere(
      (l) => l.isUnlocked && l.status != LevelStatus.completed,
    );
    return i < 0 ? 0 : i ~/ 6;
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    _updateMotion();
  }

  void _updateMotion() {
    if (_paused ||
        MediaQuery.disableAnimationsOf(context) ||
        !TickerMode.of(context)) {
      _clock.stop();
    } else if (!_clock.isAnimating) {
      _clock.repeat();
    }
  }

  @override
  void dispose() {
    _clock.dispose();
    _frames.dispose();
    super.dispose();
  }

  void _move(double value) => setState(
    () => _position = value.clamp(0, math.max(0, _count - 1)).toDouble(),
  );
  @override
  Widget build(BuildContext context) {
    final levels = _levels;
    if (levels.isEmpty) return const Center(child: Text('Noch keine Level.'));
    final position = _position.clamp(0, _count - 1).toDouble();
    final chapter = position.round();
    return Column(
      children: [
        Row(
          key: const ValueKey('level-list-ready'),
          children: [
            IconButton(
              key: const ValueKey('map-previous-chapter'),
              tooltip: 'Vorheriger Abschnitt',
              onPressed: chapter > 0 ? () => _move(chapter - 1.0) : null,
              icon: const Icon(Icons.chevron_left),
            ),
            Expanded(
              child: Text(
                '${widget.world.title} ${chapter + 1} / $_count · ${levels.length} Level',
                textAlign: TextAlign.center,
              ),
            ),
            IconButton(
              key: const ValueKey('map-next-chapter'),
              tooltip: 'Nächster Abschnitt',
              onPressed: chapter < _count - 1
                  ? () => _move(chapter + 1.0)
                  : null,
              icon: const Icon(Icons.chevron_right),
            ),
            IconButton(
              tooltip: _paused ? 'Bewegung einschalten' : 'Bewegung anhalten',
              onPressed: () {
                setState(() => _paused = !_paused);
                _updateMotion();
              },
              icon: Icon(_paused ? Icons.play_arrow : Icons.pause),
            ),
          ],
        ),
        Expanded(
          child: FutureBuilder<WorldModule>(
            key: ValueKey(widget.world),
            future: _module,
            builder: (context, snapshot) {
              if (snapshot.hasError) {
                return const Center(
                  child: Text(
                    'Die 3D-Welt konnte nicht geladen werden. Bitte öffne den Lernpfad erneut.',
                  ),
                );
              }
              if (!snapshot.hasData) {
                return const Center(child: CircularProgressIndicator());
              }
              final module = snapshot.data!;
              return LayoutBuilder(
                builder: (context, constraints) {
                  final size = Size(
                    constraints.maxWidth,
                    constraints.maxHeight,
                  );
                  final view = _Projection(size, position * 10, _yaw);
                  return ClipRect(
                    child: Stack(
                      fit: StackFit.expand,
                      children: [
                        Positioned.fill(
                          child: GestureDetector(
                            onPanUpdate: (d) {
                              setState(() {
                                _position =
                                    (position + d.delta.dy / (view.scale * 7))
                                        .clamp(0, _count - 1)
                                        .toDouble();
                                _yaw = (_yaw + d.delta.dx * .003).clamp(
                                  -.35,
                                  .35,
                                );
                              });
                            },
                            child: RepaintBoundary(
                              child: CustomPaint(
                                key: ValueKey('${widget.world.asset}-3d-world'),
                                painter: _ForestPainter(
                                  module,
                                  view,
                                  levels.length,
                                  _clock,
                                  MediaQuery.disableAnimationsOf(context),
                                  _frames,
                                  widget.world.background,
                                  levels.indexWhere(
                                    (l) =>
                                        l.isUnlocked &&
                                        l.status != LevelStatus.completed,
                                  ),
                                ),
                                child: const SizedBox.expand(),
                              ),
                            ),
                          ),
                        ),
                        for (
                          var m = math.max(0, chapter - 1);
                          m <= math.min(_count - 1, chapter + 1);
                          m++
                        )
                          for (
                            var slot = 0;
                            slot < 6 && m * 6 + slot < levels.length;
                            slot++
                          )
                            _station(
                              levels[m * 6 + slot],
                              view.project(
                                module.slots[slot][0],
                                module.slots[slot][1] + m * 10,
                                .40,
                              ),
                              size,
                            ),
                      ],
                    ),
                  );
                },
              );
            },
          ),
        ),
        if (_count > 1)
          Slider(
            label: 'Abschnitt ${chapter + 1}',
            semanticFormatterCallback: (v) =>
                'Abschnitt ${v.round() + 1} von $_count',
            min: 0,
            max: (_count - 1).toDouble(),
            value: position,
            onChanged: _move,
          ),
        if (chapter == _count - 1 && widget.finale != null)
          SizedBox(
            height: 150,
            child: SingleChildScrollView(child: widget.finale!),
          ),
        Padding(
          padding: const EdgeInsets.only(bottom: 8),
          child: Text(
            'Ziehen: die Welt erkunden · Level antippen',
            style: Theme.of(context).textTheme.bodySmall,
          ),
        ),
      ],
    );
  }

  Widget _station(Level level, Offset at, Size viewport) {
    // Omit off-screen hit/semantics targets, not merely their clipped pixels.
    if (at.dx < 24 ||
        at.dx > viewport.width - 24 ||
        at.dy < 24 ||
        at.dy > viewport.height - 24) {
      return const SizedBox.shrink();
    }
    return Positioned(
      left: at.dx - 24,
      top: at.dy - 24,
      width: 48,
      height: 48,
      child: Semantics(
        label:
            'Level ${level.sequence}: ${level.title}. ${level.isUnlocked ? 'Spielbar' : 'Gesperrt'}',
        button: true,
        enabled: level.isUnlocked,
        child: Tooltip(
          message: level.title,
          child: Material(
            color: level.status == LevelStatus.completed
                ? AppColors.accent300
                : level.isUnlocked
                ? AppColors.neutral100
                : AppColors.sage300,
            elevation: 3,
            shape: const CircleBorder(),
            child: InkWell(
              key: ValueKey('level-card-${level.id}'),
              customBorder: const CircleBorder(),
              onTap: level.isUnlocked && widget.onLevelTap != null
                  ? () => widget.onLevelTap!(level)
                  : null,
              child: Center(
                child: level.isUnlocked
                    ? Text(
                        '${level.sequence}',
                        style: const TextStyle(
                          fontWeight: FontWeight.w800,
                          color: AppColors.sage900,
                        ),
                      )
                    : const Icon(
                        Icons.lock_outline,
                        size: 18,
                        color: AppColors.sage800,
                      ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}

final class _Projection {
  _Projection(this.size, this.focus, this.yaw);
  final Size size;
  final double focus, yaw;
  // Keep adjacent 48px level targets separated on narrow phone screens.
  // Peripheral scenery may be clipped; the path remains in the viewport.
  double get scale =>
      math.max(52, math.min(size.width / 12.5, size.height / 8.5));
  Offset project(double x, double y, double z) {
    final yy = y - focus;
    return Offset(
      size.width / 2 + (x * math.cos(yaw) - yy * math.sin(yaw)) * scale,
      size.height / 2 -
          (x * math.sin(yaw) + yy * math.cos(yaw)) * .7 * scale -
          z * .85 * scale,
    );
  }

  double depth(double x, double y, double z) =>
      (x * math.sin(yaw) + (y - focus) * math.cos(yaw)) * .85 - z * .7;
}

final class _Face {
  _Face(this.points, this.depth, this.color);
  final List<Offset> points;
  final double depth;
  final Color color;
}

final class _ForestPainter extends CustomPainter {
  _ForestPainter(
    this.module,
    this.view,
    this.levelCount,
    this.clock,
    this.reduceMotion,
    Listenable frames,
    this.background,
    this.currentIndex,
  ) : super(repaint: frames);
  final WorldModule module;
  final _Projection view;
  final int levelCount;
  final Animation<double> clock;
  final bool reduceMotion;
  final int currentIndex;
  final Color background;
  @override
  void paint(Canvas canvas, Size size) {
    final timer = Stopwatch()..start();
    canvas.drawColor(background, BlendMode.src);
    final faces = <_Face>[];
    final center = (view.focus / 10).round();
    final phase = reduceMotion ? 0.0 : clock.value * math.pi * 2;
    for (
      var m = math.max(0, center - 1);
      m <= math.min((levelCount / 6).ceil() - 1, center + 1);
      m++
    ) {
      for (final mesh in module.meshes) {
        if (mesh.slot != null && m * 6 + mesh.slot! >= levelCount) continue;
        if (mesh.motion == 'ranger' &&
            (currentIndex < 0 || currentIndex ~/ 6 != m)) {
          continue;
        }
        final ranger = mesh.motion == 'ranger'
            ? module.slots[currentIndex % 6]
            : null;
        final vs = mesh.vertices.map((v) {
          final x =
              v[0] +
              (ranger == null ? 0 : ranger[0] + .65) +
              (mesh.motion == 'tree' || mesh.motion == 'plant'
                  ? math.sin(phase + m) * .022 * math.max(0, v[2])
                  : 0);
          final y =
              v[1] +
              (ranger == null ? 0 : ranger[1] - .2) +
              m * 10 +
              (mesh.motion == 'water' ? math.sin(phase) * .17 : 0);
          return [x, y, v[2]];
        }).toList();
        final ps = vs.map((v) => view.project(v[0], v[1], v[2])).toList();
        for (final indices in mesh.faces) {
          final points = indices.map((i) => ps[i]).toList();
          if (points.every((p) => p.dy < -40) ||
              points.every((p) => p.dy > size.height + 40)) {
            continue;
          }
          final a = vs[indices[0]], b = vs[indices[1]], c = vs[indices[2]];
          final ux = b[0] - a[0], uy = b[1] - a[1], uz = b[2] - a[2];
          final vx = c[0] - a[0], vy = c[1] - a[1], vz = c[2] - a[2];
          final nx = uy * vz - uz * vy,
              ny = uz * vx - ux * vz,
              nz = ux * vy - uy * vx;
          final length = math.sqrt(nx * nx + ny * ny + nz * nz);
          final light =
              .70 +
              .30 *
                  (length == 0
                      ? 0
                      : ((-nx * .3 - ny * .4 + nz * .85) / length).clamp(0, 1));
          final base = mesh.color;
          final color = Color.fromRGBO(
            (math.pow(base.r * light, 1 / 2.2) * 255).round(),
            (math.pow(base.g * light, 1 / 2.2) * 255).round(),
            (math.pow(base.b * light, 1 / 2.2) * 255).round(),
            1,
          );
          faces.add(
            _Face(
              points,
              (view.depth(a[0], a[1], a[2]) +
                          view.depth(b[0], b[1], b[2]) +
                          view.depth(c[0], c[1], c[2])) /
                      3 +
                  _groundDepth(mesh.name),
              color,
            ),
          );
        }
      }
    }
    faces.sort((a, b) => b.depth.compareTo(a.depth));
    final points = <Offset>[], colors = <Color>[];
    for (final face in faces) {
      points.addAll(face.points);
      colors.addAll([face.color, face.color, face.color]);
    }
    if (points.isNotEmpty) {
      final vertices = ui.Vertices(
        ui.VertexMode.triangles,
        points,
        colors: colors,
      );
      canvas.drawVertices(vertices, BlendMode.srcOver, Paint());
      vertices.dispose();
    }
    FrameStats.note('path-paint', timer.elapsed);
  }

  // Terrain is a non-intersecting height-layer system. Draw its broad planes
  // before props rather than sorting their centroids against individual trees.
  double _groundDepth(String name) {
    if (name == 'earth' || name == 'grass') return 1000000;
    if (name.startsWith('Sandy stream')) return 900000;
    if (name.startsWith('Flowing woodland')) return 800000;
    if (name.startsWith('Animated water')) return 700000;
    return 0;
  }

  @override
  bool shouldRepaint(covariant _ForestPainter old) =>
      old.view != view ||
      old.module != module ||
      old.levelCount != levelCount ||
      old.background != background ||
      old.reduceMotion != reduceMotion;
}
