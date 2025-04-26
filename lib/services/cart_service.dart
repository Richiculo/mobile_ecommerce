import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import '../config/api_config.dart';
import '../models/producto_model.dart';

class CartService {
  final storage = const FlutterSecureStorage();

  Future<String?> _getToken() async {
    return await storage.read(key: 'token');
  }

  Future<String?> _getUserId() async {
    return await storage.read(key: 'user_id');
  }

  Future<Map<String, dynamic>> fetchCartAndItems() async {
    final token = await _getToken();
    final usuarioId = await _getUserId();

    final cartResponse = await http.get(
      Uri.parse('${baseUrl}/pedidos/carts/?usuario_id=$usuarioId'),
      headers: {
        'Authorization': 'Token $token',
        'Content-Type': 'application/json',
      },
    );

    if (cartResponse.statusCode == 200) {
      final List cartList = json.decode(cartResponse.body);

      final activeCart = cartList.firstWhere(
        (cart) => cart['estado'] == 'activo',
        orElse: () => null,
      );

      if (activeCart != null) {
        final itemResponse = await http.get(
          Uri.parse(
              '${baseUrl}/pedidos/itemcarts/?cart_id=${activeCart['id']}'),
          headers: {
            'Authorization': 'Token $token',
            'Content-Type': 'application/json',
          },
        );

        if (itemResponse.statusCode == 200) {
          final List itemList = json.decode(itemResponse.body);
          final items = itemList.map((item) {
            return {
              'id': item['id'],
              'producto': item['producto_detalle'],
              'cantidad': item['cantidad'],
              'precio_unitario': item['precio_unitario'],
            };
          }).toList();

          return {
            'cart': activeCart,
            'items': items,
          };
        } else {
          throw Exception('Error al obtener los items del carrito');
        }
      } else {
        throw Exception('No se encontró un carrito activo');
      }
    } else {
      throw Exception('Error al obtener el carrito');
    }
  }

  Future<void> deleteCartItem(int productoId) async {
    final token = await _getToken();
    final url = Uri.parse('${baseUrl}/pedidos/itemcarts/$productoId/');

    final response = await http.delete(
      url,
      headers: {
        'Authorization': 'Token $token',
        'Content-Type': 'application/json',
      },
    );

    if (response.statusCode != 204) {
      throw Exception('Error al eliminar el item del carrito');
    }
  }

  Future<void> addCartItem({
    required int productoId,
    required int cantidad,
  }) async {
    final token = await _getToken();
    print(productoId);
    final url = Uri.parse('${baseUrl}/pedidos/itemcarts/');

    final response = await http.post(url,
        headers: {
          'Authorization': 'Token $token',
          'Content-Type': 'application/json',
        },
        body: jsonEncode({
          'producto': productoId,
          'cantidad': cantidad,
        }));

    if (response.statusCode != 201) {
      throw Exception('Error al agregar producto al carrito');
    }
  }
}
