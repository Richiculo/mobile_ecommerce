import 'package:flutter/widgets.dart';
import '../../services/envios/envio_service.dart';

class EnviosProvider with ChangeNotifier {
  final EnvioService _envioService = EnvioService();
  bool _isLoading = false;
  bool get isLoading => _isLoading;

  List<Map<String, dynamic>>? _envios;
  List<Map<String, dynamic>>? get envios => _envios;

  Future<void> obtenerEnvios() async {
    try {
      _isLoading = true;
      notifyListeners();
      _envios = await _envioService.getEnvios();
      if (_envios == null) {
        print('No hay envios');
      }
      notifyListeners();
    } catch (e) {
      _envios = null;
      notifyListeners();
      rethrow;
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }
}
