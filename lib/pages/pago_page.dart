import 'package:flutter/material.dart';
import 'package:flutter_stripe/flutter_stripe.dart';
import 'package:provider/provider.dart';
import '../providers/pedidos/pago_provider.dart';

class PagoPage extends StatefulWidget {
  final int amount; // en centavos
  final String pagoId; // ID del Pago que quieres confirmar luego
  final dynamic venta; // Venta asociada a este pago

  const PagoPage({
    required this.amount,
    required this.pagoId,
    required this.venta, // Se pasa la venta para referencia
    Key? key,
  }) : super(key: key);

  @override
  State<PagoPage> createState() => _PaymentPageState();
}

class _PaymentPageState extends State<PagoPage> {
  @override
  Widget build(BuildContext context) {
    final paymentProvider = Provider.of<PagoProvider>(context);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Pago'),
      ),
      body: Center(
        child: paymentProvider.isLoading
            ? const CircularProgressIndicator()
            : Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                      'Monto a pagar: \$${widget.amount / 100}', // Monto en formato legible
                      style: const TextStyle(fontSize: 18)),
                  const SizedBox(height: 20),
                  ElevatedButton(
                    onPressed: () async {
                      try {
                        // Crear el cliente secreto para Stripe
                        final clientSecret =
                            await paymentProvider.createIntent(widget.amount);

                        if (clientSecret != null) {
                          await Stripe.instance.initPaymentSheet(
                            paymentSheetParameters: SetupPaymentSheetParameters(
                              paymentIntentClientSecret: clientSecret,
                              merchantDisplayName: 'Tu Tienda',
                            ),
                          );

                          // Mostrar el pago
                          await Stripe.instance.presentPaymentSheet();

                          // Si el pago es exitoso, confirmamos el pago
                          await paymentProvider.confirmar(widget.pagoId);

                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(content: Text('Pago exitoso!')),
                          );

                          // Puedes navegar a la página de confirmación o finalizar la compra
                          Navigator.pop(context); // Volver a la página anterior
                        }
                      } catch (e) {
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(content: Text('Error: $e')),
                        );
                      }
                    },
                    child: const Text('Pagar con Stripe'),
                  ),
                ],
              ),
      ),
    );
  }
}
