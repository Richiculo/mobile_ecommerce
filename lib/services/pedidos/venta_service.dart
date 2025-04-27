import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:mobile_ecommerce/models/user_model.dart';
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
      'metodo_pago': metodoPagoId,
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
}
