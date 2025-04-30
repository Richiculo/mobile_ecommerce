import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
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

    if (user == null) {
      return Scaffold(
        appBar: AppBar(title: const Text('Mi Perfil')),
        body: const Center(child: Text('No hay datos del usuario')),
      );
    }

    return Scaffold(
      backgroundColor: Colors.grey[100],
      appBar: AppBar(
        title: Text('Mi Perfil', style: GoogleFonts.poppins()),
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
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Card(
            shape:
                RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
            elevation: 4,
            child: Padding(
              padding: const EdgeInsets.all(20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Datos del usuario',
                    style: GoogleFonts.poppins(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 16),
                  _infoTile('Correo', user['correo']),
                  _infoTile('Nombre', user['nombre']),
                  _infoTile('Apellidos', user['apellidos'] ?? ''),
                ],
              ),
            ),
          ),
          const SizedBox(height: 20),
          Card(
            shape:
                RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
            elevation: 4,
            child: Padding(
              padding: const EdgeInsets.all(20),
              child: DireccionSection(),
            ),
          ),
          const SizedBox(height: 30),
          _buildButton(
            context,
            label: 'Ver mis envíos',
            icon: Icons.local_shipping,
            onPressed: () {
              Navigator.of(context).push(
                MaterialPageRoute(builder: (_) => const EnviosPage()),
              );
            },
          ),
          const SizedBox(height: 12),
          _buildButton(
            context,
            label: 'Ver mis ventas',
            icon: Icons.receipt_long,
            onPressed: () {
              Navigator.of(context).push(
                MaterialPageRoute(builder: (_) => const VentasUserPage()),
              );
            },
          ),
          const SizedBox(height: 12),
          _buildButton(
            context,
            label: 'Cerrar sesión',
            icon: Icons.logout,
            color: Colors.redAccent,
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

  Widget _infoTile(String label, String value) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Row(
        children: [
          Text(
            "$label: ",
            style: GoogleFonts.poppins(
              fontWeight: FontWeight.w600,
              fontSize: 16,
            ),
          ),
          Expanded(
            child: Text(
              value,
              style: GoogleFonts.poppins(fontSize: 16),
              overflow: TextOverflow.ellipsis,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildButton(BuildContext context,
      {required String label,
      required IconData icon,
      required VoidCallback onPressed,
      Color color = Colors.blueAccent}) {
    return SizedBox(
      width: double.infinity,
      child: ElevatedButton.icon(
        icon: Icon(icon, color: Colors.white),
        label: Text(
          label,
          style: GoogleFonts.poppins(
            color: Colors.white,
            fontWeight: FontWeight.w600,
          ),
        ),
        onPressed: onPressed,
        style: ElevatedButton.styleFrom(
          padding: const EdgeInsets.symmetric(vertical: 14),
          backgroundColor: color,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
        ),
      ),
    );
  }
}
