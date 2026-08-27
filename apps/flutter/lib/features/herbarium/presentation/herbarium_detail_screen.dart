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
      backgroundColor: AppColors.neutral100,
      body: SafeArea(
        child: Column(
          children: [
            // Custom App Bar
            Padding(
              padding: const EdgeInsets.fromLTRB(22, 6, 22, 8),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  InkWell(
                    onTap: () => Navigator.of(context).pop(),
                    borderRadius: BorderRadius.circular(999),
                    child: Container(
                      width: 32,
                      height: 32,
                      decoration: const BoxDecoration(
                        color: AppColors.bg,
                        shape: BoxShape.circle,
                      ),
                      child: const Icon(
                        Icons.arrow_back,
                        size: 16,
                        color: AppColors.ink,
                      ),
                    ),
                  ),
                  Text(
                    'Fund-Detail',
                    style: AppTypography.textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.w400,
                      color: AppColors.ink,
                    ),
                  ),
                  if (onDelete != null)
                    InkWell(
                      key: const ValueKey('herbarium-delete-button'),
                      onTap: () => _confirmDelete(context),
                      borderRadius: BorderRadius.circular(999),
                      child: Container(
                        width: 32,
                        height: 32,
                        decoration: const BoxDecoration(
                          color: AppColors.bg,
                          shape: BoxShape.circle,
                        ),
                        child: const Icon(
                          Icons.delete_outline,
                          size: 16,
                          color: AppColors.danger,
                        ),
                      ),
                    )
                  else
                    const SizedBox(width: 32),
                ],
              ),
            ),
            // Body Content
            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.symmetric(horizontal: 22),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    const SizedBox(height: 12),
                    // Large Hero Image with Status Pill
                    Container(
                      height: 186,
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(26),
                        color: AppColors.beige,
                        image:
                            entry.mediaUrl != null && entry.mediaUrl!.isNotEmpty
                            ? DecorationImage(
                                image: NetworkImage(entry.mediaUrl!),
                                fit: BoxFit.cover,
                              )
                            : null,
                      ),
                      alignment: Alignment.topRight,
                      padding: const EdgeInsets.all(12),
                      child: entry.mediaUrl == null || entry.mediaUrl!.isEmpty
                          ? const Center(
                              child: Icon(
                                Icons.eco_rounded,
                                size: 48,
                                color: AppColors.sage,
                              ),
                            )
                          : Container(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 11,
                                vertical: 6,
                              ),
                              decoration: BoxDecoration(
                                color: AppColors.neutral100,
                                borderRadius: BorderRadius.circular(999),
                              ),
                              child: Row(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  Container(
                                    width: 7,
                                    height: 7,
                                    decoration: const BoxDecoration(
                                      color: AppColors.sage600,
                                      shape: BoxShape.circle,
                                    ),
                                  ),
                                  const SizedBox(width: 6),
                                  Text(
                                    entry.syncStatus == SyncStatus.synced
                                        ? 'synchronisiert'
                                        : 'lokal',
                                    style: AppTypography.textTheme.labelSmall
                                        ?.copyWith(
                                          fontWeight: FontWeight.bold,
                                          fontSize: 10.5,
                                          color: AppColors.sage800,
                                        ),
                                  ),
                                ],
                              ),
                            ),
                    ),
                    const SizedBox(height: 12),

                    // Title Area
                    Text(
                      entry.displayTitle,
                      style: AppTypography.textTheme.headlineMedium?.copyWith(
                        fontWeight: FontWeight.w400,
                        fontSize: 25,
                        color: AppColors.ink,
                      ),
                    ),
                    if (entry.scientificName != null &&
                        entry.scientificName!.isNotEmpty) ...[
                      Text(
                        entry.scientificName!,
                        style: AppTypography.textTheme.bodyMedium?.copyWith(
                          fontStyle: FontStyle.italic,
                          fontSize: 12,
                          color: AppColors.neutral600,
                        ),
                      ),
                    ],
                    const SizedBox(height: 16),

                    // Sync status banner (existing)
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
                        color: AppColors.bg,
                        borderRadius: BorderRadius.circular(14),
                      ),
                      child: Text(
                        entry.note.isNotEmpty
                            ? entry.note
                            : 'Keine Notizen zu diesem Fund hinterlegt.',
                        style: AppTypography.textTheme.bodyMedium?.copyWith(
                          color: entry.note.isNotEmpty
                              ? AppColors.ink
                              : AppColors.neutral500,
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
                    const SizedBox(height: 32),
                  ],
                ),
              ),
            ),
          ],
        ),
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
