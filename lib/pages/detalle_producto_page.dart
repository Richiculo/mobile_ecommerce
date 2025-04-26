import 'package:flutter/material.dart';
import 'package:mobile_ecommerce/models/producto_model.dart';
import 'package:mobile_ecommerce/pages/login_page.dart';
import 'package:mobile_ecommerce/providers/auth_provider.dart';
import 'package:mobile_ecommerce/providers/cart_provider.dart';
import 'package:provider/provider.dart';

class DetalleProductoPage extends StatelessWidget {
  final Producto product;

  const DetalleProductoPage({Key? key, required this.product})
      : super(key: key);

  @override
  Widget build(BuildContext context) {
    final double? precio = product.detalle?.precio;
    final double? descuento = product.descuento;
    final bool hasDiscount =
        precio != null && descuento != null && descuento > 0;
    final double? precioDescuento =
        hasDiscount ? precio * (1 - descuento / 100) : null;

    // Controlador de cantidad
    final TextEditingController cantidadController =
        TextEditingController(text: '1');

    return Scaffold(
      appBar: AppBar(
        title: Text(product.nombre),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Mostrar imagen principal
            if (product.imagenes.isNotEmpty)
              Image.network(
                product.imagenes.first,
                height: 220,
                width: double.infinity,
                fit: BoxFit.cover,
              )
            else
              Container(
                height: 220,
                width: double.infinity,
                color: Colors.grey[300],
                child: const Center(child: Icon(Icons.image_not_supported)),
              ),
            const SizedBox(height: 16),

            Text(
              product.nombre,
              style: Theme.of(context).textTheme.headlineSmall,
            ),
            const SizedBox(height: 8),
            Text(
              product.descripcion,
              style: Theme.of(context).textTheme.bodyMedium,
            ),
            const SizedBox(height: 16),

            if (hasDiscount) ...[
              Text(
                '\$${precio.toStringAsFixed(2)}',
                style: const TextStyle(
                  fontSize: 14,
                  color: Colors.grey,
                  decoration: TextDecoration.lineThrough,
                ),
              ),
              Text(
                '\$${precioDescuento!.toStringAsFixed(2)}',
                style: const TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                  color: Colors.red,
                ),
              ),
            ] else if (precio != null) ...[
              Text(
                '\$${precio.toStringAsFixed(2)}',
                style: const TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ] else ...[
              const Text("Precio no disponible"),
            ],

            const SizedBox(height: 16),

            // Campo para seleccionar cantidad
            Row(
              children: [
                const Text("Cantidad:"),
                IconButton(
                  icon: const Icon(Icons.remove),
                  onPressed: () {
                    if (int.tryParse(cantidadController.text) != null &&
                        int.parse(cantidadController.text) > 1) {
                      cantidadController.text =
                          (int.parse(cantidadController.text) - 1).toString();
                    }
                  },
                ),
                SizedBox(
                  width: 40,
                  child: TextField(
                    controller: cantidadController,
                    keyboardType: TextInputType.number,
                    textAlign: TextAlign.center,
                    decoration: const InputDecoration(
                      border: OutlineInputBorder(),
                    ),
                  ),
                ),
                IconButton(
                  icon: const Icon(Icons.add),
                  onPressed: () {
                    if (int.tryParse(cantidadController.text) != null) {
                      cantidadController.text =
                          (int.parse(cantidadController.text) + 1).toString();
                    }
                  },
                ),
              ],
            ),

            const Spacer(),

            Consumer2<AuthProvider, CartProvider>(
              builder: (context, auth, cart, _) {
                return SizedBox(
                  width: double.infinity,
                  child: ElevatedButton.icon(
                    icon: const Icon(Icons.shopping_cart),
                    label: const Text('Agregar al carrito'),
                    onPressed: () async {
                      if (!auth.isAuthenticated) {
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(
                            content:
                                Text('Inicia sesión para agregar al carrito'),
                          ),
                        );
                        Navigator.push(
                          context,
                          MaterialPageRoute(builder: (_) => const LoginPage()),
                        );
                      }

                      try {
                        // Se pasa solo el producto y la cantidad
                        await cart.addItem(
                            product.id, int.parse(cantidadController.text));
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(
                              content: Text('Producto agregado al carrito')),
                        );
                      } catch (e) {
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(
                              content: Text('Error al agregar al carrito')),
                        );
                      }
                    },
                  ),
                );
              },
            ),
          ],
        ),
      ),
    );
  }
}
