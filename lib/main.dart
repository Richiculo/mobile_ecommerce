import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:mobile_ecommerce/providers/auth_provider.dart';
import 'pages/login_page.dart';
import 'pages/home_page.dart';

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
            create: (_) => AuthProvider()..checkLoginStatus())
      ],
      child: MaterialApp(
        title: 'Ecommerce App',
        theme: ThemeData(
          primarySwatch: Colors.indigo,
          useMaterial3: true,
        ),
        home: Consumer<AuthProvider>(
          builder: (context, auth, _) {
            if (auth.isLoading) {
              return const Scaffold(
                body: Center(child: CircularProgressIndicator()),
              );
            }
            return auth.isAuthenticated ? const HomePage() : const LoginPage();
          },
        ),
      ),
    );
  }
}
