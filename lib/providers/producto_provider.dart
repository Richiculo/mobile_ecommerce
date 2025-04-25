import 'package:flutter/material.dart';
import '../models/producto_model.dart';
import '../services/producto_service.dart';

class ProductoProvider with ChangeNotifier {
  final ProductoService _service = ProductoService();

  List<Producto> _productos = [];
  bool _isLoading = false;

  List<Producto> get productos => _productos;
  bool get isLoading => _isLoading;

  Future<void> cargarProductos() async {
    _isLoading = true;
    notifyListeners();

    try {
      _productos = await _service.obtenerProductos();
    } catch (e) {
      print('Error al cargar productos: $e');
    }

    _isLoading = false;
    notifyListeners();
  }

  List<Producto> productosPorCategoria(String categoria) {
    return _productos
        .where((p) => p.categorias
            .any((cat) => cat.nombre.toLowerCase() == categoria.toLowerCase()))
        .toList();
  }

  List<Producto> productosEnDescuento() {
    return _productos.where((p) => p.descuento != null).toList();
  }
}
