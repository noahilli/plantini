import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../../app/app_dependencies.dart';
import '../../../core/result.dart';
import '../../../design_system/async_state_view.dart';
import '../../catalog/domain/catalog_models.dart';
import '../../catalog/presentation/widgets/plant_index_card.dart';

/// Unlimited browsing of published ecosystem plants, independent of game locks.
/// Recall is optional self-assessment and never modifies level progress.
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
  late Future<Result<List<Plant>>> _future = _load();
  int _index = 0;
  int _round = 1;
  _Phase _phase = _Phase.study;
  final Map<String, bool> _assessments = {};

  Future<Result<List<Plant>>> _load() async {
    final result = await widget.dependencies.loadLevels(widget.ecosystemId);
    if (result case Failure<List<Level>>(:final failure)) {
      return Result.failure(failure);
    }
    final levels = [...result.valueOrNull!]
      ..sort((a, b) => a.sequence.compareTo(b.sequence));
    // Locks constrain playing a level, not reading its published plant profile.
    final ids = levels.expand((level) => level.plantIds).toSet();
    final plants = <Plant>[];
    for (final id in ids) {
      final result = await widget.dependencies.loadPlant(id);
      if (result case Failure<Plant>(:final failure)) {
        return Result.failure(failure);
      }
      plants.add(
        result.valueOrNull!,
      ); // Even profiles without recall notes remain browsable.
    }
    return Result.success(plants);
  }

  void _reset() {
    _index = 0;
    _round = 1;
    _phase = _Phase.study;
    _assessments.clear();
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

  void _move(int delta, int count) => setState(() {
    if (delta > 0 && _index == count - 1) {
      _round++;
      _assessments.clear();
    }
    _index = (_index + delta) % count;
    _phase = _Phase.study;
  });

  void _assess(Plant plant, bool known, int count) {
    if (_phase != _Phase.revealed) return;
    _assessments[plant.id] = known;
    _move(1, count);
  }

  PlantProfileCard? _recall(Plant plant) {
    final cards = plant.profileCards
        .where((c) => c.heading.trim().isNotEmpty && c.text.trim().isNotEmpty)
        .toList();
    if (cards.isNotEmpty) return cards[(_round - 1) % cards.length];
    if (plant.description.trim().isNotEmpty) {
      return PlantProfileCard(
        heading: 'Auf einen Blick',
        text: plant.description,
      );
    }
    return null;
  }

  Widget _message(String text) => Center(
    child: SingleChildScrollView(
      padding: const EdgeInsets.all(24),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(text, textAlign: TextAlign.center),
          const SizedBox(height: 16),
          OutlinedButton(onPressed: _reload, child: const Text('Erneut laden')),
        ],
      ),
    ),
  );

  @override
  Widget build(BuildContext context) => Scaffold(
    appBar: AppBar(
      title: const Text('Alle Pflanzenkarten'),
      leading: IconButton(
        tooltip: 'Zum Lernpfad',
        onPressed: () => context.go(
          '/ecosystems/${Uri.encodeComponent(widget.ecosystemId)}',
        ),
        icon: const Icon(Icons.arrow_back),
      ),
    ),
    body: FutureBuilder<Result<List<Plant>>>(
      future: _future,
      builder: (context, snapshot) {
        if (snapshot.connectionState != ConnectionState.done) {
          return const AsyncStateView(kind: AsyncViewKind.loading);
        }
        if (snapshot.hasError) {
          return _message(
            'Die Karten konnten nicht geladen werden. Prüfe deine Verbindung und versuche es erneut.',
          );
        }
        if (snapshot.data case Failure<List<Plant>>(:final failure)) {
          return AsyncStateView(
            kind: AsyncViewKind.recoverableError,
            failure: failure,
            onRetry: _reload,
          );
        }
        final plants = snapshot.data?.valueOrNull;
        if (plants == null || plants.isEmpty) {
          return _message(
            'In diesem Ökosystem sind noch keine Pflanzenkarten veröffentlicht.',
          );
        }
        final plant = plants[_index];
        final card = _recall(plant);
        return Column(
          children: [
            Padding(
              padding: const EdgeInsets.fromLTRB(16, 8, 16, 8),
              child: Column(
                children: [
                  const Text(
                    'Alle veröffentlichten Pflanzen · unabhängig vom Levelstand',
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 8),
                  Row(
                    children: [
                      IconButton(
                        tooltip: 'Vorherige Karte',
                        onPressed: () => _move(-1, plants.length),
                        icon: const Icon(Icons.chevron_left),
                      ),
                      Expanded(
                        child: Semantics(
                          liveRegion: true,
                          child: Text(
                            'Runde $_round · Karte ${_index + 1} von ${plants.length}',
                            textAlign: TextAlign.center,
                          ),
                        ),
                      ),
                      IconButton(
                        tooltip: 'Nächste Karte',
                        onPressed: () => _move(1, plants.length),
                        icon: const Icon(Icons.chevron_right),
                      ),
                    ],
                  ),
                  LinearProgressIndicator(
                    value: (_index + 1) / plants.length,
                    semanticsLabel: 'Position in der Kartenrunde',
                    semanticsValue: '${_index + 1} von ${plants.length}',
                  ),
                ],
              ),
            ),
            Expanded(
              child: SingleChildScrollView(
                key: ValueKey(
                  '${widget.ecosystemId}-$_round-$_index-${_phase.name}',
                ),
                padding: const EdgeInsets.fromLTRB(20, 12, 20, 24),
                child: Center(
                  child: ConstrainedBox(
                    constraints: const BoxConstraints(maxWidth: 1040),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        if (_phase == _Phase.study) ...[
                          PlantIndexCard(plant: plant),
                          const SizedBox(height: 20),
                          if (card != null)
                            FilledButton.icon(
                              onPressed: () =>
                                  setState(() => _phase = _Phase.recall),
                              icon: const Icon(Icons.psychology_outlined),
                              label: const Text(
                                'Karte verdecken & kurz erinnern',
                              ),
                            ),
                          const SizedBox(height: 10),
                          OutlinedButton(
                            onPressed: () => _move(1, plants.length),
                            child: Text(
                              _index == plants.length - 1
                                  ? 'Weiter · neue Runde'
                                  : 'Nur anschauen · nächste Karte',
                            ),
                          ),
                        ] else if (card != null) ...[
                          Text(
                            plant.commonName.isEmpty
                                ? plant.scientificName
                                : plant.commonName,
                            style: Theme.of(context).textTheme.headlineSmall,
                          ),
                          const SizedBox(height: 16),
                          Text(
                            'Was weißt du über „${card.heading}“ bei dieser Pflanze?',
                            style: Theme.of(context).textTheme.titleLarge,
                          ),
                          const SizedBox(height: 12),
                          const Text(
                            'Erinnere dich kurz und vergleiche anschließend mit dem Originaltext.',
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
                                  onPressed: () =>
                                      _assess(plant, true, plants.length),
                                  child: const Text('Gewusst'),
                                ),
                                OutlinedButton(
                                  onPressed: () =>
                                      _assess(plant, false, plants.length),
                                  child: const Text('Noch üben'),
                                ),
                              ],
                            ),
                          ],
                          TextButton(
                            onPressed: () =>
                                setState(() => _phase = _Phase.study),
                            child: const Text('Karte wieder ansehen'),
                          ),
                        ],
                        const SizedBox(height: 16),
                        Text(
                          'In dieser Runde selbst eingeschätzt: ${_assessments.values.where((v) => v).length} gewusst · ${_assessments.values.where((v) => !v).length} noch üben.',
                        ),
                        const SizedBox(height: 8),
                        const Text(
                          'Nach der letzten Karte geht es automatisch von vorne los. Keine Punkte oder Levelabschlüsse; deine Selbsteinschätzung gilt nur für diese Runde.',
                          style: TextStyle(fontSize: 12),
                          textAlign: TextAlign.center,
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ),
          ],
        );
      },
    ),
  );
}
