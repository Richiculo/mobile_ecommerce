import 'package:flutter/material.dart';
import '../../services/pedidos/cart_service.dart';
import '../../models/cart_model.dart';

class CartProvider with ChangeNotifier {
  final CartService _cartService = CartService();
  List<dynamic> _cartItems = [];
  Cart? _cart;
  List<dynamic> get cartItems => _cartItems;
  List<Map<String, dynamic>> _recomendaciones = [];
  List<Map<String, dynamic>> get recomendaciones => _recomendaciones;
  bool _isLoading = false;
  bool get isLoading => _isLoading;

  Cart? get cart => _cart;

  int? get cartId => _cart?.id;

  Future<void> loadCart() async {
    try {
      final data = await _cartService.fetchCartAndItems();
      _cartItems = data['items'];
      _cart = Cart.fromJson(data['cart']);
      notifyListeners();
    } catch (e) {
      debugPrint('Error al cargar el carrito: $e');
    }
  }

  void clearCart() {
    _cartItems = [];
    notifyListeners();
  }

  Future<void> removeItem(int productoId) async {
    try {
      await _cartService.deleteCartItem(productoId);
      _cartItems.removeWhere((item) => item['id'] == productoId);
      notifyListeners();
    } catch (e) {
      debugPrint('Error al eliminar un itme del carrito: $e');
    }
  }

  Future<void> addItem(int productoId, int cantidad) async {
    try {
      await _cartService.addCartItem(
          productoId: productoId, cantidad: cantidad);
      await loadCart();
    } catch (e) {
      debugPrint('Error al agregar item: $e');
    }
  }

  Future<void> obtenerRecomendaciones() async {
    _isLoading = true;
    notifyListeners();
    try {
      final data = await _cartService.getRecomendaciones();
      if (data != null) {
        _recomendaciones = data;
      } else {
        _recomendaciones = [];
      }
    } catch (e) {
      print('Error en fetchRecomendaciones: $e');
      _recomendaciones = [];
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }
}
