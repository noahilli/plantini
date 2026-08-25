import 'package:flutter/material.dart';
import 'package:openapi/openapi.dart';
import '../level/level_list_screen.dart';
import '../../storage/progress_service.dart';

class EcosystemListScreen extends StatelessWidget {
  final List<Ecosystem> ecosystems;
  final Openapi api;
  final ProgressService? progressService;

  const EcosystemListScreen({super.key, required this.ecosystems, required this.api, this.progressService});

  @override
  Widget build(BuildContext context) {
    return ListView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      itemCount: ecosystems.length,
      itemBuilder: (context, index) {
        final ecosystem = ecosystems[index];
        return Card(
          margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
          child: InkWell(
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (_) => LevelListScreen(
                    ecosystem: ecosystem, 
                    api: api,
                    progressService: progressService,
                  ),
                ),
              );
            },
            child: Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    ecosystem.name,
                    style: Theme.of(context).textTheme.titleLarge,
                  ),
                  const SizedBox(height: 8),
                  Text(
                    ecosystem.description ?? 'Keine Beschreibung verfügbar.',
                    style: Theme.of(context).textTheme.bodyMedium,
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }
}
