import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:openapi/openapi.dart';
import '../../storage/progress_service.dart';

class QuizScreen extends StatefulWidget {
  final Openapi api;
  final String plantId;
  final ProgressService? progressService;

  const QuizScreen({super.key, required this.api, required this.plantId, this.progressService});

  @override
  State<QuizScreen> createState() => _QuizScreenState();
}

class _QuizScreenState extends State<QuizScreen> {
  int _currentQuestionIndex = 0;
  String? _feedbackMessage;
  bool _isAnswerCorrect = false;
  final TextEditingController _textController = TextEditingController();

  late final String _quizId;

  final List<Map<String, dynamic>> _quizQuestions = [
    {
      'type': 'multiple_choice',
      'question': 'Welche dieser Pflanzen ist eine Stieleiche?',
      'options': ['Pflanze A', 'Pflanze B', 'Pflanze C'],
      'correctOption': 1, // index of option B
    },
    {
      'type': 'image_recognition',
      'question': 'Erkenne die Pflanze auf dem Bild:',
      'imageUrl': 'https://via.placeholder.com/300x200.png?text=Mystery+Plant',
      'options': ['Stieleiche', 'Rotbuche', 'Spitzahorn'],
      'correctOption': 0,
    },
    {
      'type': 'text_input',
      'question': 'Wie lautet der botanische Name der Stieleiche?',
      'correctAnswer': 'Quercus robur',
    }
  ];

  @override
  void initState() {
    super.initState();
    _quizId = 'quiz_${widget.plantId}';
    _loadProgress();
  }

  Future<void> _loadProgress() async {
    if (widget.progressService == null) return;
    final progress = await widget.progressService!.getQuizProgress(_quizId);
    if (progress != null && progress.pausedStateJson != null) {
      try {
        final state = jsonDecode(progress.pausedStateJson!);
        setState(() {
          _currentQuestionIndex = state['currentQuestionIndex'] ?? 0;
        });
      } catch (e) {
        debugPrint('Failed to load quiz progress: $e');
      }
    }
  }

  Future<void> _saveProgress() async {
    if (widget.progressService == null) return;
    final state = jsonEncode({'currentQuestionIndex': _currentQuestionIndex});
    await widget.progressService!.saveQuizPausedState(_quizId, state);
  }

  Future<void> _completeQuiz() async {
    if (widget.progressService != null) {
      await widget.progressService!.markQuizPassed(_quizId);
    }
    if (mounted) {
      Navigator.pop(context);
    }
  }

  void _submitAnswer(dynamic answer) {
    setState(() {
      final currentQ = _quizQuestions[_currentQuestionIndex];
      if (currentQ['type'] == 'text_input') {
        _isAnswerCorrect = (answer.toString().trim().toLowerCase() == currentQ['correctAnswer'].toString().toLowerCase());
      } else {
        _isAnswerCorrect = (answer == currentQ['correctOption']);
      }

      _feedbackMessage = _isAnswerCorrect ? 'Richtig!' : 'Leider falsch. Versuch es nochmal.';
    });
  }

  void _nextQuestion() {
    setState(() {
      _feedbackMessage = null;
      _textController.clear();
      if (_currentQuestionIndex < _quizQuestions.length - 1) {
        _currentQuestionIndex++;
        _saveProgress();
      } else {
        // End of quiz
        _completeQuiz();
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final currentQ = _quizQuestions[_currentQuestionIndex];
    final progress = (_currentQuestionIndex + 1) / _quizQuestions.length;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Quiz'),
      ),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              LinearProgressIndicator(value: progress),
              const SizedBox(height: 24),
              Text(
                'Frage ${_currentQuestionIndex + 1} von ${_quizQuestions.length}',
                style: Theme.of(context).textTheme.titleMedium,
              ),
              const SizedBox(height: 16),
              Text(
                currentQ['question'],
                style: Theme.of(context).textTheme.headlineSmall,
              ),
              const SizedBox(height: 24),
              if (currentQ['type'] == 'image_recognition') ...[
                Image.network(
                  currentQ['imageUrl'],
                  height: 200,
                  fit: BoxFit.cover,
                  errorBuilder: (context, error, stackTrace) => Container(
                    height: 200,
                    color: Theme.of(context).colorScheme.surfaceContainerHighest,
                    child: const Center(child: Icon(Icons.broken_image)),
                  ),
                ),
                const SizedBox(height: 24),
              ],
              Expanded(
                child: _buildQuestionContent(currentQ),
              ),
              if (_feedbackMessage != null) ...[
                Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: _isAnswerCorrect ? Theme.of(context).colorScheme.primaryContainer : Theme.of(context).colorScheme.errorContainer,
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Row(
                    children: [
                      Icon(
                        _isAnswerCorrect ? Icons.check_circle : Icons.error,
                        color: _isAnswerCorrect ? Theme.of(context).colorScheme.onPrimaryContainer : Theme.of(context).colorScheme.onErrorContainer,
                      ),
                      const SizedBox(width: 16),
                      Expanded(
                        child: Text(
                          _feedbackMessage!,
                          style: TextStyle(
                            color: _isAnswerCorrect ? Theme.of(context).colorScheme.onPrimaryContainer : Theme.of(context).colorScheme.onErrorContainer,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 16),
                if (_isAnswerCorrect)
                  ElevatedButton(
                    onPressed: _nextQuestion,
                    child: Text(_currentQuestionIndex == _quizQuestions.length - 1 ? 'Quiz beenden' : 'Nächste Frage'),
                  ),
              ],
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildQuestionContent(Map<String, dynamic> currentQ) {
    if (currentQ['type'] == 'text_input') {
      return Column(
        children: [
          TextField(
            controller: _textController,
            decoration: const InputDecoration(
              labelText: 'Antwort eingeben',
              border: OutlineInputBorder(),
            ),
            enabled: _feedbackMessage == null || !_isAnswerCorrect,
            onSubmitted: (value) => _submitAnswer(value),
          ),
          const SizedBox(height: 16),
          ElevatedButton(
            onPressed: (_feedbackMessage == null || !_isAnswerCorrect) ? () => _submitAnswer(_textController.text) : null,
            child: const Text('Prüfen'),
          ),
        ],
      );
    } else {
      // multiple_choice or image_recognition options
      final options = List<String>.from(currentQ['options']);
      return ListView.builder(
        itemCount: options.length,
        itemBuilder: (context, index) {
          final isSelectedAndCorrect = _feedbackMessage != null && index == currentQ['correctOption'];
          return Padding(
            padding: const EdgeInsets.only(bottom: 12.0),
            child: ElevatedButton(
              style: ElevatedButton.styleFrom(
                alignment: Alignment.centerLeft,
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 20),
                backgroundColor: isSelectedAndCorrect ? Theme.of(context).colorScheme.primaryContainer : null,
                foregroundColor: isSelectedAndCorrect ? Theme.of(context).colorScheme.onPrimaryContainer : null,
              ),
              onPressed: (_feedbackMessage == null || !_isAnswerCorrect) ? () => _submitAnswer(index) : null,
              child: Text(options[index], style: const TextStyle(fontSize: 16)),
            ),
          );
        },
      );
    }
  }

  @override
  void dispose() {
    _textController.dispose();
    super.dispose();
  }
}
