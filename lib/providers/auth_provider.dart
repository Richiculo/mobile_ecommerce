import 'package:flutter/material.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import '../services/auth_service.dart';
import '../services/direccion_service.dart';

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
    print('Token leído: $_token');
    if (_token != null) {
      _user = await _authService.getUserProfile(_token!);
    } else {
      print('Token no encontrado');
    }
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
      await _storage.write(key: 'token', value: _token);
      print('Token guardado: $_token');
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
    _token = await _storage.read(key: 'token');
    if (_token != null) {
      _user = await _authService.getUserProfile(_token!);
      notifyListeners();
    }

    _loading = false;
    notifyListeners();
  }

  Future<bool> updateUser(Map<String, dynamic> nuevosDatos) async {
    if (_token == null) return false;
    final updated = await _authService.updateProfile(nuevosDatos, _token!);
    if (updated != null) {
      _user = updated;
      notifyListeners();
      return true;
    }
    return false;
  }

  final _direccionService = DireccionService();

  Future<bool> addDireccion(Map<String, dynamic> datosDireccion) async {
    if (_token == null) return false;
    final nuevaDir =
        await _direccionService.createDireccion(datosDireccion, _token!);
    if (nuevaDir != null && nuevaDir['id'] != null) {
      // luego asociamos al usuario:
      final asociado = await updateUser({'direccion': nuevaDir['id']});
      return asociado;
    }
    return false;
  }

  Future<bool> updateDireccion(Map<String, dynamic> data) async {
    try {
      final id = user!['direccion']['id'];
      final updated =
          await _direccionService.updateDireccion(id, data, _token!);
      if (updated != null) {
        user!['direccion'] = updated;
        notifyListeners();
        return true;
      }
      return false;
    } catch (_) {
      return false;
    }
  }
}
