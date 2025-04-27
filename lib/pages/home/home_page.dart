import 'package:flutter/material.dart';
import 'package:mobile_ecommerce/pages/login_page.dart';
import 'package:mobile_ecommerce/providers/auth/auth_provider.dart';
import 'package:mobile_ecommerce/providers/pedidos/cart_provider.dart';
import 'package:provider/provider.dart';
import '../../providers/productos/producto_provider.dart';
import '../perfil/perfil_page.dart';
import '../cart_page.dart';
import '../detalle_producto_page.dart';

class HomePage extends StatelessWidget {
  const HomePage({super.key});

  @override
  Widget build(BuildContext context) {
    final productoProvider = Provider.of<ProductoProvider>(context);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Tienda Electroshit'),
        foregroundColor: Colors.blueAccent,
        actions: [
          Consumer2<AuthProvider, CartProvider>(
            builder: (context, auth, cart, _) {
              return IconButton(
                icon: const Icon(Icons.shopping_cart),
                onPressed: () {
                  if (auth.isAuthenticated) {
                    Navigator.push(
                      context,
                      MaterialPageRoute(builder: (_) => const CartPage()),
                    );
                  } else {
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(
                          content: Text(
                              'Debes iniciar sesión para ver el carrito.')),
                    );
                  }
                },
              );
            },
          ),
          Consumer<AuthProvider>(
            builder: (context, auth, _) {
              return IconButton(
                onPressed: () {
                  if (auth.isAuthenticated) {
                    Navigator.push(
                      context,
                      MaterialPageRoute(builder: (_) => const PerfilPage()),
                    );
                  } else {
                    Navigator.push(
                      context,
                      MaterialPageRoute(builder: (_) => const LoginPage()),
                    );
                  }
                },
                icon: const Icon(Icons.person),
                style: TextButton.styleFrom(foregroundColor: Colors.blueAccent),
              );
            },
          )
        ],
      ),
      body: productoProvider.isLoading
          ? const Center(child: CircularProgressIndicator())
          : RefreshIndicator(
              onRefresh: () => productoProvider.cargarProductos(),
              child: ListView(
                children:
                    _buildSeccionesPorCategoria(context, productoProvider),
              ),
            ),
    );
  }

  List<Widget> _buildSeccionesPorCategoria(
      BuildContext context, ProductoProvider provider) {
    final categoriasUnicas = {
      for (var p in provider.productos)
        ...p.categorias.map((c) => c.nombre.toLowerCase())
    }.toList();

    categoriasUnicas.sort();

    return categoriasUnicas.map((categoria) {
      final productos = provider.productosPorCategoria(categoria);

      if (productos.isEmpty) return const SizedBox.shrink();

      return Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            child: Text(
              categoria[0].toUpperCase() + categoria.substring(1),
              style: const TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
          SizedBox(
            height: 260,
            child: ListView.separated(
              scrollDirection: Axis.horizontal,
              padding: const EdgeInsets.symmetric(horizontal: 16),
              itemCount: productos.length,
              separatorBuilder: (_, __) => const SizedBox(width: 12),
              itemBuilder: (context, i) {
                final producto = productos[i];
                final precioOriginal = producto.detalle?.precio ?? 0;
                final tieneDescuento =
                    producto.descuento != null && producto.descuento! > 0;
                final precioConDescuento = tieneDescuento
                    ? precioOriginal * (1 - producto.descuento! / 100)
                    : precioOriginal;

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
                  child: Card(
                    elevation: 4,
                    shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(16)),
                    child: Container(
                      width: 160,
                      padding: const EdgeInsets.all(8),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          ClipRRect(
                            borderRadius: BorderRadius.circular(12),
                            child: Image.network(
                              producto.imagenes.isNotEmpty
                                  ? producto.imagenes[0]
                                  : 'https://via.placeholder.com/150',
                              height: 120,
                              width: double.infinity,
                              fit: BoxFit.cover,
                            ),
                          ),
                          const SizedBox(height: 8),
                          Text(
                            producto.nombre,
                            maxLines: 2,
                            overflow: TextOverflow.ellipsis,
                            style: const TextStyle(
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          const SizedBox(height: 4),
                          if (tieneDescuento) ...[
                            Text(
                              '\$${precioOriginal.toStringAsFixed(2)}',
                              style: const TextStyle(
                                decoration: TextDecoration.lineThrough,
                                fontSize: 12,
                                color: Colors.grey,
                              ),
                            ),
                            Text(
                              '\$${precioConDescuento.toStringAsFixed(2)}',
                              style: const TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.bold,
                                color: Colors.red,
                              ),
                            ),
                          ] else ...[
                            Text(
                              '\$${precioOriginal.toStringAsFixed(2)}',
                              style: const TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ],
                        ],
                      ),
                    ),
                  ),
                );
              },
            ),
          ),
          const SizedBox(height: 16),
        ],
      );
    }).toList();
  }
}
