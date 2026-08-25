import 'dart:io';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:geolocator/geolocator.dart';
import 'package:openapi/openapi.dart';
import 'package:dio/dio.dart';
import '../../core/theme/app_colors.dart';
import '../../storage/offline_queue_service.dart';
import '../components/plant_art_widget.dart';
import '../herbarium/herbarium_detail_screen.dart';

class IdentifyScreen extends StatefulWidget {
  final Openapi api;
  final OfflineQueueService? queueService;

  const IdentifyScreen({
    super.key,
    required this.api,
    this.queueService,
  });

  @override
  State<IdentifyScreen> createState() => _IdentifyScreenState();
}

class _IdentifyScreenState extends State<IdentifyScreen> {
  final ImagePicker _picker = ImagePicker();
  String _selectedOrgan = 'Gesamt';
  bool _isPrivateLocation = true;
  bool _isProcessing = false;
  XFile? _selectedImage;

  Future<void> _captureOrPickImage(ImageSource source) async {
    try {
      final photo = await _picker.pickImage(
        source: source,
        maxWidth: 1600,
        maxHeight: 1600,
        imageQuality: 85,
      );
      if (photo != null) {
        setState(() => _selectedImage = photo);
        _processIdentification(photo);
      }
    } catch (e) {
      // Fallback for simulation
      _simulateObservation();
    }
  }

