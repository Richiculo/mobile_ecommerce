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
}
