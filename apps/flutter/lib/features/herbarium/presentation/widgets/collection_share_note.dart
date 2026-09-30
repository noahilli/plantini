import 'package:flutter/material.dart';

import '../../../../core/theme/app_colors.dart';
import '../../domain/insight_repository.dart';

/// "12 % der Nutzer*innen haben diese Art gesammelt" for a catalogue plant
/// (per mille below one percent). Hidden until the server publishes shares.
class CollectionShareNote extends StatefulWidget {
  const CollectionShareNote({
    super.key,
    required this.plantId,
    required this.insights,
  });

  final String plantId;
  final InsightRepository? insights;

  @override
  State<CollectionShareNote> createState() => _CollectionShareNoteState();
}

class _CollectionShareNoteState extends State<CollectionShareNote> {
  String? _sentence;

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    final result = await widget.insights?.collectionStats();
    if (!mounted || result == null) return;
    final sentence = result.valueOrNull?.sentenceFor(plantId: widget.plantId);
    if (sentence != null) setState(() => _sentence = sentence);
  }

  @override
  Widget build(BuildContext context) {
    final sentence = _sentence;
    if (sentence == null) return const SizedBox.shrink();
    return Container(
      key: const ValueKey('plant-collection-share'),
      margin: const EdgeInsets.only(top: 16),
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
      decoration: BoxDecoration(
        color: AppColors.sage100,
        borderRadius: BorderRadius.circular(16),
      ),
      child: Row(
        children: [
          const Icon(Icons.groups_2_rounded, color: AppColors.sage700),
          const SizedBox(width: 10),
          Expanded(child: Text(sentence)),
        ],
      ),
    );
  }
}
