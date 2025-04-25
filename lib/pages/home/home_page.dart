import 'package:flutter/material.dart';
import 'package:mobile_ecommerce/pages/login_page.dart';
import 'package:mobile_ecommerce/providers/auth_provider.dart';
import 'package:provider/provider.dart';
import '../../providers/producto_provider.dart';
import '../home/widgets/producto_card.dart';
import '../perfil_page.dart';

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
          ? Center(child: CircularProgressIndicator())
          : RefreshIndicator(
              onRefresh: () => productoProvider.cargarProductos(),
              child: SingleChildScrollView(
                child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      _buildSeccion(context,
                          titulo: '🔥 En Descuento',
                          productos: productoProvider.productosEnDescuento()),
                    ]),
              ),
            ),
    );
  }

  Widget _buildSeccion(BuildContext context,
      {required String titulo, required List productos}) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
          child: Text(
            titulo,
            style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
          ),
        ),
        SizedBox(
          height: 240,
          child: ListView.builder(
            shrinkWrap: true,
            primary: false,
            scrollDirection: Axis.horizontal,
            physics: BouncingScrollPhysics(),
            padding: const EdgeInsets.symmetric(horizontal: 16),
            itemCount: productos.length,
            itemBuilder: (context, index) =>
                ProductoCard(producto: productos[index]),
          ),
        ),
      ],
    );
  }
}
