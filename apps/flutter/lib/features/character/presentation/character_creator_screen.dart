import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../../core/result.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_typography.dart';
import '../application/character_store.dart';
import '../domain/character_spec.dart';
import 'widgets/character_preview.dart';

/// Builds the player's character from kit parts: body, hair, headgear, glasses,
/// clothes, shoes and backpack. Shown once after the first login, and again
/// from the profile.
class CharacterCreatorScreen extends StatefulWidget {
  const CharacterCreatorScreen({
    super.key,
    required this.store,
    this.returnTo = '/home',
  });

  final CharacterStore store;

  /// Where "Fertig" leads.
  final String returnTo;

  @override
  State<CharacterCreatorScreen> createState() => _CharacterCreatorScreenState();
}

class _CharacterCreatorScreenState extends State<CharacterCreatorScreen> {
  static const _categories = ['skin', ...CharacterOptions.partNames];

  late CharacterSpec _spec = widget.store.spec ?? CharacterSpec.starter();
  String _category = 'hair';
  bool _saving = false;
  final _random = math.Random();

  String _label(String category) =>
      category == 'skin' ? 'Haut' : CharacterOptions.partLabels[category]!;

  void _setStyle(String part, StyleOption option) {
    final previous = _spec.part(part);
    final colors = CharacterOptions.colorsFor(part);
    setState(() {
      _spec = _spec.withPart(
        part,
        option.id == 'none'
            ? PartChoice.none
            : PartChoice(option.id, previous.color ?? colors.first.color),
      );
    });
  }

  void _setColor(String part, Color color) {
    if (part == 'skin') {
      setState(() => _spec = _spec.copyWith(skin: color));
    } else {
      setState(
        () => _spec = _spec.withPart(part, _spec.part(part).withColor(color)),
      );
    }
  }

  Future<void> _done() async {
    if (_saving) return;
    setState(() => _saving = true);
    final result = await widget.store.save(_spec);
    if (!mounted) return;
    if (result is Failure<CharacterSpec>) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text(
            'Dein Charakter ist auf diesem Gerät gespeichert und wird später übertragen.',
          ),
        ),
      );
    }
    context.go(widget.returnTo);
  }

  @override
  Widget build(BuildContext context) {
    final part = _category == 'skin' ? null : _spec.part(_category);
    return Scaffold(
      backgroundColor: AppColors.neutral100,
      body: SafeArea(
        child: Column(
          children: [
            Padding(
              padding: const EdgeInsets.fromLTRB(22, 12, 22, 8),
              child: Row(
                children: [
                  Expanded(
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
                          'So siehst du aus',
                          style: AppTypography.textTheme.headlineMedium,
                        ),
                      ],
                    ),
                  ),
                  IconButton.filledTonal(
                    key: const ValueKey('character-random'),
                    tooltip: 'Zufälliger Charakter',
                    onPressed: () =>
                        setState(() => _spec = CharacterSpec.random(_random)),
                    icon: const Icon(Icons.casino_outlined),
                  ),
                ],
              ),
            ),
            Expanded(
              flex: 5,
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 22),
                child: SizedBox.expand(child: CharacterPreview(spec: _spec)),
              ),
            ),
            const SizedBox(height: 10),
            Wrap(
              spacing: 8,
              children: [
                for (final gender in CharacterGender.values)
                  ChoiceChip(
                    key: ValueKey('character-gender-${gender.name}'),
                    label: Text(gender.label),
                    selected: _spec.gender == gender,
                    onSelected: (_) =>
                        setState(() => _spec = _spec.copyWith(gender: gender)),
                  ),
              ],
            ),
            SizedBox(
              height: 52,
              child: ListView(
                scrollDirection: Axis.horizontal,
                padding: const EdgeInsets.symmetric(
                  horizontal: 18,
                  vertical: 8,
                ),
                children: [
                  for (final category in _categories)
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 4),
                      child: ChoiceChip(
                        key: ValueKey('character-category-$category'),
                        label: Text(_label(category)),
                        selected: _category == category,
                        showCheckmark: false,
                        onSelected: (_) => setState(() => _category = category),
                      ),
                    ),
                ],
              ),
            ),
            Expanded(
              flex: 4,
              child: SingleChildScrollView(
                padding: const EdgeInsets.fromLTRB(22, 4, 22, 8),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    if (part != null)
                      Wrap(
                        spacing: 8,
                        runSpacing: 4,
                        children: [
                          for (final option
                              in CharacterOptions.styles[_category]!)
                            ChoiceChip(
                              key: ValueKey(
                                'character-style-$_category-${option.id}',
                              ),
                              label: Text(option.label),
                              selected: part.style == option.id,
                              onSelected: (_) => _setStyle(_category, option),
                            ),
                        ],
                      ),
                    if (part == null || !part.isNone) ...[
                      const SizedBox(height: 12),
                      Wrap(
                        spacing: 10,
                        runSpacing: 10,
                        children: [
                          for (final named
                              in _category == 'skin'
                                  ? CharacterOptions.skins
                                  : CharacterOptions.colorsFor(_category))
                            _Swatch(
                              named: named,
                              selected:
                                  (_category == 'skin'
                                      ? _spec.skin
                                      : part!.color) ==
                                  named.color,
                              onTap: () => _setColor(_category, named.color),
                            ),
                        ],
                      ),
                    ],
                  ],
                ),
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
                  label: const Text('Fertig'),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _Swatch extends StatelessWidget {
  const _Swatch({
    required this.named,
    required this.selected,
    required this.onTap,
  });

  final NamedColor named;
  final bool selected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) => Semantics(
    button: true,
    selected: selected,
    label: named.name,
    child: GestureDetector(
      onTap: onTap,
      child: Container(
        width: 38,
        height: 38,
        decoration: BoxDecoration(
          color: named.color,
          shape: BoxShape.circle,
          border: Border.all(
            color: selected ? AppColors.ink : AppColors.neutral300,
            width: selected ? 3 : 1.5,
          ),
        ),
        child: selected
            ? Icon(
                Icons.check_rounded,
                size: 18,
                color: named.color.computeLuminance() > .55
                    ? AppColors.ink
                    : Colors.white,
              )
            : null,
      ),
    ),
  );
}
