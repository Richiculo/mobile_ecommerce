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
  int metodoPagoId = 1;
  bool esDelivery = true;
  int? selectedSucursalId;

  double calcularTotal(List cartItems) {
    double total = 0.0;
    for (var item in cartItems) {
      total += double.parse(item['precio_unitario'].toString()) *
          int.parse(item['cantidad'].toString());
    }
    return total;
  }

  @override
  void initState() {
    super.initState();
    Provider.of<SucursalesProvider>(context, listen: false).getSucursalesP();
    Provider.of<PagoProvider>(context, listen: false).obtenerMetodosPago();
  }

  Future<void> _finalizarCompra() async {
    final cartProvider = Provider.of<CartProvider>(context, listen: false);
    final ventaProvider = Provider.of<VentaProvider>(context, listen: false);
    final authProvider = Provider.of<AuthProvider>(context, listen: false);
    final pagoProvider = Provider.of<PagoProvider>(context, listen: false);
    dynamic direccion = authProvider.user?['direccion'];

    setState(() => _isLoading = true);

    try {
      final total = calcularTotal(cartProvider.cartItems);
      final direccionId = direccion is Map ? direccion['id'] : direccion;

      if (esDelivery && direccionId == null) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Debes registrar una dirección.')),
        );
        setState(() => _isLoading = false);
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
        if (metodoPagoId == 1) {
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
              await pagoProvider.confirmar(ventaPendiente['pago'].toString());

              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('Pago exitoso!')),
              );
            } catch (e) {
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(content: Text('Error en el pago: $e')),
              );
            }
          }
        } else {
          await pagoProvider.confirmar(ventaPendiente['pago'].toString());
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Compra registrada!')),
          );
        }

        cartProvider.clearCart();
        Navigator.of(context).pushReplacement(
          MaterialPageRoute(builder: (_) => const HomePage()),
        );
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error al procesar la compra: $e')),
      );
    } finally {
      setState(() => _isLoading = false);
    }
  }

  Widget _buildCartItem(dynamic item) {
    final producto = item['producto'];
    return Container(
      margin: const EdgeInsets.only(bottom: 8),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(8),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withOpacity(0.2),
            spreadRadius: 1,
            blurRadius: 2,
            offset: const Offset(0, 1),
          ),
        ],
      ),
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: Row(
          children: [
            Container(
              width: 40,
              height: 40,
              decoration: BoxDecoration(
                color: Colors.deepPurple.withOpacity(0.1),
                borderRadius: BorderRadius.circular(8),
              ),
              child: const Icon(Icons.shopping_bag_outlined,
                  color: Colors.deepPurple),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    producto['nombre'],
                    style: const TextStyle(fontWeight: FontWeight.bold),
                  ),
                  Text(
                    'Cantidad: ${item['cantidad']} • \$${item['precio_unitario']} c/u',
                    style: TextStyle(color: Colors.grey.shade700, fontSize: 13),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final cartItems = Provider.of<CartProvider>(context).cartItems;
    final total = calcularTotal(cartItems);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Confirmar Compra'),
        backgroundColor: Colors.deepPurple,
        foregroundColor: Colors.white,
      ),
      body: _isLoading
          ? const Center(
              child: CircularProgressIndicator(color: Colors.deepPurple))
          : cartItems.isEmpty
              ? const Center(child: Text('Tu carrito está vacío.'))
              : Column(
                  children: [
                    Expanded(
                      child: SingleChildScrollView(
                        padding: const EdgeInsets.all(16),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            // Resumen del carrito
                            Container(
                              margin: const EdgeInsets.only(bottom: 16),
                              child: const Text(
                                'Resumen del carrito',
                                style: TextStyle(
                                  fontSize: 18,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ),

                            // Items del carrito (using for loop instead of spread operator)
                            Column(
                              children: [
                                for (var item in cartItems)
                                  _buildCartItem(item),
                              ],
                            ),

                            const SizedBox(height: 20),
                            const Divider(),

                            // Método de pago
                            Container(
                              margin: const EdgeInsets.symmetric(vertical: 16),
                              child: const Text(
                                'Método de pago',
                                style: TextStyle(
                                  fontSize: 18,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ),

                            Consumer<PagoProvider>(
                              builder: (context, pagoProvider, _) {
                                if (pagoProvider.isLoading) {
                                  return const Padding(
                                    padding: EdgeInsets.all(8),
                                    child: LinearProgressIndicator(),
                                  );
                                }
                                final metodos = pagoProvider.metodosPago;
                                return DropdownButtonFormField<int>(
                                  value: metodoPagoId,
                                  decoration: const InputDecoration(
                                    labelText: 'Selecciona un método',
                                    border: OutlineInputBorder(),
                                  ),
                                  items: metodos
                                      .map((m) => DropdownMenuItem<int>(
                                          value: m['id'],
                                          child: Text(m['nombre'])))
                                      .toList(),
                                  onChanged: (val) {
                                    setState(() => metodoPagoId = val!);
                                  },
                                );
                              },
                            ),

                            const SizedBox(height: 20),
                            const Divider(),

                            // Método de entrega
                            Container(
                              margin: const EdgeInsets.symmetric(vertical: 16),
                              child: const Text(
                                'Método de entrega',
                                style: TextStyle(
                                  fontSize: 18,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ),

                            Container(
                              decoration: BoxDecoration(
                                border: Border.all(color: Colors.grey.shade300),
                                borderRadius: BorderRadius.circular(8),
                              ),
                              margin: const EdgeInsets.only(bottom: 8),
                              child: RadioListTile<bool>(
                                title: const Text('Delivery (a domicilio)'),
                                value: true,
                                groupValue: esDelivery,
                                activeColor: Colors.deepPurple,
                                onChanged: (val) =>
                                    setState(() => esDelivery = val!),
                              ),
                            ),

                            Container(
                              decoration: BoxDecoration(
                                border: Border.all(color: Colors.grey.shade300),
                                borderRadius: BorderRadius.circular(8),
                              ),
                              margin: const EdgeInsets.only(bottom: 16),
                              child: RadioListTile<bool>(
                                title: const Text('Recoger en sucursal'),
                                value: false,
                                groupValue: esDelivery,
                                activeColor: Colors.deepPurple,
                                onChanged: (val) =>
                                    setState(() => esDelivery = val!),
                              ),
                            ),

                            if (!esDelivery)
                              Consumer<SucursalesProvider>(
                                builder: (context, provider, _) {
                                  final sucursales = provider.sucursales;
                                  return Container(
                                    margin: const EdgeInsets.only(bottom: 16),
                                    child: DropdownButtonFormField<int>(
                                      value: selectedSucursalId,
                                      decoration: const InputDecoration(
                                        labelText: 'Sucursal',
                                        border: OutlineInputBorder(),
                                      ),
                                      items: sucursales
                                          .map((s) => DropdownMenuItem<int>(
                                                value: s['id'],
                                                child: Text(s['nombre']),
                                              ))
                                          .toList(),
                                      onChanged: (val) => setState(
                                          () => selectedSucursalId = val),
                                    ),
                                  );
                                },
                              ),

                            const SizedBox(height: 16),
                          ],
                        ),
                      ),
                    ),

                    // Bottom payment bar
                    Container(
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withOpacity(0.1),
                            blurRadius: 4,
                            offset: const Offset(0, -2),
                          ),
                        ],
                      ),
                      child: SafeArea(
                        child: Row(
                          children: [
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  const Text('Total a pagar:'),
                                  Text(
                                    '\$${total.toStringAsFixed(2)}',
                                    style: const TextStyle(
                                      fontSize: 20,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                            ElevatedButton.icon(
                              style: ElevatedButton.styleFrom(
                                backgroundColor: Colors.deepPurple,
                                foregroundColor: Colors.white,
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 20,
                                  vertical: 12,
                                ),
                              ),
                              onPressed: _finalizarCompra,
                              icon: const Icon(Icons.payment),
                              label: const Text(
                                'Finalizar Compra',
                                style: TextStyle(fontWeight: FontWeight.bold),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
    );
  }
}
