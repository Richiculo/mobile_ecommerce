import 'dart:convert';
import 'package:http/http.dart' as http;
import '../../config/api_config.dart';

class DireccionService {
  Future<Map<String, dynamic>?> createDireccion(
      Map<String, dynamic> data, String token) async {
    final url = Uri.parse('$baseUrl/direcciones');
    final resp = await http.post(
      url,
      headers: {
        'Content-Type': 'application/json',
        'Authorization': 'Token $token'
      },
      body: jsonEncode(data),
    );
    if (resp.statusCode == 201)
      return json.decode(resp.body) as Map<String, dynamic>;
    return null;
  }

  Future<Map<String, dynamic>?> updateDireccion(
      int id, Map<String, dynamic> data, String token) async {
    final url = Uri.parse('$baseUrl/direcciones/$id/');
    final resp = await http.put(
      url,
      headers: {
        'Content-Type': 'application/json',
        'Authorization': 'Token $token'
      },
      body: jsonEncode(data),
    );
    if (resp.statusCode == 200)
      return json.decode(resp.body) as Map<String, dynamic>;
    return null;
  }

  Future<Map<String, dynamic>?> getDir(int direccionId) async {
    final url = Uri.parse('$baseUrl/direcciones/$direccionId/');
    final response = await http.get(url);

    if (response.statusCode == 200) {
      return json.decode(response.body);
    } else {
      print('Error al obtener direccion: ${response.statusCode}');
      print('Respuesta: ${response.body}');
      return null;
    }
  }
}
