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
        child: Column(
          children: [
            Padding(
              padding: const EdgeInsets.fromLTRB(22, 12, 22, 8),
              child: Align(
                alignment: Alignment.centerLeft,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'DEIN CHARAKTER',
                      style: AppTypography.textTheme.labelSmall?.copyWith(
                        color: AppColors.sage700,
                        fontWeight: FontWeight.w700,
                        letterSpacing: 1.1,
                      ),
                    ),
                    Text(
                      'Wer erkundet mit dir?',
                      style: AppTypography.textTheme.headlineMedium,
                    ),
                  ],
                ),
              ),
            ),
            Expanded(
              flex: 4,
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 22),
                child: Column(
                  children: [
                    Expanded(
                      child: SizedBox.expand(
                        child: ExplorerStage(
                          key: ValueKey(current.id),
                          explorer: current,
                        ),
                      ),
                    ),
                    const SizedBox(height: 8),
                    _NameTag(explorer: current),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 10),
            Expanded(
              flex: 5,
              child: ListView(
                padding: const EdgeInsets.fromLTRB(22, 0, 22, 8),
                children: [
                  for (final group in ExplorerGroup.values) ...[
                    Padding(
                      padding: const EdgeInsets.only(top: 6, bottom: 6),
                      child: Text(
                        group.label,
                        style: AppTypography.textTheme.titleSmall?.copyWith(
                          color: AppColors.sage800,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                    ),
                    Row(
                      children: [
                        for (final explorer in _roster.inGroup(group))
                          Expanded(
                            child: Padding(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 4,
                              ),
                              child: _Card(
                                explorer: explorer,
                                selected: explorer.id == _selected,
                                onTap: () =>
                                    setState(() => _selected = explorer.id),
                              ),
                            ),
                          ),
                      ],
                    ),
                  ],
                ],
              ),
            ),
            Padding(
              padding: const EdgeInsets.fromLTRB(22, 4, 22, 14),
              child: SizedBox(
                width: double.infinity,
                child: FilledButton.icon(
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
              ),
            ),
          ],
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
    child: Row(
      children: [
        Text(
          explorer.name,
          style: AppTypography.textTheme.titleMedium?.copyWith(
            color: AppColors.neutral100,
          ),
        ),
        const SizedBox(width: 10),
        Expanded(
          child: Text(
            explorer.blurb,
            overflow: TextOverflow.ellipsis,
            style: const TextStyle(color: AppColors.sage200, fontSize: 12),
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
    label: '${explorer.name}, ${explorer.blurb}',
    child: GestureDetector(
      key: ValueKey('explorer-${explorer.id}'),
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 150),
        padding: const EdgeInsets.all(3),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(22),
          border: Border.all(
            color: selected ? AppColors.terracotta : Colors.transparent,
            width: 3,
          ),
        ),
        child: Column(
          children: [
            AspectRatio(
              aspectRatio: .9,
              child: ExplorerPortrait(explorer: explorer, borderRadius: 18),
            ),
            const SizedBox(height: 4),
            Text(
              explorer.name,
              style: TextStyle(
                fontWeight: selected ? FontWeight.w800 : FontWeight.w600,
              ),
            ),
          ],
        ),
      ),
    ),
  );
}
