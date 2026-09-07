import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../../app/app_dependencies.dart';
import '../../../core/result.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_typography.dart';
import '../../../design_system/async_state_view.dart';
import '../../catalog/application/catalog_use_cases.dart';
import '../../catalog/domain/catalog_models.dart';
import '../application/herbarium_use_cases.dart';
import '../domain/herbarium_models.dart';
import '../domain/herbarium_repository.dart';
import '../infrastructure/local_herbarium_repository.dart';
import 'herbarium_detail_screen.dart';
import 'widgets/herbarium_list_view.dart';
import 'widgets/herbarium_bottle_collection.dart';
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
    this.loadEcosystems,
    this.loadLevels,
    this.loadPlant,
  });

  final AppDependencies? dependencies;
  final HerbariumRepository? repository;
  final ListHerbarium? listHerbarium;
  final DeleteEntry? deleteEntry;
  final SyncEntries? syncEntries;
  final VoidCallback? onStartField;
  final LoadPublishedEcosystems? loadEcosystems;
  final LoadPublishedLevels? loadLevels;
  final LoadPublishedPlant? loadPlant;

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
  String? _entriesError;
  bool _showCollection = true;

  bool get _hasCatalog =>
      (widget.loadEcosystems ?? widget.dependencies?.loadEcosystems) != null &&
      (widget.loadLevels ?? widget.dependencies?.loadLevels) != null &&
      (widget.loadPlant ?? widget.dependencies?.loadPlant) != null;

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
    setState(() {
      _isLoading = true;
      _entriesError = null;
    });
    final result = await _listUseCase.all();
    if (!mounted) return;

    if (result case Success<List<HerbariumEntry>>(:final value)) {
      setState(() {
        _allEntries = List.of(value);
        _isLoading = false;
      });
    } else {
      setState(() {
        _isLoading = false;
        _entriesError =
            result.failureOrNull?.message ??
            'Funde konnten nicht geladen werden.';
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
      await _loadEntries();
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

  Future<Result<HerbariumEntry>> _handleUpdateNote(
    HerbariumEntry entry,
    String note,
  ) async {
    final result = await _repository.updateEntry(
      id: entry.id,
      note: note,
      ifMatchVersion: entry.version,
    );
    if (result case Success<HerbariumEntry>(:final value)) {
      if (mounted) {
        setState(() {
          final index = _allEntries.indexWhere((item) => item.id == value.id);
          if (index >= 0) _allEntries[index] = value;
        });
      }
    }
    return result;
  }

  void _startField() {
    final callback = widget.onStartField;
    if (callback != null) {
      callback();
      return;
    }
    context.go('/field');
  }

  void _discoverPlant(Plant plant) {
    if (widget.onStartField != null) {
      widget.onStartField!();
      return;
    }
    context.go(
      Uri(
        path: '/field',
        queryParameters: {
          'expectedPlantId': plant.id,
          'expectedPlantName': plant.commonName,
        },
      ).toString(),
    );
  }

  void _onEntryTap(HerbariumEntry entry) {
    Navigator.of(context)
        .push(
          MaterialPageRoute(
            builder: (ctx) => HerbariumDetailScreen(
              entry: entry,
              onDelete: (item) async {
                await _handleDeleteEntry(item);
              },
              onUpdateNote: _handleUpdateNote,
            ),
          ),
        )
        .then((_) {
          if (mounted) _loadEntries();
        });
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

            if (_hasCatalog)
              Padding(
                padding: const EdgeInsets.fromLTRB(22, 0, 22, 12),
                child: Wrap(
                  spacing: 8,
                  runSpacing: 8,
                  children: [
                    ChoiceChip(
                      key: const ValueKey('herbarium-tab-collection'),
                      label: const Text('Sammlung'),
                      selected: _showCollection,
                      onSelected: (_) => setState(() => _showCollection = true),
                    ),
                    ChoiceChip(
                      key: const ValueKey('herbarium-tab-observations'),
                      label: const Text('Beobachtungen'),
                      selected: !_showCollection,
                      onSelected: (_) =>
                          setState(() => _showCollection = false),
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

            if (_entriesError != null)
              Flexible(
                flex: 0,
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 22),
                  child: Row(
                    children: [
                      Expanded(child: Text(_entriesError!)),
                      IconButton(
                        key: const ValueKey('herbarium-entries-retry'),
                        tooltip: 'Funde erneut laden',
                        onPressed: _loadEntries,
                        icon: const Icon(Icons.refresh),
                      ),
                    ],
                  ),
                ),
              ),

            // Keep the catalog mounted while browsing personal observations.
            Expanded(
              child: _hasCatalog
                  ? IndexedStack(
                      index: _showCollection ? 0 : 1,
                      children: [
                        HerbariumBottleCollection(
                          loadEcosystems:
                              (widget.loadEcosystems ??
                              widget.dependencies?.loadEcosystems)!,
                          loadLevels:
                              (widget.loadLevels ??
                              widget.dependencies?.loadLevels)!,
                          loadPlant:
                              (widget.loadPlant ??
                              widget.dependencies?.loadPlant)!,
                          entries: _allEntries,
                          entriesAvailable:
                              !_isLoading && _entriesError == null,
                          searchQuery: _searchQuery,
                          selectedStatus: _selectedStatus,
                          onEntryTap: _onEntryTap,
                          onStartField: _startField,
                          onDiscoverPlant: _discoverPlant,
                          onRefreshEntries: _loadEntries,
                        ),
                        _buildObservations(),
                      ],
                    )
                  : _buildObservations(),
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

  Widget _buildObservations() => _isLoading
      ? const AsyncStateView(kind: AsyncViewKind.loading)
      : HerbariumListView(
          entries: _filteredEntries,
          onEntryTap: _onEntryTap,
          onDeleteEntry: _handleDeleteEntry,
          onRefresh: _loadEntries,
          emptyMessage: _searchQuery.isNotEmpty || _selectedStatus != null
              ? 'Keine Funde für die aktuelle Suche oder Filterung gefunden.'
              : _entriesError ??
                    'Noch keine Pflanzenfunde im Herbarium erfasst.',
        );
}
