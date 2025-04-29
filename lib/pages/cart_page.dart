import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/pedidos/cart_provider.dart';
import '../pages/venta_page.dart';
import '../pages/detalle_producto_page.dart';
import '../models/producto_model.dart';
import '../utils/voice_dale_helper.dart';

class CartPage extends StatefulWidget {
  const CartPage({super.key});

  @override
  State<CartPage> createState() => _CartPageState();
}

class _CartPageState extends State<CartPage> {
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadCart();
  }

  Future<void> _loadCart() async {
    await Provider.of<CartProvider>(context, listen: false).loadCart();
    await Provider.of<CartProvider>(context, listen: false)
        .obtenerRecomendaciones();
    setState(() {
      _isLoading = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    final cartProvider = Provider.of<CartProvider>(context);
    final cartItems = cartProvider.cartItems;
    final recomendaciones = cartProvider.recomendaciones;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Mi Carrito'),
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : cartItems.isEmpty
              ? const Center(child: Text('Tu carrito está vacío.'))
              : Column(
                  children: [
                    Expanded(
                      child: ListView.builder(
                        itemCount: cartItems.length,
                        itemBuilder: (context, index) {
                          final item = cartItems[index];
                          final producto = item['producto'];
                          final cantidad = item['cantidad'];
                          final imagenes =
                              producto['imagenes'] as List<dynamic>? ?? [];

                          return Card(
                            margin: const EdgeInsets.symmetric(
                                horizontal: 12, vertical: 6),
                            child: ListTile(
                              leading: imagenes.isNotEmpty
                                  ? Image.network(
                                      imagenes.first,
                                      width: 50,
                                      height: 50,
                                      fit: BoxFit.cover,
                                    )
                                  : const Icon(Icons.shopping_cart),
                              title: Text(producto['nombre']),
                              subtitle: Text('Cantidad: $cantidad'),
                              trailing: IconButton(
                                icon:
                                    const Icon(Icons.delete, color: Colors.red),
                                onPressed: () {
                                  cartProvider.removeItem(item['id']);
                                },
                              ),
                            ),
                          );
                        },
                      ),
                    ),

                    const SizedBox(height: 20),

                    // ------------------- "Te podría interesar" -------------------
                    if (recomendaciones.isNotEmpty)
                      Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 12),
                        child: Text(
                          'Te podría interesar',
                          style: Theme.of(context).textTheme.titleLarge,
                        ),
                      ),
                    if (recomendaciones.isNotEmpty)
                      SizedBox(
                        height: 250,
                        child: ListView.builder(
                          scrollDirection: Axis.horizontal,
                          itemCount: recomendaciones.length,
                          itemBuilder: (context, index) {
                            final recomendacion = recomendaciones[index];
                            final detalle = recomendacion['detalle'] ?? {};

                            final producto = Producto(
                              id: recomendacion['id'],
                              nombre: recomendacion['nombre'] ?? '',
                              descripcion: recomendacion['descripcion'] ?? '',
                              proveedor: recomendacion['proveedor'] ?? '',
                              descuento: recomendacion['descuento']?.toDouble(),
                              imagenes:
                                  (recomendacion['imagenes'] as List<dynamic>?)
                                          ?.map((img) => img.toString())
                                          .toList() ??
                                      [],
                              stockTotal: recomendacion['stock_total'] ?? 0,
                              estaDisponible:
                                  recomendacion['esta_disponible'] ?? true,
                              detalle: detalle.isNotEmpty
                                  ? Detalle(
                                      precio:
                                          detalle['precio']?.toDouble() ?? 0.0,
                                      marca: detalle['marca'] ?? '',
                                    )
                                  : null,
                              categorias: (recomendacion['categorias']
                                          as List<dynamic>?)
                                      ?.map((cat) => Categoria.fromJson(cat))
                                      .toList() ??
                                  [],
                            );

                            return GestureDetector(
                              onTap: () {
                                Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                    builder: (context) =>
                                        DetalleProductoPage(product: producto),
                                  ),
                                );
                              },
                              child: Container(
                                width: 180,
                                margin: const EdgeInsets.all(8),
                                decoration: BoxDecoration(
                                  color: Colors.white,
                                  borderRadius: BorderRadius.circular(16),
                                  boxShadow: [
                                    BoxShadow(
                                      color: Colors.black12,
                                      blurRadius: 6,
                                      offset: const Offset(0, 2),
                                    ),
                                  ],
                                ),
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Expanded(
                                      child: producto.imagenes.isNotEmpty
                                          ? ClipRRect(
                                              borderRadius:
                                                  const BorderRadius.vertical(
                                                      top: Radius.circular(16)),
                                              child: Image.network(
                                                producto.imagenes.first,
                                                fit: BoxFit.cover,
                                                width: double.infinity,
                                              ),
                                            )
                                          : Container(
                                              decoration: BoxDecoration(
                                                color: Colors.grey[200],
                                                borderRadius: const BorderRadius
                                                    .vertical(
                                                    top: Radius.circular(16)),
                                              ),
                                              child: const Center(
                                                child: Icon(Icons.image,
                                                    size: 50,
                                                    color: Colors.grey),
                                              ),
                                            ),
                                    ),
                                    Padding(
                                      padding: const EdgeInsets.all(8.0),
                                      child: Column(
                                        crossAxisAlignment:
                                            CrossAxisAlignment.start,
                                        children: [
                                          Text(
                                            producto.nombre,
                                            style: const TextStyle(
                                                fontWeight: FontWeight.bold),
                                            maxLines: 2,
                                            overflow: TextOverflow.ellipsis,
                                          ),
                                          const SizedBox(height: 4),
                                          Text(
                                            'Bs ${producto.detalle?.precio.toStringAsFixed(2) ?? ''}',
                                            style: const TextStyle(
                                                color: Colors.green),
                                          ),
                                        ],
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            );
                          },
                        ),
                      ),

                    const SizedBox(height: 20),

                    Container(
                      padding: const EdgeInsets.all(12),
                      width: double.infinity,
                      child: ElevatedButton.icon(
                        onPressed: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                                builder: (context) => const VentaPage()),
                          );
                        },
                        icon: const Icon(Icons.payment),
                        label: const Text('Finalizar compra'),
                      ),
                    ),
                  ],
                ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          VoiceSaleHelper().iniciarComandoVenta(context, () {
            Navigator.push(
              context,
              MaterialPageRoute(builder: (context) => const VentaPage()),
            );
          });
        },
        child: const Icon(Icons.mic),
        tooltip: 'Comando por voz',
      ),
    );
  }
}
