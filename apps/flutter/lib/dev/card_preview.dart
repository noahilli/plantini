// Design workbench using public published content from the local API.
// Not imported into the app router; no authentication or progress mutation.
import 'package:flutter/material.dart';
import 'package:dio/dio.dart';

import '../core/theme/app_theme.dart';
import '../features/catalog/domain/plant_model.dart';
import '../features/catalog/infrastructure/catalog_dto.dart';
import '../features/catalog/presentation/widgets/plant_index_card.dart';

void main() => runApp(
  MaterialApp(
    initialRoute: '/',
    theme: AppTheme.lightTheme,
    home: const _Preview(),
  ),
);

class _Preview extends StatefulWidget {
  const _Preview();
  @override
  State<_Preview> createState() => _PreviewState();
}

class _PreviewState extends State<_Preview> {
  late final Future<Plant> _plant = _load();
  Future<Plant> _load() async {
    const api = 'http://127.0.0.1:1338';
    final id =
        Uri.base.queryParameters['plant'] ??
        'e86229bc-320e-41ff-8741-033e3a118cd4';
    final client = Dio();
    late final Map<String, dynamic> data;
    try {
      final response = await client
          .get<Map<String, dynamic>>('$api/api/v1/plants/$id')
          .timeout(const Duration(seconds: 20));
      data = response.data!;
    } finally {
      client.close();
    }
    for (final m in (data['media'] as List? ?? [])) {
      m['url'] = Uri.parse(api).resolve(m['url'] as String).toString();
    }
    if (Uri.base.queryParameters['photos'] == 'none') data['media'] = [];
    return CatalogDto.plantFromJson(data).valueOrNull!;
  }

  @override
  Widget build(BuildContext context) => Scaffold(
    appBar: AppBar(
      title: const Text('Kartenatelier · veröffentlichte Inhalte'),
    ),
    body: MediaQuery(
      data: MediaQuery.of(context).copyWith(
        textScaler: TextScaler.linear(
          double.tryParse(Uri.base.queryParameters['scale'] ?? '') ?? 1,
        ),
      ),
      child: FutureBuilder<Plant>(
        future: _plant,
        builder: (context, snapshot) {
          if (snapshot.hasError) {
            return Center(
              child: Text('Vorschau nicht verfügbar: ${snapshot.error}'),
            );
          }
          if (!snapshot.hasData) {
            return const Center(child: CircularProgressIndicator());
          }
          return ListView(
            padding: const EdgeInsets.all(20),
            children: [PlantIndexCard(plant: snapshot.data!)],
          );
        },
      ),
    ),
  );
}
