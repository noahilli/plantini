import 'package:flutter/material.dart';
import 'package:openapi/openapi.dart';
import '../../core/theme/app_colors.dart';
import '../../storage/progress_service.dart';
import '../components/plant_art_widget.dart';
import '../quiz/quiz_screen.dart';

class PlantProfileScreen extends StatefulWidget {
  final String plantId;
  final Openapi api;
  final ProgressService? progressService;

  const PlantProfileScreen({
    super.key,
    required this.plantId,
    required this.api,
    this.progressService,
  });

  @override
  State<PlantProfileScreen> createState() => _PlantProfileScreenState();
}

class _PlantProfileScreenState extends State<PlantProfileScreen> {
  Plant? _plant;
  bool _isLoading = true;
  bool _isFavorite = false;

  @override
  void initState() {
    super.initState();
    _fetchPlant();
  }

  Future<void> _fetchPlant() async {
    setState(() {
      _isLoading = true;
    });

    try {
      final res = await widget.api.getDefaultApi().getPlant(id: widget.plantId);
      setState(() {
        _plant = res.data;
        _isLoading = false;
      });
    } catch (e) {
      // Fallback if plant not found
      setState(() {
        _plant = Plant((b) => b
          ..id = widget.plantId
          ..commonName = 'Waldmeister'
          ..scientificName = 'Galium odoratum'
          ..family = 'Rubiaceae'
          ..description = 'Sechs bis acht schmale Blätter stehen sternförmig um den vierkantigen Stängel. Weiß blühend im Laubwald.');
        _isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return const Scaffold(
        body: Center(child: CircularProgressIndicator()),
      );
    }

    final plant = _plant!;
    final commonName = plant.commonName ?? plant.scientificName;
    final sciName = plant.scientificName;
    final family = plant.family ?? 'Botanik';

    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new, size: 18),
          onPressed: () => Navigator.pop(context),
        ),
        title: const Text('Pflanzenwissen'),
        actions: [
          IconButton(
            icon: Icon(
              _isFavorite ? Icons.star_rounded : Icons.star_border_rounded,
              color: _isFavorite ? AppColors.sun : AppColors.forest,
            ),
            onPressed: () => setState(() => _isFavorite = !_isFavorite),
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 10),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // Species Hero Art / Photo
            Stack(
              children: [
                const PlantArtWidget(
                  height: 250,
                  width: double.infinity,
                ),
                Positioned(
                  left: 14,
                  bottom: 13,
                  child: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                    decoration: BoxDecoration(
                      color: Colors.white.withOpacity(0.92),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: const Text(
                      'Bild 1 von 3 · Blüte',
                      style: TextStyle(
                        fontSize: 10,
                        fontWeight: FontWeight.w900,
                        color: AppColors.forest,
                      ),
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 14),

            // Header: Common Name & Latin Name & Learned Badge
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'ART ${widget.plantId} · $family',
                      style: const TextStyle(
                        fontSize: 11,
                        fontWeight: FontWeight.w900,
                        letterSpacing: 1.1,
                        color: AppColors.sage,
                      ),
                    ),
                    const SizedBox(height: 3),
                    Text(
                      commonName,
                      style: const TextStyle(
                        fontSize: 26,
                        fontWeight: FontWeight.w900,
                        letterSpacing: -0.7,
                        color: AppColors.ink,
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      sciName,
                      style: const TextStyle(
                        fontFamily: 'serif',
                        fontStyle: FontStyle.italic,
                        fontSize: 15,
                        color: AppColors.sage,
                      ),
                    ),
                  ],
                ),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                  decoration: BoxDecoration(
                    color: AppColors.mint,
                    borderRadius: BorderRadius.circular(999),
                  ),
                  child: const Row(
                    children: [
                      Icon(Icons.check_rounded, size: 14, color: AppColors.forest),
                      SizedBox(width: 4),
                      Text(
                        'gelernt',
                        style: TextStyle(
                          fontSize: 11,
                          fontWeight: FontWeight.w900,
                          color: AppColors.forest,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
            const SizedBox(height: 14),

            // Trait Grid (3 Cards)
            Row(
              children: [
                _buildTraitCard(Icons.eco_rounded, 'Blattquirle'),
                const SizedBox(width: 8),
                _buildTraitCard(Icons.star_rounded, 'weiße Blüte'),
                const SizedBox(width: 8),
                _buildTraitCard(Icons.explore_rounded, 'Laubwald'),
              ],
            ),
            const SizedBox(height: 12),

            // Info Card: Description
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(20),
                border: Border.all(color: const Color(0x182F5D50)),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'So erkennst du die Art',
                    style: TextStyle(
                      fontSize: 13,
                      fontWeight: FontWeight.w900,
                      color: AppColors.ink,
                    ),
                  ),
                  const SizedBox(height: 6),
                  Text(
                    plant.description ?? 'Charakteristische Merkmale für Feld- und Naturbeobachtungen.',
                    style: const TextStyle(
                      fontSize: 12,
                      color: AppColors.muted,
                      height: 1.45,
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 10),

            // Warning Box: Verwechslung
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: AppColors.warningBg,
                borderRadius: BorderRadius.circular(15),
                border: Border.all(color: AppColors.warningBorder),
              ),
              child: const Row(
                children: [
                  Text('⚠', style: TextStyle(fontSize: 16)),
                  SizedBox(width: 8),
                  Expanded(
                    child: Text.rich(
                      TextSpan(
                        children: [
                          TextSpan(
                            text: 'Verwechslung: ',
                            style: TextStyle(fontWeight: FontWeight.bold),
                          ),
                          TextSpan(
                            text: 'Vor der Feldaufgabe Merkmale mit ähnlichen Arten vergleichen.',
                          ),
                        ],
                      ),
                      style: TextStyle(fontSize: 11, color: AppColors.bark, height: 1.35),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 18),

            // Action Button: Im Quiz festigen
            ElevatedButton(
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (_) => QuizScreen(
                      api: widget.api,
                      progressService: widget.progressService,
                    ),
                  ),
                );
              },
              style: ElevatedButton.styleFrom(
                padding: const EdgeInsets.symmetric(vertical: 14),
              ),
              child: const Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text('Im Quiz festigen', style: TextStyle(fontWeight: FontWeight.w900, fontSize: 14)),
                  SizedBox(width: 6),
                  Icon(Icons.arrow_forward_rounded, size: 18),
                ],
              ),
            ),
            const SizedBox(height: 20),
          ],
        ),
      ),
    );
  }

  Widget _buildTraitCard(IconData icon, String label) {
    return Expanded(
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 8),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: const Color(0x182F5D50)),
        ),
        child: Column(
          children: [
            Icon(icon, size: 22, color: AppColors.forest),
            const SizedBox(height: 5),
            Text(
              label,
              textAlign: TextAlign.center,
              style: const TextStyle(
                fontSize: 10,
                fontWeight: FontWeight.w800,
                color: AppColors.forest,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
