import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter/foundation.dart' show kIsWeb;
import '../../storage/offline_queue_service.dart';
import '../../storage/isar_collection.dart';

class HerbariumScreen extends StatefulWidget {
  final OfflineQueueService queueService;

  const HerbariumScreen({super.key, required this.queueService});

  @override
  State<HerbariumScreen> createState() => _HerbariumScreenState();
}

class _HerbariumScreenState extends State<HerbariumScreen> {
  List<OfflineObservation> _observations = [];
  String _searchQuery = '';
  String _filterOrgan = 'All';
  
  final List<String> _organs = ['All', 'leaf', 'flower', 'fruit', 'bark', 'habit'];

  @override
  void initState() {
    super.initState();
    _loadObservations();
    widget.queueService.addListener(_loadObservations);
  }

  @override
  void dispose() {
    widget.queueService.removeListener(_loadObservations);
    super.dispose();
  }

  Future<void> _loadObservations() async {
    final obs = await widget.queueService.getAllObservations();
    setState(() {
      _observations = obs;
    });
  }

  List<OfflineObservation> get _filteredObservations {
    return _observations.where((obs) {
      final matchesSearch = _searchQuery.isEmpty || 
          (obs.notes?.toLowerCase().contains(_searchQuery.toLowerCase()) ?? false);
      final matchesOrgan = _filterOrgan == 'All' || obs.organ == _filterOrgan;
      return matchesSearch && matchesOrgan;
    }).toList();
  }

  Future<void> _editNotes(OfflineObservation obs) async {
    final controller = TextEditingController(text: obs.notes);
    final newNotes = await showDialog<String>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Notizen bearbeiten'),
        content: TextField(
          controller: controller,
          decoration: const InputDecoration(hintText: 'Beobachtungsnotizen...'),
          maxLines: 3,
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context), child: const Text('Abbrechen')),
          ElevatedButton(onPressed: () => Navigator.pop(context, controller.text), child: const Text('Speichern')),
        ],
      ),
    );
    
    if (newNotes != null) {
      await widget.queueService.updateNotes(obs.id, newNotes);
    }
  }

  Future<void> _deleteObservation(int id) async {
    final confirm = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Löschen bestätigen'),
        content: const Text('Möchtest du diese Beobachtung wirklich löschen?'),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context, false), child: const Text('Abbrechen')),
          ElevatedButton(
            style: ElevatedButton.styleFrom(backgroundColor: Theme.of(context).colorScheme.error),
            onPressed: () => Navigator.pop(context, true), 
            child: Text('Löschen', style: TextStyle(color: Theme.of(context).colorScheme.onError)),
          ),
        ],
      ),
    );
    
    if (confirm == true) {
      await widget.queueService.deleteObservation(id);
    }
  }

  @override
  Widget build(BuildContext context) {
    final items = _filteredObservations;
    
    return Scaffold(
      appBar: AppBar(
        title: const Text('Herbarium'),
        bottom: PreferredSize(
          preferredSize: const Size.fromHeight(110),
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                TextField(
                  decoration: const InputDecoration(
                    hintText: 'Suchen...',
                    prefixIcon: Icon(Icons.search),
                    filled: true,
                  ),
                  onChanged: (value) => setState(() => _searchQuery = value),
                ),
                const SizedBox(height: 8),
                SingleChildScrollView(
                  scrollDirection: Axis.horizontal,
                  child: Row(
                    children: _organs.map((organ) => Padding(
                      padding: const EdgeInsets.only(right: 8.0),
                      child: ChoiceChip(
                        label: Text(organ.toUpperCase()),
                        selected: _filterOrgan == organ,
                        onSelected: (selected) {
                          if (selected) setState(() => _filterOrgan = organ);
                        },
                      ),
                    )).toList(),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
      body: items.isEmpty
        ? const Center(child: Text('Keine Beobachtungen gefunden.'))
        : ListView.builder(
            padding: const EdgeInsets.all(8.0),
            itemCount: items.length,
            itemBuilder: (context, index) {
              final obs = items[index];
              return Card(
                child: Column(
                  children: [
                    if (kIsWeb)
                      Image.network(obs.imagePath, height: 200, width: double.infinity, fit: BoxFit.cover)
                    else
                      Image.file(File(obs.imagePath), height: 200, width: double.infinity, fit: BoxFit.cover),
                    ListTile(
                      title: Text(obs.capturedAt.toLocal().toString().split('.')[0]),
                      subtitle: Text('Organ: ${obs.organ} | Synced: ${obs.isSynced}\nNotizen: ${obs.notes ?? "-"}'),
                      isThreeLine: true,
                    ),
                    OverflowBar(
                      children: [
                        TextButton.icon(
                          onPressed: () => _editNotes(obs),
                          icon: const Icon(Icons.edit),
                          label: const Text('Notizen'),
                        ),
                        TextButton.icon(
                          onPressed: () => _deleteObservation(obs.id),
                          icon: const Icon(Icons.delete, color: Colors.red),
                          label: const Text('Löschen', style: TextStyle(color: Colors.red)),
                        ),
                      ],
                    )
                  ],
                ),
              );
            },
          ),
    );
  }
}
