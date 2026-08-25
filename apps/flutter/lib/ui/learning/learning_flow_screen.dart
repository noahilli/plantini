import 'package:flutter/material.dart';
import 'package:openapi/openapi.dart';
import '../quiz/quiz_screen.dart';
import '../../storage/progress_service.dart';

class LearningFlowScreen extends StatelessWidget {
  final String plantId;
  final Openapi api;
  final ProgressService? progressService;

  const LearningFlowScreen({super.key, required this.plantId, required this.api, this.progressService});

  @override
  Widget build(BuildContext context) {
    // Mock data for the learning unit
    final Map<String, String> learningData = {
      'title': 'Die Eiche erkennen',
      'shortText': 'Die Stieleiche hat eine tief gefurchte, graubraune Rinde. Ihre Blätter sind gelappt und die Eicheln sitzen an langen Stielen.',
      'mnemonic': 'Hat der Stiel eine Eichel, so ist es eine Stieleiche!',
      'imageUrl': 'https://via.placeholder.com/400x250.png?text=Eichenblatt',
    };

    return Scaffold(
      appBar: AppBar(
        title: Text(learningData['title']!),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Image.network(
              learningData['imageUrl']!,
              height: 250,
              fit: BoxFit.cover,
              errorBuilder: (context, error, stackTrace) {
                return Container(
                  height: 250,
                  color: Theme.of(context).colorScheme.surfaceContainerHighest,
                  child: const Center(child: Icon(Icons.broken_image, size: 50)),
                );
              },
            ),
            const SizedBox(height: 24),
            Text(
              'Lerneinheit',
              style: Theme.of(context).textTheme.headlineMedium,
            ),
            const SizedBox(height: 16),
            Text(
              learningData['shortText']!,
              style: Theme.of(context).textTheme.bodyLarge,
            ),
            const SizedBox(height: 24),
            Container(
              padding: const EdgeInsets.all(16.0),
              decoration: BoxDecoration(
                color: Theme.of(context).colorScheme.secondaryContainer,
                borderRadius: BorderRadius.circular(12),
                border: Border.all(
                  color: Theme.of(context).colorScheme.secondary,
                  width: 2,
                ),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Icon(Icons.lightbulb, color: Theme.of(context).colorScheme.secondary),
                      const SizedBox(width: 8),
                      Text(
                        'Merkhilfe',
                        style: Theme.of(context).textTheme.titleLarge?.copyWith(
                          color: Theme.of(context).colorScheme.onSecondaryContainer,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 8),
                  Text(
                    learningData['mnemonic']!,
                    style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                      fontWeight: FontWeight.bold,
                      color: Theme.of(context).colorScheme.onSecondaryContainer,
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 32),
            ElevatedButton(
              onPressed: () {
                Navigator.pushReplacement(
                  context,
                  MaterialPageRoute(builder: (_) => QuizScreen(
                    api: api, 
                    plantId: plantId,
                    progressService: progressService,
                  )),
                );
              },
              child: const Padding(
                padding: EdgeInsets.symmetric(vertical: 16.0),
                child: Text('Quiz Starten'),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
