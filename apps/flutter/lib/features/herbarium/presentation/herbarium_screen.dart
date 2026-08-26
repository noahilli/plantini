import 'package:flutter/material.dart';

import '../../../app/app_dependencies.dart';
import '../../../core/result.dart';
import '../../../core/theme/app_colors.dart';
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
  });

  final AppDependencies? dependencies;
  final HerbariumRepository? repository;
  final ListHerbarium? listHerbarium;
  final DeleteEntry? deleteEntry;
  final SyncEntries? syncEntries;

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
    _repository = widget.repository ??
        widget.dependencies?.herbariumRepository ??
        LocalHerbariumRepository();

    _listUseCase = widget.listHerbarium ??
        widget.dependencies?.listHerbarium ??
        ListHerbarium(_repository);

    _deleteUseCase = widget.deleteEntry ??
        widget.dependencies?.deleteHerbariumEntry ??
        DeleteEntry(_repository);

    _syncUseCase = widget.syncEntries ??
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
      setState(() => _isSyncing = false);
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

  Future<void> _showAddObservationDialog() async {
    final result = await showDialog<(String, String)>(
      context: context,
      builder: (ctx) => const _AddObservationDialog(),
    );

    if (result != null && mounted) {
      final (name, note) = result;
      final now = DateTime.now();
      final clientId = 'obs-${now.millisecondsSinceEpoch}';

      final createResult = await _repository.createEntry(
        clientObservationId: clientId,
        observedAt: now,
        plantName: name.isNotEmpty ? name : 'Unbekannter Fund',
        note: note,
        identificationResult: 'Manuell hinzugefügter Feldfund',
        idempotencyKey: clientId,
      );

      if (createResult case Success<HerbariumEntry>(:final value)) {
        setState(() {
          _allEntries.removeWhere((e) => e.id == value.id);
          _allEntries.insert(0, value);
        });
      }
    }
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
      appBar: AppBar(
        title: const Text('Herbarium'),
        actions: [
          IconButton(
            key: const ValueKey('herbarium-sync-button'),
            tooltip: 'Synchronisieren',
            onPressed: _isSyncing ? null : _handleSync,
            icon: _isSyncing
                ? const SizedBox(
                    width: 20,
                    height: 20,
                    child: CircularProgressIndicator(
                      strokeWidth: 2,
                      color: AppColors.white,
                    ),
                  )
                : const Icon(Icons.sync),
          ),
        ],
      ),
      body: Column(
        children: [
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
                    emptyMessage: _searchQuery.isNotEmpty || _selectedStatus != null
                        ? 'Keine Funde für die aktuelle Suche oder Filterung gefunden.'
                        : 'Noch keine Pflanzenfunde im Herbarium erfasst.',
                  ),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        key: const ValueKey('herbarium-add-observation'),
        tooltip: 'Neuen Fund hinzufügen',
        onPressed: _showAddObservationDialog,
        backgroundColor: AppColors.forest,
        foregroundColor: AppColors.white,
        child: const Icon(Icons.add_photo_alternate_outlined),
      ),
    );
  }
}

class _AddObservationDialog extends StatefulWidget {
  const _AddObservationDialog();

  @override
  State<_AddObservationDialog> createState() => _AddObservationDialogState();
}

class _AddObservationDialogState extends State<_AddObservationDialog> {
  late final TextEditingController _nameController = TextEditingController();
  late final TextEditingController _noteController = TextEditingController();

  @override
  void dispose() {
    _nameController.dispose();
    _noteController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: const Text('Neuen Fund erfassen'),
      content: SingleChildScrollView(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(
              key: const ValueKey('add-plant-name'),
              controller: _nameController,
              decoration: const InputDecoration(
                labelText: 'Pflanzenname',
                hintText: 'z.B. Wald-Sauerklee',
              ),
            ),
            const SizedBox(height: 12),
            TextField(
              key: const ValueKey('add-plant-note'),
              controller: _noteController,
              decoration: const InputDecoration(
                labelText: 'Notiz / Fundort',
                hintText: 'z.B. Im schattigen Buchenwald gefunden.',
              ),
              maxLines: 2,
            ),
          ],
        ),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.of(context).pop(),
          child: const Text('Abbrechen'),
        ),
        FilledButton(
          key: const ValueKey('submit-add-plant'),
          onPressed: () {
            Navigator.of(context).pop((
              _nameController.text.trim(),
              _noteController.text.trim(),
            ));
          },
          child: const Text('Speichern'),
        ),
      ],
    );
  }
}
