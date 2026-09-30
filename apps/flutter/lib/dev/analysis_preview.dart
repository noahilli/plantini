// Design workbench: the analysis wait and the problem pop-up, no backend.
import 'dart:convert';
import 'dart:typed_data';

import 'package:flutter/material.dart';

import '../core/errors/app_failure.dart';
import '../core/theme/app_colors.dart';
import '../core/theme/app_theme.dart';
import '../features/field/presentation/field_problem.dart';
import '../features/field/presentation/widgets/analysis_progress.dart';

// 1x1 green pixel PNG scaled by the widget; enough to see the frame and beam.
final Uint8List _pixel = base64Decode(
  'iVBORw0KGgoAAAANSUhEUgAAAAEAAAABCAYAAAAfFcSJAAAADUlEQVR42mNkYPhfDwAChwGA60e6kgAAAABJRU5ErkJggg==',
);

void main() =>
    runApp(MaterialApp(theme: AppTheme.lightTheme, home: const _Preview()));

class _Preview extends StatelessWidget {
  const _Preview();

  @override
  Widget build(BuildContext context) {
    final stage = Uri.base.queryParameters['stage'] ?? 'analysing';
    if (stage == 'dialog') {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        showFieldProblemDialog(
          context,
          FieldProblem.fromFailure(
            const NetworkFailure(message: 'x'),
            FieldStep.upload,
          ),
        );
      });
    }
    return Scaffold(
      backgroundColor: AppColors.neutral100,
      body: SafeArea(
        child: Center(
          child: AnalysisProgress(
            stage: AnalysisStage.values.byName(
              stage == 'dialog' ? 'uploading' : stage,
            ),
            photo: _pixel,
          ),
        ),
      ),
    );
  }
}
