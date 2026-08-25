import 'dart:io';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:geolocator/geolocator.dart';
import 'package:flutter/foundation.dart' show kIsWeb;
import '../../storage/offline_queue_service.dart';

class IdentifyScreen extends StatefulWidget {
  final OfflineQueueService? queueService;
  const IdentifyScreen({super.key, this.queueService});

  @override
  State<IdentifyScreen> createState() => _IdentifyScreenState();
}

class _IdentifyScreenState extends State<IdentifyScreen> {
  final ImagePicker _picker = ImagePicker();
  XFile? _imageFile;
  String _selectedOrgan = 'auto';
  
  bool _cameraGranted = false;
  bool _locationGranted = false;
  Position? _currentPosition;
  
  bool _isIdentifying = false;
  Map<String, dynamic>? _mockResult;

  final List<String> _organs = ['auto', 'leaf', 'flower', 'fruit', 'bark', 'habit'];

  @override
  void initState() {
    super.initState();
    _checkPermissions();
  }

  Future<void> _checkPermissions() async {
    if (kIsWeb) {
      // On web, permissions are handled natively by the browser on request,
      // but we can set them to true to simplify the UI flow for now.
      setState(() {
        _cameraGranted = true;
        _locationGranted = true;
      });
      return;
    }
    
    final cameraStatus = await Permission.camera.status;
    bool locationService = await Geolocator.isLocationServiceEnabled();
    LocationPermission locationPermission = await Geolocator.checkPermission();

    setState(() {
      _cameraGranted = cameraStatus.isGranted;
      _locationGranted = locationService && (locationPermission == LocationPermission.always || locationPermission == LocationPermission.whileInUse);
    });
  }

  Future<void> _requestCameraPermission() async {
    if (kIsWeb) return;
    final status = await Permission.camera.request();
    setState(() {
      _cameraGranted = status.isGranted;
    });
  }

  Future<void> _requestLocationPermission() async {
    if (kIsWeb) return;
    bool serviceEnabled = await Geolocator.isLocationServiceEnabled();
    if (!serviceEnabled) {
      return;
    }

    LocationPermission permission = await Geolocator.checkPermission();
    if (permission == LocationPermission.denied) {
      permission = await Geolocator.requestPermission();
    }
    
    setState(() {
      _locationGranted = (permission == LocationPermission.whileInUse || permission == LocationPermission.always);
    });

    if (_locationGranted) {
      _currentPosition = await Geolocator.getCurrentPosition();
    }
  }

  Future<void> _pickImage(ImageSource source) async {
    try {
      final pickedFile = await _picker.pickImage(source: source);
      if (pickedFile != null) {
        setState(() {
          _imageFile = pickedFile;
          _mockResult = null; // reset result
        });
        if (_locationGranted && _currentPosition == null && !kIsWeb) {
           _currentPosition = await Geolocator.getCurrentPosition();
        }
      }
    } catch (e) {
      debugPrint("Error picking image: $e");
    }
  }

