import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/auth_provider.dart';
import 'login_page.dart';

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

    // 2) Si tengo user, construyo la UI
    return Scaffold(
      appBar: AppBar(
        title: const Text('Mi Perfil'),
        actions: [
          IconButton(
            icon: const Icon(Icons.edit),
            onPressed: () => _editarPerfil(context, auth, user),
          ),
        ],
      ),
      body: _buildBody(context, user, auth),
    );
  }

  // 3) Recibe el BuildContext
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
          _buildDireccionSection(context, auth),
          ElevatedButton.icon(
            icon: const Icon(Icons.logout),
            label: const Text('Cerrar sesión'),
            onPressed: () {
              auth.logout();
              // 4) Para no depender de rutas nombradas, usamos un pushReplacement
              Navigator.of(context).pushReplacement(
                MaterialPageRoute(builder: (_) => const LoginPage()),
              );
            },
          ),
        ],
      ),
    );
  }

  void _editarPerfil(
      BuildContext ctx, AuthProvider auth, Map<String, dynamic> user) {
    final nombreCtrl = TextEditingController(text: user['nombre']);
    final apellidosCtrl = TextEditingController(text: user['apellidos']);

    showDialog(
      context: ctx,
      builder: (_) => AlertDialog(
        title: const Text('Editar perfil'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(
              controller: nombreCtrl,
              decoration: const InputDecoration(labelText: 'Nombre'),
            ),
            TextField(
              controller: apellidosCtrl,
              decoration: const InputDecoration(labelText: 'Apellidos'),
            ),
          ],
        ),
        actions: [
          TextButton(
              onPressed: () => Navigator.pop(ctx),
              child: const Text('Cancelar')),
          ElevatedButton(
            onPressed: () async {
              final ok = await auth.updateUser({
                'nombre': nombreCtrl.text,
                'apellidos': apellidosCtrl.text,
              });
              Navigator.pop(ctx);
              ScaffoldMessenger.of(ctx).showSnackBar(
                SnackBar(
                    content: Text(
                        ok ? 'Perfil actualizado' : 'Error al actualizar')),
              );
            },
            child: const Text('Guardar'),
          ),
        ],
      ),
    );
  }

  Widget _buildDireccionSection(BuildContext context, AuthProvider auth) {
    final user = auth.user!;
    final dir = user['direccion'];
    if (dir != null) {
      // Si ya hay dirección, la mostramos con opción a editar
      return Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text('Dirección:',
              style: TextStyle(fontWeight: FontWeight.bold)),
          Text('${dir['calle']} #${dir['numero']}, ${dir['ciudad']}'),
          const SizedBox(height: 10),
          ElevatedButton.icon(
            icon: const Icon(Icons.edit_location_alt),
            label: const Text('Editar dirección'),
            onPressed: () => _editarDireccion(context, auth, dir),
          ),
        ],
      );
    } else {
      // No hay dirección: botón para agregar
      return ElevatedButton.icon(
        icon: const Icon(Icons.add_location),
        label: const Text('Agregar dirección'),
        onPressed: () => _agregarDireccion(context, auth),
      );
    }
  }

  void _agregarDireccion(BuildContext ctx, AuthProvider auth) {
    final paisC = TextEditingController();
    final ciudadC = TextEditingController();
    final calleC = TextEditingController();
    final numeroC = TextEditingController();
    // …otros campos (zona, referencia, departamentoId)

    showDialog(
      context: ctx,
      builder: (_) => AlertDialog(
        title: Text('Nueva dirección'),
        content: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(
                  controller: paisC,
                  decoration: InputDecoration(labelText: 'País')),
              TextField(
                  controller: ciudadC,
                  decoration: InputDecoration(labelText: 'Ciudad')),
              TextField(
                  controller: calleC,
                  decoration: InputDecoration(labelText: 'Calle')),
              TextField(
                  controller: numeroC,
                  decoration: InputDecoration(labelText: 'Número')),
              // … resto de campos
            ],
          ),
        ),
        actions: [
          TextButton(
              onPressed: () => Navigator.pop(ctx), child: Text('Cancelar')),
          ElevatedButton(
            onPressed: () async {
              final ok = await auth.addDireccion({
                'pais': paisC.text,
                'ciudad': ciudadC.text,
                'calle': calleC.text,
                'numero': numeroC.text,
                // …otros campos solicitados por tu serializer
              });
              Navigator.pop(ctx);
              if (ok) {
                ScaffoldMessenger.of(ctx).showSnackBar(
                    SnackBar(content: Text('Dirección agregada')));
              } else {
                ScaffoldMessenger.of(ctx)
                    .showSnackBar(SnackBar(content: Text('Error al añadir')));
              }
            },
            child: Text('Guardar'),
          ),
        ],
      ),
    );
  }

  void _editarDireccion(
      BuildContext ctx, AuthProvider auth, Map<String, dynamic> direccion) {
    final paisC = TextEditingController(text: direccion['pais']);
    final ciudadC = TextEditingController(text: direccion['ciudad']);
    final calleC = TextEditingController(text: direccion['calle']);
    final numeroC = TextEditingController(text: direccion['numero']);
    // otros campos también aquí si tienes

    showDialog(
      context: ctx,
      builder: (_) => AlertDialog(
        title: const Text('Editar dirección'),
        content: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(
                  controller: paisC,
                  decoration: const InputDecoration(labelText: 'País')),
              TextField(
                  controller: ciudadC,
                  decoration: const InputDecoration(labelText: 'Ciudad')),
              TextField(
                  controller: calleC,
                  decoration: const InputDecoration(labelText: 'Calle')),
              TextField(
                  controller: numeroC,
                  decoration: const InputDecoration(labelText: 'Número')),
              // otros campos si hace falta
            ],
          ),
        ),
        actions: [
          TextButton(
              onPressed: () => Navigator.pop(ctx),
              child: const Text('Cancelar')),
          ElevatedButton(
            onPressed: () async {
              final ok = await auth.updateDireccion({
                'pais': paisC.text,
                'ciudad': ciudadC.text,
                'calle': calleC.text,
                'numero': numeroC.text,
                // incluir ID si se requiere para identificar la dirección
              });
              Navigator.pop(ctx);
              ScaffoldMessenger.of(ctx).showSnackBar(
                SnackBar(
                  content: Text(ok
                      ? 'Dirección actualizada'
                      : 'Error al actualizar dirección'),
                ),
              );
            },
            child: const Text('Guardar'),
          ),
        ],
      ),
    );
  }
}
