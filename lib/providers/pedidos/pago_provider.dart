import 'package:flutter/material.dart';
import '../../services/pedidos/pago_service.dart';

class PagoProvider with ChangeNotifier {
  final PagoService _paymentService = PagoService();

  bool _isLoading = false;
  bool get isLoading => _isLoading;

  List<Map<String, dynamic>> _metodosPago = [];
  List<Map<String, dynamic>> get metodosPago => _metodosPago;

  Future<String?> createIntent(int amount) async {
    try {
      _isLoading = true;
      notifyListeners();
      final clientSecret = await _paymentService.createPaymentIntent(amount);
      _isLoading = false;
      notifyListeners();
      return clientSecret;
    } catch (e) {
      _isLoading = false;
      notifyListeners();
      rethrow;
    }
  }

  Future<void> confirmar(String pagoId, {String? referencia}) async {
    try {
      _isLoading = true;
      notifyListeners();
      await _paymentService.confirmarPago(pagoId, referencia: referencia);
      _isLoading = false;
      notifyListeners();
    } catch (e) {
      _isLoading = false;
      notifyListeners();
      rethrow;
    }
  }

  Future<bool> obtenerMetodosPago() async {
    try {
      _isLoading = true;
      final res = await _paymentService.getMetodosPago();
      if (res != null) {
        _metodosPago = res;
        _isLoading = false;
        notifyListeners();
        return true;
      }
      return false;
    } catch (e) {
      debugPrint('Error al cargar los metodos de pago: $e');
      _isLoading = false;
      notifyListeners();
      return false;
    }
  }
}
