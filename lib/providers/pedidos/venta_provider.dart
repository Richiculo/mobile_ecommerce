import 'package:flutter/material.dart';
import '../../services/pedidos/venta_service.dart';

class VentaProvider with ChangeNotifier {
  final VentaService _ventaService = VentaService();

  bool _isProcessing = false;
  bool get isProcessing => _isProcessing;

  Map<String, dynamic>? _venta;
  Map<String, dynamic>? get venta => _venta;

  List<Map<String, dynamic>>? _ventas;
  List<Map<String, dynamic>>? get ventas => _ventas;
  List<Map<String, dynamic>>? _dventas;
  List<Map<String, dynamic>>? get dventas => _dventas;

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

  Future<void> obtenerVentas() async {
    try {
      _isProcessing = true;
      notifyListeners();
      _ventas = await _ventaService.getVentasUser();
      if (_ventas == null) {
        print('No hay ventas');
      }
      notifyListeners();
    } catch (e) {
      _ventas = null;
      notifyListeners();
      rethrow;
    } finally {
      _isProcessing = false;
      notifyListeners();
    }
  }

  Future<void> obtenerDetalleVenta(int ventaId) async {
    try {
      _isProcessing = true;
      notifyListeners();
      _dventas = await _ventaService.getDetalleVenta(ventaId);
      if (_dventas == null) {
        print('No hay detalle de la venta');
      }
      notifyListeners();
    } catch (e) {
      _dventas = null;
      notifyListeners();
      rethrow;
    } finally {
      _isProcessing = false;
      notifyListeners();
    }
  }
}
