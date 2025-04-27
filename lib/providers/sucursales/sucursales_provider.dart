import 'package:flutter/material.dart';
import '../../services/sucursales/sucursales_services.dart';

class SucursalesProvider with ChangeNotifier {
  List<Map<String, dynamic>> _sucursales = [];
  List<Map<String, dynamic>> get sucursales => _sucursales;
  bool isLoading = true;
  final _sucursalesService = SucursalesService();
  Future<bool> getSucursalesP() async {
    try {
      isLoading = true;
      final res = await _sucursalesService.getSucursales();
      if (res != null) {
        _sucursales = res;
        isLoading = false;
        notifyListeners();
        return true;
      }
      return false;
    } catch (e) {
      debugPrint('Error al cargar las sucursales: $e');
      isLoading = false;
      notifyListeners();
      return false;
    }
  }
}
