import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import '../../config/api_config.dart';

class PagoService {
  final storage = const FlutterSecureStorage();

  Future<String?> createPaymentIntent(int amount) async {
    final token = await storage.read(key: 'token');

    final response = await http.post(
      Uri.parse('$baseUrl/pedidos/pago/crear-intencion-pago/'),
      headers: {
        'Authorization': 'Token $token',
        'Content-Type': 'application/json',
      },
      body: json.encode({
        'amount': amount, // Monto en centavos
        'currency': 'usd', // o 'bs' si prefieres
      }),
    );

    if (response.statusCode == 200) {
      final data = json.decode(response.body);
      return data['client_secret'];
    } else {
      throw Exception('Error al crear intent de pago: ${response.body}');
    }
  }

  Future<void> confirmarPago(String pagoId, {String? referencia}) async {
    final token = await storage.read(key: 'token');

    final response = await http.post(
      Uri.parse('$baseUrl/pedidos/$pagoId/confirmar_pago/'),
      headers: {
        'Authorization': 'Token $token',
        'Content-Type': 'application/json',
      },
      body: json.encode({
        'referencia': referencia ?? 'Pago desde Flutter',
      }),
    );

    if (response.statusCode != 200) {
      throw Exception('Error al confirmar pago: ${response.body}');
    }
  }
}
