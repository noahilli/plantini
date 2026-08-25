import 'package:flutter/material.dart';
import 'package:openapi/openapi.dart';
import 'package:dio/dio.dart';
import '../auth/auth_service.dart';
import '../main.dart' show getApiBaseUrl;
import '../core/theme/app_colors.dart';
import '../storage/progress_service.dart';
import '../storage/offline_queue_service.dart';
import 'components/plant_art_widget.dart';
import 'components/circular_progress_ring.dart';
import 'game/level_map_screen.dart';
import 'expedition/identify_screen.dart';
import 'herbarium/herbarium_screen.dart';

class HomeScreen extends StatefulWidget {
  final AuthService authService;
  final ProgressService? progressService;
  final OfflineQueueService? queueService;
  final Openapi? api;

  const HomeScreen({
    super.key,
    required this.authService,
    this.progressService,
    this.queueService,
    this.api,
  });

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  late final Openapi api;
  int _currentTabIndex = 0;
  UserProfile? _profile;
  List<Ecosystem> _ecosystems = [];
  bool _isLoading = true;
  String? _error;

  @override
  void initState() {
    super.initState();
    api = widget.api ?? Openapi(dio: Dio(BaseOptions(baseUrl: getApiBaseUrl())));
    _fetchData();
  }

  Future<void> _fetchData() async {
    setState(() {
      _isLoading = true;
      _error = null;
    });

    try {
      final token = await widget.authService.getAccessToken();
      if (token != null) {
        api.setBearerAuth('bearerAuth', token);
      }
      final profileRes = await api.getDefaultApi().getMe();
      final ecosystemRes = await api.getDefaultApi().listEcosystems();

      setState(() {
        _profile = profileRes.data;
        _ecosystems = ecosystemRes.data?.toList() ?? [];
        _isLoading = false;
        _error = null;
      });
    } catch (e) {
      setState(() {
        _error = e.toString();
        _isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: IndexedStack(
        index: _currentTabIndex,
        children: [
          // Tab 0: Home Screen
          _buildHomeTab(),

          // Tab 1: Lernen (Super Mario Level Map)
          _ecosystems.isNotEmpty
              ? LevelMapScreen(
                  ecosystem: _ecosystems.first,
                  api: api,
                  progressService: widget.progressService,
                )
              : const Center(child: CircularProgressIndicator()),

          // Tab 2: Expedition
          IdentifyScreen(
            api: api,
            queueService: widget.queueService,
          ),

          // Tab 3: Herbarium
          HerbariumScreen(
            api: api,
            queueService: widget.queueService,
          ),

          // Tab 4: Profil
          _buildProfileTab(),
        ],
      ),
      bottomNavigationBar: _buildBottomNav(),
    );
  }

  Widget _buildHomeTab() {
    return SafeArea(
      child: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : _error != null
              ? Center(
                  child: Padding(
                    padding: const EdgeInsets.all(24.0),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        const Icon(Icons.error_outline, size: 48, color: AppColors.danger),
                        const SizedBox(height: 16),
                        Text('Fehler beim Laden: $_error', textAlign: TextAlign.center),
                        const SizedBox(height: 16),
                        ElevatedButton.icon(
                          onPressed: _fetchData,
                          icon: const Icon(Icons.refresh),
                          label: const Text('Erneut versuchen'),
                        ),
                      ],
                    ),
                  ),
                )
              : RefreshIndicator(
                  onRefresh: _fetchData,
                  child: SingleChildScrollView(
                    physics: const AlwaysScrollableScrollPhysics(),
                    padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 12),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        // Topbar: Brand & Profile button
                        _buildTopBar(),
                        const SizedBox(height: 16),

                        // Header: Greeting & Streak
                        _buildGreetingHeader(),
                        const SizedBox(height: 14),

                        // Hero Banner Card
                        _buildHeroCard(),
                        const SizedBox(height: 20),

                        // Section Title: Ökosysteme
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            const Text(
                              'Ökosysteme',
                              style: TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.w900,
                                color: AppColors.ink,
                              ),
                            ),
                            TextButton(
                              onPressed: () {
                                setState(() => _currentTabIndex = 1);
                              },
                              style: TextButton.styleFrom(
                                padding: EdgeInsets.zero,
                                minimumSize: const Size(40, 30),
                              ),
                              child: const Text(
                                'Alle ansehen',
                                style: TextStyle(
                                  fontSize: 12,
                                  fontWeight: FontWeight.w700,
                                  color: AppColors.muted,
                                ),
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 10),

                        // Eco Grid Cards
                        _buildEcoGrid(),
                        const SizedBox(height: 16),

                        // Offline Status Card
                        _buildOfflineStatusCard(),
                        const SizedBox(height: 20),
                      ],
                    ),
                  ),
                ),
    );
  }

  Widget _buildTopBar() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Row(
          children: [
            Container(
              width: 32,
              height: 32,
              decoration: BoxDecoration(
                color: AppColors.forest,
                borderRadius: BorderRadius.circular(10),
              ),
              child: const Icon(
                Icons.eco_rounded,
                color: Colors.white,
                size: 20,
              ),
            ),
            const SizedBox(width: 8),
            const Text(
              'plantini',
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.w900,
                letterSpacing: -0.5,
                color: AppColors.forest,
              ),
            ),
          ],
        ),
        IconButton(
          onPressed: () => setState(() => _currentTabIndex = 4),
          icon: const Icon(Icons.person_outline_rounded, size: 22),
          style: IconButton.styleFrom(
            backgroundColor: Colors.white,
            side: const BorderSide(color: AppColors.line),
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(13)),
          ),
        ),
      ],
    );
  }

  Widget _buildGreetingHeader() {
    final name = _profile?.username ?? 'Alex';
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'DEINE FORSCHUNGSREISE',
              style: TextStyle(
                fontSize: 11,
                fontWeight: FontWeight.w900,
                letterSpacing: 1.1,
                color: AppColors.sage,
              ),
            ),
            const SizedBox(height: 4),
            Text(
              'Hallo, $name!',
              style: const TextStyle(
                fontSize: 26,
                fontWeight: FontWeight.w900,
                letterSpacing: -0.7,
                color: AppColors.ink,
              ),
            ),
          ],
        ),
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 11, vertical: 7),
          decoration: BoxDecoration(
            color: const Color(0xFFFFF4D2),
            borderRadius: BorderRadius.circular(13),
          ),
          child: const Text(
            '🔥 7 Tage',
            style: TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.w900,
              color: Color(0xFF7B5A1E),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildHeroCard() {
    return Container(
      height: 245,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(26),
        gradient: const LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            AppColors.forestDark,
            AppColors.forest,
          ],
        ),
        boxShadow: const [
          BoxShadow(
            color: Color(0x382F5D50),
            blurRadius: 32,
            offset: Offset(0, 15),
          )
        ],
      ),
      child: Stack(
        children: [
          // Background circular botanical artwork
          Positioned(
            right: -30,
            bottom: -34,
            child: Container(
              width: 205,
              height: 205,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                border: Border.all(color: Colors.white24, width: 1),
              ),
              child: const ClipOval(
                child: PlantArtWidget(),
              ),
            ),
          ),

          // Content
          Padding(
            padding: const EdgeInsets.all(18.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                      decoration: BoxDecoration(
                        color: AppColors.mint,
                        borderRadius: BorderRadius.circular(999),
                      ),
                      child: const Text(
                        'Wald · Level 1',
                        style: TextStyle(
                          fontSize: 11,
                          fontWeight: FontWeight.w900,
                          color: AppColors.forest,
                        ),
                      ),
                    ),
                    const CircularProgressRing(progress: 0.42, size: 56),
                  ],
                ),
                const SizedBox(height: 8),
                const SizedBox(
                  width: 200,
                  child: Text(
                    'Waldmeister sicher erkennen',
                    style: TextStyle(
                      fontSize: 22,
                      fontWeight: FontWeight.w900,
                      color: Colors.white,
                      height: 1.1,
                    ),
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  '12 von 30 Arten entdeckt',
                  style: TextStyle(
                    fontSize: 12,
                    color: Colors.white.withOpacity(0.75),
                  ),
                ),
                const Spacer(),
                SizedBox(
                  width: double.infinity,
                  height: 44,
                  child: ElevatedButton(
                    onPressed: () {
                      if (_ecosystems.isNotEmpty) {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (_) => LevelMapScreen(
                              ecosystem: _ecosystems.first,
                              api: api,
                              progressService: widget.progressService,
                            ),
                          ),
                        );
                      }
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.white,
                      foregroundColor: AppColors.forest,
                      elevation: 0,
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
                    ),
                    child: const Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Text('Weiterlernen', style: TextStyle(fontWeight: FontWeight.w900, fontSize: 14)),
                        SizedBox(width: 6),
                        Icon(Icons.arrow_forward_rounded, size: 18),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildEcoGrid() {
    final items = [
      {'name': 'Wald', 'progress': '42 % gelernt', 'colors': [const Color(0xFF5B7A5E), const Color(0xFF2E5649)]},
      {'name': 'Wiese', 'progress': '18 % gelernt', 'colors': [const Color(0xFFB6A267), const Color(0xFF71805A)]},
      {'name': 'Gewässer', 'progress': 'bereit', 'colors': [const Color(0xFF6D8E91), const Color(0xFF365B63)]},
    ];

    return Row(
      children: items.asMap().entries.map((entry) {
        final idx = entry.key;
        final item = entry.value;
        final ecosystem = idx < _ecosystems.length ? _ecosystems[idx] : null;

        return Expanded(
          child: Padding(
            padding: EdgeInsets.only(right: idx < 2 ? 8.0 : 0.0),
            child: GestureDetector(
              onTap: () {
                if (ecosystem != null) {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (_) => LevelMapScreen(
                        ecosystem: ecosystem,
                        api: api,
                        progressService: widget.progressService,
                      ),
                    ),
                  );
                }
              },
              child: Container(
                height: 88,
                padding: const EdgeInsets.all(10),
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(17),
                  gradient: LinearGradient(
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                    colors: item['colors'] as List<Color>,
                  ),
                ),
                child: Stack(
                  children: [
                    Positioned(
                      right: -17,
                      top: -18,
                      child: Container(
                        width: 64,
                        height: 64,
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          color: Colors.white.withOpacity(0.12),
                        ),
                      ),
                    ),
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      mainAxisAlignment: MainAxisAlignment.end,
                      children: [
                        Text(
                          item['name'] as String,
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 13,
                            fontWeight: FontWeight.w900,
                          ),
                        ),
                        Text(
                          item['progress'] as String,
                          style: TextStyle(
                            color: Colors.white.withOpacity(0.8),
                            fontSize: 9,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
          ),
        );
      }).toList(),
    );
  }

  Widget _buildOfflineStatusCard() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: const Color(0x182F5D50)),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          const Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Offline-Paket aktuell',
                style: TextStyle(fontSize: 12, fontWeight: FontWeight.w800, color: AppColors.ink),
              ),
              SizedBox(height: 2),
              Text(
                'Zuletzt synchronisiert vor 3 Min.',
                style: TextStyle(fontSize: 10, color: AppColors.muted),
              ),
            ],
          ),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
            decoration: BoxDecoration(
              color: AppColors.mint,
              borderRadius: BorderRadius.circular(999),
            ),
            child: const Row(
              children: [
                Icon(Icons.cloud_done_rounded, size: 14, color: AppColors.forest),
                SizedBox(width: 4),
                Text(
                  'bereit',
                  style: TextStyle(
                    fontSize: 11,
                    fontWeight: FontWeight.w800,
                    color: AppColors.forest,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildProfileTab() {
    final username = _profile?.username ?? 'Alex';
    final email = _profile?.email ?? 'learner1@example.com';
    final roles = _profile?.roles?.join(', ') ?? 'Lernende';

    return SafeArea(
      child: Padding(
        padding: const EdgeInsets.all(20.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            const Text(
              'Mein Profil',
              style: TextStyle(fontSize: 24, fontWeight: FontWeight.w900, color: AppColors.ink),
            ),
            const SizedBox(height: 20),
            Container(
              padding: const EdgeInsets.all(18),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(20),
                border: Border.all(color: const Color(0x182F5D50)),
              ),
              child: Column(
                children: [
                  const CircleAvatar(
                    radius: 36,
                    backgroundColor: AppColors.mint,
                    child: Icon(Icons.person, size: 40, color: AppColors.forest),
                  ),
                  const SizedBox(height: 12),
                  Text(username, style: const TextStyle(fontSize: 18, fontWeight: FontWeight.w900)),
                  Text(email, style: const TextStyle(fontSize: 12, color: AppColors.muted)),
                  const SizedBox(height: 8),
                  Chip(
                    label: Text(roles),
                    backgroundColor: AppColors.mint,
                  ),
                ],
              ),
            ),
            const SizedBox(height: 20),
            ElevatedButton.icon(
              onPressed: () => widget.authService.logout(),
              icon: const Icon(Icons.logout),
              label: const Text('Abmelden'),
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.danger,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildBottomNav() {
    final items = [
      {'icon': Icons.home_rounded, 'label': 'Home'},
      {'icon': Icons.menu_book_rounded, 'label': 'Lernen'},
      {'icon': Icons.explore_rounded, 'label': 'Expedition'},
      {'icon': Icons.local_florist_rounded, 'label': 'Herbarium'},
      {'icon': Icons.person_rounded, 'label': 'Profil'},
    ];

    return Container(
      height: 69,
      decoration: const BoxDecoration(
        color: Colors.white,
        border: Border(top: BorderSide(color: AppColors.line)),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceAround,
        children: items.asMap().entries.map((entry) {
          final idx = entry.key;
          final item = entry.value;
          final isActive = _currentTabIndex == idx;

          return GestureDetector(
            onTap: () => setState(() => _currentTabIndex = idx),
            behavior: HitTestBehavior.opaque,
            child: SizedBox(
              width: 64,
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  if (isActive)
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 3),
                      decoration: BoxDecoration(
                        color: AppColors.mint,
                        borderRadius: BorderRadius.circular(10),
                      ),
                      child: Icon(
                        item['icon'] as IconData,
                        size: 20,
                        color: AppColors.forest,
                      ),
                    )
                  else
                    Icon(
                      item['icon'] as IconData,
                      size: 20,
                      color: const Color(0xFF7B837F),
                    ),
                  const SizedBox(height: 3),
                  Text(
                    item['label'] as String,
                    style: TextStyle(
                      fontSize: 9,
                      fontWeight: isActive ? FontWeight.w800 : FontWeight.w600,
                      color: isActive ? AppColors.forest : const Color(0xFF7B837F),
                    ),
                  ),
                ],
              ),
            ),
          );
        }).toList(),
      ),
    );
  }
}
