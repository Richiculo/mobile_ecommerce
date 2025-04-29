import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import '../../config/api_config.dart';

class VentaService {
  final storage = const FlutterSecureStorage();

  Future<String?> _getToken() async {
    return await storage.read(key: 'token');
  }

  Future<String?> _getUserId() async {
    return await storage.read(key: 'user_id');
  }

  Future<void> crearVenta(
      {required int cartId,
      required double total,
      required int metodoPagoId,
      required bool esDelivery,
      int? direccionId,
      required sucursalId}) async {
    final token = await _getToken();
    final usuarioId = await _getUserId();

    final url = Uri.parse('${baseUrl}/pedidos/venta/');

    final Map<String, dynamic> body = {
      'carrito': cartId,
      'usuario': int.parse(usuarioId!),
      'total': double.parse(total.toString()),
      'metodo_pago_id': metodoPagoId,
      'es_delivery': esDelivery,
      'direccion_id': direccionId,
      'sucursal_id': sucursalId
    };

    if (esDelivery && direccionId != null) {
      body['direccion'] = direccionId;
    }

    final response = await http.post(
      url,
      headers: {
        'Authorization': 'Token $token',
        'Content-Type': 'application/json',
      },
      body: jsonEncode(body),
    );

    if (response.statusCode != 201) {
      throw Exception('Error al crear la venta: ${response.body}');
    }
  }

  Future<Map<String, dynamic>?> getVenta() async {
    final token = await _getToken();
    final url = Uri.parse('$baseUrl/pedidos/venta/venta-pendiente/');
    final response = await http.get(
      url,
      headers: {
        'Authorization': 'Token $token',
        'Content-Type': 'application/json',
      },
    );
    if (response.statusCode == 200) {
      return jsonDecode(response.body);
    } else {
      print('Error al obtener la venta pendiente: ${response.body}');
      return null;
    }
  }

  Future<List<Map<String, dynamic>>?> getVentasUser() async {
    final token = await _getToken();
    final usuarioId = await _getUserId();
    final url = Uri.parse('$baseUrl/pedidos/venta/?usuario_id=$usuarioId');
    final res = await http.get(url, headers: {
      'Authorization': 'Token $token',
      'Content-Type': 'application/json',
    });
    if (res.statusCode == 200) {
      final List<dynamic> decoded = jsonDecode(res.body);
      return decoded.map((item) => item as Map<String, dynamic>).toList();
    } else {
      print('Error al obtener las ventas: ${res.body}');
      return null;
    }
  }

  Future<List<Map<String, dynamic>>?> getDetalleVenta(int ventaId) async {
    final url = Uri.parse('$baseUrl/pedidos/detalle-venta/?venta_id=$ventaId');
    final res = await http.get(url);
    if (res.statusCode == 200) {
      final List<dynamic> decoded = jsonDecode(res.body);
      return decoded.map((detalle) => detalle as Map<String, dynamic>).toList();
    } else {
      print('Error al obtener los detalles de la venta: ${res.body}');
      return null;
    }
  }
}
