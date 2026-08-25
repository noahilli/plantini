import 'package:flutter/material.dart';
import 'package:openapi/openapi.dart';
import '../../core/theme/app_colors.dart';
import '../../storage/offline_queue_service.dart';
import '../../storage/isar_collection.dart';
import '../components/plant_art_widget.dart';
import 'herbarium_detail_screen.dart';

class HerbariumScreen extends StatefulWidget {
  final Openapi? api;
  final OfflineQueueService? queueService;

  const HerbariumScreen({
    super.key,
    this.api,
    this.queueService,
  });

  @override
  State<HerbariumScreen> createState() => _HerbariumScreenState();
}

class _HerbariumScreenState extends State<HerbariumScreen> {
  List<OfflineObservation> _localObservations = [];
  List<Observation> _remoteObservations = [];
  bool _isLoading = true;
  String _filter = 'Alle';

  @override
  void initState() {
    super.initState();
    _loadData();
    widget.queueService?.addListener(_loadData);
  }

  @override
  void dispose() {
    widget.queueService?.removeListener(_loadData);
    super.dispose();
  }

  Future<void> _loadData() async {
    setState(() => _isLoading = true);

    try {
      if (widget.queueService != null) {
        _localObservations = await widget.queueService!.getAllObservations();
      }
    } catch (_) {}

    try {
      if (widget.api != null) {
        final res = await widget.api!.getDefaultApi().listObservations();
        _remoteObservations = res.data?.toList() ?? [];
      }
    } catch (_) {}

    setState(() => _isLoading = false);
  }

