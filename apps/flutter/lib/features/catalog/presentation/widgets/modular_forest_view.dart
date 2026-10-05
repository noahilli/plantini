import 'dart:convert';
import 'dart:math' as math;
import 'dart:ui' as ui;

import 'package:flutter/material.dart';
import 'package:flutter/gestures.dart';
import 'package:flutter/services.dart';

import '../../../../core/diagnostics/frame_stats.dart';
import '../../../../core/theme/app_colors.dart';
import '../../domain/catalog_models.dart';
import '../../../character/presentation/widgets/explorer_roster.dart';
import 'world_lighting.dart';
import 'world_module.dart';
import 'world_scene.dart';

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
/// Animation frames per 6 s cycle that are recorded once and replayed.
const _phases = 16;

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
  final _cache = PictureCache();
  int _lastPhase = -1;
  @override
  void initState() {
    super.initState();
    // Repaint only when the animation moves to the next of _phases recorded
    // frames, not on every tick: sway and water are slow, and a replayed
    // picture costs almost nothing.
    DayClock.phase.addListener(_dayChanged);
    PlayerLook.id.addListener(_dayChanged);
    _clock.addListener(() {
      final phase = (_clock.value * _phases).floor() % _phases;
      if (phase != _lastPhase) {
        _lastPhase = phase;
        _frames.value++;
      }
    });
  }

  void _dayChanged() {
    if (mounted) setState(() {});
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
    DayClock.phase.removeListener(_dayChanged);
    PlayerLook.id.removeListener(_dayChanged);
    _clock.dispose();
    _frames.dispose();
    _cache.dispose();
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
    return Align(
      alignment: Alignment.topCenter,
      child: ConstrainedBox(
        constraints: const BoxConstraints(maxWidth: 920, maxHeight: 760),
        child: Column(
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
                  tooltip: _paused
                      ? 'Bewegung einschalten'
                      : 'Bewegung anhalten',
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
                              child: Listener(
                                onPointerSignal: (event) {
                                  if (event is PointerScrollEvent) {
                                    GestureBinding
                                        .instance
                                        .pointerSignalResolver
                                        .register(event, (event) {
                                          final scroll =
                                              event as PointerScrollEvent;
                                          _move(
                                            position +
                                                scroll.scrollDelta.dy / 600,
                                          );
                                        });
                                  }
                                },
                                child: GestureDetector(
                                  onPanUpdate: (d) {
                                    setState(() {
                                      _position =
                                          (position +
                                                  d.delta.dy / (view.scale * 7))
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
                                      key: ValueKey(
                                        '${widget.world.asset}-3d-world',
                                      ),
                                      painter: _ForestPainter(
                                        module,
                                        view,
                                        levels.length,
                                        _clock,
                                        MediaQuery.disableAnimationsOf(context),
                                        _frames,
                                        widget.world.background,
                                        WorldLighting.of(DayClock.phase.value),
                                        _cache,
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
                            ),
                            if (module.fireflies != null &&
                                WorldLighting.of(DayClock.phase.value).lamps)
                              Positioned.fill(
                                child: IgnorePointer(
                                  child: RepaintBoundary(
                                    child: CustomPaint(
                                      painter: _FireflyPainter(
                                        module.fireflies!,
                                        view,
                                        math.max(0, chapter - 1),
                                        math.min(_count - 1, chapter + 1),
                                        _clock,
                                        DayClock.phase.value == DayPhase.night
                                            ? 1
                                            : .4,
                                        MediaQuery.disableAnimationsOf(context),
                                      ),
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
        ),
      ),
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
      child: DecoratedBox(
        // Station lanterns glow in the evening and at night.
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          boxShadow: [
            if (WorldLighting.of(DayClock.phase.value).lamps &&
                level.isUnlocked)
              BoxShadow(
                color: const Color(0xAAFFC46B),
                blurRadius: DayClock.phase.value == DayPhase.night ? 22 : 14,
                spreadRadius: DayClock.phase.value == DayPhase.night ? 4 : 1,
              ),
          ],
        ),
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

final class _ForestPainter extends CustomPainter {
  _ForestPainter(
    this.module,
    this.view,
    this.levelCount,
    this.clock,
    this.reduceMotion,
    Listenable frames,
    this.background,
    this.lighting,
    this.cache,
    this.currentIndex,
  ) : super(repaint: frames);
  final WorldModule module;
  final _Projection view;
  final int levelCount;
  final Animation<double> clock;
  final bool reduceMotion;
  final int currentIndex;
  final Color background;
  final WorldLighting lighting;
  final PictureCache cache;

  @override
  void paint(Canvas canvas, Size size) {
    final timer = Stopwatch()..start();
    final phase = reduceMotion ? 0 : (clock.value * _phases).floor() % _phases;
    // Same view state, same animation phase: replay the recorded picture.
    final key = (
      module,
      view.size,
      view.focus,
      view.yaw,
      levelCount,
      currentIndex,
      background,
      lighting.phase,
      PlayerLook.cacheKey,
    );
    final picture = cache.obtain(key, phase, () => _record(size, phase));
    canvas.drawPicture(picture);
    FrameStats.note('path-paint', timer.elapsed);
  }

  ui.Picture _record(Size size, int phaseIndex) {
    final recorder = ui.PictureRecorder();
    final canvas = Canvas(recorder);
    paintSkyBackdrop(canvas, size, lighting, background);
    final phase = reduceMotion ? 0.0 : phaseIndex / _phases * math.pi * 2;
    final center = (view.focus / 10).round();
    final instances = <SceneInstance>[];
    for (
      var m = math.max(0, center - 1);
      m <= math.min((levelCount / 6).ceil() - 1, center + 1);
      m++
    ) {
      for (final mesh in PlayerLook.meshesFor(module)) {
        if (mesh.slot != null && m * 6 + mesh.slot! >= levelCount) continue;
        if (mesh.motion == 'ranger' &&
            (currentIndex < 0 || currentIndex ~/ 6 != m)) {
          continue;
        }
        final ranger = mesh.motion == 'ranger'
            ? module.slots[currentIndex % 6]
            : null;
        final dx = ranger == null ? 0.0 : ranger[0] + .65;
        final dy =
            (ranger == null ? 0.0 : ranger[1] - .2) +
            m * 10 +
            (mesh.motion == 'water' ? math.sin(phase) * .17 : 0);
        instances.add(
          SceneInstance(
            mesh,
            dx: dx,
            dy: dy,
            sway: mesh.motion == 'tree' || mesh.motion == 'plant'
                ? math.sin(phase + m) * .022
                : 0,
          ),
        );
        if (mesh.motion == 'tree') {
          final shadow = mesh.shadowFor(lighting);
          if (shadow != null) {
            instances.add(SceneInstance(shadow, dx: dx, dy: dy));
          }
        }
      }
      // The player (or the default ranger) casts one shadow as a whole.
      if (currentIndex >= 0 && currentIndex ~/ 6 == m) {
        final player =
            PlayerLook.shadow(lighting) ??
            WorldMesh.shadowOf(
              [
                for (final mesh in module.meshes)
                  if (mesh.motion == 'ranger') mesh,
              ],
              lighting,
              'ranger',
            );
        final at = module.slots[currentIndex % 6];
        if (player != null) {
          instances.add(
            SceneInstance(player, dx: at[0] + .65, dy: at[1] - .2 + m * 10),
          );
        }
      }
    }
    final vertices = SceneBuilder.build(
      instances,
      SceneProjection(
        yaw: view.yaw,
        focus: view.focus,
        scale: view.scale,
        ox: size.width / 2,
        oy: size.height / 2,
      ),
      lighting: lighting,
      cullHeight: size.height,
    );
    if (vertices != null) {
      canvas.drawVertices(vertices, BlendMode.srcOver, Paint());
      vertices.dispose();
    }
    // Lit windows and lanterns of every module in view glow in the evening and at night.
    for (
      var m = math.max(0, center - 1);
      m <= math.min((levelCount / 6).ceil() - 1, center + 1);
      m++
    ) {
      paintLightHalos(
        canvas,
        size,
        module.lights,
        view.project,
        view.scale,
        lighting,
        dy: m * 10.0,
      );
    }
    return recorder.endRecording();
  }

  @override
  bool shouldRepaint(covariant _ForestPainter old) =>
      old.view != view ||
      old.module != module ||
      old.levelCount != levelCount ||
      old.background != background ||
      old.lighting != lighting ||
      old.reduceMotion != reduceMotion;
}

/// Fireflies over the meadow: a few small blinking dots per visible module,
/// redrawn every frame (they are far cheaper than the recorded world).
final class _FireflyPainter extends CustomPainter {
  _FireflyPainter(
    this.field,
    this.view,
    this.first,
    this.last,
    this.clock,
    this.share,
    this.still,
  ) : super(repaint: clock);

  final FireflyField field;
  final _Projection view;
  final int first, last;
  final Animation<double> clock;
  final double share;
  final bool still;

  @override
  void paint(Canvas canvas, Size size) {
    final phase = still ? .35 : clock.value;
    for (var m = first; m <= last; m++) {
      paintFireflies(
        canvas,
        field,
        view.project,
        view.scale,
        phase,
        dy: m * 10.0,
        share: share,
        salt: m,
      );
    }
  }

  @override
  bool shouldRepaint(_FireflyPainter old) =>
      old.view.focus != view.focus ||
      old.view.yaw != view.yaw ||
      old.view.size != view.size ||
      old.first != first ||
      old.last != last ||
      old.share != share ||
      old.still != still;
}
