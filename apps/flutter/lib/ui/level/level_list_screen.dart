import 'package:flutter/material.dart';
import 'package:openapi/openapi.dart';
import '../plant/plant_profile_screen.dart';
import '../../storage/progress_service.dart';

class LevelListScreen extends StatefulWidget {
  final Ecosystem ecosystem;
  final Openapi api;
  final ProgressService? progressService;

  const LevelListScreen({super.key, required this.ecosystem, required this.api, this.progressService});

  @override
  State<LevelListScreen> createState() => _LevelListScreenState();
}

class _LevelListScreenState extends State<LevelListScreen> {
  List<Level>? _levels;
  bool _isLoading = true;
  String? _error;

  @override
  void initState() {
    super.initState();
    _fetchLevels();
  }

  Future<void> _fetchLevels() async {
    try {
      final res = await widget.api.getDefaultApi().listLevels();
      setState(() {
        _levels = res.data?.toList();
        _isLoading = false;
      });
    } catch (e) {
      setState(() {
        _error = e.toString();
        _isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.ecosystem.name),
      ),
      body: _isLoading 
        ? const Center(child: CircularProgressIndicator())
        : _error != null
          ? Center(child: Text('Error: $_error'))
          : ListView.builder(
              itemCount: _levels?.length ?? 0,
              itemBuilder: (context, index) {
                final level = _levels![index];
                final bool isUnlocked = level.isUnlocked ?? true; // isUnlocked is nullable
                
                return ListTile(
                  leading: Icon(
                    isUnlocked ? Icons.lock_open : Icons.lock,
                    color: isUnlocked ? Theme.of(context).colorScheme.primary : Colors.grey,
                  ),
                  title: Text(
                    level.title,
                    style: Theme.of(context).textTheme.titleMedium?.copyWith(
                      color: isUnlocked ? null : Colors.grey,
                    ),
                  ),
                  subtitle: isUnlocked 
                      ? LinearProgressIndicator(value: level.progress ?? 0.0)
                      : const Text('Gesperrt'),
                  onTap: isUnlocked ? () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (_) => PlantProfileScreen(
                          plantId: 'mock-plant-1', 
                          api: widget.api,
                          progressService: widget.progressService,
                        ),
                      ),
                    );
                  } : null,
                );
              },
            ),
    );
  }
}
