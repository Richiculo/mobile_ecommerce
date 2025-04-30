import 'package:flutter/material.dart';
import 'package:mobile_ecommerce/providers/pedidos/pago_provider.dart';
import 'package:provider/provider.dart';
import '../providers/pedidos/cart_provider.dart';
import '../providers/pedidos/venta_provider.dart';
import '../providers/auth/auth_provider.dart';
import '../providers/sucursales/sucursales_provider.dart';
import 'package:flutter_stripe/flutter_stripe.dart';
import 'package:mobile_ecommerce/pages/home/home_page.dart';

class VentaPage extends StatefulWidget {
  const VentaPage({super.key});

  @override
  State<VentaPage> createState() => _VentaPageState();
}

class _VentaPageState extends State<VentaPage> {
  bool _isLoading = false;
  int metodoPagoId = 1; // Temporal
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
    final pagoProvider = Provider.of<PagoProvider>(context, listen: false);
    pagoProvider.obtenerMetodosPago();
  }

  Future<void> _finalizarCompra() async {
    final cartProvider = Provider.of<CartProvider>(context, listen: false);
    final ventaProvider = Provider.of<VentaProvider>(context, listen: false);
    final authProvider = Provider.of<AuthProvider>(context, listen: false);
    final pagoProvider = Provider.of<PagoProvider>(context, listen: false);
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
      print('metodo pago que manda el page: $metodoPagoId');
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
          const SnackBar(content: Text('Venta procesada con éxito!')),
        );

        // 🔥Según el método de pago, decido qué hacer
        if (/* si el metodoPagoId es Stripe */ metodoPagoId == 1) {
          // Lógica de pago con Stripe
          final clientSecret =
              await pagoProvider.createIntent(((total / 7) * 100).toInt());

          if (clientSecret != null) {
            try {
              await Stripe.instance.initPaymentSheet(
                paymentSheetParameters: SetupPaymentSheetParameters(
                  paymentIntentClientSecret: clientSecret,
                  merchantDisplayName: 'Tu Tienda',
                ),
              );

              await Stripe.instance.presentPaymentSheet();

              //  Solo si el pago fue exitoso, confirmamos
              await pagoProvider.confirmar(ventaPendiente['pago'].toString());

              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('Pago exitoso!')),
              );

              // Después de éxito, puedes navegar o limpiar si quieres
            } on Exception catch (e) {
              // Si el usuario cancela o falla el pago
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(content: Text('Error en el pago: $e')),
              );
            }
          }
        } else {
          await pagoProvider.confirmar(ventaPendiente['pago'].toString());
          // Otros métodos de pago (no Stripe)
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Compra registrada!')),
          );
        }
        cartProvider.clearCart();
        // Navegar a PagoPage pasando la venta pendiente
        Navigator.of(context).pushReplacement(
          MaterialPageRoute(builder: (_) => const HomePage()),
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
                    Consumer<PagoProvider>(
                      builder: (context, pagoProvider, _) {
                        if (pagoProvider.isLoading) {
                          return const Padding(
                            padding: EdgeInsets.symmetric(vertical: 8),
                            child: Text('Cargando metodos de pago...'),
                          );
                        }

                        final metodosPago = pagoProvider.metodosPago;
                        if (metodosPago.isEmpty) {
                          return const Padding(
                            padding: EdgeInsets.symmetric(vertical: 8),
                            child: Text('No hay metodos de pago disponibles.'),
                          );
                        }

                        return Padding(
                          padding: const EdgeInsets.symmetric(vertical: 8),
                          child: DropdownButton<int>(
                            value: metodoPagoId,
                            hint: const Text('Selecciona un metodo de pago'),
                            isExpanded: true,
                            items: metodosPago.map((metodo) {
                              return DropdownMenuItem<int>(
                                value: metodo['id'],
                                child: Text(metodo['nombre']),
                              );
                            }).toList(),
                            onChanged: (value) {
                              setState(() {
                                metodoPagoId = value!;
                              });
                            },
                          ),
                        );
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
                        label: const Text('Procesar Venta'),
                      ),
                    ),
                  ],
                ),
    );
  }
}
