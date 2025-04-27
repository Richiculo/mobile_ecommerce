import 'dart:convert';
import 'package:http/http.dart' as http;
import '../../models/producto_model.dart';
import '../../config/api_config.dart';

class ProductoService {
  final url = Uri.parse('${baseUrl}/productos/productos/');
  Future<List<Producto>> obtenerProductos() async {
    final response = await http.get(url);

    if (response.statusCode == 200) {
      final List data = json.decode(response.body);
      return data.map((item) => Producto.fromJson(item)).toList();
    } else {
      throw Exception('Error al obtener productos');
    }
  }
}
