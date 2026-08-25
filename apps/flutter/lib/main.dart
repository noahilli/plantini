import 'package:flutter/material.dart';
import 'package:isar/isar.dart';
import 'package:path_provider/path_provider.dart';
import 'package:openapi/openapi.dart';
import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart' show kIsWeb, defaultTargetPlatform, TargetPlatform;
import 'storage/isar_collection.dart';
import 'storage/progress_service.dart';
import 'storage/offline_queue_service.dart';
import 'auth/auth_service.dart';
import 'ui/home_screen.dart';
import 'core/theme/app_theme.dart';

String getApiBaseUrl() {
  if (!kIsWeb && defaultTargetPlatform == TargetPlatform.android) {
    return 'http://10.0.2.2:1338/api';
  }
  return 'http://localhost:1338/api';
}

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  
  final authService = AuthService();
  late Isar isar;
  late ProgressService progressService;
  late OfflineQueueService queueService;
  late Openapi api;

  try {
    String dirPath = '';
    if (!kIsWeb) {
      final dir = await getApplicationDocumentsDirectory();
      dirPath = dir.path;
    }
    isar = await Isar.open(
      [PlantSchema, QuizProgressSchema, LevelProgressSchema, OfflineObservationSchema],
      directory: dirPath,
    );
    
    final dio = Dio(BaseOptions(baseUrl: getApiBaseUrl()));
    dio.interceptors.add(
      InterceptorsWrapper(
        onRequest: (options, handler) async {
          if (!options.headers.containsKey('Authorization')) {
            final token = await authService.getAccessToken();
            if (token != null) {
              options.headers['Authorization'] = 'Bearer $token';
            }
          }
          return handler.next(options);
        },
      ),
    );
    
    api = Openapi(dio: dio);
    final initialToken = await authService.getAccessToken();
    if (initialToken != null) {
      api.setBearerAuth('bearerAuth', initialToken);
    }
    
    progressService = ProgressService(isar);
    queueService = OfflineQueueService(isar, api);
  } catch (e) {
    debugPrint('Initialization failed: $e');
  }

  runApp(PlantiniApp(
    authService: authService, 
    progressService: progressService,
    queueService: queueService,
    api: api,
  ));
}

class PlantiniApp extends StatelessWidget {
  final AuthService authService;
  final ProgressService progressService;
  final OfflineQueueService queueService;
  final Openapi api;
  
  const PlantiniApp({
    super.key, 
    required this.authService, 
    required this.progressService,
    required this.queueService,
    required this.api,
  });

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Plantini',
      theme: AppTheme.lightTheme,
      darkTheme: AppTheme.darkTheme,
      themeMode: ThemeMode.system,
      home: AuthWrapper(
        authService: authService, 
        progressService: progressService,
        queueService: queueService,
        api: api,
      ),
    );
  }
}

class AuthWrapper extends StatefulWidget {
  final AuthService authService;
  final ProgressService? progressService;
  final OfflineQueueService? queueService;
  final Openapi? api;
  
  const AuthWrapper({
    super.key, 
    required this.authService, 
    this.progressService,
    this.queueService,
    this.api,
  });

  @override
  State<AuthWrapper> createState() => _AuthWrapperState();
}

class _AuthWrapperState extends State<AuthWrapper> {
  @override
  void initState() {
    super.initState();
    widget.authService.processRedirect();
  }

  @override
  Widget build(BuildContext context) {
    return ListenableBuilder(
      listenable: widget.authService,
      builder: (context, _) {
        if (widget.authService.isAuthenticated) {
          return HomeScreen(
            authService: widget.authService, 
            progressService: widget.progressService,
            queueService: widget.queueService,
            api: widget.api,
          );
        }
        return Scaffold(
          appBar: AppBar(title: const Text('Plantini Login')),
          body: Center(
            child: ElevatedButton(
              onPressed: () => widget.authService.login(),
              child: const Text('Login with Keycloak'),
            ),
          ),
        );
      },
    );
  }
}
