import 'package:flutter/material.dart';
import 'package:mobile_ecommerce/providers/producto_provider.dart';
import 'package:provider/provider.dart';
import 'package:mobile_ecommerce/providers/auth_provider.dart';
import 'pages/home/home_page.dart';

void main() {
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
