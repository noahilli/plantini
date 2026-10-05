import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../../core/result.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_typography.dart';
import '../application/character_store.dart';
import '../domain/explorer.dart';
import 'widgets/explorer_roster.dart';
import 'widgets/explorer_views.dart';

/// Pick one of the nine explorers. Shown once after the first login, and again
/// from the profile.
class CharacterSelectorScreen extends StatefulWidget {
  const CharacterSelectorScreen({
    super.key,
    required this.store,
    this.returnTo = '/home',
  });

  final CharacterStore store;

  /// Where "Das bin ich" leads.
  final String returnTo;

  @override
  State<CharacterSelectorScreen> createState() =>
      _CharacterSelectorScreenState();
}

class _CharacterSelectorScreenState extends State<CharacterSelectorScreen> {
  late final ExplorerRoster _roster = ExplorerRoster.loaded!;
  late String _selected = widget.store.explorerId ?? _roster.explorers.first.id;
  bool _saving = false;

  Explorer get _current => _roster.byId(_selected)!;

  Future<void> _done() async {
    if (_saving) return;
    setState(() => _saving = true);
    final result = await widget.store.choose(_selected);
    if (!mounted) return;
    if (result is Failure<String>) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text(
            'Deine Wahl ist auf diesem Gerät gespeichert und wird später übertragen.',
          ),
        ),
      );
    }
    context.go(widget.returnTo);
  }

  @override
  Widget build(BuildContext context) {
    final current = _current;
    return Scaffold(
      backgroundColor: AppColors.neutral100,
      body: SafeArea(
        child: LayoutBuilder(
          builder: (context, constraints) {
            final textScale = MediaQuery.textScalerOf(context).scale(16) / 16;
            final desktop = constraints.maxWidth >= 900 && textScale <= 1.3;
            final preview = Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                SizedBox(
                  height: desktop
                      ? (constraints.maxHeight * .48).clamp(240.0, 380.0)
                      : (constraints.maxHeight * .32).clamp(180.0, 300.0),
                  child: ExplorerStage(
                    key: ValueKey(current.id),
                    explorer: current,
                  ),
                ),
                const SizedBox(height: 12),
                _NameTag(explorer: current),
                const SizedBox(height: 16),
                FilledButton.icon(
                  key: const ValueKey('character-done'),
                  onPressed: _saving ? null : _done,
                  icon: _saving
                      ? const SizedBox(
                          width: 18,
                          height: 18,
                          child: CircularProgressIndicator(strokeWidth: 2),
                        )
                      : const Icon(Icons.check_rounded),
                  label: Text('Ich bin ${current.name}'),
                ),
              ],
            );
            final roster = LayoutBuilder(
              builder: (context, rosterConstraints) {
                final columns = desktop
                    ? 3
                    : (rosterConstraints.maxWidth / (110 * textScale))
                          .floor()
                          .clamp(1, 3);
                final cardWidth =
                    (rosterConstraints.maxWidth - (columns - 1) * 12) / columns;
                return Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    for (final group in ExplorerGroup.values) ...[
                      Padding(
                        padding: const EdgeInsets.only(top: 8, bottom: 8),
                        child: Text(
                          group.label,
                          style: AppTypography.textTheme.titleSmall?.copyWith(
                            color: AppColors.sage800,
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                      ),
                      Wrap(
                        spacing: 12,
                        runSpacing: 12,
                        children: [
                          for (final explorer in _roster.inGroup(group))
                            SizedBox(
                              width: cardWidth,
                              child: _Card(
                                explorer: explorer,
                                selected: explorer.id == _selected,
                                onTap: () =>
                                    setState(() => _selected = explorer.id),
                              ),
                            ),
                        ],
                      ),
                    ],
                  ],
                );
              },
            );
            return SingleChildScrollView(
              padding: const EdgeInsets.fromLTRB(22, 24, 22, 24),
              child: Center(
                child: ConstrainedBox(
                  constraints: const BoxConstraints(maxWidth: 1100),
                  child: FocusTraversalGroup(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        Text(
                          'DEIN CHARAKTER',
                          style: AppTypography.textTheme.labelSmall?.copyWith(
                            color: AppColors.sage700,
                            fontWeight: FontWeight.w700,
                            letterSpacing: 1.1,
                          ),
                        ),
                        const SizedBox(height: 8),
                        Text(
                          'Wer erkundet mit dir?',
                          style: AppTypography.textTheme.headlineMedium,
                        ),
                        const SizedBox(height: 8),
                        const Text(
                          'Wähle deine Begleitung für die nächste Entdeckung. '
                          'Du kannst deinen Charakter später im Profil ändern.',
                        ),
                        const SizedBox(height: 24),
                        if (desktop)
                          Row(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Expanded(flex: 4, child: preview),
                              const SizedBox(width: 32),
                              Expanded(flex: 6, child: roster),
                            ],
                          )
                        else ...[
                          preview,
                          const SizedBox(height: 16),
                          roster,
                        ],
                      ],
                    ),
                  ),
                ),
              ),
            );
          },
        ),
      ),
    );
  }
}

class _NameTag extends StatelessWidget {
  const _NameTag({required this.explorer});

  final Explorer explorer;

  @override
  Widget build(BuildContext context) => Container(
    padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
    decoration: BoxDecoration(
      color: AppColors.sage800.withValues(alpha: .86),
      borderRadius: BorderRadius.circular(16),
    ),
    child: Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          explorer.name,
          style: AppTypography.textTheme.titleMedium?.copyWith(
            color: AppColors.neutral100,
          ),
        ),
        const SizedBox(height: 6),
        Text(
          explorer.blurb,
          style: const TextStyle(
            color: AppColors.neutral100,
            fontSize: 14,
            height: 1.5,
          ),
        ),
      ],
    ),
  );
}

class _Card extends StatelessWidget {
  const _Card({
    required this.explorer,
    required this.selected,
    required this.onTap,
  });

  final Explorer explorer;
  final bool selected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) => Semantics(
    button: true,
    selected: selected,
    onTap: onTap,
    excludeSemantics: true,
    label: '${explorer.name}, ${explorer.blurb}',
    child: Material(
      key: ValueKey('explorer-${explorer.id}'),
      color: selected ? AppColors.sage200 : Colors.white,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(18),
        side: BorderSide(
          color: selected ? AppColors.sage800 : AppColors.sage200,
          width: selected ? 2 : 1,
        ),
      ),
      clipBehavior: Clip.antiAlias,
      child: InkWell(
        onTap: onTap,
        excludeFromSemantics: true,
        child: Padding(
          padding: const EdgeInsets.all(8),
          child: Column(
            children: [
              SizedBox(
                height: 104,
                width: double.infinity,
                child: ExplorerPortrait(explorer: explorer, borderRadius: 12),
              ),
              const SizedBox(height: 4),
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  if (selected) ...[
                    const Icon(
                      Icons.check_circle_rounded,
                      size: 16,
                      color: AppColors.sage800,
                    ),
                    const SizedBox(width: 4),
                  ],
                  Flexible(
                    child: Text(
                      explorer.name,
                      style: TextStyle(
                        fontWeight: selected
                            ? FontWeight.w800
                            : FontWeight.w600,
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    ),
  );
}
