import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../../app/app_dependencies.dart';
import '../../../core/result.dart';
import '../../../design_system/async_state_view.dart';
import '../../catalog/domain/catalog_models.dart';
import '../../catalog/presentation/widgets/plant_index_card.dart';

/// Session-only self-assessment using published profiles, never quiz solutions.
final class PracticeScreen extends StatefulWidget {
  const PracticeScreen({
    super.key,
    required this.dependencies,
    required this.ecosystemId,
  });

  final AppDependencies dependencies;
  final String ecosystemId;

  @override
  State<PracticeScreen> createState() => _PracticeScreenState();
}

enum _Phase { study, recall, revealed }

final class _PracticeScreenState extends State<PracticeScreen> {
  late Future<Result<_PracticeContent>> _future = _load();
  List<Plant>? _round;
  final List<Plant> _repeat = [];
  int _index = 0;
  int _known = 0;
  _Phase _phase = _Phase.study;

  Future<Result<_PracticeContent>> _load() async {
    final result = await widget.dependencies.loadLevels(widget.ecosystemId);
    if (result case Failure<List<Level>>(:final failure)) {
      return Result.failure(failure);
    }
    final levels = [...result.valueOrNull!]
      ..sort((a, b) => a.sequence.compareTo(b.sequence));
    final accessible = levels.where((level) => level.isUnlocked).toList();
    final ids = accessible.expand((level) => level.plantIds).toSet();
    final plants = <Plant>[];
    for (final id in ids) {
      final result = await widget.dependencies.loadPlant(id);
      if (result case Failure<Plant>(:final failure)) {
        return Result.failure(failure);
      }
      final plant = result.valueOrNull!;
      if (plant.profileCards.any(_usable)) plants.add(plant);
    }
    return Result.success(
      _PracticeContent(
        plants,
        locked: levels.isNotEmpty && accessible.isEmpty,
        skipped: ids.length - plants.length,
      ),
    );
  }

  bool _usable(PlantProfileCard card) =>
      card.heading.trim().isNotEmpty && card.text.trim().isNotEmpty;

  void _reset() {
    _round = null;
    _repeat.clear();
    _index = 0;
    _known = 0;
    _phase = _Phase.study;
  }

  void _reload() => setState(() {
    _reset();
    _future = _load();
  });

