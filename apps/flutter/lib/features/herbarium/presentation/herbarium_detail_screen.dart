import 'package:flutter/material.dart';

import '../../../core/images/plantini_image.dart';
import '../../../core/result.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_typography.dart';
import '../domain/herbarium_models.dart';
import '../domain/insight_repository.dart';
import 'widgets/find_insights.dart';

final class _ObservationHero extends StatelessWidget {
  const _ObservationHero({required this.entry});
  final HerbariumEntry entry;

  @override
  Widget build(BuildContext context) => ClipRRect(
    borderRadius: BorderRadius.circular(28),
    child: SizedBox(
      height: 250,
      child: entry.mediaUrl?.isNotEmpty == true
          ? PlantiniImage(
              entry.photoUrl(width: 1280)!,
              authenticated: true,
              semanticLabel: 'Fundfoto: ${entry.displayTitle}',
              errorBuilder: (_, _) => _placeholder('Fundfoto nicht verfügbar'),
              placeholder: (_) => _placeholder('Foto wird geladen …'),
            )
          : _placeholder('Noch kein Fundfoto'),
    ),
  );

  Widget _placeholder(String label) => ColoredBox(
    color: AppColors.sage200,
    child: Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          const Icon(
            Icons.local_florist_outlined,
            size: 64,
            color: AppColors.sage700,
          ),
          const SizedBox(height: 12),
          Text(label),
        ],
      ),
    ),
  );
}

/// Screen presenting the detailed observation record from the digital herbarium.
class HerbariumDetailScreen extends StatefulWidget {
  const HerbariumDetailScreen({
    super.key,
    required this.entry,
    this.onDelete,
    this.onUpdateNote,
    this.insights,
  });

  final HerbariumEntry entry;
  final InsightRepository? insights;
  final Future<void> Function(HerbariumEntry entry)? onDelete;
  final Future<Result<HerbariumEntry>> Function(
    HerbariumEntry entry,
    String note,
  )?
  onUpdateNote;

  @override
  State<HerbariumDetailScreen> createState() => _HerbariumDetailScreenState();
}

class _HerbariumDetailScreenState extends State<HerbariumDetailScreen> {
  late HerbariumEntry entry = widget.entry;

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
      if (widget.onDelete != null) {
        await widget.onDelete!(entry);
      }
      if (context.mounted) {
        Navigator.of(context).pop(true);
      }
    }
  }

  Future<void> _editNote(BuildContext context) async {
    var editedNote = entry.note;
    final note = await showDialog<String>(
      context: context,
      builder: (dialogContext) => AlertDialog(
        title: const Text('Notiz bearbeiten'),
        content: TextFormField(
          key: const ValueKey('herbarium-note-input'),
          initialValue: entry.note,
          onChanged: (value) => editedNote = value,
          maxLength: 4000,
          maxLines: 6,
          autofocus: true,
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(dialogContext).pop(),
            child: const Text('Abbrechen'),
          ),
          FilledButton(
            key: const ValueKey('herbarium-note-save'),
            onPressed: () => Navigator.of(dialogContext).pop(editedNote),
            child: const Text('Speichern'),
          ),
        ],
      ),
    );
    if (note == null || !mounted || widget.onUpdateNote == null) return;
    final result = await widget.onUpdateNote!(entry, note.trim());
    if (!mounted) return;
    if (result case Success<HerbariumEntry>(:final value)) {
      setState(() => entry = value);
      return;
    }
    ScaffoldMessenger.of(this.context)
        .showSnackBar(SnackBar(content: Text(result.failureOrNull!.message)));
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
            Padding(
              padding: const EdgeInsets.fromLTRB(22, 10, 22, 12),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  InkWell(
                    onTap: () => Navigator.of(context).pop(),
                    borderRadius: BorderRadius.circular(999),
                    child: Container(
                      width: 40,
                      height: 40,
                      decoration: BoxDecoration(
                        color: AppColors.white,
                        shape: BoxShape.circle,
                        border: Border.all(color: AppColors.line),
                      ),
                      child: const Icon(
                        Icons.arrow_back,
                        size: 19,
                        color: AppColors.ink,
                      ),
                    ),
                  ),
                  Text(
                    'HERBARIUM',
                    style: AppTypography.textTheme.labelMedium?.copyWith(
                      fontWeight: FontWeight.w800,
                      letterSpacing: 1.2,
                      color: AppColors.sage700,
                    ),
                  ),
                  if (widget.onDelete != null)
                    InkWell(
                      key: const ValueKey('herbarium-delete-button'),
                      onTap: () => _confirmDelete(context),
                      borderRadius: BorderRadius.circular(999),
                      child: Container(
                        width: 40,
                        height: 40,
                        decoration: BoxDecoration(
                          color: AppColors.white,
                          shape: BoxShape.circle,
                          border: Border.all(color: AppColors.line),
                        ),
                        child: const Icon(
                          Icons.delete_outline,
                          size: 19,
                          color: AppColors.danger,
                        ),
                      ),
                    )
                  else
                    const SizedBox(width: 40),
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
                    _ObservationHero(entry: entry),
                    const SizedBox(height: 18),

                    // Title Area
                    Text(
                      entry.displayTitle,
                      style: AppTypography.textTheme.headlineMedium?.copyWith(
                        fontWeight: FontWeight.w700,
                        fontSize: 28,
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
                    const SizedBox(height: 18),

                    // Sync status banner (existing)
                    _SyncStatusBanner(entry: entry),
                    const SizedBox(height: 20),

                    FindInsights(entry: entry, insights: widget.insights),
                    if (widget.insights != null) const SizedBox(height: 20),

                    // PlantNet KI Result Card
                    if (hasPlantNetResult) ...[
                      _PlantNetResultCard(result: entry.identificationResult!),
                      const SizedBox(height: 20),
                    ],

                    _SectionHeader(
                      icon: Icons.edit_note_rounded,
                      title: 'Notizen & Feldeindrücke',
                      trailing: widget.onUpdateNote == null
                          ? null
                          : IconButton(
                              key: const ValueKey('herbarium-edit-note'),
                              tooltip: 'Notiz bearbeiten',
                              onPressed: () => _editNote(context),
                              icon: const Icon(Icons.edit_outlined),
                            ),
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
                    if (entry.latitude != null && entry.longitude != null) ...[
                      const SizedBox(height: 8),
                      _MetadataTile(
                        icon: Icons.location_on_outlined,
                        label: 'Fundort',
                        value: 'Privat gespeichert',
                      ),
                    ],
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
  const _SyncStatusBanner({required this.entry});

  final HerbariumEntry entry;

  @override
  Widget build(BuildContext context) {
    final (
      icon,
      color,
      bgColor,
      title,
      defaultDescription,
    ) = switch (entry.syncStatus) {
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
    final description = entry.syncError?.trim().isNotEmpty == true
        ? 'Letzter Fehler: ${entry.syncError}'
        : defaultDescription;

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
                  description,
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
  const _SectionHeader({
    required this.icon,
    required this.title,
    this.trailing,
  });

  final IconData icon;
  final String title;
  final Widget? trailing;

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
        if (trailing != null) ...[const Spacer(), trailing!],
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
