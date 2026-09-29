// Standalone design workbench only. Not imported by main.dart or the router.
// flutter run -t lib/dev/forest_preview.dart
import 'package:flutter/material.dart';

import '../core/theme/app_theme.dart';
import '../features/catalog/domain/catalog_models.dart';
import '../features/catalog/presentation/widgets/modular_forest_view.dart';

void main() =>
    runApp(MaterialApp(theme: AppTheme.lightTheme, home: const _Preview()));

class _Preview extends StatefulWidget {
  const _Preview();
  @override
  State<_Preview> createState() => _PreviewState();
}

class _PreviewState extends State<_Preview> {
  int count = 31;
  @override
  Widget build(BuildContext context) => Scaffold(
    appBar: AppBar(
      title: const Text('Designvorschau · keine echten Fortschritte'),
      actions: [
        DropdownButton<int>(
          value: count,
          items: [1, 7, 30, 31, 60, 300]
              .map((n) => DropdownMenuItem(value: n, child: Text('$n Level')))
              .toList(),
          onChanged: (n) => setState(() => count = n!),
        ),
      ],
    ),
    body: ModularForestView(
      levels: List.generate(
        count,
        (i) => Level(
          id: 'preview-$i',
          ecosystemId: 'preview',
          title: 'Designstation ${i + 1}',
          sequence: i + 1,
          status: i < 2
              ? LevelStatus.completed
              : i == 2
              ? LevelStatus.available
              : LevelStatus.locked,
          minimumScore: .66,
          requiredQuizIds: const [],
          plantIds: const [],
        ),
      ),
      onLevelTap: (level) => ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Vorschau: Level ${level.sequence}')),
      ),
    ),
  );
}
