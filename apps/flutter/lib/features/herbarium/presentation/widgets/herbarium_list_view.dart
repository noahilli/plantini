import 'package:flutter/material.dart';

import '../../../../core/images/plantini_image.dart';
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
                  emptyMessage ?? 'Es wurden keine Einträge für die gewählten Filter gefunden.',
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

    final listView = GridView.builder(
      key: const ValueKey('herbarium-list-view'),
      padding: const EdgeInsets.symmetric(horizontal: 22, vertical: 12),
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 2,
        crossAxisSpacing: 10,
        mainAxisSpacing: 10,
        childAspectRatio: 0.8,
      ),
      itemCount: entries.length,
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

  String _formatDateShort(DateTime date) {
    const months = [
      'Jan',
      'Feb',
      'Mär',
      'Apr',
      'Mai',
      'Jun',
      'Jul',
      'Aug',
      'Sep',
      'Okt',
      'Nov',
      'Dez',
    ];
    return '${date.day}. ${months[date.month - 1]}';
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: AppColors.bg,
        borderRadius: BorderRadius.circular(22),
        boxShadow: const [
          BoxShadow(
            color: Color(0x242E2B25), // --shadow-sm roughly
            blurRadius: 2,
            offset: Offset(0, 1),
          ),
        ],
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          borderRadius: BorderRadius.circular(22),
          onTap: onTap,
          child: Padding(
            padding: const EdgeInsets.all(9),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                // Thumbnail image
                Expanded(
                  child: _HerbariumThumbnail(
                    mediaUrl: entry.photoUrl(width: 320),
                  ),
                ),
                // Text Area
                Padding(
                  padding: const EdgeInsets.fromLTRB(4, 8, 4, 3),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        entry.displayTitle,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: AppTypography.textTheme.bodyMedium?.copyWith(
                          fontWeight: FontWeight.bold,
                          fontSize: 12,
                          color: AppColors.ink,
                        ),
                      ),
                      const SizedBox(height: 2),
                      Row(
                        children: [
                          Expanded(
                            child: Text(
                              entry.syncStatus == SyncStatus.pending ||
                                      entry.syncStatus == SyncStatus.conflict
                                  ? 'offline · nicht synchron'
                                  : '${_formatDateShort(entry.observedAt)} · ${entry.identificationResult != null ? 'bestimmt' : 'manuell'}',
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                              style: AppTypography.textTheme.bodySmall
                                  ?.copyWith(
                                    fontSize: 10,
                                    color:
                                        entry.syncStatus ==
                                                SyncStatus.conflict ||
                                            entry.syncStatus ==
                                                SyncStatus.pending
                                        ? AppColors.terracotta
                                        : AppColors.neutral700,
                                  ),
                            ),
                          ),
                          if (entry.syncStatus != SyncStatus.synced) ...[
                            const SizedBox(width: 4),
                            _SyncStatusIcon(status: entry.syncStatus),
                          ],
                        ],
                      ),
                    ],
                  ),
                ),
              ],
            ),
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
          ? PlantiniImage(
              mediaUrl!,
              authenticated: true,
              decodeWidth: 64,
              errorBuilder: (_, _) => const Center(
                child: Icon(Icons.eco_rounded, color: AppColors.sage, size: 28),
              ),
            )
          : const Center(
              child: Icon(Icons.eco_rounded, color: AppColors.sage, size: 28),
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
      SyncStatus.deleted => (Icons.delete_outline, AppColors.muted, 'Gelöscht'),
    };

    return Tooltip(
      message: tooltip,
      child: Container(
        padding: const EdgeInsets.all(6),
        decoration: BoxDecoration(
          color: color.withOpacity(0.12),
          shape: BoxShape.circle,
        ),
        child: Icon(icon, size: 18, color: color),
      ),
    );
  }
}