  @override
  void didUpdateWidget(covariant PracticeScreen oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.ecosystemId != widget.ecosystemId ||
        oldWidget.dependencies != widget.dependencies) {
      _reset();
      _future = _load();
    }
  }

  void _assess(Plant plant, bool known) {
    // A rapid second tap must not skip the next card or count twice.
    if (_phase != _Phase.revealed) return;
    setState(() {
      if (known) {
        _known++;
      } else {
        _repeat.add(plant);
      }
      _index++;
      _phase = _Phase.study;
    });
  }

  void _restart(List<Plant> plants) => setState(() {
    final next = List<Plant>.of(plants);
    _reset();
    _round = next;
  });

  Widget _message(String message) => Center(
    child: SingleChildScrollView(
      padding: const EdgeInsets.all(24),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(message, textAlign: TextAlign.center),
          const SizedBox(height: 16),
          OutlinedButton(onPressed: _reload, child: const Text('Erneut laden')),
        ],
      ),
    ),
  );

  @override
  Widget build(BuildContext context) => Scaffold(
    appBar: AppBar(
      title: const Text('Karteikarten üben'),
      leading: IconButton(
        tooltip: 'Zum Lernpfad',
        onPressed: () => context.go(
          '/ecosystems/${Uri.encodeComponent(widget.ecosystemId)}',
        ),
        icon: const Icon(Icons.arrow_back),
      ),
    ),
    body: FutureBuilder<Result<_PracticeContent>>(
      future: _future,
      builder: (context, snapshot) {
        if (snapshot.connectionState != ConnectionState.done) {
          return const AsyncStateView(kind: AsyncViewKind.loading);
        }
        if (snapshot.hasError) {
          return _message(
            'Die Karteikarten konnten nicht geladen werden. Prüfe deine Verbindung und versuche es erneut.',
          );
        }
        final result = snapshot.data;
        if (result case Failure<_PracticeContent>(:final failure)) {
          return AsyncStateView(
            kind: AsyncViewKind.recoverableError,
            failure: failure,
            onRetry: _reload,
          );
        }
        final content = result?.valueOrNull;
        if (content == null) {
          return _message('Die Karteikarten sind gerade nicht verfügbar.');
        }
        if (content.locked) {
          return _message(
            'Die Level dieses Ökosystems sind noch gesperrt. Schalte zuerst ein Level im Lernpfad frei.',
          );
        }
        if (content.plants.isEmpty) {
          return _message(
            'In den freigeschalteten Leveln gibt es noch keine veröffentlichten Steckbriefabschnitte zum Üben.',
          );
        }
        final round = _round ?? content.plants;
        final finished = _index >= round.length;
        final plant = finished ? null : round[_index];
        final card = plant?.profileCards.firstWhere(_usable);
        return SingleChildScrollView(
          key: ValueKey(
            '${widget.ecosystemId}-$_index-${_phase.name}-$finished',
          ),
          padding: const EdgeInsets.all(20),
          child: Center(
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 920),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  const Text(
                    'Selbsteinschätzung · keine Punkte oder Levelabschlüsse. Deine Angaben bleiben nur in dieser Sitzung; beim Verlassen werden sie verworfen.',
                  ),
                  const SizedBox(height: 16),
                  LinearProgressIndicator(
                    value: finished ? 1 : _index / round.length,
                    minHeight: 6,
                    borderRadius: BorderRadius.circular(8),
                    semanticsLabel: 'Fortschritt der Übungsrunde',
                    semanticsValue: '$_index von ${round.length} Pflanzen',
                  ),
                  const SizedBox(height: 20),
                  if (finished) ...[
                    Semantics(
                      header: true,
                      child: Text(
                        'Übungsrunde beendet',
                        style: Theme.of(context).textTheme.headlineSmall,
                      ),
                    ),
                    const SizedBox(height: 12),
                    Text(
                      'Deine Einschätzung: $_known von ${round.length} gewusst · ${_repeat.length} noch üben.',
                    ),
                    const SizedBox(height: 16),
                    if (_repeat.isNotEmpty)
                      FilledButton(
                        onPressed: () => _restart(_repeat),
                        child: const Text('Noch üben wiederholen'),
                      ),
                    OutlinedButton(
                      onPressed: () => _restart(content.plants),
                      child: const Text('Alle Karten wiederholen'),
                    ),
                  ] else ...[
                    Semantics(
                      liveRegion: true,
                      child: Text(
                        'Pflanze ${_index + 1} von ${round.length} · ${_phase == _Phase.study ? 'Ansehen' : 'Erinnern'}',
                      ),
                    ),
                    if (content.skipped > 0)
                      Text(
                        '${content.skipped} Pflanzen ohne vollständigen Steckbriefabschnitt ausgelassen.',
                      ),
                    const SizedBox(height: 16),
                    if (_phase == _Phase.study) ...[
                      PlantIndexCard(plant: plant!),
                      const SizedBox(height: 20),
                      FilledButton(
                        onPressed: () => setState(() => _phase = _Phase.recall),
                        child: const Text('Karte verdecken & kurz erinnern'),
                      ),
                    ] else ...[
                      Text(
                        plant!.commonName.isEmpty
                            ? plant.scientificName
                            : plant.commonName,
                        style: Theme.of(context).textTheme.headlineSmall,
                      ),
                      const SizedBox(height: 16),
                      Text(
                        'Was weißt du über „${card!.heading}“ bei dieser Pflanze?',
                        style: Theme.of(context).textTheme.titleLarge,
                      ),
                      const SizedBox(height: 12),
                      const Text(
                        'Rufe dir die wichtigsten Punkte ins Gedächtnis. Vergleiche anschließend selbst mit dem Steckbrief.',
                      ),
                      const SizedBox(height: 20),
                      if (_phase == _Phase.recall)
                        FilledButton(
                          onPressed: () =>
                              setState(() => _phase = _Phase.revealed),
                          child: const Text('Steckbrieftext aufdecken'),
                        ),
                      if (_phase == _Phase.revealed) ...[
                        const Text(
                          'Zum Vergleichen: Originaltext aus dem Steckbrief',
                        ),
                        const SizedBox(height: 8),
                        SelectableText(card.text),
                        const SizedBox(height: 20),
                        Wrap(
                          spacing: 12,
                          runSpacing: 12,
                          children: [
                            FilledButton(
                              onPressed: () => _assess(plant, true),
                              child: const Text('Gewusst'),
                            ),
                            OutlinedButton(
                              onPressed: () => _assess(plant, false),
                              child: const Text('Noch üben'),
                            ),
                          ],
                        ),
                      ],
                    ],
                  ],
                ],
              ),
            ),
          ),
        );
      },
    ),
  );
}

final class _PracticeContent {
  const _PracticeContent(
    this.plants, {
    required this.locked,
    required this.skipped,
  });
  final List<Plant> plants;
  final bool locked;
  final int skipped;
}
