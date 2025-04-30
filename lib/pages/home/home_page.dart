import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:shimmer/shimmer.dart';
import 'package:provider/provider.dart';

import 'package:mobile_ecommerce/pages/login_page.dart';
import 'package:mobile_ecommerce/providers/auth/auth_provider.dart';
import 'package:mobile_ecommerce/providers/pedidos/cart_provider.dart';
import '../../providers/productos/producto_provider.dart';
import '../perfil/perfil_page.dart';
import '../cart_page.dart';
import '../detalle_producto_page.dart';

class HomePage extends StatelessWidget {
  const HomePage({super.key});

  @override
  Widget build(BuildContext context) {
    final productoProvider = Provider.of<ProductoProvider>(context);
    final theme = Theme.of(context);

    return Scaffold(
      appBar: AppBar(
        elevation: 0,
        backgroundColor: Colors.white,
        title: Text(
          'ElectroTech',
          style: GoogleFonts.poppins(
            fontWeight: FontWeight.bold,
            fontSize: 22,
            color: theme.primaryColor,
          ),
        ),
        actions: [
          Consumer<AuthProvider>(
            builder: (context, auth, _) {
              return IconButton(
                icon: const Icon(Icons.search, color: Colors.black87),
                onPressed: () {
                  // Aquí puedes implementar la búsqueda
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('Búsqueda próximamente')),
                  );
                },
              );
            },
          ),
          Consumer2<AuthProvider, CartProvider>(
            builder: (context, auth, cart, _) {
              return Stack(
                alignment: Alignment.center,
                children: [
                  IconButton(
                    icon: const Icon(Icons.shopping_cart_outlined,
                        color: Colors.black87),
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
                                'Debes iniciar sesión para ver el carrito'),
                          ),
                        );
                      }
                    },
                  ),
                  if (auth.isAuthenticated && cart.cartItems.isNotEmpty)
                    Positioned(
                      top: 8,
                      right: 8,
                      child: Container(
                        padding: const EdgeInsets.all(4),
                        decoration: BoxDecoration(
                          color: Colors.red,
                          shape: BoxShape.circle,
                        ),
                        constraints: const BoxConstraints(
                          minWidth: 16,
                          minHeight: 16,
                        ),
                        child: Text(
                          '${cart.cartItems.length}',
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 10,
                            fontWeight: FontWeight.bold,
                          ),
                          textAlign: TextAlign.center,
                        ),
                      ),
                    ),
                ],
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
                icon: Icon(
                  auth.isAuthenticated
                      ? Icons.account_circle
                      : Icons.account_circle_outlined,
                  color: Colors.black87,
                ),
              );
            },
          ),
        ],
      ),
      body: productoProvider.isLoading
          ? _buildShimmerLoader()
          : RefreshIndicator(
              color: theme.primaryColor,
              onRefresh: () => productoProvider.cargarProductos(),
              child: CustomScrollView(
                slivers: [
                  // Categorías horizontales
                  SliverToBoxAdapter(
                    child: _buildCategoriesRow(context, productoProvider),
                  ),

                  // Secciones por categoría
                  SliverList(
                    delegate: SliverChildListDelegate(
                      _buildSeccionesPorCategoria(context, productoProvider),
                    ),
                  ),
                ],
              ),
            ),
    );
  }

  // Categorías horizontales
  Widget _buildCategoriesRow(BuildContext context, ProductoProvider provider) {
    final categoriasUnicas = {
      for (var p in provider.productos)
        ...p.categorias.map((c) => c.nombre.toLowerCase())
    }.toList()
      ..sort();

    return Container(
      margin: const EdgeInsets.only(top: 24),
      height: 100,
      child: ListView.builder(
        scrollDirection: Axis.horizontal,
        padding: const EdgeInsets.symmetric(horizontal: 8),
        itemCount: categoriasUnicas.length,
        itemBuilder: (context, index) {
          final categoria = categoriasUnicas[index];
          final iconData = _getCategoryIcon(categoria);

          return Container(
            width: 80,
            margin: const EdgeInsets.symmetric(horizontal: 8),
            child: Column(
              children: [
                Container(
                  width: 60,
                  height: 60,
                  decoration: BoxDecoration(
                    color: Colors.blue.shade50,
                    shape: BoxShape.circle,
                  ),
                  child: Icon(
                    iconData,
                    color: Theme.of(context).primaryColor,
                    size: 30,
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  categoria[0].toUpperCase() + categoria.substring(1),
                  style: GoogleFonts.poppins(
                    fontSize: 12,
                    fontWeight: FontWeight.w500,
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  textAlign: TextAlign.center,
                ),
              ],
            ),
          );
        },
      ),
    );
  }

  // Obtiene un ícono para cada categoría
  IconData _getCategoryIcon(String categoria) {
    switch (categoria.toLowerCase()) {
      case 'smartphones':
        return Icons.smartphone;
      case 'laptops':
        return Icons.laptop;
      case 'tablets':
        return Icons.tablet_android;
      case 'audio':
        return Icons.headphones;
      case 'accesorios':
        return Icons.cable;
      case 'televisores':
        return Icons.tv;
      case 'cámaras':
        return Icons.camera_alt;
      case 'gaming':
        return Icons.sports_esports;
      default:
        return Icons.devices_other;
    }
  }

  // Shimmer para carga
  Widget _buildShimmerLoader() {
    return ListView(
      padding: const EdgeInsets.all(16),
      children: [
        // Shimmer para banner
        Shimmer.fromColors(
          baseColor: Colors.grey.shade300,
          highlightColor: Colors.grey.shade100,
          child: Container(
            height: 150,
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(16),
            ),
          ),
        ),
        const SizedBox(height: 24),

        // Shimmer para categorías
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
          children: List.generate(
            4,
            (index) => Shimmer.fromColors(
              baseColor: Colors.grey.shade300,
              highlightColor: Colors.grey.shade100,
              child: Column(
                children: [
                  Container(
                    width: 60,
                    height: 60,
                    decoration: const BoxDecoration(
                      color: Colors.white,
                      shape: BoxShape.circle,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Container(
                    width: 60,
                    height: 10,
                    color: Colors.white,
                  ),
                ],
              ),
            ),
          ),
        ),
        const SizedBox(height: 24),

        // Shimmer para productos
        Row(
          children: [
            Expanded(
              child: Shimmer.fromColors(
                baseColor: Colors.grey.shade300,
                highlightColor: Colors.grey.shade100,
                child: Container(
                  height: 20,
                  color: Colors.white,
                ),
              ),
            ),
            const SizedBox(width: 80),
          ],
        ),
        const SizedBox(height: 16),

        // Shimmer para lista de productos
        SizedBox(
          height: 250,
          child: ListView.separated(
            scrollDirection: Axis.horizontal,
            itemCount: 3,
            separatorBuilder: (_, __) => const SizedBox(width: 16),
            itemBuilder: (_, __) => Shimmer.fromColors(
              baseColor: Colors.grey.shade300,
              highlightColor: Colors.grey.shade100,
              child: Container(
                width: 180,
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(16),
                ),
              ),
            ),
          ),
        ),
      ],
    );
  }

  // Productos por categoría
  List<Widget> _buildSeccionesPorCategoria(
      BuildContext context, ProductoProvider provider) {
    final categoriasUnicas = {
      for (var p in provider.productos)
        ...p.categorias.map((c) => c.nombre.toLowerCase())
    }.toList()
      ..sort();

    return categoriasUnicas.map((categoria) {
      final productos = provider.productosPorCategoria(categoria);

      if (productos.isEmpty) return const SizedBox.shrink();

      return Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 24, 16, 8),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  categoria[0].toUpperCase() + categoria.substring(1),
                  style: GoogleFonts.poppins(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                TextButton(
                  onPressed: () {
                    // Navegar a todos los productos de esta categoría
                  },
                  child: Text(
                    'Ver todos',
                    style: TextStyle(color: Theme.of(context).primaryColor),
                  ),
                ),
              ],
            ),
          ),
          SizedBox(
            height: 220, // Reducido de 260 a 220
            child: ListView.builder(
              scrollDirection: Axis.horizontal,
              padding: const EdgeInsets.symmetric(horizontal: 16),
              itemCount: productos.length,
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
                  child: Container(
                    width: 160,
                    margin: const EdgeInsets.only(right: 12, bottom: 4),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(16),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.grey.withOpacity(0.1),
                          blurRadius: 6,
                          offset: const Offset(0, 2),
                        ),
                      ],
                    ),
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Container(
                          height: 100, // Reducido de 110 a 100
                          decoration: BoxDecoration(
                            color: Colors.grey.shade100,
                            borderRadius: const BorderRadius.only(
                              topLeft: Radius.circular(16),
                              topRight: Radius.circular(16),
                            ),
                          ),
                          child: Center(
                            child: Icon(
                              _getProductIcon(producto.nombre),
                              size: 36, // Reducido de 40 a 36
                              color: Colors.grey.shade400,
                            ),
                          ),
                        ),
                        Padding(
                          padding:
                              const EdgeInsets.all(10), // Reducido de 12 a 10
                          child: Column(
                            mainAxisSize: MainAxisSize.min,
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                producto.nombre,
                                maxLines: 1, // Reducido de 2 a 1
                                overflow: TextOverflow.ellipsis,
                                style: GoogleFonts.poppins(
                                  fontWeight: FontWeight.w600,
                                  fontSize: 12, // Reducido de 13 a 12
                                ),
                              ),
                              const SizedBox(height: 4), // Reducido de 8 a 4
                              if (tieneDescuento) ...[
                                Text(
                                  '${precioOriginal.toStringAsFixed(2)} Bs',
                                  style: TextStyle(
                                    decoration: TextDecoration.lineThrough,
                                    fontSize: 10, // Reducido de 11 a 10
                                    color: Colors.grey.shade600,
                                  ),
                                ),
                                Text(
                                  '${precioConDescuento.toStringAsFixed(2)} Bs',
                                  style: GoogleFonts.poppins(
                                    fontSize: 13, // Reducido de 15 a 13
                                    fontWeight: FontWeight.bold,
                                    color: Colors.red,
                                  ),
                                ),
                              ] else ...[
                                Text(
                                  '${precioOriginal.toStringAsFixed(2)} Bs',
                                  style: GoogleFonts.poppins(
                                    fontSize: 13, // Reducido de 15 a 13
                                    fontWeight: FontWeight.bold,
                                    color: Colors.black87,
                                  ),
                                ),
                              ],
                              // Las estrellas de valoración se han eliminado
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
        ],
      );
    }).toList();
  }

  // Obtiene un ícono para cada producto según su nombre
  IconData _getProductIcon(String nombre) {
    nombre = nombre.toLowerCase();
    if (nombre.contains('smartphone') ||
        nombre.contains('celular') ||
        nombre.contains('phone')) {
      return Icons.smartphone;
    } else if (nombre.contains('laptop') || nombre.contains('notebook')) {
      return Icons.laptop;
    } else if (nombre.contains('tv') || nombre.contains('televisor')) {
      return Icons.tv;
    } else if (nombre.contains('auricular') || nombre.contains('headphone')) {
      return Icons.headphones;
    } else if (nombre.contains('reloj') || nombre.contains('watch')) {
      return Icons.watch;
    } else if (nombre.contains('cámara') || nombre.contains('camera')) {
      return Icons.camera_alt;
    } else if (nombre.contains('tablet')) {
      return Icons.tablet_android;
    } else {
      return Icons.devices_other;
    }
  }
}