  Future<void> _identifyPlant() async {
    if (_imageFile == null) return;
    
    setState(() {
      _isIdentifying = true;
      _mockResult = null;
    });

    // Simulate API call delay
    await Future.delayed(const Duration(seconds: 2));

    setState(() {
      _isIdentifying = false;
      _mockResult = {
        'results': [
          {
            'scientificName': 'Quercus robur',
            'commonName': 'Stieleiche',
            'score': 0.95,
          },
          {
            'scientificName': 'Fagus sylvatica',
            'commonName': 'Rotbuche',
            'score': 0.12,
          }
        ]
      };
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Expedition: Bestimmung'),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            _buildPermissionWarnings(),
            const SizedBox(height: 16),
            _buildImagePicker(),
            const SizedBox(height: 24),
            if (_imageFile != null) ...[
              _buildOrganSelector(),
              const SizedBox(height: 24),
              ElevatedButton.icon(
                onPressed: _isIdentifying ? null : _identifyPlant,
                icon: _isIdentifying 
                    ? const SizedBox(width: 20, height: 20, child: CircularProgressIndicator(strokeWidth: 2))
                    : const Icon(Icons.search),
                label: const Padding(
                  padding: EdgeInsets.symmetric(vertical: 16.0),
                  child: Text('Identifizieren'),
                ),
              ),
              const SizedBox(height: 32),
              if (_mockResult != null) _buildResults(),
            ],
          ],
        ),
      ),
    );
  }

  Widget _buildPermissionWarnings() {
    if (_cameraGranted && _locationGranted) {
      return const SizedBox.shrink();
    }
    
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.errorContainer,
        borderRadius: BorderRadius.circular(8),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(Icons.warning_amber_rounded, color: Theme.of(context).colorScheme.onErrorContainer),
              const SizedBox(width: 8),
              Text(
                'Eingeschränkte Funktion',
                style: Theme.of(context).textTheme.titleMedium?.copyWith(
                  color: Theme.of(context).colorScheme.onErrorContainer,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          if (!_cameraGranted) ...[
            Text('Kamerazugriff wird für direkte Aufnahmen benötigt.', style: TextStyle(color: Theme.of(context).colorScheme.onErrorContainer)),
            TextButton(
              onPressed: _requestCameraPermission,
              child: const Text('Kamera erlauben'),
            ),
          ],
          if (!_locationGranted) ...[
            Text('Standort wird benötigt, um die Ergebnisse zu verbessern.', style: TextStyle(color: Theme.of(context).colorScheme.onErrorContainer)),
            TextButton(
              onPressed: _requestLocationPermission,
              child: const Text('Standort erlauben'),
            ),
          ]
        ],
      ),
    );
  }

  Widget _buildImagePicker() {
    return Column(
      children: [
        if (_imageFile != null)
          ClipRRect(
            borderRadius: BorderRadius.circular(12),
            child: kIsWeb 
                ? Image.network(_imageFile!.path, height: 250, width: double.infinity, fit: BoxFit.cover)
                : Image.file(File(_imageFile!.path), height: 250, width: double.infinity, fit: BoxFit.cover),
          )
        else
          Container(
            height: 250,
            width: double.infinity,
            decoration: BoxDecoration(
              color: Theme.of(context).colorScheme.surfaceContainerHighest,
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: Theme.of(context).colorScheme.outline),
            ),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(Icons.add_a_photo, size: 64, color: Theme.of(context).colorScheme.onSurfaceVariant),
                const SizedBox(height: 16),
                Text('Pflanze fotografieren', style: Theme.of(context).textTheme.titleMedium),
              ],
            ),
          ),
        const SizedBox(height: 16),
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
          children: [
            ElevatedButton.icon(
              onPressed: _cameraGranted || kIsWeb ? () => _pickImage(ImageSource.camera) : null,
              icon: const Icon(Icons.camera_alt),
              label: const Text('Kamera'),
            ),
            ElevatedButton.icon(
              onPressed: () => _pickImage(ImageSource.gallery),
              icon: const Icon(Icons.photo_library),
              label: const Text('Galerie'),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildOrganSelector() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text('Welcher Teil ist zu sehen?', style: Theme.of(context).textTheme.titleMedium),
        const SizedBox(height: 8),
        Wrap(
          spacing: 8.0,
          children: _organs.map((organ) {
            return ChoiceChip(
              label: Text(organ.toUpperCase()),
              selected: _selectedOrgan == organ,
              onSelected: (selected) {
                if (selected) {
                  setState(() {
                    _selectedOrgan = organ;
                  });
                }
              },
            );
          }).toList(),
        ),
      ],
    );
  }

  Widget _buildResults() {
    final results = _mockResult!['results'] as List;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text('Ergebnisse', style: Theme.of(context).textTheme.titleLarge),
        const SizedBox(height: 8),
        ...results.map((r) {
          final score = r['score'] as double;
          final percentage = (score * 100).toStringAsFixed(1);
          return Card(
            child: ListTile(
              leading: CircularProgressIndicator(
                value: score,
                color: score > 0.8 ? Colors.green : score > 0.5 ? Colors.orange : Colors.red,
              ),
              title: Text('${r['commonName']} ($percentage%)'),
              subtitle: Text(r['scientificName'], style: const TextStyle(fontStyle: FontStyle.italic)),
              trailing: const Icon(Icons.chevron_right),
              onTap: () {
                // Could navigate to PlantProfileScreen here
              },
            ),
          );
        }),
        const SizedBox(height: 24),
        ElevatedButton.icon(
          onPressed: () {
             widget.queueService?.queueObservation(
               imagePath: _imageFile!.path,
               organ: _selectedOrgan,
               latitude: _currentPosition?.latitude,
               longitude: _currentPosition?.longitude,
               notes: 'Bestimmt als: ${results.first['scientificName']}',
             );
             ScaffoldMessenger.of(context).showSnackBar(
               const SnackBar(content: Text('Ins Herbarium gespeichert!'))
             );
             Navigator.pop(context);
          },
          icon: const Icon(Icons.save),
          label: const Text('Ins Herbarium aufnehmen'),
        ),
      ],
    );
  }
}
