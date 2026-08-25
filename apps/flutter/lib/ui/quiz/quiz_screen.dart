import 'package:flutter/material.dart';
import 'package:openapi/openapi.dart';
import '../../core/theme/app_colors.dart';
import '../../storage/progress_service.dart';
import '../components/plant_art_widget.dart';

class QuizScreen extends StatefulWidget {
  final Level? level;
  final String? plantId;
  final Openapi api;
  final ProgressService? progressService;

  const QuizScreen({
    super.key,
    this.level,
    this.plantId,
    required this.api,
    this.progressService,
  });

  @override
  State<QuizScreen> createState() => _QuizScreenState();
}

class _QuizScreenState extends State<QuizScreen> {
  List<Map<String, dynamic>> _questions = [];
  int _currentIndex = 0;
  int? _selectedAnswer;
  bool _answered = false;
  int _score = 0;
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadQuizzes();
  }

  Future<void> _loadQuizzes() async {
    try {
      final res = await widget.api.getDefaultApi().listQuizzes();
      final quizzes = res.data?.toList() ?? [];

      if (quizzes.isNotEmpty) {
        final parsed = <Map<String, dynamic>>[];
        for (final q in quizzes) {
          if (q.data != null) {
            final map = q.data!.asMap;
            if (map.containsKey('question') && map.containsKey('options')) {
              parsed.add({
                'title': q.title,
                'question': map['question'] ?? 'Welche Pflanze ist hier abgebildet?',
                'options': List<String>.from(map['options'] ?? []),
                'correct': map['correct'] is int ? map['correct'] : 0,
                'explanation': map['explanation'] ?? 'Typische Merkmale der Art.',
              });
            }
          }
        }
        if (parsed.isNotEmpty) {
          setState(() {
            _questions = parsed.take(5).toList();
            _isLoading = false;
          });
          return;
        }
      }
    } catch (_) {}

    // Fallback interactive questions
    setState(() {
      _questions = [
        {
          'title': 'Waldmeister-Quiz',
          'question': 'Welche Art hat schmale Blätter in deutlichen Quirlen um den vierkantigen Stängel?',
          'options': ['Waldmeister', 'Bärlauch', 'Kletten-Labkraut', 'Maiglöckchen'],
          'correct': 0,
          'explanation': 'Die schmalen Blätter stehen in 6-8-zähligen Quirlen sternförmig um den Stängel.',
        },
        {
          'title': 'Laubbaum-Merkmale',
          'question': 'Welcher Baum besitzt eine glatte, silbergraue Rinde und dreikantige Bucheckern?',
          'options': ['Stieleiche', 'Rotbuche', 'Bergahorn', 'Hänge-Birke'],
          'correct': 1,
          'explanation': 'Die Rotbuche (Fagus sylvatica) ist an ihrer glatten Rinde und den Bucheckern eindeutig erkennbar.',
        },
        {
          'title': 'Frühblüher',
          'question': 'Welche Pflanze riecht intensiv nach Knoblauch und wächst teppichartig in Auwäldern?',
          'options': ['Buschwindröschen', 'Maiglöckchen', 'Bärlauch', 'Wald-Sauerklee'],
          'correct': 2,
          'explanation': 'Bärlauch verströmt beim Zerreiben einen intensiven Knoblauchduft.',
        },
      ];
      _isLoading = false;
    });
  }

  void _onAnswerSelected(int index) {
    if (_answered) return;
    setState(() {
      _selectedAnswer = index;
      _answered = true;
      if (index == _questions[_currentIndex]['correct']) {
        _score++;
      }
    });
  }

  void _nextQuestion() {
    if (_currentIndex < _questions.length - 1) {
      setState(() {
        _currentIndex++;
        _selectedAnswer = null;
        _answered = false;
      });
    } else {
      _showQuizFinishedDialog();
    }
  }

  void _showQuizFinishedDialog() {
    final percent = (_score / _questions.length * 100).round();
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (ctx) => AlertDialog(
        backgroundColor: AppColors.cream,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
        title: Row(
          children: [
            const Icon(Icons.stars_rounded, color: AppColors.sun, size: 28),
            const SizedBox(width: 8),
            Text(
              percent >= 60 ? 'Level gemeistert! 🎉' : 'Übung beendet',
              style: const TextStyle(fontWeight: FontWeight.w900, color: AppColors.forest),
            ),
          ],
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Du hast $_score von ${_questions.length} Fragen richtig beantwortet ($percent%).'),
            const SizedBox(height: 12),
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: AppColors.mint,
                borderRadius: BorderRadius.circular(14),
              ),
              child: const Row(
                children: [
                  Icon(Icons.bolt_rounded, color: AppColors.forest),
                  SizedBox(width: 8),
                  Text(
                    '+50 XP für deinen Forscherpass!',
                    style: TextStyle(fontWeight: FontWeight.w800, color: AppColors.forest, fontSize: 12),
                  ),
                ],
              ),
            ),
          ],
        ),
        actions: [
          ElevatedButton(
            onPressed: () {
              Navigator.pop(ctx);
              Navigator.pop(context);
            },
            child: const Text('Zum Forscherpfad'),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return const Scaffold(body: Center(child: CircularProgressIndicator()));
    }

    final currentQ = _questions[_currentIndex];
    final options = currentQ['options'] as List<String>;
    final correctIdx = currentQ['correct'] as int;
    final progress = (_currentIndex + 1) / _questions.length;

    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
          icon: const Icon(Icons.close_rounded, size: 22),
          onPressed: () => Navigator.pop(context),
        ),
        title: Text(widget.level?.title ?? 'Wald-Quiz'),
        actions: [
          Container(
            margin: const EdgeInsets.only(right: 14),
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
            decoration: BoxDecoration(
              color: const Color(0xFFFFF4D2),
              borderRadius: BorderRadius.circular(12),
            ),
            child: const Text(
              '+20 XP',
              style: TextStyle(
                fontSize: 11,
                fontWeight: FontWeight.w900,
                color: Color(0xFF7D5A19),
              ),
            ),
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 8),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // Progress row
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'Frage ${_currentIndex + 1} von ${_questions.length}',
                  style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w900, color: AppColors.ink),
                ),
                const Text(
                  'Merkmale',
                  style: TextStyle(fontSize: 11, color: AppColors.muted),
                ),
              ],
            ),
            const SizedBox(height: 8),
            ClipRRect(
              borderRadius: BorderRadius.circular(999),
              child: LinearProgressIndicator(
                value: progress,
                minHeight: 8,
                backgroundColor: const Color(0xFFE7E9E3),
                valueColor: const AlwaysStoppedAnimation<Color>(AppColors.forest),
              ),
            ),
            const SizedBox(height: 16),

            // Prompt Header
            const Text(
              'ARTEN SICHER UNTERSCHEIDEN',
              style: TextStyle(
                fontSize: 11,
                fontWeight: FontWeight.w900,
                letterSpacing: 1.1,
                color: AppColors.sage,
              ),
            ),
            const SizedBox(height: 4),
            Text(
              currentQ['question'] as String,
              style: const TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.w900,
                letterSpacing: -0.4,
                color: AppColors.ink,
                height: 1.2,
              ),
            ),
            const SizedBox(height: 14),

            // Botanical Image Card
            const PlantArtWidget(
              height: 200,
              width: double.infinity,
            ),
            const SizedBox(height: 16),

            // 4-Answer Grid (2x2)
            GridView.builder(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 2,
                crossAxisSpacing: 10,
                mainAxisSpacing: 10,
                childAspectRatio: 2.2,
              ),
              itemCount: options.length,
              itemBuilder: (context, idx) {
                final isSelected = _selectedAnswer == idx;
                final isCorrect = idx == correctIdx;

                Color bgColor = Colors.white;
                Color borderColor = AppColors.line;
                Color textColor = AppColors.ink;
                Widget? trailingIcon;

                if (_answered) {
                  if (isCorrect) {
                    bgColor = const Color(0xFFEDF5EB);
                    borderColor = AppColors.forest;
                    textColor = AppColors.forest;
                    trailingIcon = const Icon(Icons.check_circle_rounded, size: 18, color: AppColors.forest);
                  } else if (isSelected) {
                    bgColor = const Color(0xFFFFECE8);
                    borderColor = AppColors.danger;
                    textColor = AppColors.danger;
                    trailingIcon = const Icon(Icons.cancel_rounded, size: 18, color: AppColors.danger);
                  }
                }

                return GestureDetector(
                  onTap: () => _onAnswerSelected(idx),
                  child: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                    decoration: BoxDecoration(
                      color: bgColor,
                      borderRadius: BorderRadius.circular(16),
                      border: Border.all(color: borderColor, width: isCorrect && _answered ? 2 : 1),
                    ),
                    alignment: Alignment.centerLeft,
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Expanded(
                          child: Text(
                            options[idx],
                            style: TextStyle(
                              fontSize: 12,
                              fontWeight: FontWeight.w800,
                              color: textColor,
                            ),
                          ),
                        ),
                        if (trailingIcon != null) trailingIcon,
                      ],
                    ),
                  ),
                );
              },
            ),
            const SizedBox(height: 14),

            // Instant Botanical Feedback Card
            if (_answered) ...[
              Container(
                padding: const EdgeInsets.all(14),
                decoration: BoxDecoration(
                  color: _selectedAnswer == correctIdx ? const Color(0xFFE5EFE2) : const Color(0xFFFFF0EC),
                  borderRadius: BorderRadius.circular(16),
                ),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      _selectedAnswer == correctIdx ? '✓ ' : '✗ ',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w900,
                        color: _selectedAnswer == correctIdx ? AppColors.forest : AppColors.danger,
                      ),
                    ),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            _selectedAnswer == correctIdx ? 'Richtig!' : 'Nicht ganz richtig!',
                            style: TextStyle(
                              fontWeight: FontWeight.w900,
                              fontSize: 12,
                              color: _selectedAnswer == correctIdx ? AppColors.forest : AppColors.danger,
                            ),
                          ),
                          const SizedBox(height: 2),
                          Text(
                            currentQ['explanation'] as String,
                            style: const TextStyle(fontSize: 11, color: AppColors.ink, height: 1.35),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 14),
              ElevatedButton(
                onPressed: _nextQuestion,
                style: ElevatedButton.styleFrom(padding: const EdgeInsets.symmetric(vertical: 14)),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(
                      _currentIndex < _questions.length - 1 ? 'Weiter zur nächsten Art' : 'Ergebnis anzeigen',
                      style: const TextStyle(fontWeight: FontWeight.w900, fontSize: 14),
                    ),
                    const SizedBox(width: 6),
                    const Icon(Icons.arrow_forward_rounded, size: 18),
                  ],
                ),
              ),
            ],
            const SizedBox(height: 20),
          ],
        ),
      ),
    );
  }
}
