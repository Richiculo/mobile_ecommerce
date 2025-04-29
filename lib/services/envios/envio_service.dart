import '../../config/api_config.dart';
import 'package:http/http.dart' as http;
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'dart:convert';

class EnvioService {
  final url = Uri.parse('$baseUrl/envios/');
  final storage = FlutterSecureStorage();

  Future<String?> _getToken() async {
    return await storage.read(key: 'token');
  }

  Future<List<Map<String, dynamic>>?> getEnvios() async {
    final token = await _getToken();
    final res = await http.get(url, headers: {
      'Authorization': 'Token $token',
      'Content-Type': 'application/json',
    });
    if (res.statusCode == 200) {
      final List<dynamic> decoded = jsonDecode(res.body);
      return decoded.map((item) => item as Map<String, dynamic>).toList();
    } else {
      print('Error al obtener los envios: ${res.body}');
      return null;
    }
  }
}
