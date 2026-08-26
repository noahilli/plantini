import 'package:flutter/material.dart';

import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_typography.dart';
import '../../domain/herbarium_models.dart';

/// Callback signature when an entry is selected.
typedef HerbariumEntryCallback = void Function(HerbariumEntry entry);

/// Reactive list view displaying digital herbarium observation entries.
class HerbariumListView extends StatelessWidget {
  const HerbariumListView({
    super.key,
    required this.entries,
    required this.onEntryTap,
    this.onDeleteEntry,
    this.onRefresh,
    this.emptyMessage,
  });

  final List<HerbariumEntry> entries;
  final HerbariumEntryCallback onEntryTap;
  final HerbariumEntryCallback? onDeleteEntry;
  final Future<void> Function()? onRefresh;
  final String? emptyMessage;

  @override
  Widget build(BuildContext context) {
    if (entries.isEmpty) {
      final emptyWidget = Center(
        child: SingleChildScrollView(
          physics: const AlwaysScrollableScrollPhysics(),
          child: Padding(
            padding: const EdgeInsets.all(32.0),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Container(
                  padding: const EdgeInsets.all(20),
                  decoration: BoxDecoration(
                    color: AppColors.cream,
                    shape: BoxShape.circle,
                    border: Border.all(color: AppColors.line),
                  ),
                  child: const Icon(
                    Icons.eco_outlined,
                    size: 48,
                    color: AppColors.forest,
                  ),
                ),
                const SizedBox(height: 20),
                Text(
                  'Keine Pflanzenfunde',
                  style: AppTypography.textTheme.titleLarge?.copyWith(
                    fontWeight: FontWeight.bold,
                    color: AppColors.forest,
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  emptyMessage ??
                      'Es wurden keine Einträge für die gewählten Filter gefunden.',
                  textAlign: TextAlign.center,
                  style: AppTypography.textTheme.bodyMedium?.copyWith(
                    color: AppColors.muted,
                  ),
                ),
              ],
            ),
          ),
        ),
      );

      if (onRefresh != null) {
        return RefreshIndicator(
          onRefresh: onRefresh!,
          color: AppColors.forest,
          child: emptyWidget,
        );
      }
      return emptyWidget;
    }

    final listView = ListView.separated(
      key: const ValueKey('herbarium-list-view'),
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      itemCount: entries.length,
      separatorBuilder: (_, _) => const SizedBox(height: 10),
      itemBuilder: (context, index) {
        final entry = entries[index];
        return _HerbariumEntryCard(
          key: ValueKey('herbarium-entry-${entry.id}'),
          entry: entry,
          onTap: () => onEntryTap(entry),
          onDelete: onDeleteEntry != null ? () => onDeleteEntry!(entry) : null,
        );
      },
    );

    if (onRefresh != null) {
      return RefreshIndicator(
        onRefresh: onRefresh!,
        color: AppColors.forest,
        child: listView,
      );
    }

    return listView;
  }
}

class _HerbariumEntryCard extends StatelessWidget {
  const _HerbariumEntryCard({
    super.key,
    required this.entry,
    required this.onTap,
    this.onDelete,
  });

  final HerbariumEntry entry;
  final VoidCallback onTap;
  final VoidCallback? onDelete;

