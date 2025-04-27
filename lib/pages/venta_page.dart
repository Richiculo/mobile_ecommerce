import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/pedidos/cart_provider.dart';
import '../providers/pedidos/venta_provider.dart';
import '../providers/auth/auth_provider.dart';
import '../providers/sucursales/sucursales_provider.dart';
import '../pages/pago_page.dart';

class VentaPage extends StatefulWidget {
  const VentaPage({super.key});

  @override
  State<VentaPage> createState() => _VentaPageState();
}

class _VentaPageState extends State<VentaPage> {
  bool _isLoading = false;
  int metodoPagoId = 1; // Temporal: podrías hacer un selector de métodos
  bool esDelivery = true;
  int? selectedSucursalId;

  double calcularTotal(List cartItems) {
    double total = 0.0;
    for (var item in cartItems) {
      double precioUnitario = double.parse(item['precio_unitario'].toString());
      int cantidad = int.parse(item['cantidad'].toString());
      total += precioUnitario * cantidad;
    }
    return total;
  }

  @override
  void initState() {
    super.initState();
    final sucursalesProvider =
        Provider.of<SucursalesProvider>(context, listen: false);
    sucursalesProvider.getSucursalesP();
  }

  Future<void> _finalizarCompra() async {
    final cartProvider = Provider.of<CartProvider>(context, listen: false);
    final ventaProvider = Provider.of<VentaProvider>(context, listen: false);
    final authProvider = Provider.of<AuthProvider>(context, listen: false);
    dynamic direccion = authProvider.user?['direccion'];
    print(direccion);

    setState(() {
      _isLoading = true;
    });

    try {
      final total = calcularTotal(cartProvider.cartItems);
      final direccionId = direccion is Map<String, dynamic>
          ? direccion['id']
          : direccion; // si no es mapa, es directamente el id o null
      print(direccionId);
      if (esDelivery && direccionId == null) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
              content: Text('Debes registrar una dirección para envío.')),
        );
        setState(() {
          _isLoading = false;
        });
        return;
      }

      await ventaProvider.realizarVenta(
        cartId: cartProvider.cartId!,
        total: total,
        metodoPagoId: metodoPagoId,
        esDelivery: esDelivery,
        direccionId: esDelivery ? direccionId : null,
        sucursalId: selectedSucursalId,
      );

      await ventaProvider.obtenerVentaPendiente();
      final ventaPendiente = ventaProvider.venta;

      if (ventaPendiente != null) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Compra realizada con éxito!')),
        );

        // Navegar a PagoPage pasando la venta pendiente
        Navigator.of(context).pushReplacement(
          MaterialPageRoute(
            builder: (context) => PagoPage(
              amount: (total * 100).toInt(), // Monto en centavos
              pagoId: ventaPendiente['id']
                  .toString(), // ID de la venta para confirmar el pago
              venta: ventaPendiente, // Venta asociada al pago
            ),
          ),
        );
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error al procesar la compra: $e')),
      );
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final cartProvider = Provider.of<CartProvider>(context);
    final cartItems = cartProvider.cartItems;
    final authProvider = Provider.of<AuthProvider>(context);
    final user = authProvider.user;
    final direccion = user?['direccion'];
    print(user);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Confirmar Compra'),
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
                          final precio = item['precio_unitario'];

                          return ListTile(
                            title: Text(producto['nombre']),
                            subtitle:
                                Text('Cantidad: $cantidad - \$${precio} c/u'),
                          );
                        },
                      ),
                    ),
                    DropdownButton<int>(
                      value: metodoPagoId,
                      items: const [
                        DropdownMenuItem(
                            value: 1, child: Text('Tarjeta de crédito')),
                        DropdownMenuItem(
                            value: 2, child: Text('Transferencia bancaria')),
                        DropdownMenuItem(
                            value: 3, child: Text('Pago en efectivo')),
                      ],
                      onChanged: (value) {
                        if (value != null) {
                          setState(() {
                            metodoPagoId = value;
                          });
                        }
                      },
                    ),
                    Padding(
                      padding: const EdgeInsets.all(12),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text('¿Cómo deseas recibir tu compra?'),
                          RadioListTile<bool>(
                            title: const Text('Delivery (Envío a domicilio)'),
                            value: true,
                            groupValue: esDelivery,
                            onChanged: (value) {
                              setState(() {
                                esDelivery = value!;
                              });
                            },
                          ),
                          RadioListTile<bool>(
                            title: const Text('Recoger en sucursal'),
                            value: false,
                            groupValue: esDelivery,
                            onChanged: (value) {
                              setState(() {
                                esDelivery = value!;
                              });
                            },
                          ),
                          Consumer<SucursalesProvider>(
                            builder: (context, sucursalProvider, _) {
                              if (sucursalProvider.isLoading) {
                                return const Padding(
                                  padding: EdgeInsets.symmetric(vertical: 8),
                                  child: Text('Cargando sucursales...'),
                                );
                              }

                              final sucursales = sucursalProvider.sucursales;
                              if (sucursales.isEmpty) {
                                return const Padding(
                                  padding: EdgeInsets.symmetric(vertical: 8),
                                  child: Text('No hay sucursales disponibles.'),
                                );
                              }

                              return Padding(
                                padding:
                                    const EdgeInsets.symmetric(vertical: 8),
                                child: DropdownButton<int>(
                                  value: selectedSucursalId,
                                  hint: const Text('Selecciona una sucursal'),
                                  isExpanded: true,
                                  items: sucursales.map((sucursal) {
                                    return DropdownMenuItem<int>(
                                      value: sucursal['id'],
                                      child: Text(sucursal['nombre']),
                                    );
                                  }).toList(),
                                  onChanged: (value) {
                                    setState(() {
                                      selectedSucursalId = value;
                                    });
                                  },
                                ),
                              );
                            },
                          )
                        ],
                      ),
                    ),
                    Padding(
                      padding: const EdgeInsets.all(12),
                      child: ElevatedButton.icon(
                        onPressed: _finalizarCompra,
                        icon: const Icon(Icons.payment),
                        label: const Text('Confirmar Compra'),
                      ),
                    ),
                  ],
                ),
    );
  }
}