  @override
  Widget build(BuildContext context) {
    final totalCount = _localObservations.length + _remoteObservations.length;
    final displayCount = totalCount > 0 ? totalCount : 18;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Mein Herbarium'),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh_rounded),
            onPressed: _loadData,
          )
        ],
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : RefreshIndicator(
              onRefresh: _loadData,
              child: SingleChildScrollView(
                physics: const AlwaysScrollableScrollPhysics(),
                padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 12),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    // Artenpass Summary Card
                    Container(
                      padding: const EdgeInsets.all(18),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(20),
                        border: Border.all(color: const Color(0x182F5D50)),
                      ),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              const Text(
                                'ARTENPASS & SAMMLUNG',
                                style: TextStyle(
                                  fontSize: 10,
                                  fontWeight: FontWeight.w900,
                                  letterSpacing: 1.1,
                                  color: AppColors.sage,
                                ),
                              ),
                              const SizedBox(height: 4),
                              Text(
                                '$displayCount von 90 Funden',
                                style: const TextStyle(
                                  fontSize: 22,
                                  fontWeight: FontWeight.w900,
                                  color: AppColors.ink,
                                ),
                              ),
                            ],
                          ),
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                            decoration: BoxDecoration(
                              color: const Color(0xFFFFF4D2),
                              borderRadius: BorderRadius.circular(12),
                            ),
                            child: const Text(
                              'Level 1',
                              style: TextStyle(
                                fontSize: 11,
                                fontWeight: FontWeight.w900,
                                color: Color(0xFF7D5A19),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 16),

                    // Filter Chips
                    Row(
                      children: ['Alle', 'Wald', 'Wiese', 'Gewässer'].map((category) {
                        final isSel = _filter == category;
                        return Padding(
                          padding: const EdgeInsets.only(right: 8.0),
                          child: ChoiceChip(
                            label: Text(category),
                            selected: isSel,
                            selectedColor: AppColors.forest,
                            backgroundColor: Colors.white,
                            labelStyle: TextStyle(
                              color: isSel ? Colors.white : AppColors.ink,
                              fontWeight: FontWeight.w800,
                              fontSize: 11,
                            ),
                            onSelected: (_) => setState(() => _filter = category),
                          ),
                        );
                      }).toList(),
                    ),
                    const SizedBox(height: 14),

                    // Featured Primary Specimen Card (Waldmeister)
                    _buildFeaturedSpecimenCard(),
                    const SizedBox(height: 14),

                    // Additional Specimen List
                    if (_remoteObservations.isNotEmpty) ...[
                      const Text(
                        'Gespeicherte Naturfunde',
                        style: TextStyle(fontSize: 14, fontWeight: FontWeight.w900, color: AppColors.ink),
                      ),
                      const SizedBox(height: 8),
                      ..._remoteObservations.map((obs) => _buildRemoteObservationTile(obs)),
                    ],

                    if (_localObservations.isNotEmpty) ...[
                      const SizedBox(height: 14),
                      const Text(
                        'Lokale Warteschlange',
                        style: TextStyle(fontSize: 14, fontWeight: FontWeight.w900, color: AppColors.ink),
                      ),
                      const SizedBox(height: 8),
                      ..._localObservations.map((obs) => _buildLocalObservationTile(obs)),
                    ],
                    const SizedBox(height: 20),
                  ],
                ),
              ),
            ),
    );
  }

  Widget _buildFeaturedSpecimenCard() {
    return GestureDetector(
      onTap: () {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (_) => const HerbariumDetailScreen(
              plantName: 'Waldmeister',
              scientificName: 'Galium odoratum',
              date: '18. Mai 2027',
              score: 0.87,
              location: 'Ulm · Waldgebiet',
              notes: 'Unter Buchen am schattigen Wegrand gefunden.',
            ),
          ),
        );
      },
      child: Container(
        padding: const EdgeInsets.all(14),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(24),
          border: Border.all(color: const Color(0x182F5D50)),
          boxShadow: const [
            BoxShadow(
              color: Color(0x0E26332F),
              blurRadius: 18,
              offset: Offset(0, 8),
            )
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Stack(
              children: [
                const PlantArtWidget(
                  height: 200,
                  width: double.infinity,
                ),
                Positioned(
                  right: 12,
                  top: 12,
                  child: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                    decoration: BoxDecoration(
                      color: AppColors.forest.withOpacity(0.92),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: const Text(
                      '✓ erfolgreich bestimmt',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 10,
                        fontWeight: FontWeight.w900,
                      ),
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Waldmeister',
                      style: TextStyle(fontSize: 18, fontWeight: FontWeight.w900, color: AppColors.ink),
                    ),
                    SizedBox(height: 2),
                    Text(
                      'Galium odoratum',
                      style: TextStyle(
                        fontFamily: 'serif',
                        fontStyle: FontStyle.italic,
                        fontSize: 13,
                        color: AppColors.sage,
                      ),
                    ),
                  ],
                ),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                  decoration: BoxDecoration(
                    color: AppColors.mint,
                    borderRadius: BorderRadius.circular(999),
                  ),
                  child: const Text(
                    '18. Mai 2027',
                    style: TextStyle(fontSize: 10, fontWeight: FontWeight.w800, color: AppColors.forest),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildRemoteObservationTile(Observation obs) {
    return Card(
      margin: const EdgeInsets.only(bottom: 10),
      child: ListTile(
        leading: Container(
          width: 44,
          height: 44,
          decoration: BoxDecoration(
            color: AppColors.mint,
            borderRadius: BorderRadius.circular(12),
          ),
          child: const Icon(Icons.local_florist, color: AppColors.forest),
        ),
        title: Text(obs.plantName, style: const TextStyle(fontWeight: FontWeight.w900, fontSize: 14)),
        subtitle: Text(
          'Score: ${((obs.identificationScore ?? 0.85) * 100).toInt()}% · ${(obs.notes?.isNotEmpty ?? false) ? obs.notes! : "Feldbeobachtung"}',
          style: const TextStyle(fontSize: 11, color: AppColors.muted),
        ),
        trailing: const Icon(Icons.arrow_forward_ios, size: 14, color: AppColors.muted),
        onTap: () {
          final noteText = (obs.notes?.isNotEmpty ?? false) ? obs.notes! : 'Unter freiem Himmel im Biotop entdeckt.';
          final dateText = obs.date.toIso8601String().split('T')[0];
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (_) => HerbariumDetailScreen(
                plantName: obs.plantName.split(' (')[0],
                scientificName: obs.plantName.contains('(') ? obs.plantName.split('(')[1].replaceAll(')', '') : 'Botanische Art',
                date: dateText,
                score: obs.identificationScore ?? 0.85,
                location: obs.location != null ? 'GPS: ${obs.location!.lat}, ${obs.location!.lon}' : 'Grobe Position',
                notes: noteText,
              ),
            ),
          );
        },
      ),
    );
  }

  Widget _buildLocalObservationTile(OfflineObservation obs) {
    return Card(
      margin: const EdgeInsets.only(bottom: 10),
      child: ListTile(
        leading: const Icon(Icons.cloud_upload_outlined, color: AppColors.forest),
        title: Text(obs.organ.toUpperCase(), style: const TextStyle(fontWeight: FontWeight.w900, fontSize: 13)),
        subtitle: Text(
          'Warteschlange · ${obs.notes ?? "Lokale Aufnahme"}',
          style: const TextStyle(fontSize: 11, color: AppColors.muted),
        ),
        trailing: const Icon(Icons.chevron_right, color: AppColors.muted),
      ),
    );
  }
}
