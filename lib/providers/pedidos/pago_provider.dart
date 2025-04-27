import 'package:flutter/material.dart';
import '../../services/pedidos/pago_service.dart';

class PagoProvider with ChangeNotifier {
  final PagoService _paymentService = PagoService();

  bool _isLoading = false;
  bool get isLoading => _isLoading;

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
}
