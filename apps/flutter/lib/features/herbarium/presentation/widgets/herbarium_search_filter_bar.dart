import 'package:flutter/material.dart';

import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_typography.dart';
import '../../domain/herbarium_models.dart';

/// Search and filter bar widget for filtering herbarium entries in-memory.
class HerbariumSearchFilterBar extends StatelessWidget {
  const HerbariumSearchFilterBar({
    super.key,
    required this.searchQuery,
    required this.selectedStatus,
    required this.onSearchChanged,
    required this.onStatusFilterChanged,
    this.searchController,
  });

  final String searchQuery;
  final SyncStatus? selectedStatus;
  final ValueChanged<String> onSearchChanged;
  final ValueChanged<SyncStatus?> onStatusFilterChanged;
  final TextEditingController? searchController;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.fromLTRB(22, 0, 22, 12),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          // Search input field (Styled organically)
          TextField(
            key: const ValueKey('herbarium-search-field'),
            controller: searchController,
            onChanged: onSearchChanged,
            decoration: InputDecoration(
              hintText: 'Pflanze oder Notiz suchen...',
              hintStyle: AppTypography.textTheme.bodyMedium?.copyWith(
                color: AppColors.neutral500,
              ),
              prefixIcon: const Icon(
                Icons.search,
                color: AppColors.sage700,
                size: 22,
              ),
              suffixIcon: searchQuery.isNotEmpty
                  ? IconButton(
                      key: const ValueKey('herbarium-search-clear'),
                      icon: const Icon(Icons.clear, size: 20),
                      onPressed: () {
                        searchController?.clear();
                        onSearchChanged('');
                      },
                    )
                  : null,
              filled: true,
              fillColor: AppColors.white,
              contentPadding: const EdgeInsets.symmetric(
                horizontal: 16,
                vertical: 10,
              ),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(999),
                borderSide: BorderSide.none,
              ),
              focusedBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(999),
                borderSide: const BorderSide(
                  color: AppColors.terracotta,
                  width: 1.5,
                ),
              ),
            ),
          ),
          const SizedBox(height: 12),

          // Filter chips styled as Organic tags
          SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            child: Row(
              children: [
                _buildFilterChip(
                  key: const ValueKey('filter-all'),
                  label: 'Alle',
                  isSelected: selectedStatus == null,
                  onTap: () => onStatusFilterChanged(null),
                ),
                const SizedBox(width: 8),
                _buildFilterChip(
                  key: const ValueKey('filter-synced'),
                  label: 'Synchronisiert',
                  icon: Icons.cloud_done_outlined,
                  isSelected: selectedStatus == SyncStatus.synced,
                  onTap: () => onStatusFilterChanged(
                    selectedStatus == SyncStatus.synced
                        ? null
                        : SyncStatus.synced,
                  ),
                ),
                const SizedBox(width: 8),
                _buildFilterChip(
                  key: const ValueKey('filter-pending'),
                  label: 'Ausstehend',
                  icon: Icons.cloud_upload_outlined,
                  isSelected: selectedStatus == SyncStatus.pending,
                  onTap: () => onStatusFilterChanged(
                    selectedStatus == SyncStatus.pending
                        ? null
                        : SyncStatus.pending,
                  ),
                ),
                const SizedBox(width: 8),
                _buildFilterChip(
                  key: const ValueKey('filter-conflict'),
                  label: 'Konflikte',
                  icon: Icons.warning_amber_rounded,
                  isSelected: selectedStatus == SyncStatus.conflict,
                  onTap: () => onStatusFilterChanged(
                    selectedStatus == SyncStatus.conflict
                        ? null
                        : SyncStatus.conflict,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildFilterChip({
    required Key key,
    required String label,
    IconData? icon,
    required bool isSelected,
    required VoidCallback onTap,
  }) {
    return InkWell(
      key: key,
      onTap: onTap,
      borderRadius: BorderRadius.circular(999),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
        decoration: BoxDecoration(
          color: isSelected ? AppColors.accent100 : Colors.transparent,
          borderRadius: BorderRadius.circular(999),
          border: Border.all(
            color: isSelected ? Colors.transparent : AppColors.terracotta,
          ),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            if (icon != null) ...[
              Icon(
                icon,
                size: 14,
                color: isSelected ? AppColors.accent800 : AppColors.terracotta,
              ),
              const SizedBox(width: 4),
            ],
            Text(
              label,
              style: AppTypography.textTheme.bodySmall?.copyWith(
                color: isSelected ? AppColors.accent800 : AppColors.terracotta,
                fontWeight: isSelected ? FontWeight.bold : FontWeight.w500,
                fontSize: 11,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
