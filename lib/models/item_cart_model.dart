import '../models/producto_model.dart';

class ItemCart {
  final int id;
  final Producto producto;
  final int cantidad;
  final double precioUnitario;

  ItemCart({
    required this.id,
    required this.producto,
    required this.cantidad,
    required this.precioUnitario,
  });

  factory ItemCart.fromJson(Map<String, dynamic> json) {
    // El campo "producto" ya es una instancia de Producto, no necesitas deserializarlo
    return ItemCart(
      id: json['id'],
      producto: Producto.fromJson(
          json['producto']), // Asumimos que "producto" es un Map
      cantidad: json['cantidad'],
      precioUnitario: (json['precio_unitario'] as num).toDouble(),
    );
  }

  Map<String, dynamic> toJson() => {
        'producto': producto.id,
        'cantidad': cantidad,
      };
}