  String _formatDate(DateTime date) {
    final day = date.day.toString().padLeft(2, '0');
    final month = date.month.toString().padLeft(2, '0');
    final year = date.year;
    final hour = date.hour.toString().padLeft(2, '0');
    final minute = date.minute.toString().padLeft(2, '0');
    return '$day.$month.$year, $hour:$minute Uhr';
  }

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 0,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
        side: const BorderSide(color: AppColors.line, width: 1),
      ),
      color: AppColors.white,
      clipBehavior: Clip.antiAlias,
      child: InkWell(
        onTap: onTap,
        child: Padding(
          padding: const EdgeInsets.all(12),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              // Thumbnail image
              _HerbariumThumbnail(mediaUrl: entry.mediaUrl),
              const SizedBox(width: 14),

              // Title, scientific name, date & note snippet
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      entry.displayTitle,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: AppTypography.textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.bold,
                        color: AppColors.ink,
                      ),
                    ),
                    if (entry.scientificName != null &&
                        entry.scientificName!.isNotEmpty &&
                        entry.scientificName != entry.plantName) ...[
                      const SizedBox(height: 2),
                      Text(
                        entry.scientificName!,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: AppTypography.textTheme.bodySmall?.copyWith(
                          fontStyle: FontStyle.italic,
                          color: AppColors.forest,
                        ),
                      ),
                    ],
                    const SizedBox(height: 4),
                    Row(
                      children: [
                        const Icon(
                          Icons.calendar_today_outlined,
                          size: 13,
                          color: AppColors.muted,
                        ),
                        const SizedBox(width: 4),
                        Text(
                          _formatDate(entry.observedAt),
                          style: AppTypography.textTheme.labelSmall?.copyWith(
                            color: AppColors.muted,
                          ),
                        ),
                      ],
                    ),
                    if (entry.note.isNotEmpty) ...[
                      const SizedBox(height: 4),
                      Text(
                        entry.note,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: AppTypography.textTheme.bodySmall?.copyWith(
                          color: AppColors.muted,
                        ),
                      ),
                    ],
                  ],
                ),
              ),
              const SizedBox(width: 8),

              // Sync status icon
              _SyncStatusIcon(status: entry.syncStatus),
              const SizedBox(width: 4),
              const Icon(
                Icons.chevron_right,
                color: AppColors.muted,
                size: 20,
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _HerbariumThumbnail extends StatelessWidget {
  const _HerbariumThumbnail({this.mediaUrl});

  final String? mediaUrl;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 64,
      height: 64,
      decoration: BoxDecoration(
        color: AppColors.cream,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppColors.line),
      ),
      clipBehavior: Clip.antiAlias,
      child: mediaUrl != null && mediaUrl!.isNotEmpty
          ? Image.network(
              mediaUrl!,
              fit: BoxFit.cover,
              errorBuilder: (_, _, _) => const Center(
                child: Icon(
                  Icons.eco_rounded,
                  color: AppColors.sage,
                  size: 28,
                ),
              ),
              loadingBuilder: (context, child, progress) {
                if (progress == null) return child;
                return const Center(
                  child: SizedBox(
                    width: 20,
                    height: 20,
                    child: CircularProgressIndicator(
                      strokeWidth: 2,
                      color: AppColors.forest,
                    ),
                  ),
                );
              },
            )
          : const Center(
              child: Icon(
                Icons.eco_rounded,
                color: AppColors.sage,
                size: 28,
              ),
            ),
    );
  }
}

class _SyncStatusIcon extends StatelessWidget {
  const _SyncStatusIcon({required this.status});

  final SyncStatus status;

  @override
  Widget build(BuildContext context) {
    final (icon, color, tooltip) = switch (status) {
      SyncStatus.synced => (
          Icons.cloud_done,
          AppColors.forest,
          'Synchronisiert',
        ),
      SyncStatus.pending => (
          Icons.cloud_upload_outlined,
          AppColors.bark,
          'Ausstehend (Lokal)',
        ),
      SyncStatus.conflict => (
          Icons.warning_amber_rounded,
          AppColors.danger,
          'Synchronisationskonflikt',
        ),
      SyncStatus.deleted => (
          Icons.delete_outline,
          AppColors.muted,
          'Gelöscht',
        ),
    };

    return Tooltip(
      message: tooltip,
      child: Container(
        padding: const EdgeInsets.all(6),
        decoration: BoxDecoration(
          color: color.withOpacity(0.12),
          shape: BoxShape.circle,
        ),
        child: Icon(
          icon,
          size: 18,
          color: color,
        ),
      ),
    );
  }
}
