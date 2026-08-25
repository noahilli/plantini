import 'package:flutter/material.dart';
import 'package:openapi/openapi.dart';
import '../learning/learning_flow_screen.dart';
import '../../storage/progress_service.dart';

class PlantProfileScreen extends StatefulWidget {
  final String plantId;
  final Openapi api;
  final ProgressService? progressService;

  const PlantProfileScreen({super.key, required this.plantId, required this.api, this.progressService});

  @override
  State<PlantProfileScreen> createState() => _PlantProfileScreenState();
}

class _PlantProfileScreenState extends State<PlantProfileScreen> {
  Plant? _plant;
  bool _isLoading = true;
  String? _error;

  @override
  void initState() {
    super.initState();
    _fetchPlant();
  }

  Future<void> _fetchPlant() async {
    try {
      final res = await widget.api.getDefaultApi().getPlant(id: widget.plantId);
      setState(() {
        _plant = res.data;
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
    if (_isLoading) {
      return Scaffold(
        appBar: AppBar(title: const Text('Loading...')),
        body: const Center(child: CircularProgressIndicator()),
      );
    }
    
    if (_error != null || _plant == null) {
      return Scaffold(
        appBar: AppBar(title: const Text('Error')),
        body: Center(child: Text('Error: $_error')),
      );
    }

    return Scaffold(
      appBar: AppBar(
        title: Text(_plant!.commonName ?? _plant!.scientificName),
      ),
      body: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // Placeholder for image, in a real app this would come from the Media API
            Container(
              height: 250,
              color: Theme.of(context).colorScheme.surfaceContainerHighest,
              child: const Center(child: Icon(Icons.image, size: 50)),
            ),
            Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    _plant!.scientificName,
                    style: Theme.of(context).textTheme.titleLarge?.copyWith(
                      fontStyle: FontStyle.italic,
                      color: Theme.of(context).colorScheme.secondary,
                    ),
                  ),
                  if (_plant!.family != null) ...[
                    const SizedBox(height: 8),
                    Text(
                      'Familie: ${_plant!.family}',
                      style: Theme.of(context).textTheme.titleMedium,
                    ),
                  ],
                  const SizedBox(height: 16),
                  Text(
                    'Beschreibung',
                    style: Theme.of(context).textTheme.titleMedium,
                  ),
                  const SizedBox(height: 8),
                  Text(
                    _plant!.description ?? 'Keine Beschreibung verfügbar.',
                    style: Theme.of(context).textTheme.bodyLarge,
                  ),
                  const SizedBox(height: 32),
                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton.icon(
                      icon: const Icon(Icons.school),
                      label: const Padding(
                        padding: EdgeInsets.symmetric(vertical: 16.0),
                        child: Text('Lerneinheit Starten'),
                      ),
                      onPressed: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (_) => LearningFlowScreen(
                              plantId: widget.plantId, 
                              api: widget.api,
                              progressService: widget.progressService,
                            ),
                          ),
                        );
                      },
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
