import 'dart:convert';
import 'package:http/http.dart' as http;
import '../config/api_config.dart';

class AuthService {
  Future<Map<String, dynamic>?> login(String correo, String password) async {
    final url = Uri.parse('$baseUrl/login/');
    final response = await http.post(
      url,
      headers: {'Content-type': 'application/json'},
      body: jsonEncode({'correo': correo, 'password': password}),
    );

    if (response.statusCode == 200) {
      final data = jsonDecode(response.body);
      return {
        'token': data['token'],
        'user': data['user'],
      };
    } else {
      print('Error al iniciar sesion: ${response.statusCode}');
      return null;
    }
  }

  Future<Map<String, dynamic>?> getUserProfile(String token) async {
    final url = Uri.parse('$baseUrl/perfil/');
    final response = await http.get(
      url,
      headers: {
        'Authorization': 'Token $token',
      },
    );

    if (response.statusCode == 200) {
      return json.decode(response.body);
    } else {
      print('Error al obtener perfil: ${response.statusCode}');
      print('Respuesta: ${response.body}');
      return null;
    }
  }

  Future<Map<String, dynamic>?> updateProfile(
      Map<String, dynamic> data, String token) async {
    final url = Uri.parse('$baseUrl/actualizar');
    final resp = await http.put(
      url,
      headers: {
        'Content-Type': 'application/json',
        'Authorization': 'Token $token'
      },
      body: jsonEncode(data),
    );
    if (resp.statusCode == 200) {
      return json.decode(resp.body)['usuario'] as Map<String, dynamic>;
    }
    return null;
  }
}
