import 'package:flutter/material.dart';
import 'package:mobile_ecommerce/providers/productos/producto_provider.dart';
import 'package:mobile_ecommerce/providers/sucursales/sucursales_provider.dart';
import 'package:provider/provider.dart';
import 'package:mobile_ecommerce/providers/auth/auth_provider.dart';
import 'pages/home/home_page.dart';
import 'package:mobile_ecommerce/providers/pedidos/cart_provider.dart';
import 'package:mobile_ecommerce/providers/pedidos/venta_provider.dart';
import 'package:flutter_stripe/flutter_stripe.dart';
import 'package:mobile_ecommerce/providers/pedidos/pago_provider.dart';
import 'package:mobile_ecommerce/providers/envios/envios_provider.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  Stripe.publishableKey =
      'pk_test_51RIMga4EVPnJsl9Ev2glEjjCHrVQCGlR2pOosyTJ3rwepZ2RbBbfkY7gkDbOjVd1AcXJ3TQjpzCA3L2Vt6oGL9qj00iu7cGQP0';
  await Stripe.instance.applySettings();
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider(
            create: (_) => AuthProvider()..checkLoginStatus()),
        ChangeNotifierProvider(
            create: (_) => ProductoProvider()..cargarProductos()),
        ChangeNotifierProvider(create: (_) => CartProvider()),
        ChangeNotifierProvider(create: (_) => VentaProvider()),
        ChangeNotifierProvider(create: (_) => SucursalesProvider()),
        ChangeNotifierProvider(create: (_) => PagoProvider()),
        ChangeNotifierProvider(create: (_) => EnviosProvider()),
      ],
      child: MaterialApp(
        title: 'Ecommerce App',
        theme: ThemeData(
          primarySwatch: Colors.indigo,
          useMaterial3: true,
        ),
        home: HomePage(),
      ),
    );
  }
}
