import 'package:flutter/material.dart';
import 'package:openapi/openapi.dart';
import 'package:dio/dio.dart';
import '../auth/auth_service.dart';
import '../main.dart' show getApiBaseUrl;
import 'ecosystem/ecosystem_list_screen.dart';

import '../storage/progress_service.dart';
import '../storage/offline_queue_service.dart';
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
  UserProfile? _profile;
  List<Ecosystem>? _ecosystems;
  bool _isLoading = true;
  String? _error;

  @override
  void initState() {
    super.initState();
    // Use injected api or fallback for safety
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
        _ecosystems = ecosystemRes.data?.toList();
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
      appBar: AppBar(
        title: const Text('Plantini Home'),
        actions: [
          IconButton(
            icon: const Icon(Icons.logout),
            onPressed: () => widget.authService.logout(),
          )
        ],
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : _error != null
              ? Center(
                  child: Padding(
                    padding: const EdgeInsets.all(24.0),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        const Icon(Icons.error_outline, size: 48, color: Colors.red),
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
              : ListView(
                  children: [
                    if (_profile != null)
                      ListTile(
                        leading: const Icon(Icons.person),
                        title: Text('Welcome, ${_profile?.username}'),
                        subtitle: Text('Email: ${_profile?.email ?? "-"}'),
                      ),
                    const Divider(),
                    ListTile(
                      leading: const Icon(Icons.local_florist, color: Colors.green),
                      title: const Text('Mein Herbarium'),
                      trailing: const Icon(Icons.chevron_right),
                      onTap: () {
                        if (widget.queueService != null) {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (_) => HerbariumScreen(queueService: widget.queueService!),
                            ),
                          );
                        }
                      },
                    ),
                    const Divider(),
                    const Padding(
                      padding: EdgeInsets.all(16.0),
                      child: Text('Ecosystems', style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
                    ),
                    if (_ecosystems != null)
                      EcosystemListScreen(
                        ecosystems: _ecosystems!, 
                        api: api,
                        progressService: widget.progressService,
                      ),
                  ],
                ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () {
          Navigator.push(
            context,
            MaterialPageRoute(builder: (_) => IdentifyScreen(queueService: widget.queueService)),
          );
        },
        icon: const Icon(Icons.camera_alt),
        label: const Text('Expedition'),
      ),
    );
  }
}
