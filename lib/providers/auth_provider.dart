import 'package:flutter/material.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import '../services/auth_service.dart';

class AuthProvider with ChangeNotifier {
  final _storage = const FlutterSecureStorage();
  final _authService = AuthService();

  String? _token;
  bool _loading = true;

  String? get token => _token;
  bool get isAuthenticated => _token != null;
  bool get isLoading => _loading;

  AuthProvider() {
    _loadToken();
  }

  Future<void> _loadToken() async {
    _token = await _storage.read(key: 'token');
    _loading = false;
    notifyListeners();
  }

  Map<String, dynamic>? _user;

  Map<String, dynamic>? get user => _user;

  Future<bool> login(String correo, String password) async {
    final data = await _authService.login(correo, password);
    if (data != null) {
      _token = data['token'];
      _user = data['user'];
      await _storage.write(key: 'token', value: token);
      notifyListeners();
      return true;
    }
    return false;
  }

  Future<void> logout() async {
    _token = null;
    await _storage.delete(key: 'token');
    notifyListeners();
  }

  Future<void> checkLoginStatus() async {
    final storedToken = await _storage.read(key: 'auth_token');
    if (storedToken != null) {
      _token = storedToken;
      notifyListeners();
    }
  }
}
