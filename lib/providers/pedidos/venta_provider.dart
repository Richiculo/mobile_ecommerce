import 'package:flutter/material.dart';
import '../../services/pedidos/venta_service.dart';

class VentaProvider with ChangeNotifier {
  final VentaService _ventaService = VentaService();

  bool _isProcessing = false;
  bool get isProcessing => _isProcessing;

  Map<String, dynamic>? _venta;
  Map<String, dynamic>? get venta => _venta;

  Future<void> realizarVenta(
      {required int cartId,
      required double total,
      required int metodoPagoId,
      required bool esDelivery,
      int? direccionId,
      required int? sucursalId}) async {
    _isProcessing = true;
    notifyListeners();

    try {
      await _ventaService.crearVenta(
          cartId: cartId,
          total: total,
          metodoPagoId: metodoPagoId,
          esDelivery: esDelivery,
          direccionId: direccionId,
          sucursalId: sucursalId);
    } finally {
      _isProcessing = false;
      notifyListeners();
    }
  }

  Future<void> obtenerVentaPendiente() async {
    _isProcessing = true;
    notifyListeners();
    try {
      _venta = await _ventaService.getVenta();
      if (_venta == null) {
        print('No hay venta pendiente');
      } else {
        print('Venta pendiente encontrada: $_venta');
      }
      notifyListeners();
    } catch (e) {
      _venta = null;
      notifyListeners();
      rethrow;
    } finally {
      _isProcessing = false;
      notifyListeners();
    }
  }
}
