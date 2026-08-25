import 'package:flutter/material.dart';
import 'package:openapi/openapi.dart';
import '../../core/theme/app_colors.dart';
import '../../storage/progress_service.dart';
import '../quiz/quiz_screen.dart';
import '../plant/plant_profile_screen.dart';

class LevelMapScreen extends StatefulWidget {
  final Ecosystem ecosystem;
  final Openapi api;
  final ProgressService? progressService;

  const LevelMapScreen({
    super.key,
    required this.ecosystem,
    required this.api,
    this.progressService,
  });

  @override
  State<LevelMapScreen> createState() => _LevelMapScreenState();
}

class _LevelMapScreenState extends State<LevelMapScreen> {
  List<Level> _levels = [];
  List<Plant> _plants = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadData();
  }

  Future<void> _loadData() async {
    setState(() {
      _isLoading = true;
    });

    try {
      final levelsRes = await widget.api.getDefaultApi().listLevels();
      final plantsRes = await widget.api.getDefaultApi().listPlants();

      // Filter levels for current ecosystem or default
      final allLevels = levelsRes.data?.toList() ?? [];
      final ecoNameKeyword = widget.ecosystem.name.split(' ')[0];
      final ecoLevels = allLevels.where((l) => l.title.contains(ecoNameKeyword)).toList();

      setState(() {
        _levels = ecoLevels.isNotEmpty ? ecoLevels : (allLevels.isNotEmpty ? allLevels.take(5).toList() : _generateFallbackLevels());
        _plants = plantsRes.data?.toList() ?? [];
        _isLoading = false;
      });
    } catch (e) {
      setState(() {
        _levels = _generateFallbackLevels();
        _isLoading = false;
      });
    }
  }

  List<Level> _generateFallbackLevels() {
    return [
      Level((b) => b
        ..id = '1'
        ..title = 'Grundlagen & Erste Arten'
        ..isUnlocked = true
        ..progress = 0.6),
      Level((b) => b
        ..id = '2'
        ..title = 'Häufige Arten unterscheiden'
        ..isUnlocked = true
        ..progress = 0.2),
      Level((b) => b
        ..id = '3'
        ..title = 'Fortgeschrittene Merkmale'
        ..isUnlocked = false
        ..progress = 0.0),
      Level((b) => b
        ..id = '4'
        ..title = 'Experten-Bestimmung'
        ..isUnlocked = false
        ..progress = 0.0),
      Level((b) => b
        ..id = '5'
        ..title = 'Meister-Feldforschung'
        ..isUnlocked = false
        ..progress = 0.0),
    ];
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new, size: 18),
          onPressed: () => Navigator.pop(context),
        ),
        title: Text(widget.ecosystem.name),
        actions: [
          IconButton(
            icon: const Icon(Icons.more_horiz),
            onPressed: () {},
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
                    // Path Summary Card
                    _buildPathSummaryCard(),
                    const SizedBox(height: 18),

                    // Super Mario World Level Path
                    _buildSuperMarioLevelPath(),
                    const SizedBox(height: 24),
                  ],
                ),
              ),
            ),
    );
  }

  Widget _buildPathSummaryCard() {
    return Container(
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: AppColors.white,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: const Color(0x182F5D50)),
        boxShadow: const [
          BoxShadow(
            color: Color(0x0E26332F),
            blurRadius: 20,
            offset: Offset(0, 8),
          )
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'FORSCHERPFAD',
                    style: TextStyle(
                      fontSize: 11,
                      fontWeight: FontWeight.w900,
                      letterSpacing: 1.1,
                      color: AppColors.sage,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    'Dein Weg durch: ${widget.ecosystem.name}',
                    style: const TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.w900,
                      letterSpacing: -0.3,
                      color: AppColors.ink,
                    ),
                  ),
                ],
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                decoration: BoxDecoration(
                  color: const Color(0xFFFFF4D2),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: const Text(
                  '1.240 XP',
                  style: TextStyle(
                    fontSize: 11,
                    fontWeight: FontWeight.w900,
                    color: Color(0xFF7D5A19),
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 14),
          ClipRRect(
            borderRadius: BorderRadius.circular(999),
            child: const LinearProgressIndicator(
              value: 0.42,
              minHeight: 8,
              backgroundColor: Color(0xFFE7E9E3),
              valueColor: AlwaysStoppedAnimation<Color>(AppColors.forest),
            ),
          ),
          const SizedBox(height: 8),
          const Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                '12 von 30 Arten sicher',
                style: TextStyle(fontSize: 11, color: AppColors.muted, fontWeight: FontWeight.w600),
              ),
              Text(
                '42 % abgeschlossen',
                style: TextStyle(fontSize: 11, color: AppColors.muted, fontWeight: FontWeight.w800),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildSuperMarioLevelPath() {
    return Stack(
      children: [
        // Connected path line
        Positioned(
          left: 42,
          top: 30,
          bottom: 40,
          child: Container(
            width: 4,
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(4),
              gradient: const LinearGradient(
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
                colors: [
                  AppColors.forest,
                  AppColors.forest,
                  Color(0xFFCED5CE),
                  Color(0xFFCED5CE),
                ],
                stops: [0.0, 0.4, 0.45, 1.0],
              ),
            ),
          ),
        ),

        // Stage rows
        Column(
          children: _levels.asMap().entries.map((entry) {
            final idx = entry.key;
            final level = entry.value;
            final isUnlocked = level.isUnlocked ?? (idx < 2);
            final stageNum = int.tryParse(level.id) ?? (idx + 1);

            return Padding(
              padding: const EdgeInsets.only(bottom: 22.0),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Super Mario Level Node
                  GestureDetector(
                    onTap: () => _onLevelTapped(level, isUnlocked, stageNum),
                    child: Container(
                      width: 54,
                      height: 54,
                      margin: const EdgeInsets.only(left: 15, right: 14),
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        color: isUnlocked ? AppColors.forest : const Color(0xFFEDF0EC),
                        border: Border.all(
                          color: isUnlocked ? const Color(0xFFDCE8D9) : Colors.white,
                          width: 5,
                        ),
                        boxShadow: [
                          BoxShadow(
                            color: isUnlocked ? AppColors.forest.withValues(alpha: 0.3) : Colors.black12,
                            blurRadius: 8,
                            offset: const Offset(0, 4),
                          )
                        ],
                      ),
                      alignment: Alignment.center,
                      child: isUnlocked
                          ? Text(
                              '$stageNum',
                              style: const TextStyle(
                                color: Colors.white,
                                fontSize: 18,
                                fontWeight: FontWeight.w900,
                              ),
                            )
                          : const Icon(
                              Icons.lock_rounded,
                              size: 20,
                              color: Color(0xFF7F8984),
                            ),
                    ),
                  ),

                  // Level Info Card
                  Expanded(
                    child: GestureDetector(
                      onTap: () => _onLevelTapped(level, isUnlocked, stageNum),
                      child: Container(
                        padding: const EdgeInsets.all(14),
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(20),
                          border: Border.all(
                            color: isUnlocked ? const Color(0x1A2F5D50) : const Color(0x0C000000),
                          ),
                          boxShadow: [
                            if (isUnlocked)
                              const BoxShadow(
                                color: Color(0x0B26332F),
                                blurRadius: 16,
                                offset: Offset(0, 6),
                              )
                          ],
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Container(
                                  padding: const EdgeInsets.symmetric(horizontal: 9, vertical: 4),
                                  decoration: BoxDecoration(
                                    color: isUnlocked ? AppColors.forest : const Color(0xFFF0EADF),
                                    borderRadius: BorderRadius.circular(999),
                                  ),
                                  child: Text(
                                    isUnlocked ? (idx == 0 ? 'aktiv' : 'Level $stageNum') : 'Level $stageNum',
                                    style: TextStyle(
                                      color: isUnlocked ? Colors.white : AppColors.bark,
                                      fontSize: 10,
                                      fontWeight: FontWeight.w900,
                                    ),
                                  ),
                                ),
                                Text(
                                  isUnlocked ? '6 Arten' : 'gesperrt',
                                  style: const TextStyle(
                                    fontSize: 11,
                                    color: AppColors.muted,
                                    fontWeight: FontWeight.w600,
                                  ),
                                ),
                              ],
                            ),
                            const SizedBox(height: 8),
                            Text(
                              level.title,
                              style: TextStyle(
                                fontSize: 15,
                                fontWeight: FontWeight.w800,
                                color: isUnlocked ? AppColors.ink : AppColors.muted,
                              ),
                            ),
                            const SizedBox(height: 4),
                            Text(
                              isUnlocked
                                  ? 'Quiz, Merkmale und Artenpass abschließen'
                                  : 'Voraussetzung: Level $idx abschließen',
                              style: const TextStyle(
                                fontSize: 11,
                                color: AppColors.muted,
                              ),
                            ),
                            if (isUnlocked) ...[
                              const SizedBox(height: 10),
                              ClipRRect(
                                borderRadius: BorderRadius.circular(999),
                                child: LinearProgressIndicator(
                                  value: level.progress ?? (idx == 0 ? 0.6 : 0.2),
                                  minHeight: 6,
                                  backgroundColor: const Color(0xFFE7E9E3),
                                  valueColor: const AlwaysStoppedAnimation<Color>(AppColors.forest),
                                ),
                              ),
                            ]
                          ],
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            );
          }).toList(),
        ),
      ],
    );
  }

  void _onLevelTapped(Level level, bool isUnlocked, int stageNum) {
    if (!isUnlocked) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('🔒 Level $stageNum: Schließe zuerst das vorherige Level ab!'),
          backgroundColor: AppColors.forestDark,
          duration: const Duration(seconds: 2),
        ),
      );
      return;
    }

    // Open Super Mario Level Modal
    showModalBottomSheet(
      context: context,
      backgroundColor: AppColors.cream,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(28)),
      ),
      builder: (ctx) => Padding(
        padding: const EdgeInsets.fromLTRB(24, 20, 24, 32),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Center(
              child: Container(
                width: 40,
                height: 4,
                decoration: BoxDecoration(
                  color: AppColors.line,
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
            ),
            const SizedBox(height: 18),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                  decoration: BoxDecoration(
                    color: AppColors.mint,
                    borderRadius: BorderRadius.circular(999),
                  ),
                  child: Text(
                    'Level $stageNum · ${widget.ecosystem.name}',
                    style: const TextStyle(
                      color: AppColors.forest,
                      fontWeight: FontWeight.w900,
                      fontSize: 11,
                    ),
                  ),
                ),
                const Text(
                  '+50 XP',
                  style: TextStyle(
                    color: Color(0xFF7D5A19),
                    fontWeight: FontWeight.w900,
                    fontSize: 12,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            Text(
              level.title,
              style: const TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.w900,
                color: AppColors.ink,
              ),
            ),
            const SizedBox(height: 6),
            const Text(
              'Beantworte die Quizfragen zu den Arten dieses Levels, um deinen Artenpass zu erweitern!',
              style: TextStyle(
                fontSize: 13,
                color: AppColors.muted,
                height: 1.4,
              ),
            ),
            const SizedBox(height: 24),
            ElevatedButton.icon(
              onPressed: () {
                Navigator.pop(ctx);
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (_) => QuizScreen(
                      level: level,
                      api: widget.api,
                      progressService: widget.progressService,
                    ),
                  ),
                );
              },
              icon: const Icon(Icons.play_arrow_rounded, size: 22),
              label: const Text('Level-Quiz starten'),
              style: ElevatedButton.styleFrom(
                padding: const EdgeInsets.symmetric(vertical: 14),
              ),
            ),
            const SizedBox(height: 10),
            TextButton.icon(
              onPressed: () {
                Navigator.pop(ctx);
                final plantId = _plants.isNotEmpty ? _plants.first.id : '1';
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (_) => PlantProfileScreen(
                      plantId: plantId,
                      api: widget.api,
                      progressService: widget.progressService,
                    ),
                  ),
                );
              },
              icon: const Icon(Icons.menu_book_rounded, size: 18, color: AppColors.forest),
              label: const Text('Pflanzensteckbriefe ansehen', style: TextStyle(color: AppColors.forest)),
            ),
          ],
        ),
      ),
    );
  }
}
