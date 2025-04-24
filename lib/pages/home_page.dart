import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/auth_provider.dart';

class HomePage extends StatelessWidget {
  const HomePage({super.key});

  @override
  Widget build(BuildContext context) {
    final authProvider = Provider.of<AuthProvider>(context);
    final user = authProvider.user;

    return Scaffold(
      appBar: AppBar(
        title: const Text('inicio'),
        actions: [
          IconButton(
            onPressed: () async {
              await authProvider.logout();
            },
            icon: const Icon(Icons.logout),
            tooltip: 'Cerrar sesion',
          )
        ],
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            if (user != null) ...[
              Text(
                'Bienvenido, ${user['nombre']} ${user['apellidos']}!',
                style: const TextStyle(fontSize: 20),
              ),
              const SizedBox(height: 20),
            ],
            ElevatedButton(
              onPressed: () async {
                await authProvider.logout();
              },
              child: const Text('Cerrar sesion'),
            ),
          ],
        ),
      ),
    );
  }
}
