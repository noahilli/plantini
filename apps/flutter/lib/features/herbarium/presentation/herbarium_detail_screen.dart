import 'package:flutter/material.dart';

import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_typography.dart';
import '../domain/herbarium_models.dart';

/// Screen presenting the detailed observation record from the digital herbarium.
class HerbariumDetailScreen extends StatelessWidget {
  const HerbariumDetailScreen({super.key, required this.entry, this.onDelete});

  final HerbariumEntry entry;
  final Future<void> Function(HerbariumEntry entry)? onDelete;

  String _formatDate(DateTime date) {
    final day = date.day.toString().padLeft(2, '0');
    final month = date.month.toString().padLeft(2, '0');
    final year = date.year;
    final hour = date.hour.toString().padLeft(2, '0');
    final minute = date.minute.toString().padLeft(2, '0');
    return '$day.$month.$year um $hour:$minute Uhr';
  }

  Future<void> _confirmDelete(BuildContext context) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Fund löschen?'),
        content: Text(
          'Möchtest du "${entry.displayTitle}" wirklich aus deinem Herbarium entfernen?',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(ctx).pop(false),
            child: const Text('Abbrechen'),
          ),
          FilledButton(
            style: FilledButton.styleFrom(backgroundColor: AppColors.danger),
            onPressed: () => Navigator.of(ctx).pop(true),
            child: const Text('Löschen'),
          ),
        ],
      ),
    );

    if (confirmed == true && context.mounted) {
      if (onDelete != null) {
        await onDelete!(entry);
      }
      if (context.mounted) {
        Navigator.of(context).pop(true);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final hasPlantNetResult =
        entry.identificationResult != null &&
        entry.identificationResult!.trim().isNotEmpty;

    return Scaffold(
      appBar: AppBar(
        title: Text(entry.displayTitle),
        actions: [
          if (onDelete != null)
            IconButton(
              key: const ValueKey('herbarium-delete-button'),
              icon: const Icon(Icons.delete_outline),
              tooltip: 'Fund löschen',
              onPressed: () => _confirmDelete(context),
            ),
        ],
      ),
      body: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // Large Hero / Cover Image
            _DetailHeroImage(mediaUrl: entry.mediaUrl),

            Padding(
              padding: const EdgeInsets.all(20.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Common & Scientific Name
                  Text(
                    entry.displayTitle,
                    style: AppTypography.textTheme.headlineMedium?.copyWith(
                      fontWeight: FontWeight.bold,
                      color: AppColors.forest,
                    ),
                  ),
                  if (entry.scientificName != null &&
                      entry.scientificName!.isNotEmpty) ...[
                    const SizedBox(height: 4),
                    Text(
                      entry.scientificName!,
                      style: AppTypography.textTheme.titleMedium?.copyWith(
                        fontStyle: FontStyle.italic,
                        color: AppColors.muted,
                      ),
                    ),
                  ],
                  const SizedBox(height: 16),

                  // Sync status banner
                  _SyncStatusBanner(status: entry.syncStatus),
                  const SizedBox(height: 20),

                  // PlantNet KI Result Card
                  if (hasPlantNetResult) ...[
                    _PlantNetResultCard(result: entry.identificationResult!),
                    const SizedBox(height: 20),
                  ],

                  // Notes section
                  _SectionHeader(
                    icon: Icons.edit_note_rounded,
                    title: 'Notizen & Feldeindrücke',
                  ),
                  const SizedBox(height: 8),
                  Container(
                    width: double.infinity,
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: AppColors.cream,
                      borderRadius: BorderRadius.circular(14),
                      border: Border.all(color: AppColors.line),
                    ),
                    child: Text(
                      entry.note.isNotEmpty
                          ? entry.note
                          : 'Keine Notizen zu diesem Fund hinterlegt.',
                      style: AppTypography.textTheme.bodyMedium?.copyWith(
                        color: entry.note.isNotEmpty
                            ? AppColors.ink
                            : AppColors.muted,
                        height: 1.5,
                      ),
                    ),
                  ),
                  const SizedBox(height: 24),

                  // Funddetails / Metadata
                  _SectionHeader(
                    icon: Icons.info_outline_rounded,
                    title: 'Fundinformationen',
                  ),
                  const SizedBox(height: 12),
                  _MetadataTile(
                    icon: Icons.calendar_today_outlined,
                    label: 'Beobachtet am',
                    value: _formatDate(entry.observedAt),
                  ),
                  if (entry.confirmedPlantId != null) ...[
                    const SizedBox(height: 8),
                    _MetadataTile(
                      icon: Icons.eco_outlined,
                      label: 'Bestätigte Pflanzen-ID',
                      value: entry.confirmedPlantId!,
                    ),
                  ],
                  const SizedBox(height: 8),
                  _MetadataTile(
                    icon: Icons.tag_rounded,
                    label: 'Eintrags-ID',
                    value: entry.id,
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _DetailHeroImage extends StatelessWidget {
  const _DetailHeroImage({this.mediaUrl});

  final String? mediaUrl;

  @override
  Widget build(BuildContext context) {
    if (mediaUrl == null || mediaUrl!.isEmpty) {
      return Container(
        height: 220,
        color: AppColors.cream,
        alignment: Alignment.center,
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: const [
            Icon(Icons.eco_rounded, size: 64, color: AppColors.sage),
            SizedBox(height: 8),
            Text(
              'Kein Belegfoto vorhanden',
              style: TextStyle(color: AppColors.muted),
            ),
          ],
        ),
      );
    }

    return Container(
      height: 260,
      width: double.infinity,
      color: AppColors.beige,
      child: Image.network(
        mediaUrl!,
        fit: BoxFit.cover,
        errorBuilder: (_, _, _) => Container(
          color: AppColors.cream,
          alignment: Alignment.center,
          child: const Icon(
            Icons.broken_image_outlined,
            size: 48,
            color: AppColors.muted,
          ),
        ),
        loadingBuilder: (context, child, loadingProgress) {
          if (loadingProgress == null) return child;
          return Container(
            color: AppColors.cream,
            alignment: Alignment.center,
            child: const CircularProgressIndicator(color: AppColors.forest),
          );
        },
      ),
    );
  }
}

class _SyncStatusBanner extends StatelessWidget {
  const _SyncStatusBanner({required this.status});

  final SyncStatus status;

  @override
  Widget build(BuildContext context) {
    final (icon, color, bgColor, title, desc) = switch (status) {
      SyncStatus.synced => (
        Icons.cloud_done_rounded,
        AppColors.forest,
        AppColors.mint,
        'Synchronisiert',
        'Dieser Fund ist sicher auf dem Server und lokal gespeichert.',
      ),
      SyncStatus.pending => (
        Icons.cloud_upload_outlined,
        AppColors.bark,
        AppColors.warningBg,
        'Lokal gespeichert (Ausstehend)',
        'Wird automatisch synchronisiert, sobald eine Internetverbindung besteht.',
      ),
      SyncStatus.conflict => (
        Icons.warning_amber_rounded,
        AppColors.danger,
        AppColors.warningBg,
        'Synchronisationskonflikt',
        'Bei der Synchronisation ist ein Versionskonflikt aufgetreten.',
      ),
      SyncStatus.deleted => (
        Icons.delete_outline,
        AppColors.muted,
        AppColors.cream,
        'Gelöscht',
        'Dieser Eintrag ist zur Löschung vorgemerkt.',
      ),
    };

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
      decoration: BoxDecoration(
        color: bgColor,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: color.withOpacity(0.3)),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon, color: color, size: 22),
          const SizedBox(width: 10),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: AppTypography.textTheme.labelLarge?.copyWith(
                    fontWeight: FontWeight.bold,
                    color: color,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  desc,
                  style: AppTypography.textTheme.bodySmall?.copyWith(
                    color: AppColors.ink,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _PlantNetResultCard extends StatelessWidget {
  const _PlantNetResultCard({required this.result});

  final String result;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.white,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: AppColors.sage.withOpacity(0.5)),
        boxShadow: [
          BoxShadow(
            color: AppColors.forest.withOpacity(0.06),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(6),
                decoration: BoxDecoration(
                  color: AppColors.mint,
                  borderRadius: BorderRadius.circular(8),
                ),
                child: const Icon(
                  Icons.auto_awesome,
                  size: 18,
                  color: AppColors.forest,
                ),
              ),
              const SizedBox(width: 10),
              Text(
                'PlantNet KI-Bestimmung',
                style: AppTypography.textTheme.titleMedium?.copyWith(
                  fontWeight: FontWeight.bold,
                  color: AppColors.forest,
                ),
              ),
            ],
          ),
          const SizedBox(height: 10),
          Text(
            result,
            style: AppTypography.textTheme.bodyMedium?.copyWith(
              color: AppColors.ink,
              fontWeight: FontWeight.w500,
            ),
          ),
        ],
      ),
    );
  }
}

class _SectionHeader extends StatelessWidget {
  const _SectionHeader({required this.icon, required this.title});

  final IconData icon;
  final String title;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Icon(icon, size: 20, color: AppColors.forest),
        const SizedBox(width: 8),
        Text(
          title,
          style: AppTypography.textTheme.titleMedium?.copyWith(
            fontWeight: FontWeight.bold,
            color: AppColors.forest,
          ),
        ),
      ],
    );
  }
}

class _MetadataTile extends StatelessWidget {
  const _MetadataTile({
    required this.icon,
    required this.label,
    required this.value,
  });

  final IconData icon;
  final String label;
  final String value;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
      decoration: BoxDecoration(
        color: AppColors.white,
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: AppColors.line),
      ),
      child: Row(
        children: [
          Icon(icon, size: 18, color: AppColors.muted),
          const SizedBox(width: 10),
          Text(
            label,
            style: AppTypography.textTheme.bodySmall?.copyWith(
              color: AppColors.muted,
            ),
          ),
          const Spacer(),
          Flexible(
            child: Text(
              value,
              textAlign: TextAlign.end,
              overflow: TextOverflow.ellipsis,
              style: AppTypography.textTheme.bodyMedium?.copyWith(
                fontWeight: FontWeight.w600,
                color: AppColors.ink,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
