import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../../app/app_dependencies.dart';
import '../../../core/result.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_typography.dart';
import '../../../design_system/async_state_view.dart';
import '../application/herbarium_use_cases.dart';
import '../domain/herbarium_models.dart';
import '../domain/herbarium_repository.dart';
import '../infrastructure/local_herbarium_repository.dart';
import 'herbarium_detail_screen.dart';
import 'widgets/herbarium_list_view.dart';
import 'widgets/herbarium_search_filter_bar.dart';

/// Screen displaying the user's digital herbarium with reactive list updates,
/// offline caching, and real-time search & status filtering.
class HerbariumScreen extends StatefulWidget {
  const HerbariumScreen({
    super.key,
    this.dependencies,
    this.repository,
    this.listHerbarium,
    this.deleteEntry,
    this.syncEntries,
    this.onStartField,
  });

  final AppDependencies? dependencies;
  final HerbariumRepository? repository;
  final ListHerbarium? listHerbarium;
  final DeleteEntry? deleteEntry;
  final SyncEntries? syncEntries;
  final VoidCallback? onStartField;

  @override
  State<HerbariumScreen> createState() => _HerbariumScreenState();
}

class _HerbariumScreenState extends State<HerbariumScreen> {
  late final HerbariumRepository _repository;
  late final ListHerbarium _listUseCase;
  late final DeleteEntry _deleteUseCase;
  late final SyncEntries _syncUseCase;

  final TextEditingController _searchController = TextEditingController();
  List<HerbariumEntry> _allEntries = [];
  bool _isLoading = true;
  bool _isSyncing = false;
  String _searchQuery = '';
  SyncStatus? _selectedStatus;

  @override
  void initState() {
    super.initState();
    _initDependencies();
    _loadEntries();
  }

  void _initDependencies() {
    _repository =
        widget.repository ??
        widget.dependencies?.herbariumRepository ??
        LocalHerbariumRepository();

    _listUseCase =
        widget.listHerbarium ??
        widget.dependencies?.listHerbarium ??
        ListHerbarium(_repository);

    _deleteUseCase =
        widget.deleteEntry ??
        widget.dependencies?.deleteHerbariumEntry ??
        DeleteEntry(_repository);

    _syncUseCase =
        widget.syncEntries ??
        widget.dependencies?.syncHerbariumEntries ??
        SyncEntries(_repository);
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  Future<void> _loadEntries() async {
    setState(() => _isLoading = true);
    final result = await _listUseCase();
    if (!mounted) return;

    if (result case Success<List<HerbariumEntry>>(:final value)) {
      setState(() {
        _allEntries = List.of(value);
        _isLoading = false;
      });
    } else {
      setState(() {
        _isLoading = false;
      });
    }
  }

  Future<void> _handleSync() async {
    if (_isSyncing) return;
    setState(() => _isSyncing = true);

    final result = await _syncUseCase();
    if (!mounted) return;

    if (result case Success<List<HerbariumEntry>>(:final value)) {
      setState(() {
        _allEntries = List.of(value);
        _isSyncing = false;
      });
    } else {
      final failure = result.failureOrNull;
      setState(() => _isSyncing = false);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            failure?.message ??
                'Das Herbarium konnte nicht synchronisiert werden.',
          ),
        ),
      );
    }
  }

  Future<void> _handleDeleteEntry(HerbariumEntry entry) async {
    final result = await _deleteUseCase(
      id: entry.id,
      ifMatchVersion: entry.version,
    );

    if (result.isSuccess && mounted) {
      setState(() {
        _allEntries.removeWhere((e) => e.id == entry.id);
      });
    }
  }

  void _startField() {
    final callback = widget.onStartField;
    if (callback != null) {
      callback();
      return;
    }
    context.go('/field');
  }

  void _onEntryTap(HerbariumEntry entry) {
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (ctx) => HerbariumDetailScreen(
          entry: entry,
          onDelete: (item) async {
            await _handleDeleteEntry(item);
          },
        ),
      ),
    );
  }

  List<HerbariumEntry> get _filteredEntries {
    return _allEntries.where((entry) {
      final matchesStatus =
          _selectedStatus == null || entry.syncStatus == _selectedStatus;
      if (!matchesStatus) return false;

      if (_searchQuery.isEmpty) return true;
      final q = _searchQuery.toLowerCase();
      final matchesTitle = entry.displayTitle.toLowerCase().contains(q);
      final matchesScientific =
          entry.scientificName?.toLowerCase().contains(q) ?? false;
      final matchesNote = entry.note.toLowerCase().contains(q);

      return matchesTitle || matchesScientific || matchesNote;
    }).toList();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.neutral100,
      body: SafeArea(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // Custom Header matching 1p
            Padding(
              padding: const EdgeInsets.fromLTRB(22, 10, 22, 12),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        'MEIN HERBARIUM',
                        style: AppTypography.textTheme.labelSmall?.copyWith(
                          color: AppColors.sage700,
                          fontWeight: FontWeight.bold,
                          letterSpacing: 1.3,
                        ),
                      ),
                      IconButton(
                        key: const ValueKey('herbarium-sync-button'),
                        tooltip: 'Synchronisieren',
                        onPressed: _isSyncing ? null : _handleSync,
                        icon: _isSyncing
                            ? const SizedBox(
                                width: 16,
                                height: 16,
                                child: CircularProgressIndicator(
                                  strokeWidth: 2,
                                  color: AppColors.sage700,
                                ),
                              )
                            : const Icon(
                                Icons.sync,
                                color: AppColors.sage700,
                                size: 20,
                              ),
                      ),
                    ],
                  ),
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.baseline,
                    textBaseline: TextBaseline.alphabetic,
                    children: [
                      Text(
                        '${_allEntries.length}',
                        style: AppTypography.textTheme.displaySmall?.copyWith(
                          fontWeight: FontWeight.w400,
                          fontSize: 34,
                          color: AppColors.ink,
                        ),
                      ),
                      const SizedBox(width: 9),
                      Text(
                        'Funde',
                        style: AppTypography.textTheme.titleMedium?.copyWith(
                          fontWeight: FontWeight.w400,
                          fontSize: 16,
                          color: AppColors.neutral600,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),

            // Search & Filter UI
            HerbariumSearchFilterBar(
              searchQuery: _searchQuery,
              selectedStatus: _selectedStatus,
              searchController: _searchController,
              onSearchChanged: (query) {
                setState(() => _searchQuery = query);
              },
              onStatusFilterChanged: (status) {
                setState(() => _selectedStatus = status);
              },
            ),

            // Reactive List View
            Expanded(
              child: _isLoading
                  ? const AsyncStateView(kind: AsyncViewKind.loading)
                  : HerbariumListView(
                      entries: _filteredEntries,
                      onEntryTap: _onEntryTap,
                      onDeleteEntry: _handleDeleteEntry,
                      onRefresh: _loadEntries,
                      emptyMessage:
                          _searchQuery.isNotEmpty || _selectedStatus != null
                          ? 'Keine Funde für die aktuelle Suche oder Filterung gefunden.'
                          : 'Noch keine Pflanzenfunde im Herbarium erfasst.',
                    ),
            ),
          ],
        ),
      ),
      floatingActionButton: FloatingActionButton(
        key: const ValueKey('herbarium-add-observation'),
        tooltip: 'Neuen Fund bestimmen',
        onPressed: _startField,
        backgroundColor: AppColors.terracotta,
        foregroundColor: AppColors.white,
        child: const Icon(Icons.add_photo_alternate_outlined),
      ),
    );
  }
}