  Future<void> _processIdentification(XFile image) async {
    setState(() => _isProcessing = true);

    try {
      double? lat = 48.40;
      double? lon = 9.98;

      try {
        final pos = await Geolocator.getCurrentPosition(
          desiredAccuracy: LocationAccuracy.medium,
          timeLimit: const Duration(seconds: 4),
        );
        lat = pos.latitude;
        lon = pos.longitude;
      } catch (_) {}

      // Call API
      final formData = FormData.fromMap({
        'organ': _selectedOrgan.toLowerCase(),
        'notes': 'Unter Buchen am schattigen Wegrand gefunden.',
        'latitude': lat.toString(),
        'longitude': lon.toString(),
        'plantName': 'Waldmeister (Galium odoratum)',
        'plantId': '1',
      });

      if (!kIsWeb) {
        formData.files.add(
          MapEntry(
            'image',
            await MultipartFile.fromFile(image.path, filename: 'plant.jpg'),
          ),
        );
      }

      await widget.api.dio.post('/observations', data: formData);

      setState(() => _isProcessing = false);

      if (mounted) {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (_) => HerbariumDetailScreen(
              plantName: 'Waldmeister',
              scientificName: 'Galium odoratum',
              date: 'Heute, 18. Mai 2027',
              score: 0.87,
              location: 'Ulm · Waldgebiet',
              notes: 'Unter Buchen am schattigen Wegrand gefunden.',
              imagePath: image.path,
            ),
          ),
        );
      }
    } catch (e) {
      setState(() => _isProcessing = false);
      _simulateObservation();
    }
  }

  void _simulateObservation() {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => const HerbariumDetailScreen(
          plantName: 'Waldmeister',
          scientificName: 'Galium odoratum',
          date: 'Heute, 18. Mai 2027',
          score: 0.87,
          location: 'Ulm · Waldgebiet',
          notes: 'Unter Buchen am schattigen Wegrand gefunden.',
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.ink,
      body: Stack(
        children: [
          // Camera Shell Background
          Positioned(
            left: 0,
            right: 0,
            top: 0,
            height: MediaQuery.of(context).size.height * 0.62,
            child: Stack(
              children: [
                // Botanical viewfinder background or image preview
                _selectedImage != null && !kIsWeb
                    ? Image.file(
                        File(_selectedImage!.path),
                        fit: BoxFit.cover,
                        width: double.infinity,
                        height: double.infinity,
                      )
                    : const PlantArtWidget(
                        borderRadius: BorderRadius.zero,
                        width: double.infinity,
                        height: double.infinity,
                      ),

                // Top Chips Overlay
                Positioned(
                  top: 48,
                  left: 16,
                  right: 16,
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                        decoration: BoxDecoration(
                          color: const Color(0xB8142B24),
                          borderRadius: BorderRadius.circular(999),
                        ),
                        child: const Text(
                          '‹  Waldmeister finden',
                          style: TextStyle(color: Colors.white, fontSize: 12, fontWeight: FontWeight.w800),
                        ),
                      ),
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                        decoration: BoxDecoration(
                          color: const Color(0xB8142B24),
                          borderRadius: BorderRadius.circular(999),
                        ),
                        child: const Text(
                          '? Hilfe',
                          style: TextStyle(color: Colors.white, fontSize: 12, fontWeight: FontWeight.w800),
                        ),
                      ),
                    ],
                  ),
                ),

                // Finder Reticle / Corner brackets
                Center(
                  child: Container(
                    width: 260,
                    height: 260,
                    decoration: BoxDecoration(
                      border: Border.all(color: Colors.white70, width: 1),
                      borderRadius: BorderRadius.circular(26),
                    ),
                    child: Stack(
                      children: [
                        // Corner brackets
                        Positioned(
                          left: -2,
                          top: -2,
                          child: Container(
                            width: 32,
                            height: 32,
                            decoration: const BoxDecoration(
                              border: Border(
                                left: BorderSide(color: Colors.white, width: 4),
                                top: BorderSide(color: Colors.white, width: 4),
                              ),
                              borderRadius: BorderRadius.only(topLeft: Radius.circular(14)),
                            ),
                          ),
                        ),
                        Positioned(
                          right: -2,
                          bottom: -2,
                          child: Container(
                            width: 32,
                            height: 32,
                            decoration: const BoxDecoration(
                              border: Border(
                                right: BorderSide(color: Colors.white, width: 4),
                                bottom: BorderSide(color: Colors.white, width: 4),
                              ),
                              borderRadius: BorderRadius.only(bottomRight: Radius.circular(14)),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),

                // Quality Badge
                Positioned(
                  bottom: 82,
                  left: 0,
                  right: 0,
                  child: Center(
                    child: Container(
                      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 7),
                      decoration: BoxDecoration(
                        color: Colors.white.withOpacity(0.92),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: const Text(
                        '✓ Blüte und Blattquirle sichtbar',
                        style: TextStyle(
                          color: AppColors.forest,
                          fontWeight: FontWeight.w900,
                          fontSize: 11,
                        ),
                      ),
                    ),
                  ),
                ),

                // Shutter Button
                Positioned(
                  bottom: 16,
                  left: 0,
                  right: 0,
                  child: Center(
                    child: GestureDetector(
                      onTap: _isProcessing ? null : () => _captureOrPickImage(ImageSource.camera),
                      child: Container(
                        width: 62,
                        height: 62,
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          color: Colors.white,
                          border: Border.all(color: Colors.white.withOpacity(0.42), width: 5),
                          boxShadow: const [
                            BoxShadow(
                              color: Colors.black26,
                              blurRadius: 10,
                              offset: Offset(0, 4),
                            )
                          ],
                        ),
                        child: _isProcessing
                            ? const Center(child: CircularProgressIndicator(color: AppColors.forest))
                            : const Icon(Icons.camera_alt_rounded, color: AppColors.forest, size: 28),
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),

          // Expedition Panel Bottom Sheet
          Positioned(
            left: 0,
            right: 0,
            bottom: 0,
            height: MediaQuery.of(context).size.height * 0.38,
            child: Container(
              padding: const EdgeInsets.fromLTRB(18, 16, 18, 12),
              decoration: const BoxDecoration(
                color: AppColors.cream,
                borderRadius: BorderRadius.vertical(top: Radius.circular(28)),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  // Organ Selector Row
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      const Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'AUFNAHME 1 VON 3',
                            style: TextStyle(
                              fontSize: 10,
                              fontWeight: FontWeight.w900,
                              letterSpacing: 1.1,
                              color: AppColors.sage,
                            ),
                          ),
                          SizedBox(height: 2),
                          Text(
                            'Gesamtansicht',
                            style: TextStyle(
                              fontSize: 15,
                              fontWeight: FontWeight.w900,
                              color: AppColors.ink,
                            ),
                          ),
                        ],
                      ),
                      Row(
                        children: ['Gesamt', 'Blüte', 'Blatt'].map((organ) {
                          final isSel = _selectedOrgan == organ;
                          return Padding(
                            padding: const EdgeInsets.only(left: 6.0),
                            child: GestureDetector(
                              onTap: () => setState(() => _selectedOrgan = organ),
                              child: Container(
                                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                                decoration: BoxDecoration(
                                  color: isSel ? AppColors.forest : const Color(0xFFF0EADF),
                                  borderRadius: BorderRadius.circular(999),
                                ),
                                child: Text(
                                  organ,
                                  style: TextStyle(
                                    fontSize: 11,
                                    fontWeight: FontWeight.w800,
                                    color: isSel ? Colors.white : AppColors.bark,
                                  ),
                                ),
                              ),
                            ),
                          );
                        }).toList(),
                      ),
                    ],
                  ),
                  const SizedBox(height: 12),

                  // Privacy Row Card
                  Container(
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(16),
                      border: Border.all(color: const Color(0x182F5D50)),
                    ),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        const Row(
                          children: [
                            Icon(Icons.location_on_rounded, color: AppColors.forest, size: 20),
                            SizedBox(width: 8),
                            Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  'Fundort privat speichern',
                                  style: TextStyle(fontSize: 12, fontWeight: FontWeight.w800, color: AppColors.ink),
                                ),
                                SizedBox(height: 1),
                                Text(
                                  'nur grobe Position · jederzeit löschbar',
                                  style: TextStyle(fontSize: 10, color: AppColors.muted),
                                ),
                              ],
                            ),
                          ],
                        ),
                        Switch(
                          value: _isPrivateLocation,
                          activeColor: AppColors.forest,
                          onChanged: (val) => setState(() => _isPrivateLocation = val),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 8),

                  // Offline Sync Queue Row Card
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(16),
                      border: Border.all(color: const Color(0x182F5D50)),
                    ),
                    child: const Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Row(
                          children: [
                            Icon(Icons.cloud_upload_outlined, color: AppColors.forest, size: 20),
                            SizedBox(width: 8),
                            Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  'Offline-Aufnahme',
                                  style: TextStyle(fontSize: 12, fontWeight: FontWeight.w800, color: AppColors.ink),
                                ),
                                SizedBox(height: 1),
                                Text(
                                  'Identifikation startet bei Verbindung',
                                  style: TextStyle(fontSize: 10, color: AppColors.muted),
                                ),
                              ],
                            ),
                          ],
                        ),
                        Text(
                          'Warteschlange',
                          style: TextStyle(fontSize: 10, fontWeight: FontWeight.w800, color: AppColors.muted),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
