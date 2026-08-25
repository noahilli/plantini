import 'package:flutter/foundation.dart';
import 'package:openid_client/openid_client.dart';
import 'auth_platform_io.dart' if (dart.library.html) 'auth_platform_web.dart';

class AuthService extends ChangeNotifier {
  final String clientId = 'plantini-flutter';
  
  // Note: On Android emulator, localhost is 10.0.2.2; on iOS simulator and Web it is localhost.
  String get issuerUrl {
    if (!kIsWeb && defaultTargetPlatform == TargetPlatform.android) {
      return 'http://10.0.2.2:8082/realms/plantini';
    }
    return 'http://localhost:8082/realms/plantini';
  }
  
  Credential? _credential;
  bool get isAuthenticated => _credential != null;
  
  final _helper = getAuthPlatformHelper();

  Future<void> login() async {
    final cred = await _helper.login(
      issuerUrl,
      clientId,
      const ['openid', 'profile', 'email'],
    );
    if (cred != null) {
      _credential = cred;
      notifyListeners();
    }
  }

  Future<void> processRedirect() async {
    final cred = await _helper.processRedirect(
      issuerUrl,
      clientId,
      const ['openid', 'profile', 'email'],
    );
    if (cred != null) {
      _credential = cred;
      notifyListeners();
    }
  }

  Future<void> logout() async {
    _credential = null;
    notifyListeners();
  }
}
