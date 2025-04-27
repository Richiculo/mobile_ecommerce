import 'dart:convert';
import 'package:http/http.dart' as http;
import '../../config/api_config.dart';

class SucursalesService {
  Future<List<Map<String, dynamic>>?> getSucursales() async {
    final url = Uri.parse('$baseUrl/sucursales/sucursales/');
    final resp = await http.get(url);
    if (resp.statusCode == 200) {
      final List<dynamic> decoded = json.decode(resp.body);
      return decoded.map((item) => item as Map<String, dynamic>).toList();
    }
    return null;
  }
}
