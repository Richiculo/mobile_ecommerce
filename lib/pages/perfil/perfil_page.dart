import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../providers/auth/auth_provider.dart';
import '../login_page.dart';
import './editar_perfil_dialog.dart';
import './widgets/direccion_section.dart';
import '../envio_page.dart';
import '../ventas_user_page.dart';

class PerfilPage extends StatelessWidget {
  const PerfilPage({super.key});

  @override
  Widget build(BuildContext context) {
    final auth = Provider.of<AuthProvider>(context);
    final user = auth.user;
    // 1) Si aún no hay user, muestro un mensaje
    if (user == null) {
      return Scaffold(
        appBar: AppBar(title: const Text('Mi Perfil')),
        body: const Center(child: Text('No hay datos del usuario')),
      );
    }

    return Scaffold(
      appBar: AppBar(
        title: const Text('Mi Perfil'),
        actions: [
          IconButton(
            icon: const Icon(Icons.edit),
            onPressed: () => mostrarDialogoEditarPerfil(context, auth, user),
          ),
        ],
      ),
      body: _buildBody(context, user, auth),
    );
  }

  Widget _buildBody(
      BuildContext context, Map<String, dynamic> user, AuthProvider auth) {
    return Padding(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('Correo: ${user['correo']}',
              style: const TextStyle(fontSize: 18)),
          const SizedBox(height: 10),
          Text('Nombre: ${user['nombre']}',
              style: const TextStyle(fontSize: 18)),
          const SizedBox(height: 10),
          Text('Apellidos: ${user['apellidos'] ?? ''}',
              style: const TextStyle(fontSize: 18)),
          const SizedBox(height: 30),
          DireccionSection(),
          const SizedBox(height: 30),
          ElevatedButton.icon(
            icon: const Icon(Icons.local_shipping),
            label: const Text('Ver mis envíos'),
            onPressed: () {
              Navigator.of(context).push(
                MaterialPageRoute(builder: (_) => const EnviosPage()),
              );
            },
          ),
          const SizedBox(height: 10),
          // Botón para ir a Mis Ventas
          ElevatedButton.icon(
            icon: const Icon(Icons.receipt_long),
            label: const Text('Ver mis ventas'),
            onPressed: () {
              Navigator.of(context).push(
                MaterialPageRoute(builder: (_) => const VentasUserPage()),
              );
            },
          ),
          const SizedBox(height: 10),
          ElevatedButton.icon(
            icon: const Icon(Icons.logout),
            label: const Text('Cerrar sesión'),
            onPressed: () {
              auth.logout();
              Navigator.of(context).pushReplacement(
                MaterialPageRoute(builder: (_) => const LoginPage()),
              );
            },
          ),
        ],
      ),
    );
  }
}
