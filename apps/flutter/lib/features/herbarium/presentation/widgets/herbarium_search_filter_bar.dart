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
      padding: const EdgeInsets.fromLTRB(16, 12, 16, 8),
      decoration: const BoxDecoration(
        color: AppColors.white,
        border: Border(
          bottom: BorderSide(color: AppColors.line, width: 1),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          // Search input field
          TextField(
            key: const ValueKey('herbarium-search-field'),
            controller: searchController,
            onChanged: onSearchChanged,
            decoration: InputDecoration(
              hintText: 'Pflanze oder Notiz suchen...',
              hintStyle: AppTypography.textTheme.bodyMedium?.copyWith(
                color: AppColors.muted,
              ),
              prefixIcon: const Icon(
                Icons.search,
                color: AppColors.forest,
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
              fillColor: AppColors.cream,
              contentPadding: const EdgeInsets.symmetric(
                horizontal: 16,
                vertical: 10,
              ),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
                borderSide: BorderSide.none,
              ),
              focusedBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
                borderSide: const BorderSide(color: AppColors.forest, width: 1.5),
              ),
            ),
          ),
          const SizedBox(height: 10),

          // Filter chips
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
                    selectedStatus == SyncStatus.synced ? null : SyncStatus.synced,
                  ),
                ),
                const SizedBox(width: 8),
                _buildFilterChip(
                  key: const ValueKey('filter-pending'),
                  label: 'Ausstehend',
                  icon: Icons.cloud_upload_outlined,
                  isSelected: selectedStatus == SyncStatus.pending,
                  onTap: () => onStatusFilterChanged(
                    selectedStatus == SyncStatus.pending ? null : SyncStatus.pending,
                  ),
                ),
                const SizedBox(width: 8),
                _buildFilterChip(
                  key: const ValueKey('filter-conflict'),
                  label: 'Konflikte',
                  icon: Icons.warning_amber_rounded,
                  isSelected: selectedStatus == SyncStatus.conflict,
                  onTap: () => onStatusFilterChanged(
                    selectedStatus == SyncStatus.conflict ? null : SyncStatus.conflict,
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
    return FilterChip(
      key: key,
      label: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          if (icon != null) ...[
            Icon(
              icon,
              size: 16,
              color: isSelected ? AppColors.white : AppColors.forest,
            ),
            const SizedBox(width: 6),
          ],
          Text(label),
        ],
      ),
      selected: isSelected,
      onSelected: (_) => onTap(),
      selectedColor: AppColors.forest,
      backgroundColor: AppColors.cream,
      checkmarkColor: AppColors.white,
      showCheckmark: false,
      labelStyle: AppTypography.textTheme.labelMedium?.copyWith(
        color: isSelected ? AppColors.white : AppColors.ink,
        fontWeight: isSelected ? FontWeight.bold : FontWeight.w500,
      ),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(20),
        side: BorderSide(
          color: isSelected ? AppColors.forest : AppColors.line,
        ),
      ),
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
    );
  }
}
