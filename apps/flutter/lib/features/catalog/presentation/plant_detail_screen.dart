import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../domain/plant_model.dart';
import 'widgets/plant_index_card.dart';

/// Shared editorial card, also used before each quiz.
class PlantDetailScreen extends StatelessWidget {
  const PlantDetailScreen({super.key, required this.plant});
  final Plant plant;

  @override
  Widget build(BuildContext context) {
    final title = plant.commonName.isEmpty
        ? plant.scientificName
        : plant.commonName;
    return Scaffold(
      appBar: AppBar(title: const Text('Pflanzenkartei')),
      body: ListView(
        padding: const EdgeInsets.all(20),
        children: [
          PlantIndexCard(plant: plant),
          const SizedBox(height: 24),
          Center(
            child: FilledButton.icon(
              onPressed: () => context.go(
                Uri(
                  path: '/field',
                  queryParameters: {
                    'expectedPlantId': plant.id,
                    'expectedPlantName': title,
                  },
                ).toString(),
              ),
              icon: const Icon(Icons.explore_outlined),
              label: Text('$title in der Natur bestimmen'),
            ),
          ),
        ],
      ),
    );
  }
}
